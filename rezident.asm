.model tiny
.code
org 100h

VIDEOSEG equ 0b800h

Start:

        mov ax, 09h
        mov dx, offset String
        int 21h

        xor ax, ax
        mov es, ax
        mov bx, 09h * 4
        mov ax, es:[bx]

        mov old09ofs, ax
        mov ax, es:[bx+2]
        mov old09seg, ax

        cli
        mov es:[bx], offset New09
        push cs
        pop ax
        mov es:[bx+2], ax
        sti

        mov ax, 3100h
        mov dx, offset EOP

        shr dx, 4
        inc dx
        int 21h

New09:
        push ax bx es

        mov ax, VIDEOSEG
        mov es, ax
        mov ah, 4ch
        mov bx, 5 * 80 * 2 + 40 * 2
        cld

        in al, 60h
        mov es:[bx], ax

        mov cs: Active, 1

        pop es bx ax
	    db 0EAh

old09ofs dw ?
old09seg dw ?

Active db 0

String db 'Start$'

EOP:

end     Start
