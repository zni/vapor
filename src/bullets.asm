.include "constants.inc"

.segment "CODE"

; Gets the next free bullet in the list.
;   @return X   the location of the next free bullet 
;               or #$ff if not available
.proc get_next_free_bullet
    PHP
    PHA
    TYA
    PHA

    LDX #$00
@loop:
    LDA bullet_state,x
    AND #STATE_BULLET_ALIVE
    BNE @has_next
    JMP @done
@has_next:
    CPX #MAX_BULLET_POOL_SIZE
    BEQ @full
    INX
    CPX #MAX_BULLET_POOL_SIZE
    BNE @loop
    JMP @full

@full:
    LDX #$ff 
@done:
    PLA
    TAY
    PLA
    PLP
    RTS
.endproc

.export spawn_player_bullet
.proc spawn_player_bullet
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    JSR get_next_free_bullet    ; get next free, store in X
    CPX #$ff                    ; check if nothing is free
    BEQ @done                   ; if yes, we're done here

    LDA player_x                ; otherwise, initialize our bullet
    STA bullet_x,x
    LDA player_y
    SEC
    SBC #$08
    STA bullet_y,x

    LDA #STATE_BULLET_ALIVE
    STA bullet_state,x

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
    LDA bullet_state,x
    AND #STATE_BULLET_ALIVE
    BEQ @continue
    LDA bullet_y,x
    CMP #$00                ; if we hit the top, despawn
    BEQ @despawn_bullet
    SEC
    SBC #$04                ; move the bullet
    BCC @despawn_bullet     ; if carry bit is clear, despawn
    STA bullet_y,x          ; otherwise store y-coord
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
    LDA bullet_y,x
    STA $0230,y

    LDA #BULLET_TILE
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
bullet_x: .res MAX_BULLET_POOL_SIZE
bullet_y: .res MAX_BULLET_POOL_SIZE
bullet_state: .res MAX_BULLET_POOL_SIZE
.importzp player_x, player_y
.exportzp bullet_x, bullet_y, bullet_state