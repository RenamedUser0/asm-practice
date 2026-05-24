section .data
    prompt      db "Enter n (0..12): "
    prompt_len  equ $ - prompt

    fact_msg    db "fact(n) = "
    fact_len    equ $ - fact_msg

    calls_msg   db 10, "calls = "
    calls_len   equ $ - calls_msg

    newline     db 10

section .bss
    input       resb 16
    outbuf      resb 16
    calls       resd 1

section .text
    global _start

_start:

    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 16
    int 0x80

    mov esi, input
    xor eax, eax

parse_loop:
    mov bl, [esi]

    cmp bl, 10
    je parse_done

    cmp bl, 13
    je parse_done

    cmp bl, 0
    je parse_done

    sub bl, '0'

    imul eax, eax, 10
    add eax, ebx

    inc esi
    jmp parse_loop

parse_done:

    cmp eax, 12
    jle valid_input

    mov eax, 12

valid_input:

    mov dword [calls], 0

    call fact

    push eax

    mov eax, 4
    mov ebx, 1
    mov ecx, fact_msg
    mov edx, fact_len
    int 0x80

    ; print factorial
    pop eax
    call print_number

    mov eax, 4
    mov ebx, 1
    mov ecx, calls_msg
    mov edx, calls_len
    int 0x80

    mov eax, [calls]
    call print_number

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80

fact:
    inc dword [calls]

    push ebp
    mov ebp, esp

    push ebx

    cmp eax, 1
    jle fact_base

    mov ebx, eax

    dec eax
    call fact

    imul eax, ebx
    jmp fact_end

fact_base:
    mov eax, 1

fact_end:
    pop ebx

    mov esp, ebp
    pop ebp
    ret

print_number:

    mov edi, outbuf
    add edi, 15

    mov byte [edi], 0

    mov ebx, 10

    cmp eax, 0
    jne convert_loop

    dec edi
    mov byte [edi], '0'
    jmp print_buf

convert_loop:

    xor edx, edx
    div ebx

    add dl, '0'

    dec edi
    mov [edi], dl

    test eax, eax
    jnz convert_loop

print_buf:

    mov esi, edi
    mov ecx, 0

len_loop:
    cmp byte [esi], 0
    je len_done

    inc ecx
    inc esi
    jmp len_loop

len_done:
    mov eax, 4
    mov ebx, 1
    mov edx, ecx
    mov ecx, edi
    int 0x80

    ret
