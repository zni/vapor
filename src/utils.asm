.segment "CODE"


; mod
; Calculate modulus of left_op and right_op (left_op % right_op).
;   @arg left_op
;   @arg right_op
;
;   @return A - remainder
.export mod
.proc mod
@loop:
    LDA left_op
    CMP right_op
    BCC @done
    LDA left_op
    CMP #00
    BEQ @done
    LDA left_op
    SEC
    SBC right_op
    BEQ @done       ; if 0, we're done
    STA left_op
    CMP right_op
    BCC @done
    JMP @loop
@invalid:
    LDA #$ff
@done:
    RTS
.endproc

.segment "BSS"
left_op: .res 1
right_op: .res 1
.export left_op, right_op