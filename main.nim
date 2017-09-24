
import state, dynlib, os


when defined(Windows):
    const LibName = "lib.dll"
elif defined(Linux):
    const LibName = "liblib.so"
else:
    const LibName = ""
    assert(false, "Add the lib name format for your OS")


type
    LibInit = proc (ts: TestState) {.nimcall.}
    LibUpdate = proc (ts: TestState) {.nimcall.}
    Lib = tuple[handle: LibHandle, init: LibInit, update: LibUpdate]


proc loadLib: Lib =
    var fullLibName = LibName
    when defined(Windows):
        fullLibName = "." & LibName
        # Need to make copy so windows doesn't block the file we want to keep rewriting
        copyFile(LibName, fullLibName)
    
    result.handle = loadLib("./" & fullLibName)
    result.init = cast[LibInit](result.handle.symAddr("init"))
    result.update = cast[LibUpdate](result.handle.symAddr("update"))


proc main =
    let ts = new TestState
    var lib = loadLib()
    
    # Call newSeq in the linked code
    lib.init(ts)
    
    echo "exit via ctrl + c"
    while true:
        
        # 
        lib.update(ts)
        
        # Reload lib every two seconds
        sleep(2000)
        unloadLib(lib.handle)
        lib = loadLib()


main()
