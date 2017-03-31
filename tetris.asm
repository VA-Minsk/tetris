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

;	figures
figureBlock equ grSym

maxViewNum equ 4
currViewNum db 0

emptyBlock equ 0
fullBlock equ 0ffh

fieldSize equ xField*yField
oneFigureBigSize equ maxViewNum*fieldSize

;	save: figure - row number - column number
currentFigure db oneFigureBigSize dup(emptyBlock)
futureFigure db oneFigureBigSize dup(emptyBlock)
virtualField db fieldSize dup(emptyBlock)

numOfFigures equ 7


;	квадратик
figures	db fieldSize dup(emptyBlock)
		db fieldSize dup(emptyBlock)
		db fieldSize dup(emptyBlock)
		db fieldSize dup(emptyBlock)
	;	I
		db fieldSize dup(emptyBlock)
		db fieldSize dup(emptyBlock)
		db fieldSize dup(emptyBlock)
		db fieldSize dup(emptyBlock)
	;	T
		db fieldSize dup(emptyBlock)
		db fieldSize dup(emptyBlock)
		db fieldSize dup(emptyBlock)
		db fieldSize dup(emptyBlock)
	;	z
		db fieldSize dup(emptyBlock)
		db fieldSize dup(emptyBlock)
		db fieldSize dup(emptyBlock)
		db fieldSize dup(emptyBlock)
	;	z зеркальное
		db fieldSize dup(emptyBlock)
		db fieldSize dup(emptyBlock)
		db fieldSize dup(emptyBlock)
		db fieldSize dup(emptyBlock)
	;	Г
		db fieldSize dup(emptyBlock)
		db fieldSize dup(emptyBlock)
		db fieldSize dup(emptyBlock)
		db fieldSize dup(emptyBlock)
	;	Г зеркальное
		db fieldSize dup(emptyBlock)
		db fieldSize dup(emptyBlock)
		db fieldSize dup(emptyBlock)
		db fieldSize dup(emptyBlock)

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
	call GenerateNewFigure
	mov bx, figureBlock
	call PrintCurrFigure

;	Main loop
;	*********
checkKeyPressing:
	CheckBuffer
	jz      newIteration						;клавишу не нажали

	ReadFromBuffer

	cmp		ah, KExit
	je 		game_over
	cmp		ah, KLeft
	je 		go_left
	cmp		ah, KRight
	je 		go_right
	cmp		ah, KRotate
	je 		go_rotate
;	cmp		al, KDrop
;	je 		go_drop

;	If not found key - down block & go to new iteration
newIteration:
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
go_rotate:
	call    Rotate
	jmp     checkKeyPressing

game_over:
;	End Main loop
;	*************
    ret
ENDP

;	Time random
;	Input:
;		ax - max value
;	Result:
;		ax - random number [0, max value)
Random PROC
	push bx cx dx

	mov cx, ax			;в cx - max value
	cmp cx, 0
	je quitRandom

	;считываем текущее время
	;ch - час, cl - минута, dh - секунда, dl - сотая доля секунды
	mov ah, 2Ch
	int 21h

	mov al, dl
	mul dh 				;в ax теперь число для рандома

	xor dx, dx			;чтобы не словить переполнение и получить хороший результат
	div cx				;в dx - результат (случайное число);

	mov ax, dx

quitRandom:
	pop dx cx bx
	ret
ENDP

GenerateNewFigure PROC
	push ax cx dx ds es si di

	mov ax, dataStart
	mov ds, ax
	mov es, ax

	mov ax, numOfFigures
	call Random
	mov cx, oneFigureBigSize	;в cx - размер одной "пачки" из видов фигур
	mul cx						;теперь имеем смещение фигуры относительно начала figures

	mov si, offset figures
	add si, ax					;получаем реальное смещение в памяти, где сгенерированная фигура
	
	mov di, offset currentFigure	;теперь всё готово для "копирования" новой фигуры
	rep movsb

	;Выбираем вид фигуры
	mov ax, maxViewNum
	call Random
	mov currViewNum, al				;сохраняем индекс текущего вида

	pop di si es ds dx cx ax
	ret
ENDP

;	Input:
;		bx - symbol how to print current figure
PrintCurrFigure PROC
	push ax cx ds es si di

	mov ax, videoStart
	mov es, ax
	mov ax, dataStart
	mov ds, ax

	mov ax, fieldSize				;set what figure we print
	mul currViewNum
	add ax, offset currentFigure
	mov si, ax


	mov ax, 2*(2*xSize + 2)			;пропускаем 2 первые строки + 2 певых символа третьей строки (становимся в левый верхний угол поля)
	mov di, ax
	
	mov cx, yField

loopAllRows:

	push cx
	mov cx, xField

loopOneRow:
	mov al, [si]
	cmp al, emptyBlock
	je skipWriteBlock

	mov word ptr [di], bx

skipWriteBlock:
	inc si
	add di, 2					;т.к. каждый символ занимает 2 байта в видеопамяти

	loop loopOneRow

	add di, 2*(xSize - xField)	;для перехода в начало следующей строки

	pop cx

	loop loopAllRows

	pop di si es ds cx ax
	ret
ENDP

;	Down block for one position
;	If need - generate new one
;	Return:
;		ax = 0 - all is good
;		ax = 1 - no more plase in field
Down proc
	push cx si ds
	jmp goodQuit	;todo: delete
	mov ah, 0
	mov al, 1
	call Move

	cmp ax, 0
	je goodQuit

	call copyCurrentFigureToVirtualField
	;todo: delete rows
	call GenerateNewFigure

	mov ax, dataStart
	mov ds, ax

	call getCurrentFigure
	call checkFigureForCrossing
	
	jmp DownToQuit

goodQuit:
	mov ax, 0

DownToQuit:
	pop ds si cx
	ret
endp

;	Input:
;		ds:si - starting pos to compare
;	Return:
;		ax = 0 - all is good (not crossing)
;		ax != 0 - crossing
checkFigureForCrossing PROC
	push cx es di

	mov ax, dataStart
	mov es, ax

	mov di, offset virtualField
	mov cx, fieldSize

checkCrossingLoop:
	mov ax, [si]
	and ax, [di]
	jnz qutiCrossingProc
	loop checkCrossingLoop

qutiCrossingProc:
	pop di es cx
	ret
ENDP

DeleteRow proc
	;todo

	ret
endp

;	Move current block to calculated position only to one direction
;	Input:
;		ah - how much points current figure goes right (-1, 0, 1)
;		al - how much points currnet figure goes down  (0, 1)
;	Output:
;		ax = 0 - all is good
;		ax != 0 - we cannot do that
Move proc
	push ds es si di

	cmp ah, 0
	je moveDownPoint
	cmp al, 0
	je MoveSucceedExit
	jl MoveErrorExit

	;;todo

moveDownPoint:
	;mov
	;todo
	

MoveErrorExit:
	mov ax, 1
	jmp MoveExit
MoveSucceedExit:
	mov ax, 0
MoveExit:
	pop di si es ds
	ret
endp
;	Output:
;		ax = 0 - all is good
;		ax != 0 - we cannot do that
MoveDown proc
	push cx ds es si di
	;todo

	call getCurrentFigure
	add si, cx
	;todo: set D flag
	mov cx, xField
	mov al, emptyBlock

	;mov cx, maxViewNum

	;mov si, 

;MoveDownCheckLoop:	
	
	

;	loop MoveDownCheckLoop

MoveDownErrorExit:
	mov ax, 1
	jmp MoveDownExit
MoveDownSucceedExit:
	mov ax, 0
MoveDownExit:
	pop di si es ds cx
	ret
endp

Rotate	proc
	push ax bx

	mov bx, space			;delete old figure
	call PrintCurrFigure

	;change current figure index
	inc currViewNum
	mov al, currViewNum
	cmp al, maxViewNum
	jl skipNulling

	mov currViewNum, 0		;loop indexing

skipNulling:
	mov bx, figureBlock			;print new view of figure
	call PrintCurrFigure

	pop bx ax
	ret
endp

copyCurrentFigureToVirtualField PROC
	push ax cx dx ds es si di

	mov ax, dataStart
	mov ds, ax
	mov es, ax

	call getCurrentFigure

	mov di, offset virtualField

	;сам процесс дозаписи
loopAddFigure:
	mov al, [si]
	or [di], al 				;переписали, если что-то где-то было
	inc si
	inc di
	loop loopAddFigure

	pop di si es ds dx cx ax
	ret
ENDP

;	Return:
;		si - offset of current figure
;		cx - current figure size
getCurrentFigure PROC
	push ax

	xor ah, ah
	mov al, currViewNum
	mov cx, fieldSize			;в cx - размер одного вида фигур
	mul cx						;теперь имеем смещение фигуры относительно начала currentFigure

	mov si, offset currentFigure
	add si, ax					;получаем реальное смещение в памяти, где сгенерированная фигура

	pop ax
	ret
ENDP


end main