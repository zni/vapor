.include "constants.inc"

.ZEROPAGE
.importzp released_pad1, pressed_pad1
.importzp tick, tock

.BSS
nmi_trampoline: .res 3
.export nmi_trampoline

.CODE
.import blank_screen
.import draw_starfield
.import get_controller_state


.export change_nmi_handler
.proc change_nmi_handler
    PHP

    LDA #RTI_OPCODE
    STA nmi_trampoline+0
    STX nmi_trampoline+1
    STY nmi_trampoline+2
    LDA #JMP_OPCODE
    STA nmi_trampoline+0

    PLP
    RTS
.endproc

.export title_nmi_handler
.proc title_nmi_handler
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    LDA #$00
    STA OAMADDR
    LDA #$02
    STA OAMDMA

    JSR get_controller_state
    LDA pressed_pad1
    AND #BTN_START
    BNE @load_game
    JMP @done

@load_game:
    LDX #<game_nmi_handler
    LDY #>game_nmi_handler
    JSR change_nmi_handler

    LDX #$20
    JSR blank_screen
    LDX #$28
    JSR blank_screen

    LDX #$20
    JSR draw_starfield
    LDX #$28
    JSR draw_starfield


@done:
    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTI
.endproc


.import update_level

.import draw_player
.import update_player

.import draw_enemies
.import update_enemies

.import update_player_bullets
.import draw_player_bullets
.import update_enemy_bullets
.import draw_enemy_bullets

.import draw_title_screen
.import draw_starfield
.import set_scroll_position

.import collision_detection

.export game_nmi_handler
.proc game_nmi_handler
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

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
    JSR get_controller_state

    JSR update_player
    JSR draw_player

    JSR update_level

    JSR update_enemies
    JSR draw_enemies

    JSR update_player_bullets
    JSR draw_player_bullets
    JSR update_enemy_bullets
    JSR draw_enemy_bullets

    JSR collision_detection

    JSR set_scroll_position

    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTI
.endproc