.include "constants.inc"
.include "header.inc"

.segment "CODE"
.proc irq_handler
    RTI
.endproc

.import init_level
.import update_level

.import draw_player
.import update_player

.import draw_enemies
.import update_enemies
.import spawn_enemy_for_screen
.import enemy_liveness_check

.import update_player_bullets
.import draw_player_bullets
.import update_enemy_bullets
.import draw_enemy_bullets

.import draw_title_screen
.import draw_starfield
.import set_scroll_position

.import collision_detection_first_round
.import collision_detection_second_round

.BSS
last_tock: .res 1
.import title_screen_high_byte
.export last_tock

.CODE
.proc nmi_handler
    LDA #$00
    STA OAMADDR
    LDA #$02
    STA OAMDMA

    ; put together some kind of timing mechanism,
    ; however bullshit it may be.
    INC tick
    LDA tick
    CMP #$ff
    BNE @updates
    LDA tock            ; load up tock...
    STA last_tock       ; and save it as last_tock.
    INC tock

@updates:
    ; JSR update_player
    ; JSR draw_player

    ; JSR update_level

    ; JSR update_enemies
    ; JSR draw_enemies

    ; JSR update_player_bullets
    ; JSR draw_player_bullets
    ; JSR update_enemy_bullets
    ; JSR draw_enemy_bullets

    ; JSR collision_detection_first_round
    ; JSR collision_detection_second_round

    ; JSR set_scroll_position

    RTI
.endproc

.import reset_handler

.export main
.proc main
    LDX PPUSTATUS

    ; palette high-low address bytes
    LDX #$3f
    STX PPUADDR
    LDX #$00
    STX PPUADDR

    ; load palettes from memory
    LDX #$00
load_bg_palettes:
    LDA bg_palette, x
    STA PPUDATA
    INX
    CPX #$10
    BNE load_bg_palettes

    LDX #$00
load_sprite_palettes:
    LDA sprite_palettes, x
    STA PPUDATA
    INX
    CPX #$10
    BNE load_sprite_palettes

    ; LDX #$20
    ; JSR draw_starfield
    ; LDX #$28
    ; JSR draw_starfield

    LDA #$20
    STA title_screen_high_byte
    JSR draw_title_screen

    ; Initialize last tock.
    LDA #$00
    STA last_tock

    JSR init_level

forever:
    JMP forever
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "CHR"
.incbin "graphics.chr"

.segment "RODATA"
bg_palette:
    .byte $0f, $12, $23, $27
    .byte $0f, $2b, $3c, $39
    .byte $0f, $0c, $07, $13
    .byte $0f, $19, $09, $29
sprite_palettes:
    .byte $0f, $2d, $10, $15
    .byte $0f, $18, $28, $38
    .byte $0f, $19, $09, $29
    .byte $0f, $19, $09, $29


.ZEROPAGE
player_x: .res 1
player_y: .res 1
player_state: .res 1
tick: .res 1
tock: .res 1
screen: .res 1
.exportzp player_x, player_y, player_state
.exportzp tick, tock
.exportzp screen