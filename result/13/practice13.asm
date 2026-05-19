section .data

msgN        db "Enter n (5..200): "
lenMsgN     equ $-msgN

msgElem     db "Enter number: "
lenMsgElem  equ $-msgElem

msgOrig     db 10, "Original array:", 10
lenMsgOrig  equ $-msgOrig

msgRev      db 10, "Reversed array:", 10
lenMsgRev   equ $-msgRev

msgYes      db 10, "PALINDROME: YES", 10
lenMsgYes   equ $-msgYes

msgNo       db 10, "PALINDROME: NO", 10
lenMsgNo    equ $-msgNo

space       db " "
newline     db 10

section .bss

inputBuffer     resb 32
numBuffer       resb 16

n               resd 1
array           resd 200
reverseArray    resd 200

section .text
global _start

_start:

; ===== read n =====
mov eax, 4
mov ebx, 1
mov ecx, msgN
mov edx, lenMsgN
int 0x80

mov eax, 3
mov ebx, 0
mov ecx, inputBuffer
mov edx, 32
int 0x80

mov esi, inputBuffer
call str_to_int
mov [n], eax

xor esi, esi          ; index = 0

input_loop:

cmp esi, [n]
jge input_done

mov eax, 4
mov ebx, 1
mov ecx, msgElem
mov edx, lenMsgElem
int 0x80

mov eax, 3
mov ebx, 0
mov ecx, inputBuffer
mov edx, 32
int 0x80

push esi

mov esi, inputBuffer
call str_to_int

pop esi

mov [array + esi*4], eax

inc esi
jmp input_loop

input_done:

xor esi, esi

rev_loop:

cmp esi, [n]
jge rev_done

mov eax, [n]
dec eax
sub eax, esi

mov ebx, [array + eax*4]
mov [reverseArray + esi*4], ebx

inc esi
jmp rev_loop

rev_done:

mov eax, 4
mov ebx, 1
mov ecx, msgOrig
mov edx, lenMsgOrig
int 0x80

xor esi, esi

print_orig:

cmp esi, [n]
jge print_orig_done

mov eax, [array + esi*4]
call print_number

mov eax, 4
mov ebx, 1
mov ecx, space
mov edx, 1
int 0x80

inc esi
jmp print_orig

print_orig_done:

mov eax, 4
mov ebx, 1
mov ecx, newline
mov edx, 1
int 0x80

mov eax, 4
mov ebx, 1
mov ecx, msgRev
mov edx, lenMsgRev
int 0x80

xor esi, esi

print_rev:

cmp esi, [n]
jge print_rev_done

mov eax, [reverseArray + esi*4]
call print_number

mov eax, 4
mov ebx, 1
mov ecx, space
mov edx, 1
int 0x80

inc esi
jmp print_rev

print_rev_done:

mov eax, 4
mov ebx, 1
mov ecx, newline
mov edx, 1
int 0x80

xor esi, esi
mov edi, [n]
dec edi

mov ebp, 1

pal_loop:

cmp esi, edi
jge pal_done

mov eax, [array + esi*4]
mov ebx, [array + edi*4]

cmp eax, ebx
jne not_pal

inc esi
dec edi
jmp pal_loop

not_pal:
mov ebp, 0

pal_done:

cmp ebp, 1
je yes_pal

mov eax, 4
mov ebx, 1
mov ecx, msgNo
mov edx, lenMsgNo
int 0x80
jmp exit

yes_pal:
mov eax, 4
mov ebx, 1
mov ecx, msgYes
mov edx, lenMsgYes
int 0x80


exit:
mov eax, 1
xor ebx, ebx
int 0x80

str_to_int:
xor eax, eax
xor ebx, ebx

.loop:
mov bl, [esi]

cmp bl, 10
je .done
cmp bl, 13
je .done
cmp bl, 0
je .done

sub bl, '0'
imul eax, eax, 10
add eax, ebx

inc esi
jmp .loop

.done:
ret

print_number:
mov edi, numBuffer
add edi, 15
mov byte [edi], 0

mov ebx, 10

cmp eax, 0
jne .conv

dec edi
mov byte [edi], '0'
jmp .out

.conv:
xor edx, edx
div ebx
add dl, '0'
dec edi
mov [edi], dl
cmp eax, 0
jne .conv

.out:
mov eax, 4
mov ebx, 1
mov ecx, edi

mov edx, numBuffer
add edx, 15
sub edx, edi

int 0x80
ret
