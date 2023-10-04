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

    LDA player_x
    CMP #$e0
    BCC not_at_right_edge
    ; if not BCC, we are greater than $e0
    LDA #$00
    STA player_dir          ; start moving left
    JMP direction_set

not_at_right_edge:
    LDA player_x
    CMP #$10
    BCS direction_set
    ; if not BCS, we are less than $10
    LDA #$01
    STA player_dir

direction_set:
    LDA player_dir
    CMP #$01
    BEQ move_right
    ; if player_dir - $01 is not zero,
    ; that means player_dir was $00 and
    ; we need to move left
    SEC
    LDA player_x
    SBC #PLAYER_SPEED
    STA player_x
    JMP exit_subroutine
move_right:
    CLC
    LDA player_x
    ADC #PLAYER_SPEED
    STA player_x

exit_subroutine:
    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc

.segment "ZEROPAGE"
.importzp player_x, player_y, player_dir