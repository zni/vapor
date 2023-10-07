.include "constants.inc"

.segment "CODE"
.export draw_starfield
; draws the starfield background
;   @arg X  contains high byte of nametable to write to.
.proc draw_starfield
    LDA PPUSTATUS

    LDY #$00
@load_bg_big_stars:
    LDA PPUSTATUS

    TXA
    CLC
    ADC bg_big_stars,y
    STA PPUADDR
    INY
    LDA bg_big_stars,y
    STA PPUADDR

    LDA #$01
    STA PPUDATA

    CPY #$0a
    INY
    BNE @load_bg_big_stars

@load_bg_little_stars:
    LDA PPUSTATUS

    TXA
    CLC
    ADC bg_little_stars,y
    STA PPUADDR
    INY
    LDA bg_little_stars,y
    STA PPUADDR

    LDA #$02
    STA PPUDATA

    CPY #$14
    INY
    BNE @load_bg_little_stars

    ; set attribute table
    LDA PPUSTATUS
    TXA
    CLC
    ADC #$03
    STA PPUADDR
    LDA #$c0
    STA PPUADDR
    LDA #%00000011
    STA PPUDATA

    LDA PPUSTATUS
    TXA
    CLC
    ADC #$03
    STA PPUADDR
    LDA #$ee
    STA PPUADDR
    LDA #%11000000
    STA PPUDATA

    RTS
.endproc

.export set_scroll_position
.proc set_scroll_position
    LDA scroll
    CMP #$00
    BNE @set_positions

    LDA ppuctrl_settings
    EOR #%00000010
    STA ppuctrl_settings
    STA PPUCTRL
    LDA #240
    STA scroll

@set_positions:
    LDA #$00
    STA PPUSCROLL
    DEC scroll
    LDA scroll
    STA PPUSCROLL

    RTS
.endproc

.segment "RODATA"
bg_big_stars:
    .byte $00, $21
    .byte $00, $bc
    .byte $01, $27
    .byte $02, $ab
    .byte $02, $db

bg_little_stars:
    .byte $00, $3d
    .byte $00, $68
    .byte $00, $70
    .byte $00, $d7
    .byte $01, $7c
    .byte $01, $cf
    .byte $02, $04
    .byte $02, $93
    .byte $03, $08
    .byte $03, $99

.segment "ZEROPAGE"
scroll: .res 1
ppuctrl_settings: .res 1
.exportzp ppuctrl_settings