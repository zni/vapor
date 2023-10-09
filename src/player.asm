.include "constants.inc"

.import spawn_player_bullet

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

    LDA player_state
    AND #STATE_PLAYER_ALIVE
    BNE death_spiral

    LDA pad1
    EOR #%11111111
    AND last_frame_pad1
    STA released_pad1
    LDA last_frame_pad1
    EOR #%11111111
    AND pad1
    STA pressed_pad1

;;;; check button presses
    LDA pad1
    AND #BTN_LEFT
    BEQ check_right
    LDA player_x
    CMP #$0a        ; are we at the left boundary?
    BCC check_right
    BEQ check_right
    LDA player_x
    SEC
    SBC #PLAYER_SPEED
    STA player_x
    
check_right:
    LDA pad1
    AND #BTN_RIGHT
    BEQ check_up
    LDA player_x
    CMP #$f0        ; are we at the right boundary?
    BCS check_up
    BEQ check_up
    LDA player_x
    CLC
    ADC #PLAYER_SPEED
    STA player_x
    JMP check_up

death_spiral: JMP done_checking

check_up:
    LDA pad1
    AND #BTN_UP
    BEQ check_down
    LDA player_y
    CMP #$0a        ; are we at the top boundary?
    BCC check_down
    BEQ check_down
    LDA player_y
    SEC
    SBC #PLAYER_SPEED
    STA player_y

check_down:
    LDA pad1
    AND #BTN_DOWN
    BEQ check_a
    LDA player_y
    CMP #$df        ; are we at the bottom boundary?
    BCS check_a
    BEQ check_a
    LDA player_y
    CLC
    ADC #PLAYER_SPEED
    STA player_y

check_a:
    LDA pressed_pad1
    AND #BTN_A
    BEQ done_checking
    JSR spawn_player_bullet


done_checking:
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






.segment "ZEROPAGE"
pad1: .res 1
last_frame_pad1: .res 1
released_pad1: .res 1
pressed_pad1: .res 1
.importzp player_x, player_y, player_state
.exportzp last_frame_pad1