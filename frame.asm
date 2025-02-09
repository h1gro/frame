.model tiny
.code
org 100h

Main:		mov bx, 0b800h
		mov es, bx
		mov bx, 0

		call DrawFrame

		mov ax, 4c00h
		int 21h

DrawFrame:	call DrawLineUp

		add bx, 96

		mov cx, 10

		call DrawVert

		call DrawLineDown

		ret

DrawLineUp:	mov dl, 0DAh
		mov cx, 1h
		call DrawChar

		mov dl, 0C4h
		mov cx, 30
		call DrawChar

		mov dl, 0BFh
		mov cx, 1h
		call DrawChar

		ret

DrawLineDown:	mov dl, 0C0h
		mov cx, 1h
		call DrawChar

		mov dl, 0C4h
		mov cx, 30
		call DrawChar

		mov dl, 0D9h
		mov cx, 1h
		call DrawChar

		ret

DrawChar:	mov byte ptr es:[bx], dl
		mov byte ptr es:[bx+1], 00011111b

		add bx, 2h

		loop DrawChar
		ret

DrawVert:	mov ax, cx

		mov dl, 0B3h
		mov cx, 1
		call DrawChar

		add bx, 60

		mov dl, 0B3h
		mov cx, 1
		call DrawChar

		add bx, 96

		mov cx, ax
		loop DrawVert
		ret

end		Main
