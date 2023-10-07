.include "constants.inc"
.include "header.inc"

.segment "CODE"
.proc irq_handler
    RTI
.endproc

.import draw_player
.import update_player
.import draw_enemy
.import update_enemy
.import spawn_enemy_pool
.import update_bullets
.import draw_bullets

.import draw_starfield
.import set_scroll_position

.import collision_detection

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
    INC tock

@updates:
    JSR update_player
    JSR draw_player

    ; check the tocks for the keys to the future.
    LDA tock
    SEC
    SBC #$01
    CMP #$00
    BEQ @spawn
    JMP @enemy_updates

@spawn:
    JSR spawn_enemy_pool

@enemy_updates:
    JSR update_enemy
    JSR draw_enemy

    JSR update_bullets
    JSR draw_bullets

    JSR collision_detection

    JSR set_scroll_position

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

    LDX #$20
    JSR draw_starfield
    LDX #$28
    JSR draw_starfield

    JSR spawn_enemy_pool

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

sprites:
    ; y-coord, tile num, attributes, x-coord
    .byte $70, $01, $00, $80
    .byte $60, $02, $01, $80
    .byte $50, $03, $02, $a0
    .byte $40, $04, $03, $80


.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
tick: .res 1
tock: .res 1
.exportzp player_x, player_y
.exportzp tick