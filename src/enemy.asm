; enemy locations are always > $0203
.include "constants.inc"


.segment "CODE"
.export spawn_enemy_pool
.proc spawn_enemy_pool
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    LDX #$00
    LDY #$10
@spawn:
    LDA #%00000100
    STA enemy_state,x
    LDA #$01
    STA enemy_y,x

    TYA
    CLC
    ADC #$10
    TAY
    STY enemy_x,x
    INX
    CPX #MAX_ENEMY_POOL_SIZE
    BNE @spawn

    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc


.export draw_enemy
.proc draw_enemy
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA
  
    LDX #$00
    LDY #$00
@draw:
    ; load y-coord
    LDA enemy_y,x
    STA $0204,y
    ; load tile
    LDA enemy_state,x
    AND #STATE_ENEMY_TYPE
    CLC
    ADC #$02
    STA $0205,y
    ; load attrib
    LDA #$01
    STA $0206,y
    ; load x-coords
    LDA enemy_x,x
    STA $0207,y
    CLC
    TYA
    ADC #$04
    TAY
    INX
    CPY #(MAX_ENEMY_POOL_SIZE * 4)
    BNE @draw


    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc



.export update_enemy
.proc update_enemy
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

init_y:
    LDX #$00
update_y:
    LDA enemy_state,x
    AND #STATE_ENEMY_ALIVE
    BEQ cont_y

    LDA enemy_y,x
    CMP #$df
    BEQ despawn_y
    INC enemy_y,x
cont_y:
    INX
    CPX #MAX_ENEMY_POOL_SIZE
    BNE update_y
    JMP init_x
despawn_y:
    LDA enemy_state,x
    EOR #STATE_ENEMY_ALIVE
    STA enemy_state,x
    LDA #$ff
    STA enemy_y,x
    STA enemy_x,x
    JMP cont_y

init_x:
;    LDX #$00
; update_x:
;     INC enemy_x,x
;     INX
;     CPX #$03
;     BNE update_x

    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc

.segment "ZEROPAGE"
enemy_x: .res MAX_ENEMY_POOL_SIZE
enemy_y: .res MAX_ENEMY_POOL_SIZE
enemy_vel: .res MAX_ENEMY_POOL_SIZE
enemy_state: .res MAX_ENEMY_POOL_SIZE
;; enemy state  -> %00000Att
;                        | |_ Type
;                        |___ Alive
.exportzp enemy_x, enemy_y, enemy_state