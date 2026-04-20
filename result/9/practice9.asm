section .data
    prompt db "Enter n (100..1000): ", 0
    prompt_len equ $ - prompt

    newline db 10
    hash db "#"
    colon db ": "
    lparen db " ("
    rparen db ")"

section .bss
    input resb 16          ; buffer for input
    freq resd 10           ; freq[10]
    num resd 1             ; n
    seed resd 1            ; LCG seed
    buffer resb 16         ; number to string buffer

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
    cmp bl, 0
    je parse_done

    sub bl, '0'
    imul eax, eax, 10
    add eax, ebx

    inc esi
    jmp parse_loop

parse_done:
    mov [num], eax

    mov eax, [num]
    cmp eax, 100
    jl exit
    cmp eax, 1000
    jg exit

    mov dword [seed], 1

    mov ecx, 10
    mov edi, freq

zero_loop:
    mov dword [edi], 0
    add edi, 4
    loop zero_loop

    mov ecx, [num]

gen_loop:
    cmp ecx, 0
    je gen_done

    mov eax, [seed]
    mov ebx, 1103515245
    mul ebx

    add eax, 12345
    and eax, 0x7FFFFFFF

    mov [seed], eax

    xor edx, edx
    mov ebx, 10
    div ebx

; freq[edx]++
    mov edi, freq
    mov eax, edx
    shl eax, 2
    add edi, eax

    mov eax, [edi]
    inc eax
    mov [edi], eax

    dec ecx
    jmp gen_loop

gen_done:

    xor esi, esi

print_loop:
    cmp esi, 10
    je exit

; print digit
    mov eax, esi
    add eax, '0'
    mov [buffer], al

    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, 1
    int 0x80

; print ": "
    mov eax, 4
    mov ebx, 1
    mov ecx, colon
    mov edx, 2
    int 0x80

; get count
    mov edi, freq
    mov eax, esi
    shl eax, 2
    add edi, eax
    mov eax, [edi]      ; count

; ===== histogram (#####) =====
    mov edx, eax        ; counter

print_hash:
    cmp edx, 0
    je after_hash

    push edx

    mov eax, 4
    mov ebx, 1
    mov ecx, hash
    mov edx, 1
    int 0x80

    pop edx
    dec edx
    jmp print_hash

after_hash:

; print " ("
    mov eax, 4
    mov ebx, 1
    mov ecx, lparen
    mov edx, 2
    int 0x80

; print number
    mov eax, [edi]
    call print_number

; print ")"
    mov eax, 4
    mov ebx, 1
    mov ecx, rparen
    mov edx, 1
    int 0x80

; newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    inc esi
    jmp print_loop

print_number:
    mov ecx, buffer + 15
    mov ebx, 10

.convert:
    xor edx, edx
    div ebx
    add dl, '0'
    dec ecx
    mov [ecx], dl
    test eax, eax
    jnz .convert

    mov eax, 4
    mov ebx, 1
    mov edx, buffer + 15
    sub edx, ecx
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80
