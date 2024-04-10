.model small
.stack 1000h

.data
name_msg db 'Enter your name: '
seed_msg db 'Enter a number for seed: '
user_msg db 'User: '
score_msg db 'Score: '
dash_msg db 80 DUP('-')
score dw 0
username db 64 DUP(?)
seed_str db 64 DUP(?)
seed dw ?
cursor_x db 0
cursor_y db 0
string db 64 DUP(?)
number dw ?
left dw ?
right dw ?
asnwer dw ?
operator db ?
equal db '='
space db ' '
hashtag db '#'
itr dw 0
time db 0
WhITECOLOR db 0fh
BLUECOLOR db 0bh
GREENCOLOR db 0ah
REDCOLOR db 0ch
YELLOWCOLOR db 0eh
COLOR db ?
TEN dw 10
clk dw 0
number_of_hashtags db 0
errors db 0
update_seed db 0
ptime db 0

BUF1 DB 20, ?, 8 DUP(0FFH)

.code
main proc
    mov ax, @data
    mov ds, ax

    ; set termimnal mode
    mov ah, 0
    mov al, 03h
    int 10h         ; text mode. 80x25. 16 color.

    call clear_screen
    mov al, [WhITECOLOR]
    mov [COLOR], al

    call get_info

    call clear_screen

    call print_bar

    add cursor_x, 2
    call set_cursor

loop:
    mov al, [cursor_x]
    cmp al, 25
    jb no_scroll
    call scroll_up
    mov [cursor_x], 23
    call set_cursor
no_scroll:
    mov number_of_hashtags, 0
    call print_question
    call evaluate
    call check_answer
    add cursor_x, 2
    call set_cursor
    mov al, [WhITECOLOR]
    mov [COLOR], al
    cmp errors, 3
    jb loop

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

    mov [cursor_x], 0
    mov [cursor_y], 0
    call set_cursor
    ret
clear_screen endp

scroll_up proc
    push ax
    push bx
    push cx
    push dx

    mov ah, 06      ; argument for scroll upward
    mov al, 02      ; number of rows that scrolled up
    mov bh, 07      ; color
    mov ch, 03
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

    mov ah, 02          ; argument for scroll upward
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

    mov ah, 09          ; argument for outputing a string
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
	mov bl, [COLOR] ; color
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
    ; bx is the offset of the string
    mov dx, bx
    push dx         ; save starting address of the string
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
    mov bx, dx      ; get the starting address of the string
    push dx
    jz check_time   ; if no key is pressed then check time

check:  
    mov ah, 00h     ; remove the key from the string
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

get_info proc
    ; print input name message
    mov bx, offset name_msg
    mov cx, 17  ; message size.
    call print

    ; get name
    call set_cursor
    mov bx, offset username
    ; call get_str
    call get_input
    
    ; goto next line
    inc [cursor_x]
    mov [cursor_y], 0
    call set_cursor
    
    ; print input seed message
    mov bx, offset seed_msg
    mov cx, 25  ; message size.
    call print

    ; get seed
    call set_cursor
    mov bx, offset seed_str
    ; call get_str
    call get_input

    ; convert seed string to number
    mov bx, offset seed_str + 1
    mov ch, 0
    mov cl, [seed_str]  ; message size.
    call str_to_num
    mov bx, [number]
    mov [seed], bx
    ret
get_info endp

print_bar proc
    push ax
    push bx
    push cx
    ; push dx

    mov al, [BLUECOLOR]
    mov [COLOR], al
    ; print 'user: '
    mov bx, offset user_msg
    mov ch, 0
    mov cl, 6   ; message size.
    call print

    ; print username
    mov bx, offset username + 1
    mov ch, 0
    mov cl, [username]  ; message size.
    call print

    mov [cursor_y], 68
    call set_cursor

    ; print 'score: '
    mov bx, offset score_msg
    mov ch, 0
    mov cl, 7   ; message size.
    call print

    ; print score
    mov bx, score
    call num_to_str
    mov bx, offset string + 1
    mov ch, 0
    mov cl, [string]  ; message size.
    call print

    ; goto next line
    inc [cursor_x]
    mov [cursor_y], 0
    call set_cursor

    mov al, [WhITECOLOR]
    mov [COLOR], al

    ; print a line of dashes
    mov bx, offset dash_msg
    mov ch, 0
    mov cl, 80   ; message size.
    call print

    ; pop dx
    pop cx
    pop bx
    pop ax
    ret
print_bar endp

num_of_digits proc
    ; bx is the input number
    push ax
    push cx
    push dx

    mov cx, 0
    mov ax, bx
while1:
    mov dx, 0
    inc cx
    div [TEN]  ; Divide ax by 10
    cmp ax, 0 ; Compare quotient with zero
    jnz while1 ; If quotient != 0 continue counting

    mov bx, cx ; return number of digits in bx.

    pop dx
    pop cx
    pop ax
    ret
num_of_digits endp

str_to_num proc
    ; bx is offset of string
    ; cx is size of string
    ; output is in [number]
    push ax
    push dx
    mov [number], 0

while2:
    mov ax, [number]
    mul TEN

    mov dl, [bx]
    mov dh, 0
    inc bx          ; goto next character
    sub dx, 30h     ; convert ascci character to number
    add ax, dx
    mov [number], ax
    dec cx
    cmp cx, 0
    jnz while2

    pop dx
    pop ax
    ret
str_to_num endp

num_to_str proc
    ; bx is input number
    ; output is string variable
    push ax
    push cx
    push dx

    mov ax, bx  ; ax is the number
    
while3:
    mov dx, 0
    div TEN
    push dx
    cmp ax, 0
    jnz while3
    
    call num_of_digits
    mov cx, bx
    mov bx, offset string
    mov [bx], cl    ; store the length of the string
    inc bx

while4:
    pop dx
    add dx, 30h
    mov [bx], dx
    inc bx
    dec cx
    cmp cx, 0
    jnz while4

    pop dx
    pop cx
    pop ax
    ret
num_to_str endp

random_number proc
    ; [seed] is input
    ; output is in [number]
    push ax
    push bx
    push cx
    push dx
    
    ; update seed with the current time each 10 times
    inc update_seed
    mov al, 10
    cmp update_seed, al
    jne skip_seed_update
    mov update_seed, 0
    mov ah, 2ch     ; get time
    int 21h
    mov dh, 0
    add seed, dx

skip_seed_update:
    mov ax, seed   
    mov cx, 25173d  ; Multiplier
    mov dx, 13849d   ; Increment
    mov bx, 10000d   ; Modulus	

    ; random number using LCG algorithm
    mul cx          ; ax = ax * cx
    add ax, dx      ; ax = ax + dx
    mov dx, 0
    div bx          ; (remainder is the random number) dx between 0-9999
    mov seed, dx    ; update seed
    mov number, dx

    pop dx
    pop cx
    pop bx
    pop ax
    ret
random_number endp

print_question proc
    ; [number] is input
    ; output is in [left], [right], [operator]
    push ax
    push bx
    push cx
    push dx

    mov cursor_y, 0

    call random_number
    mov ax, number
    mov [left], ax

    call random_number
    mov ax, number
    mov [right], ax

    mov ax, [seed]
    mov dx, 0
    mov cx, 2
    div cx
    cmp dx, 0
    jnz add
    mov operator, '-'

    ; in subtraction left should be greater than right
    mov ax, [left]
    cmp ax, [right]
    ja print_end
    push ax
    mov ax, [right]
    mov [left], ax
    pop ax
    mov [right], ax
    jmp print_end

add:
    mov operator, '+'

print_end:
    mov bx, [left]
    call num_to_str
    ; print string
    mov bx, offset string + 1
    mov ch, 0
    mov cl, [string]  ; message size.
    call print

    mov bx, offset operator
    mov ch, 0
    mov cl, 1  ; message size.
    call print

    mov bx, [right]
    call num_to_str
    ; print string
    mov bx, offset string + 1
    mov ch, 0
    mov cl, [string]  ; message size.
    call print

    mov bx, offset equal
    mov ch, 0
    mov cl, 1  ; message size.
    call print

    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_question endp

evaluate proc
    ; [left], [right], [operator] are inputs
    ; output is in [number]
    push ax
    push bx
    push cx
    push dx

    mov ax, [left]
    mov bx, [right]
    mov dl, [operator]
    cmp dl, '+'
    jnz sub_operation
    add ax, bx
    mov asnwer, ax
    jmp eval_end

sub_operation:
    sub ax, bx
    mov asnwer, ax

eval_end:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
evaluate endp

get_answer proc
    ; bx is the offset of the string
    mov dx, bx
    push dx         ; save starting address of the string
    mov itr, 1

    mov ah, 2ch     ; get time 
    int 21h
    mov time, dl

    mov ah, 0       ; get number of clock ticks
    int 1ah
    mov clk, dx


check_time2:
    mov ah, 2ch    ; get time to check
    int 21h
    cmp time, dl
    je check_time2   ; if time is the same then check again else get the key
    
    mov time, dl

    mov ah, 0       ; get number of clock ticks
    int 1ah
    sub dx, clk
    cmp dx, 4
    jae update_progress_bar

            
get2:
    mov al, number_of_hashtags
    mov ah, 0
    cmp ax, 80
    jae str_end2

    mov ah, 01h     ; get the key that is pressed
    int 16h

    pop dx
    mov bx, dx      ; get the starting address of the string
    push dx
    jz check_time2   ; if no key is pressed then check time

check2:
    mov ah, 00h     ; remove the key from the string
    int 16h
    cmp al, 0dh     ; if enter is pressed
    je str_end2
    cmp al, 08h     ; if backspace is pressed
    je backspace2
         
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
    jmp check_time2

backspace2:
    cmp itr, 1
    je get2
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

    jmp get2

update_progress_bar:
    mov al, [cursor_y]
    push ax
    mov al, number_of_hashtags
    mov ah, 0
    mov [cursor_y], al
    inc [cursor_x]
    call set_cursor

    inc number_of_hashtags
    cmp number_of_hashtags, 80
    ja end_progress_bar
    cmp number_of_hashtags, 54
    ja red_progress_bar
    cmp number_of_hashtags, 27
    ja yellow_progress_bar
    jmp green_progress_bar

green_progress_bar:
    mov al, [GREENCOLOR]
    mov [COLOR], al
    mov bx, offset hashtag
    mov ch, 0
    mov cl, 1  ; message size.
    call print
    jmp end_progress_bar

yellow_progress_bar:
    mov al, [YELLOWCOLOR]
    mov [COLOR], al
    mov bx, offset hashtag
    mov ch, 0
    mov cl, 1  ; message size.
    call print
    jmp end_progress_bar

red_progress_bar:
    mov al, [REDCOLOR]
    mov [COLOR], al
    mov bx, offset hashtag
    mov ch, 0
    mov cl, 1  ; message size.
    call print
    jmp end_progress_bar

end_progress_bar:
    pop ax
    mov [cursor_y], al
    dec [cursor_x]
    call set_cursor
    add [clk], 4
    jmp get2

str_end2:
    mov cx, itr    
    dec cx          ; length of the string
    pop dx
    mov bx, dx
    mov [bx], cl    ; store the length of the string
    ret
get_answer endp

check_answer proc
    ; [asnwer] is input
    ; output is in [number]
    push ax
    push bx
    push cx
    push dx

    ; get input and save to string variable
    mov bx, offset string
    call get_answer

    ; check if there is asnwer
    mov ch, 0       
    mov cl, [string]  ; message size.
    cmp cl, 0       ; if there is no asnwer
    je no_asnwer

    ; convert string to number
    mov bx, offset string + 1
    mov ch, 0
    mov cl, [string]  ; message size.
    call str_to_num

    ; compare asnwer and number
    mov ax, [number]
    mov bx, [asnwer]
    cmp ax, bx
    jnz wrong_answer

correct_asnwer:
    ; increase score
    mov ax, 80
    mov bl, [number_of_hashtags]
    mov bh, 0
    sub ax, bx
    mov dx, 0
    mov bx, 4
    div bx
    add score, ax

    mov cl, [string]  ; message size.
    sub [cursor_y], cl
    ; Change the color of the user input number to green
    mov al, [GREENCOLOR]
    mov [COLOR], al
    mov bx, offset string + 1
    mov ch, 0
    mov cl, [string]  ; message size.
    call print

    call update_score

    jmp end_check

wrong_answer:
    mov cl, [string]  ; message size.
    sub [cursor_y], cl
    ; Change the color of the user input number to red
    mov al, [REDCOLOR]
    mov [COLOR], al
    mov bx, offset string + 1
    mov ch, 0
    mov cl, [string]  ; message size.
    call print

    ; print space
    mov bx, offset space
    mov ch, 0
    mov cl, 1  ; message size.
    call print

    ; print correct answer
    mov al, [YELLOWCOLOR]
    mov [COLOR], al
    mov bx, asnwer
    call num_to_str
    mov bx, offset string + 1
    mov ch, 0
    mov cl, [string]  ; message size.
    call print

    inc errors

    jmp end_check

no_asnwer:
    ; print correct answer
    mov al, [YELLOWCOLOR]
    mov [COLOR], al
    mov bx, asnwer
    call num_to_str
    mov bx, offset string + 1
    mov ch, 0
    mov cl, [string]  ; message size.
    call print

    inc errors

end_check:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
check_answer endp

update_score proc
    push ax
    push bx
    push cx
    push dx

    ; save cursor position
    mov al, [cursor_y]
    push ax
    mov al, [cursor_x]
    push ax
    mov cursor_y, 75
    mov cursor_x, 0
    call set_cursor

    ; save color
    mov al, [color]
    push ax
    mov al, [BLUECOLOR]
    mov [COLOR], al

    mov bx, score
    call num_to_str
    mov bx, offset string + 1
    mov ch, 0
    mov cl, [string]  ; message size.
    call print

    ; restore color
    pop ax
    mov [COLOR], al

    ; restore cursor position
    pop ax
    mov cursor_x, al
    pop ax
    mov cursor_y, al

    pop dx
    pop cx
    pop bx
    pop ax
    ret
update_score endp

end main
