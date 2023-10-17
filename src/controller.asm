.include "constants.inc"

.ZEROPAGE
pad1: .res 1
last_frame_pad1: .res 1
released_pad1: .res 1
pressed_pad1: .res 1
.exportzp pad1, last_frame_pad1, released_pad1, pressed_pad1

.CODE
.export get_controller_state
.proc get_controller_state
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    LDA #$01
    STA CONTROLLER_1
    LDA #$00
    STA CONTROLLER_1

    ; initialize pad1
    LDA #%00000001
    STA pad1

@get_button_states:
    LDA CONTROLLER_1
    LSR A                           ; Shift the accumulator into the carry flag.
    ROL pad1                        ; Shift everything in pad1,
                                    ; bringing the carry flag into pad1.
    BCC @get_button_states

    LDA pad1
    EOR #%11111111
    AND last_frame_pad1
    STA released_pad1
    LDA last_frame_pad1
    EOR #%11111111
    AND pad1
    STA pressed_pad1

    LDA pad1
    STA last_frame_pad1

    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc