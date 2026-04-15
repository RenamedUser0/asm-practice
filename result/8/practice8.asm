section .data
    msg_n db "Enter n: ", 0
    msg_arr db "Enter numbers:", 10, 0
    msg_target db "Enter target: ", 0
    nl db 10
    space db " "

section .bss
    n resd 1
    target resd 1
    arr resd 100
    buffer resb 32

section .text
    global _start

; ================= PRINT =================
print:
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

; ================= READ =================
read:
    mov eax, 3
    mov ebx, 0
    int 0x80
    ret

; ================= ATOI =================
atoi:
    xor eax, eax
.next:
    mov bl, [esi]
    cmp bl, 10
    je .done
    cmp bl, 0
    je .done
    sub bl, '0'
    imul eax, eax, 10
    add eax, ebx
    inc esi
    jmp .next
.done:
    ret

; ================= PRINT NUM =================
print_num:
    cmp eax, 0
    jne .conv
    mov byte [buffer], '0'
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, 1
    int 0x80
    ret

.conv:
    mov ecx, buffer + 31
    mov byte [ecx], 0
    dec ecx
    mov ebx, 10

.loop:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [ecx], dl
    dec ecx
    cmp eax, 0
    jne .loop

    inc ecx

    mov eax, 4
    mov ebx, 1
    mov edx, buffer + 32
    sub edx, ecx
    mov ecx, ecx
    int 0x80
    ret

; ================= MAIN =================
_start:

; ---- n ----
    mov ecx, msg_n
    mov edx, 10
    call print

    mov ecx, buffer
    mov edx, 32
    call read

    mov esi, buffer
    call atoi
    mov [n], eax

; ---- array ----
    mov ecx, msg_arr
    mov edx, 16
    call print

    xor edi, edi        ; i = 0

read_loop:
    cmp edi, [n]
    jge read_done

    mov ecx, buffer
    mov edx, 32
    call read

    mov esi, buffer
    call atoi

    mov ebx, arr
    mov [ebx + edi*4], eax

    inc edi
    jmp read_loop

read_done:

; ---- target ----
    mov ecx, msg_target
    mov edx, 14
    call print

    mov ecx, buffer
    mov edx, 32
    call read

    mov esi, buffer
    call atoi
    mov [target], eax

; ================= SEARCH =================

    xor edi, edi
    mov ebx, -1
    xor edx, edx

search:
    cmp edi, [n]
    jge done

    mov ecx, arr
    mov eax, [ecx + edi*4]

    cmp eax, [target]
    jne next

    cmp ebx, -1
    jne skip
    mov ebx, edi

skip:
    inc edx

    mov eax, edi
    call print_num

    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80

next:
    inc edi
    jmp search

done:

; ---- first index ----
    mov eax, ebx
    call print_num

    mov eax, 4
    mov ebx, 1
    mov ecx, nl
    mov edx, 1
    int 0x80

; ---- count ----
    mov eax, edx
    call print_num

    mov eax, 4
    mov ebx, 1
    mov ecx, nl
    mov edx, 1
    int 0x80

; ---- exit ----
    mov eax, 1
    xor ebx, ebx
    int 0x80
