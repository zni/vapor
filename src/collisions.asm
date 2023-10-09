.include "constants.inc"

; collision_detection_first_round
; Perform AABB collision detection on player bullets and enemies.
.export collision_detection_first_round
.proc collision_detection_first_round
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    LDY #$00
@outer_loop:
    LDX #$00

@loop:
    LDA enemy_x,y       ; load object x-coord
    CLC
    ADC #$08            ; add the width
    STA object_x_w      ; store as object X + W
    CMP bullet_x,x
    BEQ @loop_inc  
    BCS @hit_x          ; bullet_x < object_x_w
    JMP @loop_inc

@hit_x:
    LDA bullet_x, x
    CLC
    ADC #$08
    STA object_x_w
    CMP enemy_x,y
    BEQ @loop_inc
    BCS @hit_y          ; object_x_w > enemy_x
    JMP @loop_inc

@hit_y:
    LDA enemy_y, y
    CLC
    ADC #$08
    STA object_y_h
    CMP bullet_y, x
    BEQ @loop_inc
    BCS @hit_y2         ; bullet_y < object_y_h
    JMP @loop_inc

@hit_y2:
    LDA bullet_y, x
    CLC
    ADC #$08
    STA object_y_h
    CMP enemy_y, y
    BEQ @loop_inc
    BCS @collided       ; object_y_h > enemy_y
    JMP @loop_inc

@landing_pad: JMP @outer_loop   ; intermediate jump point for outer loop.

@collided:
    LDA bullet_state, x
    EOR #STATE_BULLET_ALIVE
    STA bullet_state, x
    LDA #$ff
    STA bullet_x, x
    STA bullet_y, y

    LDA enemy_state, y
    EOR #STATE_ENEMY_ALIVE
    STA enemy_state, y
    LDA #$ff
    STA enemy_x, y
    STA enemy_y, y

@loop_inc:
    INX
    CPX #MAX_BULLET_POOL_SIZE
    BNE @loop
    INY
    CPY #MAX_ENEMY_POOL_SIZE
    BNE @landing_pad            ; read this as @outer_loop, it's too 
                                ; far for a direct jump from here.

@done:
    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc

.export collision_detection_second_round
.proc collision_detection_second_round
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    LDX #$00
@loop:
    LDA player_x       ; load object x-coord
    CLC
    ADC #$08            ; add the width
    STA object_x_w      ; store as object X + W
    CMP enemy_bullet_x,x
    BEQ @loop_inc  
    BCS @hit_x          ; bullet_x < object_x_w
    JMP @loop_inc

@hit_x:
    LDA enemy_bullet_x,x
    CLC
    ADC #$08
    STA object_x_w
    CMP player_x
    BEQ @loop_inc
    BCS @hit_y          ; object_x_w > player_x
    JMP @loop_inc

@hit_y:
    LDA player_y
    CLC
    ADC #$08
    STA object_y_h
    CMP enemy_bullet_y,x
    BEQ @loop_inc
    BCS @hit_y2         ; enemy_bullet_y < object_y_h
    JMP @loop_inc

@hit_y2:
    LDA enemy_bullet_y,x
    CLC
    ADC #$08
    STA object_y_h
    CMP player_y
    BEQ @loop_inc
    BCS @collided       ; object_y_h > player_y
    JMP @loop_inc

@collided:
    LDA enemy_bullet_state,x
    EOR #STATE_BULLET_ALIVE
    STA enemy_bullet_state,x
    LDA #$ff
    STA enemy_bullet_x, x
    STA enemy_bullet_y, y

    LDA player_state
    EOR #STATE_PLAYER_ALIVE
    STA player_state
    LDA #$ff
    STA player_x
    STA player_y

@loop_inc:
    INX
    CPX #MAX_NME_BULLET_POOL_SIZE
    BNE @loop


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
object_x_w: .res 1
object_y_h: .res 1
.importzp enemy_x, enemy_y, enemy_state
.importzp player_x, player_y, player_state
.importzp bullet_x, bullet_y, bullet_state
.importzp enemy_bullet_x, enemy_bullet_y, enemy_bullet_state