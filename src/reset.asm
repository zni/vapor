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
    STA ppuctrl_settings
    LDA #%00011000      ; turn on screen - show bg / sprites
    STA PPUMASK

    LDA #$80
    STA player_x
    LDA #$a0
    STA player_y

    LDA #$00
    STA last_frame_pad1

    LDX #$00
init_bullet_state:
    STA bullet_state,x
    INX
    CPX #MAX_BULLET_POOL_SIZE
    BNE init_bullet_state

    JMP main
.endproc

.segment "ZEROPAGE"
.importzp player_x, player_y, last_frame_pad1, bullet_state
.importzp ppuctrl_settings