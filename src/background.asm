.include "constants.inc"

.BSS
title_screen_high_byte: .byte $00
title_row_count: .byte $00
.export title_screen_high_byte


.ZEROPAGE
title_screen_addr: .addr $0000


.CODE

; @arg X    - high byte of the nametable to write to.
.export blank_screen
.proc blank_screen
    PHP
    PHA
    TYA
    PHA

    LDA #0
    STA PPUMASK

    LDA PPUSTATUS
    STX PPUADDR
    LDA #0
    STA PPUADDR

    LDX #0
@init_y:
    LDY #0
@loop:
    LDA #0
    STA PPUDATA
    INY
    CPY #16
    BNE @loop

    INX
    CPX #60
    BNE @init_y

@done:
    LDA #PPU_SHOW_SPRITES
    STA PPUMASK

    LDA #0
    STA PPUSCROLL
    STA PPUSCROLL

    PLA
    TAY
    PLA
    PLP
    RTS
.endproc

.export draw_title_screen
.proc draw_title_screen
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

@vblankwait:
    BIT PPUSTATUS
    BPL @vblankwait

    LDA #%00010000      ; turn off NMIs, sprites use first pattern table
    STA PPUCTRL
    LDA #0
    STA PPUMASK

    LDA #<title_screen
    STA title_screen_addr+0
    LDA #>title_screen
    STA title_screen_addr+1

    LDA #0
    STA PPUSCROLL
    STA PPUSCROLL

    LDA #0
    STA PPUMASK

    LDA PPUSTATUS
    LDA title_screen_high_byte
    STA PPUADDR
    LDA #0
    STA PPUADDR

    LDX #0
    LDY #0
@loop:
    LDA (title_screen_addr),y
    STA PPUDATA


    INC title_screen_addr+0
    BNE @inc_row
    INC title_screen_addr+1

@inc_row:
    INC title_row_count
    LDA title_row_count
    CMP #16
    BEQ @reset
    JMP @loop

@reset:
    LDA #0
    STA title_row_count

    INX
    CPX #63
    BEQ @done

    JMP @loop

@done:
    LDA #0
    STA PPUSCROLL
    STA PPUSCROLL

@vblankwait2:
    BIT PPUSTATUS
    BPL @vblankwait2

    LDA PPUSTATUS
    LDA #%10010000      ; turn on NMIs, sprites use first pattern table
    STA PPUCTRL
    LDA #PPU_SHOW_SPRITES
    STA PPUMASK

    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc


.export draw_starfield
; draws the starfield background
;   @arg X  contains high byte of nametable to write to.
.proc draw_starfield
    LDA #0
    STA PPUMASK

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

    LDA #PPU_SHOW_SPRITES
    STA PPUMASK

    RTS
.endproc

.export set_scroll_position
.proc set_scroll_position
    LDA scroll
    CMP #$00
    BNE @set_positions

    LDA screen
    CMP #$04
    BEQ @reset_screen
    INC screen
    JMP @scroll_settings
@reset_screen:
    LDA #$00
    STA screen

@scroll_settings:
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
title_screen:
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$04,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$10,$11,$12,$13,$14,$15,$16,$17,$18,$05
	.byte $19,$1a,$1b,$1c,$1d,$1e,$1f,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$20,$21,$22,$23,$24,$25,$26,$27,$28,$06
	.byte $29,$2a,$2b,$2c,$2d,$2e,$2f,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$30,$31,$32,$33,$34,$35,$36,$37,$38,$07
	.byte $39,$3a,$3b,$3c,$3d,$3e,$3f,$00,$00,$00,$00,$00,$01,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$40,$41,$42,$43,$44,$45,$46,$47,$48,$08
	.byte $49,$4a,$4b,$4c,$4d,$4e,$4f,$02,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$50,$51,$52,$53,$54,$55,$56,$57,$58,$09
	.byte $59,$5a,$5b,$5c,$5d,$5e,$5f,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$04,$00,$00,$60,$61,$62,$63,$64,$65,$66,$67,$68,$0a
	.byte $69,$6a,$6b,$6c,$6d,$6e,$6f,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$70,$71,$72,$73,$74,$75,$76,$77,$78,$0b
	.byte $79,$7a,$7b,$7c,$7d,$7e,$7f,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$80,$81,$82,$83,$84,$85,$86,$87,$88,$00
	.byte $89,$8a,$8b,$8c,$8d,$8e,$8f,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$90,$91,$92,$93,$94,$95,$96,$97,$98,$00
	.byte $99,$9a,$9b,$9c,$9d,$9e,$9f,$00,$00,$00,$04,$00,$02,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$a0,$a1,$a2,$a3,$a4,$a5,$a6,$a7,$a8,$0c
	.byte $a9,$aa,$ab,$ac,$ad,$ae,$af,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$b0,$b1,$b2,$00,$b3,$b4,$00,$b5
	.byte $b6,$b7,$b8,$00,$b9,$ba,$bb,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$02,$00,$04,$00,$c0,$c1,$c2,$00,$c3,$c4,$c5,$c6
	.byte $00,$c7,$c8,$c9,$ca,$cb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $04,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$d0,$d1,$00,$00,$d2,$d3
	.byte $d4,$d5,$d6,$00,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$d7,$d8,$d9,$da,$db,$00,$00,$00
	.byte $e0,$e1,$e2,$e3,$e4,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$02,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$04,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04
	.byte $00,$00,$00,$00,$00,$00,$e5,$e6,$e7,$e8,$e9,$ea,$eb,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$40,$50,$50,$50,$50,$00,$00,$00,$44,$55,$55,$55,$55,$00,$00
	.byte $00,$44,$55,$55,$55,$55,$00,$00,$00,$04,$55,$55,$55,$55,$00,$00
	.byte $00,$00,$45,$45,$55,$01,$00,$00,$00,$00,$50,$50,$50,$10,$00,$00
	.byte $00,$00,$00,$00,$00,$40,$50,$10,$00,$00,$00,$00,$00,$00,$00,$00

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
.importzp screen