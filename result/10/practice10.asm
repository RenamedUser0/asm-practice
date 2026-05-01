section .data
    ; =========================
    ; I/O
    ; =========================
    msg_in      db "Enter 32-bit integer: "
    len_in      equ $ - msg_in

    msg_bin     db 10, "Binary: "
    len_bin     equ $ - msg_bin

    msg_pop     db 10, "Popcount: "
    len_pop     equ $ - msg_pop

    msg_mod     db 10, "Modified: "
    len_mod     equ $ - msg_mod

    ; positions for bit operations
    p           equ 1
    q           equ 5
    r           equ 3

section .bss
    input       resb 64
    outbuf      resb 128
    num         resd 1
    popval      resd 1

section .text
    global _start

_start:

; =========================
; I/O
; =========================
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_in
    mov edx, len_in
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 64
    int 0x80

; =========================
; parse
; =========================
    mov esi, input
    xor eax, eax
    xor ebx, ebx
    xor edi, edi              ; sign flag

    cmp byte [esi], '-'
    jne parse_loop
    mov edi, 1
    inc esi

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
    cmp edi, 0
    je store_num
    neg eax

store_num:
    mov [num], eax

; =========================
; I/O
; =========================
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_bin
    mov edx, len_bin
    int 0x80

; =========================
; loops / logic
; друк 32-бітного двійкового числа
; =========================
    mov eax, [num]
    mov ecx, 32
    mov edi, outbuf
    xor esi, esi

bin_loop:
    mov edx, eax
    shr edx, 31
    and edx, 1
    add dl, '0'
    mov [edi], dl
    inc edi

    inc esi
    cmp esi, 4
    jne no_space

    cmp ecx, 1
    je no_space

    mov byte [edi], ' '
    inc edi
    xor esi, esi

no_space:
    shl eax, 1
    loop bin_loop

    mov byte [edi], 10
    inc edi

    mov eax, 4
    mov ebx, 1
    mov ecx, outbuf
    mov edx, edi
    sub edx, outbuf
    int 0x80

; =========================
; math / logic
; popcount через shr + and 1
; =========================
    mov eax, [num]
    xor ebx, ebx
    mov ecx, 32

pop_loop:
    mov edx, eax
    and edx, 1
    add ebx, edx
    shr eax, 1
    loop pop_loop

    mov [popval], ebx

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_pop
    mov edx, len_pop
    int 0x80

    mov eax, [popval]
    call print_int

; =========================
; logic
; set bits p,q and clear r
; =========================
    mov eax, [num]

    mov ebx, 1
    shl ebx, p
    or eax, ebx

    mov ebx, 1
    shl ebx, q
    or eax, ebx

    mov ebx, 1
    shl ebx, r
    not ebx
    and eax, ebx

    mov [num], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_mod
    mov edx, len_mod
    int 0x80

    mov eax, [num]
    call print_int

; =========================
; exit
; =========================
    mov eax, 1
    xor ebx, ebx
    int 0x80


; ==================================================
; memory
; helper: print signed integer from eax
; ==================================================
print_int:
    mov edi, outbuf + 127
    mov byte [edi], 10
    dec edi

    mov ebx, 10
    xor esi, esi

    cmp eax, 0
    jge convert_digits

    neg eax
    mov esi, 1

convert_digits:
    cmp eax, 0
    jne digit_loop

    mov byte [edi], '0'
    dec edi
    jmp digits_done

digit_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    dec edi
    test eax, eax
    jnz digit_loop

digits_done:
    cmp esi, 0
    je print_number

    mov byte [edi], '-'
    dec edi

print_number:
    inc edi

    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, outbuf + 128
    sub edx, edi
    int 0x80

    ret
