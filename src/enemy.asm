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

; Get next free enemy in pool.
;   @return X - next free position or $ff if full.
.proc get_next_free_enemy
    PHP
    PHA
    TYA
    PHA

    LDX #$00
@loop:
    LDA enemy_state,x               ; Check enemy_state at X.
    AND #STATE_ENEMY_ALIVE          ; Is it alive?
    BNE @has_next                   ; It is so check the next one.
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
@done:
    PLA
    TAY
    PLA
    PLP
    RTS
.endproc


.export spawn_enemy_for_screen
.proc spawn_enemy_for_screen
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA
    ; TODO make this not crazy
    LDA tock                        ; Load the number of tocks that have passed.
    CMP #$01                        ; Has more than 1 tock passed?
    BCS @init                       ; If tock >= $01, start spawning.
    JMP @done                       ; Otherwise, jump to done.

@init:
    LDA #$00
    STA tock
    LDX #$00
@spawn:
    TXA                             ; Transfer X to A, as get_next_free_enemy stores its result in X
    JSR get_next_free_enemy         ; Now get the next free enemy pool spot.
    CPX #$ff                        ; Are there any free spots?
    BEQ @done                       ; Nope.
    STX next_free                   ; Yes, store it in next_free.
    TAX                             ; Transfer A back to X
    JSR _spawn_enemy                ; Let's spawn an enemy.
    LDA level_1,x                   ; Load level data at X.
    AND #LEVEL_ENEMY_AMT            ; Grab the amount of enemies to spawn.
    STA count                       ; Store it in count.
    INX                             ; Increment X.
    CPX count                       ; Have we spawned everything?
    BNE @spawn                      ; Nope, keep spawning.

@done:
    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc

; _spawn_enemy
; Initialize an enemy's state, x-coord, and y-coord.
; Only to be called by spawn_enemy_for_screen, or in a context
; where next_free is valid.
;
;   @depends next_free      being populated with a valid address
;   @depends get_random     used to initialize x-coord spawn location
;
.export _spawn_enemy
.proc _spawn_enemy
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    LDY next_free                   ; initialize memory index
    CPY #$ff                        ; sanity check, is this actually free?
    BEQ @done                       ; if not, get out of here.
    LDX screen                      ; load screen for offset into enemy type and amount
    LDA level_1,x                   ; get the enemy type and amount: %0tttAAAA -> t = type, A = amount
    AND #LEVEL_ENEMY_TYPE           ; get the enemy type
    LSR                             ; shift to the end ...
    LSR
    LSR
    LSR
    EOR #STATE_ENEMY_ALIVE          ; mark it as alive
    STA enemy_state,y               ; store the state
    JSR get_random                  ; get a random number
    AND #STATE_ENEMY_DIR            ; try and and it with a direction bit
    EOR enemy_state,y               ; XOR it with enemy_state
    STA enemy_state,y               ; store it in enemy_state
    JSR get_random
    AND #STATE_ENEMY_ATTR
    EOR enemy_state,y
    STA enemy_state,y

    LDY next_free                   ; reload next_free
    JSR get_random                  ; get a random value for x-coord
    STA enemy_x,y                   ; store it at the next_free location
    LDA #$00                        ; load up $00
    STA enemy_y,y                   ; store it in the y-coord for next_free

@done:
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
    STY enemy_offset
    LDX #$00
@loop:
    LDY enemy_offset
    CMP #(MAX_ENEMY_POOL_SIZE * 4)
    BEQ @done

    LDA enemy_state,x
    AND #STATE_ENEMY_TYPE
    TAY
    LDA tile_size,y
    CMP #$01
    BEQ @single
@multi:
    ;JSR _draw_enemy_multitile
    JMP @cont
@single:
    JSR _draw_enemy_tile
@cont:
    INX
    CMP #MAX_ENEMY_POOL_SIZE
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

; .proc _draw_enemy_multitile
;     LDY #$00
;     STY enemy_offset

;     LDA enemy_y,x               ; load y-coord
;     STA ENEMY_SPRITE_Y_COORD,y

;     LDA enemy_state,x           ; load tile
;     AND #STATE_ENEMY_TYPE       ; get type bits
;     STX enemy_offset
;     TAX
;     LDA tile_index,x
;     STA ENEMY_SPRITE_TILE,y     ; store tile
;     LDA enemy_state,x

;     AND #STATE_ENEMY_ATTR
;     LSR A
;     LSR A
;     LSR A
;     LSR A
;     LSR A
;     STA ENEMY_SPRITE_ATTR,y      ; load attrib

;     LDA enemy_x,x
;     STA ENEMY_SPRITE_X_COORD,y

;     RTS
; .endproc

; _draw_enemy_tile
; Draws an enemy that takes up a single tile.
; @arg X    the offset into the enemy pool
;
; @no-modify X
.proc _draw_enemy_tile
    LDY enemy_offset

    LDA enemy_y,x               ; load y-coord
    STA ENEMY_SPRITE_Y_COORD,y

    LDA enemy_state,x           ; get enemy state
    AND #STATE_ENEMY_TYPE       ; get the type bits
    TAY                         ; transfer the bits to Y
    LDA tile_index,y            ; load the tile_index at Y
    LDY enemy_offset            ; load enemy_offset back into Y
    STA ENEMY_SPRITE_TILE,y     ; store tile at offset Y

    LDA enemy_state,x
    AND #STATE_ENEMY_ATTR
    LSR A
    LSR A
    LSR A
    LSR A
    LSR A
    STA ENEMY_SPRITE_ATTR,y      ; load attrib

    LDA enemy_x,x
    STA ENEMY_SPRITE_X_COORD,y

    CLC
    TYA                          ; get memory offset
    ADC #$04                     ; add offset into next OAM block
    STA enemy_offset

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
@update_y:
    LDA enemy_state,x               ; get enemy state
    AND #STATE_ENEMY_ALIVE          ; check if it's alive
    BEQ @cont_y                     ; if it's dead, don't update it
    
    LDA enemy_y,x                   ; get the enemy y-coord
    CMP #$dd                        ; have we crossed the despawn boundary?
    BEQ @despawn_y                  ; then despawn the enemy
    BCS @despawn_y                  ; if we passed the despawn, ex: y-coord >= despawn, despawn also

    INC enemy_y,x                   ; otherwise, increase the y-coord

@cont_y:
    INX
    CPX #MAX_ENEMY_POOL_SIZE
    BNE @update_y
    JMP @init_x
@despawn_y:
    LDA enemy_state,x
    EOR #STATE_ENEMY_ALIVE
    STA enemy_state,x
    LDA #$ff
    STA enemy_y,x
    STA enemy_x,x
    JMP @cont_y

@init_x:
    LDX #$00
@update_x:
    LDA enemy_state,x           ; load enemy state
    AND #STATE_ENEMY_ALIVE      ; check if we're actually alive
    BEQ @done_x                 ; we're dead, move on

    LDA enemy_x,x               ; load enemy x-coord
    CMP #$01                    ; are we past the left boundary?
    BEQ @despawn_x              ; we're right on it, despawn
    BCC @despawn_x              ; we're beyond it, despawn

    LDA enemy_x,x               ; load enemy x-coord
    CMP #$f0                    ; are we past the right boundary?
    BCS @despawn_x              ; we're beyond it, despawn
    BEQ @despawn_x              ; we're right on it, despawn

    LDA player_y
    SEC
    SBC enemy_y,x
    CMP #$10
    BCS @spawn_bullet
    BEQ @spawn_bullet
    JMP @comp
@spawn_bullet:
    LDA enemy_state,x
    AND #STATE_ENEMY_FIRE
    BNE @comp
    TXA
    TAY
    JSR spawn_enemy_bullet
    LDA enemy_state,x
    EOR #STATE_ENEMY_FIRE
    STA enemy_state,x

@comp:
    LDA player_x                ; load player's x-coord
    CMP enemy_x,x               ; compare it with the current enemy's x-coord
    BEQ @flip_dir               ; if it's equal flip directions
    BMI @comp2                  ; if enemy_x > player_x, recompare
    JMP @load_dir               ; otherwise, stay the course

@comp2:
    LDA enemy_x,x               ; load the current enemy's x-coord
    CMP player_x                ; compare it with the player's x-coord
    BCC @flip_dir               ; if player_x < enemy_x, flip the direction
    JMP @load_dir               ; otherwise, stay the course

@flip_dir:
    LDA enemy_state,x           ; reload the enemy state
    EOR #STATE_ENEMY_DIR        ; flip direction
    STA enemy_state,x

@load_dir:
    LDA enemy_state,x
    AND #STATE_ENEMY_DIR
    BEQ @inc_x                  ; go right
    JMP @dec_x                  ; go left

@landing_pad: JMP @update_x

@inc_x:
    INC enemy_x,x
    JMP @done_x

@dec_x:
    DEC enemy_x,x
    JMP @done_x

@despawn_x:
    LDA enemy_state,x
    EOR #STATE_ENEMY_ALIVE
    STA enemy_state,x
    LDA #$ff
    STA enemy_y,x
    STA enemy_x,x
@done_x:
    INX
    CPX #MAX_ENEMY_POOL_SIZE
    BNE @landing_pad

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
level_1: 
    .byte %00100000, %00110000, %00100011, %00000111
tile_index:
    .byte $02, $03, $04, $05, $20
tile_size:
    .byte $01, $01, $01, $01, $04


.segment "ZEROPAGE"
enemy_x: .res MAX_ENEMY_POOL_SIZE
enemy_y: .res MAX_ENEMY_POOL_SIZE
enemy_state: .res MAX_ENEMY_POOL_SIZE
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
next_free: .res 1
.exportzp enemy_x, enemy_y, enemy_state
.importzp player_x, player_y
.importzp tick, tock
.importzp screen