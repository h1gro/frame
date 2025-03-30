.model tiny
.code
org 100h

Start:  jmp Main

FRAME_LEN    equ 14d            ;length of frame
FRAME_HIGH   equ 13d            ;high of frame

FRAME_COLOR  equ 5fh            ;set color to frame
BUFFER_COLOR equ 0fh            ;set color of buffer

NUM_OF_REGS  equ 11d            ;amount of registers

VIDEO_MEM    equ 0b800h         ;video segment

CONSOLE_LEN  equ 80d            ;length of console
CONSOLE_HIGH equ 25d            ;high of console

START_KEY   equ 10h            ;scan code 'o'
TIMER_KEY   equ 11h            ;scan code 't'
DESTR_KEY   equ 12h            ;scan c'

FRAME_PTR    equ (CONSOLE_LEN - FRAME_LEN) * 2 - 2 * 4 + 80 * 2     ;set console ptr
NEW_LINE     equ (CONSOLE_LEN - FRAME_LEN) * 2                      ;set new line

BlackFrame   equ 0Fh
FrameColour  equ 00011111b
FrameWeight  equ 30d
FrameHight   equ 10d
FramePosition equ 200d
NewLineShift equ 96d
video_segment equ 0b800h

;------------------------------------------------------------------
;MyInt08h - func to create my int08h interrupt
;------------------------------------------------------------------
MyInt08h        proc

    push sp bp si di ss es ds dx cx bx ax           ;save registers

    push cs                                         ;cs = ds
    pop ds

    cmp [TimerFrameFlag], 1d

    jne End_of_Int08h

    push si ax                                      ;save si
    ;mov si, offset RegistersName
    mov si, offset FrameStyle
    mov ah, FRAME_COLOR                             ;set color of registers

    ;call DrawFrame                                     ;draw registers and their value

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
;------------------------------------------------------------------
;MyInt09h - func to create my int09h interrupt
;------------------------------------------------------------------
MyInt09h        proc
    push sp bp si di ss es ds dx cx bx ax ;save reg

    push cs
    pop ds                                ;mov code segment

    xor ax, ax
    in al, 60h                            ;60h - keyboard

    cmp al, START_KEY
    je Start_draw                                 ;if 'o(open)' draw frame

    cmp al, DESTR_KEY
    je Destr_frame                                ;if 'backspace' draw destroy frame

    cmp al, TIMER_KEY                     ;if 't(timer)' start updating registers
    je Start_updating_reg

    jmp SkipAction

Start_draw:

    mov ah, FRAME_COLOR                  ;set frame color
    mov si, offset FrameStyle            ;set frame style
    call DrawFrame

    ;mov si, offset RegistersName         ;name of registers
    ;call WriteRegisters

    jmp End_of_Int09h

Destr_frame:

    mov ah, BUFFER_COLOR                ;black color
    mov si, offset DestrStyle           ;set frame style

    call DrawFrame

    jmp End_of_Int09h

Start_updating_reg:

    xor [TimerFrameFlag], 1            ;set updating mode

    jmp End_of_Int09h

SkipAction:
    in  al, 61h             ;
    mov ah, al              ;lock keyboard with 61h port
    or  al, 80h             ;
    out 61h, al             ;
    mov al, ah              ;
    out 61h, al             ;

    mov al, 20h             ;end of interrupt with 21h
    out 20h, al             ;

End_of_Int09h:

    pop ax bx cx dx ds es ss di si bp sp          ;restoring reg
;------------------------------------------------------------------
;               DEFINE OLD INT 09H
;------------------------------------------------------------------
                db 0eah
                Old_Int09h_offset  dw 0
                Old_Int09h_segment dw 0

                endp

;------------------------------------------------------------------
;DrawFrame - draw frame in video mem
;Entry: si - frame style
;Exit: es:[di]
;Destr: cx
;------------------------------------------------------------------
DrawFrame:

    mov bx, video_segment                   ;bx = addr videomem
    mov es, bx
	mov bx, 0

    mov di, FramePosition

    mov dh, FrameWeight
    mov dl, FrameHight
    mov bp, NewLineShift

	;mov ah, [colour]

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

	;mov si, offset FrameStyle          ;si = addres of LEFT_DOWN
	lodsb							   ;get LEFT_DOWN symbol in videomem
	stosw                              ;print LEFT_DOWN symbol from videomem

	mov cl, dh                         ;cx = elem from FrameStyle in 16 position (=30)
	mov ch, 0
	;mov si, offset FrameStyle + 2      ;si = addres of DASH

	lodsb                              ;get DASH symbol in videomem
	rep stosw                          ;print RIGHT_UP symbol from videomem and repeat cx times

	;mov si, offset FrameStyle + 4      ;si = addres of RIGHT_DOWN
	lodsb							   ;GET RIGHT_DOWN symbol in videomem
	stosw                              ;print RIGHT_DOWN symbol from videomem

	ret

;-----------------------------------------------------------------------------------------------

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

	;cmp cx, bx
	;je TextLine

	mov ah, FrameColour                    ;colour
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


;---------------------------------------------------------------------
;                FRAME STYLE AND VARIABLES
;---------------------------------------------------------------------
TimerFrameFlag       db 0                               ;1 - show frame
FrameStyle           db 6Fh, 5Fh, 6Fh, 7Ch, 20h, 7Ch, 6Fh, 5Fh, 6Fh
;FrameStyle           db 0c9h, 0cdh, 0bbh, 0bah, 32d, 0bah, 0c8h, 0cdh, 0bch
DestrStyle           db 3Ch, 7Eh, 3Ch, 26h, 20h, 26h, 3Ch, 7Eh, 3Ch
RegistersName        db "Ax = ", "Bx = ", "Cx = ", "Dx = ", "Ds = ", "Es = ", "Ss = ", "Di = ", "Si = ", "Bp = ", "Sp = "
ValRegisters         db 4d dup(0)
;---------------------------------------------------------------------
;               SAVING UP TO HER
;---------------------------------------------------------------------
SaveCode:

Main:
    push 0
    pop es                          ;

    mov ax, 3509h                   ;get old interrupt vector 09h
    int 21h                         ;in bx - offset, es - segment

    mov Old_Int09h_offset,  bx
    mov Old_Int09h_segment, es      ;save old interrupt vector

    cli                             ;clear int flags

    mov ax, 2509h                   ;set int 25h
    push cs
    pop ds                           ;save code segment
    lea dx, MyInt09h
    int 21h

    sti                            ;restoring int flags

    mov ax, 3508h                   ;get old interrupt vector 08h
    int 21h                         ;in bx - offset, es - segment

    mov Old_Int08h_offset, bx
    mov Old_Int08h_segment, es      ;save old interrupt vector

    cli

    mov ax, 2508h                   ;set my int08h
    push cs
    pop ds                          ;save code segment
    lea dx, MyInt08h
    int 21h

    sti

    lea dx, SaveCode         ;saving code from start to SaveCode
    shr dx, 4
    inc dx

    mov ax, 3100h                   ;dos function 31
    int 21h

end         Start
