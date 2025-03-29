.model tiny
.code
org 100h

Start:  jmp main

    FRAME_COLOR equ 5fh
    RunFrame equ 71h
    EndFrame equ 77h

    start_rez equ 71h
    time_rez   equ 77h

    Msg db 'Our rezident - OC has been installed!$'
    FrameStyle db 6Fh, 7Eh, 6Fh, 6Ch, 20h
    Strr db 'helloy!$'

    Old_09h dw 0,0

    BlackFrame   equ 0Fh
    FrameColour  equ 00011111b
    FrameWeight  equ 30d
    FrameHight   equ 10d
    NewLineShift equ 96d
    video_segment equ 0b800h

    colour db 0

My_Int08h        proc

    push sp bp si di ss es ds dx cx bx ax           ;save registers

    push cs                                         ;cs = ds
    pop  ds

    cmp [TimerFrameFlag], 1d
    jne End_of_Int08h

    push si ax                                      ;save si
    mov si, offset RegistersName
    mov ah, FRAME_COLOR                             ;set color of registers

    ;call WriteRegisters                                     ;draw registers and their value


    pop ax si                                       ;restoring si

End_of_Int08h:

    mov al, 20h
    out 20h, al                                     ;end of interrupt 21h

    pop ax bx cx dx ds es ss di si bp sp            ;restoring registers

;-------------------------------------------------------------------
;               DEFINE OLD INT 08H
;-------------------------------------------------------------------
    db 0eah
    Old_Int08h_offset  dw 0
    Old_Int08h_segment dw 0

    endp
;--------------------------------------------------------------------
My_Int09h proc

    push ax bx cx dx bp sp si di ds es ss

    push cs
    pop ds

    xor ax, ax
    mov al, 60h                             ;scan_code

    cmp al, start_rez
    je start_draw

    cmp al, time_rez
    je update_rez

    jmp SkipAction

start_draw:

    mov ah, FrameColour

    call DrawFrame

    jmp return_regs

update_rez:

    xor [TimerFrameFlag], 1            ;set updating mode

SkipAction:
    in  al, 61h             ;
    mov ah, al              ;lock keyboard with 61h port
    or  al, 80h             ;
    out 61h, al             ;
    mov al, ah              ;
    out 61h, al             ;

    mov al, 20h             ;end of interrupt with 21h
    out 20h, al             ;

    return_regs:

    pop ss es ds di si sp bp dx cx bx ax

    db 0eah
    Old_Int09h_offset  dw 0
    Old_Int09h_segment dw 0

    endp
;-------------------------------------------------------------------
DrawFrame:

    mov bx, video_segment                   ;bx = addr videomem
    mov es, bx
	mov bx, 0

    mov dh, FrameWeight
    mov dl, FrameHight
    mov bp, NewLineShift

	;mov ah, [colour]

	mov si, offset FrameStyle          ;si = addres of LEFT_UP
	lodsb                              ;get LEFT_UP symbol in videomem
	stosw                              ;print LEFT_UP symbol from videomem

	mov cl, dh
	mov ch, 0

	mov si, offset FrameStyle + 2	   ;si = addres of DASH
	lodsb                              ;get DASH symbol in videomem
	rep stosw						   ;print DASH symbol from videomem and repeat cx times

	mov si, offset FrameStyle + 4      ;si = addres of RIGHT_UP
	lodsb                              ;get RIGHT_UP symbol in videomem
	stosw                              ;print RIGHT_UP symbol from videomem

	add di, bp                         ;di += shift for new line

	mov cl, dl                         ;cx = elem from FrameStyle in 14 position (=10)
	mov ch, 0
	;call DrawVert

	mov si, offset FrameStyle          ;si = addres of LEFT_DOWN
	lodsb							   ;get LEFT_DOWN symbol in videomem
	stosw                              ;print LEFT_DOWN symbol from videomem

	mov cl, dh                         ;cx = elem from FrameStyle in 16 position (=30)
	mov ch, 0
	mov si, offset FrameStyle + 2      ;si = addres of DASH

	lodsb                              ;get DASH symbol in videomem
	rep stosw                          ;print RIGHT_UP symbol from videomem and repeat cx times

	mov si, offset FrameStyle + 4      ;si = addres of RIGHT_DOWN
	lodsb							   ;GET RIGHT_DOWN symbol in videomem
	stosw                              ;print RIGHT_DOWN symbol from videomem

	ret
;-----------------------------------------------------

next_line proc

  mov ah, 02h
  mov dl, 0Ah
  int 21h

  endp
  ret

;--------------------------------------------


TimerFrameFlag       db 0                               ;1 - show frame
;FrameStyle           db 0c9h, 0cdh, 0bbh, 0bah, 32d, 0bah, 0c8h, 0cdh, 0bch
DestrStyle           db 9d dup(3d)
RegistersName        db "Ax = ", "Bx = ", "Cx = ", "Dx = ", "Ds = ", "Es = ", "Ss = ", "Di = ", "Si = ", "Bp = ", "Sp = "
ValRegisters         db 4d dup(0)

SaveCode:

Main:
    push 0
    pop es                          ;

    mov ax, 3509h                   ;get old interrupt vector 09h
    int 21h                         ;in bx - offset, es - segment

    mov Old_Int09h_offset,  bx
    mov Old_Int09h_segment, es     ;save old interrupt vector

    cli                             ;clear int flags

    mov ax, 2509h                   ;set int 25h
    push cs
    pop ds                          ;save code segment
    lea dx, My_Int09h
    int 21h

    sti                             ;restoring int flags

    mov ax, 3508h                   ;get old interrupt vector 08h
    int 21h                         ;in bx - offset, es - segment

    mov Old_Int08h_offset, bx
    mov Old_Int08h_segment, es      ;save old interrupt vector

    cli

    mov ax, 2508h                   ;set my int08h
    push cs
    pop ds                          ;save code segment
    lea dx, My_Int08h
    int 21h

    sti

    lea dx, SaveCode                ;saving code from start to SaveCode
    shr dx, 4
    inc dx

    mov ax, 3100h                   ;dos function 31
    int 21h

end         Start
