.include "constants.inc"

.segment "CODE"
; get_random
; generate random numbers based on the tick, tock variables.
;   @return A - random number is placed in the accumulator
.export get_random
.proc get_random

    LDA seeded
    CMP #$01
    BEQ @gen
    LDA #$ff
    STA lfsr
    LDA #$01
    STA seeded

@gen:
    LDA lfsr
    ROL A
    EOR lfsr
    ROL A
    ROL A
    ROL A
    EOR lfsr
    ROL A
    ROL A
    ROL A
    ROL A
    ROL A
    EOR lfsr
    STA lfsr

    RTS
.endproc

.segment "ZEROPAGE"
lfsr: .res 1
seeded: .res 1
.importzp tick, tock