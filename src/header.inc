.segment "HEADER"
.byte $4e, $45, $53, $1a    ; magic string
.byte $02                   ; number of 16KB PRG-ROM banks
.byte $01                   ; number of 8KB CHR-ROM banks
.byte %00000001             ; vertical mirroring, no save RAM, no mapper
.byte %00000000             ; no special case flags
.byte $00                   ; no PRG-RAM
.byte $00                   ; NTSC format
