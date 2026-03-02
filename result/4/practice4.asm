section .data
    newline db 10
    K equ 8       ;

section .bss
    input   resb 32
    output  resb 32

section .text
    global _start

_start:

    ; ---------- I/O: read ----------
    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 32
    int 0x80

    ; удаляем \n или \r
    mov esi, input
strip_loop:
    mov al,[esi]
    cmp al,10
    je strip_done
    cmp al,13
    je strip_done
    inc esi
    cmp esi,input+32
    jb strip_loop
strip_done:
    mov byte [esi],0

    ; ---------- atoi ----------
    mov esi,input
    xor eax,eax
atoi_loop:
    mov bl,[esi]
    cmp bl,0
    je atoi_done
    sub bl,'0'
    imul eax,eax,10
    add eax,ebx
    inc esi
    jmp atoi_loop
atoi_done:
    mov ebx,eax    ; x в ebx

    ; ---------- math: sumDigits + len ----------
    xor ecx,ecx    ; sumDigits
    xor edi,edi    ; len
sum_loop:
    cmp ebx,0
    je sum_done
    mov eax,ebx
    xor edx,edx
    mov esi,10
    div esi
    add ecx,edx
    inc edi
    mov ebx,eax
    jmp sum_loop
sum_done:

    ; ---------- print sumDigits ----------
    mov eax,ecx
    call print_num

    ; ---------- print len ----------
    mov eax,edi
    call print_num

    ; ---------- print sumDigits+K ----------
    mov eax,ecx
    add eax,K
    call print_num

    ; ---------- exit ----------
    mov eax,1
    xor ebx,ebx
    int 0x80

; =================================
; print_num:
; =================================
print_num:
    push eax
    mov edi,output
    add edi,31
    mov byte [edi],0
    xor ecx,ecx

.convert:
    xor edx,edx
    mov ebx,10
    div ebx
    add dl,'0'
    dec edi
    mov [edi],dl
    inc ecx
    test eax,eax
    jnz .convert

    ;
    mov esi,edi
    mov edi,output
    mov ebx,ecx
.copy_loop:
    mov al,[esi]
    mov [edi],al
    inc esi
    inc edi
    dec ecx
    jnz .copy_loop

    ;
    mov edx,edi
    sub edx,output

    ; вывод
    mov eax,4
    mov ebx,1
    mov ecx,output
    int 0x80

    ; newline
    mov eax,4
    mov ebx,1
    mov ecx,newline
    mov edx,1
    int 0x80
    pop eax
    ret
