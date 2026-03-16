section .data
    prompt db "Enter number: "
    prompt_len equ $-prompt

    newline db 10

section .bss
    input resb 32
    output resb 32

section .text
global _start

_start:

; =====================
; I/O
; =====================

    mov eax,4
    mov ebx,1
    mov ecx,prompt
    mov edx,prompt_len
    int 0x80

    mov eax,3
    mov ebx,0
    mov ecx,input
    mov edx,32
    int 0x80

; =====================
; parse
; =====================

    mov esi,input
    xor eax,eax
    xor ebx,ebx

parse_loop:

; =====================
; memory
; =====================

    mov bl,[esi]

; =====================
; logic
; =====================

    cmp bl,10
    je parse_done

    cmp bl,13
    je parse_done

; =====================
; math
; =====================

    sub bl,'0'

    imul eax,eax,10
    add eax,ebx

; =====================
; loops
; =====================

    inc esi
    jmp parse_loop

parse_done:

    mov ax,ax

; =====================
; convert number to string
; =====================

    mov ecx,output
    add ecx,31
    mov byte [ecx],0

    mov ebx,10

convert_loop:

    xor edx,edx
    div ebx

    add dl,'0'

    dec ecx
    mov [ecx],dl

    cmp eax,0
    jne convert_loop

; =====================
; I/O
; =====================

    mov eax,4
    mov ebx,1
    mov edx,output
    add edx,31
    sub edx,ecx
    mov eax,4
    mov ebx,1
    mov edx,31
    sub edx,ecx
    mov ecx,ecx
    int 0x80

    mov eax,4
    mov ebx,1
    mov ecx,newline
    mov edx,1
    int 0x80

; =====================
; exit
; =====================

    mov eax,1
    xor ebx,ebx
    int 0x80
