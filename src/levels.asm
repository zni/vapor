.include "constants.inc"

.CODE

.import get_random
.import mod
.import left_op, right_op

.export init_level
.proc init_level
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    LDA #$00
    STA level_index
    STA stage_index

    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc

.export update_level
.proc update_level
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    JSR _spawn_next_section

    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc

.BSS
.import spawn_enemy_amount, spawn_enemy_type, spawn_enemy_x_coord
.CODE
.import spawn_enemies_for_stage 
.proc _spawn_next_section
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    LDX stage_index
    CPX #LEVEL_STAGES

    LDX stage_index
    LDA tock
    CMP level_1_tocks,x
    BEQ @has_been_spawned
    BNE @done

@has_been_spawned:
    LDX stage_index
    LDA stage_spawned,x
    CMP #$01
    BEQ @done

@spawn:
    LDX stage_index
    LDA level_1,x
    AND #LEVEL_ENEMY_TYPE
    LSR
    LSR
    LSR
    LSR
    STA spawn_enemy_type

    LDA level_1,x
    AND #LEVEL_ENEMY_AMT
    STA spawn_enemy_amount

    JSR get_random
    STA left_op
    LDA #LEVEL_SPAWN_LOCATIONS
    STA right_op
    JSR mod
    TAX 
    LDA spawn_locations,x
    STA spawn_enemy_x_coord
    LDX stage_index

    JSR spawn_enemies_for_stage

@next_stage:
    LDA #$01
    STA stage_spawned,x
    LDX stage_index
    INX
    STX stage_index

@done:
    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc

.ZEROPAGE
level_index: .res 1
stage_index: .res 1
.importzp tick, tock

.BSS
stage_spawned:
    .byte $00, $00, $00, $00
    .byte $00, $00, $00, $00

.segment "RODATA"
levels: 
    .addr level_1
    
; enemy types and amounts making up a stage.
level_1:
    .byte %00000011, %00110011, %00100011, %00000111
    .byte %00010100, %00100100, %00110011, %00000111
    .byte %00000011, %00110011, %00100011, %00000111
    .byte %00010100, %00100100, %00110011, %00000111
; level_X    -> %TTTTAAAA
; T = 4 bits: enemy type
; A = 4 bits: amount to spawn

; the tocks that need to have passed to trigger a stage.
level_1_tocks:
    .byte $01, $03, $06, $09
    .byte $0c, $0f, $12, $15
    .byte $18, $1b, $1e, $21
    .byte $24, $27, $2a, $2d

spawn_locations:
    .byte $40, $60, $80, $a0, $c0
