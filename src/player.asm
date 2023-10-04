.include "constants.inc"

.segment "CODE"
.export draw_player
.proc draw_player
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    ; write player ship tile
    LDA #$01
    STA $0201

    ; write player ship attr
    LDA #$00
    STA $0202

    ; write player tile location
    LDA player_y
    STA $0200
    LDA player_x
    STA $0203

    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc

.export update_player
.proc update_player
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

;;;; get controller input
    LDA #$01
    STA CONTROLLER_1
    LDA #$00
    STA CONTROLLER_1

    ; initialize pad1
    LDA #%00000001
    STA pad1

get_button_states:
    LDA CONTROLLER_1
    LSR A            ; Shift the accumulator into the carry flag.
    ROL pad1         ; Shift everything in pad1,
                     ; bringing the carry flag into pad1.
    BCC get_button_states
;;;; end get input

;;;; check button presses
    LDA pad1
    AND #BTN_LEFT
    BEQ check_right
    DEC player_x
check_right:
    LDA pad1
    AND #BTN_RIGHT
    BEQ check_up
    INC player_x
check_up:
    LDA pad1
    AND #BTN_UP
    BEQ check_down
    DEC player_y
check_down:
    LDA pad1
    AND #BTN_DOWN
    BEQ done_checking
    INC player_y
done_checking:
    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc

.segment "ZEROPAGE"
pad1: .res 1
.importzp player_x, player_y, player_dir