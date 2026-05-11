; ================================
; Practice 12 - Substring Search
; NASM i386 / Debian Linux
; int 0x80 only
; ================================

section .data
    prompt_text     db "Enter text: "
    prompt_text_len equ $ - prompt_text

    prompt_pat      db "Enter pattern: "
    prompt_pat_len  equ $ - prompt_pat

    msg_first       db "First position: "
    msg_first_len   equ $ - msg_first

    msg_count       db 10, "Count: "
    msg_count_len   equ $ - msg_count

    minus_one       db "-1", 10
    minus_one_len   equ $ - minus_one

    newline         db 10

section .bss
    text_buf        resb 256
    pattern_buf     resb 64
    number_buf      resb 16

    text_len        resd 1
    pattern_len     resd 1

    first_pos       resd 1
    count_found     resd 1

section .text
    global _start

; =====================================
; logic / program entry
; =====================================
_start:

; =====================================
; I/O - input text
; =====================================
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_text
    mov edx, prompt_text_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, text_buf
    mov edx, 255
    int 0x80

; =====================================
; parse - remove newline
; =====================================
    mov esi, text_buf

remove_text_nl:
    mov al, [esi]

    cmp al, 10
    je text_end

    cmp al, 0
    je text_end

    inc esi
    jmp remove_text_nl

text_end:
    mov byte [esi], 0

; =====================================
; memory - strlen(text)
; =====================================
    mov esi, text_buf
    call strlen
    mov [text_len], eax

; =====================================
; I/O - input pattern
; =====================================
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_pat
    mov edx, prompt_pat_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, pattern_buf
    mov edx, 63
    int 0x80

; =====================================
; parse - remove newline
; =====================================
    mov esi, pattern_buf

remove_pat_nl:
    mov al, [esi]

    cmp al, 10
    je pat_end

    cmp al, 0
    je pat_end

    inc esi
    jmp remove_pat_nl

pat_end:
    mov byte [esi], 0

; =====================================
; memory - strlen(pattern)
; =====================================
    mov esi, pattern_buf
    call strlen
    mov [pattern_len], eax

; =====================================
; logic - pattern == ""
; =====================================
    mov eax, [pattern_len]
    cmp eax, 0
    jne search_start

    mov dword [first_pos], -1
    mov dword [count_found], 0
    jmp print_results

; =====================================
; logic / loops - naive substring search
; =====================================
search_start:

    mov dword [first_pos], -1
    mov dword [count_found], 0

    xor edi, edi                ; text index

outer_loop:

    mov eax, [text_len]
    cmp edi, eax
    jge print_results

    xor ebx, ebx                ; pattern index

inner_loop:

    mov eax, [pattern_len]
    cmp ebx, eax
    je found_match

    mov al, [text_buf + edi + ebx]
    mov dl, [pattern_buf + ebx]

    cmp al, 0
    je next_position

    cmp al, dl
    jne next_position

    inc ebx
    jmp inner_loop

found_match:

; first position
    mov eax, [first_pos]
    cmp eax, -1
    jne skip_first

    mov [first_pos], edi

skip_first:

; count++
    mov eax, [count_found]
    inc eax
    mov [count_found], eax

; no overlap
    mov eax, [pattern_len]
    add edi, eax
    jmp outer_loop

next_position:
    inc edi
    jmp outer_loop

; =====================================
; I/O - print results
; =====================================
print_results:

; print label
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_first
    mov edx, msg_first_len
    int 0x80

; logic - print first position
    mov eax, [first_pos]
    cmp eax, -1
    jne print_first_num

    mov eax, 4
    mov ebx, 1
    mov ecx, minus_one
    mov edx, minus_one_len
    int 0x80

    jmp print_count_label

print_first_num:
    call print_number

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

; print count label
print_count_label:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_count
    mov edx, msg_count_len
    int 0x80

; print count
    mov eax, [count_found]
    call print_number

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

; =====================================
; I/O - exit
; =====================================
exit_program:
    mov eax, 1
    xor ebx, ebx
    int 0x80

; =====================================
; memory - strlen
; ESI = string
; return EAX = length
; =====================================
strlen:
    xor eax, eax

strlen_loop:
    cmp byte [esi + eax], 0
    je strlen_done

    inc eax
    jmp strlen_loop

strlen_done:
    ret

; =====================================
; math / I/O - print_number
; EAX = number
; =====================================
print_number:

    mov edi, number_buf
    add edi, 15

    mov byte [edi], 0
    dec edi

    cmp eax, 0
    jne convert_loop

    mov byte [edi], '0'
    jmp print_digits

convert_loop:
    xor edx, edx
    mov ebx, 10
    div ebx

    add dl, '0'
    mov [edi], dl

    dec edi

    cmp eax, 0
    jne convert_loop

    inc edi

print_digits:

    mov esi, edi

digit_len_loop:
    cmp byte [esi], 0
    je digit_len_done

    inc esi
    jmp digit_len_loop

digit_len_done:
    mov edx, esi
    sub edx, edi

    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    int 0x80

    ret
