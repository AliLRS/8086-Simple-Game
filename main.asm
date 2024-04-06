.model small
.stack 100h

.data
score db 0
username db ?
seed db ?
cursor_x db 0
cursor_y db 0

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

scroll_up proc
    push ax
    push bx
    push cx
    push dx

    mov ah, 06      ; arguman for scroll upward
    mov al, 02      ; number of rows that scrolled up
    mov bh, 07      ; color
    mov ch, 01
    mov cl, 00
    mov dh, 24
    mov dl, 79
    int 10h

    pop dx
    pop cx
    pop bx
    pop ax
    ret
scroll_up endp

set_cursor proc
    push ax
    push bx
    push dx

    mov ah, 02          ; arguman for scroll upward
    mov bh, 00          ; page number
    mov dh, [cursor_x]  ; row
    mov dl, [cursor_y]  ; column
    int 10h

    pop dx
    pop bx
    pop ax
    ret
set_cursor endp

print_string proc       ;;;;;;;;;; there is better intrupt for this. change it.(INT 10h / AH = 13h - write string.)
    push ax
    push dx

    mov ah, 09          ; arguman for outputing a string
    mov dx, offset username ;;;;;;;;;;;;;;;;;;; replace it with a register
    int 21h

    pop dx
    pop ax
    ret
print_string endp

end main
