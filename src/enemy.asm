.include "constants.inc"
; NOTE TO SELF
;
; The Picture Processing Unit (PPU) in the NES can only draw 64 sprites 
; per frame and 8 sprites per horizontal line (scanline). If the game 
; tries to draw more than that, some of them will be invisible.
; - https://retrocomputing.stackexchange.com/a/1146

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
    LDY #$02
    LDA #$08
    STA enemy_offset
@spawn:
    LDA #%00000101
    STA enemy_state,x

    LDA enemy_offset
    CMP #$08
    BEQ @dec2
    JMP @inc2
@inc2:
    CLC
    ADC #$08
    JMP @done_offset
@dec2:
    SEC
    SBC #$08
@done_offset:
    STA enemy_y,x
    STA enemy_offset

    TYA
    CLC
    ADC #$08
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

init_y:
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

.segment "ZEROPAGE"
enemy_x: .res MAX_ENEMY_POOL_SIZE
enemy_y: .res MAX_ENEMY_POOL_SIZE
enemy_state: .res MAX_ENEMY_POOL_SIZE
; enemy state  -> %00000Att
;                       | |_ Type
;                       |___ Alive
enemy_offset: .res 1
.exportzp enemy_x, enemy_y, enemy_state
.importzp player_x, player_y