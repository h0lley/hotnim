# This runs the game
#
# compile with `nim c --threads:on runner`

import os, osproc, dynlib, locks, times
import stopwatch

import state


# Where your nim compiler is located
when defined(windows):
  const nimEXE = "nim"
else:
  const nimEXE = "/home/schminzt/nim/bin/nim"


# Platform independant way of building a DLL path
proc buildDLLPath(name: string): string =
  when defined(windows):
    return "." & name & ".dll"
  elif defined(macosx):
    return "./lib" & name & ".dylib"
  else:
    # Assume it's linux or UNIX
    return "./lib" & name & ".so"


# Proc prototype
type
  initProc = proc (ts: TestState) {.nimcall.}
  updateProc = proc (ts: TestState, frameNum: int; dt, total: float) {.nimcall.}


# Global variables
var
  dll: LibHandle      # Library that's loaded
  init: initProc
  update: updateProc  # Function to call, and reload
  dllReady = false    # DLL has been loaded or not
  running = true      # Running the "game,"

  # Locks for threading & flags
  dllLock: Lock
  dllReadyLock: Lock
  runningLock: Lock


# Setup the loading lock
initLock(dllLock)
initLock(dllReadyLock)
initLock(runningLock)


# Checks to see if a module/file has been changed, then  will recompile it and
# load the DLL.  It keeps on doing this until `running` has been set to `false`
# This proc should be run in its own thread.
proc loadDLL(name: string) {.thread.} =
  # Make some paths
  let
    dllPath = buildDLLPath(name)
    nimSrcPath = name & ".nim"

  var
    lastWriteTime = 0.Time 
    isRunning = true

  while isRunning:
    # Check for change on .nim file
    var writeTime = 0.Time
    try:
      writeTime = getFileInfo(nimSrcPath).lastWriteTime
    except:
      discard

    if lastWriteTime < writeTime:
      echo "Write detected on " & nimSrcPath
      lastWriteTime = writeTime

      # if so, try compile it
      let
        compile = startProcess(nimEXE, "", ["c", "--app:lib", name])
        compileStatus = waitForExit(compile)    # TODO maybe should have a timeout
      close(compile)

      # if compilaiton was good, load the DLL
      if compileStatus == 0:
        # Get the lock
        acquire(dllLock)

        # unload the library if it has already been loaded
        if dll != nil:
          unloadLib(dll)
          dll = nil
        
        # windows needs to use a copy as it blocks the dll for writing
        when defined(windows):
          copyFile(name & ".dll", dllPath)
        
        # (Re)load the library
        echo "Attempting to load " & dllPath
        dll = loadLib(dllPath)
        if dll != nil:
          let initAddr = dll.symAddr("init")
          let updateAddr = dll.symAddr("update")
        
          if initAddr != nil:
            init = cast[initProc](initAddr)
        
          if updateAddr != nil:
            update = cast[updateProc](updateAddr)

            echo "Successfully loaded DLL & functions " & dllPath
            acquire(dllReadyLock)
            dllReady = true
            release(dllReadyLock)
          else:
            echo "Error, Was able to load DLL, but not functions " & dllPath
        else:
          echo "Error, wasn't able to load DLL " & dllPath

        # Release the lock
        release(dllLock)
      else: 
        # Bad compile, print a message
        echo nimSrcPath & " failed to compile; not reloading"
    
    # sleep for 1/5 of a second, then check for changes again
    sleep(200)

    # Check for quit
    acquire(runningLock)
    isRunning = running
    release(runningLock)


# Block until the DLL is loaded
proc waitForDLLReady() =
  acquire(dllReadyLock)
  var ready = dllReady
  release(dllReadyLock)

  while not ready:
    # Test again every 1/5 second
    sleep(200)  
    acquire(dllReadyLock)
    ready = dllReady
    release(dllReadyLock)


# Main game prodecedure and loop 
proc main() = 
  # Loading a DLL needs to be in it's own thread
  var dllLoadingThread: Thread[string]
  createThread(dllLoadingThread, loadDLL, "game")

  # Setup some of the game stuff
  var
    sw = stopwatch()
    lastFrameTime = 0.0
    frameCount = 0
    t = 0.0

  # Hold here until our DLLs are ready
  echo "Waiting for the DLL to be loaded..."
  waitForDLLReady()
  
  # Persistent state
  let ts = new TestState
  init(ts)
  
  # Start the loop
  echo "Running for 60 seconds..."
  sw.start()
  while t < 60.1:
    let delta = t - lastFrameTime
    if delta >= 0.5:
      # run a frame
      update(ts, frameCount, delta, t)

      # Set next
      lastFrameTime = t
      frameCount += 1

    t = sw.secs

  echo "Shutting down."

  # Cleanup our threads
  acquire(runningLock)
  running = false
  release(runningLock)
  joinThread(dllLoadingThread)


main()
