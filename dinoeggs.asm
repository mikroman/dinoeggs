// [ ][$][0-z][0-z][0-z]	// search for " $<hex><hex><hex>"
// project created by mikroman
// June 18,2024
.import source "dino_labels.asm"

// ########################### BUILD OPTIONS #################################
#define no_error_build	// comment this line for read_error_build
//#define read_error_build	// comment this line for no_error_build
// ###########################################################################

	#if read_error_build
	BasicUpstart2(error)	// SYS2064 ($0810)

	#elif no_error_build
	BasicUpstart2(start)	// SYS2178 ($0882)

#endif

* = $0810 "read_error_build"

error:

	jmp L_JMP_0819_0810		// Do Read Error check/continue or reset

L_JSR_0813_50AD:
L_JSR_0813_5422:

	jmp L_JMP_1BB2_0813		//

L_JSR_0816_341D:
L_JSR_0816_3441:
L_JSR_0816_346E:
L_JSR_0816_349E:

	jmp L_JMP_7C38_0816		//

L_JMP_0819_0810:	// Disk protection check

	jsr CLALL			// Close All Channels And Files
	lda #$00
	jsr SETNAM		// Set Filename - null, here.
	lda #$0F
	ldx #$08
	ldy #$0F
	jsr SETLFS		// Set Logical File Parameters
	jsr OPEN			// Open Channel - In this case; the command channel, 15
	lda #$01
	ldx #$96
	ldy #$1D
	jsr SETNAM		// Set Filename
	lda #$05
	ldx #$08
	ldy #$05
	jsr SETLFS		// Set Logical File Parameters
	jsr OPEN			// Open Vector
	ldx #$0F
	jsr CHKOUT		// Set Output
	ldx #$00

L_BRS_0849_0852:	// perform Block Read (U1) of T,S = 18,18 to look for a checksum error

	lda BlockRead,X		// get a byte from U1 command string
	jsr CHROUT		// Output Vector, chrout
	inx
	cpx #$0C
	bne L_BRS_0849_0852
	jsr CLRCHN		// Restore I/O Vector
	ldx #$0F
	jsr CHKIN			// Set Input
	ldx #$00
	jsr CHRIN			// Input Vector, chrin
	cmp #$32
	bne L_BRS_086C_0863
	jsr CHRIN			// Input Vector, chrin
	cmp #$33
	beq L_BRS_0870_086A

L_BRS_086C_0863:

	sei
	jmp (RESET_vector)

L_BRS_0870_086A:

	ldx #$14

L_BRS_0872_0876:

	jsr CHRIN                         // Input Vector, chrin
	dex
	bne L_BRS_0872_0876
	lda #$05
	jsr CLOSE                         // Close Vector
	lda #$0F
	jsr CLOSE                         // Close Vector

*=$0882 "no_error_build"
start:	
	// 10 SYS2178 entry: skip disk error check

	sei
	ldx #$1E

L_BRS_0885_088C:	// prep VIC $D010-D01E

	lda table_6060,X
	sta MSIGX,X		// Sprites 0-7 MSB of X coordinate
	dex
	bpl L_BRS_0885_088C
	ldx #$0F

L_BRS_0890_089D:	// prep CIA1 and CIA2

	lda table_60C2,X
	sta D1PRA,X                          // Data Port A (Keyboard, Joystick, Paddles)
	lda table_60D2,X
	sta D2PRA,X                          // Data Port A (Serial Bus, RS232, VIC Base Mem.)
	dex
	bpl L_BRS_0890_089D
	lda #$00
	ldx #$20
	ldy #$86
	jsr L_JSR_660C_08A5
	lda #$BA
	sta NMI_vector                          // Vector: NMI
	lda #$1C
	sta NMI_vector + 1
	lda #$95	// VIC BANK2 $8000
	sta D2PRA                          // Data Port A (Serial Bus, RS232, VIC Base Mem.)
	sta $0203
	lda #$19
	sta $01
	ldx #$00

L_BRS_08C0_08D5:

	lda SP0X,X                          // Sprite 0 X Pos
	sta $CE00,X
	lda $D100,X
	sta $CF00,X
	lda #$00
	sta $0400,X
	sta FRELO1,X                          // Voice 1: Frequency Control - Low-Byte
	inx
	bne L_BRS_08C0_08D5
	dec $0400
	ldx #$07

L_BRS_08DC_08E9:
	lda table_1C92,X
	sta $CFE0,X
	lda table_1C9A,X
	sta $CFF0,X
	dex
	bpl L_BRS_08DC_08E9
	lda #$0F
	sta SIGVOL                          // Select Filter Mode and Volume
	lda #$08
	sta VCREG1                          // Voice 1: Control Register
	lda #$1D
	sta $01
	ldx #$02
	lda #$00

L_BRS_08FD_0900:

	sta $00,X
	inx
	bne L_BRS_08FD_0900
	jsr L_JSR_6124_0902
	lda #$C0
	sta $E0
	lda #$FE
	sta $E2
	ldx #$BC
	stx $E1
	inx
	stx $E3
	ldy #$00

L_BRS_0916_093C:

	sty $EF
	ldx table_627B,Y
	ldy #$02

L_BRS_091D_092B:

	lda table_625F,X
	sta ($E0),Y
	lda table_625F + 1,X
	sta ($E2),Y
	iny
	inx
	cpy #$08
	bne L_BRS_091D_092B
	ldy #$01
	jsr L_JSR_61C2_092F
	ldx #$02
	jsr L_JSR_61DE_0934
	ldy $EF
	iny
	cpy #$28
	bne L_BRS_0916_093C
	ldx #$00

L_BRS_0940_0953:

	lda $BCC0,X
	sta $FCC0,X
	lda $BDC0,X
	sta $FDC0,X
	lda $BEC0,X
	sta $FEC0,X
	inx
	bne L_BRS_0940_0953
	dex
	stx $DE
	lda #$6C
	sta v_1D95

L_JMP_095D_1204:

	lda #$7F
	sta IRQ_vector                          // Vector: IRQ
	lda #$60
	sta IRQ_vector + 1
	lda #$85
	sta LOOP_632A

L_JMP_096C_10B3:
L_JMP_096C_18AE:

	lda #$00
	ldx #$F8
	txs
	ldx #$03
	stx $1E
	bit $DE
	bmi L_BRS_097E_0977

L_BRS_0979_097C:

	sta $D0,X
	dex
	bpl L_BRS_0979_097C

L_BRS_097E_0977:

	lda #$00
	ldx #$FF
	stx $CF
	jsr L_JSR_656A_0984
	ldx #$1C
	bit $DE
	bpl L_BRS_098E_098B
	inx

L_BRS_098E_098B:

	cli
	jsr L_JSR_3200_098F
	lda #$03
	sta SPMC                          // Sprites Multi-Color Mode Select
	lda #$06
	sta SP0COL                          // Sprite 0 Color
	sta SP1COL                          // Sprite 1 Color
	lda #$FF
	sta SPENA                          // Sprite display Enable

L_JMP_09A4_1738:

	lda $20
	and #$01
	tax
	lda table_67A7,X
	sta $29
	ldy #$27
	sty $EF
	bit $29
	bvc L_BRS_09B8_09B4
	ldy #$4F

L_BRS_09B8_09B4:
L_BRS_09B8_09E7:

	lda $0410,Y
	beq L_BRS_09E4_09BB
	sec
	sbc #$01
	sta $0410,Y
	sty $EE
	lda $0460,Y
	ldx $0370,Y
	bmi L_BRS_09E4_09CB
	jsr L_JSR_6E5C_09CD
	lda $E0
	ldy $E1
	jsr L_JSR_665F_09D4
	ldy #$17
	lda #$00

L_BRS_09DB_09E0:

	sta ($E0),Y
	sta ($E2),Y
	dey
	bpl L_BRS_09DB_09E0
	ldy $EE

L_BRS_09E4_09BB:
L_BRS_09E4_09CB:

	dey
	dec $EF
	bpl L_BRS_09B8_09E7
	ldx #$03

L_JMP_09EB_0A80:

	lda $BFF8,X
	bne L_BRS_09F3_09EE
	jmp L_JMP_0A7D_09F0

L_BRS_09F3_09EE:

	dec $BFF8,X
	stx $EF
	lda $BFFC,X
	tax
	dex
	lda REDQ,X
	beq L_BRS_0A1F_0A00
	ldy DINOSZ+2,X
	beq L_BRS_0A1F_0A05
	ldy $09
	ora table_1C6A,Y
	tay
	ldx #$05
	lda $05
	beq L_BRS_0A14_0A11
	inx

L_BRS_0A14_0A11:
L_BRS_0A14_0A1B:

	lda #$04
	sta $0580,Y
	iny
	dex
	bne L_BRS_0A14_0A1B
	beq L_BRS_0A7B_0A1D

L_BRS_0A1F_0A00:
L_BRS_0A1F_0A05:

	lda $09
	jsr L_JSR_6E5A_0A21
	ldx #$00
	jsr L_JSR_6762_0A26
	ldy $EF
	ldx $BFFC,Y
	ldy #$5F
	lda $05
	beq L_BRS_0A36_0A32
	ldy #$7F

L_BRS_0A36_0A32:

	cpx #$04
	bcs L_BRS_0A74_0A38
	lda $E0
	sta $0A49
	lda $E1
	and #$1F
	ora #$28
	sta $0A4A

L_BRS_0A48_0A4E:

	lda $F000,Y
	sta ($E0),Y
	dey
	bpl L_BRS_0A48_0A4E
	lda $0C
	bpl L_BRS_0A71_0A52
	lda table_1C86,X
	clc
	adc $CE
	tay
	lda table_6EB9,Y
	jsr L_JSR_1C4D_0A5E
	lda $E5
	and #$1F
	ora #$D8
	sta $E5
	ldy $CE
	lda table_6ED7,Y
	jsr L_JSR_1C4D_0A6E

L_BRS_0A71_0A52:

	jmp L_JMP_0A7B_0A71

L_BRS_0A74_0A38:

	lda #$00

L_BRS_0A76_0A79:

	sta ($E0),Y
	dey
	bpl L_BRS_0A76_0A79

L_BRS_0A7B_0A1D:
L_JMP_0A7B_0A71:

	ldx $EF

L_JMP_0A7D_09F0:

	dex
	bmi L_BRS_0A83_0A7E
	jmp L_JMP_09EB_0A80

L_BRS_0A83_0A7E:

	jsr L_JSR_692D_0A83
	lda $05
	beq L_BRS_0AC7_0A88
	sec
	ror $0C
	lda #$0C
	sta $09
	lda $04
	sec
	sbc #$44
	bcc L_BRS_0AAE_0A96
	lsr
	lsr
	lsr
	tax
	inx
	ldy #$03

L_BRS_0A9F_0AAC:

	txa
	sta $BFFC,Y
	lda #$02
	sta $BFF8,Y
	dey
	bmi L_BRS_0AAE_0AA9
	dex
	bne L_BRS_0A9F_0AAC

L_BRS_0AAE_0A96:
L_BRS_0AAE_0AA9:

	jsr L_JSR_31FA_0AAE
	lda $05
	bne L_BRS_0ABB_0AB3
	txa
	bmi L_BRS_0ABB_0AB6
	jmp L_JMP_1204_0AB8

L_BRS_0ABB_0AB3:
L_BRS_0ABB_0AB6:

	lda #$40
	sta $0204
	lda #$10
	sta $D5
	jmp L_JMP_0FE8_0AC4

L_BRS_0AC7_0A88:

	bit $DE
	bpl L_BRS_0AE0_0AC9
	bvc L_BRS_0ADB_0ACB
	lda $20
	cmp #$E0
	bcs L_BRS_0ADB_0AD1
	lda #$30
	sta $21
	lda #$E0
	sta $20

L_BRS_0ADB_0ACB:
L_BRS_0ADB_0AD1:

	lda #$60
	sta LOOP_632A

L_BRS_0AE0_0AC9:

	ldx #$04

L_BRS_0AE2_0AEE:

	lda $4E,X
	bne L_BRS_0AF3_0AE4
	sta $72,X
	sta $78,X
	sta $71,X

L_JMP_0AEC_0BBC:
L_JMP_0AEC_0DB5:

	dex
	dex
	bpl L_BRS_0AE2_0AEE
	jmp L_JMP_0DB8_0AF0

L_BRS_0AF3_0AE4:

	stx $EE
	lda $4F,X
	beq L_BRS_0B6F_0AF7
	bmi L_BRS_0B2B_0AF9
	lda #$00
	sta $72,X
	jsr L_JSR_71FE_0AFF
	pha
	lda $4E,X
	lsr
	lsr
	lsr
	tax
	inx
	inx
	pla
	jsr L_JSR_6E5C_0B0C
	ldx $EE
	lda $4F,X
	ldx #$17
	cmp #$38
	bcs L_BRS_0B1B_0B17
	ldx #$2F

L_BRS_0B1B_0B17:

	ldy #$17

L_BRS_0B1D_0B26:

	lda ($E0),Y
	and $9F70,X
	sta ($E0),Y
	dex
	dey
	bpl L_BRS_0B1D_0B26
	jmp L_JMP_0CA3_0B28

L_BRS_0B2B_0AF9:

	cmp #$C0
	bcs L_BRS_0B60_0B2D
	lda $77,X
	and #$FC
	clc
	adc #$0D
	asl
	sta $48,X
	lda #$00
	rol
	sta $49,X
	dec $4F,X
	bmi L_BRS_0B6C_0B40
	lda #$00
	sta FREHI1                          // Voice 1: Frequency Control - High-Byte
	sta VCREG1                          // Voice 1: Control Register
	ldy $02D7
	inc $02D7
	lda DINOSZ,Y
	pha
	jsr L_JSR_722D_0B54
	dey
	tax
	pla
	jsr L_JSR_71D6_0B5A
	jmp L_JMP_0B6C_0B5D

L_BRS_0B60_0B2D:

	inc $4F,X
	bne L_BRS_0B6C_0B62
	jsr L_JSR_722D_0B64
	ldx #$01
	jsr L_JSR_717B_0B69

L_BRS_0B6C_0B40:
L_JMP_0B6C_0B5D:
L_BRS_0B6C_0B62:

	jmp L_JMP_0CA3_0B6C

L_BRS_0B6F_0AF7:

	lda $72,X
	beq L_BRS_0BCA_0B71
	cmp #$04
	bcc L_BRS_0B96_0B75
	jsr L_JSR_6200_0B77
	and #$07
	beq L_BRS_0B85_0B7C
	lda #$00
	sta $72,X
	jmp L_JMP_0C3A_0B82

L_BRS_0B85_0B7C:

	jsr L_JSR_71FE_0B85
	ldy #$00
	cmp $72,X
	bcc L_BRS_0B8F_0B8C
	iny

L_BRS_0B8F_0B8C:

	lda #$00
	sta $72,X
	jmp L_JMP_0C26_0B93

L_BRS_0B96_0B75:

	jsr L_JSR_7CF1_0B96
	inc $4E,X
	inc $5B,X
	ldy $4E,X
	cpy #$B3
	bcc L_BRS_0BBF_0BA1
	jsr L_JSR_722D_0BA3
	dey
	dey
	tax
	lda #$90
	jsr L_JSR_71D6_0BAB
	ldx $EE
	ldy $72,X
	dey
	cpy #$03
	bcs L_BRS_0BBC_0BB5
	lda #$01
	sta $00A7,Y

L_BRS_0BBC_0BB5:

	jmp L_JMP_0AEC_0BBC

L_BRS_0BBF_0BA1:

	lda $5A,X
	and #$0F
	sta $EA
	jsr L_JSR_4FFD_0BC5
	sta $5A,X

L_BRS_0BCA_0B71:

	lda $5B,X
	beq L_BRS_0BD8_0BCC
	dec $5B,X
	lda $55,X
	ora #$80
	sta $55,X
	bmi L_BRS_0C50_0BD6

L_BRS_0BD8_0BCC:

	lda $71,X
	beq L_BRS_0C01_0BDA
	lda $77,X
	and #$FC
	sta $E1
	jsr L_JSR_71FE_0BE2
	sec
	sbc $E1
	clc
	adc #$20
	ldy $54,X
	cmp CGWR,Y
	bcs L_BRS_0BFA_0BF0
	cmp CGWL,Y
	bcs L_BRS_0C3A_0BF5
	lda #$00
	.byte $2C

L_BRS_0BFA_0BF0:

	lda #$01
	sta $55,X
	jmp L_JMP_0C50_0BFE

L_BRS_0C01_0BDA:

	lda $13
	ora $02
	ora $DE
	bne L_BRS_0C3A_0C07
	lda $D5
	ora $D4
	beq L_BRS_0C3A_0C0D
	lda $2A
	bne L_BRS_0C33_0C11
	lda $16
	ldy $5A,X
	jsr L_JSR_7208_0C17
	beq L_BRS_0C3A_0C1A
	ldy #$00
	jsr L_JSR_71FE_0C1E
	cmp $15
	bcc L_BRS_0C26_0C23
	iny

L_JMP_0C26_0B93:
L_BRS_0C26_0C23:

	lda $55,X
	and #$7F
	sta $E0
	tya
	cmp $E0
	sta $55,X
	beq L_BRS_0C50_0C31

L_BRS_0C33_0C11:

	lda #$05
	sta $5B,X
	jmp L_JMP_0C50_0C37

L_JMP_0C3A_0B82:
L_BRS_0C3A_0BF5:
L_BRS_0C3A_0C07:
L_BRS_0C3A_0C0D:
L_BRS_0C3A_0C1A:

	jsr L_JSR_6200_0C3A
	cmp #$F0
	bcc L_BRS_0C50_0C3F
	tay
	lda $55,X
	eor #$80
	bmi L_BRS_0C4E_0C46
	cpy #$F8
	bcc L_BRS_0C4E_0C4A
	eor #$81

L_BRS_0C4E_0C46:
L_BRS_0C4E_0C4A:

	sta $55,X

L_BRS_0C50_0BD6:
L_JMP_0C50_0BFE:
L_BRS_0C50_0C31:
L_JMP_0C50_0C37:
L_BRS_0C50_0C3F:
L_JMP_0C50_1BA8:

	lda #$01
	ldy $55,X
	beq L_BRS_0C5C_0C54
	bmi L_BRS_0C7D_0C56
	ldy #$FF
	lda #$FF

L_BRS_0C5C_0C54:

	clc
	adc $48,X
	sta $48,X
	tya
	adc $49,X
	sta $49,X
	lda $48,X
	cmp #$18
	bne L_BRS_0C70_0C6A
	lda $49,X
	beq L_BRS_0C7A_0C6E

L_BRS_0C70_0C6A:

	lda $48,X
	cmp #$4A
	bne L_BRS_0C7D_0C74
	lda $49,X
	beq L_BRS_0C7D_0C78

L_BRS_0C7A_0C6E:

	jmp L_JMP_1BA2_0C7A

L_BRS_0C7D_0C56:
L_BRS_0C7D_0C74:
L_BRS_0C7D_0C78:

	lda $71,X
	bne L_BRS_0CA3_0C7F
	ldy $54,X
	lda BABW1,Y
	pha
	lda $4E,X
	pha
	jsr L_JSR_71FE_0C8A
	sec
	sbc BABWD,Y
	tax
	pla
	clc
	adc #$08
	tay
	pla
	jsr L_JSR_1BB2_0C98
	beq L_BRS_0CA3_0C9B
	ldx $EE
	lda #$E8
	sta $4F,X

L_JMP_0CA3_0B28:
L_JMP_0CA3_0B6C:
L_BRS_0CA3_0C7F:
L_BRS_0CA3_0C9B:

	ldx $EE
	jsr L_JSR_71FE_0CA5
	clc
	adc #$06
	ldy #$FF
	sec

L_BRS_0CAE_0CB1:

	sbc #$0C
	iny
	bcs L_BRS_0CAE_0CB1
	sty $EF
	lda $5A,X
	and #$F0
	ora $EF
	sta $5A,X
	tay
	lda $72,X
	bne L_BRS_0CCC_0CC0
	lda $0510,Y
	and #$03
	bne L_BRS_0CCC_0CC7
	jmp L_JMP_1BA2_0CC9

L_BRS_0CCC_0CC0:
L_BRS_0CCC_0CC7:

	lda $4F,X
	bne L_BRS_0CDC_0CCE
	tya
	jsr L_JSR_6E38_0CD1
	bne L_BRS_0CDC_0CD4
	ldx $EE
	lda #$E8
	sta $4F,X

L_BRS_0CDC_0CCE:
L_BRS_0CDC_0CD4:

	ldx $EE
	lda $4F,X
	beq L_BRS_0D1F_0CE0
	bpl L_BRS_0CF4_0CE2
	cmp #$87
	bcs L_BRS_0D1F_0CE6
	and #$7F
	pha
	jsr L_JSR_1D7D_0CEB
	pla
	clc
	adc #$24
	bne L_BRS_0D4D_0CF2

L_BRS_0CF4_0CE2:

	ldy $5A,X
	lda #$04
	sta $0590,Y
	lda $4F,X
	dec $4F,X
	bne L_BRS_0D17_0CFF
	lda $0510,Y
	and #$3C
	beq L_BRS_0D15_0D06
	cmp #$10
	bcs L_BRS_0D15_0D0A
	lda $0510,Y
	sec
	sbc #$04
	sta $0510,Y

L_BRS_0D15_0D06:
L_BRS_0D15_0D0A:

	lda #$01

L_BRS_0D17_0CFF:

	lsr
	lsr
	lsr
	clc
	adc #$2B
	bne L_BRS_0D4D_0D1D

L_BRS_0D1F_0CE0:
L_BRS_0D1F_0CE6:

	lda $54,X
	asl
	asl
	ldy $55,X
	beq L_BRS_0D43_0D25
	bpl L_BRS_0D41_0D27
	asl
	cpy #$80
	beq L_BRS_0D30_0D2C
	ora #$04

L_BRS_0D30_0D2C:

	tay
	lda $20
	lsr
	lsr
	and #$03
	sta $E0
	tya
	ora $E0
	clc
	adc #$0C
	bcc L_BRS_0D4D_0D3F

L_BRS_0D41_0D27:

	ora #$02

L_BRS_0D43_0D25:

	tay
	lda $20
	lsr
	and #$01
	beq L_BRS_0D4C_0D49
	iny

L_BRS_0D4C_0D49:

	tya

L_BRS_0D4D_0CF2:
L_BRS_0D4D_0D1D:
L_BRS_0D4D_0D3F:

	asl
	tay
	lda table_68C1,Y
	pha
	lda table_68C1 + 1,Y
	ldy table_6927,X
	sta MOON,Y
	pla
	sta MOON-1,Y
	lda #$1F
	sta $E0
	lda $55,X
	and #$80
	ora $72,X
	ora $4F,X
	beq L_BRS_0D70_0D6C
	lsr $E0

L_BRS_0D70_0D6C:

	jsr L_JSR_6200_0D70
	and #$03
	ora $20
	and $E0
	ora $71,X
	bne L_BRS_0DB5_0D7B
	stx $EF
	jsr L_JSR_6200_0D7F
	and #$0F
	sta $E0
	jsr L_JSR_6200_0D86
	and #$1F
	ora #$E0
	sta $E1
	lda #$11
	sta VCREG1                          // Voice 1: Control Register

L_BRS_0D94_0DAC:

	lda $E1
	sta FREHI1                          // Voice 1: Frequency Control - High-Byte
	lda #$00
	sta ATDCY1                          // Voice 1: Attack / Decay Cycle Control
	lda #$E0
	sta SUREL1                          // Voice 1: Sustain / Release Cycle Control
	ldx #$00

L_BRS_0DA5_0DA6:

	inx
	bne L_BRS_0DA5_0DA6
	inc $E1
	dec $E0
	bpl L_BRS_0D94_0DAC
	ldy #$00
	sty VCREG1                          // Voice 1: Control Register
	ldx $EF

L_BRS_0DB5_0D7B:

	jmp L_JMP_0AEC_0DB5

L_JMP_0DB8_0AF0:

	ldy #$04

L_BRS_0DBA_0DC0:

	ldx $78,Y
	bne L_BRS_0DC5_0DBC

L_JMP_0DBE_0E16:

	dey
	dey
	bpl L_BRS_0DBA_0DC0
	jmp L_JMP_0E19_0DC2

L_BRS_0DC5_0DBC:

	lda $0077,Y
	sty $EF
	jsr L_JSR_6E5C_0DCA
	lda $E0
	ldy $E1
	jsr L_JSR_665F_0DD1
	ldx $EF
	lda $E0
	sta $BF9E,X
	lda $E1
	sta $BF9F,X
	lda #$02
	sta $BFAC,X
	lda $20
	and #$03
	tay
	ldx table_1BAB_7andFs,Y
	ldy #$17

L_BRS_0DEF_0DFF:

	lda $9CAC,X
	ora ($E0),Y
	sta ($E0),Y
	lda $9D0C,X
	ora ($E2),Y
	sta ($E2),Y
	dex
	dey
	bpl L_BRS_0DEF_0DFF
	ldx #$00
	jsr L_JSR_6762_0E03
	ldx $EF
	lda #$7D
	ldx #$05

L_BRS_0E0C_0E12:

	ldy table_6784,X
	sta ($E4),Y
	dex
	bpl L_BRS_0E0C_0E12
	ldy $EF
	jmp L_JMP_0DBE_0E16

L_JMP_0E19_0DC2:

	ldy #$03

L_BRS_0E1B_0E21:

	lda $0068,Y
	bne L_BRS_0E26_0E1E

L_JMP_0E20_0EBB:

	dey
	bpl L_BRS_0E1B_0E21
	jmp L_JMP_0EBE_0E23

L_BRS_0E26_0E1E:

	lda $0060,Y
	cmp #$98
	bcc L_BRS_0E32_0E2B
	sty $EF
	jmp L_JMP_0EA2_0E2F

L_BRS_0E32_0E2B:

	ldx $64,Y
	lda REDQ,X
	sta $E8
	lda $0060,Y
	sty $EF
	jsr L_JSR_6E5C_0E3E
	lda $E0
	ldy $E1
	jsr L_JSR_665F_0E45
	ldx $EF
	txa
	asl
	tay
	lda $E0
	sta $BFA4,Y
	lda $E1
	sta $BFA5,Y
	lda #$02
	sta $BFB2,Y
	lda $E8
	beq L_BRS_0E6F_0E5E
	lda $60,X
	sec
	sbc #$08
	bcc L_BRS_0E6F_0E65
	jsr GETIND
	lda #$04
	sta $0580,Y

L_BRS_0E6F_0E5E:
L_BRS_0E6F_0E65:

	lda $68,X
	lsr
	tay
	ldx table_1BAB_7andFs,Y
	ldy #$17

L_BRS_0E78_0E88:

	lda $9D6C,X
	ora ($E0),Y
	sta ($E0),Y
	lda $9E14,X
	ora ($E2),Y
	sta ($E2),Y
	dex
	dey
	bpl L_BRS_0E78_0E88
	ldx #$00
	jsr L_JSR_6762_0E8C
	ldx $EF
	ldy $6C,X
	lda FLSHCOL,Y
	ora $0E
	ldx #$05

L_BRS_0E9A_0EA0:

	ldy table_6784,X
	sta ($E4),Y
	dex
	bpl L_BRS_0E9A_0EA0

L_JMP_0EA2_0E2F:

	ldx $EF
	dec $68,X
	bne L_BRS_0EB9_0EA6
	ldy $6C,X
	lda FLSHSC,Y
	beq L_BRS_0EB9_0EAD
	ldy $64,X
	pha
	lda $60,X
	tax
	pla
	jsr L_JSR_71D6_0EB6

L_BRS_0EB9_0EA6:
L_BRS_0EB9_0EAD:

	ldy $EF
	jmp L_JMP_0E20_0EBB

L_JMP_0EBE_0E23:

	ldy #$27

L_BRS_0EC0_0EC6:

	lda $0287,Y
	bne L_BRS_0ECB_0EC3

L_BRS_0EC5_0EEC:
L_JMP_0EC5_0FB1:

	dey
	bpl L_BRS_0EC0_0EC6
	jmp L_JMP_0FB4_0EC8

L_BRS_0ECB_0EC3:

	sty $EF
	sec
	sbc #$01
	bne L_BRS_0ED8_0ED0
	ldx $12
	cpx #$02
	bcs L_BRS_0EDB_0ED6

L_BRS_0ED8_0ED0:

	sta $0287,Y

L_BRS_0EDB_0ED6:

	cmp #$17
	bne L_BRS_0EE5_0EDD
	lda $02AF,Y
	jsr L_JSR_6531_0EE2

L_BRS_0EE5_0EDD:

	ldy $EF
	lda $020F,Y
	cmp #$94
	bcs L_BRS_0EC5_0EEC
	ldx $0237,Y
	bmi L_BRS_0F24_0EF1
	lda REDQ,X
	sta $E8
	beq L_BRS_0F0A_0EF8
	lda $020F,Y
	jsr GETIND
	lda #$04
	sta $0580,Y
	ldy $EF
	jmp L_JMP_0F24_0F07

L_BRS_0F0A_0EF8:

	tya
	bit $29
	bvc L_BRS_0F12_0F0D
	clc
	adc #$28

L_BRS_0F12_0F0D:

	tax
	lda #$02
	sta $0410,X
	lda $0237,Y
	sta $0370,X
	lda $020F,Y
	sta $0460,X

L_BRS_0F24_0EF1:
L_JMP_0F24_0F07:

	lda $020F,Y
	ldx $0237,Y
	jsr L_JSR_6E5C_0F2A
	lda $E0
	ldy $E1
	jsr L_JSR_665F_0F31
	ldx $EF
	lda $0237,X
	cmp #$FF
	bne L_BRS_0F4D_0F3B
	lda #$00
	ldy #$07
	sty $E1
	sty $E3
	sta $E0
	lda #$18
	sta $E2
	bne L_BRS_0F65_0F4B

L_BRS_0F4D_0F3B:

	ldx #$00
	jsr L_JSR_6762_0F4F
	ldx $EF
	ldy $025F,X
	lda #$70
	ora $0E
	ldx #$05

L_BRS_0F5D_0F63:

	ldy table_6784,X
	sta ($E4),Y
	dex
	bpl L_BRS_0F5D_0F63

L_BRS_0F65_0F4B:

	ldy #$15

L_BRS_0F67_0F74:

	lda #$FF
	sta ($E2),Y
	dey
	dey
	sta ($E0),Y
	tya
	sec
	sbc #$06
	tay
	bpl L_BRS_0F67_0F74
	ldx $EF
	lda #$0A
	ldy $02AF,X
	bpl L_BRS_0F81_0F7D
	lda #$0B

L_BRS_0F81_0F7D:

	jsr L_JSR_71A9_0F81
	lda $02AF,X
	and #$7F
	lsr
	lsr
	lsr
	lsr
	php
	beq L_BRS_0F93_0F8E
	jsr L_JSR_71A9_0F90

L_BRS_0F93_0F8E:

	lda $02AF,X
	and #$0F
	jsr L_JSR_71A9_0F98
	plp
	bne L_BRS_0FAF_0F9C
	ldy #$00
	tya

L_BRS_0FA1_0FA6:

	sta ($E2),Y
	iny
	cpy #$04
	bne L_BRS_0FA1_0FA6

L_BRS_0FA8_0FAD:

	sta ($E0),Y
	iny
	cpy #$08
	bne L_BRS_0FA8_0FAD

L_BRS_0FAF_0F9C:

	ldy $EF
	jmp L_JMP_0EC5_0FB1

L_JMP_0FB4_0EC8:

	jsr L_JSR_5000_0FB4
	lda $B3
	beq L_BRS_0FE8_0FB9
	dec $B3
	bne L_BRS_0FCD_0FBD
	lda #$00
	sta FREHI1                          // Voice 1: Frequency Control - High-Byte
	sta PWHI1                          // Voice 1: Pulse Waveform Width - High-Nybble
	sta VCREG1                          // Voice 1: Control Register
	jmp L_JMP_0FE8_0FCA

L_BRS_0FCD_0FBD:

	sta FREHI1                          // Voice 1: Frequency Control - High-Byte
	lda PWHI1                          // Voice 1: Pulse Waveform Width - High-Nybble
	clc
	adc #$08
	sta PWHI1                          // Voice 1: Pulse Waveform Width - High-Nybble
	lda #$00
	sta ATDCY1                          // Voice 1: Attack / Decay Cycle Control
	lda #$E1
	sta SUREL1                          // Voice 1: Sustain / Release Cycle Control
	ldy #$81
	sty VCREG1                          // Voice 1: Control Register

L_JMP_0FE8_0AC4:
L_BRS_0FE8_0FB9:
L_JMP_0FE8_0FCA:

	lda $0D
	bne L_BRS_0FF3_0FEA
	sta $0A
	sta $0B
	jmp L_JMP_116A_0FF0

L_BRS_0FF3_0FEA:

	ldy #$01
	bit $29
	bvc L_BRS_0FFA_0FF7
	dey

L_BRS_0FFA_0FF7:

	tax
	sta $BFFC,Y
	lda #$02
	sta $BFF8,Y
	bit $DE
	bvc L_BRS_100B_1005
	lda #$0E
	sta $09

L_BRS_100B_1005:

	jsr L_JSR_1C21_100B
	ldy #$5F

L_BRS_1010_1016:

	lda table_3141,Y
	sta ($E0),Y
	dey
	bpl L_BRS_1010_1016
	ldx $0D
	dex
	beq L_BRS_106E_101B
	jsr L_JSR_1C21_101D
	ldy #$5F

L_BRS_1022_1028:

	lda table_30E1,Y
	sta ($E0),Y
	dey
	bpl L_BRS_1022_1028
	lda #$00
	sta $ED
	ldx $0D
	dex
	dex
	beq L_BRS_106E_1032

L_BRS_1034_106C:	// 

	jsr L_JSR_1C21_1034
	lda $0D
	sec
	sbc $EF
	tay
	lda table_1C55_dinomama - 3,Y
	sta MAMA+1
	sta PAPA+1
	sta BABY+1
	ldy #$5F

L_BRS_104B_1055:

	lda MAMA:$F000,Y
	ora #$03
	sta ($E0),Y
	dey
	cpy #$57
	bne L_BRS_104B_1055

L_BRS_1057_105F:

	lda PAPA:$F000,Y
	sta ($E0),Y
	dey
	cpy #$07
	bne L_BRS_1057_105F

L_BRS_1061_1069:

	lda BABY:$F000,Y
	ora #$C0
	sta ($E0),Y
	dey
	bpl L_BRS_1061_1069
	txa
	bne L_BRS_1034_106C

L_BRS_106E_101B:
L_BRS_106E_1032:

	lda $0B
	beq L_BRS_10C4_1070
	dec $0B
	bne L_BRS_10BA_1074
	bit $DE
	bpl L_BRS_10B6_1078
	bvc L_BRS_10B3_107A
	jsr L_JSR_6200_107C
	and #$03
	clc
	adc #$05
	sta $CF
	ldx #$00
	lda #$80
	sta $DE
	jsr L_JSR_3200_108C

L_BRS_108F_109A:

	jsr L_JSR_679B_108F
	ora #$60
	tax
	lda $0500,X
	cmp #$41
	beq L_BRS_108F_109A
	lda #$25
	sta $0510,X
	lda #$03
	sta $0500,X
	stx $21
	lda $20
	sta $24
	lda #$00
	sta $10
	jmp L_JMP_116A_10B0

L_BRS_10B3_107A:

	jmp L_JMP_096C_10B3

L_BRS_10B6_1078:

	lda #$FF
	sta $0C

L_BRS_10BA_1074:

	jmp L_JMP_116A_10BA

L_BRS_10BD_10D0:
L_BRS_10BD_10D6:
L_BRS_10BD_10EA:
L_BRS_10BD_10F4:
L_BRS_10BD_10F8:
L_JMP_10BD_115A:

	lda #$FF
	sta $0C
	jmp L_JMP_115D_10C1

L_BRS_10C4_1070:

	lda $13
	ora $02
	ora $10
	ora $12
	ora $11
	ora $0A
	bne L_BRS_10BD_10D0
	lda $D5
	ora $D4
	beq L_BRS_10BD_10D6
	bit $DE
	bvs L_BRS_10F6_10DA
	ldy #$00
	ldx #$02

L_BRS_10E0_10E6:

	lda $21,X
	beq L_BRS_10E5_10E2
	iny

L_BRS_10E5_10E2:

	dex
	bpl L_BRS_10E0_10E6
	cpy #$02
	bcs L_BRS_10BD_10EA
	lda $CE
	cmp #$09
	beq L_BRS_10F6_10F0
	cpy #$01
	beq L_BRS_10BD_10F4

L_BRS_10F6_10DA:
L_BRS_10F6_10F0:

	lda $0C
	bmi L_BRS_10BD_10F8
	ldy #$03
	lda $0D

L_BRS_10FE_1104:

	cmp table_1C1D_4bytes,Y
	beq L_BRS_1109_1101
	dey
	bpl L_BRS_10FE_1104
	jmp L_JMP_115D_1106

L_BRS_1109_1101:

	lda $0D
	bit $DE
	bpl L_BRS_1113_110D
	cmp #$09
	bcc L_BRS_115D_1111

L_BRS_1113_110D:

	asl
	asl
	asl
	cmp $17
	bcc L_BRS_115D_1118
	lda #$05
	sta $B3
	bit $DE
	bpl L_BRS_1126_1120
	lda #$40
	sta $0B

L_BRS_1126_1120:

	lda $09
	asl
	asl
	sec
	sbc #$03
	bcs L_BRS_1131_112D
	lda #$00

L_BRS_1131_112D:

	cmp $15
	bcs L_BRS_1158_1133
	lda $09
	asl
	asl
	clc
	adc #$2C
	cmp $15
	bcc L_BRS_1158_113E
	ldx #$17
	jsr L_JSR_6307_1142
	jsr L_JSR_62CF_1145
	lda #$50
	sta $13
	sta $08
	lda $1B
	sta $17
	lda #$0A
	sta $0B
	bne L_BRS_116A_1156

L_BRS_1158_1133:
L_BRS_1158_113E:

	inc $0A
	jmp L_JMP_10BD_115A

L_JMP_115D_10C1:
L_JMP_115D_1106:
L_BRS_115D_1111:
L_BRS_115D_1118:

	lda $20
	and #$01
	bne L_BRS_116A_1161
	lda $0D
	clc
	adc $0C
	sta $0D

L_JMP_116A_0FF0:
L_JMP_116A_10B0:
L_JMP_116A_10BA:
L_BRS_116A_1156:
L_BRS_116A_1161:

	lda $20
	and #$01
	tax
	lda table_67A7 + 2,X
	sta $0203			// flip between VIC BANKs 2 and 3 $8000,$C000
	ldy $0400
	cpy #$FF
	beq L_BRS_1189_117A
	lda $05F3
	bne L_BRS_1189_117F
	lda #$FF
	sta $0400
	jsr L_JSR_31F7_1186

L_BRS_1189_117A:
L_BRS_1189_117F:

	lda $14
	sta $020E
	ldx #$00
	stx D1DDRA                          // Data Direction Register A
	stx D1DDRB                          // Data Direction Register B
	lda D1PRA                          // Data Port A (Keyboard, Joystick, Paddles)
	and #$1F
	cmp #$1F
	beq L_BRS_11B0_119D
	inc $DF
	asl
	asl
	asl
	asl
	ora #$0F
	bcs L_BRS_11AB_11A7
	and #$F7

L_BRS_11AB_11A7:

	sta $14
	jmp L_JMP_11B3_11AD

L_BRS_11B0_119D:

	jsr SCON

L_JMP_11B3_11AD:

	bit $DE
	bmi L_BRS_11F1_11B5
	lda $14
	and #$04
	bne L_BRS_11F1_11BB
	lda $020E
	and #$04
	beq L_BRS_11F1_11C2
	lda $0201
	clc
	adc #$02

L_BRS_11CA_11CD:

	cmp $0201
	bne L_BRS_11CA_11CD
	lda #$88
	sta VCREG1                          // Voice 1: Control Register
	sta VCREG2                          // Voice 2: Control Register
	sta VCREG3                          // Voice 3: Control Register

L_BRS_11DA_11E1:

	jsr SCON
	lda $14
	and #$04
	beq L_BRS_11DA_11E1

L_BRS_11E3_11E6:

	jsr L_JSR_7D55_11E3
	beq L_BRS_11E3_11E6
	lda #$FB
	sta $14
	sta $020E
	bne L_BRS_121B_11EF

L_BRS_11F1_11B5:
L_BRS_11F1_11BB:
L_BRS_11F1_11C2:

	lda $DE
	bpl L_BRS_1207_11F3
	lda $14
	and #$08
	beq L_BRS_1200_11F9
	jsr L_JSR_7D55_11FB
	beq L_BRS_1207_11FE

L_BRS_1200_11F9:

	lda #$00
	sta $DE

L_JMP_1204_0AB8:
L_JMP_1204_1CBE:

	jmp L_JMP_095D_1204

L_BRS_1207_11F3:
L_BRS_1207_11FE:

	ldx #$FF
	lda $11
	ora $12
	ora $10
	ora $2A
	ora $DE
	ora $02
	ora $13
	beq L_BRS_121B_1217
	stx $14

L_BRS_121B_11EF:
L_BRS_121B_1217:

	ldy #$00
	lda $13
	beq L_BRS_1273_121F
	cmp #$03
	bne L_BRS_1227_1223
	sty $28

L_BRS_1227_1223:

	dec $13
	bne L_BRS_1241_1229
	inc $11

L_JMP_122D_12D5:

	ldy #$00
	sty $1C
	sty $18
	sty $19
	sty $2A
	lda #$03
	sta $1E
	jmp L_JMP_1327_123B

L_BRS_123E_1243:
L_JMP_123E_1258:

	jmp L_JMP_158D_123E

L_BRS_1241_1229:

	cmp #$12
	bcc L_BRS_123E_1243
	bne L_BRS_125B_1245
	lda #$00
	sta $08
	lda $17
	lsr
	lsr
	lsr
	tay
	lda $15
	ldx #$00
	jsr L_JSR_717B_1255
	jmp L_JMP_123E_1258

L_BRS_125B_1245:

	lda $08
	beq L_BRS_1270_125D
	lda $20
	lsr
	lsr
	lsr
	and #$01
	tax

L_JMP_1267_1318:
L_JMP_1267_1554:
L_JMP_1267_15D4:

	lda table_5AD6,X
	ldy table_5AE4,X
	jmp L_JMP_15DD_126D

L_BRS_1270_125D:

	jmp L_JMP_1546_1270

L_BRS_1273_121F:

	sta $08
	lda $0207
	beq L_BRS_128D_1278
	lda $14
	and #$D0
	cmp #$D0
	beq L_BRS_128D_1280
	lda #$00
	sta $0207
	ldx $20
	inx
	stx $0200

L_BRS_128D_1278:
L_BRS_128D_1280:

	lda $D5
	ora $D4
	bne L_BRS_12A5_1291
	jsr L_JSR_1CA2_1293
	ldx $1C
	beq L_BRS_12A1_1298
	ldx #$00
	stx $1C
	inx
	stx $18

L_BRS_12A1_1298:

	lda $17
	cmp $1B

L_BRS_12A5_1291:

	bne L_BRS_131B_12A5
	dec $02
	dec $02
	lda $02
	bpl L_BRS_12D8_12AD
	cmp #$F8
	bne L_BRS_12BE_12B1
	ldx #$1A
	jsr L_JSR_6307_12B5
	jsr L_JSR_62CF_12B8
	jmp L_JMP_1327_12BB

L_BRS_12BE_12B1:

	cmp #$80
	bne L_BRS_12F0_12C0
	ldy #$00
	sty $B1
	lda #$7F
	bit D1T2L                          // Timer B Low-Byte  (Tape, Serial Port)
	bvc L_BRS_12CF_12CB
	lda #$BF

L_BRS_12CF_12CB:

	sta $B2
	lda #$3E
	sta $11
	jmp L_JMP_122D_12D5

L_BRS_12D8_12AD:

	dec $B1
	bpl L_BRS_12E9_12DA
	jsr L_JSR_6200_12DC
	and #$0F
	sta $B1
	lda $B2
	eor #$C0
	sta $B2

L_BRS_12E9_12DA:

	lda $B2
	sta $1A
	jmp L_JMP_1451_12ED

L_BRS_12F0_12C0:

	lda $02
	and #$7F
	lsr
	lsr
	lsr
	tax
	inx
	inx
	cpx #$08
	bcc L_BRS_1300_12FC
	ldx #$08

L_BRS_1300_12FC:

	cpx #$04
	bne L_BRS_1311_1302
	lda #$01
	sta SP0COL                          // Sprite 0 Color
	sta SP1COL                          // Sprite 1 Color
	lda #$00
	sta SPMC                          // Sprites Multi-Color Mode Select

L_BRS_1311_1302:

	stx $E8
	jsr L_JSR_1CC1_1313
	ldx $E8
	jmp L_JMP_1267_1318

L_BRS_131B_12A5:

	lda $2A
	beq L_BRS_136B_131D
	dec $2A
	beq L_BRS_1353_1321
	cmp #$18
	bne L_BRS_1365_1325

L_JMP_1327_123B:
L_JMP_1327_12BB:

	lda $1D
	ldx $11
	beq L_BRS_1331_132B
	ldx #$00
	stx $1D

L_BRS_1331_132B:

	tax
	beq L_BRS_1350_1332
	bmi L_BRS_1350_1334
	lda #$18
	sta $70
	ldy #$FF
	txa
	ora #$80
	jsr L_JSR_71D6_133F
	ldx #$0C
	jsr L_JSR_6307_1344
	lda #$00
	jsr L_JSR_62DB_1349
	lda #$00
	sta $1D

L_BRS_1350_1332:
L_BRS_1350_1334:

	jmp L_JMP_15E3_1350

L_BRS_1353_1321:

	lda $18
	ora $19
	beq L_BRS_1360_1357
	ldx #$01
	stx $19
	dex
	stx $18

L_BRS_1360_1357:

	ldx #$0B
	jsr L_JSR_6307_1362

L_BRS_1365_1325:

	jsr L_JSR_1CF5_1365
	jmp L_JMP_15E3_1368

L_BRS_136B_131D:

	lda $1C
	beq L_BRS_13A7_136D
	ldx $1F
	ldy $1F
	lda $20
	lsr
	bcc L_BRS_1384_1376
	lda $14
	asl
	asl
	asl
	bcs L_BRS_1380_137D
	dex

L_BRS_1380_137D:

	asl
	bcs L_BRS_1384_1381
	inx

L_BRS_1384_1376:
L_BRS_1384_1381:

	stx $1F
	cpx #$0E
	beq L_BRS_138D_1388
	txa
	bne L_BRS_138F_138B

L_BRS_138D_1388:

	dec $1C

L_BRS_138F_138B:

	lda $1B
	sec
	sbc table_6250,X
	sta $17
	sty $E0
	cpx $E0
	beq L_BRS_13A4_139B
	txa
	lsr
	bcs L_BRS_13A4_139F
	jsr L_JSR_1CC1_13A1

L_BRS_13A4_139B:
L_BRS_13A4_139F:

	jmp L_JMP_14E5_13A4

L_BRS_13A7_136D:

	ldx $18
	bne L_BRS_13AE_13A9
	jmp L_JMP_142E_13AB

L_BRS_13AE_13A9:

	lda $17
	sec
	sbc table_622D,X
	sta $17
	dec $18
	bne L_BRS_142B_13B8
	lda $1D
	bpl L_BRS_13E9_13BC
	ldx $16
	jsr L_JSR_6E39_13C0
	bne L_BRS_13E9_13C3
	dec $27
	lda #$09
	sta $0500,X
	lda #$00
	sta $1D
	ldx #$02
	lda $16

L_BRS_13D4_13D9:

	cmp $21,X
	beq L_BRS_13DD_13D6
	dex
	bpl L_BRS_13D4_13D9
	bmi L_BRS_13E9_13DB

L_BRS_13DD_13D6:

	lda $20
	sta $24,X
	ldx #$0A
	jsr L_JSR_6307_13E3
	jsr L_JSR_62D3_13E6

L_BRS_13E9_13BC:
L_BRS_13E9_13C3:
L_BRS_13E9_13DB:

	ldx #$04

L_BRS_13EB_1427:

	lda $1B
	clc
	adc #$07
	cmp $4E,X
	bne L_BRS_1425_13F2
	lda $71,X
	bne L_BRS_1425_13F6
	jsr L_JSR_71FE_13F8
	sec
	sbc $15
	clc
	adc #$03
	cmp #$07
	bcs L_BRS_1425_1403
	inc $0206
	inc $71,X
	lda $4E,X
	lsr
	lsr
	lsr
	sta $78,X
	jsr L_JSR_71FE_1411
	cmp #$98
	bcc L_BRS_141A_1416
	lda #$98

L_BRS_141A_1416:

	sta $77,X
	dec $77,X
	ldx #$10
	jsr L_JSR_6307_1420
	ldx #$00

L_BRS_1425_13F2:
L_BRS_1425_13F6:
L_BRS_1425_1403:

	dex
	dex
	bpl L_BRS_13EB_1427
	inc $19

L_BRS_142B_13B8:

	jmp L_JMP_1451_142B

L_JMP_142E_13AB:

	ldx $19
	beq L_BRS_1458_1430
	lda $17
	clc
	adc table_622D,X
	sta $17
	inc $19
	cmp $1B
	bcc L_BRS_1451_143E
	ldx $16
	lda $0510,X
	and #$03
	beq L_BRS_1451_1447
	lda $1B
	sta $17
	lda #$00
	sta $19

L_JMP_1451_12ED:
L_JMP_1451_142B:
L_BRS_1451_143E:
L_BRS_1451_1447:

	lda $1A
	sta $14
	jmp L_JMP_14CB_1455

L_BRS_1458_1430:

	ldx $16
	lda $14
	and #$08
	bne L_BRS_1485_145E
	lda $020E
	and #$08
	beq L_BRS_14CB_1465
	lda $14
	and #$20
	bne L_BRS_1470_146B
	jmp L_JMP_14B5_146D

L_BRS_1470_146B:

	jsr L_JSR_1CC1_1470
	lda $14
	sta $1A
	lda $1C
	beq L_BRS_1481_1479
	dec $1C
	inc $19
	bne L_BRS_1485_147F

L_BRS_1481_1479:

	lda #$08
	sta $18

L_BRS_1485_145E:
L_BRS_1485_147F:

	lda $14
	asl
	asl
	asl
	bcs L_BRS_1499_148A
	lda $0510,X
	and #$40
	beq L_BRS_14CB_1491
	inc $17
	lda #$0D
	bne L_BRS_14A5_1497

L_BRS_1499_148A:

	asl
	bcs L_BRS_14CB_149A
	lda $0500,X
	and #$40
	beq L_BRS_14CB_14A1
	lda #$01

L_BRS_14A5_1497:

	sta $1F
	txa
	and #$0F
	tax
	lda table_7109,X
	sta $15
	inc $1C
	jmp L_JMP_14E5_14B2

L_JMP_14B5_146D:

	txa
	and #$0F
	beq L_BRS_14CB_14B8
	cmp #$0D
	beq L_BRS_14CB_14BC
	lda $0500,X
	ora $0510,X
	and #$40
	bne L_BRS_14CB_14C6
	jsr L_JSR_7000_14C8

L_JMP_14CB_1455:
L_BRS_14CB_1465:
L_BRS_14CB_1491:
L_BRS_14CB_149A:
L_BRS_14CB_14A1:
L_BRS_14CB_14B8:
L_BRS_14CB_14BC:
L_BRS_14CB_14C6:

	ldx $15
	lda $14
	asl
	bcs L_BRS_14D3_14D0
	inx

L_BRS_14D3_14D0:

	asl
	bcs L_BRS_14D7_14D4
	dex

L_BRS_14D7_14D4:

	cpx #$FF
	bne L_BRS_14DD_14D9
	ldx #$9F

L_BRS_14DD_14D9:

	cpx #$A0
	bne L_BRS_14E3_14DF
	ldx #$00

L_BRS_14E3_14DF:

	stx $15

L_JMP_14E5_13A4:
L_JMP_14E5_14B2:

	lda $15
	clc
	adc #$06
	ldx #$FF
	sec

L_BRS_14ED_14F0:

	inx
	sbc #$0C
	bcs L_BRS_14ED_14F0
	stx $16
	ldx #$FF
	lda $17
	sec
	sbc #$0C
	sec

L_BRS_14FC_14FF:

	inx
	sbc #$14
	bcs L_BRS_14FC_14FF
	lda table_6249,X
	sta $1B
	txa
	asl
	asl
	asl
	asl
	ora $16
	sta $16
	tax
	jsr L_JSR_6E39_1510
	bne L_BRS_1531_1513
	lda $18
	ora $19
	ora $13
	ora $11
	ora $10
	ora $02
	bne L_BRS_1531_1521
	ldx #$16
	jsr L_JSR_6307_1525
	jsr L_JSR_62CF_1528
	lda #$40
	sta $13
	bne L_BRS_1546_152F

L_BRS_1531_1513:
L_BRS_1531_1521:

	lda $0510,X
	and #$03
	bne L_BRS_1546_1536
	lda $18
	ora $19
	bne L_BRS_1546_153C
	lda #$03
	sta $19
	lda $14
	sta $1A

L_JMP_1546_1270:
L_BRS_1546_152F:
L_BRS_1546_1536:
L_BRS_1546_153C:

	lda $02
	bmi L_BRS_1557_1548
	beq L_BRS_1557_154A
	lda $15
	and #$03
	clc
	adc #$09
	tax
	jmp L_JMP_1267_1554

L_BRS_1557_1548:
L_BRS_1557_154A:

	lda $10
	beq L_BRS_1591_1559
	cmp #$30
	bcs L_BRS_1591_155D
	cmp #$28
	bne L_BRS_1566_1561
	jmp L_JMP_1B5C_1563

L_BRS_1566_1561:

	bcc L_BRS_1583_1566

L_BRS_1568_159D:

	eor #$07
	.byte $2C

L_BRS_156B_158B:

	sbc #$00
	and #$07
	clc
	adc #$0E
	tax
	lda $16
	and #$0F
	tay
	lda table_7109,Y
	sta $15
	jsr L_JSR_1D17_157D
	jmp L_JMP_15D7_1580

L_BRS_1583_1566:

	cmp #$09
	bne L_BRS_158B_1585
	jsr L_JSR_1B18_1587
	sec

L_BRS_158B_1585:

	bcc L_BRS_156B_158B

L_JMP_158D_123E:
L_BRS_158D_159B:
L_BRS_158D_15A3:
L_JMP_158D_1B9F:

	ldx #$16
	bne L_BRS_15D7_158F

L_BRS_1591_1559:
L_BRS_1591_155D:

	lda $12
	beq L_BRS_15A5_1593
	cmp #$48
	bcs L_BRS_15A5_1597
	cmp #$40
	bcc L_BRS_158D_159B
	bne L_BRS_1568_159D
	lda #$00
	sta $28
	beq L_BRS_158D_15A3

L_BRS_15A5_1593:
L_BRS_15A5_1597:

	lda $1C
	beq L_BRS_15B2_15A7
	ldx $1F
	lda table_621F,X
	tax
	jmp L_JMP_15D7_15AF

L_BRS_15B2_15A7:

	ldx #$0C
	lda $18
	ora $19
	bne L_BRS_15C1_15B8
	lda $20
	and #$03
	asl
	tax
	inx

L_BRS_15C1_15B8:

	lda $14
	asl
	bcc L_BRS_15D7_15C4
	inx
	asl
	bcc L_BRS_15D7_15C8
	ldx #$00
	lda $18
	ora $19
	beq L_BRS_15D7_15D0
	ldx #$0D
	jmp L_JMP_1267_15D4

L_JMP_15D7_1580:
L_BRS_15D7_158F:
L_JMP_15D7_15AF:
L_BRS_15D7_15C4:
L_BRS_15D7_15C8:
L_BRS_15D7_15D0:

	lda table_65DE,X
	ldy table_65F5,X

L_JMP_15DD_126D:

	sta GEMINI		// LB
	sty GEMINI + 1		// HB

L_JMP_15E3_1350:
L_JMP_15E3_1368:

	jsr L_JSR_173B_15E3
	lda $13
	ora $02
	beq L_BRS_1610_15EA
	lda $02
	bmi L_BRS_1610_15EE
	lda $20
	and #$01
	bne L_BRS_1610_15F4
	sta FREHI2                          // Voice 2: Frequency Control - High-Byte
	jsr L_JSR_6200_15F9
	and #$0F
	sta FREHI3                          // Voice 3: Frequency Control - High-Byte
	ldy #$E0
	lda $13
	bne L_BRS_1609_1605
	ldy #$50

L_BRS_1609_1605:

	lda #$81
	ldx #$00
	jsr L_JSR_1D0D_160D

L_BRS_1610_15EA:
L_BRS_1610_15EE:
L_BRS_1610_15F4:

	ldy #$04
	lda $0D
	beq L_BRS_1618_1614
	ldy #$02

L_BRS_1618_1614:
L_BRS_1618_162E:
L_BRS_1618_1632:

	lda $0201
	sta $EF

L_BRS_161D_1622:

	lda $0201
	cmp $EF
	beq L_BRS_161D_1622
	sec
	sbc $020D
	cmp #$03
	bcs L_BRS_1634_162A
	cmp #$01
	bne L_BRS_1618_162E
	ldy #$0C
	bne L_BRS_1618_1632

L_BRS_1634_162A:

	lda $0201
	sta $020D
	ldx v_1D95

L_BRS_163D_1665:

	lda $0590,X
	cmp #$02
	bcs L_BRS_164F_1642
	lda $0510,X
	beq L_BRS_164F_1647
	lda #$02
	sta $0590,X
	dey

L_BRS_164F_1642:
L_BRS_164F_1647:

	dex
	txa
	and #$0F
	bne L_BRS_165E_1653
	txa
	sec
	sbc #$14
	tax
	bpl L_BRS_165E_165A
	ldx #$6C

L_BRS_165E_1653:
L_BRS_165E_165A:

	cpx v_1D95
	beq L_BRS_1667_1661
	cpy #$00
	bne L_BRS_163D_1665

L_BRS_1667_1661:

	stx v_1D95
	ldy #$00
	lda $02
	bmi L_BRS_1674_166E
	beq L_BRS_1674_1670
	ldy #$12

L_BRS_1674_166E:
L_BRS_1674_1670:
L_BRS_1674_1684:
L_BRS_1674_1688:
L_BRS_1674_168C:
L_BRS_1674_16AB:

	lda GEMINI:$F000,Y
	sta RAM8400,Y
	sta RAMC400,Y
	iny
	cpy #$33
	beq L_BRS_16AD_1680
	cpy #$09
	bcc L_BRS_1674_1684
	cpy #$2A
	bcs L_BRS_1674_1688
	lda $70
	beq L_BRS_1674_168C
	dec $70
	ldx #$00

L_BRS_1692_16A9:

	lda CONV,X
	stx $EF
	tax
	lda $0700,X
	and #$55
	sta RAM8400,Y
	sta RAMC400,Y
	iny
	ldx $EF
	inx
	cpy #$2A
	bne L_BRS_1692_16A9
	beq L_BRS_1674_16AB

L_BRS_16AD_1680:

	lda $15
	tay
	asl
	clc
	adc #$12
	sta SP0X                          // Sprite 0 X Pos
	cpy #$9B
	bcc L_BRS_16BE_16B9
	adc #$BE
	.byte $2C

L_BRS_16BE_16B9:

	lda #$00
	sta SP1X                          // Sprite 1 X Pos
	lda MSIGX                          // Sprites 0-7 MSB of X coordinate
	and #$FC
	cpy #$77
	bcc L_BRS_16CE_16CA
	ora #$01

L_BRS_16CE_16CA:

	sta MSIGX                          // Sprites 0-7 MSB of X coordinate
	lda #$00
	bit $DE
	bmi L_BRS_16DE_16D5
	lda $17
	beq L_BRS_16DE_16D9
	clc
	adc #$32

L_BRS_16DE_16D5:
L_BRS_16DE_16D9:

	sta SP0Y                          // Sprite 0 Y Pos
	sta SP1Y                          // Sprite 1 Y Pos
	ldx #$04

L_BRS_16E6_1716:

	lda $4E,X
	beq L_BRS_16FA_16E8
	ldy $4F,X
	bmi L_BRS_16F6_16EC
	beq L_BRS_16F6_16EE
	cpy #$3E
	bcs L_BRS_16FA_16F2
	adc #$05

L_BRS_16F6_16EC:
L_BRS_16F6_16EE:

	clc
	adc #$32
	.byte $2C

L_BRS_16FA_16E8:
L_BRS_16FA_16F2:

	lda #$00
	sta SP2Y,X                          // Sprite 2 Y Pos
	lda $48,X
	sta SP2X,X                          // Sprite 2 X Pos
	lda MSIGX                          // Sprites 0-7 MSB of X coordinate
	and table_68BB,X
	ldy $49,X
	beq L_BRS_1711_170C
	ora table_68BB + 1,X

L_BRS_1711_170C:

	sta MSIGX                          // Sprites 0-7 MSB of X coordinate
	dex
	dex
	bpl L_BRS_16E6_1716
	ldy #$1D

L_BRS_171A_1736:

	lda MOON:$F000,Y
	sta RAM8400 + $40,Y
	sta RAMC400 + $40,Y
	lda SUN:$F000,Y
	sta RAM8400 + $80,Y
	sta RAMC400 + $80,Y
	lda STARS:$F000,Y
	sta RAM8400 + $C0,Y
	sta RAMC400 + $C0,Y
	dey
	bpl L_BRS_171A_1736
	jmp L_JMP_09A4_1738

L_JSR_173B_15E3:

	inc $20
	beq L_BRS_1742_173D

L_BRS_173F_1748:
L_BRS_173F_174C:
L_BRS_173F_1750:
L_BRS_173F_1771:

	jmp L_JMP_17F5_173F

L_BRS_1742_173D:

	lda $21
	ora $22
	ora $23
	beq L_BRS_173F_1748
	lda $12
	bne L_BRS_173F_174C
	lda $D5
	beq L_BRS_173F_1750

L_BRS_1752_1767:

	jsr L_JSR_6200_1752
	and #$60
	sta $E0
	ldy #$FF
	ldx #$04

L_BRS_175D_176E:

	lda $4E,X
	beq L_BRS_176A_175F
	lda $5A,X
	and #$F0
	cmp $E0
	beq L_BRS_1752_1767
	.byte $2C

L_BRS_176A_175F:

	txa
	tay
	dex
	dex
	bpl L_BRS_175D_176E
	tya
	bmi L_BRS_173F_1771
	lda #$14
	sta $E1

L_BRS_1777_178F:

	jsr L_JSR_679B_1777
	ora $E0
	tax
	lda $0510,X
	beq L_BRS_178D_1780
	and #$F0
	bne L_BRS_178D_1784
	lda $0510,X
	and #$0C
	bne L_BRS_1794_178B

L_BRS_178D_1780:
L_BRS_178D_1784:

	dec $E1
	bne L_BRS_1777_178F
	jmp L_JMP_17F5_1791

L_BRS_1794_178B:

	lda #$3F
	sta $004F,Y
	stx $5A,Y
	lda #$00
	sta $0072,Y
	sta $0078,Y
	sta $0071,Y
	txa
	lsr
	lsr
	lsr
	lsr
	tax
	lda table_6249,X
	clc
	adc #$07
	sta $004E,Y
	lda $005A,Y
	and #$0F
	asl
	asl
	asl
	sta $E0
	adc #$0A
	asl
	adc $E0
	sta $0048,Y
	lda #$00
	rol
	sta $0049,Y

L_BRS_17CD_17D4:
L_BRS_17CD_17D9:

	jsr L_JSR_6200_17CD
	and #$03
	cmp #$03
	beq L_BRS_17CD_17D4
	cmp $02D8
	beq L_BRS_17CD_17D9
	sta $02D8
	sta $0054,Y
	tya
	lsr
	tay
	jsr L_JSR_6200_17E4
	and #$07
	tax
	lda table_1C8A,X
	sta SP2COL,Y                          // Sprite 2 Color
	ldx #$0F
	jsr L_JSR_6307_17F2

L_JMP_17F5_173F:
L_JMP_17F5_1791:

	lda $20
	and #$03
	ora $0D
	ora $13
	ora $02
	ora $10
	ora $12
	ora $11
	bne L_BRS_1865_1805
	bit $DE
	bvs L_BRS_1825_1809
	ldy #$00
	ldx #$02

L_BRS_180F_1815:

	lda $21,X
	beq L_BRS_1814_1811
	iny

L_BRS_1814_1811:

	dex
	bpl L_BRS_180F_1815
	cpy #$02
	bcs L_BRS_1865_1819
	lda $CE
	cmp #$09
	beq L_BRS_1825_181F
	cpy #$01
	beq L_BRS_1865_1823

L_BRS_1825_1809:
L_BRS_1825_181F:

	dec $0204
	bne L_BRS_1850_1828
	inc $0D
	jsr L_JSR_6200_182C
	and #$F0
	ora $0E
	sta $03
	lda #$01
	sta $0C
	lda #$18
	sta $0204
	ldx #$09
	jsr L_JSR_6307_1840

L_BRS_1843_184A:

	jsr L_JSR_6200_1843
	and #$1F
	cmp #$1D
	bcs L_BRS_1843_184A
	sta $09
	bcc L_BRS_1865_184E

L_BRS_1850_1828:

	lda $0204
	and #$C7
	bne L_BRS_1865_1855
	ldx #$08
	lda $0204
	and #$08
	beq L_BRS_1862_185E
	ldx #$19

L_BRS_1862_185E:

	jsr L_JSR_6307_1862

L_BRS_1865_1805:
L_BRS_1865_1819:
L_BRS_1865_1823:
L_BRS_1865_184E:
L_BRS_1865_1855:

	lda $11
	beq L_BRS_18C3_1867
	dec $11
	bne L_BRS_18C3_186B
	lda #$00
	sta FREHI3                          // Voice 3: Frequency Control - High-Byte
	sta VCREG3                          // Voice 3: Control Register
	inc $D0
	lda $D0
	cmp #$03
	bcc L_BRS_18B1_187B
	bne L_BRS_1889_187D
	lda $D1
	bmi L_BRS_1889_1881
	lda $D3
	cmp #$02
	bcs L_BRS_18B1_1887

L_BRS_1889_187D:
L_BRS_1889_1881:

	ldx #$1B
	jsr L_JSR_6307_188B
	lda $D1
	bmi L_BRS_18A5_1890
	sec
	lda $D6
	sbc $D2
	lda $D7
	sbc $D3
	bcs L_BRS_18A5_189B
	lda $D2
	sta $D6
	lda $D3
	sta $D7

L_BRS_18A5_1890:
L_BRS_18A5_189B:

	ldy #$62
	jsr L_JSR_31F7_18A7
	lda #$FF
	sta $DE
	jmp L_JMP_096C_18AE

L_BRS_18B1_187B:
L_BRS_18B1_1887:

	ldy #$56
	jsr L_JSR_31F7_18B3
	lda #$00
	sta $12
	sta $28
	jsr L_JSR_31FD_18BC
	lda #$18
	sta $10

L_BRS_18C3_1867:
L_BRS_18C3_186B:

	lda $10
	beq L_BRS_18D9_18C5
	dec $10
	bne L_BRS_18D9_18C9
	lda $0200
	sec
	sbc #$80
	sta $0200
	ldx #$20
	jsr L_JSR_62F4_18D6

L_BRS_18D9_18C5:
L_BRS_18D9_18C9:

	lda $12
	beq L_BRS_194E_18DB
	dec $12
	bne L_BRS_190A_18DF
	lda $B0
	bne L_BRS_18FB_18E3
	lda #$10
	ldx $CE
	cpx #$09
	bne L_BRS_18EF_18EB
	lda #$50

L_BRS_18EF_18EB:

	jsr L_JSR_6531_18EF
	ldx #$15
	jsr L_JSR_6307_18F4
	ldy #$3C
	bne L_BRS_1902_18F9

L_BRS_18FB_18E3:

	ldx #$14
	jsr L_JSR_6307_18FD
	ldy #$30

L_BRS_1902_18F9:

	jsr L_JSR_31F7_1902
	ldx #$18
	jmp L_JMP_3200_1907

L_BRS_190A_18DF:

	cmp #$20
	bne L_BRS_1950_190C
	ldx #$7D

L_BRS_1910_194C:

	txa
	and #$10
	beq L_BRS_194B_1913
	lda $0500,X
	and #$F0
	bne L_BRS_194B_191A
	lda $0500,X
	and #$0C
	beq L_BRS_194B_1921
	lsr
	lsr
	sta $E0
	inc $B0
	txa
	lsr
	lsr
	lsr
	lsr
	lsr
	tay
	lda table_1C1D_4bytes,Y
	pha
	txa
	and #$0F
	tay
	lda table_6E77,Y
	asl
	asl
	stx $EA
	tax
	pla
	tay
	lda $E0
	ora #$80
	jsr L_JSR_71D6_1946
	ldx $EA

L_BRS_194B_1913:
L_BRS_194B_191A:
L_BRS_194B_1921:

	dex
	bne L_BRS_1910_194C

L_BRS_194E_18DB:

	beq L_BRS_1968_194E

L_BRS_1950_190C:

	cmp #$38
	bne L_BRS_196A_1952
	ldx #$6D

L_BRS_1956_1966:

	txa
	and #$10
	bne L_BRS_1965_1959
	lda $0510,X
	and #$10
	beq L_BRS_1965_1960
	jsr L_JSR_7116_1962

L_BRS_1965_1959:
L_BRS_1965_1960:

	dex
	bne L_BRS_1956_1966

L_BRS_1968_194E:

	beq L_BRS_1990_1968

L_BRS_196A_1952:

	cmp #$31
	bne L_BRS_1990_196C
	ldy #$04
	lda #$00
	sta $B0

L_BRS_1974_198C:

	lda #$00
	sta $00AD,Y
	lda $004F,Y
	bmi L_BRS_198A_197C
	lda $004E,Y
	beq L_BRS_198A_1981
	lda #$E8
	sta $004F,Y
	inc $B0

L_BRS_198A_197C:
L_BRS_198A_1981:

	dey
	dey
	bpl L_BRS_1974_198C
	bmi L_BRS_1990_198E

L_BRS_1990_1968:
L_BRS_1990_196C:
L_BRS_1990_198E:

	lda $D5
	cmp #$10
	bne L_BRS_1999_1994

L_BRS_1996_199B:
L_BRS_1996_19A5:

	jmp L_JMP_1A3D_1996

L_BRS_1999_1994:

	ora $D4
	beq L_BRS_1996_199B
	lda $11
	ora $13
	ora $12
	ora $10
	bne L_BRS_1996_19A5
	lda $16
	cmp $28
	bne L_BRS_19E9_19AB
	sed
	lda $D4
	clc
	adc #$20
	and #$E0
	sta $D4
	lda $D5
	adc #$00
	sta $D5
	cld
	cmp #$10
	bne L_BRS_19CF_19C0
	ldx $20
	stx $0200
	lda #$00
	sta FREHI2                          // Voice 2: Frequency Control - High-Byte
	jmp L_JMP_1A3A_19CC

L_BRS_19CF_19C0:

	cld
	asl
	asl
	asl
	asl
	sta $E0
	lda $D4
	lsr
	lsr
	lsr
	lsr
	ora $E0
	lsr
	lsr
	clc
	adc #$10
	sta FREHI2                          // Voice 2: Frequency Control - High-Byte
	jmp L_JMP_1A1C_19E6

L_BRS_19E9_19AB:

	lda $20
	and SEVEN:#07
	bne L_BRS_1A3D_19ED
	sed
	lda $D4
	sec
	sbc #$10
	sta $D4
	lda $D5
	sbc #$00
	sta $D5
	cld
	cmp #$05
	bne L_BRS_1A0B_1A00
	lda $D4
	bne L_BRS_1A0B_1A04
	ldx #$05
	jsr L_JSR_6307_1A08

L_BRS_1A0B_1A00:
L_BRS_1A0B_1A04:

	lda SEVEN
	asl
	ora #$01
	and $20
	ora $2A
	bne L_BRS_1A3A_1A15
	lda #$13
	sta FREHI2                          // Voice 2: Frequency Control - High-Byte

L_JMP_1A1C_19E6:

	lda #$11
	ldx #$20
	ldy #$E1
	sty $E0
	stx ATDCY2                          // Voice 2: Attack / Decay Cycle Control
	sty SUREL2                          // Voice 2: Sustain / Release Cycle Control
	sta VCREG2                          // Voice 2: Control Register
	ldy #$14

L_BRS_1A2F_1A30:
L_BRS_1A2F_1A33:

	inx
	bne L_BRS_1A2F_1A30
	dey
	bne L_BRS_1A2F_1A33
	lda #$00
	sta VCREG2                          // Voice 2: Control Register

L_JMP_1A3A_19CC:
L_BRS_1A3A_1A15:

	jsr L_JSR_656E_1A3A

L_JMP_1A3D_1996:
L_BRS_1A3D_19ED:

	ldy #$02

L_BRS_1A3F_1A6E:

	ldx $21,Y
	beq L_BRS_1A6D_1A41
	lda #$04
	sta $0590,X
	lda $20
	cmp $0024,Y
	bne L_BRS_1A6D_1A4D
	dec $0500,X
	lda $0500,X
	bne L_BRS_1A5C_1A55
	sta $0021,Y
	beq L_BRS_1A6D_1A5A

L_BRS_1A5C_1A55:

	cmp #$03
	bcs L_BRS_1A6D_1A5E
	stx $EA
	tya
	pha
	ldx #$07
	jsr L_JSR_6307_1A66
	ldx $EA
	pla
	tay

L_BRS_1A6D_1A41:
L_BRS_1A6D_1A4D:
L_BRS_1A6D_1A5A:
L_BRS_1A6D_1A5E:

	dey
	bpl L_BRS_1A3F_1A6E
	lda $20
	cmp $0200
	bne L_BRS_1A8C_1A75
	ldx #$05
	lda $D5
	cmp #$05
	bcc L_BRS_1A89_1A7D
	ldx #$01
	lda $1E
	cmp #$03
	bne L_BRS_1A89_1A85
	ldx #$0B

L_BRS_1A89_1A7D:
L_BRS_1A89_1A85:

	jsr L_JSR_6307_1A89

L_BRS_1A8C_1A75:

	bit $DE
	bvs L_BRS_1AA9_1A8E
	lda $20
	and #$1F
	bne L_BRS_1AA9_1A94
	jsr L_JSR_6200_1A96
	ldy $CE
	cmp table_67AB,Y
	bcs L_BRS_1AA9_1A9E
	ldx #$02

L_BRS_1AA2_1AA7:

	lda $2E,X
	beq L_BRS_1AAC_1AA4
	dex
	bpl L_BRS_1AA2_1AA7

L_BRS_1AA9_1A8E:
L_BRS_1AA9_1A94:
L_BRS_1AA9_1A9E:

	jmp L_JMP_1B17_1AA9

L_BRS_1AAC_1AA4:

	sta $34,X
	sta $40,X

L_BRS_1AB0_1AC7:
L_BRS_1AB0_1ACB:
L_BRS_1AB0_1AF7:

	jsr L_JSR_6200_1AB0
	and #$03
	tay
	lda table_67B5,Y
	sta $E4
	jsr L_JSR_679B_1ABB
	ora table_67B9,Y
	tay
	lda $0510,Y
	cmp #$25
	beq L_BRS_1AB0_1AC7
	cpy $16
	beq L_BRS_1AB0_1ACB
	sty $E5
	lda #$01
	sta $31,X
	ldy $CE
	cpy #$03
	bcc L_BRS_1AF0_1AD7
	jsr L_JSR_6200_1AD9
	cmp #$80
	bcc L_BRS_1AF0_1ADE
	cmp #$C0
	bcs L_BRS_1AEA_1AE2
	cpy #$06
	bcc L_BRS_1AF0_1AE6
	bcs L_BRS_1AEE_1AE8

L_BRS_1AEA_1AE2:

	dec $E4
	dec $E4

L_BRS_1AEE_1AE8:

	dec $31,X

L_BRS_1AF0_1AD7:
L_BRS_1AF0_1ADE:
L_BRS_1AF0_1AE6:

	ldy #$02
	lda $E4

L_BRS_1AF4_1AFA:

	cmp $002E,Y
	beq L_BRS_1AB0_1AF7
	dey
	bpl L_BRS_1AF4_1AFA
	lda $E4
	sta $2E,X
	lda $E5
	sta $43,X
	and #$0F
	asl
	asl
	sec
	sbc #$02
	sta $2B,X
	sta $37,X
	lda #$20
	sta $3A,X
	lda #$01
	sta $3D,X

L_JMP_1B17_1AA9:

	rts

L_JSR_1B18_1587:

	lda $0209
	and #$60

L_BRS_1B1D_1B37:
L_BRS_1B1D_1B3A:

	sta $E0

L_BRS_1B1F_1B26:

	jsr L_JSR_6200_1B1F
	and #$60
	cmp $E0
	beq L_BRS_1B1F_1B26
	sta $ED
	ldx #$01
	lda #$00
	jsr L_JSR_7C38_1B2E
	lda $EE
	bne L_BRS_1B39_1B33
	lda #$FF
	bmi L_BRS_1B1D_1B37

L_BRS_1B39_1B33:

	txa
	beq L_BRS_1B1D_1B3A
	sta $28
	sta $16
	sta $0209
	lsr
	lsr
	lsr
	lsr
	tax
	lda table_6249,X
	sta $17
	lda $16
	and #$0F
	tax
	lda table_7109,X
	sta $15
	ldx #$0E
	jmp L_JMP_6307_1B59

L_JMP_1B5C_1563:

	ldx #$20
	jsr L_JSR_62D3_1B5E
	lda #$18
	sta $70
	ldy #$FF
	lda $1D
	bpl L_BRS_1B6F_1B69
	lda #$00
	beq L_BRS_1B7A_1B6D

L_BRS_1B6F_1B69:

	clc
	sed
	adc $1D
	cld
	cmp #$80
	bcc L_BRS_1B7A_1B76
	lda #$78

L_BRS_1B7A_1B6D:
L_BRS_1B7A_1B76:

	jsr L_JSR_71D6_1B7A
	ldx #$04

L_BRS_1B7F_1B91:

	lda $4E,X
	beq L_BRS_1B8F_1B81
	lda $71,X
	beq L_BRS_1B8F_1B85
	lda $4F,X
	bmi L_BRS_1B8F_1B89
	lda #$98
	sta $4F,X

L_BRS_1B8F_1B81:
L_BRS_1B8F_1B85:
L_BRS_1B8F_1B89:

	dex
	dex
	bpl L_BRS_1B7F_1B91
	lda #$00
	sta $02D7
	sta $1D
	sta $0206
	sta $28
	jmp L_JMP_158D_1B9F

L_JMP_1BA2_0C7A:
L_JMP_1BA2_0CC9:

	lda $55,X
	eor #$01
	sta $55,X
	jmp L_JMP_0C50_1BA8

table_1BAB_7andFs:

	.byte $17,$2F,$47,$5F,$77,$8F,$A7

L_JMP_1BB2_0813:
L_JSR_1BB2_0C98:

	and #$0F
	clc
	adc #$07
	sta $1BC0
	txa
	sec
	sbc $15
	clc
	adc #$00
	bcc L_BRS_1C18_1BC1
	cpy $17
	bcc L_BRS_1C18_1BC5
	tya
	sbc #$14
	cmp $17
	bcs L_BRS_1C18_1BCC
	lda $16
	cmp $28
	beq L_BRS_1C18_1BD2
	lda $11
	ora $DE
	ora $02
	ora $13
	ora $10
	ora $12
	bne L_BRS_1C18_1BE0
	lda $D5
	cmp #$10
	bne L_BRS_1BFC_1BE6
	lda #$09
	sta $D5
	lda #$90
	sta $D4
	lda #$07
	ldy $CE
	cpy #$06
	bcc L_BRS_1BF9_1BF6
	lsr

L_BRS_1BF9_1BF6:

	sta SEVEN

L_BRS_1BFC_1BE6:

	lsr SEVEN
	ldx #$04
	lda $1E
	cmp #$03
	beq L_BRS_1C08_1C05
	dex

L_BRS_1C08_1C05:

	jsr L_JSR_6307_1C08
	lda #$20
	sta $2A
	lda #$03
	sta $1E
	ldx $EE
	lda #$FF
	rts

L_BRS_1C18_1BC1:
L_BRS_1C18_1BC5:
L_BRS_1C18_1BCC:
L_BRS_1C18_1BD2:
L_BRS_1C18_1BE0:

	ldx $EE
	lda #$00
	rts

table_1C1D_4bytes:

	.byte $06,$0B,$10,$15

L_JSR_1C21_100B:
L_JSR_1C21_101D:
L_JSR_1C21_1034:

	dex
	stx $EF
	lda $09
	jsr L_JSR_6E5A_1C26
	ldx #$00
	jsr L_JSR_6762_1C2B
	ldy #$0B
	lda $03
	jsr L_JSR_1C45_1C32
	ldx $EF
	cpx #$03
	bcs L_BRS_1C4C_1C39
	lda $E5
	and #$1F
	ora #$D8
	sta $E5
	lda #$01

L_JSR_1C45_1C32:
L_BRS_1C45_1C4F:

	ldy #$0B

L_BRS_1C47_1C4A:
L_BRS_1C47_1C53:

	sta ($E4),Y
	dey
	bpl L_BRS_1C47_1C4A

L_BRS_1C4C_1C39:

	rts

L_JSR_1C4D_0A5E:
L_JSR_1C4D_0A6E:

	ldx $05
	beq L_BRS_1C45_1C4F
	ldy #$0F
	bne L_BRS_1C47_1C53

table_1C55_dinomama:

	.byte $0E,$0D,$0C,$0E,$0D,$0C,$0E,$0D
	.byte $0C,$0E,$0D,$0C,$0E,$0D,$0C,$0E
	.byte $0D,$0C,$0E,$0D,$0C

table_1C6A:

	.byte $00,$00,$01
	.byte $01,$01,$02,$02,$02,$03,$03,$03
	.byte $04,$04,$04,$05,$05,$05,$06,$06
	.byte $06,$07,$07,$07,$08,$08,$08,$09
	.byte $09
	
table_1C86:
	
	.byte $09,$00,$0A,$14
	
table_1C8A:
	
	.byte $01,$03,$07
	.byte $0E,$0D,$01,$0A,$04
	
table_1C92:
	
	.byte $1C,$3C,$7C
	.byte $FC,$7C,$3C,$1C,$00
	
table_1C9A:
	
	.byte $E0,$F0,$F8
	.byte $FC,$F8,$F0,$E0,$00

L_JSR_1CA2_1293:

	ldy #$03

L_BRS_1CA4_1CB7:

	lda $CF80,Y
	sta $BCDC,Y
	sta $FCDC,Y
	lda $CF84,Y
	sta $BE18,Y
	sta $FE18,Y                          // Control OS Messages
	dey
	bpl L_BRS_1CA4_1CB7
	rts

NMI:	// 1CBA

	lda #$00
	sta $DE
	jmp L_JMP_1204_1CBE

L_JSR_1CC1_1313:
L_JSR_1CC1_13A1:
L_JSR_1CC1_1470:

	lda #$F0
	sta SUREL3                          // Voice 3: Sustain / Release Cycle Control
	lda #$00
	sta VCREG3                          // Voice 3: Control Register
	lda #$12
	sta FREHI3                          // Voice 3: Frequency Control - High-Byte
	lda #$21
	ldx #$11
	ldy #$A0
	jsr L_JSR_1D0D_1CD6
	ldy #$0A
	ldx #$00

L_BRS_1CDD_1CDE:
L_BRS_1CDD_1CEA:

	inx
	bne L_BRS_1CDD_1CDE
	tya
	asl
	asl
	clc
	adc #$20
	sta FREHI3                          // Voice 3: Frequency Control - High-Byte
	dey
	bne L_BRS_1CDD_1CEA
	ldy #$00
	sty VCREG3                          // Voice 3: Control Register
	sty FREHI3                          // Voice 3: Frequency Control - High-Byte
	rts

L_JSR_1CF5_1365:

	jsr L_JSR_6200_1CF5
	and #$07
	ora #$20
	sta FREHI3                          // Voice 3: Frequency Control - High-Byte
	ldy #$00
	lda #$08
	ldx $2A
	beq L_BRS_1D0B_1D05
	ldy #$82
	lda #$11

L_BRS_1D0B_1D05:

	ldx #$52

L_JSR_1D0D_160D:
L_JSR_1D0D_1CD6:

	stx ATDCY3                          // Voice 3: Attack / Decay Cycle Control
	sty SUREL3                          // Voice 3: Sustain / Release Cycle Control
	sta VCREG3                          // Voice 3: Control Register
	rts

L_JSR_1D17_157D:

	stx $E0
	txa
	sec
	sbc #$0E
	eor #$07
	sta $E1
	tay
	asl
	asl
	clc
	adc table_1D65,Y
	sta $E2
	sta FREHI3                          // Voice 3: Frequency Control - High-Byte
	lda table_1D6D,Y
	sta VCREG3                          // Voice 3: Control Register
	lda table_1D75,Y
	sta ATDCY3                          // Voice 3: Attack / Decay Cycle Control
	lda #$F1
	sta SUREL3                          // Voice 3: Sustain / Release Cycle Control
	lda $E1
	asl
	asl
	tay
	iny
	ldx #$00

L_BRS_1D46_1D47:
L_BRS_1D46_1D58:

	inx
	bne L_BRS_1D46_1D47
	lda $E2
	clc
	adc #$03
	and #$1F
	eor $E2
	sta $E2
	sta FREHI3                          // Voice 3: Frequency Control - High-Byte
	dey
	bne L_BRS_1D46_1D58
	lda #$00
	sta VCREG3                          // Voice 3: Control Register
	sta SUREL3                          // Voice 3: Sustain / Release Cycle Control
	ldx $E0
	rts

table_1D65:

	.byte $23,$31,$43,$52,$7A,$9E,$B6,$DE

table_1D6D:

	.byte $11,$21,$11,$21,$11,$21,$11,$21

table_1D75:

	.byte $00,$00,$10,$10,$20,$20,$30,$30

L_JSR_1D7D_0CEB:

	eor #$07
	asl
	ora #$40
	sta FREHI1                          // Voice 1: Frequency Control - High-Byte
	lda #$31
	sta ATDCY1                          // Voice 1: Attack / Decay Cycle Control
	lda #$A1
	sta SUREL1                          // Voice 1: Sustain / Release Cycle Control
	lda #$11
	sta VCREG1                          // Voice 1: Control Register
	rts

// 1D95

	.byte $00,$23			// 0,[$]

BlockRead:	// 1D97

	.byte $55,$31,$3A,$35,$2C,$30,$2C	// disk command <U1:channel,drive,t,s>
	.byte $31,$38,$2C,$31,$38		// "U1:5,0,18,18"

	.byte $2C,$31,$38			// 1DA3

	.byte $FF,$7D,$06,$05,$20,$A7,$04	// 1DA6
	.byte $EF,$00,$5F,$25,$FF,$0E,$00,$04
	.byte $FF,$04,$DF,$B5,$5E,$91,$B5,$2F
	.byte $7F,$0F,$95,$45,$FD,$07,$BD,$04
	.byte $FB,$0E,$FD,$30,$7F,$00,$E4,$80
	.byte $BF,$0F,$3F,$05,$B5,$1F,$9F,$D5
	.byte $FF,$94,$FF,$14,$77,$04,$DE,$CF
	.byte $EF,$4F,$FF,$04,$F7,$01,$FD,$04
	.byte $D7,$04,$B7,$06,$6F,$10,$BF,$DD
	.byte $FF,$47,$95,$00,$EE,$10,$05,$04
	.byte $FF,$04,$7C,$95,$FF,$94,$B5,$4F
	.byte $B7,$CF,$FF,$FF,$FF,$FF,$6F,$FF
	.byte $6F,$FF,$00,$FF,$B1,$FF,$02,$FF
	.byte $FF,$FF,$3E,$FF,$FF,$4F,$7F,$FF
	.byte $F7,$FF,$FF,$FF,$01,$DF,$FF,$FF
	.byte $D7,$FF,$FF,$FF,$FF,$FF,$42,$FF
	.byte $FF,$7F,$FF,$BF,$FF,$DF,$FF,$FF
	.byte $7F,$FF,$FD,$DF,$95,$F5,$FF,$FF
	.byte $00,$FF,$4E,$FF,$B1,$FF,$6F,$FF
	.byte $4F,$FF,$4F,$FF,$27,$DF,$6F,$FF
	.byte $0E,$FF,$BF,$DF,$95,$FF,$FF,$7F
	.byte $FF,$FF,$FF,$FF,$4F,$7F,$7F,$FF
	.byte $7F,$FF,$00,$FF,$9F,$FF,$F5,$FF
	.byte $D6,$FF,$00,$FF,$0D,$FF,$00,$FF
	.byte $B7,$FF,$FF,$BF,$B1,$FE,$FF,$FF
	.byte $00,$FF,$FF,$FF,$5F,$EF,$FF,$FF
	.byte $04,$FF,$CF,$FF,$00,$FF,$6F,$FF
	.byte $FF,$FF,$00,$05,$B5,$05,$BF,$14
	.byte $BF,$05,$BF,$0A,$4E,$00,$FF,$04
	.byte $34,$1F,$FF,$05,$35,$B0,$9F,$5F
	.byte $FF,$04,$A7,$94,$EE,$84,$F7,$45
	.byte $FF,$1B,$1F,$05,$07,$05,$BD,$05
	.byte $07,$95,$75,$0E,$05,$20,$A7,$05
	.byte $AF,$00,$5F,$35,$FF,$1E,$0C,$04
	.byte $FF,$05,$DF,$B5,$5E,$91,$B5,$2F
	.byte $7F,$0F,$95,$05,$FD,$07,$BD,$04
	.byte $FB,$06,$D5,$30,$7F,$00,$A4,$80
	.byte $BF,$0F,$3F,$05,$B5,$9F,$9F,$D5
	.byte $FF,$94,$F7,$14,$77,$04,$DE,$EF
	.byte $EF,$4F,$FF,$05,$D7,$01,$FD,$04
	.byte $D7,$05,$B5,$06,$2D,$00,$B7,$9D
	.byte $FF,$45,$95,$01,$FF,$10,$05,$04
	.byte $FF,$05,$5D,$95,$DF,$94,$B5,$4F
	.byte $B5,$CF,$FF,$FF,$FF,$FF,$6F,$FF
	.byte $6F,$FF,$00,$FF,$B1,$FF,$02,$FF
	.byte $FF,$FF,$0F,$FF,$FF,$4E,$6C,$FF
	.byte $C7,$FF,$FF,$FF,$00,$FF,$FF,$FF
	.byte $C6,$FF,$FF,$FF,$FF,$FF,$42,$FF
	.byte $FF,$6E,$EF,$FF,$FF,$DF,$7F,$FF
	.byte $5E,$FF,$FF,$DF,$91,$F1,$FF,$FF
	.byte $00,$FF,$4C,$FF,$B1,$FF,$4E,$FF
	.byte $4E,$FF,$4F,$FF,$27,$FF,$6F,$FF
	.byte $0E,$FF,$BF,$DF,$91,$FF,$7F,$7F
	.byte $FF,$FF,$FF,$FF,$6F,$6D,$7D,$FF
	.byte $4F,$FF,$00,$FF,$9E,$FF,$F5,$FF
	.byte $D6,$FF,$00,$FF,$0C,$FF,$00,$FF
	.byte $B7,$FF,$EF,$FF,$B1,$FE,$FF,$FF
	.byte $00,$FF,$EF,$FF,$5F,$EF,$FF,$FF
	.byte $00,$FF,$CF,$FF,$00,$FF,$6E,$FF
	.byte $EF,$FF,$00,$45,$BF,$07,$BF,$14
	.byte $BF,$05,$BF,$0A,$4E,$00,$FF,$04
	.byte $3C,$2F,$FF,$05,$35,$B0,$9F,$5E
	.byte $FF,$14,$A7,$94,$6F,$84,$F7,$44
	.byte $FF,$0B,$5F,$04,$07,$05,$BD,$05
	.byte $07,$95,$75,$06,$05,$20,$A7,$05
	.byte $EF,$00,$5F,$25,$FF,$0E,$00,$04
	.byte $FF,$04,$DF,$B5,$5E,$91,$B5,$2F
	.byte $7F,$0F,$95,$05,$FD,$07,$BD,$04
	.byte $FB,$0E,$F5,$30,$7F,$00,$E4,$80
	.byte $BF,$0F,$3F,$05,$B5,$1F,$9F,$D5
	.byte $FF,$94,$FF,$14,$77,$04,$DE,$6F
	.byte $EF,$4F,$FF,$04,$D7,$01,$FD,$04
	.byte $D7,$05,$B7,$06,$6D,$00,$BF,$DD
	.byte $FF,$47,$95,$05,$FE,$10,$05,$04
	.byte $FF,$04,$5C,$95,$FF,$94,$B5,$4F
	.byte $B5,$4F,$FF,$00,$3C,$00,$00,$FF
	.byte $00,$03,$00,$C0,$03,$14,$C0,$00
	.byte $14,$D9,$05,$69,$00,$01,$AA,$40
	.byte $01,$AA,$40,$01,$AA,$40,$00,$96
	.byte $00,$00,$96,$00,$00,$82,$00,$00
	.byte $82,$00,$00,$82,$00,$00,$82,$00
	.byte $01,$41,$40,$00,$3C,$00,$00,$FC
	.byte $00,$03,$00,$00,$03,$14,$00,$03
	.byte $15,$00,$00,$10,$00,$2A,$A8,$00
	.byte $20,$A8,$14,$14,$AA,$A0,$00,$A8
	.byte $00,$00,$50,$00,$00,$96,$A0,$00
	.byte $AA,$A0,$00,$80,$54,$00,$80,$00
	.byte $02,$00,$00,$01,$50,$00,$00,$3C
	.byte $00,$00,$FC,$00,$03,$00,$00,$03
	.byte $14,$00,$03,$15,$00,$00,$10,$00
	.byte $00,$A8,$00,$14,$A8,$14,$00,$AA
	.byte $A0,$00,$A8,$00,$00,$50,$00,$00
	.byte $96,$00,$00,$AA,$A0,$0A,$80,$20
	.byte $08,$02,$A0,$08,$00,$54,$05,$D9
	.byte $03,$3C,$00,$00,$FC,$00,$03,$00
	.byte $00,$03,$14,$00,$03,$15,$00,$00
	.byte $10,$00,$00,$A8,$00,$02,$A8,$00
	.byte $02,$A9,$00,$01,$A8,$00,$00,$14
	.byte $00,$00,$58,$00,$02,$A8,$00,$1A
	.byte $A8,$00,$10,$08,$00,$10,$08,$00
	.byte $00,$15,$00,$00,$3C,$00,$00,$FC
	.byte $00,$03,$00,$00,$03,$14,$00,$03
	.byte $15,$00,$00,$10,$00,$00,$A8,$00
	.byte $02,$A8,$00,$02,$A9,$00,$01,$A8
	.byte $00,$00,$14,$00,$00,$58,$00,$00
	.byte $AA,$00,$00,$0A,$00,$00,$08,$00
	.byte $00,$05,$40,$00,$54,$00,$00,$3C
	.byte $00,$00,$3F,$D9,$03,$C0,$00,$14
	.byte $C0,$00,$54,$C0,$00,$04,$00,$00
	.byte $2A,$A8,$14,$2A,$08,$0A,$AA,$14
	.byte $00,$2A,$00,$00,$05,$00,$0A,$96
	.byte $00,$0A,$AA,$00,$15,$02,$00,$00
	.byte $02,$D9,$03,$80,$00,$05,$40,$00
	.byte $3C,$00,$00,$3F,$D9,$03,$C0,$00
	.byte $14,$C0,$00,$54,$C0,$00,$04,$00
	.byte $00,$2A,$00,$14,$2A,$14,$0A,$AA
	.byte $00,$00,$2A,$00,$00,$05,$00,$00
	.byte $96,$00,$0A,$AA,$00,$08,$02,$A0
	.byte $0A,$80,$20,$15,$00,$20,$00,$00
	.byte $50,$00,$3C,$00,$00,$3F,$D9,$03
	.byte $C0,$00,$14,$C0,$00,$54,$C0,$00
	.byte $04,$00,$00,$2A,$00,$00,$2A,$80
	.byte $00,$6A,$80,$00,$2A,$40,$00,$14
	.byte $00,$00,$25,$00,$00,$2A,$80,$00
	.byte $2A,$A4,$00,$20,$04,$00,$20,$04
	.byte $00,$54,$00,$00,$3C,$00,$00,$3F
	.byte $D9,$03,$C0,$00,$14,$C0,$00,$54
	.byte $C0,$00,$04,$00,$00,$2A,$00,$00
	.byte $2A,$80,$00,$6A,$80,$00,$2A,$40
	.byte $00,$14,$00,$00,$25,$00,$00,$AA
	.byte $00,$00,$A0,$00,$00,$20,$00,$01
	.byte $50,$00,$00,$15,$00,$00,$3C,$00
	.byte $00,$FF,$00,$03,$00,$C0,$03,$14
	.byte $C0,$40,$14,$00,$60,$00,$00,$2A
	.byte $AA,$A0,$02,$AA,$A8,$00,$AA,$09
	.byte $00,$96,$01,$00,$96,$A8,$00,$AA
	.byte $A8,$02,$AA,$08,$2A,$00,$15,$20
	.byte $00,$00,$20,$00,$00,$54,$D9,$06
	.byte $3C,$00,$00,$FF,$00,$03,$00,$C0
	.byte $03,$14,$C0,$00,$14,$D9,$04,$5A
	.byte $AA,$A5,$0A,$AA,$A0,$00,$AA,$00
	.byte $00,$96,$00,$00,$96,$00,$2A,$AA
	.byte $A8,$2A,$AA,$A8,$20,$00,$08,$54
	.byte $00,$15,$D9,$04,$3C,$00,$00,$FF
	.byte $00,$03,$00,$C0,$03,$14,$C0,$00
	.byte $14,$01,$00,$00,$09,$0A,$AA,$A8
	.byte $2A,$AA,$80,$60,$AA,$00,$40,$96
	.byte $00,$2A,$96,$00,$2A,$AA,$00,$20
	.byte $AA,$80,$54,$00,$A8,$00,$00,$08
	.byte $00,$00,$08,$00,$00,$15,$00,$3C
	.byte $00,$00,$FC,$00,$03,$00,$00,$03
	.byte $14,$00,$03,$15,$00,$00,$10,$00
	.byte $2A,$A8,$50,$20,$A8,$20,$14,$AA
	.byte $A0,$00,$54,$00,$00,$AA,$A0,$00
	.byte $AA,$A0,$1A,$A8,$20,$5A,$A8,$15
	.byte $40,$D9,$09,$3C,$00,$00,$3F,$D9
	.byte $03,$C0,$00,$14,$C0,$00,$54,$C0
	.byte $00,$04,$00,$05,$2A,$A8,$08,$2A
	.byte $08,$0A,$AA,$14,$00,$15,$00,$0A
	.byte $AA,$00,$0A,$AA,$00,$08,$2A,$A4
	.byte $54,$2A,$A5,$00,$00,$01,$D9,$06
	.byte $AA,$AE,$2A,$F0,$FC,$3F,$0F,$02
	.byte $AA,$B2,$0A,$2F,$3C,$AA,$AA,$82
	.byte $AA,$A8,$A2,$0F,$3F,$FC,$C0,$80
	.byte $0A,$FA,$C2,$00,$0F,$3F,$F0,$00
	.byte $3C,$3C,$82,$AA,$AA,$0F,$0F,$00
	.byte $A0,$A0,$BC,$FC,$0F,$00,$F0,$3C
	.byte $AA,$BB,$A8,$8A,$D9,$04,$AA,$AA
	.byte $8A,$A8,$88,$D9,$03,$AA,$80,$00
	.byte $00,$AA,$AC,$28,$D9,$03,$2A,$3A
	.byte $0A,$D9,$05,$80,$80,$D9,$12,$2A
	.byte $3E,$D9,$06,$80,$00,$AA,$AA,$D9
	.byte $06,$0A,$D9,$13,$AA,$AA,$28,$D9
	.byte $03,$2A,$0A,$D9,$14,$AA,$AB,$3B
	.byte $8F,$0F,$03,$00,$03,$AA,$FA,$D8
	.byte $04,$00,$FF,$AA,$88,$E2,$FA,$F0
	.byte $C0,$00,$C0,$AA,$AA,$8B,$2F,$0F
	.byte $03,$00,$03,$AA,$0A,$D8,$04,$00
	.byte $FF,$AA,$BA,$E0,$F0,$F0,$C0,$00
	.byte $C0,$AA,$AE,$8B,$2F,$0F,$03,$00
	.byte $03,$AA,$BE,$D8,$04,$00,$FF,$AA
	.byte $AA,$E2,$F8,$F8,$C0,$00,$C0,$0F
	.byte $0F,$03,$D9,$05,$D8,$03,$D9,$05
	.byte $F0,$F0,$C0,$D9,$05,$0F,$0F,$03
	.byte $00,$03,$0F,$0F,$03,$D8,$03,$00
	.byte $D8,$04,$F0,$F0,$C0,$00,$C0,$F0
	.byte $F0,$C0,$AA,$AB,$3B,$8F,$0F,$03
	.byte $00,$00,$AA,$FA,$D8,$04,$00,$00
	.byte $AA,$88,$E2,$FA,$F0,$C0,$00,$00
	.byte $AA,$AA,$8B,$2F,$0F,$03,$00,$00
	.byte $AA,$0A,$D8,$04,$00,$00,$AA,$BA
	.byte $E0,$F0,$F0,$C0,$00,$00,$AA,$AE
	.byte $8B,$2F,$0F,$03,$00,$00,$AA,$BE
	.byte $D8,$04,$00,$00,$AA,$AA,$E2,$F8
	.byte $F8,$C0,$00,$00,$AA,$AB,$3A,$8A
	.byte $02,$D9,$03,$AA,$FA,$2B,$88,$D9
	.byte $04,$AA,$88,$E2,$EA,$F0,$D9,$03
	.byte $AA,$AA,$8B,$20,$D9,$04,$AA,$0A
	.byte $EB,$E0,$D9,$04,$AA,$BA,$A0,$D9
	.byte $05,$AA,$AE,$88,$2C,$08,$D9,$03
	.byte $AA,$BE,$EA,$A3,$D9,$04,$AA,$AA
	.byte $E2,$A8,$88,$D9,$03,$AA,$B8,$8A
	.byte $22,$3E,$0C,$3F,$03,$AA,$CA,$AA
	.byte $C8,$F0,$3F,$03,$FF,$BA,$EA,$02
	.byte $FC,$C0,$F0,$FC,$0C,$33,$3C,$30
	.byte $D9,$05,$03,$D9,$07,$CC,$FC,$D9
	.byte $06,$AA,$AB,$3A,$8A,$02,$00,$00
	.byte $0F,$AA,$FA,$2B,$88,$00,$00,$3C
	.byte $0F,$AA,$88,$E2,$EA,$F0,$00,$00
	.byte $30,$AA,$AA,$8B,$20,$D9,$03,$0F
	.byte $AA,$0A,$EB,$E0,$00,$00,$3C,$0F
	.byte $AA,$BA,$A0,$D9,$04,$30,$AA,$AE
	.byte $88,$2C,$08,$00,$00,$0F,$AA,$BE
	.byte $EA,$A3,$00,$00,$3C,$0F,$AA,$AA
	.byte $E2,$A8,$88,$00,$00,$30,$AA,$AB
	.byte $CA,$8A,$02,$00,$00,$3F,$AA,$FA
	.byte $2B,$88,$00,$00,$0F,$FC,$AA,$88
	.byte $E2,$EA,$F0,$00,$C0,$FC,$AA,$AA
	.byte $8B,$20,$D9,$03,$3F,$AA,$0A,$EB
	.byte $E0,$00,$00,$0F,$FC,$AA,$BA,$A0
	.byte $D9,$03,$C0,$FC,$AA,$AE,$88,$2C
	.byte $08,$00,$00,$3F,$AA,$BE,$EA,$A3
	.byte $00,$00,$0F,$FC,$AA,$AA,$E2,$A8
	.byte $88,$00,$C0,$FC,$3F,$30,$30,$3F
	.byte $D9,$04,$FF,$00,$FF,$CC,$D9,$04
	.byte $FC,$0C,$FC,$D9,$05,$30,$30,$3C
	.byte $0F,$D9,$04,$00,$3F,$F0,$C0,$D9
	.byte $04,$0C,$FC,$D9,$06,$D9,$19,$C0
	.byte $3C,$30,$F3,$C3,$F3,$30,$C0,$30
	.byte $F0,$C3,$C3,$03,$0C,$30,$00,$00
	.byte $30,$0C,$3C,$3C,$C0,$C0,$0F,$0F
	.byte $D9,$06,$03,$03,$D9,$06,$C0,$D9
	.byte $4F,$D9,$05,$C0,$30,$F0,$D9,$05
	.byte $C0,$F0,$3C,$D9,$05,$30,$0C,$0F
	.byte $C0,$F0,$30,$0C,$D9,$04,$0C,$3C
	.byte $D9,$06,$0F,$0C,$FC,$C0,$D9,$1C
	.byte $D9,$1F,$05,$D9,$04,$01,$31,$40
	.byte $10,$D9,$06,$10,$00,$01,$04,$01
	.byte $D9,$05,$01,$11,$55,$D9,$05,$54
	.byte $10,$40,$D9,$23,$01,$D9,$05,$10
	.byte $14,$01,$15,$D9,$04,$40,$00,$00
	.byte $50,$01,$05,$01,$D9,$05,$54,$45
	.byte $40,$D9,$05,$44,$50,$04,$D9,$2A
	.byte $11,$01,$10,$D9,$04,$40,$00,$50
	.byte $04,$01,$05,$04,$D9,$05,$11,$55
	.byte $44,$D9,$05,$40,$14,$D9,$24,$01
	.byte $00,$D9,$04,$40,$00,$11,$11,$D9
	.byte $06,$10,$40,$05,$05,$04,$D9,$05
	.byte $00,$55,$14,$D9,$05,$50,$50,$40
	.byte $D9,$1E,$05,$00,$00,$05,$15,$00
	.byte $00,$40,$01,$10,$50,$50,$51,$55
	.byte $55,$04,$00,$50,$10,$44,$54,$40
	.byte $54,$15,$14,$14,$D9,$05,$55,$55
	.byte $40,$D9,$05,$54,$50,$50,$D9,$1D
	.byte $01,$04,$04,$00,$01,$05,$15,$15
	.byte $00,$04,$01,$04,$04,$44,$41,$55
	.byte $D9,$03,$04,$14,$54,$54,$14,$15
	.byte $05,$04,$D9,$05,$51,$15,$D9,$06
	.byte $00,$40,$D9,$1E,$00,$10,$04,$00
	.byte $00,$05,$04,$15,$04,$14,$10,$00
	.byte $54,$55,$54,$54,$00,$10,$00,$10
	.byte $40,$40,$54,$40,$15,$00,$10,$D9
	.byte $05,$40,$54,$14,$D9,$05,$54,$50
	.byte $D9,$20,$01,$00,$10,$14,$15,$15
	.byte $01,$10,$05,$40,$04,$10,$50,$55
	.byte $00,$10,$40,$10,$50,$50,$50,$50
	.byte $05,$00,$01,$D9,$05,$55,$40,$40
	.byte $D9,$05,$54,$50,$40,$D9,$12,$01
	.byte $40,$11,$D9,$06,$40,$00,$04,$04
	.byte $14,$14,$05,$15,$14,$14,$40,$14
	.byte $50,$50,$51,$40,$15,$05,$10,$04
	.byte $50,$00,$00,$04,$04,$00,$04,$00
	.byte $15,$D9,$05,$40,$50,$D9,$06,$00
	.byte $50,$D9,$0C,$01,$10,$D9,$05,$40
	.byte $01,$11,$D9,$05,$10,$04,$41,$10
	.byte $40,$05,$01,$01,$04,$10,$00,$11
	.byte $15,$05,$05,$05,$04,$40,$41,$05
	.byte $15,$15,$55,$01,$00,$50,$50,$15
	.byte $15,$05,$D9,$05,$55,$55,$50,$D9
	.byte $05,$40,$40,$D9,$0C,$04,$D9,$06
	.byte $01,$41,$44,$D9,$06,$10,$10,$11
	.byte $01,$11,$15,$05,$05,$01,$01,$01
	.byte $00,$00,$41,$40,$50,$51,$01,$04
	.byte $04,$40,$40,$00,$04,$14,$04,$00
	.byte $04,$05,$D9,$05,$15,$15,$D9,$06
	.byte $44,$40,$D9,$0B,$04,$01,$40,$D9
	.byte $06,$01,$10,$D9,$05,$40,$00,$10
	.byte $11,$10,$14,$15,$15,$10,$10,$00
	.byte $44,$04,$05,$15,$01,$50,$10,$01
	.byte $10,$14,$04,$54,$40,$00,$40,$50
	.byte $05,$05,$15,$D9,$05,$01,$01,$01
	.byte $D9,$05,$54,$54,$50,$D9,$05,$D9
	.byte $07,$01,$D9,$07,$10,$D9,$05,$41
	.byte $D9,$09,$04,$D9,$07,$40,$00,$00
	.byte $04,$D9,$03,$04,$D9,$03,$40,$D9
	.byte $03,$40,$D9,$0B,$01,$D9,$03,$01
	.byte $D9,$03,$10,$D9,$03,$10,$D9,$03
	.byte $04,$D9,$07,$40,$D9,$0F,$01,$D9
	.byte $07,$10,$D9,$0C,$04,$D9,$07,$44
	.byte $D9,$05,$41,$D9,$09,$11,$D9,$07
	.byte $10,$00,$04,$D9,$03,$04,$D9,$03
	.byte $40,$D9,$03,$40,$D9,$0B,$01,$D9
	.byte $03,$01,$D9,$03,$10,$D9,$03,$10
	.byte $D9,$03,$04,$D9,$07,$40,$D9,$0F
	.byte $01,$D9,$07,$10,$D9,$14,$40,$04
	.byte $D9,$05,$14,$D9,$08,$01,$10,$D9
	.byte $0C,$04,$D9,$03,$40,$D9,$03,$40
	.byte $D9,$0B,$01,$D9,$03,$01,$D9,$07
	.byte $10,$D9,$03,$04,$00,$04,$D9,$05
	.byte $40,$00,$40,$D9,$0D,$01,$00,$01
	.byte $D9,$05,$10,$00,$10,$D9,$12,$40
	.byte $00,$45,$D9,$05,$14,$D9,$07,$01
	.byte $00,$51,$D9,$0B,$04,$D9,$03,$04
	.byte $00,$40,$00,$40,$D9,$03,$40,$D9
	.byte $09,$01,$00,$01,$D9,$03,$01,$D9
	.byte $03,$10,$D9,$03,$10,$D9,$36,$10
	.byte $01,$D9,$07,$41,$D9,$06,$04,$40
	.byte $D9,$08,$01,$00,$04,$D9,$03,$04
	.byte $D9,$03,$40,$D9,$03,$40,$D9,$0B
	.byte $01,$D9,$03,$01,$00,$40,$00,$10
	.byte $D9,$03,$10,$D9,$03,$04,$D9,$07
	.byte $40,$D9,$0F,$01,$D9,$07,$10,$D9
	.byte $12,$04,$00,$40,$D9,$07,$41,$D9
	.byte $05,$10,$00,$01,$D9,$09,$04,$D9
	.byte $03,$04,$D9,$07,$40,$D9,$0F,$01
	.byte $D9,$03,$10,$D9,$03,$10,$D9,$03
	.byte $04,$D9,$07,$40,$D9,$0F,$01,$D9
	.byte $07,$10,$D9,$13,$01,$40,$D9,$08
	.byte $14,$D9,$05,$40,$01,$D9,$0D,$01
	.byte $D9,$03,$10,$D9,$03,$40,$D9,$0B
	.byte $04,$D9,$03,$01,$D9,$07,$10,$D9
	.byte $03,$04,$00,$04,$D9,$05,$40,$00
	.byte $40,$D9,$0D,$01,$00,$01,$D9,$05
	.byte $10,$00,$10,$D9,$0A,$04,$D9,$07
	.byte $01,$00,$40,$D9,$07,$14,$D9,$05
	.byte $40,$00,$01,$D9,$05,$10,$D9,$05
	.byte $04,$D9,$03,$04,$00,$04,$00,$40
	.byte $D9,$03,$40,$D9,$09,$10,$00,$01
	.byte $D9,$03,$01,$D9,$03,$10,$D9,$03
	.byte $10,$D9,$28,$D9,$18,$55,$55,$55
	.byte $D9,$18,$D9,$0F,$40,$00,$01,$14
	.byte $00,$14,$01,$41,$40,$00,$14,$00
	.byte $01,$41,$40,$14,$00,$14,$40,$00
	.byte $01,$D9,$0F,$D9,$09,$40,$00,$01
	.byte $10,$00,$04,$04,$00,$10,$01,$00
	.byte $40,$00,$41,$00,$00,$14,$00,$00
	.byte $41,$00,$01,$00,$40,$04,$00,$10
	.byte $10,$00,$04,$40,$00,$01,$D9,$09
	.byte $04,$00,$10,$04,$00,$10,$01,$00
	.byte $40,$01,$00,$40,$01,$00,$40,$00
	.byte $41,$00,$00,$41,$00,$00,$41,$00
	.byte $00,$14,$00,$00,$41,$00,$00,$41
	.byte $00,$00,$41,$00,$01,$00,$40,$01
	.byte $00,$40,$01,$00,$40,$04,$00,$10
	.byte $04,$00,$10,$00,$14,$00,$00,$14
	.byte $00,$00,$14,$00,$00,$14,$00,$00
	.byte $14,$00,$00,$14,$00,$00,$14,$00
	.byte $00,$14,$00,$00,$14,$00,$00,$14
	.byte $00,$00,$14,$00,$00,$14,$00,$00
	.byte $14,$00,$00,$14,$00,$00,$14,$00
	.byte $00,$14,$00,$00,$14,$00,$D9,$07
	.byte $04,$00,$00,$04,$00,$00,$04,$00
	.byte $00,$04,$00,$00,$10,$00,$00,$10
	.byte $00,$00,$10,$00,$00,$40,$00,$00
	.byte $40,$00,$00,$40,$00,$01,$00,$00
	.byte $01,$00,$00,$01,$00,$00,$D9,$06
	.byte $D9,$13,$01,$40,$00,$04,$00,$00
	.byte $10,$00,$00,$40,$00,$01,$D9,$14
	.byte $D9,$19,$14,$D9,$1C,$03,$D9,$08
	.byte $C0,$30,$0C,$03,$D9,$04,$03,$0C
	.byte $30,$C0,$00,$00,$3C,$C3,$03,$03
	.byte $D9,$06,$C0,$C0,$D9,$08,$0C,$03
	.byte $D9,$04,$03,$0C,$30,$C0,$00,$00
	.byte $3C,$C3,$D9,$08,$C0,$3F,$0F,$D9
	.byte $0D,$03,$0C,$30,$D9,$03,$3C,$C3
	.byte $D9,$08,$C0,$30,$0C,$03,$D9,$04
	.byte $3C,$3C,$30,$C0,$D9,$0A,$3C,$C3
	.byte $D9,$08,$C0,$30,$0C,$03,$D9,$04
	.byte $03,$0C,$30,$C0,$D9,$03,$F0,$F0
	.byte $D9,$0E,$03,$03,$D9,$06,$C0,$F0
	.byte $0C,$03,$D9,$06,$03,$0C,$F0,$00
	.byte $00,$0F,$30,$C0,$D9,$06,$C0,$D9
	.byte $08,$0F,$0F,$03,$D9,$06,$03,$0C
	.byte $F0,$00,$00,$0F,$30,$C0,$D9,$06
	.byte $C0,$30,$0C,$03,$D9,$0E,$3F,$3C
	.byte $D9,$03,$0F,$30,$C0,$D9,$06,$C0
	.byte $30,$0C,$03,$D9,$07,$0C,$F0,$D9
	.byte $0A,$0F,$30,$F0,$F0,$D9,$05,$C0
	.byte $30,$0C,$03,$D9,$06,$03,$0C,$F0
	.byte $D9,$03,$30,$C0,$D9,$17,$0F,$0F
	.byte $D9,$06,$C0,$C0,$D9,$1D,$0F,$30
	.byte $30,$0F,$D9,$04,$C0,$30,$30,$C0
	.byte $D9,$1B,$3F,$C0,$C0,$C0,$C0,$3F
	.byte $00,$00,$F0,$0C,$0C,$0C,$0C,$F0
	.byte $D9,$12,$0C,$30,$30,$30,$30,$0C
	.byte $D9,$12,$C0,$30,$30,$30,$30,$C0
	.byte $D9,$0A,$03,$03,$D9,$04,$C0,$C0
	.byte $33,$33,$C0,$C0,$D9,$03,$C0,$33
	.byte $33,$C0,$D9,$03,$30,$30,$CF,$CF
	.byte $30,$30,$D9,$03,$F0,$00,$00,$F0
	.byte $D9,$04,$03,$0C,$0C,$03,$D9,$03
	.byte $03,$03,$CC,$CC,$03,$03,$D9,$04
	.byte $CF,$CF,$D9,$05,$C3,$3C,$3C,$C3
	.byte $D9,$04,$C0,$00,$00,$C0,$D9,$03
	.byte $0C,$0C,$33,$33,$0C,$0C,$D9,$03
	.byte $0C,$33,$33,$0C,$D9,$03,$03,$03
	.byte $3C,$3C,$03,$03,$D9,$03,$0F,$F0
	.byte $F0,$0F,$D9,$0C,$30,$CC,$CC,$30
	.byte $D9,$03,$30,$30,$CC,$CC,$30,$30
	.byte $D9,$03,$0C,$F3,$F3,$0C,$D9,$04
	.byte $3C,$C0,$C0,$3C,$D9,$0C,$03,$00
	.byte $00,$03,$D9,$03,$03,$C3,$3C,$3C
	.byte $C3,$03,$D9,$04,$F3,$F3,$D9,$05
	.byte $C0,$33,$33,$C0,$D9,$03,$C0,$C0
	.byte $30,$30,$C0,$C0,$D9,$03,$0F,$00
	.byte $00,$0F,$D9,$04,$0C,$F3,$F3,$0C
	.byte $D9,$03,$03,$03,$CC,$CC,$03,$03
	.byte $D9,$03,$03,$CC,$CC,$03,$D9,$05
	.byte $C0,$C0,$D9,$05,$3C,$03,$03,$3C
	.byte $D9,$03,$30,$30,$CF,$CF,$30,$30
	.byte $D9,$03,$0C,$33,$33,$0C,$D9,$03
	.byte $0C,$0C,$33,$33,$0C,$0C,$D9,$0B
	.byte $F0,$0F,$0F,$F0,$D9,$04,$C0,$3C
	.byte $3C,$C0,$D9,$03,$30,$30,$CC,$CC
	.byte $30,$30,$D9,$03,$30,$CC,$CC,$30
	.byte $D9,$17,$02,$20,$00,$01,$C0,$00
	.byte $0B,$E6,$00,$07,$FF,$00,$1E,$33
	.byte $00,$75,$20,$D9,$0D,$02,$20,$00
	.byte $01,$C0,$00,$03,$E6,$00,$07,$FF
	.byte $00,$3E,$33,$00,$62,$10,$D9,$0D
	.byte $04,$40,$00,$03,$80,$00,$67,$D0
	.byte $00,$FF,$E0,$00,$CC,$78,$00,$04
	.byte $AE,$D9,$0D,$04,$40,$00,$03,$80
	.byte $00,$67,$C0,$00,$FF,$E0,$00,$CC
	.byte $7C,$00,$08,$46,$00,$03,$80,$00
	.byte $03,$C0,$00,$01,$00,$00,$01,$00
	.byte $00,$01,$C0,$00,$01,$80,$00,$01
	.byte $80,$00,$03,$80,$00,$05,$40,$00
	.byte $19,$40,$00,$03,$80,$00,$03,$C0
	.byte $00,$01,$00,$00,$01,$00,$00,$01
	.byte $C0,$00,$01,$A0,$00,$01,$80,$00
	.byte $03,$80,$00,$05,$40,$00,$1A,$20
	.byte $00,$03,$80,$00,$07,$80,$00,$01
	.byte $00,$00,$01,$00,$00,$07,$80,$00
	.byte $01,$80,$00,$01,$80,$00,$01,$C0
	.byte $00,$02,$A0,$00,$02,$98,$00,$03
	.byte $80,$00,$07,$80,$00,$01,$00,$00
	.byte $01,$00,$00,$03,$80,$00,$05,$80
	.byte $00,$01,$80,$00,$01,$C0,$00,$02
	.byte $A0,$00,$04,$58,$D9,$05,$18,$00
	.byte $00,$1C,$00,$00,$10,$00,$00,$30
	.byte $00,$03,$E0
	
// v_2BC0:
	
	.byte $00,$07,$F0,$00,$0F
	.byte $80,$00,$12,$40,$00,$E4,$20,$D9
	.byte $05,$18,$00,$00,$1C,$00,$00,$10
	.byte $00,$00,$30,$00,$03,$E0,$00,$07
	.byte $F0,$00,$1F,$80,$00,$22,$80,$00
	.byte $C2,$40,$D9,$04,$30,$00,$00,$70
	.byte $00,$00,$10,$00,$00,$18,$00,$00
	.byte $0F,$80,$00,$1F,$C0,$00,$03,$E0
	.byte $00,$04,$90,$00,$10,$4E,$D9,$04
	.byte $30,$00,$00,$70,$00,$00,$10,$00
	.byte $00,$18,$00,$00,$0F,$80,$00,$1F
	.byte $C0,$00,$03,$F0,$00,$02,$88,$00
	.byte $04,$86,$D9,$0D,$04,$40,$00,$03
	.byte $80,$00,$17,$C0,$00,$0F,$EC,$00
	.byte $FC,$7E,$00,$04,$46,$D9,$0D,$04
	.byte $40,$00,$03,$80,$00,$17,$CC,$00
	.byte $0F,$FE,$00,$7C,$66,$00,$C4,$40
	.byte $D9,$0D,$04,$40,$00,$03,$86,$00
	.byte $17,$DC,$00,$0F,$F8,$00,$3C,$66
	.byte $00,$E4,$40,$D9,$0D,$04,$40,$00
	.byte $03,$80,$00,$07,$D0,$00,$6F,$E0
	.byte $00,$FC,$7E,$00,$C4,$40,$D9,$0D
	.byte $04,$40,$00,$03,$80,$00,$67,$D0
	.byte $00,$FF,$E0,$00,$CC,$7C,$00,$04
	.byte $46,$D9,$0D,$04,$40,$00,$C3,$80
	.byte $00,$77,$D0,$00,$3F,$E0,$00,$CC
	.byte $78,$00,$04,$4E,$00,$03,$80,$00
	.byte $03,$C0,$00,$01,$00,$00,$01,$00
	.byte $00,$03,$C0,$00,$03,$40,$00,$03
	.byte $00,$00,$07,$00,$00,$1A,$80,$00
	.byte $22,$80,$00,$03,$80,$00,$03,$80
	.byte $00,$01,$00,$00,$01,$00,$00,$03
	.byte $C0,$00,$03,$20,$00,$03,$00,$00
	.byte $07,$00,$00,$3A,$80,$00,$02,$80
	.byte $00,$03,$80,$00,$07,$80,$00,$01
	.byte $00,$00,$01,$00,$00,$03,$E0,$00
	.byte $03,$00,$00,$03,$00,$00,$27,$00
	.byte $00,$1A,$80,$00,$02,$80,$00,$03
	.byte $80,$00,$07,$80,$00,$01,$00,$00
	.byte $01,$00,$00,$07,$80,$00,$05,$80
	.byte $00,$01,$80,$00,$01,$C0,$00,$02
	.byte $B0,$00,$02,$88,$00,$03,$80,$00
	.byte $03,$80,$00,$01,$00,$00,$01,$00
	.byte $00,$07,$80,$00,$09,$80,$00,$01
	.byte $80,$00,$01,$C0,$00,$02,$B8,$00
	.byte $02,$80,$00,$03,$80,$00,$03,$C0
	.byte $00,$01,$00,$00,$01,$00,$00,$0F
	.byte $80,$00,$01,$80,$00,$01,$80,$00
	.byte $01,$C8,$00,$02,$B0,$00,$02,$80
	.byte $D9,$05,$18,$00,$00,$1C,$00,$00
	.byte $10,$00,$00,$30,$00,$03,$E0,$00
	.byte $07,$F0,$00,$3F,$80,$00,$42,$80
	.byte $00,$82,$40,$00,$00,$30,$00,$00
	.byte $38,$00,$00,$20,$00,$00,$20,$00
	.byte $00,$20,$00,$03,$E0,$00,$07,$F0
	.byte $00,$FF,$80,$00,$02,$80,$00,$02
	.byte $40,$00,$00,$60,$00,$00,$E0,$00
	.byte $00,$20,$00,$00,$20,$00,$00,$20
	.byte $00,$03,$E0,$00,$07,$F0,$00,$FF
	.byte $80,$00,$02,$80,$00,$02,$40,$00
	.byte $00,$30,$00,$00,$38,$00,$00,$20
	.byte $00,$00,$20,$00,$00,$20,$00,$03
	.byte $E0,$00,$07,$F0,$00,$0F,$80,$00
	.byte $12,$80,$00,$E2,$40,$D9,$04,$30
	.byte $00,$00,$70,$00,$00,$10,$00,$00
	.byte $18,$00,$00,$0F,$80,$00,$1F,$C0
	.byte $00,$03,$F8,$00,$02,$84,$00,$04
	.byte $82,$00,$18,$00,$00,$38,$00,$00
	.byte $08,$00,$00,$08,$00,$00,$08,$00
	.byte $00,$0F,$80,$00,$1F,$C0,$00,$03
	.byte $FE,$00,$02,$80,$00,$04,$80,$00
	.byte $0C,$00,$00,$0E,$00,$00,$08,$00
	.byte $00,$08,$00,$00,$08,$00,$00,$0F
	.byte $80,$00,$1F,$C0,$00,$03,$FE,$00
	.byte $02,$80,$00,$04,$80,$00,$18,$00
	.byte $00,$38,$00,$00,$08,$00,$00,$08
	.byte $00,$00,$08,$00,$00,$0F,$80,$00
	.byte $1F,$C0,$00,$03,$E0,$00,$02,$90
	.byte $00,$04,$8E,$D9,$08,$20,$00,$00
	.byte $40,$00,$00,$80,$00,$01,$00,$00
	.byte $02,$D9,$0F,$40,$00,$00,$40,$00
	.byte $00,$80,$00,$00,$80,$00,$00,$80
	.byte $00,$01,$00,$00,$01,$00,$00,$01
	.byte $D9,$08,$01,$80,$00,$01,$80,$00
	.byte $01,$80,$00,$01,$80,$00,$01,$80
	.byte $00,$01,$80,$00,$01,$80,$00,$01
	.byte $80,$00,$01,$80,$D9,$04,$04,$20
	.byte $00,$02,$40,$00,$02,$40,$00,$02
	.byte $40,$00,$01,$80,$00,$02,$40,$00
	.byte $02,$40,$00,$02,$40,$00,$04,$20
	.byte $D9,$04,$10,$08,$00,$08,$10,$00
	.byte $04,$20,$00,$02,$40,$00,$01,$80
	.byte $00,$02,$40,$00,$04,$20,$00,$08
	.byte $10,$00,$10,$08,$D9,$0A,$30,$0C
	.byte $00,$0E,$70,$00,$01,$80,$00,$0E
	.byte $70,$00,$30,$0C,$D9,$16,$3F,$FC
	.byte $D9,$10,$20,$01,$10,$80,$D9,$04
	.byte $82,$14,$D9,$06,$08,$40,$04,$02
	.byte $D9,$04,$20,$04,$80,$10,$D9,$04
	.byte $28,$41,$D9,$06,$08,$10,$02,$04
	.byte $D9,$04,$08,$84,$00,$00,$10,$D9
	.byte $03,$82,$14,$D9,$06,$20,$12,$00
	.byte $00,$04,$D9,$03,$82,$10,$00,$00
	.byte $80,$D9,$03,$28,$41,$D9,$06,$82
	.byte $04,$00,$00,$02,$00,$10,$80,$00
	.byte $00,$10,$80,$D9,$0A,$04,$02,$00
	.byte $00,$04,$02,$00,$00,$80,$10,$00
	.byte $00,$80,$10,$D9,$0A,$02,$04,$00
	.byte $00,$02,$04,$00,$80,$00,$00,$10
	.byte $80,$00,$00,$10,$D9,$08,$02,$00
	.byte $00,$04,$02,$00,$00,$04,$10,$00
	.byte $00,$80,$10,$00,$00,$80,$D9,$08
	.byte $04,$00,$00,$02,$04,$00,$00,$02
	.byte $C8,$32,$32,$0C,$0C,$A0,$08,$C0
	.byte $30,$32,$32,$88,$D9,$04,$8C,$30
	.byte $30,$C0,$C0,$28,$80,$0C,$C8,$32
	.byte $32,$0C,$0C,$A3,$0A,$C0,$30,$32
	.byte $32,$B8,$B8,$03,$02,$00,$8C,$30
	.byte $30,$C0,$C0,$28,$80,$0C,$00,$C8
	.byte $32,$32,$0C,$0C,$80,$28,$00,$30
	.byte $32,$32,$30,$FC,$00,$FC,$00,$8C
	.byte $30,$30,$C0,$C0,$02,$28,$00,$00
	.byte $32,$32,$0E,$0C,$20,$08,$00,$00
	.byte $32,$32,$32,$FC,$D9,$04,$30,$30
	.byte $C0,$C0,$20,$80,$D9,$03,$0C,$0C
	.byte $03,$00,$08,$D9,$03,$30,$30,$BB
	.byte $00,$FC,$D9,$03,$C0,$C0,$00,$00
	.byte $80,$D9,$04,$02,$02,$D9,$06,$32
	.byte $FE,$00,$CC,$D9,$0D,$03,$D9,$07
	.byte $CF,$00,$FC,$D9,$08,$C0,$08,$A0
	.byte $0C,$0C,$32,$32,$C8,$D9,$04,$88
	.byte $32,$32,$30,$0C,$80,$28,$C0,$C0
	.byte $30,$30,$8C,$C0,$0A,$A3,$0C,$0C
	.byte $32,$32,$C8,$00,$02,$03,$B8,$B8
	.byte $32,$32,$30,$0C,$80,$28,$C0,$C0
	.byte $30,$30,$8C,$28,$80,$0C,$0C,$32
	.byte $32,$C8,$00,$FC,$00,$FC,$30,$32
	.byte $32,$30,$00,$28,$02,$C0,$C0,$30
	.byte $30,$8C,$00,$08,$20,$0C,$0E,$32
	.byte $32,$D9,$04,$FC,$32,$32,$32,$00
	.byte $00,$80,$20,$C0,$C0,$30,$30,$00
	.byte $00,$08,$00,$03,$0C,$0C,$D9,$03
	.byte $FC,$00,$BB,$30,$30,$D9,$03,$80
	.byte $00,$00,$C0,$C0,$D9,$05,$02,$02
	.byte $D9,$04,$CC,$00,$FE,$32,$D9,$0E
	.byte $03,$D9,$05,$FC,$00,$CF,$D9,$0D
	.byte $03,$00,$00,$07,$00,$00,$01,$00
	.byte $00,$09,$20,$00,$07,$C0,$00,$03
	.byte $80,$00,$03,$80,$00,$03,$80,$00
	.byte $03,$80,$00,$01,$D9,$05,$01,$80
	.byte $00,$01,$C0,$00,$01,$00,$00,$05
	.byte $40,$00,$03,$80,$00,$03,$80,$00
	.byte $03,$80,$00,$03,$80,$00,$01,$D9
	.byte $05,$01,$80,$00,$01,$C0,$00,$01
	.byte $00,$00,$03,$80,$00,$03,$80,$00
	.byte $03,$80,$00,$01,$D9,$0B,$03,$00
	.byte $00,$07,$00,$00,$01,$00,$00,$01
	.byte $00,$00,$03,$80,$00,$03,$80,$00
	.byte $01,$D9,$11,$01,$80,$00,$03,$80
	.byte $00,$01,$00,$00,$03,$80,$00,$01
	.byte $D9,$17,$01,$80,$00,$03,$80,$00
	.byte $01,$D9,$08,$D8,$08,$C3,$C3,$C3
	.byte $C3,$F0,$D8,$0B,$FC,$FC,$D8,$06
	.byte $00,$00,$03,$C0,$03,$C0,$D8,$03
	.byte $3F,$D8,$06,$DA
	
table_30E1:
	
	.byte $EA,$CF,$E0,$C4
	.byte $D3,$F3,$C1,$E0,$A1,$0F,$54,$00
	.byte $94,$03,$4F,$28,$05,$01,$8A,$0E
	.byte $21,$F0,$10,$02,$AA,$00,$C4,$03
	.byte $43,$A0,$3F,$EA,$C0,$54,$00,$13
	.byte $AA,$30,$00,$C8,$7A,$00,$CC,$A0
	.byte $8F,$3A,$D5,$EA,$A7,$A8,$10,$54
	.byte $F2,$AC,$57,$AB,$2A,$0A,$C0,$87
	.byte $B5,$20,$44,$03,$A0,$AA,$4C,$0D
	.byte $60,$01,$FC,$AB,$41,$01,$30,$1F
	.byte $28,$0A,$30,$00,$6A,$00,$E3,$00
	.byte $10,$3A,$42,$00,$CF,$83,$C3,$47
	.byte $53,$8F,$33,$47
	
table_3141:
	
	.byte $CC,$C0,$EB,$F3
	.byte $DD,$CE,$DD,$FF,$3E,$EB,$55,$AA
	.byte $55,$AA,$55,$FF,$90,$13,$C3,$DE
	.byte $7D,$BE,$7D,$FF,$D5,$AA,$55,$AA
	.byte $55,$AA,$55,$FF,$D0,$B3,$73,$B7
	.byte $5F,$AF,$5F,$FF,$D5,$AA,$55,$AA
	.byte $55,$AA,$55,$FF,$55,$AA,$55,$AA
	.byte $55,$AA,$55,$FF,$ED,$CE,$CD,$FA
	.byte $F5,$FA,$F5,$FF,$55,$AA,$55,$AA
	.byte $55,$AA,$55,$FF,$CE,$D4,$73,$B3
	.byte $7E,$BE,$7E,$FF,$3F,$EA,$55,$AA
	.byte $55,$AA,$55,$FF,$03,$C3,$CB,$B3
	.byte $73,$B7,$7B,$FF,$A0,$04,$BD,$05
	.byte $07,$95,$5D,$04,$05,$20,$A7,$04
	.byte $EF,$00,$5F,$25,$FF,$0E,$00,$04
	.byte $FF,$04,$D7,$A5,$5E,$91,$B5,$2E
	.byte $7F,$0F,$95,$45,$FD,$05,$BD,$04
	.byte $FB,$0E,$FD,$30,$6F,$00,$E4,$80
	.byte $BF,$0F,$3F,$05,$BD,$1F,$9F,$85
	.byte $FF,$04,$FF,$04,$77,$04,$DE,$CE
	.byte $EF,$4F,$FF,$04,$F7,$01,$FD,$04
	.byte $DF,$05,$BD,$04,$6F,$11,$BF,$DD
	.byte $FF,$45,$95,$04,$EE,$10,$05,$04
	.byte $FF,$04

L_JSR_31F7_1186:
L_JSR_31F7_18A7:
L_JSR_31F7_18B3:
L_JSR_31F7_1902:

	jmp L_JMP_4719_31F7

L_JSR_31FA_0AAE:

	jmp L_JMP_3F84_31FA

L_JSR_31FD_18BC:

	jmp L_JMP_378E_31FD

L_JSR_3200_098F:
L_JSR_3200_108C:
L_JMP_3200_1907:

	lda #$80
	sta VCREG1                          // Voice 1: Control Register
	sta VCREG2                          // Voice 2: Control Register
	sta VCREG3                          // Voice 3: Control Register
	lda #$00
	sta FREHI1                          // Voice 1: Frequency Control - High-Byte
	sta FREHI2                          // Voice 2: Frequency Control - High-Byte
	sta FREHI3                          // Voice 3: Frequency Control - High-Byte
	lda #$0F
	sta SIGVOL                          // Select Filter Mode and Volume
	cpx #$1D
	bne L_BRS_3237_321D
	lda #$00
	sta SPENA                          // Sprite display Enable
	jsr L_JSR_6307_3224
	ldx #$1E
	jsr L_JSR_62F4_3229
	ldx #$05
	jsr L_JSR_6570_322E
	lda #$FF
	sta $DE
	bmi L_BRS_3246_3235

L_BRS_3237_321D:

	jsr L_JSR_6307_3237
	jsr L_JSR_62CF_323A
	inc $CF
	beq L_BRS_3246_323F
	lda #$05
	jsr L_JSR_3979_3243

L_BRS_3246_3235:
L_BRS_3246_323F:

	jsr L_JSR_44EA_3246
	lda #$95
	sta $0203
	lda #$00
	ldx #$0F

L_BRS_3252_3256:

	sta SP0X,X                          // Sprite 0 X Pos
	dex
	bpl L_BRS_3252_3256
	ldy $1E
	lda $DE
	pha
	lda $20
	pha
	ldx #$7F

L_BRS_3262_327A:

	lda #$00
	sta $0500,X
	sta $BF80,X
	sta $02,X
	sta $40,X
	sta $0205,X
	sta $0237,X
	lda #$04
	sta $0580,X
	dex
	bpl L_BRS_3262_327A
	sty $1E
	pla
	sta $20
	pla
	sta $DE
	ldx #$16
	jsr L_JSR_6126_3286
	bit $DE
	bpl L_BRS_32B4_328B
	bvs L_BRS_3292_328D
	jmp L_JMP_3320_328F

L_BRS_3292_328D:

	lda #$02
	sta $0E
	ldy #$72
	jsr L_JSR_615D_3298
	ldx #$7F

L_BRS_329D_32A4:

	lda table_3A04,X
	sta $0500,X
	dex
	bpl L_BRS_329D_32A4
	jsr L_JSR_34D8_32A6
	lda #$2A
	sta $05
	inc $04
	lda #$2A
	sta $05
	rts

L_BRS_32B4_328B:

	ldx #$35
	lda #$2F
	ldy #$A0
	jsr L_JSR_660C_32BA
	ldy #$5F

L_BRS_32BF_32C2:

	ldx #$07

L_BRS_32C1_32D1:

	txa
	bmi L_BRS_32BF_32C2
	lda #$00
	cpx #$03
	bcs L_BRS_32CC_32C8
	lda #$FF

L_BRS_32CC_32C8:

	sta $A2F0,Y
	dex
	dey
	bpl L_BRS_32C1_32D1
	lda $04FC
	cmp #$1C
	bne L_BRS_3315_32D8
	lda #$00
	sta $F0
	lda #$12
	sta $EA
	lda #$03
	sta $E9

L_BRS_32E6_32EB:
L_JMP_32E6_3308:

	jsr L_JSR_6200_32E6
	and #$07
	beq L_BRS_32E6_32EB
	sta $E0
	lda $EA
	sec
	sbc $E0
	bpl L_BRS_32FD_32F4
	clc
	adc #$12
	dec $E9
	beq L_BRS_330B_32FB

L_BRS_32FD_32F4:

	sta $EA
	jsr L_JSR_6150_32FF
	jsr L_JSR_3699_3302
	jsr L_JSR_3699_3305
	jmp L_JMP_32E6_3308

L_BRS_330B_32FB:

	lda #$00
	jsr L_JSR_45EC_330D
	lda #$FF
	jsr L_JSR_45EC_3312

L_BRS_3315_32D8:

	lda #$00
	jsr L_JSR_3521_3317
	lda #$FF
	jsr L_JSR_3521_331C
	cli

L_JMP_3320_328F:
L_JMP_3320_33E2:

	lda $CF
	cmp #$09
	bcc L_BRS_3328_3324
	lda #$09

L_BRS_3328_3324:

	sta $CE
	ldx #$7A
	ldy #$0E
	jsr L_JSR_359A_332E

L_BRS_3331_3336:

	jsr L_JSR_6200_3331
	and #$03
	beq L_BRS_3331_3336
	sta $F0
	sta $F1
	jsr L_JSR_679B_333C
	ora #$50
	tax

L_JMP_3342_3367:

	jsr L_JSR_6200_3342
	ldy $F0
	and table_35C5,Y
	clc
	adc table_35C5 + 4,Y
	sty $E0
	ldy $CE
	cpy #$06
	bcc L_BRS_335C_3354
	ldy $E0
	clc
	adc table_35C5 + 8,Y

L_BRS_335C_3354:

	tay
	jsr L_JSR_359A_335D
	dec $F1
	beq L_BRS_336A_3362
	jsr L_JSR_35BA_3364
	jmp L_JMP_3342_3367

L_BRS_336A_3362:

	ldx #$04
	jsr L_JSR_3628_336C
	ldx #$02
	jsr L_JSR_35D1_3371
	ldx #$00
	jsr L_JSR_35D1_3376
	ldx #$5D

L_BRS_337B_339A:

	ldy #$0D

L_BRS_337D_3394:

	lda $0500,X
	bne L_BRS_3392_3380
	lda $0501,X
	beq L_BRS_338A_3385
	inc $0581,X

L_BRS_338A_3385:

	lda $04FF,X
	beq L_BRS_3392_338D
	inc $057F,X

L_BRS_3392_3380:
L_BRS_3392_338D:

	dex
	dey
	bne L_BRS_337D_3394
	txa
	sec
	sbc #$13
	bpl L_BRS_337B_339A
	inc $05F1
	inc $05F4
	inc $05F8
	inc $05FC
	jsr L_JSR_6200_33A8
	ldy $CE
	and table_3649,Y
	sta $0F
	lda #$40

L_BRS_33B4_3405:

	sta $F0
	lda #$0F
	sta $E0

L_BRS_33BA_33C3:
L_BRS_33BA_33E0:

	jsr L_JSR_679B_33BA
	ora $F0
	tax
	lda $0510,X
	beq L_BRS_33BA_33C3
	lda $0530,X
	beq L_BRS_33DE_33C8
	txa
	ldy #$03

L_BRS_33CD_33DC:

	tax
	lda $0500,X
	and #$FC
	bne L_BRS_33DE_33D3
	dey
	bmi L_BRS_33E5_33D6
	txa
	clc
	adc #$10
	bne L_BRS_33CD_33DC

L_BRS_33DE_33C8:
L_BRS_33DE_33D3:

	dec $E0
	bne L_BRS_33BA_33E0
	jmp L_JMP_3320_33E2

L_BRS_33E5_33D6:

	ldy #$01

L_BRS_33E7_33F2:

	txa
	sec
	sbc #$10
	tax
	lda #$41
	sta $0500,X
	dey
	beq L_BRS_33E7_33F2
	lda $F0
	lsr
	lsr
	lsr
	lsr
	lsr
	tay
	txa
	sta $020A,Y
	lda $F0
	sec
	sbc #$20
	bpl L_BRS_33B4_3405
	lda $0F
	bne L_BRS_3426_3409
	jsr L_JSR_3671_340B
	ldy $CE
	and table_3653,Y
	bne L_BRS_3419_3413
	lda #$81
	bmi L_BRS_341B_3417

L_BRS_3419_3413:

	lda #$10

L_BRS_341B_3417:

	ldx #$01
	jsr L_JSR_0816_341D
	lda $EC
	beq L_BRS_3426_3422
	stx $8D

L_BRS_3426_3409:
L_BRS_3426_3422:

	jsr L_JSR_3671_3426
	and #$01
	clc
	adc #$03
	ldy $CE
	cpy #$09
	bne L_BRS_3437_3432
	clc
	adc #$02

L_BRS_3437_3432:

	sta $27
	lda #$00
	sta $E3

L_JMP_343D_345A:

	lda #$20
	ldx #$01
	jsr L_JSR_0816_3441
	lda $E3
	clc
	adc $EE
	sta $E3
	cmp $27
	beq L_BRS_345D_344D
	lda $ED
	sec
	sbc #$20
	bpl L_BRS_3458_3454
	lda #$60

L_BRS_3458_3454:

	sta $ED
	jmp L_JMP_343D_345A

L_BRS_345D_344D:

	jsr L_JSR_3671_345D
	and #$03
	clc
	ldy $CE
	adc table_365D,Y
	sta $E3

L_JMP_346A_3487:

	lda #$10
	ldx #$01
	jsr L_JSR_0816_346E
	lda $E3
	sec
	sbc $EE
	sta $E3
	bmi L_BRS_348A_3478
	beq L_BRS_348A_347A
	lda $ED
	sec
	sbc #$20
	bpl L_BRS_3485_3481
	lda #$60

L_BRS_3485_3481:

	sta $ED
	jmp L_JMP_346A_3487

L_BRS_348A_3478:
L_BRS_348A_347A:

	jsr L_JSR_6200_348A
	and #$01
	clc
	ldy $CE
	adc table_3667,Y
	sta $E3

L_BRS_3497_34A3:
L_BRS_3497_34A7:

	jsr L_JSR_3671_3497
	ldx #$01
	and #$0C
	jsr L_JSR_0816_349E
	lda $EE
	beq L_BRS_3497_34A3
	dec $E3
	bpl L_BRS_3497_34A7
	ldx $CE
	lda table_368F,X
	sta $0204
	ldy table_367B,X
	tya
	and #$0F
	sta $0E
	jsr L_JSR_615D_34B9
	lda #$00
	sta $D4
	lda #$10
	sta $D5
	jsr L_JSR_656E_34C4
	lda #$18
	sta $10
	ldx #$13
	jsr L_JSR_6307_34CD
	ldy $CE
	lda table_479B,Y
	sta $0400

L_JSR_34D8_32A6:

	lda #$DA
	sta v_2BC0
	jsr L_JSR_723B_34DD
	lda $E5
	asl
	asl
	sta $A3
	jsr L_JSR_6200_34E6
	sta $46
	jsr L_JSR_6200_34EB
	and #$07
	ora #$08
	sta $47
	ldy $CE
	bit $DE
	bpl L_BRS_34FE_34F8
	bvc L_BRS_34FE_34FA
	ldy #$00

L_BRS_34FE_34F8:
L_BRS_34FE_34FA:

	lda table_47A5,Y
	sta $E0
	lda table_47AF,Y
	sta $E1
	ldy #$77

L_BRS_350A_3510:

	lda ($E0),Y
	sta $88FA,Y
	dey
	bpl L_BRS_350A_3510
	ldx #$07

L_BRS_3514_351E:

	lda table_3687,X
	sta RAM8000 + $3F8,X
	sta RAMC000 + $3F8,X
	dex
	bpl L_BRS_3514_351E
	rts

L_JSR_3521_3317:
L_JSR_3521_331C:

	sta $F0
	lda #$12
	sta $EA

L_BRS_3527_352C:

	jsr L_JSR_3699_3527
	dec $EA
	bpl L_BRS_3527_352C
	rts

// 352F

	.byte $D9,$68,$3F,$D8,$0A,$C0,$FC,$FC
	.byte $FC,$F0,$D8,$03,$0F,$D8,$03,$3F
	.byte $D8,$13,$03,$CF,$CF,$CF,$03,$D8
	.byte $0C,$FC,$FC,$FC,$FC,$D8,$03,$33
	.byte $00,$CC,$FC,$FC,$D8,$13,$C0,$CF
	.byte $C3,$CF,$C0,$D8,$08,$FC,$D8,$07
	.byte $D9,$D0,$D8,$0B,$CF,$CF,$CC,$C0
	.byte $F3,$D8,$03,$CF,$CF,$CF,$0F,$3F
	.byte $D8,$13,$CF,$33,$03,$33,$33,$D8
	.byte $13,$03,$33,$03,$0F,$33,$D8,$13
	.byte $C0,$CC,$C0,$CF,$CF,$D8,$10,$D9
	.byte $D0,$FF,$FF,$3F,$D9,$65,$FF,$FF
	.byte $FC,$DA

L_JSR_3591_397B:
L_JSR_3591_41BB:
L_JSR_3591_474A:

	ldx #$00

L_BRS_3593_3594:
L_BRS_3593_3597:

	dex
	bne L_BRS_3593_3594
	dey
	bne L_BRS_3593_3597
	rts

L_JSR_359A_332E:
L_JSR_359A_335D:
L_BRS_359A_35B7:
L_JSR_359A_3612:
L_JSR_359A_363E:

	txa
	and #$0F
	beq L_BRS_35AE_359D
	cmp #$0D
	beq L_BRS_35AE_35A1

L_BRS_35A3_35A8:

	jsr L_JSR_6200_35A3
	and #$03
	beq L_BRS_35A3_35A8
	inc $DF
	bne L_BRS_35B0_35AC

L_BRS_35AE_359D:
L_BRS_35AE_35A1:

	lda #$01

L_BRS_35B0_35AC:

	sta $0500,X
	jsr L_JSR_35BA_35B3
	dey
	bne L_BRS_359A_35B7
	rts

L_JSR_35BA_3364:
L_JSR_35BA_35B3:
L_JSR_35BA_35E4:
L_JSR_35BA_3620:

	txa
	and #$0F
	bne L_BRS_35C3_35BD
	txa
	ora #$0E
	tax

L_BRS_35C3_35BD:

	dex
	rts

table_35C5:

	.byte $00,$03,$01,$01
	.byte $00,$08,$04,$03
	.byte $00,$03,$02,$01

L_JSR_35D1_3371:
L_JSR_35D1_3376:

	stx $ED
	jsr L_JSR_679B_35D3
	ora table_7DBA,X
	tax

L_JMP_35DA_35E7:

	lda $0520,X
	beq L_BRS_35E4_35DD
	lda $051F,X
	beq L_BRS_35EA_35E2

L_BRS_35E4_35DD:

	jsr L_JSR_35BA_35E4
	jmp L_JMP_35DA_35E7

L_BRS_35EA_35E2:

	jsr L_JSR_6200_35EA
	and #$03
	clc
	adc #$08
	ldy $CE
	cpy #$06
	bcc L_BRS_35FA_35F6
	adc #$00

L_BRS_35FA_35F6:

	sta $F1

L_JMP_35FC_3623:

	jsr L_JSR_6200_35FC
	and #$01
	clc
	adc #$03
	tay
	cpy $F1
	bcc L_BRS_3610_3607
	ldy $F1
	cpy #$02
	bcs L_BRS_3610_360D
	iny

L_BRS_3610_3607:
L_BRS_3610_360D:

	sty $E0
	jsr L_JSR_359A_3612
	lda $F1
	sec
	sbc $E0
	sta $F1
	beq L_BRS_3626_361C
	bmi L_BRS_3626_361E
	jsr L_JSR_35BA_3620
	jmp L_JMP_35FC_3623

L_BRS_3626_361C:
L_BRS_3626_361E:

	ldx $ED

L_JSR_3628_336C:

	clc

L_BRS_3629_3646:

	ldy table_7DBA,X
	bcc L_BRS_362F_362C
	dey

L_BRS_362F_362C:

	lda $0500,Y
	ora $0501,Y
	beq L_BRS_3643_3635
	stx $E2
	tya
	tax
	inx
	ldy #$02
	jsr L_JSR_359A_363E
	ldx $E2

L_BRS_3643_3635:

	inx
	txa
	lsr
	bcs L_BRS_3629_3646
	rts

table_3649:

	.byte $04,$04,$04,$04,$04,$06,$06,$06
	.byte $06,$FF
table_3653:
	.byte $00,$00,$08,$08,$08,$08
	.byte $08,$FF,$FF,$FF
table_365D:
	.byte $06,$07,$07,$08
	.byte $08,$09,$09,$0A,$0B,$0B
table_3667:
	.byte $02,$03
	.byte $04,$04,$05,$05,$06,$06,$06,$06

L_JSR_3671_340B:
L_JSR_3671_3426:
L_JSR_3671_345D:
L_JSR_3671_3497:

	jsr L_JSR_6200_3671
	and #$60
	sta $ED
	jmp L_JMP_6200_3678

table_367B:

	.byte $72,$73,$75,$74,$76,$7A,$7D,$77
	.byte $72,$78,$75,$74
table_3687:
	.byte $10,$10,$11,$12,$13,$14,$15,$16
table_368F:
	.byte $A0,$A0,$A0,$90
	.byte $90,$90,$88,$88,$70,$70

L_JSR_3699_3302:
L_JSR_3699_3305:
L_JSR_3699_3527:

	jsr L_JSR_3729_3699
	lda $EA
	lsr
	ldy #$04
	bcs L_BRS_36AA_36A1
	ldy #$00
	ldx #$02
	jsr L_JSR_61DE_36A7

L_BRS_36AA_36A1:

	sty $ED

L_BRS_36AC_36C6:

	lda #$AA
	eor ($E0),Y
	sta ($E0),Y
	sta ($E2),Y
	iny
	sta ($E0),Y
	sta ($E2),Y
	tya
	clc
	adc #$07
	tay
	bcc L_BRS_36C4_36BE
	inc $E1
	inc $E3

L_BRS_36C4_36BE:

	dec $EF
	bne L_BRS_36AC_36C6
	lda #$9E
	sec
	sbc $EE
	sta $EF
	ldy $ED
	iny
	iny

L_BRS_36D3_36F6:

	lda #$40
	eor ($E4),Y
	sta ($E4),Y
	lda #$01
	eor ($E6),Y
	sta ($E6),Y
	iny
	tya
	and #$07
	bne L_BRS_36F4_36E3
	pha
	ldy #$00
	ldx #$06
	jsr L_JSR_61DE_36EA
	ldx #$04
	jsr L_JSR_61DE_36EF
	pla
	tay

L_BRS_36F4_36E3:

	dec $EF
	bne L_BRS_36D3_36F6
	bit $F0
	bmi L_BRS_3718_36FA
	lda #$08
	sta VCREG1                          // Voice 1: Control Register
	lda $EA
	clc
	adc #$05
	sta FREHI1                          // Voice 1: Frequency Control - High-Byte
	ldx #$41
	ldy #$AA
	lda #$21
	stx ATDCY1                          // Voice 1: Attack / Decay Cycle Control
	sty SUREL1                          // Voice 1: Sustain / Release Cycle Control
	sta VCREG1                          // Voice 1: Control Register

L_BRS_3718_36FA:

	ldy #$30

L_BRS_371A_371B:
L_BRS_371A_371E:

	inx
	bne L_BRS_371A_371B
	dey
	bne L_BRS_371A_371E
	lda VCREG1                          // Voice 1: Control Register
	and #$FE
	sta VCREG1                          // Voice 1: Control Register
	rts

L_JSR_3729_3699:
L_JSR_3729_4587:
L_JSR_3729_45AC:

	lda $EA
	lsr
	tax
	stx $EF
	lda #$13
	sec
	sbc $EF
	tay
	lda $EA
	adc #$00
	asl
	asl
	asl
	php
	sta $EE
	clc
	adc table_60E2 + 3,X
	sta $E0
	sta $E4
	lda table_60FB + 3,X
	adc #$00
	plp
	adc #$00
	sta $E1
	sta $E5
	lda $EE
	adc table_60E2 + 2,Y
	sta $E2
	lda table_60FB + 2,Y
	adc #$00
	sta $E3
	lda #$27
	sbc $EA
	sbc $EA
	sta $EF
	ldx $E1
	sbc #$01
	asl
	asl
	asl
	bcc L_BRS_3773_3770
	inx

L_BRS_3773_3770:

	clc
	adc $E0
	sta $E6
	txa
	adc #$00
	sta $E7
	rts

table_377E:

	.byte $C0,$30,$0C,$03,$C0,$30,$0C,$03
	.byte $03,$0C,$30,$C0,$03,$0C,$30,$C0

L_JMP_378E_31FD:

	lda #$03
	jsr L_JSR_3979_3790
	ldx #$0B
	jsr L_JSR_6307_3795
	lda $D0
	sec
	sbc #$01
	asl
	asl
	asl
	asl
	asl
	tax
	ldy #$00
	sty $02
	sty $70

L_BRS_37A9_37B3:

	lda table_3984,X
	sta table_3921,Y
	inx
	iny
	cpy #$20
	bne L_BRS_37A9_37B3
	txa
	lsr
	lsr
	tax
	ldy #$00

L_BRS_37BB_37CD:

	sty $EF
	lda table_39E4,Y
	tay
	lda table_39E4,X
	sta table_38C1,Y
	inx
	ldy $EF
	iny
	cpy #$08
	bne L_BRS_37BB_37CD
	ldy #$5F

L_BRS_37D1_37ED:

	lda table_3859,Y
	sta $AA70,Y
	sta $EA70,Y
	lda table_38B9,Y
	sta $ABB0,Y
	sta $EBB0,Y
	lda table_3919,Y
	sta $ACF0,Y
	sta $ECF0,Y                          // Low Byte Screen Line Addresses
	dey
	bpl L_BRS_37D1_37ED
	ldy $CE
	lda table_367B + 1,Y
	jsr L_JSR_3841_37F4
	lda #$00
	sta $D4
	lda #$10
	sta $D5
	jsr L_JSR_656E_37FF
	ldy #$4B
	jsr L_JSR_4719_3804
	lda #$02
	jsr L_JSR_3979_3809
	jsr L_JSR_62CF_380C
	ldx #$20
	jsr L_JSR_62F4_3811
	ldy $CE
	lda table_368F,Y
	sta $0204
	lda #$00
	ldy #$5F

L_BRS_3820_3833:

	sta $AA70,Y
	sta $EA70,Y
	sta $ABB0,Y
	sta $EBB0,Y
	sta $ACF0,Y
	sta $ECF0,Y                          // Low Byte Screen Line Addresses
	dey
	bpl L_BRS_3820_3833
	lda $0E
	jsr L_JSR_3841_3837
	lda #$00
	sta $12
	jmp L_JMP_41EC_383E

L_JSR_3841_37F4:
L_JSR_3841_3837:

	ldx #$0B

L_BRS_3843_3856:

	sta RAM8000 + $14E,X
	sta $C14E,X
	sta RAM8000 + $176,X
	sta $C176,X
	sta RAM8000 + $19E,X
	sta $C19E,X
	dex
	bpl L_BRS_3843_3856
	rts

table_3859:

	.byte $00,$0A,$2A,$A0,$A0,$A0,$20,$28
	.byte $00,$80,$AA,$AA,$3C,$FF,$C3,$D7
	.byte $00,$0A,$AA,$00,$00,$00,$0F,$0F
	.byte $00,$A8,$AA,$0A,$00,$00,$FF,$FF
	.byte $00,$A2,$AA,$28,$00,$00,$3F,$0F
	.byte $00,$8A,$AA,$02,$00,$00,$C3,$03
	.byte $00,$8A,$AA,$A0,$00,$00,$C3,$C3
	.byte $00,$AA,$AA,$00,$3C,$3C,$CC,$C0
	.byte $00,$AA,$AA,$0A,$00,$00,$3F,$FF
	.byte $00,$02,$AA,$80,$00,$00,$F0,$F0
	.byte $00,$A8,$AA,$00,$3C,$FF,$C3,$D7
	.byte $00,$80,$A0,$A0,$28,$0A,$0A,$0A
table_38B9:
	.byte $28,$0A,$0A,$28,$28,$28,$A8,$A0
table_38C1:
	.byte $14,$00,$55,$55,$14,$00,$0F,$0F
	.byte $00,$00,$00,$00,$00,$00,$C3,$F3
	.byte $F0,$F0,$F0,$F0,$F0,$00,$0C,$CC
	.byte $0F,$0F,$0F,$0F,$3F,$00,$FC,$FF
	.byte $0F,$0F,$0F,$0F,$CF,$00,$00,$00
	.byte $FF,$FF,$3C,$3C,$00,$00,$C0,$C0
	.byte $F0,$F0,$F0,$F0,$F0,$00,$3F,$0C
	.byte $F0,$3F,$00,$FF,$FF,$00,$3F,$3F
	.byte $00,$C0,$F0,$F0,$C0,$00,$CF,$CF
	.byte $14,$00,$55,$55,$14,$00,$F0,$F0
	.byte $0A,$0A,$0A,$28,$28,$A0,$A0,$28
table_3919:
	.byte $A0,$A0,$A8,$28,$0A,$0A,$02,$00
table_3921:
	.byte $00,$03,$0F,$0F,$0F,$00,$80,$AA
	.byte $F3,$C3,$03,$F3,$F3,$00,$AA,$A0
	.byte $CC,$FC,$3C,$0C,$0C,$00,$A8,$0A
	.byte $C3,$C3,$C3,$FF,$FC,$00,$2A,$A0
	.byte $00,$00,$00,$00,$00,$00,$AA,$00
	.byte $C0,$C0,$C0,$FF,$FF,$00,$AA,$00
	.byte $0C,$0C,$0C,$0C,$3F,$00,$AA,$00
	.byte $30,$3F,$30,$30,$30,$00,$AA,$2A
	.byte $0C,$0F,$0C,$0F,$0F,$00,$82,$AA
	.byte $00,$C0,$00,$F0,$F0,$00,$AA,$80
	.byte $28,$0A,$0A,$0A,$28,$A8,$80,$00


L_JSR_3979_3243:
L_JSR_3979_3790:
L_JSR_3979_3809:
L_BRS_3979_3981:

	ldy #$FF
	jsr L_JSR_3591_397B
	sec
	sbc #$01
	bne L_BRS_3979_3981
	rts

table_3984:

	.byte $00,$03,$0F,$0F,$0F,$00,$80,$AA
	.byte $F3,$C3,$03,$F3,$F3,$00,$AA,$A0
	.byte $CC,$FC,$3C,$0C,$0C,$00,$A8,$0A
	.byte $C3,$C3,$C3,$FF,$FC,$00,$2A,$A0
	.byte $00,$03,$00,$0F,$0F,$00,$80,$AA
	.byte $33,$F3,$33,$F3,$C3,$00,$AA,$A0
	.byte $0C,$FC,$F0,$0C,$0C,$00,$A8,$0A
	.byte $C3,$C3,$C3,$FF,$FC,$00,$2A,$A0
	.byte $0C,$0F,$0F,$00,$00,$00,$80,$AA
	.byte $C0,$F0,$F0,$C0,$C0,$00,$AA,$A0
	.byte $C3,$C3,$C3,$C3,$C3,$00,$A8,$0A
	.byte $0C,$FC,$0C,$0C,$0C,$00,$2A,$A0
table_39E4:
	.byte $06,$07,$0E,$0F,$16,$17,$1E,$1F
	.byte $0F,$0F,$C3,$F3,$0C,$CC,$FC,$FF
	.byte $0F,$0F,$C3,$F3,$F0,$FC,$FC,$FF
	.byte $0C,$0C,$C3,$C0,$F3,$C3,$0C,$0C
table_3A04:
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $01,$41,$0E,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$23,$03,$01,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $01,$03,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$09,$81,$41,$01,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $01,$05,$16,$41,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$02,$01,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $01,$1E,$0B,$01,$22,$03,$01,$02
	.byte $03,$15,$02,$1B,$0D,$01,$00,$00
table_3A84:
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $03,$03,$0D,$0E,$35,$3A,$35,$3A
	.byte $0D,$3A,$35,$3A,$35,$0E,$0D,$0E
	.byte $03,$03,$03,$03,$0D,$0E,$35,$3A
	.byte $35,$3A,$35,$3A,$35,$3B,$37,$3B
	.byte $35,$3A,$35,$3A,$0D,$0E,$0D,$03
	.byte $03,$0E,$0D,$3A,$35,$3A,$35,$3A
	.byte $35,$3A,$35,$3A,$35,$3A,$35,$3A
	.byte $35,$3A,$35,$3A,$35,$3A,$35,$3A
	.byte $0D,$03,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$03,$0E,$35,$EB
	.byte $57,$AB,$57,$AB,$57,$AB,$57,$AB
	.byte $57,$AB,$57,$AB,$57,$AB,$57,$AA
	.byte $55,$AF,$5C,$AC,$5C,$AC,$5C,$AC
	.byte $5C,$AC,$5C,$AC,$5C,$AC,$5C,$AC
	.byte $DF,$EA,$DF,$EB,$75,$BA,$55,$AA
	.byte $55,$AA,$55,$AA,$55,$AA,$7D,$BB
	.byte $75,$BA,$75,$BA,$77,$BE,$55,$AA
	.byte $55,$AA,$55,$AA,$55,$AA,$55,$AA
	.byte $55,$AA,$D5,$3A,$0D,$03,$00,$00
	.byte $00,$00,$3C,$FF,$57,$AA,$55,$FF
	.byte $00,$00,$00,$03,$03,$03,$03,$03
	.byte $03,$03,$03,$00,$00,$00,$FF,$AA
	.byte $55,$FF,$00,$00,$00,$03,$03,$03
	.byte $00,$00,$03,$03,$03,$00,$00,$00
	.byte $FF,$AA,$55,$EA,$75,$AA,$55,$AA
	.byte $55,$AA,$55,$AA,$55,$AA,$55,$AA
	.byte $D5,$BA,$75,$EA,$55,$AE,$55,$AA
	.byte $75,$BA,$75,$BA,$75,$BA,$75,$BF
	.byte $55,$AA,$55,$AA,$55,$FF,$3F,$00
	.byte $00,$00,$03,$3F,$F5,$AA,$55,$FE
	.byte $03,$00,$00,$C0,$70,$AC,$5C,$AC
	.byte $5C,$B0,$C0,$00,$00,$03,$FD,$AA
	.byte $55,$FF,$00,$00,$00,$FF,$55,$FE
	.byte $0D,$0E,$FD,$AA,$FF,$00,$00,$00
	.byte $FF,$AA,$55,$AA,$55,$AB,$57,$AB
	.byte $57,$AB,$55,$AA,$55,$AA,$55,$AB
	.byte $5D,$AB,$55,$AA,$5D,$AB,$55,$AA
	.byte $55,$AA,$55,$AA,$55,$AA,$55,$EB
	.byte $55,$AA,$55,$AA,$55,$BE,$FF,$00
	.byte $3F,$FF,$55,$AA,$55,$AA,$55,$AA
	.byte $55,$EA,$35,$0E,$0D,$0E,$0D,$0E
	.byte $0D,$0E,$0D,$3A,$D5,$AA,$55,$AA
	.byte $55,$EA,$D5,$EA,$D5,$EB,$57,$AB
	.byte $57,$AB,$57,$AB,$D7,$EA,$D5,$EA
	.byte $D5,$AA,$55,$BF,$D5,$AE,$7F,$BA
	.byte $7F,$AE,$D5,$BF,$55,$AA,$D5,$BA
	.byte $5D,$AA,$D5,$BA,$5D,$BA,$D5,$AA
	.byte $55,$AA,$55,$AA,$55,$AA,$55,$AA
	.byte $55,$AA,$55,$AA,$55,$AA,$FF,$FF
	.byte $CF,$FC,$55,$AA,$55,$AA,$55,$BF
	.byte $70,$B0,$70,$B0,$70,$B0,$70,$B0
	.byte $70,$B0,$70,$B0,$70,$B0,$7F,$AA
	.byte $55,$AB,$5C,$B0,$C0,$00,$03,$03
	.byte $03,$03,$03,$03,$00,$C0,$70,$AC
	.byte $57,$AA,$55,$AA,$D5,$BA,$75,$BA
	.byte $75,$BA,$D5,$AA,$55,$AA,$55,$AA
	.byte $55,$AE,$77,$EA,$77,$AE,$55,$AA
	.byte $F5,$EE,$D7,$EB,$FD,$EB,$D7,$EE
	.byte $F5,$AA,$55,$AA,$55,$AA,$FF,$FF
	.byte $F0,$3F,$57,$AA,$55,$AA,$55,$FA
	.byte $35,$3A,$35,$3A,$35,$3A,$35,$3A
	.byte $35,$3A,$35,$3A,$35,$3A,$F5,$AA
	.byte $55,$FF,$00,$00,$00,$FF,$55,$AA
	.byte $55,$BF,$70,$B0,$C0,$00,$03,$0E
	.byte $F5,$AA,$55,$AA,$55,$AB,$57,$AB
	.byte $57,$AB,$57,$AA,$55,$AA,$75,$BA
	.byte $75,$BA,$7D,$BB,$77,$BB,$55,$AA
	.byte $55,$AA,$55,$AB,$5D,$BA,$5D,$AB
	.byte $55,$AA,$55,$AA,$55,$AA,$FF,$F0
	.byte $3F,$FF,$F5,$AA,$55,$AA,$55,$FF
	.byte $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
	.byte $C0,$C0,$C0,$C0,$C0,$C0,$FF,$AA
	.byte $55,$FA,$35,$3A,$35,$FA,$55,$AA
	.byte $55,$FA,$35,$3A,$35,$EA,$55,$AA
	.byte $55,$AA,$55,$AA,$55,$AA,$57,$AA
	.byte $55,$AA,$57,$AA,$55,$AA,$55,$AA
	.byte $55,$AA,$5F,$BA,$75,$BA,$55,$AA
	.byte $55,$AA,$55,$AA,$D5,$BB,$D7,$AB
	.byte $D5,$BA,$55,$AA,$55,$AA,$FF,$FF
	.byte $FF,$F3,$55,$AA,$55,$AA,$55,$EA
	.byte $D5,$3A,$0D,$03,$00,$00,$00,$00
	.byte $C0,$F0,$DC,$EB,$D5,$EA,$D5,$AA
	.byte $55,$AA,$57,$AC,$70,$C0,$C0,$C0
	.byte $C0,$C0,$C0,$C0,$C0,$B0,$5C,$AB
	.byte $55,$AA,$55,$AA,$75,$EE,$57,$EE
	.byte $75,$EA,$55,$AA,$55,$AA,$55,$AA
	.byte $55,$AB,$5D,$BA,$5D,$AB,$55,$AA
	.byte $55,$AA,$57,$AA,$FD,$AA,$55,$AA
	.byte $55,$AA,$55,$AA,$55,$AA,$F7,$FF
	.byte $FC,$FF,$55,$AA,$55,$AA,$55,$BF
	.byte $70,$B0,$70,$B0,$F0,$30,$00,$00
	.byte $00,$00,$00,$00,$C0,$B0,$7F,$AA
	.byte $55,$FF,$00,$00,$00,$3F,$D5,$EA
	.byte $D5,$EF,$DC,$EC,$30,$00,$00,$03
	.byte $FD,$AA,$55,$AA,$55,$AB,$5D,$AB
	.byte $5D,$BA,$5D,$AB,$55,$AA,$55,$AA
	.byte $55,$AA,$D5,$BB,$D5,$AA,$55,$AA
	.byte $D5,$EA,$F5,$EA,$D5,$EA,$DD,$BA
	.byte $55,$FA,$5D,$AB,$55,$EA,$FF,$3F
	.byte $3F,$FF,$55,$AA,$55,$AA,$55,$FA
	.byte $35,$3A,$35,$3A,$35,$3A,$35,$3A
	.byte $35,$3A,$35,$3A,$35,$3A,$F5,$AA
	.byte $55,$FE,$0D,$0E,$0D,$FE,$55,$AA
	.byte $55,$FE,$0D,$0E,$0D,$3A,$D5,$AA
	.byte $55,$AA,$55,$AA,$D5,$BA,$5D,$BA
	.byte $D5,$BA,$D5,$AA,$55,$AA,$55,$AA
	.byte $55,$BA,$DD,$AB,$DD,$BA,$5D,$AB
	.byte $55,$AA,$55,$AE,$77,$EA,$77,$AE
	.byte $55,$AA,$55,$EA,$FF,$BF,$FC,$00
	.byte $C0,$FF,$55,$AA,$55,$AA,$55,$AA
	.byte $57,$AC,$70,$C0,$C0,$C0,$C0,$C0
	.byte $C0,$C0,$C0,$B0,$5C,$AB,$55,$AA
	.byte $55,$AA,$57,$AC,$70,$B0,$5C,$AB
	.byte $55,$AA,$55,$AA,$7F,$B0,$70,$B0
	.byte $7F,$AA,$55,$AA,$57,$AE,$55,$AA
	.byte $57,$AA,$77,$AE,$55,$AA,$55,$AA
	.byte $55,$AB,$5D,$BA,$5D,$AB,$55,$AA
	.byte $55,$AA,$55,$AA,$57,$EE,$5D,$AE
	.byte $55,$AA,$75,$FE,$CF,$03,$00,$00
	.byte $FF,$FF,$55,$AA,$55,$AA,$55,$FF
	.byte $00,$00,$00,$0C,$37,$EA,$D5,$EA
	.byte $D5,$3B,$0C,$00,$00,$00,$FF,$AA
	.byte $55,$FF,$00,$00,$00,$00,$00,$00
	.byte $C0,$B0,$5C,$AC,$F0,$00,$00,$00
	.byte $FF,$AA,$55,$AA,$55,$EA,$75,$EA
	.byte $55,$EA,$55,$AA,$55,$AA,$75,$BA
	.byte $75,$BA,$F5,$BB,$D5,$AA,$55,$AA
	.byte $55,$AB,$55,$AA,$D5,$BA,$75,$BA
	.byte $55,$AA,$55,$AA,$55,$FA,$FD,$0F
	.byte $FC,$FF,$7F,$AA,$55,$AA,$55,$EA
	.byte $35,$0E,$03,$00,$00,$C0,$C0,$C0
	.byte $C0,$00,$00,$03,$0D,$3A,$D5,$AA
	.byte $55,$FF,$00,$00,$00,$3F,$D5,$EA
	.byte $35,$0E,$03,$00,$00,$00,$00,$03
	.byte $FD,$AA,$55,$AA,$55,$AA,$55,$AA
	.byte $55,$AA,$55,$AA,$55,$AA,$55,$AA
	.byte $55,$BA,$DD,$AB,$DD,$BA,$5D,$AB
	.byte $D5,$BA,$D5,$AA,$D5,$EA,$D5,$EA
	.byte $55,$AA,$55,$AA,$55,$AA,$FF,$C0
	.byte $00,$00,$C0,$F0,$5F,$AB,$55,$AA
	.byte $55,$AA,$55,$EA,$D5,$EA,$D5,$EA
	.byte $D5,$EA,$D5,$AA,$55,$AA,$55,$AA
	.byte $55,$FA,$35,$3A,$35,$FA,$55,$AA
	.byte $55,$AA,$55,$EA,$35,$3A,$D5,$AA
	.byte $57,$AF,$57,$AF,$57,$AB,$57,$AB
	.byte $5D,$AE,$75,$BA,$75,$EA,$D5,$AA
	.byte $55,$AA,$5F,$BA,$75,$BA,$55,$AA
	.byte $55,$AA,$55,$AA,$55,$AA,$55,$AA
	.byte $55,$AA,$55,$AA,$55,$AA,$D7,$FC
	.byte $00,$00,$00,$00,$00,$00,$00,$C0
	.byte $70,$B0,$5C,$BC,$5C,$BC,$5C,$BC
	.byte $5C,$BC,$70,$B0,$5C,$BC,$5C,$AC
	.byte $5C,$BC,$5C,$BC,$5C,$BC,$5C,$AC
	.byte $5C,$BC,$5C,$AC,$7C,$F0,$70,$C0
	.byte $00,$00,$00,$C0,$C0,$F0,$5C,$AC
	.byte $5C,$AC,$5C,$AC,$5C,$AC,$5C,$AC
	.byte $5C,$B0,$70,$B0,$70,$B0,$70,$B0
	.byte $70,$B0,$70,$AC,$5C,$AC,$5C,$AC
	.byte $5C,$AC,$5C,$AC,$70,$C0,$00,$00

L_JMP_3F84_31FA:

	ldx #$14
	lda #$0C
	jsr L_JSR_6E5A_3F88
	ldy #$7F
	lda #$00

L_BRS_3F8F_3F92:

	sta ($E0),Y
	dey
	bpl L_BRS_3F8F_3F92
	ldx #$00
	stx $EF
	lda $04
	sec
	sbc #$50
	lsr
	lsr
	lsr
	tax
	cpx #$15
	bcc L_BRS_3FAE_3FA3
	sec
	sbc #$11
	eor #$0F
	sta $EF
	ldx #$00

L_BRS_3FAE_3FA3:

	lda $04
	and #$07
	sta $E6
	lda #$08
	sec
	sbc $E6
	sta $E7
	lda #$0C
	jsr L_JSR_6E5A_3FBD

L_JMP_3FC0_4058:

	lda $EF
	asl
	asl
	asl
	clc
	adc #$84
	sta v_4011
	lda #$3A
	adc #$00
	sta v_4012
	lda v_4011
	sec
	sbc $E6
	sta v_4011
	lda v_4012
	sbc #$00
	sta v_4012
	ldx #$00
	ldy #$00

L_BRS_3FE7_4020:
L_BRS_3FE7_4027:

	lda $EF
	beq L_BRS_4000_3FE9
	cmp #$0A
	bne L_BRS_400C_3FED
	txa
	beq L_BRS_3FFC_3FF0
	clc
	adc $E7
	beq L_BRS_4029_3FF5
	tax
	tya
	adc $E7
	tay

L_BRS_3FFC_3FF0:

	lda $E6
	bpl L_BRS_400E_3FFE

L_BRS_4000_3FE9:

	tya
	clc
	adc $E6
	tay
	txa
	adc $E6
	tax
	lda $E7
	.byte $2C

L_BRS_400C_3FED:

	lda #$08

L_BRS_400E_3FFE:

	sta $E9

L_BRS_4010_4019:

	lda table_3A84,X
	sta ($E0),Y
	inx
	iny
	dec $E9
	bne L_BRS_4010_4019
	txa
	clc
	adc #$48
	tax
	bcc L_BRS_3FE7_4020
	beq L_BRS_4029_4022
	inc v_4012
	bne L_BRS_3FE7_4027

L_BRS_4029_3FF5:
L_BRS_4029_4022:

	ldx #$00
	jsr L_JSR_6762_402B
	lda $E4
	sta $E2
	lda $E5
	and #$1F
	ora #$D8
	sta $E3
	ldy #$0F

L_BRS_403C_4045:

	lda #$6B
	sta ($E4),Y
	lda #$01
	sta ($E2),Y
	dey
	bpl L_BRS_403C_4045
	ldy #$00
	jsr L_JSR_61C2_4049
	inc $EF
	lda $EF
	cmp #$0B
	beq L_BRS_405F_4052
	cmp #$0A
	beq L_BRS_405B_4056

L_BRS_4058_405D:

	jmp L_JMP_3FC0_4058

L_BRS_405B_4056:

	lda $E6
	bne L_BRS_4058_405D

L_BRS_405F_4052:

	lda $04
	cmp #$A8
	bne L_BRS_4081_4063
	lda #$08
	sta VCREG1                          // Voice 1: Control Register
	sta FREHI1                          // Voice 1: Frequency Control - High-Byte
	ldx #$00
	ldy #$F0
	lda #$81
	stx ATDCY1                          // Voice 1: Attack / Decay Cycle Control
	sty SUREL1                          // Voice 1: Sustain / Release Cycle Control
	sta VCREG1                          // Voice 1: Control Register
	ldy #$1E
	jsr L_JSR_4623_407E

L_BRS_4081_4063:

	lda $04
	ldx $05
	clc
	adc table_43EA,X
	sta $04
	dec $05
	beq L_BRS_4090_408D
	rts

L_BRS_4090_408D:

	lda #$FA
	sta v_414A
	lda #$41
	sta v_414B
	jsr L_JSR_44EA_409A
	ldx #$0E

L_BRS_409F_40AC:

	lda table_450C,X
	sta RAM8400 + $80,X
	lda table_44FD,X
	sta RAM8400,X
	dex
	bpl L_BRS_409F_40AC
	ldx #$35

L_BRS_40B0_40BD:

	lda table_451B,X
	sta RAM8400 + $C0,X
	lda table_4551,X
	sta RAM8400 + $100,X
	dex
	bpl L_BRS_40B0_40BD
	lda #$18
	sta XXPAND                          // Sprites Expand 2x Horizontal (X)
	lda #$02
	sta SP2COL                          // Sprite 2 Color
	sta SP3COL                          // Sprite 3 Color
	sta SP0COL                          // Sprite 0 Color
	sta SP1COL                          // Sprite 1 Color
	sta SP4COL                          // Sprite 4 Color
	sta SP5COL                          // Sprite 5 Color
	ldx #$0F

L_BRS_40DA_40E1:

	lda table_44DA,X
	sta SP0X,X                          // Sprite 0 X Pos
	dex
	bpl L_BRS_40DA_40E1
	stx SPENA                          // Sprite display Enable
	lda #$09
	sta MSIGX                          // Sprites 0-7 MSB of X coordinate
	lda #$95
	sta $0203
	ldx #$FF
	stx $EB
	inx
	stx $ED
	stx $EC
	lda IRQ_vector                          // Vector: IRQ
	pha
	lda IRQ_vector + 1
	pha
	lda #$35
	ldy #$44
	ldx #$10
	jsr L_JSR_4499_4107

L_JMP_410A_41C4:

	lda #$09
	sta $EF
	ldx #$20
	stx $E0
	inx
	stx $E2
	lda #$A4
	sta $E1
	sta $E3

L_BRS_411B_413D:

	dec $EF
	ldx #$02

L_BRS_411F_413B:
L_BRS_411F_4143:

	ldy #$78

L_BRS_4121_412A:

	lda ($E2),Y
	sta ($E0),Y
	tya
	sec
	sbc #$08
	tay
	bpl L_BRS_4121_412A
	txa
	tay
	jsr L_JSR_61C2_412E
	iny
	ldx #$02
	jsr L_JSR_61DE_4134
	tya
	tax
	cpx #$09
	bcc L_BRS_411F_413B
	bne L_BRS_411B_413D
	lda $EF
	cmp #$01
	bne L_BRS_411F_4143
	ldy #$78
	ldx #$0F

L_BRS_4149_4173:

	lda $E000,X                          // EXP continued From BASIC ROM
	bit $EB
	bmi L_BRS_4152_414E
	lda #$20

L_BRS_4152_414E:

	stx $E6
	and #$3F
	asl
	asl
	asl
	php
	clc
	adc $EC
	tax
	plp
	bcc L_BRS_4166_415F
	lda $CF00,X
	bcs L_BRS_4169_4164

L_BRS_4166_415F:

	lda $CE00,X

L_BRS_4169_4164:

	sta ($E0),Y
	tya
	sec
	sbc #$08
	tay
	ldx $E6
	dex
	bpl L_BRS_4149_4173
	lda $EC
	clc
	adc #$01
	cmp #$08
	bne L_BRS_4198_417C
	inc $ED
	jsr L_JSR_4415_4180
	beq L_BRS_4196_4183
	lda v_414A
	clc
	adc #$10
	sta v_414A
	lda v_414B
	adc #$00
	sta v_414B

L_BRS_4196_4183:

	lda #$00

L_BRS_4198_417C:

	sta $EC
	lda #$FF
	sta D1DDRA                          // Data Direction Register A
	jsr L_JSR_7D55_419F
	beq L_BRS_41AA_41A2

L_BRS_41A4_41B7:

	lda #$00
	sta $DE
	beq L_BRS_41C7_41A8

L_BRS_41AA_41A2:

	ldx #$00
	stx D1DDRA                          // Data Direction Register A
	stx D1DDRB                          // Data Direction Register B
	lda D1PRA                          // Data Port A (Keyboard, Joystick, Paddles)
	and #$10
	beq L_BRS_41A4_41B7
	ldy #$28
	jsr L_JSR_3591_41BB
	lda $ED
	cmp #$30
	beq L_BRS_41C7_41C2
	jmp L_JMP_410A_41C4

L_BRS_41C7_41A8:
L_BRS_41C7_41C2:

	pla
	tay
	pla
	ldx #$52
	jsr L_JSR_4499_41CC
	lda #$00
	sta XXPAND                          // Sprites Expand 2x Horizontal (X)
	jsr L_JSR_44EA_41D4
	lda #$00
	sta $BFFA
	sta $BFFB
	ldx #$07

L_BRS_41E1_41E5:

	sta $05B4,X
	dex
	bpl L_BRS_41E1_41E5
	bit $DE
	bmi L_BRS_41EC_41E9
	inx

L_JMP_41EC_383E:
L_BRS_41EC_41E9:

	lda #$06
	sta SP0COL                          // Sprite 0 Color
	sta SP1COL                          // Sprite 1 Color
	lda #$03
	sta SPMC                          // Sprites Multi-Color Mode Select
	rts

// 41FA

	.byte $A0,$C5,$D8,$D0,$CC,$CF,$D2,$C9
	.byte $CE,$C7,$A0,$D4,$C8,$C5,$A0,$A0
	.byte $D0,$D2,$C5,$C8,$C9,$D3,$D4,$CF
	.byte $D2,$C9,$C3,$A0,$D0,$C1,$D3,$D4
	.byte $D6,$C9,$C1,$A0,$D4,$C9,$CD,$C5
	.byte $A0,$D7,$C1,$D2,$D0,$A0,$AD,$AD
	.byte $A0,$D9,$CF,$D5,$A0,$C9,$CE,$C6
	.byte $C5,$C3,$D4,$A0,$D4,$C8,$C5,$A0
	.byte $A0,$C4,$C9,$CE,$CF,$D3,$C1,$D5
	.byte $D2,$D3,$A0,$D7,$C9,$D4,$C8,$A0
	.byte $C3,$CF,$CD,$CD,$CF,$CE,$A0,$CD
	.byte $C5,$C1,$D3,$CC,$C5,$D3,$AD,$AD
	.byte $A0,$A0,$C1,$C3,$C3,$C9,$C4,$C5
	.byte $CE,$D4,$C1,$CC,$CC,$D9,$A0,$A0
	.byte $C3,$CF,$CE,$C4,$C5,$CD,$CE,$C9
	.byte $CE,$C7,$A0,$D4,$C8,$C5,$CD,$A0
	.byte $A0,$D4,$CF,$A0,$C5,$D8,$D4,$C9
	.byte $CE,$C3,$D4,$C9,$CF,$CE,$A1,$A0
	.byte $A0,$CF,$D6,$C5,$D2,$C3,$CF,$CD
	.byte $C5,$A0,$D7,$C9,$D4,$C8,$A0,$A0
	.byte $A0,$D2,$C5,$CD,$CF,$D2,$D3,$C5
	.byte $A0,$AD,$AD,$A0,$D9,$CF,$D5,$A0
	.byte $C4,$C5,$D6,$CF,$D4,$C5,$A0,$D9
	.byte $CF,$D5,$D2,$D3,$C5,$CC,$C6,$A0
	.byte $D4,$CF,$A0,$D2,$C5,$D3,$C3,$D5
	.byte $C9,$CE,$C7,$A0,$D4,$C8,$C5,$A0
	.byte $C5,$CE,$D4,$C9,$D2,$C5,$A0,$C4
	.byte $C9,$CE,$CF,$D3,$C1,$D5,$D2,$A0
	.byte $A0,$A0,$D0,$CF,$D0,$D5,$CC,$C1
	.byte $D4,$C9,$CF,$CE,$A1,$A0,$A0,$A0
	.byte $A0,$D9,$CF,$D5,$A0,$C3,$C1,$CE
	.byte $A0,$C4,$CF,$A0,$C9,$D4,$A1,$A0
	.byte $AD,$AD,$A0,$C6,$CF,$D2,$A0,$D9
	.byte $CF,$D5,$A0,$C1,$D2,$C5,$A0,$A0
	.byte $D4,$C9,$CD,$C5,$A0,$CD,$C1,$D3
	.byte $D4,$C5,$D2,$A0,$D4,$C9,$CD,$A1
	.byte $D5,$D3,$C9,$CE,$C7,$A0,$D9,$CF
	.byte $D5,$D2,$A0,$D4,$C9,$CD,$C5,$A0
	.byte $D7,$C1,$D2,$D0,$A0,$AD,$AD,$A0
	.byte $D9,$CF,$D5,$A0,$C3,$C1,$CE,$A0
	.byte $A0,$C6,$C9,$CE,$C4,$A0,$C1,$CE
	.byte $C4,$A0,$C3,$C1,$D2,$D2,$D9,$A0
	.byte $A0,$D4,$C8,$C5,$A0,$C4,$C9,$CE
	.byte $CF,$A0,$C5,$C7,$C7,$D3,$A0,$A0
	.byte $C1,$CE,$C4,$A0,$C4,$C9,$CE,$CF
	.byte $A0,$C2,$C1,$C2,$C9,$C5,$D3,$A0
	.byte $D3,$C1,$C6,$C5,$CC,$D9,$A0,$C9
	.byte $CE,$D4,$CF,$A0,$D4,$C8,$C5,$A0
	.byte $A0,$B2,$B1,$D3,$D4,$A0,$C3,$C5
	.byte $CE,$D4,$D5,$D2,$D9,$A1,$A0,$A0
	.byte $A0,$A0,$A0,$A0,$A0,$A0,$D4,$C8
	.byte $C5,$A0,$A0,$A0,$A0,$A0,$A0,$A0
	.byte $A0,$A0,$A0,$C4,$C9,$CE,$CF,$D3
	.byte $C1,$D5,$D2,$D3,$A0,$A0,$A0,$A0
	.byte $A0,$A0,$A0,$CC,$C9,$D6,$C5,$A0
	.byte $C1,$C7,$C1,$C9,$CE,$A0,$A0,$A0
	.byte $A0,$C9,$CE,$A0,$CF,$D5,$D2,$A0
	.byte $C6,$D5,$D4,$D5,$D2,$C5,$A1,$A0
	.byte $D4,$C8,$C1,$CE,$CB,$D3,$A0,$D4
	.byte $CF,$A0,$D9,$CF,$D5,$A0,$AD,$AD
	.byte $D4,$C9,$CD,$C5,$A0,$CD,$C1,$D3
	.byte $D4,$C5,$D2,$A0,$D4,$C9,$CD,$A1

table_43EA:

	.byte $00,$00,$00,$02,$01,$FF,$FE,$03
	.byte $02,$01,$FF,$FE,$FD,$04,$08,$08
	.byte $08,$08,$08,$08,$08,$08,$08,$08
	.byte $08,$08,$07,$07,$06,$06,$05,$05
	.byte $04,$04,$04,$03,$03,$03,$03,$02
	.byte $02,$02,$01

L_JSR_4415_4180:

	lda $ED
	ldx #$10

L_BRS_4419_441F:

	cmp table_4424,X
	beq L_BRS_4421_441C
	dex
	bpl L_BRS_4419_441F

L_BRS_4421_441C:

	stx $EB
	rts

table_4424:

	.byte $03,$0A,$11,$13,$16,$17,$1F,$23
	.byte $25,$28,$29,$2A,$2B,$2C,$2D,$2E
	.byte $2F
// 4435
	pha
	txa
	pha
	tya
	pha
	lda $0202
	beq L_BRS_447C_443D
	cmp #$01
	beq L_BRS_446B_4441
	ldx #$04

L_BRS_4445_4446:

	dex
	bne L_BRS_4445_4446
	lda #$08
	sta SCROLX                          // Control Register 2

L_BRS_444D_4452:

	lda RASTER                          // Raster Position
	cmp #$8A
	bne L_BRS_444D_4452
	lda #$EE
	sta RASTER                          // Raster Position
	lda #$FF
	sta $0202
	ldx #$04

L_BRS_4460_4461:

	dex
	bne L_BRS_4460_4461
	lda #$18
	sta SCROLX                          // Control Register 2
	jmp L_JMP_448B_4468

L_BRS_446B_4441:

	lda #$4A
	sta RASTER                          // Raster Position
	lda #$18
	sta SCROLX                          // Control Register 2
	lda #$3B
	sta SCROLY                          // Control Register 1
	bne L_BRS_448B_447A

L_BRS_447C_443D:

	lda #$F6
	sta RASTER                          // Raster Position
	lda #$08
	sta SCROLX                          // Control Register 2
	lda #$95	// VIC BANK2 $8000
	sta D2PRA                          // Data Port A (Serial Bus, RS232, VIC Base Mem.)

L_JMP_448B_4468:
L_BRS_448B_447A:

	lda #$01
	sta VICIRQ                          // Interrupt Request Register (IRR)
	inc $0202
	pla
	tay
	pla
	tax
	pla
	rti

L_JSR_4499_4107:
L_JSR_4499_41CC:

	stx two_zero44b3

L_BRS_449C_44A1:

	ldx RASTER                          // Raster Position
	cpx #$90
	bne L_BRS_449C_44A1
	sei
	sta IRQ_vector                          // Vector: IRQ
	sty IRQ_vector + 1
	lda #$00
	sta $0202
	cli
	ldy #$27

L_BRS_44B2_44D7:

	lda two_zero44b3:#$20
	cpy #$20
	bcs L_BRS_44BE_44B6
	cpy #$0A
	bcc L_BRS_44BE_44BA
	lda #$10

L_BRS_44BE_44B6:
L_BRS_44BE_44BA:

	sta RAM8000 + $078,Y
	sta RAM8000 + $0A0,Y
	sta RAM8000 + $0C8,Y
	sta RAM8000 + $0F0,Y
	sta RAM8000 + $118,Y
	sta RAM8000 + $140,Y
	sta RAM8000 + $168,Y
	sta RAM8000 + $190,Y
	dey
	bpl L_BRS_44B2_44D7
	rts

table_44DA:

	.byte $48,$62,$18,$62,$40,$63,$18,$62
	.byte $28,$62,$28,$74,$90,$90,$98,$98

L_JSR_44EA_3246:
L_JSR_44EA_409A:
L_JSR_44EA_41D4:

	ldx #$00
	txa

L_BRS_44ED_44FA:

	sta RAM8400 + $000,X
	sta RAM8400 + $100,X
	sta RAMC400 + $000,X
	sta RAMC400 + $100,X
	inx
	bne L_BRS_44ED_44FA
	rts

table_44FD:

	.byte $AA,$AA,$00,$A8,$02,$00,$8A,$AA
	.byte $00,$20,$22,$00,$00,$00,$00
table_450C:
	.byte $FF
	.byte $FF,$FF,$D9,$FD,$9F,$A7,$5A,$75
	.byte $4C,$E4,$CE,$20,$A2,$0A
table_451B:
	.byte $FF,$FF
	.byte $FF,$AF,$8F,$3B,$EB,$0A,$02,$BE
	.byte $04,$00,$0A,$F0,$00,$00,$C0,$00
	.byte $00,$60,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$78,$00,$00,$38
	.byte $00,$00,$30,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$F0
	.byte $00,$00,$F0,$00
table_4551:
	.byte $00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $3F,$C0,$00,$03,$00,$00,$0F,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$FF,$00,$00,$FF
	.byte $00,$00,$3C,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$3F,$00,$00,$0F
	.byte $00,$00

L_JSR_4587_45F2:

	jsr L_JSR_3729_4587
	lda $E0
	sta $F8
	lda $E1
	sta $F9
	lda $E6
	sta $FA
	lda $E7
	sta $FB
	lda $E2
	sta $FC
	lda $E3
	sta $FD
	lda $EA
	pha
	lda #$25
	sec
	sbc $EA
	sta $EA
	jsr L_JSR_3729_45AC
	ldy #$03
	lda $EA
	lsr
	bcs L_BRS_45B8_45B4
	ldy #$07

L_BRS_45B8_45B4:

	lda #$03
	sta $EE

L_BRS_45BC_45E6:

	sty $EF
	lda table_377E,Y
	eor ($F8),Y
	sta ($F8),Y
	lda table_377E + 8,Y
	eor ($FA),Y
	sta ($FA),Y
	tya
	eor #$07
	tay
	lda table_377E,Y
	eor ($E4),Y
	sta ($E4),Y
	lda table_377E + 8,Y
	eor ($FC),Y
	sta ($FC),Y
	jsr L_JSR_45FA_45DE
	ldy $EF
	dey
	dec $EE
	bpl L_BRS_45BC_45E6
	pla
	sta $EA
	rts

L_JSR_45EC_330D:
L_JSR_45EC_3312:

	sta $F0
	lda #$12
	sta $EA

L_BRS_45F2_45F7:

	jsr L_JSR_4587_45F2
	dec $EA
	bne L_BRS_45F2_45F7
	rts

L_JSR_45FA_45DE:

	lda $EA
	bit $F0
	bpl L_BRS_4605_45FE
	lda #$26
	sec
	sbc $EA

L_BRS_4605_45FE:

	lsr
	clc
	adc #$03
	sta FREHI1                          // Voice 1: Frequency Control - High-Byte
	asl
	asl
	asl
	asl
	ora #$04
	ldy #$81
	ldx #$52
	lda #$81
	stx ATDCY1                          // Voice 1: Attack / Decay Cycle Control
	sty SUREL1                          // Voice 1: Sustain / Release Cycle Control
	sta VCREG1                          // Voice 1: Control Register
	ldy #$12

L_JSR_4623_407E:
L_BRS_4623_4624:
L_BRS_4623_462F:

	inx
	bne L_BRS_4623_4624
	lda VCREG1                          // Voice 1: Control Register
	eor #$91
	sta VCREG1                          // Voice 1: Control Register
	dey
	bne L_BRS_4623_462F
	stx VCREG1                          // Voice 1: Control Register
	rts

table_4635:

	.byte $18,$15,$13,$15,$19,$0C,$09,$07
	.byte $09,$19,$15,$13,$15,$18,$19,$0C
	.byte $19,$FF,$0C,$09,$07,$09,$19,$18
	.byte $15,$13,$15,$19,$09,$07,$09,$0C
	.byte $19,$18,$19,$FF,$07,$09,$0C,$13
	.byte $15,$18,$1A,$1B,$1C,$19,$0C,$FF
	.byte $0E,$19,$0E,$19,$0E,$19,$02,$19
	.byte $05,$19,$02,$FF,$08,$0A,$0C,$0D
	.byte $0E,$12,$0E,$12,$0B,$0E,$0D,$0A
	.byte $0B,$19,$FF,$07,$0C,$07,$19,$07
	.byte $0C,$10,$0E,$0C,$19,$FF,$0C,$07
	.byte $0C,$0F,$0E,$0C,$0F,$0E,$0C,$07
	.byte $00,$FF,$11,$12,$10,$13,$0F,$14
	.byte $0E,$15,$0D,$16,$0C,$1D,$18,$0C
	.byte $19,$FF
table_46A7:
	.byte$60,$20,$40,$40,$90,$60
	.byte $20,$40,$40,$90,$2B,$2B,$2B,$40
	.byte $30,$50,$30,$00,$60,$20,$40,$40
	.byte $90,$60,$20,$40,$40,$90,$2B,$2B
	.byte $2B,$40,$30,$50,$30,$00,$60,$20
	.byte $40,$60,$20,$40,$60,$20,$40,$80
	.byte $C0,$00,$18,$40,$18,$40,$18,$40
	.byte $30,$90,$30,$90,$38,$90,$0A,$0A
	.byte $0A,$0A,$80,$80,$80,$80,$40,$40
	.byte $40,$40,$88,$60,$00,$90,$F0,$30
	.byte $40,$90,$A0,$FF,$48,$E8,$60,$00
	.byte $60,$60,$60,$60,$60,$60,$78,$78
	.byte $D0,$E0,$F0,$00,$30,$60,$30,$60
	.byte $30,$60,$30,$60,$30,$60,$C0,$30
	.byte $39,$E8,$E0,$FF

L_JMP_4719_31F7:
L_JSR_4719_3804:
L_BRS_4719_475C:

	lda $DE
	bmi L_BRS_475E_471B
	ldx table_4635,Y
	bmi L_BRS_475E_4720
	cpx #$19
	beq L_BRS_4741_4724
	lda table_475F,X
	sta FRELO1                          // Voice 1: Frequency Control - Low-Byte
	lda table_477D,X
	sta FREHI1                          // Voice 1: Frequency Control - High-Byte
	lda #$11
	sta VCREG1                          // Voice 1: Control Register
	lda #$23
	sta ATDCY1                          // Voice 1: Attack / Decay Cycle Control
	lda #$C1
	sta SUREL1                          // Voice 1: Sustain / Release Cycle Control

L_BRS_4741_4724:

	sty $EF
	lda table_46A7,Y
	sta $E0

L_BRS_4748_474F:

	ldy #$02
	jsr L_JSR_3591_474A
	dec $E0
	bne L_BRS_4748_474F
	lda VCREG1                          // Voice 1: Control Register
	and #$FE
	sta VCREG1                          // Voice 1: Control Register
	ldy $EF
	iny
	bne L_BRS_4719_475C

L_BRS_475E_471B:
L_BRS_475E_4720:

	rts

table_475F:

	.byte $8F,$4E,$18,$EF,$D2,$C3,$C3,$D1
	.byte $EF,$1F,$60,$B5,$1E,$9C,$31,$DF
	.byte $A5,$87,$86,$A2,$DF,$3E,$C1,$6B
	.byte $3C,$00,$45,$7D,$79,$FE
table_477D:
	.byte $0C,$0D
	.byte $0E,$0E,$0F,$10,$11,$12,$13,$15
	.byte $16,$17,$19,$1A,$1C,$1D,$1F,$21
	.byte $23,$25,$27,$2A,$2C,$2F,$32,$00
	.byte $4B,$54,$64,$33
table_479B:
	.byte $00,$12,$00,$12
	.byte $00,$12,$00,$12,$00,$24
table_47A5:
	.byte $B9,$31
	.byte $A9,$B9,$31,$A9,$B9,$31,$A9,$B9
table_47AF:
	.byte $47,$48,$48,$47,$48,$48,$47,$48
	.byte $48,$47,$AA,$BB,$A8,$8A,$00,$00
	.byte $00,$00,$AA,$AA,$8A,$A8,$88,$00
	.byte $00,$00,$AA,$80,$00,$00,$AA,$AC
	.byte $28,$00,$00,$00,$2A,$3A,$0A,$00
	.byte $00,$00,$00,$00,$80,$80,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $2A,$3E,$00,$00,$00,$00,$00,$00
	.byte $80,$00,$AA,$AA,$00,$00,$00,$00
	.byte $00,$00,$0A,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$AA,$AA
	.byte $28,$00,$00,$00,$2A,$0A,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$AA,$AA,$B8,$2A,$00,$00
	.byte $00,$00,$AA,$A3,$20,$A0,$00,$00
	.byte $00,$00,$AA,$F2,$00,$00,$AA,$BA
	.byte $28,$00,$00,$00,$2B,$2A,$02,$00
	.byte $00,$00,$00,$00,$C0,$80,$80,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $2A,$0A,$00,$00,$00,$00,$00,$00
	.byte $80,$C0,$AA,$F2,$00,$00,$00,$00
	.byte $00,$00,$0A,$00,$00,$00,$00,$00
	.byte $00,$00,$80,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$AA,$AB
	.byte $E8,$20,$00,$00,$2A,$2A,$00,$00
	.byte $00,$00,$00,$00,$80,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$AA,$EA,$88,$AA,$08,$00
	.byte $00,$00,$AA,$A8,$A0,$80,$82,$02
	.byte $03,$02,$AA,$EA,$0C,$02,$AA,$B8
	.byte $A8,$E0,$00,$00,$2A,$3A,$0A,$0B
	.byte $02,$02,$02,$00,$80,$80,$80,$00
	.byte $00,$00,$B0,$80,$80,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $2A,$3A,$02,$02,$00,$00,$00,$00
	.byte $80,$C0,$AA,$AA,$00,$00,$00,$00
	.byte $00,$00,$0B,$0A,$02,$02,$02,$00
	.byte $00,$00,$00,$00,$00,$00,$C0,$80
	.byte $20,$08,$00,$00,$00,$00,$AA,$EA
	.byte $28,$28,$00,$00,$2A,$0A,$00,$00
	.byte $00,$00,$02,$00,$80,$C0,$00,$00
	.byte $00,$00,$A0,$80,$00,$00,$00,$00
	.byte $00,$00,$40,$FF,$42,$FF,$FF,$6F
	.byte $EF,$FF,$FF,$DF,$FF,$FF,$5E,$FF
	.byte $FF,$DF,$95,$F1,$FF,$FF,$00,$FF
	.byte $4E,$FF,$B1,$FF,$4F,$FF,$4F,$FF
	.byte $6F,$FF,$27,$FF,$6F,$FF,$0E,$FF
	.byte $BF,$DF,$91,$FF,$FF,$7F,$FF,$FF
	.byte $FF,$FF,$EF,$6F,$7F,$FF,$4F,$FF
	.byte $00,$FF,$BE,$FF,$F5,$FF,$D6,$FF
	.byte $00,$FF,$0D,$FF,$02,$FF,$B7,$DF
	.byte $EF,$FF,$B3,$FF,$FF,$FF,$00,$FF
	.byte $FF,$FF,$5F,$EF,$FF,$FF,$00,$FF
	.byte $CF,$FF,$00,$FF,$6F,$FF,$FF,$FF
	.byte $00,$05,$B7,$07,$BF,$14,$BF,$05
	.byte $BF,$02,$4E,$00,$FF,$04,$14,$1F
	.byte $FF,$01,$B5,$B0,$9F,$5E,$FF,$14
	.byte $A7,$94,$EE,$84,$F7,$40,$FF,$1B
	.byte $5F,$04,$07,$05,$BD,$04,$07,$95
	.byte $55,$06,$05,$20,$A7,$04,$A7,$00
	.byte $5F,$25,$FF,$0E,$00,$04,$FF,$04
	.byte $DF,$B5,$5E,$91,$B5,$2F,$7F,$0F
	.byte $95,$05,$F9,$07,$BD,$00,$FB,$0E
	.byte $55,$30,$7F,$00,$A4,$80,$BF,$0F
	.byte $3F,$05,$B5,$9F,$9F,$D5,$FF,$94
	.byte $F7,$14,$77,$04,$DE,$4F,$EF,$4F
	.byte $FF,$04,$D7,$01,$FD,$04,$57,$05
	.byte $B7,$06,$2F,$10,$B7,$9D,$FF,$47
	.byte $95,$00,$FE,$10,$05,$04,$FF,$04
	.byte $5C,$95,$FF,$94,$B5,$4F,$B5,$CF
	.byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.byte $00,$FF,$B1,$FF,$03,$FF,$FF,$FF
	.byte $BE,$FF,$FF,$4F,$7F,$FF,$F7,$FF
	.byte $FF,$FF,$01,$FF,$FF,$FF,$D7,$FF
	.byte $FF,$FF,$FF,$FF,$42,$FF,$FF,$FF
	.byte $FF,$B7,$FF,$DF,$FF,$FF,$FF,$FF
	.byte $FF,$DF,$9D,$F5,$BF,$FF,$00,$FF
	.byte $4E,$FF,$B1,$FF,$FF,$FF,$4F,$FF
	.byte $CF,$FF,$A7,$DF,$FF,$FF,$8F,$FF
	.byte $BF,$DF,$DF,$FF,$FF,$FF,$FF,$FF
	.byte $FF,$FF,$DF,$FF,$FF,$FF,$FF,$FF
	.byte $08,$FF,$BE,$FF,$F5,$FF,$D7,$FF
	.byte $00,$FF,$0D,$FF,$06,$FF,$B7,$FF
	.byte $FF,$B7,$B7,$EE,$FF,$FF,$00,$FF
	.byte $FF,$FF,$5F,$EF,$FF,$FF,$04,$FF
	.byte $CF,$FF,$00,$FF,$EF,$FF,$FF,$FF
	.byte $00,$05,$15,$05,$B7,$04,$BF,$04
	.byte $BF,$02,$4E,$00,$FD,$04,$14,$0F
	.byte $FD,$01,$A5,$B0,$97,$5C,$FF,$00
	.byte $A5,$84,$EE,$84,$D5,$40,$FF,$1B
	.byte $0D,$04,$05,$04,$B5,$04,$07,$95
	.byte $75,$04,$05,$20,$85,$04,$A5,$00
	.byte $4F,$31,$FB,$1E,$00,$04,$FF,$05
	.byte $DF,$B5,$5E,$10,$B1,$0F,$75,$0F
	.byte $95,$05,$D1,$05,$B5,$04,$FB,$04
	.byte $55,$30,$7F,$00,$A4,$80,$BF,$0F
	.byte $27,$01,$B5,$97,$97,$C5,$FF,$90
	.byte $F7,$00,$75,$04,$DE,$6F,$EF,$4F
	.byte $FF,$04,$97,$01,$F5,$04,$57,$05
	.byte $B5,$04,$25,$10,$95,$9D,$FF,$45
	.byte $95,$00,$F4,$10,$05,$04,$FF,$05
	.byte $5C,$95,$DE,$04,$B5,$4F,$15,$4F
	.byte $FF,$FF,$FF,$FF,$6F,$FF,$6F,$FF
	.byte $40,$FF,$B1,$FF,$03,$FF,$FF,$FF
	.byte $0E,$FF,$FF,$4F,$6E,$FF,$EF,$FF
	.byte $FF,$FF,$01,$FF,$FF,$FF,$C7,$FF
	.byte $FF,$FF,$FF,$FF,$42,$FF,$FF,$EF
	.byte $EF,$FF,$FF,$DF,$FF,$FF,$5E,$FF
	.byte $FF,$DF,$9D,$F1,$FF,$FF,$00,$FF
	.byte $4E,$FF,$B1,$FF,$6F,$FF,$4F,$FF
	.byte $6F,$FF,$A7,$FF,$6F,$FF,$0F,$FF
	.byte $BF,$DF,$95,$FF,$FF,$7F,$FF,$FF
	.byte $FF,$FF,$EF,$6F,$7F,$FF,$EF,$FF
	.byte $08,$FF,$BE,$FF,$F5,$FF,$D7,$FF
	.byte $00,$FF,$6D,$FF,$06,$FF,$BF,$FF
	.byte $EF,$FF,$F7,$EF,$FF,$FF,$00,$FF
	.byte $FF,$FF,$5F,$EF,$FF,$FF,$00,$FF
	.byte $CF,$FF,$00,$FF,$6F,$FF,$FF,$FF
	.byte $00,$05,$B5,$07,$BF,$14,$BF,$05
	.byte $BF,$0A,$4E,$00,$FF,$04,$14,$0F
	.byte $FF,$01,$B5,$B0,$9F,$5E,$FF,$14
	.byte $A7,$94,$EE,$84,$F7,$40,$FF,$1B
	.byte $1F,$04,$07,$04,$BD,$05,$07,$95
	.byte $55,$06,$05,$20,$A7,$04,$A7,$00
	.byte $5F,$25,$FF,$0E,$00,$04,$FF,$04
	.byte $DF,$B5,$5E,$11,$B5,$2F,$7D,$0F
	.byte $95,$05,$F9,$07,$BD,$04,$FB,$0E
	.byte $55,$30,$7F,$00,$A4,$80,$BF,$0F
	.byte $37,$05,$B5,$9F,$9F,$D5,$FF,$94
	.byte $F7,$14,$77,$04,$DE,$4F,$EF,$4F
	.byte $FF,$04,$97,$01,$FD,$04,$57,$05
	.byte $B5,$06,$6D,$10,$B7,$9D,$FF,$45
	.byte $95,$00,$FC,$10,$05,$04,$FF,$04
	.byte $5C,$95,$DF,$14,$B5,$4F,$35,$4F
	.byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.byte $00,$FF,$B1,$FF,$03,$FF,$FF,$FF
	.byte $BE,$FF,$FF,$4F,$FF,$FF,$FF,$FF
	.byte $FF,$FF,$01,$FF,$FF,$FF,$D7,$FF
	.byte $FF,$FF,$FF,$FF,$42,$FF,$FF,$FF
	.byte $FF,$BF,$FF,$DF,$FF,$FF,$FF,$FF
	.byte $FF,$DF,$9D,$FF,$FF,$FF,$00,$FF
	.byte $4E,$FF,$F1,$FF,$FF,$FF,$4F,$FF
	.byte $EF,$FF,$27,$DF,$FF,$FF,$8E,$FF
	.byte $BF,$DF,$DF,$FF,$FF,$FF,$FF,$FF
	.byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.byte $08,$FF,$BE,$FF,$F5,$FF,$D7,$FF
	.byte $00,$FF,$2D,$FF,$02,$FF,$BF,$FF
	.byte $FF,$BF,$B3,$FE,$FF,$FF,$00,$FF
	.byte $FF,$FF,$5F,$EF,$FF,$FF,$00,$FF
	.byte $CF,$FF,$00,$FF,$6F,$FF,$FF,$FF
	.byte $00,$05,$15,$05,$BF,$14,$BF,$04
	.byte $BF,$02,$4E,$00,$FD,$04,$14,$1F
	.byte $FD,$01,$B5,$B0,$8F,$7C,$FF,$00
	.byte $A7,$94,$EE,$84,$D5,$40,$FF,$1B
	.byte $0D,$04,$05,$04,$BD,$84,$47,$95
	.byte $75,$4D,$05,$20,$87,$04,$A5,$00
	.byte $4F,$31,$FB,$1E,$00,$04,$FF,$04
	.byte $DF,$B5,$5E,$10,$B1,$2F,$75,$0F
	.byte $95,$05,$D1,$05,$BD,$04,$FB,$04
	.byte $55,$30,$7F,$00,$A5,$80,$BF,$0F
	.byte $27,$01,$B5,$9F,$9F,$D5,$FF,$C0
	.byte $F7,$10,$75,$04,$DF,$6F,$EF,$4F
	.byte $FF,$04,$97,$01,$F5,$04,$57,$05
	.byte $B5,$44,$25,$10,$95,$9D,$FF,$45
	.byte $95,$00,$F4,$10,$05,$04,$FF,$04
	.byte $5C,$95,$DE,$04,$85,$4F,$B5,$CF
	.byte $FF,$FF,$FF,$FF,$6F,$FF,$6F,$FF
	.byte $00,$FF,$B1,$FF,$03,$FF,$FF,$FF
	.byte $0F,$FF,$FF,$4F,$6E,$FF,$67,$FF
	.byte $FF,$FF,$01,$FF,$FF,$FF,$C7,$FF
	.byte $FF,$FF,$FF,$FF,$42,$FF,$FF,$6F
	.byte $EF,$FF,$FF,$DF,$FF,$FF,$5E,$FF
	.byte $FF,$DF,$95,$F1,$FF,$FF,$00,$FF
	.byte $4C,$FF,$B1,$FF,$6F,$FF,$4F,$FF
	.byte $6F,$FF,$27,$FF,$6F,$FF,$0E,$FF
	.byte $BF,$DF,$95,$FF,$FF,$7F,$FF,$FF
	.byte $FF,$FF,$EF,$6F,$7F,$FF,$6F,$FF
	.byte $00,$FF,$BE,$FF,$F5,$FF,$D7,$FF
	.byte $00,$FF,$0D,$FF,$06,$FF,$B7,$FF
	.byte $EF,$FF,$B3,$FF,$FF,$FF,$00,$FF
	.byte $FF,$FF,$5F,$EF,$FF,$FF,$00,$FF
	.byte $CF,$FF,$00,$FF,$6F,$FF,$FF,$FF
	.byte $00,$C5,$B7,$07,$BF,$04,$BF,$05
	.byte $BF,$0A,$4E,$00,$FF,$04,$14,$2F
	.byte $FF,$01,$A5,$B0,$9F,$4F,$FF,$04
	.byte $A7,$84,$EE,$84,$F7,$40,$FF,$0B
	.byte $5F,$04,$07,$05,$BD,$05,$07,$95
	.byte $65,$0E,$05,$20,$A7,$05,$E7,$00
	.byte $4F,$25,$FF,$0E,$00,$04,$FF,$05
	.byte $DF,$B5,$5E,$91,$B5,$2F,$7F,$0F
	.byte $95,$45,$F9,$07,$BD,$04,$FB,$0E
	.byte $55,$30,$7F,$00,$E4,$80,$BF,$0F
	.byte $3F,$05,$B5,$9F,$9F,$C5,$FF,$94
	.byte $F7,$04,$77,$04,$DE,$4F,$EF,$4F
	.byte $FF,$04,$97,$01,$FD,$04,$57,$05
	.byte $B7,$0E,$6D,$11,$B7,$9D,$FF,$C7
	.byte $95,$00,$FE,$10,$05,$04,$FF,$05
	.byte $5C,$95,$DF,$94,$B5,$4F,$B5,$CF
	.byte $FF,$FF,$FF,$FF,$EF,$FF,$EF,$FF
	.byte $00,$FF,$B1,$FF,$02,$FF,$FF,$FF
	.byte $BE,$FF,$FF,$4F,$7F,$FF,$FF,$FF
	.byte $FF,$FF,$01,$FF,$FF,$FF,$C7,$FF
	.byte $FF,$FF,$FF,$FF,$42,$FF,$FF,$FF
	.byte $FF,$BF,$FF,$DF,$FF,$FF,$FF,$FF
	.byte $FF,$DF,$9D,$F5,$BF,$FF,$00,$FF
	.byte $4E,$FF,$B1,$FF,$EF,$FF,$4F,$FF
	.byte $CF,$FF,$27,$DF,$EF,$FF,$8E,$FF
	.byte $BF,$DF,$DF,$FF,$FF,$FF,$FF,$FF
	.byte $FF,$FF,$EF,$FF,$7F,$FF,$7F,$FF
	.byte $08,$FF,$BE,$FF,$F5,$FF,$D7,$FF
	.byte $00,$FF,$0D,$FF,$00,$FF,$B7,$FF
	.byte $FF,$BF,$B3,$FE,$FF,$FF,$00,$FF
	.byte $FF,$FF,$5F,$EF,$FF,$FF,$00,$FF
	.byte $CF,$FF,$00,$FF,$6F,$FF,$FF,$FF
	.byte $00,$05,$1F,$05,$BF,$04,$BF,$05
	.byte $BF,$02,$4E,$00,$FF,$04,$14,$0F
	.byte $FD,$01,$A5,$B0,$9F,$5D,$FF,$00
	.byte $A7,$84,$FE,$84,$C7,$48,$FF,$1B
	.byte $0F,$04,$07,$04,$BD,$04,$07,$95
	.byte $75,$06,$05,$20,$87,$04,$AF,$00
	.byte $4F,$31,$FF,$1E,$08,$04,$FF,$05
	.byte $1F,$B5,$5E,$91,$B1,$2F,$7F,$0F
	.byte $95,$05,$D9,$05,$BD,$00,$FB,$0C
	.byte $55,$30,$7F,$00,$A4,$80,$3F,$0F
	.byte $2F,$01,$B5,$9F,$9F,$C5,$FF,$90
	.byte $F7,$00,$77,$04,$DE,$4F,$EF,$4F
	.byte $FF,$04,$D7,$01,$FD,$04,$57,$05
	.byte $B5,$06,$2D,$10,$97,$9D,$FF,$45
	.byte $95,$00,$FE,$10,$0D,$04,$FF,$05
	.byte $1C,$95,$DF,$84,$B5,$4F,$B5,$4F
	.byte $FF,$FF,$FF,$FF,$6F,$FF,$6F,$FF
	.byte $00,$FF,$B1,$FF,$02,$FF,$FF,$FF
	.byte $0E,$FF,$FF,$4F,$6E,$FF,$47,$FF
	.byte $FF,$FF,$01,$FF,$FF,$FF,$C7,$FF
	.byte $FF,$FF,$FF,$FF,$42,$FF,$FF,$6F
	.byte $EF,$FF,$FF,$DF,$FF,$FF,$5E,$FF
	.byte $FF,$DF,$95,$F1,$FF,$FF,$00,$FF
	.byte $4C,$FF,$B1,$FF,$4F,$FF,$4F,$FF
	.byte $4F,$FF,$27,$FF,$6F,$FF,$0E,$FF
	.byte $BF,$DF,$91,$FF,$FF,$7F,$FF,$FF
	.byte $FF,$FF,$EF,$6F,$7F,$FF,$4F,$FF
	.byte $08,$FF,$BE,$FF,$F5,$FF,$D6,$FF
	.byte $00,$FF,$0D,$FF,$06,$FF,$B7,$DF
	.byte $EF,$FF,$B3,$FF,$FF,$FF,$00,$FF
	.byte $FF,$FF,$5F,$EF,$FF,$FF,$00,$FF
	.byte $CF,$FF,$00,$FF,$6F,$FF,$FF,$FF
	.byte $00,$05,$B5,$07,$BF,$14,$BF,$05
	.byte $BF,$02,$4E,$00,$FF,$04,$14,$BF
	.byte $FF,$01,$B5,$B0,$9F,$5F,$FF,$14
	.byte $A7,$94,$EE,$84,$F7,$40,$FF,$1B
	.byte $1F,$04,$07,$04,$BD,$04,$07,$95
	.byte $55,$06,$05,$20,$A7,$04,$A7,$00
	.byte $1F,$25,$FF,$0E,$00,$04,$FF,$04
	.byte $DF,$B5,$5E,$91,$B1,$2F,$7F,$8F
	.byte $95,$05,$F9,$07,$BD,$00,$FB,$0E
	.byte $F5,$30,$7F,$01,$A5,$80,$BF,$0F
	.byte $37,$05,$B5,$9F,$9F,$95,$FF,$94
	.byte $F7,$14,$77,$04,$DF,$CF,$EF,$4F
	.byte $FF,$04,$97,$01,$BD,$04,$D7,$05
	.byte $B5,$06,$2D,$10,$B7,$9D,$FF,$45
	.byte $95,$00,$FC,$10,$05,$04,$FF,$04
	.byte $5C,$95,$DF,$94,$B5,$4F

L_JSR_4FFD_0BC5:

	jmp L_JMP_5697_4FFD

L_JSR_5000_0FB4:

	jmp L_JMP_5003_5000

L_JMP_5003_5000:

	ldx #$02

L_BRS_5005_500A:

	lda $2E,X
	bne L_BRS_500F_5007

L_JMP_5009_517F:

	dex
	bpl L_BRS_5005_500A
	jmp L_JMP_5182_500C

L_BRS_500F_5007:

	stx $EE
	sta $ED
	lda $3D,X
	beq L_BRS_5058_5015
	ldy $3A,X
	bne L_BRS_508F_5019
	cmp #$C0
	bcc L_BRS_5045_501D
	bne L_BRS_5040_501F
	ldy #$00
	lda $8E,X
	bmi L_BRS_5029_5025
	ldy #$02

L_BRS_5029_5025:

	sty $E0
	ldy $2E,X
	lda $2B,X
	asl
	adc $2B,X
	clc
	adc #$06
	ldx $E0
	jsr L_JSR_717B_5037
	ldx $EE
	lda #$00
	sta $2E,X

L_BRS_5040_501F:

	dec $3D,X
	jmp L_JMP_50D6_5042

L_BRS_5045_501D:

	jsr L_JSR_6200_5045
	and #$3E
	bne L_BRS_508F_504A
	dec $3D,X
	bpl L_BRS_5058_504E
	lda #$00
	sta $34,X
	lda #$20
	sta $3A,X

L_BRS_5058_5015:
L_BRS_5058_504E:

	lda $40,X
	cmp #$02
	bcc L_BRS_506F_505C
	lda $2B,X
	cmp $37,X
	bne L_BRS_506F_5062
	jsr L_JSR_6200_5064
	and #$64
	bne L_BRS_506F_5069
	lda #$81
	sta $3D,X

L_BRS_506F_505C:
L_BRS_506F_5062:
L_BRS_506F_5069:

	lda $20
	lsr
	bcc L_BRS_5078_5072
	lda $31,X
	bne L_BRS_508F_5076

L_BRS_5078_5072:

	lda $2B,X
	clc
	adc $34,X
	cmp #$35
	bne L_BRS_5085_507F
	lda #$00
	inc $40,X

L_BRS_5085_507F:

	cmp #$FF
	bne L_BRS_508D_5087
	lda #$34
	inc $40,X

L_BRS_508D_5087:

	sta $2B,X

L_BRS_508F_5019:
L_BRS_508F_504A:
L_BRS_508F_5076:

	lda $3D,X
	cmp #$C0
	bcs L_BRS_50B8_5093
	lda $3A,X
	bne L_BRS_50B8_5097
	lda $2E,X
	asl
	asl
	asl
	clc
	adc #$06
	tay
	lda $2B,X
	asl
	adc $2B,X
	sec
	sbc #$01
	tax
	lda #$09
	jsr L_JSR_0813_50AD
	beq L_BRS_50B8_50B0
	lda #$FF
	sta $3D,X
	sta $8E,X

L_BRS_50B8_5093:
L_BRS_50B8_5097:
L_BRS_50B8_50B0:

	lda $2B,X
	clc
	adc #$04
	lsr
	lsr
	sta $E0
	lda $43,X
	and #$F0
	ora $E0
	sta $43,X
	jsr L_JSR_6E38_50C9
	bne L_BRS_50D6_50CC
	ldx $EE
	lda #$FF
	sta $3D,X
	sta $8E,X

L_JMP_50D6_5042:
L_BRS_50D6_50CC:

	ldx $EE
	lda $2B,X
	sta $EC
	and #$03
	ldy $34,X
	bne L_BRS_510A_50E0
	dec $3A,X
	bne L_BRS_50FB_50E4
	lda $3D,X
	bpl L_BRS_50EE_50E8
	lda #$00
	sta $2E,X

L_BRS_50EE_50E8:

	jsr L_JSR_6200_50EE
	cmp #$80
	lda #$01
	bcc L_BRS_50F9_50F5
	lda #$FF

L_BRS_50F9_50F5:

	sta $34,X

L_BRS_50FB_50E4:

	lda $3A,X
	lsr
	and #$03
	ldy $3D,X
	bmi L_BRS_5106_5102
	eor #$03

L_BRS_5106_5102:

	ora #$08
	bpl L_BRS_5115_5108

L_BRS_510A_50E0:

	bpl L_BRS_510E_510A
	ora #$04

L_BRS_510E_510A:

	ldy $31,X
	bne L_BRS_5115_5110
	clc
	adc #$0C

L_BRS_5115_5108:
L_BRS_5115_5110:

	asl
	tay
	lda table_67BD,Y
	sta $E2
	lda table_67BD + 1,Y
	sta $E3
	ldx $ED
	lda $EC
	jsr L_JSR_6E51_5125
	lda #$00
	bit $29
	bvs L_BRS_5130_512C
	lda #$0F

L_BRS_5130_512C:

	clc
	adc $EE
	tay
	lda #$01
	sta $BF80,Y
	lda $E0
	sta $BF83,Y
	lda $E1
	sta $BF86,Y
	lda $EC
	sec
	sbc #$2F
	sta $BF8C,Y
	bcc L_BRS_5172_514B
	tax
	lda table_67E5,X
	sta v_516E
	sta $BF8C,Y
	ldy #$27
	lda $E0
	sec
	sbc #$40
	sta $E4
	lda $E1
	sbc #$01
	sta $E5

L_BRS_5166_516F:

	lda ($E2),Y
	ora ($E4),Y
	sta ($E4),Y
	dey
	cpy #$00
	bne L_BRS_5166_516F
	.byte $2C

L_BRS_5172_514B:

	ldy #$27

L_BRS_5174_517B:

	lda ($E2),Y
	ora ($E0),Y
	sta ($E0),Y
	dey
	bpl L_BRS_5174_517B
	ldx $EE
	jmp L_JMP_5009_517F

L_JMP_5182_500C:

	ldx #$0F

L_BRS_5184_5189:

	lda $7D,X
	bne L_BRS_518E_5186

L_BRS_5188_519F:
L_JMP_5188_5344:

	dex
	bpl L_BRS_5184_5189
	jmp L_JMP_5347_518B

L_BRS_518E_5186:

	stx $EE
	ldy $0630,X
	clc
	adc table_5D84,Y
	cmp #$B8
	bcc L_BRS_519D_5199
	lda #$00

L_BRS_519D_5199:

	sta $7D,X
	beq L_BRS_5188_519F
	tay
	lda $0600,X
	and #$0F
	sta $EA
	jsr L_JSR_5697_51A9
	tay
	lda #$04
	sta $0590,Y
	ldy $0630,X
	cpy #$07
	beq L_BRS_51C7_51B7
	cpy #$05
	bne L_BRS_51C4_51BB
	lda $0640,X
	cmp #$01
	beq L_BRS_51C7_51C2

L_BRS_51C4_51BB:

	jmp L_JMP_5236_51C4

L_BRS_51C7_51B7:
L_BRS_51C7_51C2:

	inc $0640,X
	lda #$FF
	sta $0630,X
	ldx $EB
	jsr L_JSR_6E39_51D1
	bne L_BRS_51F5_51D4
	ldy #$02
	cpx $23
	beq L_BRS_51E2_51DA
	dey
	cpx $22
	beq L_BRS_51E2_51DF
	dey

L_BRS_51E2_51DA:
L_BRS_51E2_51DF:

	lda $20
	sta $0024,Y
	lda #$01
	sta $0500,X
	lda $12
	bne L_BRS_51F5_51EE
	ldx #$07
	jsr L_JSR_6307_51F2

L_BRS_51F5_51D4:
L_BRS_51F5_51EE:

	ldx $EB
	lda $0510,X
	and #$10
	beq L_BRS_5201_51FC
	jsr L_JSR_7116_51FE

L_BRS_5201_51FC:

	ldx #$02

L_BRS_5203_5216:

	lda $EB
	cmp $43,X
	bne L_BRS_5215_5207
	lda $3D,X
	bne L_BRS_5215_520B
	lda #$FF
	sta $3D,X
	lda #$00
	sta $8E,X

L_BRS_5215_5207:
L_BRS_5215_520B:

	dex
	bpl L_BRS_5203_5216
	ldx #$04

L_BRS_521A_522C:

	lda $EB
	cmp $5A,X
	bne L_BRS_522A_521E
	lda $4F,X
	cmp #$E0
	bcs L_BRS_522A_5224
	lda #$E8
	sta $4F,X

L_BRS_522A_521E:
L_BRS_522A_5224:

	dex
	dex
	bpl L_BRS_521A_522C
	lda #$04
	sta FREHI2                          // Voice 2: Frequency Control - High-Byte
	jsr L_JSR_56BA_5233

L_JMP_5236_51C4:

	ldx $EE
	inc $0630,X
	lda $7D,X
	lsr
	lsr
	lsr
	sta $E6
	tax
	ldy $EA
	lda table_6E77,Y
	jsr L_JSR_6E5A_5248
	ldx #$00
	jsr L_JSR_6762_524D
	ldx #$02
	lda $E6
	cmp #$16
	bcs L_BRS_5260_5256
	ldx #$05
	cmp #$15
	bcs L_BRS_5260_525C
	ldx #$08

L_BRS_5260_5256:
L_BRS_5260_525C:

	ldy $EE
	lda $0620,Y
	and #$0F
	tay
	lda table_68AB,Y
	ora $0E

L_BRS_526D_5273:

	ldy table_6784,X
	sta ($E4),Y
	dex
	bpl L_BRS_526D_5273
	lda #$80
	sta $E2
	sta $E4
	lda #$FF
	sta $E3
	sta $E5
	lda $E6
	ldy #$02
	cmp #$16
	bcs L_BRS_5293_5287
	cmp #$15
	bcs L_BRS_528E_528B
	iny

L_BRS_528E_528B:

	ldx #$00
	jsr L_JSR_6667_5290

L_BRS_5293_5287:

	lda $EE
	bit $29
	bvs L_BRS_529B_5297
	ora #$10

L_BRS_529B_5297:

	tax
	lda #$01
	sta $BFBA,X
	lda $E0
	sta $0740,X
	lda $E1
	sta $0760,X
	lda $E2
	sta $0780,X
	lda $E3
	sta $07A0,X
	lda $E4
	sta $07C0,X
	lda $E5
	sta $07E0,X
	lda #$03
	sta $E8
	ldy $EE
	lda $007D,Y
	and #$07
	sta $E6
	lda $0630,Y
	and #$03
	tay
	ldx table_5D8C,Y

L_BRS_52D5_532C:

	lda #$0F
	sta $E7
	ldy $E6

L_BRS_52DB_52EB:

	lda ($E0),Y
	and table_5D90,X
	ora table_5CD0,X
	sta ($E0),Y
	inx
	iny
	dec $E7
	cpy #$08
	bne L_BRS_52DB_52EB
	ldy #$00

L_BRS_52EF_5301:

	lda ($E2),Y
	and table_5D90,X
	ora table_5CD0,X
	sta ($E2),Y
	inx
	iny
	dec $E7
	beq L_BRS_5315_52FD
	cpy #$08
	bne L_BRS_52EF_5301
	ldy #$00

L_BRS_5305_5313:

	lda ($E4),Y
	and table_5D90,X
	ora table_5CD0,X
	sta ($E4),Y
	inx
	iny
	dec $E7
	bne L_BRS_5305_5313

L_BRS_5315_52FD:

	stx $E9
	ldx #$00
	ldy #$01
	jsr L_JSR_61DE_531B
	ldx #$02
	jsr L_JSR_61DE_5320
	ldx #$04
	jsr L_JSR_61DE_5325
	ldx $E9
	dec $E8
	bne L_BRS_52D5_532C
	lda #$21
	ldx #$00
	ldy #$F0
	jsr L_JSR_56B0_5334
	lda #$32
	sta FREHI2                          // Voice 2: Frequency Control - High-Byte

L_BRS_533C_533D:

	inx
	bne L_BRS_533C_533D
	stx VCREG2                          // Voice 2: Control Register
	ldx $EE
	jmp L_JMP_5188_5344

L_JMP_5347_518B:

	lda #$00
	sta $02D9
	lda $20
	and #$1F
	bne L_BRS_535F_5350
	jsr L_JSR_6200_5352
	ldy $CE
	cmp table_5670,Y
	bcs L_BRS_535F_535A
	jsr L_JSR_5626_535C

L_BRS_535F_5350:
L_BRS_535F_535A:

	ldx #$02

L_BRS_5361_5366:

	lda $91,X
	bne L_BRS_536B_5363

L_JMP_5365_5406:
L_JMP_5365_55BF:

	dex
	bpl L_BRS_5361_5366
	jmp L_JMP_55C2_5368

L_BRS_536B_5363:

	stx $EE
	lda $A0,X
	beq L_BRS_5397_536F
	dec $A0,X
	ldy #$00
	cmp #$10
	bcs L_BRS_537B_5377
	ldy #$02

L_BRS_537B_5377:

	sty $E0
	jsr L_JSR_6200_537D
	and #$02
	sta $9A,X
	dec $9A,X
	jsr L_JSR_6200_5386
	lsr
	and #$3F
	sta $9D,X
	lda $20
	and #$01
	ora $E0
	jmp L_JMP_55A9_5394

L_BRS_5397_536F:

	lda $97,X
	bne L_BRS_539E_5399
	jmp L_JMP_5538_539B

L_BRS_539E_5399:

	lda $A4,X
	and #$0F
	sta $EA
	lda $AA,X
	beq L_BRS_53D2_53A6
	dec $AA,X
	bne L_BRS_53C6_53AA
	ldy #$00
	lda $91,X
	sty $91,X
	lsr
	lsr
	lsr
	tay
	iny
	ldx $EA
	lda table_6E77,X
	asl
	asl
	ldx #$00
	jsr L_JSR_717B_53C0
	jmp L_JMP_55BD_53C3

L_BRS_53C6_53AA:

	ldy #$08
	cmp #$0E
	bcs L_BRS_53CE_53CA
	ldy #$0A

L_BRS_53CE_53CA:

	tya
	jmp L_JMP_55A9_53CF

L_BRS_53D2_53A6:

	lda $AD,X
	bne L_BRS_5409_53D4
	lda $91,X
	clc
	adc $97,X
	cmp #$B4
	bcc L_BRS_5402_53DD
	lda $97,X
	cmp #$06
	bne L_BRS_53FD_53E3
	lda $A7,X
	bne L_BRS_5400_53E7
	ldy #$15
	ldx $EA
	lda table_6E77,X
	asl
	asl
	tax
	lda #$01
	jsr L_JSR_71D6_53F5
	ldx $EE
	jmp L_JMP_5400_53FA

L_BRS_53FD_53E3:

	jsr L_JSR_568A_53FD

L_BRS_5400_53E7:
L_JMP_5400_53FA:

	lda #$00

L_BRS_5402_53DD:

	sta $91,X
	bne L_BRS_5409_5404
	jmp L_JMP_5365_5406

L_BRS_5409_53D4:
L_BRS_5409_5404:

	lda $97,X
	cmp #$06
	bne L_BRS_5414_540D
	lda #$0A
	jmp L_JMP_55A9_5411

L_BRS_5414_540D:

	lda $91,X
	clc
	adc #$08
	tay
	lda $94,X
	sec
	sbc #$08
	tax
	lda #$07
	jsr L_JSR_0813_5422
	beq L_BRS_542E_5425
	jsr L_JSR_568A_5427
	lda #$18
	sta $AA,X

L_BRS_542E_5425:

	ldx $EE
	lda $91,X
	cmp $17
	bcc L_BRS_5450_5434
	lda $15
	sbc $94,X
	beq L_BRS_5440_543A
	cmp #$FE
	bcc L_BRS_5450_543E

L_BRS_5440_543A:

	jsr L_JSR_568A_5440
	lda #$06
	sta $97,X
	lda #$00
	sta $AD,X
	lda #$11
	jsr L_JSR_56BC_544D

L_BRS_5450_5434:
L_BRS_5450_543E:

	ldy $EA
	lda table_6E77,Y
	ldx #$03
	jsr L_JSR_6E5A_5457
	ldx $EE
	lda $91,X
	sec
	sbc #$14
	bcc L_BRS_5487_5461
	lsr
	tax

L_BRS_5465_5485:

	ldy #$08

L_BRS_5467_5476:

	lda ($E0),Y
	and #$F3
	ora #$0C
	sta ($E0),Y
	dex
	bmi L_BRS_5487_5470
	iny
	iny
	cpy #$10
	bne L_BRS_5467_5476
	lda $E0
	clc
	adc #$40
	sta $E0
	lda $E1
	adc #$01
	sta $E1
	bcc L_BRS_5465_5485

L_BRS_5487_5461:
L_BRS_5487_5470:

	ldx $EE
	lda $91,X
	ldy #$03

L_BRS_548D_5493:

	cmp table_5FD1,Y
	beq L_BRS_5498_5490
	dey
	bpl L_BRS_548D_5493
	jmp L_JMP_5527_5495

L_BRS_5498_5490:

	tay
	lda $EA
	jsr L_JSR_5697_549B
	jsr L_JSR_6E38_549E
	bne L_BRS_54AA_54A1
	jsr L_JSR_568A_54A3
	lda #$18
	sta $AA,X

L_BRS_54AA_54A1:

	ldx $EE
	lda $97,X
	cmp #$03
	bne L_BRS_5527_54B0
	lda $CE
	cmp #$03
	bcc L_BRS_5527_54B6
	lda #$00
	sta $E7
	ldy #$04

L_BRS_54BE_5521:

	lda $004E,Y
	beq L_BRS_551F_54C1
	lda $004F,Y
	bmi L_BRS_551F_54C6
	lda $0078,Y
	ora $0072,Y
	bne L_BRS_551F_54CE
	sty $E6
	lda $005A,Y
	tay
	lda $EB
	jsr L_JSR_7208_54D8
	beq L_BRS_551D_54DB
	ldy $E6
	lda $004F,Y
	bne L_BRS_5514_54E2
	lda $0049,Y
	lsr
	lda $0048,Y
	ror
	sec
	sbc #$0A
	cmp $94,X
	bne L_BRS_5514_54F1
	lda #$01
	sta $97,X
	txa
	clc
	adc #$01
	sta $0072,Y
	lda $004E,Y
	clc
	adc #$03
	sta $004E,Y
	lda $91,X
	clc
	adc #$06
	sta $91,X
	lda #$00
	sta $AD,X
	beq L_BRS_5527_5512

L_BRS_5514_54E2:
L_BRS_5514_54F1:

	lda $94,X
	ldy $E6
	sta $0072,Y
	inc $E7

L_BRS_551D_54DB:

	ldy $E6

L_BRS_551F_54C1:
L_BRS_551F_54C6:
L_BRS_551F_54CE:

	dey
	dey
	bpl L_BRS_54BE_5521
	lda $E7
	sta $AD,X

L_JMP_5527_5495:
L_BRS_5527_54B0:
L_BRS_5527_54B6:
L_BRS_5527_5512:

	lda #$09
	ldy $AD,X
	bne L_BRS_5535_552B
	ldy $97,X
	cpy #$01
	beq L_BRS_5535_5531
	lda #$08

L_BRS_5535_552B:
L_BRS_5535_5531:

	jmp L_JMP_55A9_5535

L_JMP_5538_539B:

	dec $9D,X
	bpl L_BRS_555A_553A
	jsr L_JSR_6200_553C
	and #$03
	cmp #$03
	bne L_BRS_5547_5543
	lda #$01

L_BRS_5547_5543:

	sec
	sbc #$01
	sta $9A,X
	tay
	jsr L_JSR_6200_554D
	and #$7F
	cpy #$00
	bne L_BRS_5558_5554
	lsr
	lsr

L_BRS_5558_5554:

	sta $9D,X

L_BRS_555A_553A:

	lda $94,X
	clc
	adc $9A,X
	bne L_BRS_5563_555F
	lda #$A0

L_BRS_5563_555F:

	cmp #$A1
	bne L_BRS_5569_5565
	lda #$01

L_BRS_5569_5565:

	sta $94,X
	lda $02D9
	bne L_BRS_55A3_556E
	ldy #$0B
	lda $94,X

L_BRS_5574_557A:

	cmp table_567A,Y
	beq L_BRS_557E_5577
	dey
	bpl L_BRS_5574_557A
	bmi L_BRS_55A3_557C

L_BRS_557E_5577:

	iny
	sty $E1
	jsr L_JSR_6200_5581
	cmp #$D4
	bcc L_BRS_55A3_5586
	ldy #$02

L_BRS_558A_5596:

	lda $0094,Y
	cmp $94,X
	bne L_BRS_5595_558F
	cpy $EE
	bne L_BRS_55A3_5593

L_BRS_5595_558F:

	dey
	bpl L_BRS_558A_5596
	lda $E1
	sta $A4,X
	lda #$03
	sta $97,X
	inc $02D9

L_BRS_55A3_556E:
L_BRS_55A3_557C:
L_BRS_55A3_5586:
L_BRS_55A3_5593:

	lda $94,X
	and #$03
	ora #$04

L_JMP_55A9_5394:
L_JMP_55A9_53CF:
L_JMP_55A9_5411:
L_JMP_55A9_5535:

	tay
	ldx $EE
	lda table_5E44 + 9,Y
	pha
	lda table_5E58,Y
	ldy table_5E44 + 6,X
	sta screensplit_LB_HB + 2,Y
	pla
	sta screensplit_LB_HB + 1,Y

L_JMP_55BD_53C3:

	ldx $EE
	jmp L_JMP_5365_55BF

L_JMP_55C2_5368:

	ldx #$02

L_BRS_55C4_55FE:

	txa
	asl
	tay
	lda $91,X
	beq L_BRS_55E3_55C9
	cmp #$0D
	bne L_BRS_55D1_55CD
	sbc #$01

L_BRS_55D1_55CD:

	clc
	adc #$32
	sta $E0
	lda $AD,X
	beq L_BRS_55E1_55D8
	lda $E0
	clc
	adc #$04
	sta $E0

L_BRS_55E1_55D8:

	lda $E0

L_BRS_55E3_55C9:

	sta SP5Y,Y                          // Sprite 5 Y Pos
	lda $94,X
	clc
	adc #$0A
	asl
	sta SP5X,Y                          // Sprite 5 X Pos
	lda MSIGX                          // Sprites 0-7 MSB of X coordinate
	and table_5E44,Y
	bcc L_BRS_55FA_55F5
	ora table_5E44 + 1,Y

L_BRS_55FA_55F5:

	sta MSIGX                          // Sprites 0-7 MSB of X coordinate
	dex
	bpl L_BRS_55C4_55FE
	lda #$85
	clc
	adc $29
	sta v_5615
	sta v_561B
	sta v_5621
	ldy #$20

screensplit_LB_HB:

	lda $F000,Y
	sta RAM8400 + $00,Y
	lda $F000,Y
	sta RAM8400 + $40,Y
	lda $F000,Y
	sta RAM8400 + $80,Y
	dey
	bpl screensplit_LB_HB
	rts

L_JSR_5626_535C:

	bit $DE
	bpl L_BRS_562D_5628
	bvc L_BRS_562D_562A
	rts

L_BRS_562D_5628:
L_BRS_562D_562A:

	ldx #$02

L_BRS_562F_5634:

	lda $91,X
	beq L_BRS_5637_5631
	dex
	bpl L_BRS_562F_5634
	rts

L_BRS_5637_5631:

	sta $97,X
	sta $A7,X
	sta $AA,X
	sta $AD,X
	lda #$1F
	sta $A0,X
	ldy $CE
	lda table_565E,Y
	sec
	sbc $A3
	sta $94,X
	lda #$0D
	sta $91,X
	jsr L_JSR_6200_5651
	and #$07
	tay
	lda table_5668,Y
	sta SP5COL,X                          // Sprite 5 Color
	rts

table_565E:
	.byte $A6,$A6,$A8,$A6,$A6,$A8,$A6,$A6
	.byte $A8,$A6
table_5668:
	.byte $01,$03,$05,$0D,$07,$04,$0E,$0A
table_5670:
	.byte $12,$50,$E0,$1C,$58,$E8
	.byte $24,$60,$F0,$F8
table_567A:
	.byte $0C,$18,$24,$30,$3C,$48,$54,$60
	.byte $6C,$78,$84,$90,$9C,$A8,$B4,$C0

L_JSR_568A_53FD:
L_JSR_568A_5427:
L_JSR_568A_5440:
L_JSR_568A_54A3:

	ldx $EE
	lda #$02
	sta $BFDA,X
	lda $EA
	sta $BFDD,X
	rts

L_JMP_5697_4FFD:
L_JSR_5697_51A9:
L_JSR_5697_549B:

	lda #$00
	cpy #$40
	bcc L_BRS_56AB_569B
	lda #$20
	cpy #$68
	bcc L_BRS_56AB_56A1
	lda #$40
	cpy #$90
	bcc L_BRS_56AB_56A7
	lda #$60

L_BRS_56AB_569B:
L_BRS_56AB_56A1:
L_BRS_56AB_56A7:

	ora $EA
	sta $EB
	rts

L_JSR_56B0_5334:
L_JSR_56B0_56C0:

	sta VCREG2                          // Voice 2: Control Register
	stx ATDCY2                          // Voice 2: Attack / Decay Cycle Control
	sty SUREL2                          // Voice 2: Sustain / Release Cycle Control
	rts

L_JSR_56BA_5233:

	lda #$81

L_JSR_56BC_544D:

	ldx #$12
	ldy #$E1
	jsr L_JSR_56B0_56C0
	ldy #$0C
	ldx #$00

L_BRS_56C7_56C8:
L_BRS_56C7_56D1:

	inx
	bne L_BRS_56C7_56C8
	inc FREHI2                          // Voice 2: Frequency Control - High-Byte
	inc FREHI2                          // Voice 2: Frequency Control - High-Byte
	dey
	bne L_BRS_56C7_56D1
	sty VCREG2                          // Voice 2: Control Register
	rts

// 56D7

	.byte $B1,$B6,$AC,$D8,$8D,$A0,$C1,$CE
	.byte $C4,$A0,$A3,$A4,$C6,$C3,$8D,$A0
	.byte $C2,$CE,$C5,$A0,$D3,$D0,$D2,$CC
	.byte $8D,$A0,$CC,$C4,$C1,$A0,$D3,$D3
	.byte $AC,$D8,$8D,$A0,$C2,$CE,$C5,$A0
	.byte $D3,$D0,$D2,$CC,$8D,$A0,$CC,$C4
	.byte $C1,$A0,$D3,$D3,$AB,$B1,$B6,$AC
	.byte $D8,$8D,$A0,$C1,$CE,$C4,$A0,$A3
	.byte $B3,$8D,$A0,$C2,$C5,$D1,$A0,$D3
	.byte $D0,$D2,$CC,$8D,$A0,$CC,$C4,$C1
	.byte $A0,$D2,$C5,$C4,$D2,$C1,$D7,$AC
	.byte $D8,$8D,$A0,$C2,$CE,$C5,$A0,$C4
	.byte $CF,$C9,$D4,$8D,$A0,$CA,$D3,$D2
	.byte $A0,$D2,$CD,$8D,$A0,$C1,$CE,$C4
	.byte $A0,$A3,$A4,$B6,$8D,$A0,$C2,$CE
	.byte $C5,$A0,$D3,$D0,$D2,$CC,$8D,$C4
	.byte $CF,$C9,$D4,$A0,$CC,$C4,$C1,$A0
	.byte $D3,$D3,$AB,$B1,$B6,$AC,$D8,$8D
	.byte $C9,$D4,$C5,$CD,$A0,$CF,$D2,$C1
	.byte $A0,$A3,$B0,$8D,$A0,$D3,$D4,$C1
	.byte $A0,$D3,$D3,$AB,$B1,$B6,$AC,$D8
	.byte $8D,$A0,$CC,$C4,$C1,$A0,$C9,$D4
	.byte $C5,$CD,$AB,$B1,$8D,$A0,$C3,$CD
	.byte $D0,$A0,$A3,$A4,$B1,$B0,$8D,$A0
	.byte $C2,$CE,$C5,$A0,$D3,$D0,$D2,$CC
	.byte $C4,$8D,$A0,$CA,$D3,$D2,$A0,$D2
	.byte $CD,$8D,$A0,$C1,$CE,$C4,$A0,$A3
	.byte $A4,$C3,$8D,$A0,$CF,$D2,$C1,$A0
	.byte $D3,$D3,$AB,$B1,$B6,$AC,$D8,$8D
	.byte $A0,$D3,$D4,$C1,$A0,$D3,$D3,$AB
	.byte $B1,$B6,$AC,$D8,$8D,$D3,$D0,$D2
	.byte $CC,$C4,$A0,$C9,$CE,$C3,$A0,$D0
	.byte $D5,$D4,$C5,$CD,$D0,$8D,$A0,$CC
	.byte $C4,$C1,$A0,$D0,$D5,$D4,$C5,$CD
	.byte $D0,$8D,$A0,$C3,$CD,$D0,$A0,$D4
	.byte $AB,$B1,$B2,$8D,$A0,$C2,$CE,$C5
	.byte $A0,$D3,$D0,$D2,$CC,$C2,$8D,$CE
	.byte $CF,$C6,$CC,$A0,$D2,$D4,$D3,$8D
	.byte $D3,$D8,$C3,$CF,$CC,$A0,$C8,$C5
	.byte $D8,$A0,$B7,$B0,$B7,$B0,$B7,$B0
	.byte $B7,$B0,$8D,$C3,$CF,$CE,$D6,$A0
	.byte $C8,$C5,$D8,$A0,$B0,$B3,$B0,$C2
	.byte $B1,$B3,$B0,$B4,$B0,$C3,$B1,$B4
	.byte $B0,$B5,$B0,$C4,$B1,$B5,$B0,$B6
	.byte $B0,$C5,$B1,$B6,$B0,$B7,$B0,$C6
	.byte $B1,$B7,$B1,$B8,$B2,$B0,$B2,$B8
	.byte $B1,$B9,$B2,$B1,$B2,$B9,$B1,$C1
	.byte $B2,$B2,$B2,$C1,$B1,$C2,$B2,$B3
	.byte $B2,$C2,$8D,$A0,$C8,$C5,$D8,$A0
	.byte $B1,$C3,$B2,$B4,$B2,$C3,$B1,$C4
	.byte $B2,$B5,$B2,$C4,$8D,$C3,$C7,$D7
	.byte $D2,$A0,$C8,$C5,$D8,$A0,$B2,$B5
	.byte $B2,$B7,$B2,$B6,$8D,$C3,$C7,$D7
	.byte $CC,$A0,$C8,$C5,$D8,$A0,$B2,$B2
	.byte $B2,$B0,$B2,$B2,$8D,$C2,$C1,$C2
	.byte $D7,$C4,$A0,$C8,$C5,$D8,$A0,$B0
	.byte $B6,$B0,$B4,$B0,$B6,$8D,$C2,$C1
	.byte $C2,$D7,$B1,$A0,$C8,$C5,$D8,$A0
	.byte $B0,$B4,$B0,$B0,$B0,$B4,$8D,$C6
	.byte $CC,$D3,$C8,$C3,$CF,$CC,$A0,$C8
	.byte $C5,$D8,$A0,$B5,$B0,$B5,$B0,$B6
	.byte $B0,$B5,$B0,$8D,$C6,$CC,$D3,$C8
	.byte $D3,$C3,$A0,$C8,$C5,$D8,$A0,$B0
	.byte $B0,$B9,$B0,$B0,$B1,$B0,$B0,$8D
	.byte $C4,$C9,$CE,$CF,$D3,$DA,$A0,$C8
	.byte $C5,$D8,$A0,$B0,$B6,$B0,$B8,$B1
	.byte $B2,$8D,$D2,$C5,$C4,$BF,$A0,$C8
	.byte $C5,$D8,$A0,$B0,$B0,$B0,$B0,$B0
	.byte $B0,$B0,$B0,$B0,$B0,$B1,$B0,$B1
	.byte $B0,$B1,$B0,$B0,$B0,$B0,$B0,$B3
	.byte $B0,$B3,$B0,$B3,$B0,$B0,$B0,$B0
	.byte $B0,$B5,$B0,$B5,$B0,$B5,$B0,$B0
	.byte $B0,$B0,$B0,$B7,$B0,$B7,$B0,$B7
	.byte $B0,$8D,$C7,$C5,$D4,$C9,$CE,$C4
	.byte $A0,$CC,$C4,$D9,$A0,$A3,$B0,$8D
	.byte $A0,$D3,$C5,$C3,$8D,$C7,$C5,$D4
	.byte $B2,$A0,$C9,$CE,$D9,$8D,$A0,$D3
	.byte $C2,$C3,$A0,$A3,$B1,$B2,$8D,$A0
	.byte $C2,$C3,$D3,$A0,$C7,$C5,$D4,$B2
	.byte $8D,$A0,$D4,$D9,$C1,$8D,$A0,$CF
	.byte $D2,$C1,$A0,$D4,$AB,$B8,$8D,$A0
	.byte $D4,$C1,$D9,$8D,$A0,$D2,$D4,$D3
	.byte $8D,$CF,$CE,$CC,$C5,$D6,$BF,$A0
	.byte $D4,$C1,$D9,$8D,$A0,$C4,$C5,$D9
	.byte $8D,$A0,$CC,$C4,$C1,$A0,$D3,$D0
	.byte $C9,$C4,$D6,$C4,$AC,$D9,$8D,$A0
	.byte $C3,$CD,$D0,$A0,$A3,$B1,$8D,$A0
	.byte $C2,$CE,$C5,$A0,$C4,$D2,$CF,$D0
	.byte $D0,$C5,$C4,$8D,$A0,$CC,$C4,$C1
	.byte $A0,$D3,$D0,$C9,$C4,$C4,$C9,$C5
	.byte $AC,$D9,$8D,$A0,$C2,$C5,$D1,$A0
	.byte $CE,$D2,$B1,$8D,$C4,$D2,$CF,$D0
	.byte $D0,$C5,$C4,$A0,$CC,$C4,$C1,$A0
	.byte $C2,$C1,$C2,$C9,$D8,$AC,$D8,$8D
	.byte $A0,$CC,$D3,$D2,$8D,$A0,$CC,$D3
	.byte $D2,$8D,$A0,$CC,$D3,$D2,$8D,$A0
	.byte $CC,$D3,$D2,$8D,$A0,$CC,$D3,$D2
	.byte $8D,$A0,$D4,$C1,$D9,$8D,$A0,$CC
	.byte $C4,$C1,$A0,$C2,$C1,$C2,$D9,$AC
	.byte $D8,$8D,$A0,$D3,$C5,$C3,$8D,$A0
	.byte $D3,$C2,$C3,$A0,$C2,$D5,$CD,$D0
	.byte $AC,$D9,$8D,$A0,$C2,$CD,$C9,$A0
	.byte $C4,$D2,$B6,$8D,$A0,$C3,$CD,$D0
	.byte $A0,$A3,$B6,$8D,$A0,$C2,$C3,$D3
	.byte $A0,$C4,$D2,$B6,$8D,$A0,$D3,$D4
	.byte $D9,$A0,$D4,$AB,$B2,$8D,$A0,$CC
	.byte $C4,$D9,$A0,$C2,$C1,$C2,$C9,$D8
	.byte $AC,$D8,$8D,$A0,$CC,$C4,$C1,$A0
	.byte $D3,$D3,$AB,$B1,$B6,$AC,$D9,$8D
	.byte $A0,$C1,$CE,$C4,$A0,$A3,$B3,$8D
	.byte $A0,$C2,$C5,$D1,$A0,$C4,$D2,$B6
	.byte $8D,$A0,$CC,$C4,$C1,$A0,$A3,$B0
	.byte $8D,$A0,$D3,$D4,$C1,$A0,$C2,$C4
	.byte $C8,$CF,$CC,$C4,$AC,$D8,$8D,$A0
	.byte $CC,$C4,$C1,$A0,$A3,$B5,$8D,$A0
	.byte $D3,$D4,$C1,$A0,$C6,$C1,$CD,$C2
	.byte $AC,$D8,$8D,$A0,$CC,$C4,$D9,$A0
	.byte $D4,$AB,$B2,$8D,$A0,$CC,$C4,$C1
	.byte $A0,$C2,$D5,$CD,$D0,$AC,$D9,$8D
	.byte $A0,$D3,$C5,$C3,$8D,$A0,$D3,$C2
	.byte $C3,$A0,$A3,$B1,$8D,$A0,$D3,$D4
	.byte $C1,$A0,$C2,$C1,$C2,$D9,$AC,$D8
	.byte $8D,$C4,$D2,$B6,$A0,$C9,$CE,$C3
	.byte $A0,$C2,$C1,$C2,$D9,$AC,$D8,$8D
	.byte $A0,$C9,$CE,$C3,$A0,$C2,$C1,$C2
	.byte $D9,$AC,$D8,$8D,$CE,$D2,$B1,$A0
	.byte $D2,$D4,$D3,$8D,$D3,$C3,$CF,$CE
	.byte $A0,$CC,$C4,$C1,$A0,$A3,$A4
table_5AD6:	
	.byte $F2
	.byte $25,$9D,$40,$11,$E9,$BD,$8B,$58
	.byte $D5,$F6,$17,$38,$73
table_5AE4:
	.byte $5A,$5B,$5C
	.byte $5C,$5C,$5B,$5B,$5B,$5B,$5E,$5E
	.byte $5F,$5F,$5C,$00,$40,$40,$00,$10
	.byte $10,$00,$10,$10,$00,$40,$40,$01
	.byte $01,$00,$01,$01,$00,$00,$40,$40
	.byte $00,$10,$10,$00,$10,$10,$00,$40
	.byte $40,$00,$00,$00,$00,$03,$00,$00
	.byte $0F,$C0,$05,$00,$30,$02,$85,$00
	.byte $0A,$85,$A0,$5A,$A0,$A5,$00,$40
	.byte $40,$01,$01,$00,$01,$01,$00,$00
	.byte $40,$40,$00,$10,$10,$00,$10,$10
	.byte $00,$40,$40,$01,$01,$00,$01,$01
	.byte $00,$00,$40,$40,$00,$00,$00,$00
	.byte $03,$00,$00,$0F,$C0,$05,$00,$30
	.byte $02,$85,$00,$0A,$85,$A0,$5A,$A0
	.byte $A5,$00,$3C,$00,$00,$FF,$00,$03
	.byte $00,$C0,$03,$14,$C0,$00,$14,$00
	.byte $00,$00,$00,$5A,$AA,$A5,$02,$AA
	.byte $80,$00,$AA,$00,$00,$55,$00,$00
	.byte $55,$00,$02,$AA,$A8,$2A,$AA,$A8
	.byte $28,$00,$08,$20,$00,$08,$20,$00
	.byte $15,$54,$00,$00,$0C,$C3,$30,$03
	.byte $FF,$C0,$03,$00,$C0,$00,$14,$00
	.byte $00,$14,$00,$00,$00,$00,$5A,$AA
	.byte $A5,$02,$AA,$80,$00,$AA,$00,$00
	.byte $55,$00,$00,$AA,$00,$00,$AA,$80
	.byte $0A,$AA,$A0,$28,$00,$20,$20,$00
	.byte $54,$54,$00,$00,$00,$00,$00,$C3
	.byte $00,$00,$C3,$00,$33,$C3,$CC,$0C
	.byte $00,$30,$00,$14,$00,$00,$14,$00
	.byte $00,$00,$00,$06,$AA,$90,$00,$AA
	.byte $00,$00,$AA,$00,$00,$AA,$00,$00
	.byte $AA,$00,$0A,$00,$A0,$00,$00,$14
	.byte $14,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$CC,$00,$00,$CC,$00,$30,$CC
	.byte $30,$CC,$30,$CC,$C3,$33,$0C,$00
	.byte $10,$00,$00,$00,$00,$08,$A8,$80
	.byte $00,$A8,$00,$00,$00,$00,$00,$00
	.byte $80,$08,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$04
	.byte $00,$00,$C4,$00,$01,$28,$00,$01
	.byte $28,$C0,$02,$28,$20,$02,$92,$20
	.byte $04,$54,$10,$04,$00,$10,$04,$38
	.byte $00,$00,$38,$00,$00,$00,$00,$00
	.byte $28,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$44
	.byte $00,$02,$C6,$80,$02,$AA,$80,$05
	.byte $29,$40,$04,$82,$60,$09,$45,$20
	.byte $09,$39,$10,$08,$38,$10,$0C,$00
	.byte $10,$00,$48,$10,$00,$3C,$00,$00
	.byte $FF,$00,$03,$00,$C0,$03,$14,$C0
	.byte $00,$14,$00,$00,$00,$00,$01,$69
	.byte $40,$01,$AA,$40,$04,$AA,$10,$00
	.byte $96,$00,$0A,$AA,$A0,$08,$00,$20
	.byte $08,$00,$20,$14,$00,$14,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$44,$00
	.byte $02,$C6,$00,$05,$2A,$80,$04,$A9
	.byte $40,$05,$43,$40,$09,$3D,$40,$09
	.byte $39,$20,$0A,$01,$20,$0A,$29,$20
	.byte $0A,$01,$20,$08,$00,$10,$00,$00
	.byte $10
table_5CD0:
	.byte $00,$03,$0D,$35,$35,$D7,$F1
	.byte $D5,$D4,$D5,$F5,$33,$35,$0F,$00
	.byte $FC,$C7,$51,$55,$15,$C7,$73,$5D
	.byte $5D,$77,$D7,$54,$75,$45,$FF,$00
	.byte $C0,$C0,$70,$30,$5C,$4C,$7C,$5C
	.byte $1C,$70,$70,$70,$C0,$00,$00,$03
	.byte $0D,$31,$3D,$D5,$D7,$D5,$C5,$D7
	.byte $31,$3D,$0D,$0C,$03,$FC,$C7,$51
	.byte $55,$77,$54,$D5,$1C,$51,$17,$CD
	.byte $75,$DC,$51,$FF,$00,$00,$C0,$C0
	.byte $30,$70,$5C,$4C,$5C,$70,$70,$30
	.byte $C0,$C0,$00,$00,$03,$0D,$35,$33
	.byte $D5,$DF,$D5,$DD,$31,$35,$0D,$0C
	.byte $03,$00,$FF,$55,$71,$5C,$45,$5C
	.byte $31,$C5,$5C,$55,$C7,$55,$DD,$53
	.byte $FF,$00,$C0,$70,$B0,$B0,$EC,$4C
	.byte $7C,$5C,$5C,$0C,$70,$70,$C0,$00
	.byte $00,$03,$0D,$0D,$31,$35,$C7,$D5
	.byte $D1,$D5,$35,$34,$35,$0D,$03,$FF
	.byte $15,$F1,$5C,$77,$D7,$55,$57,$55
	.byte $D3,$55,$55,$D5,$53,$FC,$00,$C0
	.byte $C0,$70,$70,$5C,$3C,$5C,$4C,$70
	.byte $70,$70,$C0,$00,$00
table_5D84:
	.byte $01,$02,$03
	.byte $05,$06,$07,$08,$08
table_5D8C:
	.byte $00,$2D,$5A,$87
table_5D90:
	.byte $FF,$FC,$F0,$C0,$C0,$00,$00
	.byte $00,$00,$00,$00,$C0,$C0,$F0,$FF
	.byte $03,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$FF
	.byte $3F,$3F,$0F,$0F,$03,$03,$03,$03
	.byte $03,$0F,$0F,$0F,$3F,$FF,$FF,$FC
	.byte $F0,$C0,$C0,$00,$00,$00,$00,$00
	.byte $C0,$C0,$F0,$F0,$FC,$03,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$FF,$FF,$3F,$3F
	.byte $0F,$0F,$03,$03,$03,$0F,$0F,$0F
	.byte $3F,$3F,$FF,$FF,$FC,$F0,$C0,$C0
	.byte $00,$00,$00,$00,$C0,$C0,$F0,$F0
	.byte $FC,$FF,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$FF,$3F,$0F,$03,$03,$03,$03
	.byte $03,$03,$03,$03,$0F,$0F,$0F,$FF
	.byte $FF,$FC,$F0,$F0,$C0,$C0,$00,$00
	.byte $00,$00,$C0,$C0,$C0,$F0,$FC,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$03,$FF,$3F
	.byte $3F,$0F,$0F,$03,$03,$03,$03,$0F
	.byte $0F,$0F,$3F,$FF,$FF
table_5E44:
	.byte $DF,$20,$BF
	.byte $40,$7F,$80,$00,$06,$0C,$63,$84
	.byte $A5,$C6,$E7,$08,$29,$4A,$6B,$8C
	.byte $AD
table_5E58:
	.byte $5E,$5E,$5E,$5E,$5E,$5F,$5F
	.byte $5F,$5F,$5F,$5F,$FC,$00,$00,$86
	.byte $00,$00,$02,$00,$00,$02,$00,$00
	.byte $02,$1C,$00,$02,$76,$00,$02,$C2
	.byte $00,$00,$02,$00,$00,$06,$00,$00
	.byte $04,$00,$00,$00,$00,$1C,$00,$00
	.byte $36,$00,$00,$62,$00,$00,$C2,$00
	.byte $00,$82,$1C,$00,$02,$76,$00,$02
	.byte $C2,$00,$00,$02,$00,$00,$02,$00
	.byte $00,$06,$00,$00,$04,$00,$01,$C0
	.byte $00,$61,$7C,$00,$51,$04,$00,$49
	.byte $00,$00,$45,$00,$00,$23,$7C,$00
	.byte $23,$84,$00,$10,$08,$00,$10,$08
	.byte $00,$08,$10,$00,$08,$00,$00,$01
	.byte $FC,$00,$61,$00,$00,$51,$00,$00
	.byte $49,$00,$00,$45,$00,$00,$43,$7C
	.byte $00,$43,$84,$00,$20,$08,$00,$20
	.byte $08,$00,$20,$10,$00,$20,$00,$00
	.byte $08,$22,$00,$04,$66,$00,$64,$AA
	.byte $00,$92,$B2,$00,$9A,$A2,$00,$97
	.byte $E1,$00,$13,$A1,$00,$10,$21,$00
	.byte $22,$41,$00,$20,$21,$00,$20,$21
	.byte $00,$22,$20,$00,$22,$48,$00,$52
	.byte $54,$00,$4A,$B2,$00,$47,$D1,$00
	.byte $83,$89,$00,$80,$08,$00,$82,$88
	.byte $00,$80,$08,$00,$81,$04,$00,$81
	.byte $04,$00,$04,$48,$00,$24,$54,$00
	.byte $34,$A4,$00,$5A,$84,$00,$5A,$B4
	.byte $00,$4F,$D2,$00,$4B,$92,$00,$88
	.byte $09,$00,$8A,$89,$00,$88,$09,$00
	.byte $88,$09,$00,$04,$48,$00,$04,$54
	.byte $00,$6C,$54,$00,$5A,$32,$00,$4F
	.byte $E2,$00,$4B,$A2,$00,$88,$21,$00
	.byte $92,$91,$00,$90,$11,$00,$90,$11
	.byte $00,$90,$11,$00,$30,$0C,$C0,$18
	.byte $13,$00,$CC,$1C,$00,$36,$18,$00
	.byte $18,$10,$00,$05,$E0,$00,$1D,$EF
	.byte $C0,$E4,$10,$00,$0D,$58,$00,$18
	.byte $0C,$00,$30,$06,$00,$68,$2C,$00
	.byte $5B,$B4,$00,$53,$9A,$00,$54,$54
	.byte $00,$A4,$4A,$00,$A8,$2A,$00,$A8
	.byte $2A,$00,$A0,$0A,$00,$A0,$0A,$00
	.byte $90,$12,$00,$80,$02,$00,$40,$10
	.byte $00,$44,$11,$00,$84,$21,$00,$94
	.byte $21,$00,$94,$23,$00,$D2,$23,$00
	.byte $CA,$45,$00,$C1,$91,$00,$B1,$22
	.byte $00,$4F,$84,$00,$50,$7C,$00,$20
	.byte $00,$00
table_5FD1:
	.byte $22,$49,$70,$9A,$C5,$94
	.byte $F7,$14,$77,$04,$DE,$4F,$EF,$5F
	.byte $FF,$04,$97,$01,$FD,$04,$57,$05
	.byte $B5,$04,$6D,$10,$B7,$DD,$FF,$45
	.byte $95,$05,$FE,$10,$05,$04,$FF,$04
	.byte $5C,$95,$DF,$94,$B5,$4F,$B5,$4F
	.byte $FF

table_6000:
	
	.byte $00,$14,$41,$41,$41,$41,$41,$14
	.byte $00,$04,$14,$04,$04,$04,$04,$15
	.byte $00,$14,$41,$01,$14,$40,$40,$55
	.byte $00,$54,$01,$01,$14,$01,$01,$54
	.byte $00,$04,$14,$44,$44,$55,$04,$04
	.byte $00,$55,$40,$54,$01,$01,$41,$14
	.byte $00,$05,$10,$40,$54,$41,$41,$14
	.byte $00,$55,$01,$04,$10,$10,$10,$10
	.byte $00,$14,$41,$41,$14,$41,$41,$14
	.byte $00,$14,$41,$41,$15,$01,$04,$50
	.byte $00,$00,$10,$10,$54,$10,$10,$00
	.byte $00,$00,$00,$00,$54,$00,$00,$00

table_6060:

	.byte $00,$2B,$00,$00,$00,$FF,$18,$00
	.byte $08,$00,$01,$00,$03,$00,$00,$00
	.byte $00,$00,$FF,$FF,$FF,$01,$0D,$06
	.byte $06,$0E,$0D,$0F,$01,$01,$01

IRQ_607F:

	pha
	txa
	pha
	tya
	pha
	lda $0202
	and #$01
	beq L_BRS_60A2_6089
	lda #$18
	sta SCROLX                          // Control Register 2
	lda $0203	// VIC BANK X $8000
	sta D2PRA                          // Data Port A (Serial Bus, RS232, VIC Base Mem.)
	lda #$3B
	sta SCROLY                          // Control Register 1
	lda #$EE
	sta RASTER                          // Raster Position
	bne L_BRS_60B4_60A0

L_BRS_60A2_6089:

	lda #$F7
	sta RASTER                          // Raster Position
	lda #$08
	sta SCROLX                          // Control Register 2
	lda #$95	// VIC BANK2 $8000
	sta D2PRA                          // Data Port A (Serial Bus, RS232, VIC Base Mem.)
	inc $0201

L_BRS_60B4_60A0:

	lda #$01
	sta VICIRQ                          // Interrupt Request Register (IRR)
	inc $0202
	pla
	tay
	pla
	tax
	pla
	rti

table_60C2:
	.byte $7F,$FF,$FF,$00,$00,$E0,$EF,$42
	.byte $00,$00,$00,$01,$00,$7F,$01,$01
table_60D2:
	.byte $97,$BD,$3F,$03,$AE,$BD,$01,$E6
	.byte $00,$00,$00,$11,$00,$7F,$01,$01
table_60E2:
	.byte $00,$40,$80,$C0,$00,$40,$80,$C0
	.byte $00,$40,$80,$C0,$00,$40,$80,$C0
	.byte $00,$40,$80,$C0,$00,$40,$80,$C0
	.byte $00
table_60FB:
	.byte $A0,$A1,$A2,$A3,$A5,$A6,$A7
	.byte $A8,$AA,$AB,$AC,$AD,$AF,$B0,$B1
	.byte $B2,$B4,$B5,$B6,$B7,$B9,$BA,$BB
	.byte $BC,$BE
table_6114:
	.byte $BF,$DF,$FD,$FD,$7F,$7F,$FE,$FE
table_611C:
	.byte $04,$20,$10,$04,$10,$80,$40,$08

L_JSR_6124_0902:

	ldx #$18

L_JSR_6126_3286:
L_BRS_6126_614E:

	lda table_60E2,X
	sta $E0
	sta $E2
	lda table_60FB,X
	sta $E1
	ora #$40
	sta $E3
	ldy #$00
	tya

L_BRS_6139_613E:

	sta ($E0),Y
	sta ($E2),Y
	iny
	bne L_BRS_6139_613E
	inc $E1
	inc $E3
	ldy #$3F

L_BRS_6146_614B:

	sta ($E2),Y
	sta ($E0),Y
	dey
	bpl L_BRS_6146_614B
	dex
	bpl L_BRS_6126_614E

L_JSR_6150_32FF:
L_BRS_6150_6156:
L_BRS_6150_615B:

	jsr L_JSR_6200_6150
	tay
	and #$0F
	beq L_BRS_6150_6156
	tya
	and #$F0
	beq L_BRS_6150_615B

L_JSR_615D_3298:
L_JSR_615D_34B9:

	ldx #$00

L_BRS_615F_619D:

	tya
	sta RAM8000 + $000,X
	sta RAM8000 + $100,X
	sta RAM8000 + $200,X
	sta RAMC000 + $000,X
	sta RAMC000 + $100,X
	sta RAMC000 + $200,X
	cpx #$98
	bcc L_BRS_6182_6174
	cpx #$C0
	bcc L_BRS_617F_6178
	lda table_6DC9,X
	bne L_BRS_6182_617D

L_BRS_617F_6178:

	lda table_6DF1,X

L_BRS_6182_6174:
L_BRS_6182_617D:

	sta RAM8000 + $300,X
	sta RAMC000 + $300,X
	lda #$01
	sta COLRAM + $000,X
	sta COLRAM + $100,X
	sta COLRAM + $200,X
	cpx #$98
	bcc L_BRS_6199_6195
	lda #$04

L_BRS_6199_6195:

	sta COLRAM + $300,X
	inx
	bne L_BRS_615F_619D
	rts

L_JMP_61A0_6327:

	cpx #$0B
	beq L_BRS_61BC_61A2
	ldy $04FC
	cpy #$16
	beq L_BRS_61B3_61A9
	cpy #$17
	beq L_BRS_61B3_61AD
	cpy #$1A
	bne L_BRS_61BC_61B1

L_BRS_61B3_61A9:
L_BRS_61B3_61AD:

	cpx #$1B
	beq L_BRS_61BC_61B5
	cpx #$1C
	beq L_BRS_61BC_61B9
	rts

L_BRS_61BC_61A2:
L_BRS_61BC_61B1:
L_BRS_61BC_61B5:
L_BRS_61BC_61B9:

	stx $04FC
	jmp L_JMP_6302_61BF

L_JSR_61C2_092F:
L_JSR_61C2_4049:
L_JSR_61C2_412E:
L_JSR_61C2_62C2:
L_JSR_61C2_62CB:
L_JSR_61C2_6A27:

	lda #$E0
	ldx #$00

L_JMP_61C6_61E1:
L_JSR_61C6_6BE3:

	sta v_61D5
	ora #$01
	sta v_61F2
	lda $E0,X
	clc
	adc table_61E4,Y
	sta v_61D5:$E0
	lda $E1,X
	adc table_61F2,Y
	sta v_61F2:$E1
	rts

L_JSR_61DE_0934:
L_JSR_61DE_36A7:
L_JSR_61DE_36EA:
L_JSR_61DE_36EF:
L_JSR_61DE_4134:
L_JSR_61DE_531B:
L_JSR_61DE_5320:
L_JSR_61DE_5325:
L_JSR_61DE_71CB:
L_JSR_61DE_71D0:

	txa
	ora #$E0
	jmp L_JMP_61C6_61E1

table_61E4:

	.byte $40,$08,$01,$01,$01,$01,$01,$01
	.byte $01,$39,$01,$C8,$40,$38
table_61F2:
	.byte $01,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$01,$00,$FE,$FC,$FC

L_JSR_6200_0B77:
L_JSR_6200_0C3A:
L_JSR_6200_0D70:
L_JSR_6200_0D7F:
L_JSR_6200_0D86:
L_JSR_6200_107C:
L_JSR_6200_12DC:
L_JSR_6200_15F9:
L_JSR_6200_1752:
L_JSR_6200_17CD:
L_JSR_6200_17E4:
L_JSR_6200_182C:
L_JSR_6200_1843:
L_JSR_6200_1A96:
L_JSR_6200_1AB0:
L_JSR_6200_1AD9:
L_JSR_6200_1B1F:
L_JSR_6200_1CF5:
L_JSR_6200_32E6:
L_JSR_6200_3331:
L_JSR_6200_3342:
L_JSR_6200_33A8:
L_JSR_6200_348A:
L_JSR_6200_34E6:
L_JSR_6200_34EB:
L_JSR_6200_35A3:
L_JSR_6200_35EA:
L_JSR_6200_35FC:
L_JSR_6200_3671:
L_JMP_6200_3678:
L_JSR_6200_5045:
L_JSR_6200_5064:
L_JSR_6200_50EE:
L_JSR_6200_5352:
L_JSR_6200_537D:
L_JSR_6200_5386:
L_JSR_6200_553C:
L_JSR_6200_554D:
L_JSR_6200_5581:
L_JSR_6200_5651:
L_JSR_6200_6150:
L_JSR_6200_679B:
L_JSR_6200_7141:
L_JSR_6200_7164:
L_JSR_6200_7171:
L_JSR_6200_7248:
L_JSR_6200_7C67:
L_JSR_6200_7C7D:

	lda D1T1L	// TIMALO :CIA1_Timer A Low-Byte  (Kernal-IRQ, Tape)
	adc D2T2L	// TI2BLO :CIA2_Timer B Low-Byte  (RS232)
	eor D2T1L	// TI2ALO :CIA2_Timer A Low-Byte  (RS232)
	rol $DF
	adc D1T2H	// TIMBHI :CIA1_Timer B High-Byte (Tape, Serial Port)
	eor $DF
	inc $DF
	rts

table_6213:

	.byte $0D,$2D,$4D,$6D,$B0,$F0,$30,$70
	.byte $A8,$AE,$B5,$BB
table_621F:
	.byte $00,$0B,$0A,$09
	.byte $0A,$0B,$0A,$09,$0A,$0B,$0A,$09
	.byte $0A,$0B
table_622D:
	.byte $00,$00,$01,$01,$02,$02
	.byte $03,$04,$05,$07,$09,$0B,$0B,$0B
	.byte $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
	.byte $0B,$0B,$0B,$0B,$0B,$0B
table_6249:
	.byte $1F,$47
	.byte $47,$6F,$6F,$97,$97
table_6250:
	.byte $00,$00,$05
	.byte $06,$0B,$0C,$11,$12,$17,$18,$1D
	.byte $1E,$23,$25,$28
table_625F:
	.byte $0F,$0C,$0C,$0C
	.byte $0C,$0C,$0F,$FF,$00,$00,$00,$00
	.byte $00,$FF,$FC,$0C,$0C,$0C,$0C,$0C
	.byte $FC,$00,$00,$00,$00,$00,$00,$00
table_627B:
	.byte $00,$07,$07,$07,$07,$0E,$15,$00
	.byte $07,$07,$07,$07,$07,$07,$0E,$15
	.byte $00,$07,$07,$07,$07,$07,$07,$07
	.byte $07,$07,$07,$07,$07,$07,$07,$07
	.byte $0E,$15,$00,$07,$07,$07,$07,$0E

L_JSR_62A3_6346:

	asl
	asl
	asl
	sta LOOP_62B1 + 1
	lda #$67
	rol
	sta LOOP_62B1 + 2
	ldx #$00

LOOP_62B1:

	lda $F000,X
	sta ($E0),Y
	inx
	iny
	cpx #$08
	beq L_BRS_62C9_62BA
	cpx #$04
	bne LOOP_62B1
	ldy #$00
	jsr L_JSR_61C2_62C2
	ldx #$04
	bne LOOP_62B1

L_BRS_62C9_62BA:

	ldy #$0B
	jsr L_JSR_61C2_62CB
	rts

L_JSR_62CF_1145:
L_JSR_62CF_12B8:
L_JSR_62CF_1528:
L_JSR_62CF_323A:
L_JSR_62CF_380C:
L_JMP_62CF_6F4B:

	ldx #$23
	bne L_BRS_62F4_62D1

L_JSR_62D3_13E6:
L_JSR_62D3_1B5E:
L_JSR_62D3_7083:

	ldx #$20
	lda $1D
	beq L_BRS_62F4_62D7
	bmi L_BRS_62F3_62D9

L_JSR_62DB_1349:

	and #$0F
	ora #$30
	sta v_6526
	lda $1D
	lsr
	lsr
	lsr
	lsr
	bne L_BRS_62EC_62E8
	lda #$10

L_BRS_62EC_62E8:

	eor #$30
	sta v_6525
	ldx #$21

L_BRS_62F3_62D9:

	inx

L_JSR_62F4_18D6:
L_JSR_62F4_3229:
L_JSR_62F4_3811:
L_BRS_62F4_62D1:
L_BRS_62F4_62D7:

	lda $D0
	clc
	adc #$31
	sta v_652C
	lda #$06
	sta $E8
	lda #$00

L_JMP_6302_61BF:

	ldy #$BD
	jmp LOOP_632A

L_JSR_6307_1142:
L_JSR_6307_12B5:
L_JSR_6307_1344:
L_JSR_6307_1362:
L_JSR_6307_13E3:
L_JSR_6307_1420:
L_JSR_6307_1525:
L_JSR_6307_17F2:
L_JSR_6307_1840:
L_JSR_6307_1862:
L_JSR_6307_188B:
L_JSR_6307_18F4:
L_JSR_6307_18FD:
L_JSR_6307_1A08:
L_JSR_6307_1A66:
L_JSR_6307_1A89:
L_JMP_6307_1B59:
L_JSR_6307_1C08:
L_JSR_6307_3224:
L_JSR_6307_3237:
L_JSR_6307_34CD:
L_JSR_6307_3795:
L_JSR_6307_51F2:
L_JMP_6307_6F3F:
L_JSR_6307_6F48:
L_JSR_6307_6F54:
L_JSR_6307_701A:
L_JSR_6307_7061:

	lda $20
	sbc #$40
	sta $0200
	lda $CE
	ora #$30
	sta v_6496
	clc
	adc #$01
	cmp #$39
	bcc L_BRS_631E_631A
	lda #$39

L_BRS_631E_631A:

	sta v_64DC
	lda #$0F
	sta $E8
	lda #$48
	jmp L_JMP_61A0_6327

LOOP_632A:

	sta $E0
	sty $E1
	lda table_6352,X
	sta v_6341
	lda table_6377,X
	sta v_6341 + 1
	ldx #$00
	stx $E9

L_BRS_633E_634F:

	ldy #$04
	lda v_6341:$F000,X
	inx
	and #$3F
	jsr L_JSR_62A3_6346
	inc $E9
	ldx $E9
	cpx $E8
	bne L_BRS_633E_634F
	rts

table_6352:

	.byte $00,$9C,$A8,$B5,$C3,$D1,$DF,$ED
	.byte $FC,$0B,$1A,$28,$36,$44,$51,$5F
	.byte $6D,$7B,$7B,$89,$98,$A7,$B6,$C4
	.byte $D0,$DD,$EB,$F8,$06,$FA,$09,$00
	.byte $15,$1B,$21,$27,$2D
table_6377:
	.byte $00,$63,$63
	.byte $63,$63,$63,$63,$63,$63,$64,$64
	.byte $64,$64,$64,$64,$64,$64,$00,$64
	.byte $64,$64,$64,$64,$64,$64,$64,$64
	.byte $64,$65,$6E,$6F,$00,$65,$65,$65
	.byte $65,$65,$A0,$A0,$A0,$C8,$C1,$D3
	.byte $A0,$D0,$CF,$D7,$C5,$D2,$A0,$A0
	.byte $A0,$D0,$CF,$D7,$C5,$D2,$A0,$C7
	.byte $C1,$C9,$CE,$A0,$A0,$A0,$D0,$CF
	.byte $D7,$C5,$D2,$A0,$CC,$CF,$D3,$D4
	.byte $A0,$A0,$C3,$CF,$CE,$D4,$C1,$CD
	.byte $C9,$CE,$C1,$D4,$C9,$CF,$CE,$A0
	.byte $A0,$D7,$C1,$D4,$C3,$C8,$A0,$C3
	.byte $CC,$CF,$C3,$CB,$A1,$A0,$A0,$C6
	.byte $C9,$D2,$C5,$A0,$D3,$D4,$C1,$D2
	.byte $D4,$C5,$C4,$A0,$C6,$C9,$D2,$C5
	.byte $A0,$C7,$CF,$C9,$CE,$C7,$A0,$CF
	.byte $D5,$D4,$C4,$C9,$CE,$CF,$A0,$CD
	.byte $CF,$CD,$A0,$C3,$CF,$CD,$C9,$CE
	.byte $C7,$C4,$C9,$CE,$CF,$A0,$CD,$CF
	.byte $CD,$A0,$C1,$D4,$D4,$C1,$C3,$CB
	.byte $A0,$C6,$C9,$D2,$C5,$A0,$C5,$D8
	.byte $D4,$C5,$CE,$C4,$C5,$C4,$A0,$A0
	.byte $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
	.byte $A0,$A0,$A0,$A0,$A0,$C5,$C7,$C7
	.byte $D3,$A0,$D0,$CF,$C9,$D3,$CF,$CE
	.byte $C5,$C4,$A0,$A0,$D7,$C1,$D2,$D0
	.byte $C9,$CE,$C7,$A0,$CF,$D5,$D4,$A0
	.byte $A0,$D7,$C1,$D2,$D0,$C9,$CE,$C7
	.byte $A0,$C9,$CE,$A0,$A0,$A0,$C4,$C9
	.byte $CE,$CF,$A0,$C8,$C1,$D4,$C3,$C8
	.byte $C9,$CE,$C7,$A0,$A0,$C4,$C9,$CE
	.byte $CF,$A0,$C3,$C1,$C7,$C5,$C4,$A0
	.byte $A0,$A0,$CC,$C5,$C1,$D6,$C5,$A0
	.byte $C3,$CC,$C9,$C6,$C6,$BF,$A0,$A0
	.byte $D3,$CB,$C9,$CC,$CC,$A0,$CC,$C5
	.byte $D6,$C5,$CC,$A0
v_6496:
	.byte $B1,$A0,$C1,$C2
	.byte $C1,$CE,$C4,$CF,$CE,$C5,$C4,$A0
	.byte $C3,$CC,$C9,$C6,$C6,$C2,$CF,$CE
	.byte $D5,$D3,$A0
v_64AD:
	.byte $B1,$B0,$A0,$D0,$CF
	.byte $C9,$CE,$D4,$D3,$C2,$D5,$D2,$CE
	.byte $D4,$A0,$D4,$CF,$A0,$C4,$C5,$C1
	.byte $D4,$C8,$A0,$A0,$A0,$D3,$CD,$C1
	.byte $D3,$C8,$C5,$C4,$A1,$A0,$A0,$A0
	.byte $A0,$D4,$CF,$A0,$CC,$C5,$D6,$C5
	.byte $CC,$A0
v_64DC:
	.byte $B1,$A0,$A0,$D3,$D4,$C1
	.byte $D2,$D4,$A0,$C1,$A0,$C6,$C9,$D2
	.byte $C5,$A0,$A0,$C4,$C5,$D6,$CF,$CC
	.byte $D5,$D4,$C9,$CF,$CE,$A0,$A0,$A0
	.byte $C5,$CE,$C4,$A0,$CF,$C6,$A0,$C7
	.byte $C1,$CD,$C5,$A0,$A0,$C2,$C5,$C7
	.byte $C9,$CE,$CE,$C9,$CE,$C7,$A0,$C7
	.byte $C1,$CD,$C5,$A0,$A0,$AD,$AD,$A0
	.byte $A0,$AD,$D7,$CF,$CF,$C4,$AD,$C5
	.byte $C7,$C7,$D3
table_6525:
	.byte $A0,$A0,$CC,$C9,$C6,$C5,$A0
table_652C:
	.byte $A0,$00,$00,$00,$00

L_JSR_6531_0EE2:
L_JSR_6531_18EF:

	sed
	eor $D1
	bpl L_BRS_655D_6534
	and #$7F
	sta $F6
	lda $D2
	sec
	sbc $F6
	sta $D2
	lda $D3
	sbc #$00
	sta $D3
	bcs L_BRS_656A_6547
	lda $D1
	eor #$80
	sta $D1
	lda #$00
	sec
	sbc $D2
	sta $D2
	lda #$00
	sbc $D3
	jmp L_JMP_6568_655A

L_BRS_655D_6534:

	and #$7F
	clc
	adc $D2
	sta $D2
	lda $D3
	adc #$00

L_JMP_6568_655A:

	sta $D3

L_JSR_656A_0984:
L_BRS_656A_6547:

	cld
	ldx #$01
	.byte $2C

L_JSR_656E_1A3A:
L_JSR_656E_34C4:
L_JSR_656E_37FF:

	ldx #$03

L_JSR_6570_322E:

	ldy #$00
	lda #$20
	sta $F6
	lda #$02
	sta $F7

L_BRS_657A_658B:

	lda $D2,X
	pha
	lsr
	lsr
	lsr
	lsr
	jsr L_JSR_65B4_6581
	pla
	jsr L_JSR_65B4_6585
	dex
	dec $F7
	bne L_BRS_657A_658B
	lda v_6530
	cmp #$20
	bne L_BRS_6599_6592
	lda #$30
	sta v_6530

L_BRS_6599_6592:

	inx
	lda table_6F0F,X
	ldy table_6F0F + 1,X
	cpx #$02
	bne L_BRS_65A9_65A2
	ldx #$25
	stx v_6530

L_BRS_65A9_65A2:

	ldx #$04
	stx $E8
	ldx #$24
	jmp LOOP_632A
	.byte $00,$00                 // unknown so far

L_JSR_65B4_6581:
L_JSR_65B4_6585:

	and #$0F
	bne L_BRS_65BD_65B6
	lda $F6
	jmp L_JMP_65D9_65BA

L_BRS_65BD_65B6:

	clc
	adc #$30
	pha
	lda $F6
	cmp #$30
	beq L_BRS_65D4_65C5
	cpx #$02
	bcs L_BRS_65D4_65C9
	lda $D1
	bpl L_BRS_65D4_65CD
	lda #$2D
	sta table_652C,Y

L_BRS_65D4_65C5:
L_BRS_65D4_65C9:
L_BRS_65D4_65CD:

	lda #$30
	sta $F6
	pla

L_JMP_65D9_65BA:

	sta table_652C + 1,Y
	iny
	rts

table_65DE:

	.byte $00,$33,$FF,$66,$32,$99,$65,$CC
	.byte $98,$CB,$FE,$31,$64,$97,$62,$95
	.byte $C8,$FB,$2E,$61,$94,$C7,$B2
table_65F5:
	.byte $86,$86,$86,$86,$87,$86,$87,$86
	.byte $87,$87,$87,$88,$88,$88,$93,$93
	.byte $93,$93,$94,$94,$94,$94,$8B

L_JSR_660C_08A5:
L_JSR_660C_32BA:
L_JSR_660C_7245:
L_JSR_660C_72A1:
L_JSR_660C_72AA:

	sta FOO
	sta DOO
	stx FOO + 1
	stx DOO + 1
	ldx #$00
	stx $E0
	sty $E1
	ldy #$00

L_BRS_6620_6651:
L_BRS_6620_6658:
L_BRS_6620_665C:

	lda FOO:$F000,X
	inx
	bne L_BRS_662C_6624
	inc FOO+1
	inc DOO+1

L_BRS_662C_6624:

	eor #$D8
	cmp #$02
	beq L_BRS_665E_6630
	bcs L_BRS_6653_6632
	sbc #$00
	pha
	lda DOO:$F000,X
	inx
	bne L_BRS_6643_663B
	inc FOO+1
	inc DOO+1

L_BRS_6643_663B:

	sta $E2
	pla

L_BRS_6646_664F:

	sta ($E0),Y
	iny
	bne L_BRS_664D_6649
	inc $E1

L_BRS_664D_6649:

	dec $E2
	bne L_BRS_6646_664F
	beq L_BRS_6620_6651

L_BRS_6653_6632:

	eor #$D8
	sta ($E0),Y
	iny
	bne L_BRS_6620_6658
	inc $E1
	bne L_BRS_6620_665C

L_BRS_665E_6630:

	rts

L_JSR_665F_09D4:
L_JSR_665F_0DD1:
L_JSR_665F_0E45:
L_JSR_665F_0F31:

	sta $E0
	sty $E1
	ldx #$00
	ldy #$02

L_JSR_6667_5290:
L_JSR_6667_6AF0:
L_JSR_6667_6BEA:

	dey

L_BRS_6668_6678:

	lda $E0,X
	clc
	adc #$40
	sta $E2,X
	lda $E1,X
	adc #$01
	sta $E3,X
	inx
	inx
	dey
	bne L_BRS_6668_6678
	rts

table_667B:
	.byte $6A,$8B,$B2,$8B,$FA,$8B,$42,$8C
	.byte $8A,$8C,$D2,$8C,$1A,$8D,$62,$8D
	.byte $AA,$8D,$F2,$8D,$3A,$8E,$82,$8E
	.byte $CA,$8E,$12,$8F,$5A,$8F,$A2,$8F
	.byte $1A,$90,$92,$90,$0A,$91,$82,$91
	.byte $FA,$91,$72,$92,$EA,$92
table_66A9:
	.byte $82,$8B,$CA,$8B,$12,$8C,$5A,$8C
	.byte $A2,$8C,$EA,$8C,$32,$8D,$7A,$8D
	.byte $C2,$8D,$0A,$8E,$52,$8E,$9A,$8E
	.byte $E2,$8E,$2A,$8F,$72,$8F,$CA,$8F
	.byte $42,$90,$BA,$90,$32,$91,$AA,$91
	.byte $22,$92,$9A,$92,$12,$93
table_66D7:
	.byte $9A,$8B,$E2,$8B,$2A,$8C,$72,$8C
	.byte $BA,$8C,$02,$8D,$4A,$8D,$92,$8D
	.byte $DA,$8D,$22,$8E,$6A,$8E,$B2,$8E
	.byte $FA,$8E,$42,$8F,$8A,$8F,$F2,$8F
	.byte $6A,$90,$E2,$90,$5A,$91,$D2,$91
	.byte $4A,$92,$C2,$92,$3A,$93
table_6705:
	.byte $04,$02
table_6707:
	.byte $00,$00
	.byte $06,$0E,$16,$16,$0E,$0E
	.byte $06

L_BRS_6710_671B:

	lda $8972,Y
	sta ($E0),Y
	lda $89BA,Y
	sta ($E2),Y
	dey
	bpl L_BRS_6710_671B
	jmp L_JMP_6AC0_671D

L_BRS_6720_672B:

	lda $898A,Y
	sta ($E0),Y
	lda $89BA,Y
	sta ($E2),Y
	dey
	bpl L_BRS_6720_672B
	jmp L_JMP_6AC0_672D

L_BRS_6730_673B:

	lda $89A2,Y
	sta ($E0),Y
	lda $89BA,Y
	sta ($E2),Y
	dey
	bpl L_BRS_6730_673B
	jmp L_JMP_6AC0_673D

L_BRS_6740_674B:

	lda $8972,Y
	sta ($E0),Y
	lda $89D2,Y
	sta ($E2),Y
	dey
	bpl L_BRS_6740_674B
	jmp L_JMP_6AC0_674D

table_6750:

	.byte $00,$00,$00,$08,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $A2,$00// or ldx #$00

L_JSR_6762_0A26:
L_JSR_6762_0E03:
L_JSR_6762_0E8C:
L_JSR_6762_0F4F:
L_JSR_6762_1C2B:
L_JSR_6762_402B:
L_JSR_6762_524D:
L_JSR_6762_6B50:
L_JSR_6762_6C03:
L_JSR_6762_6CE4:

	lda $E0,X
	sta $E4
	lda $E1,X
	and #$1F
	lsr
	ror $E4
	lsr
	ror $E4
	lsr
	ror $E4
	ora #$80
	ora $29
	sta $E5
	ldx $EA
	lda $20
	and #$07
	tay
	lda table_6793,Y
	rts

table_6784:

	.byte $00,$01,$02,$28,$29,$2A,$50,$51
	.byte $52,$03,$04,$2B,$2C,$53,$54
table_6793:
	.byte $20,$80,$D0,$60,$70,$50,$40,$90

L_JSR_679B_108F:
L_JSR_679B_1777:
L_JSR_679B_1ABB:
L_JSR_679B_333C:
L_JSR_679B_33BA:
L_JSR_679B_35D3:
L_BRS_679B_67A2:
L_JSR_679B_7C45:

	jsr L_JSR_6200_679B
	and #$0F
	cmp #$0C
	bcs L_BRS_679B_67A2
	adc #$01
	rts

table_67A7:

	.byte $00,$40,$95,$94
table_67AB:
	.byte $12,$50,$D0,$22
	.byte $60,$E8,$28,$70,$F0,$F8
table_67B5:
	.byte $05,$0A,$0F,$14
table_67B9:
	.byte $00,$20,$40,$60
table_67BD:
	.byte $FA,$94,$22,$95

	.byte $4A,$95,$72,$95,$9A,$95
	.byte $C2,$95,$EA,$95,$12,$96,$3A,$96
	.byte $62,$96,$8A,$96,$B2,$96,$DA,$96
	.byte $02,$97,$2A,$97,$52,$97,$7A,$97
	.byte $A2,$97,$CA,$97,$F2,$97
table_67E5:
	.byte $1F,$1F,$17,$0F,$07,$07
table_67EB:
	.byte $AA,$BA,$AB,$8D
	.byte $35,$35,$D7,$F1,$AA,$FC,$C7,$51
	.byte $55,$15,$C7,$73,$AA,$8A,$EA,$E8
	.byte $70,$30,$5C,$4C,$AA,$CA,$8B,$AD
	.byte $2D,$31,$35,$C7,$AA,$FF,$15,$F1
	.byte $5C,$77,$D7,$55,$EA,$AB,$EA,$EB
	.byte $70,$70,$5C,$3C,$AA,$AA,$A3,$2D
	.byte $35,$33,$D5,$DF,$AA,$FF,$55,$71
	.byte $5C,$45,$5C,$31,$AA,$8A,$EB,$70
	.byte $5C,$4C,$E7,$47,$AA,$AB,$AC,$AD
	.byte $31,$3D,$D5,$D7,$AA,$FC,$C7,$51
	.byte $55,$77,$54,$D5,$AA,$AE,$BB,$E2
	.byte $C0,$30,$70,$5C
table_684B:
	.byte $D5,$D4,$D5,$F5,$33,$35,$0F,$00
	.byte $5D,$5D,$77,$D7,$54,$75,$45,$FF
	.byte $7C,$5C,$1C,$70,$70,$70,$C0,$00
	.byte $D5,$D1,$D5,$35,$34,$35,$0D,$03
	.byte $57,$55,$D3,$55,$55,$D5,$53,$FC
	.byte $5C,$4C,$70,$70,$70,$C0,$00,$00
	.byte $D5,$DD,$31,$35,$0D,$0C,$03,$00
	.byte $C5,$5C,$55,$C7,$55,$DD,$53,$FF
	.byte $77,$57,$5C,$0C,$70,$70,$C0,$00
	.byte $D5,$C5,$D7,$31,$3D,$0D,$0C,$03
	.byte $1C,$51,$17,$CD,$75,$DC,$51,$FF
	.byte $4C,$5C,$70,$70,$30,$C0,$C0,$00
table_68AB:
	.byte $20,$30,$40,$50,$60,$70,$80,$90
	.byte $A0,$B0,$C0,$D0,$E0,$F0,$50,$60
table_68BB:
	.byte $FB,$04,$F7,$08,$EF,$10
table_68C1:
	.byte $1A,$98,$38,$98,$56,$98,$74,$98
	.byte $92,$98,$B0,$98,$CE,$98,$EC,$98
	.byte $0A,$99,$28,$99,$46,$99,$64,$99
	.byte $82,$99,$A0,$99,$BE,$99,$A0,$99
	.byte $DC,$99,$FA,$99,$18,$9A,$FA,$99
	.byte $36,$9A,$54,$9A,$72,$9A,$54,$9A
	.byte $90,$9A,$AE,$9A,$CC,$9A,$AE,$9A
	.byte $EA,$9A,$08,$9B,$26,$9B,$44,$9B
	.byte $62,$9B,$80,$9B,$9E,$9B,$BC,$9B
	.byte $DA,$9B,$F8,$9B,$16,$9C,$34,$9C
	.byte $52,$9C,$70,$9C,$8E,$9C,$BC,$9E
	.byte $DA,$9E,$F8,$9E,$16,$9F,$34,$9F
	.byte $52,$9F,$B2,$8B,$B2,$8B
table_6927:	
	.byte $01,$00,$0A,$00,$13,$00

L_JSR_692D_0A83:

	lda #$02
	sta $EF
	tax
	bit $29
	bvs L_BRS_6938_6934
	ldx #$11

L_BRS_6938_6934:
L_BRS_6938_6974:

	lda $BF80,X
	beq L_BRS_6971_693B
	dec $BF80,X
	lda $BF83,X
	sta $E0
	lda $BF86,X
	sta $E1
	ldy #$27
	lda $BF8C,X
	bmi L_BRS_696A_694F
	sta v_6967
	lda $E0
	sec
	sbc #$40
	sta $E2
	lda $E1
	sbc #$01
	sta $E3
	lda #$00

L_BRS_6963_6968:

	sta ($E2),Y
	dey
	cpy v_6967:#$00
	bne L_BRS_6963_6968

L_BRS_696A_694F:

	lda #$00

L_BRS_696C_696F:

	sta ($E0),Y
	dey
	bpl L_BRS_696C_696F

L_BRS_6971_693B:

	dex
	dec $EF
	bpl L_BRS_6938_6974
	lda #$0F
	sta $EF
	tax
	bit $29
	bvs L_BRS_6981_697D
	ldx #$1F

L_BRS_6981_697D:
L_BRS_6981_69B7:

	lda $BFBA,X
	beq L_BRS_69B4_6984
	dec $BFBA,X
	lda $0740,X
	ldy $0760,X
	sta $E0
	sty $E1
	lda $0780,X
	ldy $07A0,X
	sta $E2
	sty $E3
	lda $07C0,X
	ldy $07E0,X
	sta $E4
	sty $E5
	ldy #$17
	lda #$00

L_BRS_69AB_69B2:

	sta ($E0),Y
	sta ($E2),Y
	sta ($E4),Y
	dey
	bpl L_BRS_69AB_69B2

L_BRS_69B4_6984:

	dex
	dec $EF
	bpl L_BRS_6981_69B7
	ldx #$0C

L_BRS_69BB_69EA:

	lda $BFAC,X
	beq L_BRS_69E8_69BE
	dec $BFAC,X
	lda $BF9F,X
	eor #$40
	sta $BF9F,X
	tay
	lda $BF9E,X
	sta $E0
	sty $E1
	clc
	adc #$40
	sta $E2
	tya
	adc #$01
	sta $E3
	lda #$00
	ldy #$17

L_BRS_69E1_69E6:

	sta ($E0),Y
	sta ($E2),Y
	dey
	bpl L_BRS_69E1_69E6

L_BRS_69E8_69BE:

	dex
	dex
	bpl L_BRS_69BB_69EA
	ldx #$02

L_BRS_69EE_6A30:

	lda $BFDA,X
	beq L_BRS_6A2F_69F1
	dec $BFDA,X
	stx $EE
	ldy $BFDD,X
	lda #$04
	sta $0590,Y
	sta $05B0,Y
	sta $05D0,Y
	sta $05F0,Y
	lda table_6E77,Y
	ldx #$03
	jsr L_JSR_6E5A_6A0E
	lda #$14
	sta $E2

L_JMP_6A15_6A2A:

	ldy #$08
	lda #$00

L_BRS_6A19_6A1F:

	sta ($E0),Y
	iny
	iny
	cpy #$10
	bne L_BRS_6A19_6A1F
	dec $E2
	beq L_BRS_6A2D_6A23
	ldy #$00
	jsr L_JSR_61C2_6A27
	jmp L_JMP_6A15_6A2A

L_BRS_6A2D_6A23:

	ldx $EE

L_BRS_6A2F_69F1:

	dex
	bpl L_BRS_69EE_6A30
	ldy #$02

L_BRS_6A34_6A3D:

	ldx $020A,Y
	lda #$04
	sta $0580,X
	dey
	bpl L_BRS_6A34_6A3D
	lda $BF89
	beq L_BRS_6A7A_6A42
	dec $BF89
	lda $BF8B
	eor #$40
	sta $BF8B
	tay
	lda $BF8A
	sta $E0
	sty $E1
	clc
	adc #$40
	sta $E2
	iny
	bcc L_BRS_6A61_6A5D
	iny
	clc

L_BRS_6A61_6A5D:

	sty $E3
	adc #$40
	sta $E4
	iny
	bcc L_BRS_6A6B_6A68
	iny

L_BRS_6A6B_6A68:

	sty $E5
	lda #$00
	ldy #$27

L_BRS_6A71_6A78:

	sta ($E0),Y
	sta ($E2),Y
	sta ($E4),Y
	dey
	bpl L_BRS_6A71_6A78

L_BRS_6A7A_6A42:

	ldy #$03

L_BRS_6A7C_6ACB:

	sty $EF
	ldx table_6213,Y

L_BRS_6A81_6AC6:

	lda $0590,X
	beq L_BRS_6AC0_6A84
	dec $0590,X
	ldy $0510,X
	lda table_6D92,Y
	pha
	lda table_6D0E,Y
	pha
	stx $EA
	lda table_7E5A,X
	eor $29
	tay
	lda table_7E4A,X
	sta $E0
	sty $E1
	clc
	adc #$40
	sta $E2
	tya
	adc #$01
	sta $E3
	ldy #$17
	ldx $EA
	txa
	and #$0F
	beq L_BRS_6ABB_6AB4
	cmp #$0D
	beq L_BRS_6ABB_6AB8
	rts

L_BRS_6ABB_6AB4:
L_BRS_6ABB_6AB8:

	pla
	pla
	jmp L_JMP_6F15_6ABD

L_JMP_6AC0_671D:
L_JMP_6AC0_672D:
L_JMP_6AC0_673D:
L_JMP_6AC0_674D:
L_BRS_6AC0_6A84:
L_JMP_6AC0_6C1A:
L_JMP_6AC0_6C2E:
L_JMP_6AC0_6C3E:
L_JMP_6AC0_6C52:
L_JMP_6AC0_6C62:
L_JMP_6AC0_6CC3:
L_JMP_6AC0_6CFF:
L_JMP_6AC0_6D0B:
L_JMP_6AC0_6D5C:
L_JMP_6AC0_6D6B:
L_JMP_6AC0_6D7A:
L_JMP_6AC0_6D89:
L_JMP_6AC0_6DE1:
L_JMP_6AC0_6DF1:
L_JMP_6AC0_6E00:
L_JMP_6AC0_6E0F:
L_JMP_6AC0_6F28:
L_JMP_6AC0_7D73:
L_JMP_6AC0_7D87:
L_JMP_6AC0_7D97:

	dex
	txa
	and #$0F
	cmp #$0F
	bne L_BRS_6A81_6AC6
	ldy $EF
	dey
	bpl L_BRS_6A7C_6ACB
	lda $28
	bne L_BRS_6AD4_6ACF
	jmp L_JMP_6B5F_6AD1

L_BRS_6AD4_6ACF:

	and #$0F
	tay
	lda $28
	lsr
	lsr
	lsr
	lsr
	lsr
	tax
	lda table_6E85,X
	tax
	lda table_6E77,Y
	sec
	sbc #$01
	jsr L_JSR_6E5A_6AE9
	ldx #$00
	ldy #$03
	jsr L_JSR_6667_6AF0
	lda $E0
	sta $BF8A
	lda $E1
	sta $BF8B
	lda #$02
	sta $BF89
	lda $20
	and #$07
	asl
	adc #$1E
	tax
	lda table_667B,X
	sta v_6b31
	lda table_667B + 1,X
	sta v_6b31 + 1
	lda table_66A9,X
	sta v_6B3A
	lda table_66A9 + 1,X
	sta v_6B3A + 1
	lda table_66D7,X
	sta v_6B43
	lda table_66D7 + 1,X
	sta v_6B43 + 1
	ldy #$27

L_BRS_6B30_6B4C:

	lda v_6b31:$F000,Y
	beq L_BRS_6B39_6B33
	ora ($E0),Y
	sta ($E0),Y

L_BRS_6B39_6B33:

	lda v_6B3A:$F000,Y
	beq L_BRS_6B42_6B3C
	ora ($E2),Y
	sta ($E2),Y

L_BRS_6B42_6B3C:

	lda v_6B43:$F000,Y
	beq L_BRS_6B4B_6B45
	ora ($E4),Y
	sta ($E4),Y

L_BRS_6B4B_6B45:

	dey
	bpl L_BRS_6B30_6B4C
	ldx #$00
	jsr L_JSR_6762_6B50
	ora $0E
	ldx #$0E

L_BRS_6B57_6B5D:

	ldy table_6784,X
	sta ($E4),Y
	dex
	bpl L_BRS_6B57_6B5D

L_JMP_6B5F_6AD1:

	rts

L_BRS_6B60_6B6B:

	lda $8A7A,Y
	sta ($E0),Y
	lda $8A92,Y
	sta ($E2),Y
	dey
	bpl L_BRS_6B60_6B6B
	lda $0500,X
	bne L_BRS_6B88_6B70
	lda $0590,X
	bne L_BRS_6B84_6B75
	lda $0510,X
	and #$03
	sta $0510,X
	lda #$04
	sta $0590,X

L_BRS_6B84_6B75:

	lda #$02
	bpl L_BRS_6BB8_6B86

L_BRS_6B88_6B70:

	pha
	asl
	asl
	asl
	tax
	ldy #$08

L_BRS_6B8F_6B98:

	lda table_6000,X
	sta ($E2),Y
	iny
	inx
	cpy #$10
	bne L_BRS_6B8F_6B98
	pla
	cmp #$01
	beq L_BRS_6BA3_6B9D
	cmp #$09
	bne L_BRS_6BAF_6BA1

L_BRS_6BA3_6B9D:

	lda $20
	lsr
	lsr
	and #$03
	tay
	lda table_6705,Y
	bpl L_BRS_6BB8_6BAD

L_BRS_6BAF_6BA1:

	tay
	lda $20
	and #$06
	clc
	adc table_6707,Y

L_BRS_6BB8_6B86:
L_BRS_6BB8_6BAD:

	tax
	lda table_667B,X
	sta v_6BF0
	lda table_667B + 1,X
	sta v_6BF0 + 1
	lda table_66A9,X
	sta v_6BF5
	lda table_66A9 + 1,X
	sta v_6BF5 + 1
	lda table_66D7,X
	sta v_6BFA
	lda table_66D7 + 1,X
	sta v_6BFA + 1
	ldy #$0C
	lda #$E4
	ldx #$00
	jsr L_JSR_61C6_6BE3
	ldx #$04
	ldy #$03
	jsr L_JSR_6667_6BEA
	ldy #$17

L_BRS_6BEF_6BFF:

	lda v_6BF0:$F000,Y
	sta ($E4),Y
	lda v_6BF5:$F000,Y
	sta ($E6),Y
	lda v_6BFA:$F000,Y
	sta ($E8),Y
	dey
	bpl L_BRS_6BEF_6BFF
	ldx #$04
	jsr L_JSR_6762_6C03
	ora $0E
	ldx #$08

L_BRS_6C0A_6C10:

	ldy table_6784,X
	sta ($E4),Y
	dex
	bpl L_BRS_6C0A_6C10
	ldy #$A1
	lda #$72
	sta ($E4),Y
	ldx $EA
	jmp L_JMP_6AC0_6C1A
	txa
	lsr
	bcc L_BRS_6C31_6C1F

L_BRS_6C21_6C2C:

	lda $8AC2,Y
	sta ($E0),Y
	lda $8B3A,Y
	sta ($E2),Y
	dey
	bpl L_BRS_6C21_6C2C
	jmp L_JMP_6AC0_6C2E

L_BRS_6C31_6C1F:
L_BRS_6C31_6C3C:

	lda $8B0A,Y
	sta ($E0),Y
	lda $8B52,Y
	sta ($E2),Y
	dey
	bpl L_BRS_6C31_6C3C
	jmp L_JMP_6AC0_6C3E
	txa
	lsr
	bcc L_BRS_6C55_6C43

L_BRS_6C45_6C50:

	lda $8AAA,Y
	sta ($E0),Y
	lda $8B3A,Y
	sta ($E2),Y
	dey
	bpl L_BRS_6C45_6C50
	jmp L_JMP_6AC0_6C52

L_BRS_6C55_6C43:
L_BRS_6C55_6C60:

	lda $8AF2,Y
	sta ($E0),Y
	lda $8B52,Y
	sta ($E2),Y
	dey
	bpl L_BRS_6C55_6C60
	jmp L_JMP_6AC0_6C62
	lda $E0
	ldy $E1
	sta v_6CA6
	sty v_6CA6 + 1
	lda $E2
	ldy $E3
	sta v_6CAC
	sty v_6CAC + 1
	clc
	adc #$40
	iny
	bcc L_BRS_6C81_6C7D
	iny
	clc

L_BRS_6C81_6C7D:

	sta v_6CB2
	sty v_6CB2 + 1
	adc #$40
	iny
	bcc L_BRS_6C8E_6C8A
	iny
	clc

L_BRS_6C8E_6C8A:

	sta v_6CB8
	sty v_6CB8 + 1
	adc #$40
	iny
	bcc L_BRS_6C9A_6C97
	iny

L_BRS_6C9A_6C97:

	sta v_6CBE
	sty v_6CBE + 1
	ldy #$17

L_BRS_6CA2_6CC1:

	lda $88FA,Y
	sta v_6CA6:$F000,Y
	lda $8912,Y
	sta v_6CAC:$F000,Y
	lda $892A,Y
	sta v_6CB2:$F000,Y
	lda $8942,Y
	sta v_6CB8:$F000,Y
	lda $895A,Y
	sta v_6CBE:$F000,Y
	dey
	bpl L_BRS_6CA2_6CC1
	jmp L_JMP_6AC0_6CC3
	lda #$17
	.byte $2C
	lda #$2F
	.byte $2C
	lda #$47
	.byte $2C
	lda #$5F
	stx $EB
	tax

L_BRS_6CD4_6CE0:

	lda table_67EB,X
	sta ($E0),Y
	lda table_684B,X
	sta ($E2),Y
	dex
	dey
	bpl L_BRS_6CD4_6CE0
	ldx #$00
	jsr L_JSR_6762_6CE4
	ldy $EB
	lda ($46),Y
	and #$0F
	tay
	lda table_68AB,Y
	ora $0E
	ldx #$05

L_BRS_6CF5_6CFB:

	ldy table_6784,X
	sta ($E4),Y
	dex
	bpl L_BRS_6CF5_6CFB
	ldx $EB
	jmp L_JMP_6AC0_6CFF

L_JMP_6D02_6F2B:

	lda #$00

L_BRS_6D04_6D09:

	sta ($E0),Y
	sta ($E2),Y
	dey
	bpl L_BRS_6D04_6D09
	jmp L_JMP_6AC0_6D0B

table_6D0E:

	.byte $01,$02,$F3,$7C,$00,$4F,$5E,$6D
	.byte $00,$0F,$1F,$2F,$00,$3F,$D3,$E3
	.byte $00,$C5,$C5,$C5,$00,$C8,$C8,$C8
	.byte $00,$CB,$CB,$CB,$00,$CE,$CE,$CE
	.byte $00,$40,$1C,$75,$00,$5F,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$64

L_BRS_6D50_6D5A:

	lda $89EA,Y
	sta ($E0),Y
	lda #$00
	sta ($E2),Y
	dey
	bpl L_BRS_6D50_6D5A
	jmp L_JMP_6AC0_6D5C

L_BRS_6D5F_6D69:

	lda $8A02,Y
	sta ($E0),Y
	lda #$00
	sta ($E2),Y
	dey
	bpl L_BRS_6D5F_6D69
	jmp L_JMP_6AC0_6D6B

L_BRS_6D6E_6D78:

	lda $8A1A,Y
	sta ($E0),Y
	lda #$00
	sta ($E2),Y
	dey
	bpl L_BRS_6D6E_6D78
	jmp L_JMP_6AC0_6D7A

L_BRS_6D7D_6D87:

	lda $8A62,Y
	sta ($E0),Y
	lda #$00
	sta ($E2),Y
	dey
	bpl L_BRS_6D7D_6D87
	jmp L_JMP_6AC0_6D89

// 6D8C

	.byte $00,$00,$00,$65,$65,$65
table_6D92:
	.byte $6D,$6E
	.byte $6D,$6D,$00,$6D,$6D,$6D,$00,$67
	.byte $67,$67,$00,$67,$6D,$6D,$00,$6C
	.byte $6C,$6C,$00,$6C,$6C,$6C,$00,$6C
	.byte $6C,$6C,$00,$6C,$6C,$6C,$00,$6C
	.byte $6C,$7D,$00,$6B,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00
table_6DC9:	// true table start = $6E89
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$6C

L_BRS_6DD4_6DDF:

	lda $898A,Y
	sta ($E0),Y
	lda $89D2,Y
	sta ($E2),Y
	dey
	bpl L_BRS_6DD4_6DDF
	jmp L_JMP_6AC0_6DE1

L_BRS_6DE4_6DEF:

	lda $89A2,Y
	sta ($E0),Y
	lda $89D2,Y
	sta ($E2),Y
	dey
	bpl L_BRS_6DE4_6DEF
table_6DF1:	// true table start = $6EB1
	jmp L_JMP_6AC0_6DF1

L_BRS_6DF4_6DFE:

	lda $8A4A,Y
	sta ($E0),Y
	lda #$00
	sta ($E2),Y
	dey
	bpl L_BRS_6DF4_6DFE
	jmp L_JMP_6AC0_6E00

L_BRS_6E03_6E0D:

	lda $8A32,Y
	sta ($E0),Y
	lda #$00
	sta ($E2),Y
	dey
	bpl L_BRS_6E03_6E0D
	jmp L_JMP_6AC0_6E0F

// 6E12

	.byte $00,$7D,$7D,$7D,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00

L_JSR_6E38_0CD1:
L_JSR_6E38_50C9:
L_JSR_6E38_549E:

	tax

L_JSR_6E39_13C0:
L_JSR_6E39_1510:
L_JSR_6E39_51D1:

	lda $0510,X
	cmp #$25
	bne L_BRS_6E4E_6E3E
	lda $0500,X
	cmp #$02
	bcc L_BRS_6E4E_6E45
	cmp #$09
	beq L_BRS_6E4E_6E49
	lda #$00
	rts

L_BRS_6E4E_6E3E:
L_BRS_6E4E_6E45:
L_BRS_6E4E_6E49:

	lda #$01
	rts

L_JSR_6E51_5125:

	lsr
	lsr
	sta $E0
	lda $EC
	sec
	sbc $E0

L_JSR_6E5A_0A21:
L_JSR_6E5A_1C26:
L_JSR_6E5A_3F88:
L_JSR_6E5A_3FBD:
L_JSR_6E5A_5248:
L_JSR_6E5A_5457:
L_JSR_6E5A_6A0E:
L_JSR_6E5A_6AE9:

	asl
	asl

L_JSR_6E5C_09CD:
L_JSR_6E5C_0B0C:
L_JSR_6E5C_0DCA:
L_JSR_6E5C_0E3E:
L_JSR_6E5C_0F2A:

	asl
	and #$F8
	ldy table_60FB,X
	bcc L_BRS_6E66_6E62
	iny
	clc

L_BRS_6E66_6E62:

	adc table_60E2,X
	sta $E0
	tya
	adc $29
	adc #$00
	sta $E1
	rts

// 6E73:

	.byte $06,$0B,$10,$15
table_6E77:
	.byte $00,$02,$05,$08,$0B,$0E,$11,$14
	.byte $17,$1A,$1D,$20,$23,$26
table_6E85:
	.byte $03,$08,$0D,$12
table_6E89:	// 6DC9
	.byte $40,$70,$70,$70,$70,$40,$40,$40
	.byte $70,$70,$70,$70,$70,$70,$40,$40
	.byte $40,$D0,$D0,$D0,$D0,$D0,$D0,$D0
	.byte $D0,$D0,$D0,$D0,$D0,$D0,$D0,$D0
	.byte $40,$40,$40,$10,$10,$10,$10,$40
table_6EB1:	// 6DF1

	.byte $31,$31,$59,$59,$81,$81,$A9,$A9
table_6EB9:
	.byte $E1,$78,$69,$71,$6A,$56,$A1,$C8
	.byte $94,$55
table_6EC3:
	.byte $51,$78,$65,$41,$6A,$55,$61,$C8
	.byte $95,$55
table_6ECD:
	.byte $32,$13,$67,$5A,$79,$3A,$49,$36
	.byte $26,$44
table_6ED7:
	.byte $04,$04,$01,$09,$05,$01,$0C,$05
	.byte $01,$01
table_6EE1:
	.byte $24,$4C,$74,$9C
table_6EE5:
	.byte $30,$9C,$DC,$30,$9C,$DC,$30,$9C
	.byte $DC,$E9
table_6EEF:
	.byte $79,$76,$73,$79,$76,$73,$79,$76
	.byte $73,$72,$00,$D3,$C3,$CF,$D2,$C5
	.byte $D3,$A0,$A0,$A0,$C6,$C9,$CE,$C1
	.byte $CC,$BE,$BC,$C8,$C9,$C7,$C8,$A0
table_6F0F:
	.byte $D8,$BD,$C8,$BC,$C8,$BC

L_JMP_6F15_6ABD:

	ldy #$0F
	lda $0510,X
	beq L_BRS_6F2B_6F1A

L_BRS_6F1C_6F26:

	lda table_7DC2,Y
	sta ($E0),Y
	lda #$00
	sta ($E2),Y
	dey
	bpl L_BRS_6F1C_6F26
	jmp L_JMP_6AC0_6F28

L_BRS_6F2B_6F1A:

	jmp L_JMP_6D02_6F2B

L_JMP_6F2E_7007:

	lda $1D
	ora $0206
	bne L_BRS_6F4E_6F33
	lda $0207
	bne L_BRS_6F42_6F38
	inc $0207
	ldx #$12
	jmp L_JMP_6307_6F3F

L_BRS_6F42_6F38:

	lda #$4C
	sta $12
	ldx #$0D
	jsr L_JSR_6307_6F48
	jmp L_JMP_62CF_6F4B

L_BRS_6F4E_6F33:

	lda #$34
	sta $10
	ldx #$0D
	jsr L_JSR_6307_6F54
	lda $1D
	cmp #$80
	bne L_BRS_6F5F_6F5B
	dec $27

L_BRS_6F5F_6F5B:

	rts

L_JMP_6F60_6F60:

	jmp L_JMP_6F60_6F60

// 6F63

	.byte $00,$FF,$BF,$DF,$4F,$FF,$B1,$FF
	.byte $FF,$FF,$00,$FF,$EF,$FF,$5F,$EF
	.byte $FF,$FF,$00,$FF,$CF,$FF,$00,$FF
	.byte $6E,$FF,$6F,$FF,$00,$45,$BF,$05
	.byte $BF,$04,$BF,$05,$FF,$02,$4E,$00
	.byte $FF,$04,$04,$2F,$FF,$01,$A5,$B0
	.byte $9F,$5E,$FF,$10,$A7,$84,$EE,$84
	.byte $E7,$40,$FF,$1B,$3D,$04,$27,$04
	.byte $BD,$05,$07,$95,$55,$04,$05,$20
	.byte $A7,$04,$EF,$00,$5F,$25,$FF,$0E
	.byte $00,$04,$FF,$04,$DF,$A5,$5E,$91
	.byte $B1,$2E,$7F,$0F,$95,$45,$F9,$05
	.byte $BD,$04,$FB,$0E,$F5,$30,$6E,$00
	.byte $E4,$80,$BF,$0F,$3F,$01,$B5,$1F
	.byte $9F,$85,$FF,$80,$F7,$04,$77,$04
	.byte $DE,$4E,$EF,$4F,$FF,$04,$F7,$01
	.byte $FD,$04,$D7,$05,$B5,$04,$6F,$10
	.byte $B7,$DD,$FF,$45,$95,$04,$EE,$10
	.byte $05,$04,$FF,$04,$5C,$85,$DF,$94
	.byte $B5,$4E,$B5,$4F,$FF

L_JSR_7000_14C8:

	cpx $28
	bne L_BRS_700A_7002
	jsr L_JSR_7DD2_7004
	jmp L_JMP_6F2E_7007

L_BRS_700A_7002:

	lda $0510,X
	ldy $1D
	asl
	bcc L_BRS_702F_7010
	lda #$7F
	sta $1E
	stx $EF
	ldx #$02
	jsr L_JSR_6307_701A
	ldx $EF
	lda $0510,X
	and #$03

L_JMP_7024_7178:

	sta $0510,X
	lda #$04
	sta $0590,X
	jmp L_JMP_7DD2_702C

L_BRS_702F_7010:

	asl
	asl
	bcc L_BRS_708A_7031
	tya
	bpl L_BRS_706B_7034
	lda #$09
	sta $0500,X
	ldy #$02
	txa

L_BRS_703E_7044:

	cmp $0021,Y
	beq L_BRS_7052_7041
	dey
	bpl L_BRS_703E_7044
	ldy #$02

L_BRS_7048_704E:

	lda $0021,Y
	beq L_BRS_7050_704B
	dey
	bpl L_BRS_7048_704E

L_BRS_7050_704B:

	dec $27

L_BRS_7052_7041:

	dec $27
	txa
	sta $0021,Y
	lda $20
	sta $0024,Y
	stx $EF
	ldx #$06
	jsr L_JSR_6307_7061
	ldx $EF
	lda #$25
	jmp L_JMP_7101_7068

L_BRS_706B_7034:

	bne L_BRS_7089_706B
	lda $0500,X
	bne L_BRS_7089_7070
	lda #$80
	sta $1D
	lda $0510,X
	and #$DF

L_JMP_707B_70D7:
L_JMP_707B_7103:

	sta $0510,X
	lda #$04
	sta $0590,X
	jsr L_JSR_62D3_7083
	jmp L_JMP_7DD2_7086

L_BRS_7089_706B:
L_BRS_7089_7070:

	rts

L_BRS_708A_7031:

	asl
	bcc L_BRS_7093_708B
	jsr L_JSR_7116_708D
	jmp L_JMP_7DD2_7090

L_BRS_7093_708B:

	cmp #$40
	bcc L_BRS_70F7_7095
	cpy #$80
	beq L_BRS_7106_7099
	cmp #$C0
	bcc L_BRS_70DA_709D
	cpy $1E
	beq L_BRS_7106_70A1

L_BRS_70A3_70DB:
L_BRS_70A3_70E8:

	sty $0205
	lda $0510,X
	and #$0C
	cmp #$04
	bne L_BRS_70C7_70AD
	ldy #$04

L_BRS_70B1_70C5:

	txa
	cmp $005A,Y
	bne L_BRS_70C3_70B5
	lda $004E,Y
	beq L_BRS_70C3_70BA
	lda $004F,Y
	beq L_BRS_70C3_70BF
	bpl L_BRS_7106_70C1

L_BRS_70C3_70B5:
L_BRS_70C3_70BA:
L_BRS_70C3_70BF:

	dey
	dey
	bpl L_BRS_70B1_70C5

L_BRS_70C7_70AD:

	lda #$01
	ldy #$FC

L_JMP_70CB_70F4:

	sed
	clc
	adc $1D
	sta $1D
	cld
	tya
	clc
	adc $0510,X
	jmp L_JMP_707B_70D7

L_BRS_70DA_709D:

	tya
	beq L_BRS_70A3_70DB
	bmi L_BRS_7106_70DD
	bit $0205
	bmi L_BRS_70EA_70E2
	cpy $1E
	beq L_BRS_70EA_70E6
	bne L_BRS_70A3_70E8

L_BRS_70EA_70E2:
L_BRS_70EA_70E6:
L_BRS_70EA_70FA:

	sed
	lda #$80
	sta $0205
	lda #$99
	ldy #$04
	jmp L_JMP_70CB_70F4

L_BRS_70F7_7095:

	tya
	beq L_BRS_7106_70F8
	bpl L_BRS_70EA_70FA
	lda $0510,X
	ora #$20

L_JMP_7101_7068:

	asl $1D
	jmp L_JMP_707B_7103

L_BRS_7106_7099:
L_BRS_7106_70A1:
L_BRS_7106_70C1:
L_BRS_7106_70DD:
L_BRS_7106_70F8:

	rts

// 7107

	.byte $AF,$B0
table_7109:
	.byte $00,$0B,$17,$23,$2F,$3B,$47,$53
	.byte $5F,$6B,$77,$83,$8F

L_JSR_7116_1962:
L_JSR_7116_51FE:
L_JSR_7116_708D:

	txa
	tay
	sty $E0
	ldx #$0F

L_BRS_711C_7121:

	lda $7D,X
	beq L_BRS_7124_711E
	dex
	bpl L_BRS_711C_7121
	rts

L_BRS_7124_711E:

	sta $0630,X
	lda #$01
	sta $0640,X
	tya
	sta $0600,X
	lsr
	lsr
	lsr
	lsr
	tay
	lda table_6EB1,Y
	sta $7D,X
	ldy $E0
	lda ($46),Y
	sta $0620,X

L_BRS_7141_7146:

	jsr L_JSR_6200_7141
	and #$03
	beq L_BRS_7141_7146
	ldx $E0
	sta $E0
	lda #$81
	cpx $8D
	beq L_BRS_7178_7150
	lda $27
	cmp #$02
	bcs L_BRS_7171_7156
	lda $21
	beq L_BRS_7164_715A
	lda $22

L_BRS_715F_719D_BAD:

	beq L_BRS_7164_715E
	lda $23
	bne L_BRS_7171_7162

L_BRS_7164_715A:
L_BRS_7164_715E:

	jsr L_JSR_6200_7164
	and #$38
	bne L_BRS_7171_7169
	inc $27
	lda #$20
	bne L_BRS_7176_716F

L_BRS_7171_7156:
L_BRS_7171_7162:
L_BRS_7171_7169:

	jsr L_JSR_6200_7171
	and #$0C

L_BRS_7176_716F:

	ora $E0

L_BRS_7178_7150:

	jmp L_JMP_7024_7178

L_JSR_717B_0B69:
L_JSR_717B_1255:
L_JSR_717B_5037:
L_JSR_717B_53C0:

	cpy #$03
	beq L_BRS_718C_717D
	cpy #$08
	beq L_BRS_718C_7181
	cpy #$0D
	beq L_BRS_718C_7185
	cpy #$12
	beq L_BRS_718C_7189
	dey

L_BRS_718C_717D:
L_BRS_718C_7181:
L_BRS_718C_7185:
L_BRS_718C_7189:

	stx $F3
	sta $F2
	sty $F4
	ldx #$03
	jmp L_JMP_7E2B_7194
// ############# snippet ###############
	lda #$04
	sta $DB00,X
	inx
	bne L_BRS_715F_719D_BAD + 1
	rts
	cpx #$0B
	beq L_BRS_71BC_71A2
	ldy $04FC
	cpy #$16
// #####################################
L_JSR_71A9_0F81:
L_JSR_71A9_0F90:
L_JSR_71A9_0F98:

	asl
	asl
	asl
	tax
	ldy #$04

L_BRS_71AF_71B8:

	lda table_6000,X
	sta ($E0),Y
	inx
	iny
	cpy #$08
	bne L_BRS_71AF_71B8
	ldy #$00

L_BRS_71BC_71A2:
L_BRS_71BC_71C5:

	lda table_6000,X
	sta ($E2),Y
	inx
	iny
	cpy #$05
	bne L_BRS_71BC_71C5
	ldy #$01
	ldx #$00
	jsr L_JSR_61DE_71CB
	ldx #$02
	jsr L_JSR_61DE_71D0
	ldx $EF
	rts

L_JSR_71D6_0B5A:
L_JSR_71D6_0BAB:
L_JSR_71D6_0EB6:
L_JSR_71D6_133F:
L_JSR_71D6_1946:
L_JSR_71D6_1B7A:
L_JSR_71D6_53F5:

	stx $F2
	sty $F3
	ldx #$27

L_BRS_71DC_71EF:

	ldy $0287,X
	bne L_BRS_71EE_71DF
	ldy $0410,X
	bne L_BRS_71EE_71E4
	ldy $0438,X
	bne L_BRS_71EE_71E9
	jmp L_JMP_7E18_71EB

L_BRS_71EE_71DF:
L_BRS_71EE_71E4:
L_BRS_71EE_71E9:

	dex
	bpl L_BRS_71DC_71EF
	rts

// 71F2

	.byte $01,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$01,$00,$FE

L_JSR_71FE_0AFF:
L_JSR_71FE_0B85:
L_JSR_71FE_0BE2:
L_JSR_71FE_0C1E:
L_JSR_71FE_0C8A:
L_JSR_71FE_0CA5:
L_JSR_71FE_13F8:
L_JSR_71FE_1411:
L_JMP_71FE_7238:

	lda $49,X
	lsr
	lda $48,X
	ror
	sec
	sbc #$0B
	rts

L_JSR_7208_0C17:
L_JSR_7208_54D8:

	sta $E0
	and #$F0
	sta $E1
	tya
	and #$F0
	cmp $E1
	bne L_BRS_7221_7213
	cpy $E0
	bcc L_BRS_721E_7217
	tya
	ldy $E0
	sta $E0

L_BRS_721E_7217:
L_BRS_721E_7228:
L_BRS_721E_722A:

	lda $0510,Y

L_BRS_7221_7213:

	and #$03
	beq L_BRS_722C_7223
	iny
	cpy $E0
	bcc L_BRS_721E_7228
	beq L_BRS_721E_722A

L_BRS_722C_7223:

	rts

L_JSR_722D_0B54:
L_JSR_722D_0B64:
L_JSR_722D_0BA3:

	lda $4E,X
	lsr
	lsr
	lsr
	tay
	iny
	lda #$00
	sta $4E,X
	jmp L_JMP_71FE_7238

L_JSR_723B_34DD:

	ldy $CE
	ldx table_6EEF,Y
	lda table_6EE5,Y
	ldy #$24
	jsr L_JSR_660C_7245
	jsr L_JSR_6200_7248
	and #$1F
	clc
	adc #$06
	sta $E5
	asl
	asl
	asl
	sta $E0
	lda #$12
	rol
	sta $E1
	lda #$00
	sta $E2
	lda #$28
	sta $E3
	lda #$28
	sec
	sbc $E5
	sta $E4
	asl
	asl
	ldy #$00
	lda #$03
	sta $EF

L_BRS_7273_7299:

	ldx $E4
	jsr L_JSR_7C1F_7275
	lda $E0
	sec
	sbc #$40
	sta $E0
	lda $E1
	sbc #$01
	sta $E1
	ldx $E5
	jsr L_JSR_7C1F_7287
	lda $E0
	clc
	adc #$40
	sta $E0
	lda $E1
	adc #$01
	sta $E1
	dec $EF
	bne L_BRS_7273_7299
	lda #$00
	ldx #$28
	ldy #$A0
	jsr L_JSR_660C_72A1
	lda #$00
	ldx #$28
	ldy #$E0
	jsr L_JSR_660C_72AA
	ldx $CE
	lda table_6EB9,X
	sta $EA
	lda table_6EC3,X
	sta $EB
	lda table_6ECD,X
	sta $EC
	ldy table_6ED7,X
	ldx #$27

L_BRS_72C3_72E6:

	lda $EA
	sta RAM8000,X
	sta $C000,X
	lda $EB
	sta RAM8000 + $28,X
	sta $C028,X
	lda $EC
	sta RAM8000 + $50,X
	sta $C050,X
	tya
	sta COLRAM + $00,X
	sta COLRAM + $28,X
	sta COLRAM + $50,X
	dex
	bpl L_BRS_72C3_72E6
	rts

// 72E9

	.byte $00,$00,$10,$D9,$11,$10,$00,$04
	.byte $D9,$06,$10,$40,$05,$D9,$18,$10
	.byte $D9,$08,$10,$D9,$09,$01,$D9,$08
	.byte $04,$D9,$14,$10,$04,$D9,$08,$01
	.byte $D9,$10,$01,$D9,$04,$01,$D9,$0A
	.byte $01,$D9,$0B,$14,$D9,$10,$00,$04
	.byte $D9,$29,$04,$D9,$14,$01,$D9,$10
	.byte $04,$D9,$10,$04,$D9,$11,$01,$D9
	.byte $1F,$40,$D9,$12,$01,$00,$40,$04
	.byte $D9,$05,$40,$D9,$3E,$44,$00,$01
	.byte $D9,$09,$40,$D9,$1E,$01,$D9,$2D
	.byte $04,$D9,$70,$10,$D9,$17,$02,$0A
	.byte $A8,$A0,$D9,$03,$A0,$AA,$82,$D9
	.byte $05,$A0,$A8,$AA,$D9,$07,$80,$A8
	.byte $0A,$D9,$07,$80,$A8,$0A,$D9,$07
	.byte $AA,$D9,$06,$A8,$AA,$D9,$07,$AA
	.byte $D9,$07,$AA,$D9,$06,$AA,$AA,$D9
	.byte $06,$AA,$AA,$D9,$06,$AA,$AA,$D9
	.byte $06,$AA,$AA,$D9,$07,$AA,$D9,$07
	.byte $AA,$D9,$06,$AA,$AA,$D9,$06,$A8
	.byte $AA,$D9,$07,$AA,$D9,$07,$AA,$D9
	.byte $07,$AA,$D9,$07,$AA,$D9,$07,$AA
	.byte $D9,$06,$AA,$AA,$D9,$06,$AA,$AA
	.byte $D9,$06,$AA,$AA,$D9,$06,$AA,$AA
	.byte $D9,$07,$AA,$D9,$07,$AA,$D9,$06
	.byte $A8,$AA,$D9,$07,$AA,$D9,$06,$2A
	.byte $AA,$D9,$06,$A8,$AA,$D9,$07,$AA
	.byte $D9,$07,$AA,$D9,$07,$AA,$D9,$06
	.byte $2A,$AA,$D9,$06,$A8,$AA,$D9,$07
	.byte $AA,$D9,$06,$AA,$AA,$D9,$05,$AA
	.byte $AA,$00,$DA,$44,$11,$44,$11,$44
	.byte $11,$44,$11,$44,$11,$44,$11,$44
	.byte $11,$44,$11,$44,$11,$44,$11,$44
	.byte $11,$44,$10,$44,$11,$44,$11,$44
	.byte $11,$04,$01,$44,$11,$44,$11,$44
	.byte $11,$44,$11,$44,$11,$44,$11,$44
	.byte $11,$44,$11,$44,$11,$44,$00,$3F
	.byte $2A,$40,$11,$44,$10,$00,$0A,$FF
	.byte $AA,$00,$11,$44,$00,$FF,$AA,$FF
	.byte $A8,$00,$11,$44,$11,$00,$AA,$FF
	.byte $00,$44,$11,$44,$11,$00,$AA,$FF
	.byte $00,$44,$10,$44,$00,$0F,$AA,$F0
	.byte $01,$44,$11,$44,$00,$FF,$A0,$04
	.byte $11,$44,$11,$44,$01,$C4,$11,$44
	.byte $11,$44,$11,$44,$11,$44,$11,$44
	.byte $11,$44,$11,$44,$11,$44,$11,$44
	.byte $11,$44,$11,$44,$11,$44,$11,$44
	.byte $11,$44,$11,$44,$11,$44,$11,$44
	.byte $11,$44,$11,$44,$11,$44,$11,$44
	.byte $11,$44,$11,$44,$11,$44,$11,$44
	.byte $11,$44,$11,$44,$11,$44,$11,$44
	.byte $1F,$7F,$3F,$44,$11,$44,$11,$44
	.byte $D1,$44,$11,$44,$11,$44,$11,$44
	.byte $11,$44,$11,$44,$11,$44,$11,$44
	.byte $11,$44,$11,$44,$11,$44,$11,$44
	.byte $11,$44,$11,$44,$11,$44,$11,$44
	.byte $11,$44,$11,$44,$11,$44,$11,$44
	.byte $11,$44,$10,$44,$10,$43,$0A,$FF
	.byte $0A,$40,$11,$44,$00,$FC,$AA,$FF
	.byte $AA,$00,$11,$44,$00,$FC,$AA,$FF
	.byte $AA,$00,$11,$44,$11,$04,$81,$04
	.byte $11,$44,$01,$44,$11,$44,$11,$44
	.byte $11,$44,$11,$44,$11,$44,$11,$44
	.byte $11,$44,$11,$44,$11,$44,$11,$44
	.byte $11,$44,$11,$44,$11,$44,$11,$44
	.byte $11,$44,$11,$44,$11,$44,$11,$44
	.byte $11,$44,$10,$44,$11,$44,$11,$44
	.byte $11,$44,$11,$44,$11,$44,$11,$44
	.byte $11,$44,$11,$44,$11,$44,$11,$44
	.byte $11,$44,$10,$44,$11,$44,$11,$44
	.byte $11,$04,$01,$44,$10,$D9,$06,$44
	.byte $11,$04,$01,$D9,$04,$44,$10,$40
	.byte $D9,$0D,$44,$11,$04,$01,$D9,$04
	.byte $44,$11,$44,$10,$40,$D9,$03,$44
	.byte $10,$D9,$06,$44,$11,$04,$D9,$05
	.byte $40,$D9,$07,$44,$11,$04,$D9,$05
	.byte $40,$D9,$07,$04,$01,$D9,$06,$44
	.byte $11,$44,$11,$04,$D9,$03,$44,$11
	.byte $40,$D9,$05,$44,$11,$44,$11,$04
	.byte $D9,$03,$44,$10,$40,$D9,$05,$04
	.byte $01,$D9,$06,$44,$11,$44,$10,$D9
	.byte $04,$44,$11,$04,$D9,$05,$44,$11
	.byte $44,$01,$D9,$04,$7F,$3F,$4F,$11
	.byte $44,$11,$04,$00,$44,$11,$C4,$11
	.byte $44,$11,$40,$00,$44,$11,$44,$10
	.byte $40,$D9,$03,$44,$01,$D9,$06,$44
	.byte $11,$44,$10,$D9,$04,$44,$01,$D9
	.byte $06,$40,$D9,$07,$04,$01,$D9,$06
	.byte $44,$D9,$07,$44,$10,$D9,$0E,$44
	.byte $11,$04,$D9,$05,$44,$01,$D9,$06
	.byte $44,$11,$44,$11,$D9,$04,$44,$11
	.byte $40,$D9,$05,$40,$D9,$07,$04,$01
	.byte $04,$01,$D9,$04,$44,$11,$40,$D9
	.byte $05,$40,$D9,$12,$0F,$FD,$D5,$AA
	.byte $AA,$00,$00,$FC,$D7,$55,$55,$95
	.byte $A5,$D9,$03,$03,$FD,$55,$55,$5A
	.byte $00,$00,$FC,$5F,$57,$55,$6A,$AA
	.byte $D9,$04,$C0,$F0,$AA,$AA,$D9,$06
	.byte $AA,$AA,$D9,$05,$0A,$AA,$BA,$D9
	.byte $04,$AA,$AA,$AA,$AE,$D9,$05,$AA
	.byte $AE,$AA,$D9,$06,$AA,$AA,$D9,$06
	.byte $AA,$AA,$D9,$06,$AA,$AA,$D9,$06
	.byte $AA,$AE,$D9,$05,$AA,$AE,$AA,$D9
	.byte $04,$A0,$AA,$AA,$AA,$D9,$05,$AA
	.byte $AA,$AA,$D9,$05,$AA,$AA,$AE,$D9
	.byte $06,$AA,$AA,$D9,$06,$AA,$AA,$D9
	.byte $06,$BA,$AA,$D9,$05,$0A,$AA,$AA
	.byte $D9,$05,$AA,$BA,$AA,$D9,$05,$AA
	.byte $AA,$AA,$D9,$05,$AA,$AA,$EA,$D9
	.byte $05,$AA,$AA,$AA,$D9,$06,$AA,$EA
	.byte $D9,$05,$0A,$AA,$AE,$D9,$04,$02
	.byte $AA,$AE,$AA,$D9,$04,$A8,$AA,$AA
	.byte $AA,$D9,$05,$A0,$AA,$AA,$D9,$06
	.byte $EA,$AA,$D9,$06,$BA,$AA,$D9,$06
	.byte $AA,$BA,$D9,$06,$AA,$AA,$D9,$05
	.byte $2A,$AA,$AA,$D9,$05,$A0,$AA,$AA
	.byte $D9,$06,$BA,$AA,$D9,$05,$AA,$AA
	.byte $AE,$D9,$06,$AA,$EA,$D9,$05,$03
	.byte $AE,$AA,$DA,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$AA,$5F,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$AA,$FF,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$AA,$05,$F0,$FF,$A0,$F0,$80
	.byte $02,$2A,$A8,$00,$02,$0A,$28,$A0
	.byte $80,$00,$02,$00,$A0,$A8,$2A,$0A
	.byte $08,$28,$A0,$00,$00,$2A,$A2,$80
	.byte $A0,$A8,$8A,$00,$00,$80,$A0,$A8
	.byte $0A,$02,$00,$00,$0F,$2A,$3F,$0A
	.byte $03,$A0,$A8,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$AA,$0F,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$AA,$FF,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$AA,$FF,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$AA,$FF,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$AA,$FF,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$AA,$FF,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$AA,$FF,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$AA,$FF,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$AA,$FF,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$A9,$F5,$FF,$FF,$AA,$FF,$AA
	.byte $57,$55,$00,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$69,$55,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$55,$05,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$AA,$7F,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$AA,$FF,$FF,$FF,$AA,$FF,$AA
	.byte $FD,$A5,$D4,$FF,$FF,$AA,$FF,$AA
	.byte $7F,$55,$00,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$AA,$55,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$55,$55,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$AA,$55,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$AA,$FF,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$AA,$D5,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$AA,$57,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$AA,$FF,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$AA,$FD,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$AA,$57,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$AA,$FF,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$AA,$FF,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$AA,$FF,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$AA,$F5,$FF,$FF,$AA,$FF,$AA
	.byte $FF,$55,$55,$45,$D9,$08,$01,$05
	.byte $54,$D9,$04,$55,$50,$40,$D9,$05
	.byte $40,$00,$02,$0A,$D9,$04,$0A,$AA
	.byte $A2,$D9,$05,$82,$82,$A0,$00,$02
	.byte $D9,$03,$82,$80,$A0,$A0,$80,$D9
	.byte $03,$80,$A0,$2A,$02,$D9,$04,$05
	.byte $D9,$07,$40,$54,$05,$D9,$05,$15
	.byte $01,$40,$54,$D9,$04,$A5,$55,$D9
	.byte $06,$6A,$55,$01,$D9,$05,$AA,$FF
	.byte $5A,$45,$D9,$04,$AA,$FF,$A9,$55
	.byte $D9,$04,$AA,$FD,$55,$40,$D9,$04
	.byte $A5,$55,$D9,$06,$55,$50,$D9,$06
	.byte $54,$D9,$1F,$45,$D9,$07,$FD,$55
	.byte $D9,$06,$50,$D9,$1F,$01,$D9,$07
	.byte $55,$D9,$07,$54,$D9,$07,$05,$01
	.byte $D9,$06,$FF,$55,$D9,$06,$D5,$50
	.byte $D9,$06,$05,$D9,$07,$7F,$57,$05
	.byte $D9,$05,$FF,$F5,$54,$D9,$05,$FD
	.byte $55,$D9,$06,$54,$D9,$0F,$54,$45
	.byte $01,$40,$55,$04,$14,$59,$00,$00
	.byte $40,$45,$50,$10,$05,$56,$01,$01
	.byte $05,$54,$10,$41,$40,$55,$50,$14
	.byte $04,$14,$45,$41,$01,$56,$D9,$06
	.byte $AA,$AA,$D9,$06,$AA,$AA,$D9,$07
	.byte $AA,$D9,$06,$0A,$AA,$D9,$04,$15
	.byte $51,$41,$56,$D9,$04,$05,$04,$04
	.byte $A9,$D9,$04,$40,$50,$10,$6A,$D9
	.byte $07,$AA,$D9,$07,$AA,$D9,$07,$AA
	.byte $D9,$07,$AA,$D9,$07,$AA,$00,$00
	.byte $05,$14,$54,$40,$40,$55,$00,$00
	.byte $40,$50,$10,$10,$9A,$6A,$D9,$06
	.byte $A0,$AA,$D9,$07,$AA,$D9,$06,$AA
	.byte $AA,$D9,$06,$AA,$AA,$D9,$07,$AA
	.byte $D9,$06,$AA,$AA,$D9,$06,$AA,$AA
	.byte $D9,$06,$AA,$AA,$D9,$07,$AA,$D9
	.byte $07,$AA,$D9,$06,$AA,$AA,$D9,$06
	.byte $AA,$AA,$D9,$06,$AA,$AA,$D9,$06
	.byte $A0,$AA,$00,$00,$15,$51,$41,$44
	.byte $50,$9A,$00,$00,$40,$50,$10,$10
	.byte $51,$69,$D9,$05,$55,$41,$55,$D9
	.byte $06,$AA,$AA,$D9,$06,$AA,$AA,$D9
	.byte $07,$AA,$D9,$06,$AA,$AA,$00,$01
	.byte $01,$05,$04,$14,$90,$A5,$DA,$D8
	.byte $06,$AF,$6A,$D8,$07,$AF,$D8,$0F
	.byte $AF,$D8,$3A,$FD,$D8,$04,$FA,$FF
	.byte $FD,$55,$FD,$FE,$EA,$9A,$A5,$FF
	.byte $5F,$55,$95,$A5,$AB,$6A,$96,$FF
	.byte $D5,$55,$55,$55,$F5,$FF,$BF,$D5
	.byte $55,$7F,$55,$55,$55,$FF,$FF,$55
	.byte $55,$55,$55,$55,$D8,$03,$55,$55
	.byte $55,$55,$D8,$04,$55,$55,$55,$57
	.byte $D8,$04,$55,$55,$55,$D8,$05,$55
	.byte $55,$55,$D5,$FD,$FF,$BF,$AB,$55
	.byte $55,$55,$55,$55,$55,$55,$FF,$55
	.byte $55,$55,$55,$55,$55,$55,$D5,$55
	.byte $56,$56,$56,$56,$55,$55,$55,$A5
	.byte $A9,$A9,$A9,$A9,$A5,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$7F,$55
	.byte $55,$55,$55,$55,$55,$FF,$FF,$5F
	.byte $55,$55,$55,$55,$7F,$FF,$FF,$FF
	.byte $FD,$55,$55,$D8,$04,$FF,$5F,$55
	.byte $FF,$FF,$FF,$FA,$E9,$D8,$05,$EA
	.byte $AA,$A6,$D8,$05,$AA,$A9,$80,$D8
	.byte $04,$AA,$AA,$AA,$02,$D8,$04,$BF
	.byte $AB,$6A,$A6,$D8,$07,$AF,$D8,$0F
	.byte $FE,$D8,$06,$AA,$B5,$55,$05,$55
	.byte $01,$55,$D9,$03,$6A,$52,$55,$50
	.byte $55,$D9,$03,$FA,$A9,$55,$05,$55
	.byte $05,$01,$00,$9B,$56,$45,$55,$41
	.byte $55,$54,$00,$FF,$FF,$AB,$5A,$55
	.byte $55,$00,$00,$FF,$FE,$EA,$A5,$55
	.byte $55,$55,$00,$FF,$AF,$5A,$55,$55
	.byte $55,$55,$00,$FF,$AA,$82,$55,$40
	.byte $55,$00,$00,$FF,$FF,$AA,$56,$00
	.byte $01,$00,$05,$D8,$03,$AF,$6A,$55
	.byte $05,$55,$D8,$03,$FE,$A9,$55,$50
	.byte $55,$EA,$E5,$95,$55,$55,$00,$05
	.byte $40,$69,$55,$55,$01,$55,$05,$55
	.byte $00,$59,$56,$55,$55,$55,$54,$00
	.byte $00,$BF,$AB,$5A,$55,$55,$D9,$03
	.byte $FF,$FF,$BF,$AA,$55,$D9,$03,$FF
	.byte $FA,$E9,$A4,$55,$D9,$03,$FF,$AF
	.byte $5E,$16,$55,$D9,$03,$EA,$E6,$E5
	.byte $90,$55,$D9,$03,$F9,$A5,$55,$00
	.byte $54,$D9,$03,$56,$55,$55,$05,$15
	.byte $01,$00,$00,$AF,$6B,$5A,$55,$05
	.byte $40,$00,$00,$FF,$FF,$BF,$AA,$55
	.byte $D9,$03,$D8,$03,$AA,$55,$00,$01
	.byte $00,$D8,$03,$AA,$55,$05,$55,$00
	.byte $D8,$03,$AA,$55,$55,$55,$00,$D8
	.byte $03,$AA,$55,$55,$00,$00,$FE,$FA
	.byte $E9,$A5,$55,$D9,$03,$AF,$6F,$1A
	.byte $55,$55,$D9,$03,$FF,$FA,$FE,$55
	.byte $55,$D9,$03,$FA,$FE,$55,$55,$55
	.byte $D9,$03,$A5,$55,$45,$55,$55,$D9
	.byte $03,$55,$55,$55,$55,$55,$D9,$03
	.byte $55,$55,$55,$40,$55,$05,$01,$00
	.byte $55,$55,$00,$05,$55,$50,$55,$00
	.byte $55,$45,$55,$55,$55,$00,$50,$00
	.byte $5B,$56,$55,$55,$55,$D9,$03,$FF
	.byte $FF,$AA,$55,$55,$D9,$03,$FA,$A9
	.byte $95,$55,$55,$D9,$03,$59,$55,$55
	.byte $50,$55,$D9,$03,$D9,$03,$02,$AA
	.byte $54,$12,$AA,$00,$14,$AA,$80,$AA
	.byte $42,$AA,$AA,$00,$0A,$AA,$82,$BA
	.byte $29,$8A,$AA,$00,$00,$80,$A8,$2A
	.byte $55,$51,$AA,$D9,$04,$80,$6A,$6A
	.byte $AA,$D9,$04,$04,$84,$84,$AA,$D9
	.byte $04,$01,$41,$41,$AA,$D9,$06,$14
	.byte $AA,$D9,$04,$44,$44,$45,$AA,$D9
	.byte $04,$01,$45,$45,$AA,$00,$00,$04
	.byte $04,$04,$14,$14,$AA,$00,$40,$00
	.byte $40,$41,$41,$41,$AA,$D9,$04,$40
	.byte $41,$01,$AA,$D9,$04,$04,$05,$54
	.byte $AA,$D9,$04,$41,$41,$41,$AA,$00
	.byte $00,$40,$40,$54,$54,$45,$AA,$D9
	.byte $04,$11,$11,$15,$AA,$00,$00,$10
	.byte $10,$14,$04,$04,$AA,$D9,$04,$14
	.byte $10,$11,$AA,$D9,$05,$01,$41,$AA
	.byte $D9,$04,$10,$15,$15,$AA,$D9,$05
	.byte $04,$54,$AA,$D9,$04,$40,$44,$44
	.byte $AA,$D9,$04,$51,$41,$44,$AA,$D9
	.byte $04,$11,$15,$04,$AA,$D9,$04,$05
	.byte $41,$41,$AA,$D9,$03,$04,$14,$14
	.byte $04,$AA,$D9,$03,$40,$54,$54,$11
	.byte $AA,$D9,$04,$10,$14,$04,$AA,$D9
	.byte $04,$04,$44,$44,$AA,$00,$00,$10
	.byte $10,$10,$14,$14,$AA,$D9,$04,$04
	.byte $14,$14,$AA,$D9,$04,$40,$51,$51
	.byte $AA,$D9,$04,$11,$11,$11,$AA,$D9
	.byte $05,$50,$50,$AA,$D9,$03,$04,$44
	.byte $45,$45,$AA,$D9,$04,$10,$10,$51
	.byte $AA,$D9,$04,$10,$10,$14,$AA,$D9
	.byte $04,$04,$44,$56,$AA,$D9,$04,$22
	.byte $25,$28,$AA,$DA,$00,$00

L_JSR_7C1F_7275:
L_JSR_7C1F_7287:
L_BRS_7C1F_7C29:
L_BRS_7C1F_7C2C:
L_BRS_7C1F_7C35:

	lda ($E0),Y
	sta ($E2),Y
	iny
	beq L_BRS_7C30_7C24
	tya
	and #$07
	bne L_BRS_7C1F_7C29
	dex
	bne L_BRS_7C1F_7C2C
	beq L_BRS_7C37_7C2E

L_BRS_7C30_7C24:

	inc $E1
	inc $E3
	dex
	bne L_BRS_7C1F_7C35

L_BRS_7C37_7C2E:

	rts

L_JMP_7C38_0816:
L_JSR_7C38_1B2E:

	sta ITEM+1

	lda #$00
	sta $EE
	stx $EC

SPRLB:

	lda #$14
	sta $EB
// (below)THIS SECTION OF CODE IS STORED IN ORIGINAL ASSEMBLY AND HAS BEEN USED TO PROVIDE SOME LABELS
SPRL:

	jsr L_JSR_679B_7C45
	dec $EB
	bmi L_BRS_7C90_7C4A
	ora $ED
	tax
	lda $0510,X	//ss+16
	and #$FC
	bne SPRL
	lda $0500,X	//ss,x
	bne SPRL
	lda $0510,X	//ss+16,x
	and #$03
	beq SPRL
	lda $0580,X	//redraw,X
	bne DOIT
	jsr L_JSR_6200_7C67	//JSR rm
	and #$06
	bne SPRL

DOIT:

	lda $0510,X	//ss+16,X
ITEM:
	ora #$00
	sta $0510,X	//ss+16,X
	lda ITEM+1
	cmp #$10
	bne SPRLD
	jsr L_JSR_6200_7C7D// JSR rm
	and #$0C
	ora $0510,X	//ss+16,X
	sta $0510,X	//ss+16,X

SPRLD:

	inc $EE		// putemp
	lda $EE		// putemp
	cmp $EC		// T+12 (so T=$00D0)
	bne SPRLB

L_BRS_7C90_7C4A:

	rts

SXCOL:
	.byte $70,$70,$70,$70
CONV:
	.byte $03,$0B,$13,$04,$0C,$14,$05,$0D
	.byte $15,$06,$0E,$16,$07,$0F,$17,$18
	.byte $20,$28,$19,$21,$29,$1A,$22,$2A
	.byte $1B,$23,$2B
	
	.byte $1C,$24,$2C,$1D,$25,$2D

CGWR:
	.byte $25,$27,$26
CGWL:
	.byte $22,$20,$22
BABWD:
	.byte $06,$04,$06
BABW1:
	.byte $04,$00,$04
FLSHCOL:
	.byte $50,$50,$60,$50
FLSHSC:
	.byte $00,$90,$01,$00
DINOSZ:
	.byte $06,$08,$12
REDQ:
	.byte $00,$00,$00,$00,$00,$10,$10,$10
	.byte $00,$00,$30,$30,$30,$00,$00,$50
	.byte $50,$50,$00,$00,$70,$70,$70
GETIND:

	ldy #$00
	sec

GET2:

	iny
	sbc #$0C
	bcs GET2
	tya
	ora $E8	//T+8
	tay
	rts

L_JSR_7CF1_0B96:

	tay
	dey
	lda $0097,Y	//SPIDVD,Y
	cmp #$01
	bne DROPPED
	lda $00AA,Y	//SPIDDIE,Y
	beq NR1

DROPPED:

	lda $5A,X		//BABIX,X
	lsr
	lsr
	lsr
	lsr
	lsr
	tay
	lda $4E,X		//BABY,X
	sec
	sbc table_6EE1,Y	//BUMP,Y
	bmi DR6
	cmp #$06
	bcs DR6
	sty $E2		//T+2
	ldy $5A,X		//BABIX,X
	lda $0510,Y	//SS+16,Y
	and #$03
	beq DR6
	lda #$00
	sta $72,X		//BDHOLD,X
	lda #$05
	sta $5B,X		//FAMB,X
	ldy $E2		//T+2
	lda table_6EE1,Y	//BUMP,Y
	sec
	sbc #$01
	sta $4E,X		//BABY,X

DR6:
	inc $4E,X		//BABY,X
	inc $4E,X		//BABY,X

NR1:

	rts

SCON:
// (above)THIS SECTION OF CODE IS STORED IN ORIGINAL ASSEMBLY AND HAS BEEN USED TO PROVIDE SOME LABELS
	lda #$FF
	sta D1DDRA                          // Data Direction Register A
	ldx #$07

L_BRS_7D3C_7D52:

	lda table_6114,X
	sta D1PRA                          // Data Port A (Keyboard, Joystick, Paddles)

L_BRS_7D42_7D48:

	lda D1PRB                          // Data Port B (Keyboard, Joystick, Paddles)
	cmp D1PRB                          // Data Port B (Keyboard, Joystick, Paddles)
	bne L_BRS_7D42_7D48
	and table_611C,X
	cmp #$01
	ror $14
	dex
	bpl L_BRS_7D3C_7D52
	rts

L_JSR_7D55_11E3:
L_JSR_7D55_11FB:
L_JSR_7D55_419F:

	lda #$00
	sta D1PRA                          // Data Port A (Keyboard, Joystick, Paddles)

L_BRS_7D5A_7D60:

	lda D1PRB                          // Data Port B (Keyboard, Joystick, Paddles)
	cmp D1PRB                          // Data Port B (Keyboard, Joystick, Paddles)
	bne L_BRS_7D5A_7D60
	cmp #$FF
	rts
	rts

L_BRS_7D66_7D71:

	lda $88CA,Y
	sta ($E0),Y
	lda $88E2,Y
	sta ($E2),Y
	dey
	bpl L_BRS_7D66_7D71
	jmp L_JMP_6AC0_7D73
	txa
	lsr
	bcc L_BRS_7D8A_7D78

L_BRS_7D7A_7D85:

	lda $8ADA,Y
	sta ($E0),Y
	lda $8B3A,Y
	sta ($E2),Y
	dey
	bpl L_BRS_7D7A_7D85
	jmp L_JMP_6AC0_7D87

L_BRS_7D8A_7D78:
L_BRS_7D8A_7D95:

	lda $8B22,Y
	sta ($E0),Y
	lda $8B52,Y
	sta ($E2),Y
	dey
	bpl L_BRS_7D8A_7D95
	jmp L_JMP_6AC0_7D97

// 7D9A

	.byte $00,$67,$67,$67,$00,$67,$6D,$6D
	.byte $00,$6C,$6C,$6C,$00,$6C,$6C,$6C
	.byte $00,$6C,$6C,$6C,$00,$6C,$6C,$6C
	.byte $00,$6C,$6C,$7D,$00,$6B,$00,$00
table_7DBA:
	.byte $10,$1D,$30,$3D,$50,$5D,$70,$7D
table_7DC2:
	.byte $AA,$AB,$8A,$20,$00,$00,$00,$00
	.byte $AA,$0E,$AA,$22,$00,$00,$00,$00

L_JSR_7DD2_7004:
L_JMP_7DD2_702C:
L_JMP_7DD2_7086:
L_JMP_7DD2_7090:

	lda #$0F
	sta SIGVOL                          // Select Filter Mode and Volume
	lda #$02
	sta FREHI1                          // Voice 1: Frequency Control - High-Byte
	lda #$21
	ldx #$51
	ldy #$91
	jsr L_JSR_7DFD_7DE2
	ldy #$20
	jsr L_JSR_7E07_7DE7
	lda #$08
	sta VCREG1                          // Voice 1: Control Register
	lda #$31
	ldy $CE
	cpy #$09
	bne L_BRS_7DF9_7DF5
	lda #$35

L_BRS_7DF9_7DF5:

	sta v_64AD
	rts

L_JSR_7DFD_7DE2:

	sta VCREG1                          // Voice 1: Control Register
	stx ATDCY1                          // Voice 1: Attack / Decay Cycle Control
	sty SUREL1                          // Voice 1: Sustain / Release Cycle Control
	rts

L_JSR_7E07_7DE7:

	ldx #$00

L_BRS_7E09_7E0A:
L_BRS_7E09_7E15:

	inx
	bne L_BRS_7E09_7E0A
	tya
	lsr
	clc
	adc #$04
	sta FREHI1                          // Voice 1: Frequency Control - High-Byte
	dey
	bne L_BRS_7E09_7E15
	rts

L_JMP_7E18_71EB:

	sta $02AF,X
	lda $F2
	sta $020F,X
	lda $F3
	sta $0237,X
	lda #$18
	sta $0287,X
	rts

L_JMP_7E2B_7194:
L_BRS_7E2B_7E47:

	txa
	asl
	tay
	lda $68,X
	ora $BFB2,Y
	bne L_BRS_7E46_7E33
	lda $F2
	sta $60,X
	lda $F3
	sta $6C,X
	lda $F4
	sta $64,X
	lda #$0D
	sta $68,X
	rts

L_BRS_7E46_7E33:

	dex
	bpl L_BRS_7E2B_7E47
	rts

table_7E4A:
	.byte $80,$90,$A8,$C0,$D8,$F0,$08,$20
	.byte $38,$50,$68,$80,$98,$B0,$00,$00
table_7E5A:
	.byte $A7,$A7,$A7,$A7,$A7,$A7,$A8,$A8
	.byte $A8,$A8,$A8,$A8,$A8,$A8,$20,$20
	.byte $C0,$D0,$E8,$00,$18,$30,$48,$60
	.byte $78,$90,$A8,$C0,$D8,$F0,$00,$00
	.byte $AD,$AD,$AD,$AE,$AE,$AE,$AE,$AE
	.byte $AE,$AE,$AE,$AE,$AE,$AE,$20,$20
	.byte $00,$10,$28,$40,$58,$70,$88,$A0
	.byte $B8,$D0,$E8,$00,$18,$30,$00,$00
	.byte $B4,$B4,$B4,$B4,$B4,$B4,$B4,$B4
	.byte $B4,$B4,$B4,$B5,$B5,$B5,$20,$20
	.byte $40,$50,$68,$80,$98,$B0,$C8,$E0
	.byte $F8,$10,$28,$40,$58,$70,$00,$00
	.byte $BA,$BA,$BA,$BA,$BA,$BA,$BA,$BA
	.byte $BA,$BB,$BB,$BB,$BB,$BB,$20,$20
	.byte $C8,$A4,$80,$BF,$0F,$3F,$05,$B5
	.byte $9F,$9F,$C5,$FF,$94,$F7,$14,$77
	.byte $04,$DE,$CF,$EF,$4F,$FF,$04,$97
	.byte $01,$FD,$04,$57,$05,$B5,$0E,$2D
	.byte $10,$B7,$9D,$FF,$C5,$95,$00,$FC
	.byte $10,$05,$04,$FF,$05,$5C,$95,$FF
	.byte $94,$B5,$4F,$B5,$CF,$FF,$FF,$EF
	.byte $FF,$4F,$FF,$4E,$FF,$40,$FF,$B1
	.byte $FF,$01,$FF,$FF,$FF,$0E,$FF,$4E
	.byte $6F,$64,$FF,$45,$FB,$FF,$FF,$01
	.byte $FF,$FF,$FF,$84,$FF,$FF,$FF,$FF
	.byte $FF,$42,$FF,$FF,$6E,$EE,$FF,$FF
	.byte $DF,$7E,$FF,$5C,$FF,$FF,$DF,$81
	.byte $F5,$FF,$FF,$00,$FF,$48,$FF,$B1
	.byte $FF,$4F,$FF,$40,$FF,$6F,$FF,$A7
	.byte $FF,$4F,$FF,$07,$FF,$AF,$DF,$99
	.byte $FF,$7F,$7F,$FF,$FF,$FF,$FF,$4E
	.byte $ED,$65,$7F,$45,$FF,$08,$FF,$BF
	.byte $FF,$75,$FF,$94,$FF,$00,$FF,$6D
	.byte $FF,$46,$FF,$AE,$DF,$4E,$FF,$F3
	.byte $FF,$6F,$FF,$00,$FF,$EE,$FF,$5F
	.byte $EF,$7E,$FF,$00,$FF,$CF,$FF,$00
	.byte $FF,$6E,$FF,$6E,$FF,$00,$FF,$FF
	.byte $8D,$00,$64