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

.proc nmi_handler
    LDA #$00
    STA OAMADDR
    LDA #$02
    STA OAMDMA

    JSR update_player
    JSR draw_player

; Do we need to spawn a new pool of enemies?
    LDX #00
loop:
    LDY enemy_state,x       ; get the state
    TYA
    AND #STATE_ENEMY_ALIVE  ; check if it's alive
    TAY
    INX
    CPX #$03
    BNE loop
    TYA
    AND #STATE_ENEMY_ALIVE  ; one extra AND to trip processor flags
    BNE enemy_seq
respawn:
    JSR spawn_enemy_pool
enemy_seq:
    JSR update_enemy
    JSR draw_enemy


    LDA #$00
    STA $2005
    STA $2005
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

;     ; load sprites from memory
;     LDX #$00
; load_sprites:
;     LDA sprites,X
;     STA $0200,X
;     INX
;     CPX #$10
;     BNE load_sprites

    ; load background elements
    LDY #$00            ; index            
    LDX #$01            ; tile#
load_bg_big_stars:
    LDA PPUSTATUS

    LDA bg_big_stars,Y
    STA PPUADDR
    INY

    LDA bg_big_stars,Y
    STA PPUADDR

    STX PPUDATA

    CPY #$0a
    INY
    BNE load_bg_big_stars

    ; set attribute table
    LDX #%00000011
    LDA PPUSTATUS
    LDA #$23
    STA PPUADDR
    LDA #$c0
    STA PPUADDR
    STX PPUDATA

    LDX #%11000000
    LDA PPUSTATUS
    LDA #$23
    STA PPUADDR
    LDA #$ee
    STA PPUADDR
    STX PPUDATA

    LDY #$00
    LDX #$02
load_bg_little_stars:
    LDA PPUSTATUS

    LDA bg_little_stars,Y
    STA PPUADDR
    INY

    LDA bg_little_stars,Y
    STA PPUADDR

    STX PPUDATA

    CPY #$14
    INY
    BNE load_bg_little_stars

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
    .byte $0f, $19, $09, $29
    .byte $0f, $19, $09, $29
    .byte $0f, $19, $09, $29

sprites:
    ; y-coord, tile num, attributes, x-coord
    .byte $70, $01, $00, $80
    .byte $60, $02, $01, $80
    .byte $50, $03, $02, $a0
    .byte $40, $04, $03, $80

bg_big_stars:
    .byte $20, $21
    .byte $20, $bc
    .byte $21, $27
    .byte $22, $ab
    .byte $22, $db

bg_little_stars:
    .byte $20, $3d
    .byte $20, $68
    .byte $20, $70
    .byte $20, $d7
    .byte $21, $7c
    .byte $21, $cf
    .byte $22, $04
    .byte $22, $93
    .byte $23, $08
    .byte $23, $99

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
.exportzp player_x, player_y
.importzp enemy_state