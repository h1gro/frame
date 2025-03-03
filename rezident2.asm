.model tiny
.code
.startup

      jmp Init

      Msg db 'Resident module installed!',10,13,'$'
      Old_09h dw 0,0

    New09h:

     mov bx, 0b800h
     mov es, bx
     mov bx, 300

     mov ah, 02h
     mov dl, 's'
     int 21h

     jmp dword ptr cs:Old_09h

     Init:

     mov ah, 09h
     mov dx, offset Msg
     int 21h

     mov ax, 3509h
     int 21h

     mov Old_09h, bx
     mov Old_09h+2, es

     mov ax, 2509h
     lea dx, New09h
     int 21h

     lea dx, Init
     int 27h

end
