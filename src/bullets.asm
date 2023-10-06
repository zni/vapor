.include "constants.inc"


.export spawn_player_bullet
.proc spawn_player_bullet
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    LDX next_bullet
    CPX #MAX_BULLET_POOL_SIZE
    BEQ @done

    LDA player_x
    STA bullet_x,x
    LDA player_y
    SEC
    SBC #$08
    STA bullet_y,x

    LDA #STATE_BULLET_ALIVE
    STA bullet_state,x

    INC next_bullet

@done:
    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc


.export update_bullets
.proc update_bullets
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    LDX #$00
@update:
    LDA bullet_y,x
    CMP #$00
    BEQ @despawn_bullet
    DEC bullet_y,x
@continue:
    INX
    CPX #MAX_BULLET_POOL_SIZE
    BNE @update
    JMP @done
@despawn_bullet:
    LDA #$ff
    STA bullet_y,x
    STA bullet_x,x
    LDA bullet_state,x
    EOR #STATE_BULLET_ALIVE
    STA bullet_state,x
    DEC next_bullet
    JMP @continue

@done:
    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc


.export draw_bullets
.proc draw_bullets
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    LDX #$00
    LDY #$00
@draw:
    LDA bullet_state,x
    AND #STATE_BULLET_ALIVE
    BEQ @skip
    LDA bullet_y,x
    STA $0230,y

    LDA #$05
    STA $0231,y

    LDA #$01
    STA $0232,y

    LDA bullet_x,x
    STA $0233,y

    TYA
    CLC
    ADC #$04
    CLC
    TAY
@skip:
    INX
    CPY #(MAX_BULLET_POOL_SIZE * 4)
    BNE @draw
@done:
    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc


.segment "ZEROPAGE"
next_bullet: .res 1
bullet_x: .res MAX_BULLET_POOL_SIZE
bullet_y: .res MAX_BULLET_POOL_SIZE
bullet_state: .res MAX_BULLET_POOL_SIZE
.importzp player_x, player_y