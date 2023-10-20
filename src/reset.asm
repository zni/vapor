.include "constants.inc"

.segment "CODE"
.import main
.import title_nmi_handler
.import change_nmi_handler
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

    LDX #<title_nmi_handler
    LDY #>title_nmi_handler
    JSR change_nmi_handler

    LDA PPUSTATUS
    LDA #%10010000      ; turn on NMIs, sprites use first pattern table
    STA PPUCTRL
    STA ppuctrl_settings
    LDA #PPU_SHOW_SPRITES    ; turn on screen - show bg / sprites
    STA PPUMASK

    LDA #$80
    STA player_x
    LDA #$a0
    STA player_y
    
    LDA #$00
    EOR #STATE_PLAYER_ALIVE
    STA player_state

    LDA #$00
    STA last_frame_pad1
    STA tick
    STA tock

    LDX #$00
init_bullet_state:
    LDA #$00
    STA bullet_state,x
    LDA #$ff
    STA bullet_x,x
    STA bullet_y,x
    INX
    CPX #MAX_BULLET_POOL_SIZE
    BNE init_bullet_state

    LDX #$00
init_enemy_state:
    LDA #$00
    STA enemy_state,x
    INX
    CPX #MAX_ENEMY_POOL_SIZE
    BNE init_enemy_state

    LDX #$00
init_enemy_bullet_state:
    LDA #$00
    STA enemy_bullet_state,x
    LDA #$ff
    STA enemy_bullet_x,x
    STA enemy_bullet_y,y
    INX
    CPX #MAX_NME_BULLET_POOL_SIZE
    BNE init_enemy_bullet_state

    LDA #$00
    STA screen

    JMP main
.endproc

.segment "ZEROPAGE"
.importzp player_x, player_y, player_state
.importzp last_frame_pad1
.importzp bullet_x, bullet_y, bullet_state
.importzp ppuctrl_settings
.importzp tick, tock
.importzp screen

.BSS
.import enemy_state
.import enemy_bullet_x, enemy_bullet_y, enemy_bullet_state