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

	mov bx, 0b800h                   ;bx = addr videomem
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

	mov si, offset FrameStyle          ;si = addres of LEFT_UP
	lodsb                              ;get LEFT_UP symbol in videomem
	stosw                              ;print LEFT_UP symbol from videomem

	mov cx, [FrameStyle + 16]

	mov si, offset FrameStyle + 2	   ;si = addres of DASH
	lodsb                              ;get DASH symbol in videomem
	rep stosw						   ;print DASH symbol from videomem and repeat cx times

	mov si, offset FrameStyle + 4      ;si = addres of RIGHT_UP
	lodsb                              ;get RIGHT_UP symbol in videomem
	stosw                              ;print RIGHT_UP symbol from videomem

	add di, 96d                        ;di += 96, 96 - shift for new line

	mov cx, [FrameStyle + 14]          ;cx = elem from FrameStyle in 14 position (=10)
	call DrawVert

	mov si, offset FrameStyle + 6      ;si = addres of LEFT_DOWN
	lodsb							   ;get LEFT_DOWN symbol in videomem
	stosw                              ;print LEFT_DOWN symbol from videomem

	mov cx, [FrameStyle + 16]          ;cx = elem from FrameStyle in 16 position (=30)
	mov si, offset FrameStyle + 2      ;si = addres of DASH

	lodsb                              ;get DASH symbol in videomem
	rep stosw                          ;print RIGHT_UP symbol from videomem and repeat cx times

	mov si, offset FrameStyle + 8      ;si = addres of RIGHT_DOWN
	lodsb							   ;GET RIGHT_DOWN symbol in videomem
	stosw                              ;print RIGHT_DOWN symbol from videomem

	ret
;-------------------------------------------------------------------


;-----------------DrawVert------------------
;DrawVert draws vertical lines of frame
;Entry: FrameStyle, cx - number of cycle repeat
;Exit: di
;Distr: ax, cx, si, di
;------------------------------------------

DrawVert:

	push cx                              ;cx - number of cycle repeat;put it to stack
	mov si, offset FrameStyle + 10       ;si = addres of VERT

	lodsb                                ;get VERT symbol in videomem
	stosw                                ;print VERT symbol from videomem

	push ax

	mov ah, 00001111b                    ;colour
	mov cx, [FrameStyle + 16]            ;cx = elem from FrameStyle in 16 position (=30)
	mov si, offset FrameStyle + 12       ;si = addres of SPACE

	lodsb								 ;get SPACE symbol in videomem
	rep stosw                            ;print SPACE symbol from videomem

	pop ax
	mov si, offset FrameStyle + 10       ;si = addres of VERT
	lodsb                                ;get VERT symbol in videomem
	stosw                                ;print VERT symbol from videomem

	add di, 96                           ;di += 96, 96 - shift for new line ;TODO OPTIMISATION

	pop cx                               ;cx = old cx (=10)

	loop DrawVert						 ;cycle on cx (draw vertical lines lenght 10)
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

	mov cx, 80                        ;cx = console's horizontal size
	mov ax, [FrameStyle + 16]         ;ax = elem from FrameStyle in 16 position (=30)

	sub ax, cx                        ;ax = ax - cx (=-50)
	neg ax                            ;ax = 50

	mov dl, 2h
	div dl                            ;ax = ax / dl (=25)

	mul dl                            ;ax = ax * dl (=50)

	mov ah, 0h

	add di, ax						  ;di += ax (horisontal shift for first element of frame)

;------------------------------------

;defined vertical shift:

	mov cx, 25                        ;cx = console's vertical size
	sub cx, 8                         ;cx = cx - 8, (8 - commands lines in low of console, they breaks frame if it's dowm)
	mov ax, [FrameStyle + 14]         ;ax = elem of FrameStyle in 14 position (=10)

	sub ax, cx                        ;ax -= cx (=-7)
	neg ax                            ;ax = 7

	mov dl, 2h
	div dl                            ;ax = 3

	mov cx, 160                       ;80 * 2 - twise horizontal size
	mul cl							  ;ax *= cx (=480)

	add di, ax						  ;di = di + 3* (80 * 2) - adding nymber shifts lines times number of bytes in this strokes

	ret
;-------------------------------------------------------------------

;array index: 0  1  |  2  3 | 4  5   |  6  7    |  8  9    |   10 11 | 12 13 | 14 15  |  16 17  | 18    19

FrameStyle dw 0DAh,    0C4h,  0BFh,     0C0h,      0D9h,       0B3h,   32d,    10d,      1Eh,     01001111b

;naming:      LEFT_UP  DASH   RIGHT_UP  LEFT_DOWN  RIGHT_DOWM  VERT    SPACE   VERT_NUM  DASH_NUM COLOUR
end 	Main
