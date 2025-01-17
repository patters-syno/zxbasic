	org 32768
__START_PROGRAM:
	di
	push ix
	push iy
	exx
	push hl
	exx
	ld hl, 0
	add hl, sp
	ld (__CALL_BACK__), hl
	ei
	call __PRINT_INIT
	jp __MAIN_PROGRAM__
__CALL_BACK__:
	DEFW 0
ZXBASIC_USER_DATA:
	; Defines USER DATA Length in bytes
ZXBASIC_USER_DATA_LEN EQU ZXBASIC_USER_DATA_END - ZXBASIC_USER_DATA
	.__LABEL__.ZXBASIC_USER_DATA_LEN EQU ZXBASIC_USER_DATA_LEN
	.__LABEL__.ZXBASIC_USER_DATA EQU ZXBASIC_USER_DATA
_a:
	DEFB 00, 00, 00, 00
ZXBASIC_USER_DATA_END:
__MAIN_PROGRAM__:
	ld hl, (_a)
	ld de, (_a + 2)
	call __PRINTU32
	ld hl, 0
	ld b, h
	ld c, l
__END_PROGRAM:
	di
	ld hl, (__CALL_BACK__)
	ld sp, hl
	exx
	pop hl
	exx
	pop iy
	pop ix
	ei
	ret
	;; --- end of user code ---
#line 1 "/zxbasic/src/arch/zx48k/library-asm/printu32.asm"
#line 1 "/zxbasic/src/arch/zx48k/library-asm/printi32.asm"
#line 1 "/zxbasic/src/arch/zx48k/library-asm/printnum.asm"
#line 1 "/zxbasic/src/arch/zx48k/library-asm/print.asm"
; vim:ts=4:sw=4:et:
; vim:ts=4:sw=4:et:
	; PRINT command routine
	; Does not print attribute. Use PRINT_STR or PRINT_NUM for that
#line 1 "/zxbasic/src/arch/zx48k/library-asm/sposn.asm"
	; Printing positioning library.
			PROC
			LOCAL ECHO_E
__LOAD_S_POSN:		; Loads into DE current ROW, COL print position from S_POSN mem var.
			ld de, (S_POSN)
			ld hl, (MAXX)
			or a
			sbc hl, de
			ex de, hl
			ret
__SAVE_S_POSN:		; Saves ROW, COL from DE into S_POSN mem var.
			ld hl, (MAXX)
			or a
			sbc hl, de
			ld (S_POSN), hl ; saves it again
			ret
	ECHO_E	EQU 23682
	MAXX	EQU ECHO_E   ; Max X position + 1
	MAXY	EQU MAXX + 1 ; Max Y position + 1
	S_POSN	EQU 23688
	POSX	EQU S_POSN		; Current POS X
	POSY	EQU S_POSN + 1	; Current POS Y
			ENDP
#line 7 "/zxbasic/src/arch/zx48k/library-asm/print.asm"
#line 1 "/zxbasic/src/arch/zx48k/library-asm/cls.asm"
	; JUMPS directly to spectrum CLS
	; This routine does not clear lower screen
	;CLS	EQU	0DAFh
	; Our faster implementation
CLS:
		PROC
		LOCAL COORDS
		LOCAL __CLS_SCR
		LOCAL ATTR_P
		LOCAL SCREEN
		ld hl, 0
		ld (COORDS), hl
	    ld hl, 1821h
		ld (S_POSN), hl
__CLS_SCR:
		ld hl, SCREEN
		ld (hl), 0
		ld d, h
		ld e, l
		inc de
		ld bc, 6144
		ldir
		; Now clear attributes
		ld a, (ATTR_P)
		ld (hl), a
		ld bc, 767
		ldir
		ret
	COORDS	EQU	23677
	SCREEN	EQU 16384 ; Default start of the screen (can be changed)
	ATTR_P	EQU 23693
	;you can poke (SCREEN_SCRADDR) to change CLS, DRAW & PRINTing address
	SCREEN_ADDR EQU (__CLS_SCR + 1) ; Address used by print and other screen routines
								    ; to get the start of the screen
		ENDP
#line 8 "/zxbasic/src/arch/zx48k/library-asm/print.asm"
#line 1 "/zxbasic/src/arch/zx48k/library-asm/in_screen.asm"
#line 1 "/zxbasic/src/arch/zx48k/library-asm/error.asm"
	; Simple error control routines
; vim:ts=4:et:
	ERR_NR    EQU    23610    ; Error code system variable
	; Error code definitions (as in ZX spectrum manual)
; Set error code with:
	;    ld a, ERROR_CODE
	;    ld (ERR_NR), a
	ERROR_Ok                EQU    -1
	ERROR_SubscriptWrong    EQU     2
	ERROR_OutOfMemory       EQU     3
	ERROR_OutOfScreen       EQU     4
	ERROR_NumberTooBig      EQU     5
	ERROR_InvalidArg        EQU     9
	ERROR_IntOutOfRange     EQU    10
	ERROR_NonsenseInBasic   EQU    11
	ERROR_InvalidFileName   EQU    14
	ERROR_InvalidColour     EQU    19
	ERROR_BreakIntoProgram  EQU    20
	ERROR_TapeLoadingErr    EQU    26
	; Raises error using RST #8
__ERROR:
	    ld (__ERROR_CODE), a
	    rst 8
__ERROR_CODE:
	    nop
	    ret
	; Sets the error system variable, but keeps running.
	; Usually this instruction if followed by the END intermediate instruction.
__STOP:
	    ld (ERR_NR), a
	    ret
#line 3 "/zxbasic/src/arch/zx48k/library-asm/in_screen.asm"
__IN_SCREEN:
		; Returns NO carry if current coords (D, E)
		; are OUT of the screen limits (MAXX, MAXY)
		PROC
		LOCAL __IN_SCREEN_ERR
		ld hl, MAXX
		ld a, e
		cp (hl)
		jr nc, __IN_SCREEN_ERR	; Do nothing and return if out of range
		ld a, d
		inc hl
		cp (hl)
		;; jr nc, __IN_SCREEN_ERR	; Do nothing and return if out of range
		;; ret
	    ret c                       ; Return if carry (OK)
__IN_SCREEN_ERR:
__OUT_OF_SCREEN_ERR:
		; Jumps here if out of screen
		ld a, ERROR_OutOfScreen
	    jp __STOP   ; Saves error code and exits
		ENDP
#line 9 "/zxbasic/src/arch/zx48k/library-asm/print.asm"
#line 1 "/zxbasic/src/arch/zx48k/library-asm/table_jump.asm"
JUMP_HL_PLUS_2A: ; Does JP (HL + A*2) Modifies DE. Modifies A
		add a, a
JUMP_HL_PLUS_A:	 ; Does JP (HL + A) Modifies DE
		ld e, a
		ld d, 0
JUMP_HL_PLUS_DE: ; Does JP (HL + DE)
		add hl, de
		ld e, (hl)
		inc hl
		ld d, (hl)
		ex de, hl
CALL_HL:
		jp (hl)
#line 10 "/zxbasic/src/arch/zx48k/library-asm/print.asm"
#line 1 "/zxbasic/src/arch/zx48k/library-asm/ink.asm"
	; Sets ink color in ATTR_P permanently
; Parameter: Paper color in A register
#line 1 "/zxbasic/src/arch/zx48k/library-asm/const.asm"
	; Global constants
	P_FLAG	EQU 23697
	FLAGS2	EQU 23681
	ATTR_P	EQU 23693	; permanet ATTRIBUTES
	ATTR_T	EQU 23695	; temporary ATTRIBUTES
	CHARS	EQU 23606 ; Pointer to ROM/RAM Charset
	UDG	EQU 23675 ; Pointer to UDG Charset
	MEM0	EQU 5C92h ; Temporary memory buffer used by ROM chars
#line 5 "/zxbasic/src/arch/zx48k/library-asm/ink.asm"
INK:
		PROC
		LOCAL __SET_INK
		LOCAL __SET_INK2
		ld de, ATTR_P
__SET_INK:
		cp 8
		jr nz, __SET_INK2
		inc de ; Points DE to MASK_T or MASK_P
		ld a, (de)
		or 7 ; Set bits 0,1,2 to enable transparency
		ld (de), a
		ret
__SET_INK2:
		; Another entry. This will set the ink color at location pointer by DE
		and 7	; # Gets color mod 8
		ld b, a	; Saves the color
		ld a, (de)
		and 0F8h ; Clears previous value
		or b
		ld (de), a
		inc de ; Points DE to MASK_T or MASK_P
		ld a, (de)
		and 0F8h ; Reset bits 0,1,2 sign to disable transparency
		ld (de), a ; Store new attr
		ret
	; Sets the INK color passed in A register in the ATTR_T variable
INK_TMP:
		ld de, ATTR_T
		jp __SET_INK
		ENDP
#line 11 "/zxbasic/src/arch/zx48k/library-asm/print.asm"
#line 1 "/zxbasic/src/arch/zx48k/library-asm/paper.asm"
	; Sets paper color in ATTR_P permanently
; Parameter: Paper color in A register
PAPER:
		PROC
		LOCAL __SET_PAPER
		LOCAL __SET_PAPER2
		ld de, ATTR_P
__SET_PAPER:
		cp 8
		jr nz, __SET_PAPER2
		inc de
		ld a, (de)
		or 038h
		ld (de), a
		ret
		; Another entry. This will set the paper color at location pointer by DE
__SET_PAPER2:
		and 7	; # Remove
		rlca
		rlca
		rlca		; a *= 8
		ld b, a	; Saves the color
		ld a, (de)
		and 0C7h ; Clears previous value
		or b
		ld (de), a
		inc de ; Points to MASK_T or MASK_P accordingly
		ld a, (de)
		and 0C7h  ; Resets bits 3,4,5
		ld (de), a
		ret
	; Sets the PAPER color passed in A register in the ATTR_T variable
PAPER_TMP:
		ld de, ATTR_T
		jp __SET_PAPER
		ENDP
#line 12 "/zxbasic/src/arch/zx48k/library-asm/print.asm"
#line 1 "/zxbasic/src/arch/zx48k/library-asm/flash.asm"
	; Sets flash flag in ATTR_P permanently
; Parameter: Paper color in A register
FLASH:
		ld hl, ATTR_P
	    PROC
	    LOCAL IS_TR
	    LOCAL IS_ZERO
__SET_FLASH:
		; Another entry. This will set the flash flag at location pointer by DE
		cp 8
		jr z, IS_TR
		; # Convert to 0/1
		or a
		jr z, IS_ZERO
		ld a, 0x80
IS_ZERO:
		ld b, a	; Saves the color
		ld a, (hl)
		and 07Fh ; Clears previous value
		or b
		ld (hl), a
		inc hl
		res 7, (hl)  ;Reset bit 7 to disable transparency
		ret
IS_TR:  ; transparent
		inc hl ; Points DE to MASK_T or MASK_P
		set 7, (hl)  ;Set bit 7 to enable transparency
		ret
	; Sets the FLASH flag passed in A register in the ATTR_T variable
FLASH_TMP:
		ld hl, ATTR_T
		jr __SET_FLASH
	    ENDP
#line 13 "/zxbasic/src/arch/zx48k/library-asm/print.asm"
#line 1 "/zxbasic/src/arch/zx48k/library-asm/bright.asm"
	; Sets bright flag in ATTR_P permanently
; Parameter: Paper color in A register
BRIGHT:
		ld hl, ATTR_P
	    PROC
	    LOCAL IS_TR
	    LOCAL IS_ZERO
__SET_BRIGHT:
		; Another entry. This will set the bright flag at location pointer by DE
		cp 8
		jr z, IS_TR
		; # Convert to 0/1
		or a
		jr z, IS_ZERO
		ld a, 0x40
IS_ZERO:
		ld b, a	; Saves the color
		ld a, (hl)
		and 0BFh ; Clears previous value
		or b
		ld (hl), a
		inc hl
		res 6, (hl)  ;Reset bit 6 to disable transparency
		ret
IS_TR:  ; transparent
		inc hl ; Points DE to MASK_T or MASK_P
	    set 6, (hl)  ;Set bit 6 to enable transparency
		ret
	; Sets the BRIGHT flag passed in A register in the ATTR_T variable
BRIGHT_TMP:
		ld hl, ATTR_T
		jr __SET_BRIGHT
	    ENDP
#line 14 "/zxbasic/src/arch/zx48k/library-asm/print.asm"
#line 1 "/zxbasic/src/arch/zx48k/library-asm/over.asm"
	; Sets OVER flag in P_FLAG permanently
; Parameter: OVER flag in bit 0 of A register
#line 1 "/zxbasic/src/arch/zx48k/library-asm/copy_attr.asm"
#line 4 "/zxbasic/src/arch/zx48k/library-asm/copy_attr.asm"
COPY_ATTR:
		; Just copies current permanent attribs into temporal attribs
		; and sets print mode
		PROC
		LOCAL INVERSE1
		LOCAL __REFRESH_TMP
	INVERSE1 EQU 02Fh
		ld hl, (ATTR_P)
		ld (ATTR_T), hl
		ld hl, FLAGS2
		call __REFRESH_TMP
		ld hl, P_FLAG
		call __REFRESH_TMP
__SET_ATTR_MODE:		; Another entry to set print modes. A contains (P_FLAG)
		LOCAL TABLE
		LOCAL CONT2
		rra					; Over bit to carry
		ld a, (FLAGS2)
		rla					; Over bit in bit 1, Over2 bit in bit 2
		and 3				; Only bit 0 and 1 (OVER flag)
		ld c, a
		ld b, 0
		ld hl, TABLE
		add hl, bc
		ld a, (hl)
		ld (PRINT_MODE), a
		ld hl, (P_FLAG)
		xor a			; NOP -> INVERSE0
		bit 2, l
		jr z, CONT2
		ld a, INVERSE1 	; CPL -> INVERSE1
CONT2:
		ld (INVERSE_MODE), a
		ret
TABLE:
		nop				; NORMAL MODE
		xor (hl)		; OVER 1 MODE
		and (hl)		; OVER 2 MODE
		or  (hl)		; OVER 3 MODE
#line 65 "/zxbasic/src/arch/zx48k/library-asm/copy_attr.asm"
__REFRESH_TMP:
		ld a, (hl)
		and 10101010b
		ld c, a
		rra
		or c
		ld (hl), a
		ret
		ENDP
#line 4 "/zxbasic/src/arch/zx48k/library-asm/over.asm"
OVER:
		PROC
		ld c, a ; saves it for later
		and 2
		ld hl, FLAGS2
		res 1, (HL)
		or (hl)
		ld (hl), a
		ld a, c	; Recovers previous value
		and 1	; # Convert to 0/1
		add a, a; # Shift left 1 bit for permanent
		ld hl, P_FLAG
		res 1, (hl)
		or (hl)
		ld (hl), a
		ret
	; Sets OVER flag in P_FLAG temporarily
OVER_TMP:
		ld c, a ; saves it for later
		and 2	; gets bit 1; clears carry
		rra
		ld hl, FLAGS2
		res 0, (hl)
		or (hl)
		ld (hl), a
		ld a, c	; Recovers previous value
		and 1
		ld hl, P_FLAG
		res 0, (hl)
	    or (hl)
		ld (hl), a
		jp __SET_ATTR_MODE
		ENDP
#line 15 "/zxbasic/src/arch/zx48k/library-asm/print.asm"
#line 1 "/zxbasic/src/arch/zx48k/library-asm/inverse.asm"
	; Sets INVERSE flag in P_FLAG permanently
; Parameter: INVERSE flag in bit 0 of A register
INVERSE:
		PROC
		and 1	; # Convert to 0/1
		add a, a; # Shift left 3 bits for permanent
		add a, a
		add a, a
		ld hl, P_FLAG
		res 3, (hl)
		or (hl)
		ld (hl), a
		ret
	; Sets INVERSE flag in P_FLAG temporarily
INVERSE_TMP:
		and 1
		add a, a
		add a, a; # Shift left 2 bits for temporary
		ld hl, P_FLAG
		res 2, (hl)
		or (hl)
		ld (hl), a
		jp __SET_ATTR_MODE
		ENDP
#line 16 "/zxbasic/src/arch/zx48k/library-asm/print.asm"
#line 1 "/zxbasic/src/arch/zx48k/library-asm/bold.asm"
	; Sets BOLD flag in P_FLAG permanently
; Parameter: BOLD flag in bit 0 of A register
BOLD:
		PROC
		and 1
		rlca
	    rlca
	    rlca
		ld hl, FLAGS2
		res 3, (HL)
		or (hl)
		ld (hl), a
		ret
	; Sets BOLD flag in P_FLAG temporarily
BOLD_TMP:
		and 1
		rlca
		rlca
		ld hl, FLAGS2
		res 2, (hl)
		or (hl)
		ld (hl), a
		ret
		ENDP
#line 17 "/zxbasic/src/arch/zx48k/library-asm/print.asm"
#line 1 "/zxbasic/src/arch/zx48k/library-asm/italic.asm"
	; Sets ITALIC flag in P_FLAG permanently
; Parameter: ITALIC flag in bit 0 of A register
ITALIC:
		PROC
		and 1
	    rrca
	    rrca
	    rrca
		ld hl, FLAGS2
		res 5, (HL)
		or (hl)
		ld (hl), a
		ret
	; Sets ITALIC flag in P_FLAG temporarily
ITALIC_TMP:
		and 1
		rrca
		rrca
		rrca
		rrca
		ld hl, FLAGS2
		res 4, (hl)
		or (hl)
		ld (hl), a
		ret
		ENDP
#line 18 "/zxbasic/src/arch/zx48k/library-asm/print.asm"
#line 1 "/zxbasic/src/arch/zx48k/library-asm/attr.asm"
	; Attribute routines
; vim:ts=4:et:sw:
__ATTR_ADDR:
	    ; calc start address in DE (as (32 * d) + e)
    ; Contributed by Santiago Romero at http://www.speccy.org
	    ld h, 0                     ;  7 T-States
	    ld a, d                     ;  4 T-States
	    add a, a     ; a * 2        ;  4 T-States
	    add a, a     ; a * 4        ;  4 T-States
	    ld l, a      ; HL = A * 4   ;  4 T-States
	    add hl, hl   ; HL = A * 8   ; 15 T-States
	    add hl, hl   ; HL = A * 16  ; 15 T-States
	    add hl, hl   ; HL = A * 32  ; 15 T-States
    ld d, 18h ; DE = 6144 + E. Note: 6144 is the screen size (before attr zone)
	    add hl, de
	    ld de, (SCREEN_ADDR)    ; Adds the screen address
	    add hl, de
	    ; Return current screen address in HL
	    ret
	; Sets the attribute at a given screen coordinate (D, E).
	; The attribute is taken from the ATTR_T memory variable
	; Used by PRINT routines
SET_ATTR:
	    ; Checks for valid coords
	    call __IN_SCREEN
	    ret nc
__SET_ATTR:
	    ; Internal __FASTCALL__ Entry used by printing routines
	    PROC
	    call __ATTR_ADDR
__SET_ATTR2:  ; Sets attr from ATTR_T to (HL) which points to the scr address
	    ld de, (ATTR_T)    ; E = ATTR_T, D = MASK_T
	    ld a, d
	    and (hl)
	    ld c, a    ; C = current screen color, masked
	    ld a, d
	    cpl        ; Negate mask
	    and e    ; Mask current attributes
	    or c    ; Mix them
	    ld (hl), a ; Store result in screen
	    ret
	    ENDP
	; Sets the attribute at a given screen pixel address in hl
	; HL contains the address in RAM for a given pixel (not a coordinate)
SET_PIXEL_ADDR_ATTR:
	    ;; gets ATTR position with offset given in SCREEN_ADDR
	    ld a, h
	    rrca
	    rrca
	    rrca
	    and 3
	    or 18h
	    ld h, a
	    ld de, (SCREEN_ADDR)
	    add hl, de  ;; Final screen addr
	    jp __SET_ATTR2
#line 20 "/zxbasic/src/arch/zx48k/library-asm/print.asm"
	; Putting a comment starting with @INIT <address>
	; will make the compiler to add a CALL to <address>
	; It is useful for initialization routines.
__PRINT_INIT: ; To be called before program starts (initializes library)
	        PROC
	        ld hl, __PRINT_START
	        ld (PRINT_JUMP_STATE), hl
	        ld hl, 1821h
	        ld (MAXX), hl  ; Sets current maxX and maxY
	        xor a
	        ld (FLAGS2), a
	        ret
__PRINTCHAR: ; Print character store in accumulator (A register)
	             ; Modifies H'L', B'C', A'F', D'E', A
	        LOCAL PO_GR_1
	        LOCAL __PRCHAR
	        LOCAL __PRINT_CONT
	        LOCAL __PRINT_CONT2
	        LOCAL __PRINT_JUMP
	        LOCAL __SRCADDR
	        LOCAL __PRINT_UDG
	        LOCAL __PRGRAPH
	        LOCAL __PRINT_START
	        LOCAL __ROM_SCROLL_SCR
	        LOCAL __TVFLAGS
	        __ROM_SCROLL_SCR EQU 0DFEh
	        __TVFLAGS EQU 5C3Ch
	PRINT_JUMP_STATE EQU __PRINT_JUMP + 1
__PRINT_JUMP:
	        jp __PRINT_START    ; Where to jump. If we print 22 (AT), next two calls jumps to AT1 and AT2 respectively
	        LOCAL __SCROLL
__SCROLL:  ; Scroll?
	        ld hl, __TVFLAGS
	        bit 1, (hl)
	        ret z
	        call __ROM_SCROLL_SCR
	        ld hl, __TVFLAGS
	        res 1, (hl)
	        ret
#line 76 "/zxbasic/src/arch/zx48k/library-asm/print.asm"
__PRINT_START:
	        cp ' '
	        jp c, __PRINT_SPECIAL    ; Characters below ' ' are special ones
	        exx               ; Switch to alternative registers
	        ex af, af'        ; Saves a value (char to print) for later
	        call __SCROLL
#line 87 "/zxbasic/src/arch/zx48k/library-asm/print.asm"
	        call __LOAD_S_POSN
	; At this point we have the new coord
	        ld hl, (SCREEN_ADDR)
	        ld a, d
	        ld c, a     ; Saves it for later
	        and 0F8h    ; Masks 3 lower bit ; zy
	        ld d, a
	        ld a, c     ; Recovers it
	        and 07h     ; MOD 7 ; y1
	        rrca
	        rrca
	        rrca
	        or e
	        ld e, a
	        add hl, de    ; HL = Screen address + DE
	        ex de, hl     ; DE = Screen address
	        ex af, af'
	        cp 80h    ; Is it an UDG or a ?
	        jp c, __SRCADDR
	        cp 90h
	        jp nc, __PRINT_UDG
	        ; Print a 8 bit pattern (80h to 8Fh)
	        ld b, a
	        call PO_GR_1 ; This ROM routine will generate the bit pattern at MEM0
	        ld hl, MEM0
	        jp __PRGRAPH
	PO_GR_1 EQU 0B38h
__PRINT_UDG:
	        sub 90h ; Sub ASC code
	        ld bc, (UDG)
	        jp __PRGRAPH0
	__SOURCEADDR EQU (__SRCADDR + 1)    ; Address of the pointer to chars source
__SRCADDR:
	        ld bc, (CHARS)
__PRGRAPH0:
        add a, a   ; A = a * 2 (since a < 80h) ; Thanks to Metalbrain at http://foro.speccy.org
	        ld l, a
	        ld h, 0    ; HL = a * 2 (accumulator)
	        add hl, hl
	        add hl, hl ; HL = a * 8
	        add hl, bc ; HL = CHARS address
__PRGRAPH:
	        ex de, hl  ; HL = Write Address, DE = CHARS address
	        bit 2, (iy + $47)
	        call nz, __BOLD
	        bit 4, (iy + $47)
	        call nz, __ITALIC
	        ld b, 8 ; 8 bytes per char
__PRCHAR:
	        ld a, (de) ; DE *must* be ALWAYS source, and HL destiny
PRINT_MODE:     ; Which operation is used to write on the screen
                ; Set it with:
	                ; LD A, <OPERATION>
	                ; LD (PRINT_MODE), A
	                ;
                ; Available opertions:
                ; NORMAL : 0h  --> NOP         ; OVER 0
                ; XOR    : AEh --> XOR (HL)    ; OVER 1
                ; OR     : B6h --> OR (HL)     ; PUTSPRITE
                ; AND    : A6h --> AND (HL)    ; PUTMASK
	        nop     ;
INVERSE_MODE:   ; 00 -> NOP -> INVERSE 0
	        nop     ; 2F -> CPL -> INVERSE 1
	        ld (hl), a
	        inc de
	        inc h     ; Next line
	        djnz __PRCHAR
	        call __LOAD_S_POSN
	        push de
	        call __SET_ATTR
	        pop de
	        inc e            ; COL = COL + 1
	        ld hl, (MAXX)
	        ld a, e
	        dec l            ; l = MAXX
	        cp l             ; Lower than max?
	        jp nc, __PRINT_EOL1
__PRINT_CONT:
	        call __SAVE_S_POSN
__PRINT_CONT2:
	        exx
	        ret
	; ------------- SPECIAL CHARS (< 32) -----------------
__PRINT_SPECIAL:    ; Jumps here if it is a special char
	        exx
	        ld hl, __PRINT_TABLE
	        jp JUMP_HL_PLUS_2A
PRINT_EOL:        ; Called WHENEVER there is no ";" at end of PRINT sentence
	        exx
__PRINT_0Dh:        ; Called WHEN printing CHR$(13)
	        call __SCROLL
#line 207 "/zxbasic/src/arch/zx48k/library-asm/print.asm"
	        call __LOAD_S_POSN
__PRINT_EOL1:        ; Another entry called from PRINT when next line required
	        ld e, 0
__PRINT_EOL2:
	        ld a, d
	        inc a
__PRINT_AT1_END:
	        ld hl, (MAXY)
	        cp l
	        jr c, __PRINT_EOL_END    ; Carry if (MAXY) < d
	        ld hl, __TVFLAGS
	        set 1, (hl)
	        dec a
#line 227 "/zxbasic/src/arch/zx48k/library-asm/print.asm"
__PRINT_EOL_END:
	        ld d, a
__PRINT_AT2_END:
	        call __SAVE_S_POSN
	        exx
	        ret
__PRINT_COM:
	        exx
	        push hl
	        push de
	        push bc
	        call PRINT_COMMA
	        pop bc
	        pop de
	        pop hl
	        ret
__PRINT_TAB:
	        ld hl, __PRINT_TAB1
	        jr __PRINT_SET_STATE
__PRINT_TAB1:
	        ld (MEM0), a
	        exx
	        ld hl, __PRINT_TAB2
	        jr __PRINT_SET_STATE
__PRINT_TAB2:
	        ld a, (MEM0)        ; Load tab code (ignore the current one)
	        push hl
	        push de
	        push bc
	        ld hl, __PRINT_START
	        ld (PRINT_JUMP_STATE), hl
	        call PRINT_TAB
	        pop bc
	        pop de
	        pop hl
	        ret
__PRINT_NOP:
__PRINT_RESTART:
	        ld hl, __PRINT_START
	        jr __PRINT_SET_STATE
__PRINT_AT:
	        ld hl, __PRINT_AT1
__PRINT_SET_STATE:
	        ld (PRINT_JUMP_STATE), hl    ; Saves next entry call
	        exx
	        ret
__PRINT_AT1:    ; Jumps here if waiting for 1st parameter
	        exx
	        ld hl, __PRINT_AT2
	        ld (PRINT_JUMP_STATE), hl    ; Saves next entry call
	        call __LOAD_S_POSN
	        jr __PRINT_AT1_END
__PRINT_AT2:
	        exx
	        ld hl, __PRINT_START
	        ld (PRINT_JUMP_STATE), hl    ; Saves next entry call
	        call __LOAD_S_POSN
	        ld e, a
	        ld hl, (MAXX)
	        cp l
	        jr c, __PRINT_AT2_END
	        jr __PRINT_EOL1
__PRINT_DEL:
	        call __LOAD_S_POSN        ; Gets current screen position
	        dec e
	        ld a, -1
	        cp e
	        jp nz, __PRINT_AT2_END
	        ld hl, (MAXX)
	        ld e, l
	        dec e
	        dec e
	        dec d
	        cp d
	        jp nz, __PRINT_AT2_END
	        ld d, h
	        dec d
	        jp __PRINT_AT2_END
__PRINT_INK:
	        ld hl, __PRINT_INK2
	        jp __PRINT_SET_STATE
__PRINT_INK2:
	        exx
	        call INK_TMP
	        jp __PRINT_RESTART
__PRINT_PAP:
	        ld hl, __PRINT_PAP2
	        jp __PRINT_SET_STATE
__PRINT_PAP2:
	        exx
	        call PAPER_TMP
	        jp __PRINT_RESTART
__PRINT_FLA:
	        ld hl, __PRINT_FLA2
	        jp __PRINT_SET_STATE
__PRINT_FLA2:
	        exx
	        call FLASH_TMP
	        jp __PRINT_RESTART
__PRINT_BRI:
	        ld hl, __PRINT_BRI2
	        jp __PRINT_SET_STATE
__PRINT_BRI2:
	        exx
	        call BRIGHT_TMP
	        jp __PRINT_RESTART
__PRINT_INV:
	        ld hl, __PRINT_INV2
	        jp __PRINT_SET_STATE
__PRINT_INV2:
	        exx
	        call INVERSE_TMP
	        jp __PRINT_RESTART
__PRINT_OVR:
	        ld hl, __PRINT_OVR2
	        jp __PRINT_SET_STATE
__PRINT_OVR2:
	        exx
	        call OVER_TMP
	        jp __PRINT_RESTART
__PRINT_BOLD:
	        ld hl, __PRINT_BOLD2
	        jp __PRINT_SET_STATE
__PRINT_BOLD2:
	        exx
	        call BOLD_TMP
	        jp __PRINT_RESTART
__PRINT_ITA:
	        ld hl, __PRINT_ITA2
	        jp __PRINT_SET_STATE
__PRINT_ITA2:
	        exx
	        call ITALIC_TMP
	        jp __PRINT_RESTART
__BOLD:
	        push hl
	        ld hl, MEM0
	        ld b, 8
__BOLD_LOOP:
	        ld a, (de)
	        ld c, a
	        rlca
	        or c
	        ld (hl), a
	        inc hl
	        inc de
	        djnz __BOLD_LOOP
	        pop hl
	        ld de, MEM0
	        ret
__ITALIC:
	        push hl
	        ld hl, MEM0
	        ex de, hl
	        ld bc, 8
	        ldir
	        ld hl, MEM0
	        srl (hl)
	        inc hl
	        srl (hl)
	        inc hl
	        srl (hl)
	        inc hl
	        inc hl
	        inc hl
	        sla (hl)
	        inc hl
	        sla (hl)
	        inc hl
	        sla (hl)
	        pop hl
	        ld de, MEM0
	        ret
PRINT_COMMA:
	        call __LOAD_S_POSN
	        ld a, e
	        and 16
	        add a, 16
PRINT_TAB:
	        PROC
	        LOCAL LOOP, CONTINUE
	        inc a
	        call __LOAD_S_POSN ; e = current row
	        ld d, a
	        ld a, e
	        cp 21h
	        jr nz, CONTINUE
	        ld e, -1
CONTINUE:
	        ld a, d
	        inc e
	        sub e  ; A = A - E
	        and 31 ;
	        ret z  ; Already at position E
	        ld b, a
LOOP:
	        ld a, ' '
	        push bc
	        exx
	        call __PRINTCHAR
	        exx
	        pop bc
	        djnz LOOP
	        ret
	        ENDP
PRINT_AT: ; Changes cursor to ROW, COL
	         ; COL in A register
	         ; ROW in stack
	        pop hl    ; Ret address
	        ex (sp), hl ; callee H = ROW
	        ld l, a
	        ex de, hl
	        call __IN_SCREEN
	        ret nc    ; Return if out of screen
	        ld hl, __TVFLAGS
	        res 1, (hl)
#line 483 "/zxbasic/src/arch/zx48k/library-asm/print.asm"
	        jp __SAVE_S_POSN
	        LOCAL __PRINT_COM
	        LOCAL __BOLD
	        LOCAL __BOLD_LOOP
	        LOCAL __ITALIC
	        LOCAL __PRINT_EOL1
	        LOCAL __PRINT_EOL2
	        LOCAL __PRINT_AT1
	        LOCAL __PRINT_AT2
	        LOCAL __PRINT_AT2_END
	        LOCAL __PRINT_BOLD
	        LOCAL __PRINT_BOLD2
	        LOCAL __PRINT_ITA
	        LOCAL __PRINT_ITA2
	        LOCAL __PRINT_INK
	        LOCAL __PRINT_PAP
	        LOCAL __PRINT_SET_STATE
	        LOCAL __PRINT_TABLE
	        LOCAL __PRINT_TAB, __PRINT_TAB1, __PRINT_TAB2
__PRINT_TABLE:    ; Jump table for 0 .. 22 codes
	        DW __PRINT_NOP    ;  0
	        DW __PRINT_NOP    ;  1
	        DW __PRINT_NOP    ;  2
	        DW __PRINT_NOP    ;  3
	        DW __PRINT_NOP    ;  4
	        DW __PRINT_NOP    ;  5
	        DW __PRINT_COM    ;  6 COMMA
	        DW __PRINT_NOP    ;  7
	        DW __PRINT_DEL    ;  8 DEL
	        DW __PRINT_NOP    ;  9
	        DW __PRINT_NOP    ; 10
	        DW __PRINT_NOP    ; 11
	        DW __PRINT_NOP    ; 12
	        DW __PRINT_0Dh    ; 13
	        DW __PRINT_BOLD   ; 14
	        DW __PRINT_ITA    ; 15
	        DW __PRINT_INK    ; 16
	        DW __PRINT_PAP    ; 17
	        DW __PRINT_FLA    ; 18
	        DW __PRINT_BRI    ; 19
	        DW __PRINT_INV    ; 20
	        DW __PRINT_OVR    ; 21
	        DW __PRINT_AT     ; 22 AT
	        DW __PRINT_TAB    ; 23 TAB
	        ENDP
#line 2 "/zxbasic/src/arch/zx48k/library-asm/printnum.asm"
__PRINTU_START:
		PROC
		LOCAL __PRINTU_CONT
		ld a, b
		or a
		jp nz, __PRINTU_CONT
		ld a, '0'
		jp __PRINT_DIGIT
__PRINTU_CONT:
		pop af
		push bc
		call __PRINT_DIGIT
		pop bc
		djnz __PRINTU_CONT
		ret
		ENDP
__PRINT_MINUS: ; PRINT the MINUS (-) sign. CALLER mus preserve registers
		ld a, '-'
		jp __PRINT_DIGIT
	__PRINT_DIGIT EQU __PRINTCHAR ; PRINTS the char in A register, and puts its attrs
#line 2 "/zxbasic/src/arch/zx48k/library-asm/printi32.asm"
#line 1 "/zxbasic/src/arch/zx48k/library-asm/neg32.asm"
__ABS32:
		bit 7, d
		ret z
__NEG32: ; Negates DEHL (Two's complement)
		ld a, l
		cpl
		ld l, a
		ld a, h
		cpl
		ld h, a
		ld a, e
		cpl
		ld e, a
		ld a, d
		cpl
		ld d, a
		inc l
		ret nz
		inc h
		ret nz
		inc de
		ret
#line 3 "/zxbasic/src/arch/zx48k/library-asm/printi32.asm"
#line 1 "/zxbasic/src/arch/zx48k/library-asm/div32.asm"
				 ; ---------------------------------------------------------
__DIVU32:    ; 32 bit unsigned division
	             ; DEHL = Dividend, Stack Top = Divisor
	             ; OPERANDS P = Dividend, Q = Divisor => OPERATION => P / Q
				 ;
				 ; Changes A, BC DE HL B'C' D'E' H'L'
				 ; ---------------------------------------------------------
	        exx
	        pop hl   ; return address
	        pop de   ; low part
	        ex (sp), hl ; CALLEE Convention ; H'L'D'E' => Dividend
__DIVU32START: ; Performs D'E'H'L' / HLDE
	        ; Now switch to DIVIDEND = B'C'BC / DIVISOR = D'E'DE (A / B)
	        push de ; push Lowpart(Q)
			ex de, hl	; DE = HL
	        ld hl, 0
	        exx
	        ld b, h
	        ld c, l
	        pop hl
	        push de
	        ex de, hl
	        ld hl, 0        ; H'L'HL = 0
	        exx
	        pop bc          ; Pop HightPart(B) => B = B'C'BC
	        exx
	        ld a, 32 ; Loop count
__DIV32LOOP:
	        sll c  ; B'C'BC << 1 ; Output most left bit to carry
	        rl  b
	        exx
	        rl c
	        rl b
	        exx
	        adc hl, hl
	        exx
	        adc hl, hl
	        exx
	        sbc hl,de
	        exx
	        sbc hl,de
	        exx
	        jp nc, __DIV32NOADD	; use JP inside a loop for being faster
	        add hl, de
	        exx
	        adc hl, de
	        exx
	        dec bc
__DIV32NOADD:
	        dec a
	        jp nz, __DIV32LOOP	; use JP inside a loop for being faster
	        ; At this point, quotient is stored in B'C'BC and the reminder in H'L'HL
	        push hl
	        exx
	        pop de
	        ex de, hl ; D'E'H'L' = 32 bits modulus
	        push bc
	        exx
	        pop de    ; DE = B'C'
	        ld h, b
	        ld l, c   ; DEHL = quotient D'E'H'L' = Modulus
	        ret     ; DEHL = quotient, D'E'H'L' = Modulus
__MODU32:    ; 32 bit modulus for 32bit unsigned division
	             ; DEHL = Dividend, Stack Top = Divisor (DE, HL)
	        exx
	        pop hl   ; return address
	        pop de   ; low part
	        ex (sp), hl ; CALLEE Convention ; H'L'D'E' => Dividend
	        call __DIVU32START	; At return, modulus is at D'E'H'L'
__MODU32START:
			exx
			push de
			push hl
			exx
			pop hl
			pop de
			ret
__DIVI32:    ; 32 bit signed division
	             ; DEHL = Dividend, Stack Top = Divisor
	             ; A = Dividend, B = Divisor => A / B
	        exx
	        pop hl   ; return address
	        pop de   ; low part
	        ex (sp), hl ; CALLEE Convention ; H'L'D'E' => Dividend
__DIVI32START:
			exx
			ld a, d	 ; Save sign
			ex af, af'
			bit 7, d ; Negative?
			call nz, __NEG32 ; Negates DEHL
			exx		; Now works with H'L'D'E'
			ex af, af'
			xor h
			ex af, af'  ; Stores sign of the result for later
			bit 7, h ; Negative?
			ex de, hl ; HLDE = DEHL
			call nz, __NEG32
			ex de, hl
			call __DIVU32START
			ex af, af' ; Recovers sign
			and 128	   ; positive?
			ret z
			jp __NEG32 ; Negates DEHL and returns from there
__MODI32:	; 32bits signed division modulus
			exx
	        pop hl   ; return address
	        pop de   ; low part
	        ex (sp), hl ; CALLEE Convention ; H'L'D'E' => Dividend
			call __DIVI32START
			jp __MODU32START
#line 4 "/zxbasic/src/arch/zx48k/library-asm/printi32.asm"
__PRINTI32:
		ld a, d
		or a
		jp p, __PRINTU32
		call __PRINT_MINUS
		call __NEG32
__PRINTU32:
		PROC
		LOCAL __PRINTU_LOOP
		ld b, 0 ; Counter
__PRINTU_LOOP:
		ld a, h
		or l
		or d
		or e
		jp z, __PRINTU_START
		push bc
		ld bc, 0
		push bc
		ld bc, 10
		push bc		  ; Push 00 0A (10 Dec) into the stack = divisor
		call __DIVU32 ; Divides by 32. D'E'H'L' contains modulo (L' since < 10)
		pop bc
		exx
		ld a, l
		or '0'		  ; Stores ASCII digit (must be print in reversed order)
		push af
		exx
		inc b
		jp __PRINTU_LOOP ; Uses JP in loops
		ENDP
#line 2 "/zxbasic/src/arch/zx48k/library-asm/printu32.asm"
#line 20 "print_u32.bas"
	END
