.model tiny
.code
org 100h

;------------------Main-----------------------
;The Main function that calls others
;Entry: None
;Exit: None
;Distr: ax, bx, es
;--------------------------------------------

Main:

	mov bx, 0b800h
	mov es, bx
	mov bx, 0

	call PositionFrame

	call DrawFrame

	mov ax, 4c00h
	int 21h
;-------------------------------------------------------------------


;-------------------DrawFrame----------------------
;DrawFrame - the main func for drawing a frame by symbols
;from array FrameStyle, it is drawing up and down lines and
;calling DrawVert
;Entry: di - current position of first symbol to draw
;Exit: None
;Distr: ax, si, cx, di,
;---------------------------------------------------
DrawFrame:

	mov ah, 00011111b

	mov si, offset FrameStyle
	lodsb                             ;left_up
	stosw

	mov cx, [FrameStyle + 16]

	mov si, offset FrameStyle + 2
	lodsb                              ;dash in rep
	rep stosw

	mov si, offset FrameStyle + 4
	lodsb                              ;right_up
	stosw

	add di, 96d

	mov cx, [FrameStyle + 14]
	call DrawVert

	mov si, offset FrameStyle + 6
	lodsb
	stosw

	mov cx, [FrameStyle + 16]
	mov si, offset FrameStyle + 2

	lodsb
	rep stosw

	mov si, offset FrameStyle + 8
	lodsb
	stosw

	ret
;-------------------------------------------------------------------


;-----------------DrawVert------------------
;DrawVert draws vertical lines of frame
;Entry: FrameStyle, cx - number of cycle repeat
;Exit: di
;Distr: ax, cx, si, di
;------------------------------------------

DrawVert:

	push cx
	mov si, offset FrameStyle + 10

	lodsb
	stosw

	push ax

	mov ah, 00001111b
	mov cx, [FrameStyle + 16]
	mov si, offset FrameStyle + 12

	lodsb
	rep stosw

	pop ax
	mov si, offset FrameStyle + 10
	lodsb
	stosw

	add di, 96

	pop cx

	loop DrawVert
	ret
;-------------------------------------------------------------------


;-----------------PositionFrame----------------
;PositionFrame definds first frame's symbol's
;position in videomem so that the whole frame
;is in center of console
;Entry:	FrameStyle
;Exit:  di
;Distr: ax, cx, dh, dl, di
;----------------------------------------------

PositionFrame:

;defined horizontal shift:

	mov cx, 80
	mov ax, [FrameStyle + 16]

	sub ax, cx           ;-50
	neg ax               ;50

	mov dl, 2h
	div dl				 ;25

	mul dl				 ;50

	mov ah, 0h

	add di, 50           ;0+50

;------------------------------------

;defined vertical shift:

	mov cx, 25
	sub cx, 8
	mov ax, [FrameStyle + 14]

	mov ax, 10

	sub ax, cx    ;-15
	neg ax        ;15

	mov dl, 2h
	div dl       ;7

	mov cx, 160
	mul cl

	add di, ax

	ret
;-------------------------------------------------------------------

;array index: 0  1  2  3  4  5  6  7  8  9  10 11  12 13  14 15  16 17  18    19
FrameStyle dw 0DAh, 0C4h, 0BFh, 0C0h, 0D9h, 0B3h,  32d,   10d,   1Eh,   01001111b

end 	Main
