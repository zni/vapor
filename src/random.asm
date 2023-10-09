.include "constants.inc"

.segment "CODE"
; get_random
; generate random numbers with xorshift.
;   @return A - random number is placed in the accumulator
.export get_random
.proc get_random

    LDA seeded
    CMP #$01
    BEQ @gen
    LDA tick
    STA lfsr
    LDA #$01
    STA seeded

@gen:
    LDA lfsr

    LSR A
    LSR A
    EOR lfsr            ; lfsr ^= lfsr >> 2
    STA lfsr

    ASL A
    ASL A
    ASL A
    ASL A
    ASL A
    EOR lfsr            ; lfsr ^= lfsr << 5
    STA lfsr

    LSR A
    LSR A
    LSR A
    LSR A
    LSR A
    LSR A
    LSR A
    EOR lfsr            ; lfsr ^= lfsr >> 7
    STA lfsr

    RTS
.endproc

.segment "ZEROPAGE"
lfsr: .res 1
seeded: .res 1
.importzp tick, tock