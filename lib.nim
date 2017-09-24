
import state


proc init (ts: TestState) {.exportc, dynlib, cdecl.} =
    ts.testSeq = newSeq[int]()


proc update (ts: TestState) {.exportc, dynlib, cdecl.}  =
    
    # Can be used to confirm in the console that the updated lib is now being used
    echo "version 1"
    
    if ts.testSeq.len == 1:
        ts.testSeq.del(0)
    
    ts.testSeq.add(1)
    
    echo "sequence reallocation worked"
    
    
    # Dummy code to be changed be commenting it out/in
    
    var dummy1 = 343424534343
    var dummy2 = 343424534343
    var dummy3 = 343424534343
    var dummy4 = 343424534343
    var dummy5 = 343424534343
    
    dummy1 = dummy2 + dummy3
    dummy2 = dummy3 + dummy4
    dummy3 = dummy4 + dummy5
    dummy4 = dummy5 + dummy1
    dummy5 = dummy1 + dummy2
    dummy1 = dummy2 + dummy3
    dummy2 = dummy3 + dummy4

    dummy1 = dummy2 + dummy3
    dummy2 = dummy3 + dummy4
    dummy3 = dummy4 + dummy5
    dummy4 = dummy5 + dummy1
    dummy5 = dummy1 + dummy2
    dummy1 = dummy2 + dummy3
    dummy2 = dummy3 + dummy4
    
    dummy1 = dummy2 + dummy3
    dummy2 = dummy3 + dummy4
    dummy3 = dummy4 + dummy5
    dummy4 = dummy5 + dummy1
    dummy5 = dummy1 + dummy2
    dummy1 = dummy2 + dummy3
    dummy2 = dummy3 + dummy4
