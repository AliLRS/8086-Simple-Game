.model small
.stack 100h

.data
score db 0
username db ?
seed db ?

.code
    mov ax, @data
    mov ds, ax

main proc

_end:
    mov ah, 4cH
    int 21H
main endp
end main
