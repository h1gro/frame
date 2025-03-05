.model tiny
.386

.data
;--------------------CONSTS-------------------

	console_horisontal_size equ 80d
	console_vertical_size   equ 25d
	console_vert_shift      equ 8d

	cmd_addr                dw 82h
	video_segment           dw 0b800h

;---------------------------------------------

.code
org 100h


;------------------Main-----------------------
;The Main function that calls others
;Entry: None
;Exit: None
;Distr: ax, bx, es
;--------------------------------------------

Main:

	mov bx, video_segment                   ;bx = addr videomem
	mov es, bx
	mov bx, 0

	call ReadFrameStyle

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
;dh - frame weight, dl - frame hight, bp - shift for new line
;Exit: None
;Distr: ax, si, cx, di,
;---------------------------------------------------

DrawFrame:

	mov ah, 00011111b

	;mov si, offset FrameStyle          ;si = addres of LEFT_UP
	lodsb                              ;get LEFT_UP symbol in videomem
	stosw                              ;print LEFT_UP symbol from videomem

	mov cl, dh
	mov ch, 0

	;mov si, offset FrameStyle + 2	   ;si = addres of DASH
	lodsb                              ;get DASH symbol in videomem
	rep stosw						   ;print DASH symbol from videomem and repeat cx times

	;mov si, offset FrameStyle + 4      ;si = addres of RIGHT_UP
	lodsb                              ;get RIGHT_UP symbol in videomem
	stosw                              ;print RIGHT_UP symbol from videomem

	add di, bp                         ;di += shift for new line

	mov cl, dl                         ;cx = elem from FrameStyle in 14 position (=10)
	mov ch, 0
	call DrawVert

	;mov si, offset FrameStyle + 6      ;si = addres of LEFT_DOWN
	lodsb							   ;get LEFT_DOWN symbol in videomem
	stosw                              ;print LEFT_DOWN symbol from videomem

	mov cl, dh                         ;cx = elem from FrameStyle in 16 position (=30)
	mov ch, 0
	;mov si, offset FrameStyle + 2      ;si = addres of DASH

	lodsb                              ;get DASH symbol in videomem
	rep stosw                          ;print RIGHT_UP symbol from videomem and repeat cx times

	;mov si, offset FrameStyle + 8      ;si = addres of RIGHT_DOWN
	lodsb							   ;GET RIGHT_DOWN symbol in videomem
	stosw                              ;print RIGHT_DOWN symbol from videomem

	ret
;-------------------------------------------------------------------


;-----------------DrawVert------------------
;DrawVert draws vertical lines of frame
;Entry: FrameStyle, cx - number of cycle repeat
;dh - frame weight, bp - shift for new line
;Exit: di
;Distr: ax, cx, si, di
;------------------------------------------

DrawVert:

	push ax
	push cx                             ;cx - number of cycle repeat;put it to stack

	mov ah, 0h
	mov al, dl
	mov cl, 2h
	div cl
	mov bx, ax

	pop cx
	cmp ah, 0h
	pop ax
	jna cycle_draw_vert

	inc bx
	mov bh, 0h

cycle_draw_vert:

	push cx

	;mov si, offset FrameStyle + 10       ;si = addres of VERT

	lodsb                                ;get VERT symbol in videomem
	stosw                                ;print VERT symbol from videomem

	push ax

	cmp cx, bx
	je TextLine

	mov ah, 00001111b                    ;colour
	mov cl, dh                           ;cx = elem from FrameStyle in 16 position (=30)
	mov ch, 0
	;mov si, offset FrameStyle + 12       ;si = addres of SPACE

	lodsb								 ;get SPACE symbol in videomem
	rep stosw                            ;print SPACE symbol from videomem

back_text_line:

	pop ax

	;mov si, offset FrameStyle + 10       ;si = address of VERT
	lodsb                                ;get VERT symbol in videomem
	stosw                                ;print VERT symbol from videomem

	pop cx                               ;cx = old cx (=10)
	add di, bp                           ;di += 96, 96 - shift for new line

	sub si, 3h

	loop cycle_draw_vert	             ;cycle on cx (draw vertical lines lenght 10)

	add si, 3h
	ret
;-------------------------------------------------------------------


;-----------------PositionFrame----------------
;PositionFrame definds first frame's symbol's
;position in videomem so that the whole frame
;is in center of console
;Entry:	dh - frame weight, dl - frame hight
;Exit:  di, bp
;Distr: ax, cx, dh, dl, di
;----------------------------------------------

PositionFrame:

;defined horizontal shift:

	mov ch, console_horisontal_size    ;ch = console's horizontal size
	mov al, dh                         ;al = horisontal frame size
	mov ah, 0b

	sub al, ch                         ;ax = ax - cx (=-50)
	neg al                             ;ax = 49

	mov bh, 2h
	div bh                             ;al = ax / dl (=24)

	mov cx, 2h

	cmp ah, 0
	jna  ax_honest

	add bp, 2h
	mov cx, 0h

ax_honest:

	mul bh                             ;ax = al * dl (=48)

	mov bp, ax                         ;bp = 50
	add bp, ax                         ;bp = 98
	sub bp, 2h                         ;bp = 94 ;-2 for begining and ending elem of frame line
	sub bp, cx

	add di, ax						   ;di += ax (horisontal shift for first element of frame)

;------------------------------------

;defined vertical shift:

	mov cl, console_vertical_size     ;cx = console's vertical size
	sub cl, console_vert_shift        ;cx = cx - 8, (8 - commands lines in low of console, they breaks frame if it's dowm)
	mov al, dl                        ;ax = elem of FrameStyle in 14 position (=10)
	mov ah, 0b

	sub al, cl                        ;ax -= cx (=-7)
	neg al                            ;ax = 7

	mov bh, 2h
	div bh                            ;ax = 3

	mov cl, console_horisontal_size  ;80 * 2 - twise horizontal size
	add cl, console_horisontal_size
	mul cl							  ;ax *= cx (=480)

	add di, ax						  ;di = di + 3* (80 * 2) - adding nymber shifts lines times number of bytes in this strokes

	ret
;-------------------------------------------------------------------


;-----------------READFRAMESTYLE----------------
;ReadFrameStyle take arguments from console and
;with help of Atoi get numbers from user
;Entry: none
;Exit: dx
;Distr: si, al, dh, dl
;-----------------------------------------------

ReadFrameStyle	proc

	mov si, cmd_addr

	call Atoi                 ;horisontal
	mov dh, al
	push dx

	call Atoi                 ;vertical
	pop dx
	mov dl, al

	endp
	ret
;-----------------------------------------------------------------


;----------------------ATOI---------------------
;Atoi get number's digits from string by subbing
;ASCKII codes of digits
;Entry: si - addr first cmd, ds - current segment
;Exit:  al, si
;Distr: ax, cx, si, ds
;-----------------------------------------------

Atoi:
		mov ax, 0
        mov cx, 0

next_digit:                         ;cycle for numbers > 10

        mov ch, ds:[si]

        cmp ch, "0"                 ;compare between current symbol and ASCKII 0
        jb end_cmd

        cmp ch, "9"                 ;compare between current symbol and ASCKII 9
        ja end_cmd

        mov al, 10d                 ;
        mul cl                      ;
        add al, ch                  ;transformation ASCKII -> number
		sub al, "0"                 ;
        mov cl, al                  ;

        inc si

        jmp next_digit              ;repeat cycle for trasform next digit

end_cmd:

        inc si
        ret

;-----------------------------------------------------------------------------


;---------------DrawText------------------
;DrawText is drawing a constant text
;of the frame
;Entry: none
;Exit: si, di
;Distr: cx, si
;-----------------------------------------

DrawText 	proc

		mov cx, ax
		add cx, ax

		mov si, 92h

draw_sym:

		lodsb
		;push dx
		;mov ah, 02h
		;mov dl, al
		;int 21h
		;pop dx
		stosw

		loop draw_sym

		;mov dl, 2h
		;div dl

		;cmp ah, 1h
		;jne no_plus_one

		;add cl, 1h

;no_plus_one:

		endp
		ret
;-----------------------------------------------------------------------

Strlen proc

	mov bl, 0h

	mov ax, si
	push ax

	mov si, 92h

next_symbol:

	mov bh, ds:[si]

	cmp bh, 36d
	je	end_text

	inc bl
	inc si

	jmp next_symbol

end_text:

	inc bl
	mov bh, 0h

	mov ax, bx
	mov bl, 2h
	div bl

	mov bl, al

	pop ax
	mov si, ax

	;mov cx, 0
	;cmp ah, 0
	;jna ax_honest3

	;mov cl, 1d
	;mov ch, 1d

;ax_honest3:

	;push cx
	endp
	ret

;-------------------TEXTLINE--------------------------
;TextLine define horizontal center of the frame and
;call DrawText to draw constant text in the center
;Entry: dh - frame weight
;Exit: di
;Distr:	ax, cx, si
;-----------------------------------------------------

TextLine proc

	call StrLen

	mov ah, 0h
	mov al, dh                           ;cx = elem from FrameStyle in 16 position (=30)
	mov cl, 2h
	div cl

	mov cl, al
	sub cl, bl

	cmp ah, 0h
	jna ax_honest1

	inc cl

ax_honest1:

	mov ch, 0h
	push ax
	mov ah, 00001111b                    ;colour
	;mov si, offset FrameStyle + 12       ;si = addres of SPACE

	lodsb								 ;get SPACE symbol in videomem
	rep stosw                            ;print SPACE symbol from videomem
	push ax
	mov ax, bx

	mov bx, si
	push bx

	call DrawText

	pop bx
	mov si, bx
	pop ax
	mov bl, al

	pop ax
	add cl, al

	;pop ax
	;sub cl, al

	sub cl, 3h
	mov ch, 0h
	mov ah, 00001111b                    ;colour
	;mov si, offset FrameStyle + 12       ;si = addres of SPACE

	mov al, bl
	rep stosw

	endp
	jmp back_text_line

;-----------------------------------------------------------------------------


;array index: 0  1  |  2  3 | 4  5   |  6  7    |  8  9    |   10 11 | 12 13

FrameStyle dw 0DAh,    0C4h,  0BFh,     0C0h,      0D9h,       0B3h,   32d,

;naming:      LEFT_UP  DASH   RIGHT_UP  LEFT_DOWN  RIGHT_DOWM  VERT    SPACE

Text       db 'BOTAY!$'

end 	Main
