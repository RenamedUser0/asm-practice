section .data
; ===== I/O =====
    promptA db "Enter a: ", 0
    promptA_len equ $ - promptA

    promptB db "Enter b: ", 0
    promptB_len equ $ - promptB

    signed_txt db "SIGNED: ", 0
    signed_len equ $ - signed_txt

    unsigned_txt db "UNSIGNED: ", 0
    unsigned_len equ $ - unsigned_txt

    less db "a < b", 10
    less_len equ $ - less

    equal db "a = b", 10
    equal_len equ $ - equal

    greater db "a > b", 10
    greater_len equ $ - greater

    max_s_txt db "max_signed: ", 0
    max_s_len equ $ - max_s_txt

    max_u_txt db "max_unsigned: ", 0
    max_u_len equ $ - max_u_txt

section .bss
    ; ===== memory =====
    buf resb 32
    a resd 1
    b resd 1

section .text
    global _start

; =========================
; I/O
; =========================
print:
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

read:
    mov eax, 3
    mov ebx, 0
    int 0x80
    ret

; =========================
; parse (string -> int, с минусом)
; =========================
atoi:
    xor eax, eax
    xor ebx, ebx
    mov bl, 10
    xor edx, edx        ; sign flag

    mov cl, [esi]
    cmp cl, '-'
    jne .parse
    inc esi
    mov edx, 1          ; число отрицательное

.parse:
    xor eax, eax

.next:
    mov cl, [esi]
    cmp cl, 10
    je .done
    cmp cl, 13
    je .done

    sub cl, '0'
    imul eax, ebx
    add eax, ecx
    inc esi
    jmp .next

.done:
    cmp edx, 1
    jne .ret
    neg eax

.ret:
    ret

; =========================
; print int (signed)
; =========================
print_int:
    mov ecx, buf + 31
    mov byte [ecx], 10
    dec ecx

    mov ebx, 10
    cmp eax, 0
    jge .convert

    ; если отрицательное
    neg eax
    mov edi, 1          ; флаг минуса
    jmp .convert

.convert:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [ecx], dl
    dec ecx
    test eax, eax
    jnz .convert

    cmp edi, 1
    jne .print
    mov byte [ecx], '-'
    dec ecx

.print:
    inc ecx
    mov edx, buf + 32
    sub edx, ecx

    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

; =========================
; logic: signed compare
; =========================
cmp_signed:
    mov eax, [a]
    mov ebx, [b]

    cmp eax, ebx
    jl .less
    je .equal
    jg .greater

.less:
    mov ecx, less
    mov edx, less_len
    call print
    ret

.equal:
    mov ecx, equal
    mov edx, equal_len
    call print
    ret

.greater:
    mov ecx, greater
    mov edx, greater_len
    call print
    ret

; =========================
; logic: unsigned compare
; =========================
cmp_unsigned:
    mov eax, [a]
    mov ebx, [b]

    cmp eax, ebx
    jb .less
    je .equal
    ja .greater

.less:
    mov ecx, less
    mov edx, less_len
    call print
    ret

.equal:
    mov ecx, equal
    mov edx, equal_len
    call print
    ret

.greater:
    mov ecx, greater
    mov edx, greater_len
    call print
    ret

; =========================
; math: max signed
; =========================
max_signed:
    mov eax, [a]
    mov ebx, [b]

    cmp eax, ebx
    jge .done
    mov eax, ebx

.done:
    ret

; =========================
; math: max unsigned
; =========================
max_unsigned:
    mov eax, [a]
    mov ebx, [b]

    cmp eax, ebx
    jae .done
    mov eax, ebx

.done:
    ret

; =========================
; MAIN
; =========================
_start:

    ; ===== input a =====
    mov ecx, promptA
    mov edx, promptA_len
    call print

    mov ecx, buf
    mov edx, 32
    call read

    mov esi, buf
    call atoi
    mov [a], eax

    ; ===== input b =====
    mov ecx, promptB
    mov edx, promptB_len
    call print

    mov ecx, buf
    mov edx, 32
    call read

    mov esi, buf
    call atoi
    mov [b], eax

    ; ===== SIGNED =====
    mov ecx, signed_txt
    mov edx, signed_len
    call print
    call cmp_signed

    ; ===== UNSIGNED =====
    mov ecx, unsigned_txt
    mov edx, unsigned_len
    call print
    call cmp_unsigned

    ; ===== max signed =====
    mov ecx, max_s_txt
    mov edx, max_s_len
    call print
    call max_signed
    call print_int
    
    ; ===== max unsigned =====
    mov ecx, max_u_txt
    mov edx, max_u_len
    call print
    call max_unsigned
    call print_int

    ; ===== exit =====
    mov eax, 1
    xor ebx, ebx
    int 0x80
