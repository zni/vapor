.include "constants.inc"

.segment "CODE"

; Gets the next free bullet in the list.
;   @return X   the location of the next free bullet 
;               or #$ff if not available
.proc get_next_free_player_bullet
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

    JSR get_next_free_player_bullet    ; get next free, store in X
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


.export update_player_bullets
.proc update_player_bullets
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
    CMP #$0a                ; if we hit the top, despawn
    BCC @despawn_bullet
    BEQ @despawn_bullet
    SEC
    SBC #BULLET_SPEED       ; move the bullet
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


.export draw_player_bullets
.proc draw_player_bullets
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
    STA PLAYER_BULLET_Y_COORD,y

    LDA #BULLET_TILE
    STA PLAYER_BULLET_TILE,y

    LDA #$01
    STA PLAYER_BULLET_ATTR,y

    LDA bullet_x,x
    STA PLAYER_BULLET_X_COORD,y

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

.proc get_next_free_enemy_bullet
    PHP
    PHA
    TYA
    PHA

    LDX #$00
@loop:
    LDA enemy_bullet_state,x
    AND #STATE_BULLET_ALIVE
    BNE @has_next
    JMP @done
@has_next:
    CPX #MAX_NME_BULLET_POOL_SIZE
    BEQ @full
    INX
    CPX #MAX_NME_BULLET_POOL_SIZE
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

; spawn_enemy_bullet
;   @arg Y  the offset of the enemy
.export spawn_enemy_bullet
.proc spawn_enemy_bullet
    PHP
    PHA
    TXA
    PHA

    JSR get_next_free_enemy_bullet      ; get next free, store in X
    CPX #$ff                            ; check if nothing is free
    BEQ @done                           ; if yes, we're done here

    LDA enemy_x,y
    STA enemy_bullet_x,x

    LDA enemy_y,y
    CLC
    ADC #$08
    STA enemy_bullet_y,x

    LDA #STATE_BULLET_ALIVE
    STA enemy_bullet_state,x

@done:
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc

.export update_enemy_bullets
.proc update_enemy_bullets
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    LDX #$00
@update:
    LDA enemy_bullet_state,x
    AND #STATE_BULLET_ALIVE
    BEQ @continue
    LDA enemy_bullet_y,x
    CMP #$f0                    ; if we hit the bottom, despawn
    BCS @despawn_bullet
    BEQ @despawn_bullet

    LDA enemy_bullet_y,x
    CLC
    ADC #ENEMY_BULLET_SPEED           ; move the bullet
    STA enemy_bullet_y,x              ; store y-coord
@continue:
    INX
    CPX #MAX_NME_BULLET_POOL_SIZE
    BNE @update
    JMP @done
@despawn_bullet:
    LDA #$ff
    STA enemy_bullet_y,x
    STA enemy_bullet_x,x
    LDA enemy_bullet_state,x
    EOR #STATE_BULLET_ALIVE
    STA enemy_bullet_state,x
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


.export draw_enemy_bullets
.proc draw_enemy_bullets
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    LDX #$00
    LDY #$00
@draw:
    LDA enemy_bullet_y,x
    STA ENEMY_BULLET_Y_COORD,y

    LDA #BULLET_TILE
    STA ENEMY_BULLET_TILE,y

    LDA #$01
    STA ENEMY_BULLET_ATTR,y

    LDA enemy_bullet_x,x
    STA ENEMY_BULLET_X_COORD,y

    TYA
    CLC
    ADC #$04
    CLC
    TAY
@skip:
    INX
    CPY #(MAX_NME_BULLET_POOL_SIZE * 4)
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

enemy_bullet_x: .res MAX_NME_BULLET_POOL_SIZE
enemy_bullet_y: .res MAX_NME_BULLET_POOL_SIZE
enemy_bullet_state: .res MAX_NME_BULLET_POOL_SIZE

.importzp player_x, player_y
.importzp enemy_x, enemy_y
.exportzp bullet_x, bullet_y, bullet_state
.exportzp enemy_bullet_x, enemy_bullet_y, enemy_bullet_state