// KERNAL
.label ACPTR	= $FFA5             // 65445	Input byte from serial port
.label CHKIN	= $FFC6             // 65478	Open channel for input
.label CHKOUT	= $FFC9             // 65481	Open a channel for output
.label CHRIN	= $FFCF             // 65487	Get a character from the input channel
.label CHROUT	= $FFD2             // 65490	Output a character
.label CIOUT	= $FFA8             // 65448	Transmit a byte over the serial bus
.label CINT	= $FF81             // 65409	Initialize the screen editor and VIC-II Chip
.label CLALL	= $FFE7             // 65511	Close all open files
.label CLOSE	= $FFC3             // 65475	Close a logical file
.label CLRCHN	= $FFCC             // 65484	Clear all I/O channels
.label GETIN	= $FFE4             // 65508	Get a character
.label IOBASE	= $FFF3             // 65523	Define I/O memory page
.label IOINIT	= $FF84             // 65412	Initialize I/O devices
.label LISTEN	= $FFB1             // 65457	Command a device on the serial bus to listen
.label LOAD	= $FFD5             // 65493	Load RAM from device
.label MEMBOT	= $FF9C             // 65436	Set bottom of memory
.label MEMTOP	= $FF99             // 65433	Set the top of RAM
.label OPEN	= $FFC0             // 65472	Open a logical file
.label PLOT	= $FFF0             // 65520	Set or retrieve cursor location
.label RAMTAS	= $FF87             // 65415	Perform RAM test
.label RDTIM	= $FFDE             // 65502	Read system clock
.label READST	= $FFB7             // 65463	Read status word
.label RESTOR	= $FF8A             // 65418	Set the top of RAM
.label SAVE	= $FFD8             // 65496	Save memory to a device
.label SCNKEY	= $FF9F             // 65439	Scan the keyboard
.label SCREEN	= $FFED             // 65517	Return screen format
.label SECOND	= $FF93             // 65427	Send secondary address for LISTEN
.label SETLFS	= $FFBA             // 65466	Set up a logical file
.label SETMSG	= $FF90             // 65424	Set system message output
.label SETNAM	= $FFBD             // 65469	Set up file name
.label SETTIM	= $FFDB             // 65499	Set the system clock
.label SETTMO	= $FFA2             // 65442	Set IEEE bus card timeout flag
.label STOP	= $FFE1             // 65505	Check if STOP key is pressed
.label TALK	= $FFB4             // 65460	Command a device on the serial bus to talk
.label TKSA	= $FF96             // 65430	Send a secondary address to a device commanded to talk
.label UDTIM	= $FFEA             // 65514	Update the system clock
.label UNLSN	= $FFAE             // 65454	Send an UNLISTEN command
.label UNTLK	= $FFAB             // 65451	Send an UNTALK command
.label VECTOR	= $FF8D             // 65421	Manage RAM vectors

.label NMI_vector   = $FFFA             // NMI vector (FE43)
.label RESET_vector = $FFFC             // RESET vector (FCE2)
.label IRQ_vector   = $FFFE             // IRQ vector (FF48)


// VIC CHIP $D000
.label SP0X         = $D000
.label SP0Y         = $D001
.label SP1X         = $D002
.label SP1Y         = $D003
.label SP2X         = $D004
.label SP2Y         = $D005
.label SP3X         = $D006
.label SP3Y         = $D007
.label SP4X         = $D008
.label SP4Y         = $D009
.label SP5X         = $D00A
.label SP5Y         = $D00B
.label SP6X         = $D00C
.label SP6Y         = $D00F
.label MSIGX        = $D010
.label SCROLY       = $D011
.label RASTER       = $D012
.label LPENX        = $D013
.label LPENY        = $D014
.label SPENA        = $D015
.label SCROLX       = $D016
.label YXPAND       = $D017
.label VMCSB        = $D018
.label VICIRQ       = $D019
.label IRQMSK       = $D01A
.label SPBGPR       = $D01B
.label SPMC         = $D01C
.label XXPAND       = $D01D
.label SPSPCL       = $D01E
.label SPBGCL       = $D01F
.label EXTCOL       = $D020
.label BGCOL0       = $D021
.label BGCOL1       = $D022
.label BGCOL2       = $D023
.label BGCOL3       = $D024
.label SPMC0        = $D025
.label SPMC1        = $D026
.label SP0COL       = $D027
.label SP1COL       = $D028
.label SP2COL       = $D029
.label SP3COL       = $D02A
.label SP4COL       = $D02B
.label SP5COL       = $D02C
.label SP6COL       = $D02D
.label SP7COL       = $D02E
// Sprite data lie at address MEM(Start of screen mem + $03F8 + sprite number)*64
// The start of the Screen RAM (the VIC bank) is set by $DD00 (see CIA 2) and $D018.
// $DD00	Bit 0..1: Select the position of the VIC-memory
// %00, 0: Bank 3: $C000-$FFFF, 49152-65535
// %01, 1: Bank 2: $8000-$BFFF, 32768-49151
// %10, 2: Bank 1: $4000-$7FFF, 16384-32767
// %11, 3: Bank 0: $0000-$3FFF, 0-16383 (standard)
// $D018
//        lda #$0f
//        and $d018
//        ora #$(A) 

//   A	Start address of screen RAM
//   0	    0 ($0000)
//  10	 1024 ($0400) default
//  20	 2048 ($0800)
//  30	 3072 ($0C00)
//  40	 4096 ($1000)
//  50	 5120 ($1400)
//  60	 6144 ($1800)
//  70	 7168 ($1C00)
//  80	 8192 ($2000)
//  90	 9216 ($2400)
//  a0	10240 ($2800)
//  b0	11264 ($2C00)
//  c0	12288 ($3000)
//  d0	13312 ($3400)
//  e0	14336 ($3800)
//  f0	15360 ($3C00)



// SID CHIP $D400
.label FRELO1       = $D400
.label FREHI1       = $D401
.label PWLO1        = $D402
.label PWHI1        = $D403
.label VCREG1       = $D404
.label ATDCY1       = $D405
.label SUREL1       = $D406
.label FRELO2       = $D407
.label FREHI2       = $D408
.label PWLO2        = $D409
.label PWHI2        = $D40A
.label VCREG2       = $D40B
.label ATDCY2       = $D40C
.label SUREL2       = $D40D
.label FRELO3       = $D40E
.label FREHI3       = $D40F
.label PWLO3        = $D410
.label PWHI3        = $D411
.label VCREG3       = $D412
.label ATDCY3       = $D413
.label SUREL3       = $D414
.label CUTLO        = $D415
.label CUTHI        = $D416
.label RESON        = $D417
.label SIGVOL       = $D418
.label POTX         = $D419
.label POTY         = $D41A
.label RANDOM       = $D41B
.label ENV3         = $D41C
//CIA#1
.label D1PRA        = $DC00
.label D1PRB        = $DC01
.label D1DDRA       = $DC02
.label D1DDRB       = $DC03
.label D1T1L        = $DC04
.label D1T1H        = $DC05
.label D1T2L        = $DC06
.label D1T2H        = $DC07
.label D1TOD1       = $DC08
.label D1TODS       = $DC09
.label D1TODM       = $DC0A
.label D1TODH       = $DC0B
.label D1SDR        = $DC0C
.label D1ICR        = $DC0D
.label D1CRA        = $DC0E
.label D1CRB        = $DC0F
//CIA#2
.label D2PRA        = $DD00
.label D2PRB        = $DD01
.label D2DDRA       = $DD02
.label D2DDRB       = $DD03
.label D2T1L        = $DD04
.label D2T1H        = $DD05
.label D2T2L        = $DD06
.label D2T2H        = $DD07
.label D2TOD2       = $DD08
.label D2TODS       = $DD09
.label D2TODM       = $DD0A
.label D2TODH       = $DD0B
.label D2SDR        = $DD0C
.label D2ICR        = $DD0D
.label D2CRA        = $DD0E
.label D2CRB        = $DD0F

//########## DINO_LABELS ##########

.label v_1D95       = $1D95
.label v_2BC0       = $2BC0
.label v_4011       = $4011
.label v_4012       = $4012
.label v_414A       = $414A
.label v_414B       = $414B
.label v_516E       = $516E
.label v_5615       = $5615
.label v_561B       = $561B
.label v_5621       = $5621
.label v_6525       = $6525
.label v_6526       = $6526
.label v_652C       = $652c
.label v_6530       = $6530



.label RAM8000      = $8000
.label RAM8400      = $8400
.label RAMC000      = $C000
.label RAMC400      = $C400
.label COLRAM       = $D800