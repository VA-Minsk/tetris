;???? "??????"


;macro HELP
clearScreen MACRO
	push ax
	mov ax, 0003h
	int 10h
	pop ax
ENDM
;end macro help

.model small

.stack 100h

.data

LEVEL_WAIT_INIT	equ		700
START_POS		equ		280

HISCORE_POS     equ		24
SCORE_POS		equ		264
LEVEL_POS		equ		424

BORDER_CHAR			equ		32
BORDER_COLOR		equ     29

HISCORE_TEXT_POS	equ		0
SCORE_TEXT_POS		equ		240
LEVEL_TEXT_POS		equ		400
LOGO_POS			equ		800
BY_POS				equ 	970
TORE_POS			equ 	1128
BAST_POS			equ		1202
PREVIEW_TEXT_POS	equ		134
GAME_OVER_POS		equ		934
PLAY_AGAIN_POS		equ     1654
PAUSE_POS			equ 	934


PREVIEW_POS		equ		380

Timer 		dw 	0
LevelWait   dw	LEVEL_WAIT_INIT
Level		dw	1
StartLevel	dw	1
Pos			dw	START_POS
Item		dw	0
Rotated		dw	0
Drops		dw  0
RandSeed    dw	0
Paused      db  0
HiScoreData db	14,0
HiScoreName db	15 dup ('$')
HiScore 	dd	0
OldInt1c 	db  4 dup (0)
Score		dw	2 dup (0)
OldRand		dw	1 dup (0)
PreItem		dw	1 dup (0)
TimerInit	dw	1 dup (0)


GameOverText label word
	db	'GAME OVER',0
	db 	'Play again?',0
RowFill		db	25 dup (0)
EnterName	db	'Enter name:',10,13,'$'

;blocks
BLOCK	equ		254

COLOR1	equ		65
COLOR2	equ     36
COLOR3	equ     23
COLOR4	equ     19
COLOR5	equ     45
COLOR6	equ     78
COLOR7	equ     124

Items label word
	db	BLOCK,	COLOR1,	176,  40,  40,  40
	db	BLOCK,	COLOR1,	214,   1,   1,   1
	db	BLOCK,	COLOR1,	176,  40,  40,	40
	db	BLOCK,	COLOR1,	214,   1,	1,	 1

	db	BLOCK,	COLOR2,	215,  40,  40,	 1
	db	BLOCK,	COLOR2,	217,  38,	1,	 1
	db	BLOCK,	COLOR2,	215,   1,  40,	40
	db	BLOCK,	COLOR2,	215,   1,	1,	38

	db	BLOCK,	COLOR3,	217,  40,  39,	 1
	db	BLOCK,	COLOR3,	215,   1,	1,	40
	db	BLOCK,	COLOR3,	215,   1,  39,	40
	db	BLOCK,	COLOR3,	255,  40,	1,	 1

	db	BLOCK,	COLOR4,	215,   1,	1,	39
	db	BLOCK,	COLOR4,	215,  40,	1,	39
	db	BLOCK,	COLOR4,	216,  39,	1,	 1
	db	BLOCK,	COLOR4,	216,  39,	1,	40

	db	BLOCK,	COLOR5,	215,   1,  39,	 1
	db	BLOCK,	COLOR5,	215,   1,  39,	 1
	db	BLOCK,	COLOR5,	215,   1,  39,	 1
	db	BLOCK,	COLOR5,	215,   1,  39,	 1

	db	BLOCK,	COLOR6,	215,   1,  40,	 1
	db	BLOCK,	COLOR6,	216,  39,	1,	39
	db	BLOCK,	COLOR6,	215,   1,  40,	 1
	db	BLOCK,	COLOR6,	216,  39,	1,	39

	db	BLOCK,	COLOR7,	216,   1,  38,	 1
	db	BLOCK,	COLOR7,	216,  40,	1,	40
	db	BLOCK,	COLOR7,	216,   1,  38,	 1
	db	BLOCK,	COLOR7,	216,  40,	1,	40

;temporary
TetrisLogo dw 0



;key bindings (configuration)
KRotate equ 48h	    ;Up key
KLeft equ 4Bh	    ;Left key
KRight equ 4Dh		;Right key
KExit equ 01h 		;ESC key

xSize equ 80
ySize equ 18
xField equ 25           ;size of playground
yField equ 14
oneMemoBlock equ 2
scoreSize equ 4

videoStart dw 0B800h
dataStart dw 0000h
timeStart dw 0040h
timePosition dw 006Ch

space equ 0020h
Figure1Symbol equ 0AEFh
Figure2Symbol equ 0B0Fh
VWallSymbol equ 0FBAh
HWallSymbol equ 0FCDh
VWallSpecialSymbol equ 0FCCh

fieldSpacingBad equ space, VWallSymbol, xField dup(space)
fieldSpacing equ fieldSpacingBad, VWallSymbol
rbSym equ 0CFDCh	;white block with red background
rbSpc equ 0CF20h	;space with red background
grSym equ 02FDBh	;white block with green background
grSpc equ 02F20h	;space with green background

screen	dw xSize dup(space)
		dw space, 0FC9h, xField dup(HWallSymbol), 0FCBh, xSize - xField - 5 dup(HWallSymbol), 0FBBh, space
firstBl	dw fieldSpacing, xSize - xField - 5 dup(rbSpc), VWallSymbol, space
		dw fieldSpacing, 2 dup(rbSpc), 7 dup(rbSym), 3 dup(rbSpc),4 dup(rbSym), 3 dup(rbSpc), 7 dup(rbSym), 3 dup(rbSpc),3 dup(rbSym), 3 dup(rbSpc),5 dup(rbSym), 3 dup(rbSpc), 5 dup(rbSym) ,2 dup(rbSpc), VWallSymbol, space
		dw fieldSpacing, 5 dup(rbSpc), rbSym, 6 dup(rbSpc),rbSym, 9 dup(rbSpc), rbSym, 6 dup(rbSpc),rbSym, 2 dup(rbSpc), rbSym, 4 dup(rbSpc), rbSym, 5 dup(rbSpc), rbSym, 6 dup(rbSpc) , VWallSymbol, space
		dw fieldSpacing, 5 dup(rbSpc), rbSym, 6 dup(rbSpc),4 dup (rbSym), 6 dup(rbSpc), rbSym, 6 dup(rbSpc),3 dup (rbSym), 5 dup(rbSpc), rbSym, 5 dup(rbSpc), 5 dup (rbSym) , 2 dup(rbSpc) , VWallSymbol, space
		dw fieldSpacing, 5 dup(rbSpc), rbSym, 6 dup(rbSpc),rbSym, 9 dup(rbSpc), rbSym, 6 dup(rbSpc) ,rbSym, rbSpc, rbSym,5 dup(rbSpc), rbSym, 9 dup(rbSpc), rbSym, 2 dup(rbSpc) , VWallSymbol, space
		dw fieldSpacing, 5 dup(rbSpc), rbSym, 6 dup(rbSpc),4 dup (rbSym), 6 dup(rbSpc), rbSym, 6 dup(rbSpc),rbSym, 2 dup(rbSpc), rbSym, 2 dup(rbSpc), 5 dup (rbSym), 3 dup(rbSpc), 5 dup(rbSym), 2 dup(rbSpc) , VWallSymbol, space
		dw fieldSpacing, xSize - xField - 5 dup(rbSpc), VWallSymbol, space  
		
delim1	dw fieldSpacingBad, 0FCCh, xSize - xField - 5 dup(HWallSymbol), 0FB9h, space  

secondF	dw fieldSpacing, xSize - xField - 5 dup(grSpc), VWallSymbol, space
		dw fieldSpacing, 12 dup (grSpc), 7 dup (grSym), 5 dup (grSpc),grSym, 3 dup (grSpc), grSym, 5 dup (grSpc), 4 dup (grSym), 12 dup (grSpc), VWallSymbol, space
        dw fieldSpacing, 15 dup (grSpc), grSym, 8 dup (grSpc),grSym, 3 dup (grSpc), grSym, 5 dup (grSpc), grSym, 15 dup (grSpc), VWallSymbol, space	
        dw fieldSpacing, 15 dup (grSpc), grSym, 9 dup (grSpc),grSym, 1 dup (grSpc), grSym, 6 dup (grSpc), 4 dup (grSym), 12 dup (grSpc), VWallSymbol, space	
        dw fieldSpacing, 15 dup (grSpc), grSym, 9 dup (grSpc),grSym, 1 dup (grSpc), grSym, 9 dup (grSpc), grSym, 12 dup (grSpc), VWallSymbol, space	                                                                                                                                                                     
        dw fieldSpacing, 15 dup (grSpc), grSym, 10 dup (grSpc),grSym, 7 dup (grSpc), 4 dup (grSym), 12 dup (grSpc), VWallSymbol, space	
	    dw fieldSpacing, xSize - xField - 5 dup(grSpc), VWallSymbol, space                                                                                                                                                            
		  		
		dw space, 0FC8h, xField dup(HWallSymbol), 0FCAh, xSize - xField - 5 dup(HWallSymbol), 0FBCh, space
		dw xSize dup(space)
.code

main:
	mov ax, @data	;init
	mov ds, ax
	mov dataStart, ax
	mov ax, videoStart
	mov es, ax
	xor ax, ax

	clearScreen

	call initAllScreen

	call mainGame

to_close:
	mov ah, 4ch
	int 21h

	;it is the end

;more macro help

;ZF = 1 - buffer is free
;AH = scan-code
CheckBuffer MACRO
	mov ah, 01h
	int 16h
ENDM

ReadFromBuffer MACRO
	mov ah, 00h
	int 16h
ENDM

;result in cx:dx
GetTimerValue MACRO
	push ax 

	mov ax, 00h
	int 1Ah

	pop ax
ENDM

;end macro help

;procedure help

initAllScreen PROC
	mov si, offset screen
	xor di, di

	mov cx, xSize*ySize
	rep movsw
	ret
ENDP   

Sleep PROC
	push ax bx cx dx

	GetTimerValue

	add dx, 3
	mov bx, dx

checkTimeLoop:
	GetTimerValue
	cmp dx, bx			;ax - current value, bx - needed value
	jl checkTimeLoop

	pop dx cx bx ax
	ret
ENDP

mainGame PROC

;	Play again starts here
restart:
	call    RandInit  				; Initialize random numbers
	
	xor 	di,di
	mov		ax,0b800h
	mov		es,ax


no_init_preview:	;143
;	Main loop
;	*********

	jmp     checkKeyPressing

for_ever:
	call 	Sleep

	call    Down                  ; go down
	or		ax,ax
	jne		checkKeyPressing
	jmp		game_over

checkKeyPressing:
	CheckBuffer
	jz      for_ever						;клавишу не нажали

	;call    GetKey        	  		; al=getkey
	ReadFromBuffer

	;; todo:stop

	cmp		al, KExit
	je 		quit
	cmp		al, KLeft
	je 		go_left
	cmp		al, KRight
	je 		go_right
	cmp		al, KRotate
	je 		go_rotate

	jmp for_ever

go_left:
	push	si
	mov		si,-2
	call    Move
	pop		si
	jmp     checkKeyPressing
go_right:
	push	si
	mov		si,2
	call    Move
	pop		si
	jmp     checkKeyPressing
go_drop:
	call    Drop
	or		ax,ax
	je		game_over
	jmp     checkKeyPressing
go_rotate:
	call    Rotate
	jmp     checkKeyPressing
game_over:
	jmp quit

;	Close down
;	**********
quit:

    ret
ENDP

Drop	proc	near
	push	si
	mov		si,80
drop_more:
	call	Move
	inc		word ptr Drops
	or		ax,ax
	jne		drop_more

	call	near ptr Down
	pop		si
	ret
Drop	endp

Down	proc	near
	push 	si
	mov     si,80
	call	Move

	or		ax,ax						; room?
	je		get_new							; no
	pop		si
	ret
get_new:
	mov		ax,word ptr Item
	add		ax,word ptr Rotated
	mov		di,word ptr Pos
	call	near ptr Bottom			; reached the bottom

	call	near ptr Rand7			; get new item
	shl		ax,1
	shl		ax,1
	mov		word ptr Item,ax
	mov		word ptr Pos,START_POS
	mov		word ptr Rotated,0

;	Test if new tetris can be printed
	mov		ax,word ptr Item
	add		ax,word ptr Rotated
	mov		di,Pos
	call	TestSpace
	or		ax,ax
	jne		place_new

;	There was no room. Return false!
	pop		si
	ret

; 	There was room. Print tetris.
place_new:
	mov		si,1
	mov		ax,word ptr Item
	add		ax,word ptr Rotated
	mov		di,Pos
	call	Print
	mov		ax,	word ptr TimerInit
	mov		word ptr Timer,ax

no_preview:
	mov     ax,1
	pop 	si
	ret
Down	endp

PrintPreView	proc near
	mov		si,1
	mov		ax,OldRand
	shl		ax,1
	shl		ax,1
	mov		PreItem,ax
	mov		di,PREVIEW_POS
	call	Print
	ret
PrintPreView	endp

RemovePreView	proc near
	xor 	si,si
	mov		ax,word ptr PreItem
	mov		di,PREVIEW_POS
	call	Print
	ret
RemovePreView	endp

GetKey proc    near
	mov      ah,07h
	mov      dl,0ffh
	int      21h
	ret
GetKey endp

RandInit       proc    near
	mov     bp,sp
	sub     sp,4
	mov      ah,02h
	int      1ah
	mov      [bp-2],cl
	mov      [bp-4],dh
	mov     ax,word ptr [bp-2]
	imul    word ptr [bp-4]
	mov     word ptr randseed,ax
	mov     sp,bp
	call    Rand7
	ret
RandInit       endp

Rand7  proc    near
	mov     ax, word ptr randseed
	imul    word ptr randseed

	test    ax,1
	je      even_number
	add     ax,3172
	mov     word ptr randseed,ax
	jmp     skip_even
even_number:
	shl		ax,1
	add		ax,Score
skip_even:
	mov     word ptr randseed,ax
	mov     bx,7
	xor     dx,dx
	div     bx
	mov     ax, word ptr OldRand
	mov		word ptr OldRand, dx
	ret
Rand7  endp

Print	proc	near					;ax= item_nr    di=scroffs si=T/F
	mov		dx,0b800h
	mov		es,dx
	mov 	dx,06
	imul    dx                      	; ax=ax*6
	add 	ax, offset Items      		; ax+=[_items]

	xor		dx,dx		   				; for dx=3 to 0

	cmp		si,0
	je 		loop2
	mov 	bx,ax
	mov		si,ds:[bx]
loop2:
	mov 	bx,ax
	add 	bx,dx
	push	ax
	mov 	al,byte ptr [bx+2]
	cbw
	shl		ax,1
	add		di,ax
	pop		ax
	mov 	es:[di],si
	inc     dx
	cmp		dx,4
	jne	    loop2
	ret
Print	endp

PrintLong	proc 					;print number

	mov		bx,0b800h
	mov		es,bx

	mov		bx,10
more_digits:
	div		bx
	add		dx,'0'+256*7
	mov		es:[di],dx
	sub		di,2
	mov		dx,0
	cmp		ax,0
	jne		more_digits
	ret
PrintLong	endp

Bottom	proc	near      	;ax=ItemNr			di=scroffset
	mov		dx,0b800h
	mov		es,dx
	mov 	dx,06

	imul    dx
	add 	ax, offset Items     			; ax=ax*6

	xor 	cx,cx                           ; for cx=0 to 3
loop_b1:
	mov 	bx,ax
	add 	bx,cx
	push	ax
	mov 	al,byte ptr [bx+2]
	cbw
	shl		ax,1
	add 	di,ax
	mov		ax,di
	xor		dx,dx
	mov		bx,80
	div		bx
	mov		bx,ax
	inc		byte ptr RowFill[bx]
	pop		ax
	inc     cx
	cmp		cx,4
	jne	    loop_b1

	xor		bx,bx
loop_b2:
	cmp		byte ptr RowFill[bx],10
	jne		not_full
	push	bx
	call	DeleteRow
	inc		word ptr randseed
	pop		bx
not_full:
	inc 	bx
	cmp		bx,24
	jne		loop_b2

	ret
Bottom	endp

TestSpace	proc	near		;ax= item_nr    di=scroffs
	mov		dx,0b800h
	mov		es,dx
	mov 	dx,06
	imul    dx
	add 	ax, offset Items     			; ax=ax*6

	xor 	dx,dx                           ; for dx=0 to 3
loop1:
	mov 	bx,ax
	add 	bx,dx
	push	ax
	mov 	al,byte ptr [bx+2]
	cbw
	shl		ax,1
	add 	di,ax
	pop		ax
	cmp 	word ptr es:[di],0
	jne	 	bad
	inc     dx
	cmp		dx,4
	jne	    loop1
	mov		ax,01
	ret
bad:
	xor		ax,ax
	ret
TestSpace	endp

DeleteRow	proc	near				;bx=Row

	mov		dx,0b800h
	mov		es,dx

	dec		bx
	mov		cx,bx
	mov		ax,bx

	mov		dx,80
	imul	dx
	add		ax,30						   		; ax=source offset

	mov		si,ax
loop_d1:
	mov		di,si
	add		di,80
	push 	cx
	mov     cx,10
	push	ds
	push	es
	pop		ds
	rep	movsw
	pop 	ds
	sub		si,100

	mov 	cl,byte ptr RowFill[bx]
	mov		byte ptr RowFill[bx+1],cl
	dec		bx

	pop		cx
	loop   	loop_d1

	ret
DeleteRow	endp

Move proc near					; si=dPos
	push 	si

	xor		si,si
	mov		ax,word ptr Item
	add		ax,word ptr Rotated
	mov		di,word ptr Pos
	call	near ptr Print				; remove old

	mov		ax,word ptr Item
	add		ax,word ptr Rotated
	mov 	di,word ptr Pos
	pop 	si
	add		di,si
	push 	si
	call	near ptr TestSpace				; test if room
	pop     si
	push	ax
	or		ax,ax
	je		no_room
	add		word ptr Pos,si				; ok, add Pos
no_room:
	push	si
	mov 	si,1
	mov		ax,word ptr Item
	add		ax,word ptr Rotated
	mov		di,word ptr Pos
	call	near ptr Print
	pop		si
	pop		ax
	ret
Move endp

Rotate	proc	near
	push si
	xor 	si,si
	mov		ax,word ptr Item
	add		ax,word ptr Rotated
	mov		di,word ptr Pos
	call	near ptr Print

	mov		ax,word ptr Rotated
	inc		ax
	mov		bx,4
	cwd
	idiv	bx
	mov		ax,word ptr Item
	add		ax,dx
	mov		di,word ptr Pos
	call	near ptr TestSpace
	or		ax,ax
	je		no_room1
	mov		ax,word ptr Rotated
	inc		ax
	mov		bx,4
	cwd
	idiv	bx
	mov		word ptr Rotated,dx
no_room1:

	mov		si,1
	mov		ax,word ptr Item
	add		ax,word ptr Rotated
	mov		di,Pos
	call	near ptr Print
	pop		si
	ret
Rotate	endp

GameOverPrompt		proc near
	mov		ah,1
	mov		di,GAME_OVER_POS
	mov		si,offset GameOverText
	call	near ptr PrintMonoString
	mov		di,PLAY_AGAIN_POS
	call	near ptr PrintMonoString
	ret
GameOverPrompt		endp

PrintMonoString		proc near
	;removed
mono_done:
	ret
PrintMonoString		endp

_NewInt1c       proc    far
	push	ax
	push	bx
	push	cx
	push	dx
	push	di
	push	si
	push	bp
	push	ds
	push	es

	mov     bp,cs
	mov     ds,bp
	pushf
	call    dword ptr OldInt1c

	inc		word ptr randseed
	cmp		word ptr Timer,0
	je		pause
	cmp		Paused,0
	je		pause_ok
	call	RemovePause
	mov		Paused,0
pause_ok:
	dec     word ptr Timer
	dec		word ptr LevelWait
	jne		return
	mov		word ptr LevelWait,LEVEL_WAIT_INIT
	cmp		TimerInit,0
	je		return
	dec		word ptr TimerInit
	inc		word ptr Level
	xor		dx,dx
	mov		ax,word ptr Level
	mov		di,LEVEL_POS
	call	PrintLong
	jmp		return
pause:
	cmp		Paused,0
	jne		return
	call	PrintPause
	mov		Paused,1
return:
	pop 	es
	pop 	ds
	pop 	bp
	pop 	si
	pop 	di
	pop 	dx
	pop 	cx
	pop 	bx
	pop 	ax

	iret
_NewInt1c       endp

PrintColorString	proc near
	;removed
	ret
PrintColorString 	endp

RemovePause proc near
	;removed
	ret
RemovePause endp

PrintPause proc near
	;removed
	ret
PrintPause endp

end main