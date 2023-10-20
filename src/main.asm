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
.import title_screen_high_byte
.import nmi_trampoline

.CODE


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

    LDA #$20
    STA title_screen_high_byte
    JSR draw_title_screen

    JSR init_level

forever:
    JMP forever
.endproc

.segment "VECTORS"
.addr nmi_trampoline, reset_handler, irq_handler

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