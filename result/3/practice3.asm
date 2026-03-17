section .data
    newline db 10

section .bss
    buffer resb 7

section .text
    global _start

_start:

    mov eax, 123456        
    mov edi, buffer + 6    
    mov byte [edi], 0    
    cmp eax, 0
    jne convert_loop
    mov byte [edi-1], '0'
    lea ecx, [edi-1]
    mov edx, 1
    jmp print

convert_loop:
    mov ebx, 10

next_digit:
    xor edx, edx         
    div ebx              
    add dl, '0'           
    dec edi
    mov [edi], dl
    cmp eax, 0
    jne next_digit
    mov ecx, edi         
    mov edx, buffer + 6
    sub edx, ecx           

print:
    mov eax, 4             
    mov ebx, 1            
    int 0x80

; вывод \n
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    mov eax, 1             
    xor ebx, ebx
    int 0x80
