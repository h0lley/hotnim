# game logic file 
#
# compile with `nim c --app:lib game`

import state


{.pragma: rtl, exportc, dynlib, cdecl.}


proc init* (ts: TestState) {.rtl.} =
    # ts.testSeq = newSeq[int]()

    ts.mem1 = newSeq[arr]()
    ts.mem2 = initTable[string, arr]()
    
    for i in 0..100:
        echo i
        ts.mem2[$i] = new arr
        ts.mem1.add(new arr)


# frameNum -- which number frame this is
# dt       -- time since last update (in seconds)
# total    -- total elapsed time (in seconds)
proc update*(ts: TestState, frameNum: int; dt, total: float) {.rtl.} =
  echo total, ": update v3 [#", frameNum, "] dt=", dt
