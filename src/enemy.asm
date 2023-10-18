.include "constants.inc"
; NOTE TO SELF
;
; The Picture Processing Unit (PPU) in the NES can only draw 64 sprites 
; per frame and 8 sprites per horizontal line (scanline). If the game 
; tries to draw more than that, some of them will be invisible.
; - https://retrocomputing.stackexchange.com/a/1146

.segment "CODE"

.import get_random
.import spawn_enemy_bullet

.import mod

; Get next free enemy in pool.
;   @return next_free_enemy - next free position or $ff if full.
.BSS
next_free_enemy: .byte 00
.CODE
.proc get_next_free_enemy
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    LDX #$00
@loop:
    LDA enemy_state,x               ; Check enemy_state at X.
    AND #STATE_ENEMY_ALIVE          ; Is it alive?
    BNE @has_next                   ; It is so check the next one.
    STX next_free_enemy
    JMP @done                       ; Otherwise we found our free space.

@has_next:
    CPX #MAX_ENEMY_POOL_SIZE        ; Are we at the max pool size.
    BEQ @full                       ; Then we're full.
    INX                             ; Otherwise increment...
    CPX #MAX_ENEMY_POOL_SIZE        ; and check if we're at the max pool size again.
    BNE @loop                       ; Not yet, keep looping.
    JMP @full                       ; Yep, return full.

@full:
    LDX #$ff
    STX next_free_enemy

@done:
    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc


; spawn_enemies_for_stage
;
;   @arg spawn_enemy_type: the type of enemy to spawn
;   @arg spawn_enemy_amount: the amount of enemies to spawn
;
.BSS
spawn_count: .byte $00          ; @internal
spawn_enemy_type: .res 1        ; @external
spawn_enemy_amount: .res 1      ; @external
spawn_enemy_x_coord: .res 1     ; @external
spawn_enemy_behavior: .res 1    ; @external
y_offset: .res 1                ; @internal
.export spawn_enemy_type, spawn_enemy_amount, spawn_enemy_x_coord
.export spawn_enemy_behavior
.CODE
.export spawn_enemies_for_stage
.proc spawn_enemies_for_stage
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    LDX #$00
    STX y_offset
    STX spawn_count
@loop:
    LDX spawn_count
    CPX spawn_enemy_amount
    BEQ @done

    JSR get_next_free_enemy
    LDA next_free_enemy
    CMP #$ff
    BEQ @done

    LDA #$00
    EOR #STATE_ENEMY_ALIVE
    STA enemy_state,x

    LDA spawn_enemy_x_coord
    STA enemy_x,x

    LDA y_offset
    CLC
    ADC #ENEMY_Y_SPACING
    STA y_offset
    STA enemy_y,x

    LDA spawn_enemy_type
    EOR enemy_state,x
    STA enemy_state,x

    LDA spawn_enemy_behavior
    STA enemy_behavior,x

    LDX spawn_count
    INX
    STX spawn_count
    JMP @loop

@done:
    LDA #$00
    STA y_offset
    STA spawn_count

    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc


.export draw_enemies
.proc draw_enemies
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    LDY #$00
    STY draw_sprite_index
    LDX #$00
    STX draw_enemy_index
@loop:
    LDY draw_sprite_index
    CPY #SIZE_ENEMY_SPRITE_POOL
    BEQ @done

    JSR _draw_enemy_tile
@cont:
    INX
    STX draw_enemy_index

    LDA draw_sprite_index
    CLC
    ADC #$04
    STA draw_sprite_index

    LDX draw_enemy_index
    CPX #MAX_ENEMY_POOL_SIZE
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


; _draw_enemy_tile
; Draws an enemy that takes up a single tile.
.BSS
draw_sprite_index: .res 1
draw_enemy_index: .res 1
.CODE
.proc _draw_enemy_tile
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    LDY draw_sprite_index
    LDX draw_enemy_index

    LDA enemy_y,x               ; load y-coord
    STA ENEMY_SPRITE_Y_COORD,y

    LDA enemy_state,x           ; get enemy state
    AND #STATE_ENEMY_TYPE       ; get the type bits
    TAY                         ; transfer the bits to Y
    LDA tile_index,y            ; load the tile_index at Y
    LDY draw_sprite_index       ; load draw_sprite_index back into Y
    STA ENEMY_SPRITE_TILE,y     ; store tile at offset Y

    LDA #$01
    STA ENEMY_SPRITE_ATTR,y      ; load attrib

    LDA enemy_x,x
    STA ENEMY_SPRITE_X_COORD,y   ; load x-coord

    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc


; _update_enemy
;
;   @arg update_index - the index of the enemy to update
;
.BSS
update_index: .res 1
.import enemy_bullet_y_offset
.CODE
.proc _update_enemy
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    LDX update_index

    LDA enemy_state,x
    AND #STATE_ENEMY_ALIVE
    BEQ @done

    LDA enemy_x,x
    CMP #$01
    BEQ @despawn
    BCC @despawn

    LDA enemy_x,x
    CMP #$f0
    BCS @despawn
    BEQ @despawn

    LDA enemy_y,x
    CMP #$dd
    BCS @despawn
    BEQ @despawn

    LDA enemy_y,x
    CMP #$80
    BCC @check_trigger
    BCS @apply_trigger

@check_trigger:
    LDA enemy_behavior,x
    AND #BEHAVIOR_TRIGGERED
    BNE @apply_behavior
    JMP @apply_regular

@apply_trigger:
    LDA enemy_behavior,x
    ORA #BEHAVIOR_TRIGGERED
    STA enemy_behavior,x

@fire_bullet:
    LDA enemy_y,x
    STA enemy_bullet_y_offset
    LDA enemy_state,x
    AND #STATE_ENEMY_FIRE
    BNE @apply_behavior
    TXA
    TAY
    JSR spawn_enemy_bullet
    LDA enemy_state,x
    EOR #STATE_ENEMY_FIRE
    STA enemy_state,x

@apply_behavior:
    JSR behavior_movement
    JMP @done

@apply_regular:
    LDA enemy_y,x
    CLC
    ADC #ENEMY_SPEED
    STA enemy_y,x
    JMP @done

@despawn:
    LDA enemy_state,x
    EOR #STATE_ENEMY_ALIVE
    STA enemy_state,x
    LDA #$ff
    STA enemy_y,x
    STA enemy_x,x

@done:
    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc

.proc behavior_movement
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    LDX update_index

    LDA enemy_behavior,x
    AND #BEHAVIOR_UP
    BNE @move_up
    JMP @check_down

@move_up:
    LDA enemy_y,x
    SEC
    SBC #ENEMY_SPEED
    STA enemy_y,x
    JMP @check_left

@check_down:
    LDA enemy_behavior,x
    AND #BEHAVIOR_DOWN
    BNE @move_down
    JMP @check_left

@move_down:
    LDA enemy_y,x
    CLC
    ADC #ENEMY_SPEED
    STA enemy_y,x

@check_left:
    LDA enemy_behavior,x
    AND #BEHAVIOR_LEFT
    BNE @move_left
    JMP @check_right

@move_left:
    LDA enemy_x,x
    SEC
    SBC #ENEMY_SPEED
    STA enemy_x,x
    JMP @done

@check_right:
    LDA enemy_behavior,x
    AND #BEHAVIOR_RIGHT
    BNE @move_right
    JMP @done

@move_right:
    LDA enemy_x,x
    CLC
    ADC #ENEMY_SPEED
    STA enemy_x,x

@done:
    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc



.export update_enemies
.proc update_enemies
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    LDX #$00
    STX update_index
@loop:
    JSR _update_enemy
    INX
    STX update_index
    CPX #MAX_ENEMY_POOL_SIZE
    BNE @loop

    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc


; Checks if a pool is still alive.
;    @return Y - #$01 if yes else #$00
.export enemy_liveness_check
.proc enemy_liveness_check
    PHP
    PHA
    TXA
    PHA

    LDX #$00
@loop:
    LDA enemy_state,x
    AND #STATE_ENEMY_ALIVE
    BEQ @return_false
    INX
    CMP #MAX_ENEMY_POOL_SIZE
    BNE @loop

@return_true:
    LDY #$01
    JMP @done

@return_false:
    LDY #$00

@done:
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc

.segment "RODATA"

tile_index:
    .byte $02, $03, $04, $05, $20
tile_size:
    .byte $01, $01, $01, $01, $04


.segment "ZEROPAGE"
enemy_x:         .res MAX_ENEMY_POOL_SIZE
enemy_y:         .res MAX_ENEMY_POOL_SIZE
enemy_behavior:  .res MAX_ENEMY_POOL_SIZE
enemy_state:     .res MAX_ENEMY_POOL_SIZE
; enemy state  -> %fPPLAttt
;                  ||||||||
;                  |+ || +-- Type
;                  || ||____ Alive
;                  || |_____ Direction (0 - right, 1 - left)
;                  ||_______ Palette (attribute bits)
;                  |________ Fired Bullet (0 - false, 1 - true)
enemy_offset: .res 1
enemy_tile_index: .res 1
count: .res 1
.exportzp enemy_x, enemy_y, enemy_state
.importzp player_x, player_y
.importzp tick, tock
.importzp screen

.segment "BSS"
.import left_op, right_op