.model tiny

			;lotsb
			;stosw

.data

;------------------------------------------------
;ASKII codes of symbols for frame:

	left_up     dw 0DAh
	right_up    dw 0BFh

	left_down   dw 0C0h
	right_down  dw 0D9h

	dash        dw 0C4h	
	vert_symbol dw 0B3h

	heart       dw 03h
;------------------------------------------------ 
;Frame size:

	hight dw 10

	wight dw 30
;------------------------------------------------

.code
org 100h

;--------------------Main------------------------
;Main - func that starts programm and calls main
;functions for frame
;Entry: None
;Exit:	None
;Distr: ax, bx, es
;------------------------------------------------

Main:		mov bx, 0b800h
		mov es, bx
		mov bx, 368

		call DrawFrame

		mov ax, 4c00h
		int 21h

;------------------DrawFrame-------------
;DrawFrame - the main func for frame that 
;calls additional funcs for drawing:
;DrawVert and DrawLine 
;Entry: None
;Exit:  None
;Distr: bx, si, cx
;----------------------------------------

DrawFrame:	arg1 dw ?
		arg2 dw ?

		mov si, left_up
		mov arg1, si

		mov si, right_up
		mov arg2, si

		call DrawLine


		add bx, 96		
		mov cx, hight

		call DrawVert
		

		mov si, left_down
		mov arg1, si
		
		mov si, right_down
		mov arg2, si

		call DrawLine

		ret

;---------------------DrawLine-----------------------
;DrawLine - func that drawing one frame line by calling
;DrawChar with different arguments
;Entry:	arg1, arg2, dash, wight,
;Exit:	None
;Distr:	dx, cx
;------------------------------------------------

DrawLine:	mov dx, arg1
		mov cx, 1h
		call DrawChar

		mov dx, dash
		mov cx, wight
		call DrawChar

		mov dx, arg2
		mov cx, 1h
		call DrawChar

		ret

;-------------------DrawChar----------------------
;DrawChar - function that draw a char in video mem
;Entry: dl = char to write
;Exit : NONE
;Destr: bx, es, dl
;-------------------------------------------------

DrawChar:	mov byte ptr es:[bx], dl
		mov byte ptr es:[bx+1], 01001111b

		add bx, 2h

		loop DrawChar
		ret

;-----------------DrawVert------------------------
;DrawVert - func that draw frame vertical columns
;by drawing lines with vert_symbols and spaces, it
;calls DrawChar
;Entry:	cx, vert_symbol 
;Exit; 	None
;Distr:	ax, bx, cx, dx
;------------------------------------------------

DrawVert:	mov ax, cx

		mov dx, vert_symbol
		mov cx, 1
		call DrawChar		

		add bx, 60

		mov dx, vert_symbol
		mov cx, 1
		call DrawChar

		add bx, 96

		mov cx, ax
		loop DrawVert
		ret

end		Main