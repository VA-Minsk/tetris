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

;key bindings (configuration)
KRotate equ 48h	    ;Up key
KLeft equ 4Bh	    ;Left key
KRight equ 4Dh		;Right key
KDrop equ 50h		;Down key
KExit equ 01h 		;ESC key

xSize equ 80
ySize equ 18
xField equ 25           ;size of playground
yField equ 14
oneMemoBlock equ 2

videoStart dw 0B800h
dataStart dw 0000h

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

;	Figures
maxViewNum equ 4

emptyFig equ 0
fullFig equ 0ffh

;	save: figure - row number - column number
currentFigure db maxViewNum*xField*yField dup(emptyFig)
fututeFigure db maxViewNum*xField*yField dup(emptyFig)
virtualField db xField*yField dup(emptyFig)

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
;	Main loop
;	*********
checkKeyPressing:
	CheckBuffer
	jz      newIteration						;клавишу не нажали

	ReadFromBuffer

	cmp		al, KExit
	je 		quit
	cmp		al, KLeft
	je 		go_left
	cmp		al, KRight
	je 		go_right
	cmp		al, KRotate
	je 		go_rotate
;	cmp		al, KDrop
;	je 		go_drop

;	If not found key - down block & go to new iteration

	call    Down                  ; go down
	cmp		ax, 0
	jne		game_over

	call 	Sleep
		
	jmp		checkKeyPressing

go_left:
	mov		ah, -1
	mov 	al, 0
	call    Move
	jmp     checkKeyPressing
go_right:
	mov		ah, 1
	mov 	al, 0
	call    Move
	jmp     checkKeyPressing
;go_drop:
;	call    Drop
;	or		ax,ax
;	je		game_over
;	jmp     checkKeyPressing
go_rotate:
	call    Rotate
	jmp     checkKeyPressing

game_over:
;	End Main loop
;	*************
    ret
ENDP

Drop	proc
	push	si
	mov		si, 2*xSize			;was 80
drop_more:
	call	Move
	inc		word ptr Drops
	or		ax,ax
	jne		drop_more

	call	Down
	pop		si
	ret
endp

;	Down block for one position
;	If need - generate new one
;	Return:
;		ax = 0 - all is good
;		ax = 1 - no more plase in field
Down	proc
	push 	si
	mov		si, 2*xSize			;was 80
	call	Move

	or		ax,ax						; room?
	je		get_new							; no
	pop		si
	ret
get_new:
	mov		ax,word ptr Item
	add		ax,word ptr Rotated
	mov		di,word ptr Pos
	call	Bottom			; reached the bottom

	call	Rand7			; get new item
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
endp

;ax - item number ???
Print	proc					;ax= item_nr    di=scroffs si=T/F
	mov		dx,0b800h
	mov		es,dx
	mov 	dx,06						; 06 - количество элементов в строке Items
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
	cbw								; байт al в слово в ax (размножением знакового бита)
	shl		ax,1
	add		di,ax
	pop		ax
	mov 	es:[di],si
	inc     dx
	cmp		dx,4
	jne	    loop2
	ret
endp

Bottom	proc      	;ax=ItemNr			di=scroffset
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
endp

TestSpace	proc		;ax= item_nr    di=scroffs
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
endp

DeleteRow	proc				;bx=Row

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

Move proc					; si=dPos
	push 	si

	xor		si,si
	mov		ax,word ptr Item
	add		ax,word ptr Rotated
	mov		di,word ptr Pos
	call	Print				; remove old

	mov		ax,word ptr Item
	add		ax,word ptr Rotated
	mov 	di,word ptr Pos
	pop 	si
	add		di,si
	push 	si
	call	TestSpace				; test if room
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
	call	Print
	pop		si
	pop		ax
	ret
endp

Rotate	proc
	push si
	xor 	si,si
	mov		ax,word ptr Item
	add		ax,word ptr Rotated
	mov		di,word ptr Pos
	call	Print

	mov		ax,word ptr Rotated
	inc		ax
	mov		bx,4
	cwd
	idiv	bx
	mov		ax,word ptr Item
	add		ax,dx
	mov		di,word ptr Pos
	call	TestSpace
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
	call	Print
	pop		si
	ret
endp

end main