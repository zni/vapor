; enemy locations are always > $0203

.segment "CODE"
.export draw_enemy
.proc draw_enemy
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    ; load y-coords
    LDX #$00
    LDA enemy_y,x
    STA $0204
    INX

    LDA enemy_y,x
    STA $0208
    INX

    LDA enemy_y,x
    STA $020c
    

    ; load tiles
    LDA #$02
    STA $0205
    LDA #$03
    STA $0209
    LDA #$04
    STA $0210

    ; load attributes
    LDA #$01
    STA $0206
    LDA #$02
    STA $020a
    LDA #$03
    STA $0211

    ; load x-coords
    LDA #$50
    STA $0207
    LDA #$a0
    STA $020b
    LDA #$b0
    STA $0212

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
    INC enemy_y,x
    INX
    CPX #$03
    BNE update_y

    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc

.segment "ZEROPAGE"
enemy_x: .res 3
enemy_y: .res 3
.exportzp enemy_x, enemy_y