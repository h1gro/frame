.model tiny
.code
org 100h

Main:		mov bx, 0b800h
		mov es, bx
		mov bx, 0
			
		call DrawFrame		

		mov ax, 4c00h
		int 21h

DrawFrame:	mov dl, 0DAh
		mov cx, 1h
		call DrawChar
		
		mov dl, 0C4h
		mov cx, 30
		call DrawChar

		mov dl, 0BFh
		mov cx, 1h
		call DrawChar
	
		call new_line

		mov dl, 41h
		mov cx, 1h
		call DrawChar
		ret


DrawChar:	mov byte ptr es:[bx], dl
		mov byte ptr es:[bx+1], 00011111b
		
		add bx, 2h
		
		loop DrawChar
		ret

New_Line:	push ax
		mov ah, 0Eh
		mov al, 0Ah
		int 10h

		mov ah, 0Eh
		mov al, 0Dh
		int 10h

		pop ax
		ret

end		Main