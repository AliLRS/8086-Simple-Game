.model small
.stack 100h

.data
greeting db 'Enter your name: '
score db 0
username db 64 DUP(?)
seed db ?
cursor_x db 0
cursor_y db 0
string db 64 DUP(?)
itr dw 0
time db 0
WhITECOLOR db 0fh
BUF1 DB 20, ?, 8 DUP(0FFH)

.code
main proc
    mov ax, @data
    mov ds, ax

    mov ah, 0
    mov al, 03h
    int 10h         ; text mode. 80x25. 16 color.

    call clear_screen

    mov bx, offset greeting
    mov cx, 17  ; message size.
    call print

    call set_cursor

    mov bx, offset username
    ; call get_str
    call get_input
    
    inc [cursor_x]
    mov [cursor_y], 0
    call set_cursor
    
    mov bx, offset username + 1
    mov ch, 0
    mov cl, [username]  ; message size.
    call print

    mov ah, 4ch
    int 21h
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

print_string proc       ;;;;;;;;;; there is better intrupt for this. change it.(int 10h / ah = 13h - write string.)
    push ax
    push dx

    mov ah, 09          ; arguman for outputing a string
    ; mov dx, offset username ;;;;;;;;;;;;;;;;;;; replace it with a register
    mov dx, bx
    int 21h

    pop dx
    pop ax
    ret
print_string endp

print proc
    push ax
    push bx
    ; push cx
    push dx
	mov bp, bx
    mov ax, @data
    mov es, ax
    mov al, 1
	mov bh, 0
	mov bl, [WhITECOLOR] ; color
	; mov cx, 3 ; calculate message size. 
	mov dl, [cursor_y]
	mov dh, [cursor_x]
	; mov bp, offset username
	mov ah, 13h
	int 10h

    add [cursor_y], cl  ; update cursor
    pop dx
    ; pop cx
    pop bx
    pop ax
    ret
print endp

get_input proc
    mov dx, bx
    push dx         ; save starting address of the buffer
    mov itr, 1

    mov ah, 2ch     ; get time 
    int 21h
    mov time, dl

check_time:
    mov ah, 2ch    ; get time to check
    int 21h
    cmp time, dl
    je check_time   ; if time is the same then check again else get the key

    mov time, dl
            
get:  
    mov ah, 01h     ; get the key that is pressed
    int 16h

    pop dx
    mov bx, dx      ; get the starting address of the buffer
    push dx
    jz check_time   ; if no key is pressed then check time

check:  
    mov ah, 00h     ; remove the key from the buffer
    int 16h
    cmp al, 0dh     ; if enter is pressed
    je str_end
    cmp al, 08h     ; if backspace is pressed
    je backspace
         
    ; echo the key
    push bx         
    call set_cursor
    inc cursor_y

    mov ah,09h
    mov bh, 0       ; Set page number
    mov bl, WHITECOLOR    ; Set color
    mov cx, 1       ; Character count
    int 10h       
    pop bx
    
    mov cx, itr
    add bx, cx
    mov [bx], al
    inc itr
    jmp check_time

backspace:
    cmp itr, 1
    je get
    dec itr
    mov al, 20h
    mov cx, itr
    add bx, cx
    mov [bx], al
    dec cursor_y

    push bx         ; save bx
    call set_cursor
    mov ah,09h
    mov bh, 0       ; Set page number
    mov bl, WhITECOLOR    ; Set color
    mov cx, 1       ; Character count
    int 10h
    pop bx

    jmp get

str_end:
    mov cx, itr    
    dec cx          ; length of the string
    pop dx
    mov bx, dx
    mov [bx], cl    ; store the length of the string
;   inc cx
;   add bx, cx
;   mov [bx], '$'
    ; pop dx
    ret
get_input endp

get_str proc
    push ax
    push dx

    mov ah, 0ah
    ; mov dx, bx  ; bx is offset of input string
    mov dx, offset BUF1
    int 21h

    pop dx
    pop ax
    ret
get_str endp

end main
