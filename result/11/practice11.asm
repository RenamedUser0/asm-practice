
section .data
    prompt      db "Enter height (5..25): "
    prompt_len  equ $ - prompt

    newline     db 10

section .bss
    input_buf   resb 16
    line_buf    resb 64
    height      resd 1

section .text
    global _start

; =====================================
; memory / logic / program entry
; =====================================
_start:

; =====================================
; I/O - print prompt
; =====================================
    mov eax, 4              ; sys_write
    mov ebx, 1              ; stdout
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

; =====================================
; I/O - read input
; =====================================
    mov eax, 3              ; sys_read
    mov ebx, 0              ; stdin
    mov ecx, input_buf
    mov edx, 16
    int 0x80

; =====================================
; parse - convert ASCII to integer
; =====================================
    xor eax, eax
    xor ebx, ebx
    mov esi, input_buf

parse_loop:
    mov bl, [esi]

    cmp bl, 10              ; newline
    je parse_done

    cmp bl, 13
    je parse_done

    sub bl, '0'

    imul eax, eax, 10
    add eax, ebx

    inc esi
    jmp parse_loop

parse_done:
    mov [height], eax

; =====================================
; logic - validate range 5..25
; if invalid -> exit
; =====================================
    cmp eax, 5
    jl exit_program

    cmp eax, 25
    jg exit_program

; =====================================
; loops - outer loop for rows
; =====================================
    mov edi, 0              ; current row

row_loop:

    mov eax, [height]
    cmp edi, eax
    jge exit_program

; =====================================
; math - calculate counts
; spaces = h - row - 1
; stars  = row * 2 + 1
; =====================================
    mov eax, [height]
    sub eax, edi
    dec eax
    mov ebp, eax            ; spaces

    mov eax, edi
    shl eax, 1
    inc eax
    mov esi, eax            ; stars

; =====================================
; memory - build line in buffer
; =====================================
    mov ecx, line_buf

; ----- inner loop: spaces -----
space_loop:
    cmp ebp, 0
    jle stars_loop_start

    mov byte [ecx], ' '
    inc ecx
    dec ebp
    jmp space_loop

; ----- inner loop: stars -----
stars_loop_start:

stars_loop:
    cmp esi, 0
    jle line_finish

    mov byte [ecx], '*'
    inc ecx
    dec esi
    jmp stars_loop

; ----- add newline -----
line_finish:
    mov byte [ecx], 10
    inc ecx

; =====================================
; math - calculate line length
; =====================================
    mov edx, ecx
    sub edx, line_buf

; =====================================
; I/O - print line
; =====================================
    mov ecx, line_buf
    call print_line

; next row
    inc edi
    jmp row_loop

; =====================================
; subprogram - print_line(buf,len)
; ecx = buffer
; edx = length
; =====================================
print_line:
    mov eax, 4              ; sys_write
    mov ebx, 1              ; stdout
    int 0x80
    ret

; =====================================
; I/O - exit
; =====================================
exit_program:
    mov eax, 1              ; sys_exit
    xor ebx, ebx
    int 0x80
