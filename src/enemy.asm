.include "constants.inc"
; NOTE TO SELF
;
; The Picture Processing Unit (PPU) in the NES can only draw 64 sprites 
; per frame and 8 sprites per horizontal line (scanline). If the game 
; tries to draw more than that, some of them will be invisible.
; - https://retrocomputing.stackexchange.com/a/1146

.segment "CODE"

.import get_random

; Get next free enemy in pool.
;   @return X - next free position or $ff if full.
.proc get_next_free_enemy
    PHP
    PHA
    TYA
    PHA

    LDX #$00
@loop:
    LDA enemy_state,x
    AND #STATE_ENEMY_ALIVE
    BNE @has_next
    JMP @done
@has_next:
    CPX #MAX_ENEMY_POOL_SIZE
    BEQ @full
    INX
    CPX #MAX_ENEMY_POOL_SIZE
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

.export spawn_enemy_for_screen
.proc spawn_enemy_for_screen
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    LDX #$00
@spawn:
    TXA
    JSR get_next_free_enemy
    CPX #$ff
    BEQ @done
    STX next_free
    TAX
    JSR spawn_enemy
    LDA level_1,x
    AND #%00001111
    STA count
    INX
    CPX count
    BNE @spawn

@done:
    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc

.export spawn_enemy
.proc spawn_enemy
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    LDY next_free                   ; initialize memory index
    LDX screen                      ; load screen for offset into enemy type and amount
    LDA level_1,x                   ; get the enemy type and amount
    AND #%00110000                  ; get the enemy type
    LSR                             ; shift to the end ...
    LSR
    LSR
    LSR
    EOR #STATE_ENEMY_ALIVE          ; mark it as alive
    STA enemy_state,y               ; store the state

    LDY next_free                   ; reload next_free
    JSR get_random                  ; get a random value for x-coord
    STA enemy_x,y                   ; store it at the next_free location
    LDA #$00                        ; load up $00
    STA enemy_y,y                   ; store it in the y-coord for next_free

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
    AND #STATE_ENEMY_TYPE   ; get type bits
    CLC
    ADC #$02                ; add offset to enemy sprite tiles
    STA $0205,y             ; store tile
    ; load attrib
    LDA #$02
    STA $0206,y
    ; load x-coords
    LDA enemy_x,x
    STA $0207,y
    CLC
    TYA                     ; get memory offset
    ADC #$04                ; add offset into next OAM block
    CLC
    TAY                     ; swap back to Y
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

    LDX #$00
update_y:
    LDA enemy_state,x           ; get enemy state
    AND #STATE_ENEMY_ALIVE      ; check if it's alive
    BEQ cont_y                  ; if it's dead, don't update it
    LDA enemy_y,x               ; get the enemy y-coord
    CMP #$dd                    ; have we crossed the despawn boundary?
    BEQ despawn_y               ; then despawn the enemy
    INC enemy_y,x               ; otherwise, increase the y-coord
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
    LDX #$00
@update_x:
    LDA enemy_state,x
    AND #STATE_ENEMY_ALIVE
    BEQ @done_x
    LDA player_x        ; load player's x-coord
    CMP enemy_x,x       ; where are we in relation?
    BCS @inc_x          ; if the player's x-coord is greater, increment
    BNE @dec_x          ; if ours is greater, decrement
    BEQ @done_x         ; otherwise, we're right on track
@inc_x:
    INC enemy_x,x
    JMP @done_x
@dec_x:
    DEC enemy_x,x
@done_x:
    INX
    CPX #MAX_ENEMY_POOL_SIZE
    BNE @update_x

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
    .byte %00100011, %00100011, %00010011, %00000111


.segment "ZEROPAGE"
enemy_x: .res MAX_ENEMY_POOL_SIZE
enemy_y: .res MAX_ENEMY_POOL_SIZE
enemy_state: .res MAX_ENEMY_POOL_SIZE
; enemy state  -> %00000Att
;                       | |_ Type
;                       |___ Alive
enemy_offset: .res 1
count: .res 1
next_free: .res 1
.exportzp enemy_x, enemy_y, enemy_state
.importzp player_x, player_y
.importzp tick, tock
.importzp screen