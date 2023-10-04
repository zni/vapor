.include "constants.inc"

.segment "CODE"
.import main
.export reset_handler
.proc reset_handler
    SEI
    CLD
    LDX #$00
    STX PPUCTRL
    STX PPUMASK
vblankwait:
    BIT PPUSTATUS
    BPL vblankwait

    LDX #$00
    LDA #$ff
clear_oam:
    STA $0200,x
    INX
    INX
    INX
    INX
    BNE clear_oam

    LDA #%10010000      ; turn on NMIs, sprites use first pattern table
    STA PPUCTRL
    LDA #%00011000      ; turn on screen
    STA PPUMASK

    LDA #$80
    STA player_x
    LDA #$a0
    STA player_y

    LDA #$00
    STA player_dir

    LDX #$00
    LDA #$00
    STA enemy_y,x
    INX
    STA enemy_y,x
    INX
    STA enemy_y,x

    JMP main
.endproc

.segment "ZEROPAGE"
.importzp player_x, player_y, player_dir
.importzp enemy_x, enemy_y