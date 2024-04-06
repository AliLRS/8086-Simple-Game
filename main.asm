.model small
.stack 100h

.data
score db 0
username db ?
seed db ?

.code
main proc
    mov ax, @data
    mov ds, ax

    mov ah, 4cH
    int 21H
main endp

clear_screen proc
    mov ah, 06      ; argumant for scrolling upward
    mov al, 00      ; number of rows that scrolled up(in this procedure, whole of screen) 
    mov bh, 07      ; color
    mov ch, 00
    mov cl, 00
    mov dh, 24
    mov dl, 79
    int 10h
    ret
clear_screen endp

end main
