
import tables
export tables

type
    arr* = ref array[128 * 128, int64]
    TestState* = ref tuple[
        mem1: seq[arr],
        mem2: Table[string, arr]]
