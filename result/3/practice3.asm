; Практична робота №3

section .data
    newline db 10

section .bss
    buffer resb 7        ; буфер для 6 цифр

section .text
    global _start

_start:

    ; memory
    ; тестове значення у AX
    mov ax, 123456

    ; parse
    movzx eax, ax        ; розширюємо AX до EAX
    mov ecx, buffer
    add ecx, 6           ; вказівник на кінець буфера
    mov ebx, 10          ; база ділення

convert_loop:

    ; loops
    ; math
    xor edx, edx
    div ebx              ; eax / 10

    ; logic
    add dl, '0'          ; перетворення у ASCII

    dec ecx
    mov [ecx], dl

    test eax, eax
    jnz convert_loop

print:

    ; I/O
    mov edx, buffer
    add edx, 6
    sub edx, ecx         ; довжина строки

    mov eax, 4           ; sys_write
    mov ebx, 1           ; stdout
    mov ecx, ecx         ; адреса числа
    int 0x80

    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

exit:

    ; I/O
    mov eax, 1
    xor ebx, ebx
    int 0x80
