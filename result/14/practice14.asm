section .data

msgN        db "Enter n (10..100): "
lenMsgN     equ $-msgN

msgElem     db "Enter number: "
lenMsgElem  equ $-msgElem

msgOrig     db 10, "Original array:", 10
lenMsgOrig  equ $-msgOrig

msgSort     db 10, "Sorted array:", 10
lenMsgSort  equ $-msgSort

msgMed      db 10, "Median: "
lenMsgMed   equ $-msgMed

space       db " "
newline     db 10

section .bss

inputBuffer     resb 32
numBuffer       resb 16

n               resd 1
array           resd 100

section .text
global _start

_start:

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

xor esi, esi

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

xor esi, esi              

outer_loop:

mov eax, [n]
dec eax
cmp esi, eax
jge sort_done

mov edi, esi              
mov ebx, esi
inc ebx                   

inner_loop:

cmp ebx, [n]
jge inner_done

mov eax, [array + ebx*4]
mov edx, [array + edi*4]

cmp eax, edx
jge skip_min

mov edi, ebx

skip_min:
inc ebx
jmp inner_loop

inner_done:

; swap array[i] and array[min]
mov eax, [array + esi*4]
mov edx, [array + edi*4]

mov [array + esi*4], edx
mov [array + edi*4], eax

inc esi
jmp outer_loop

sort_done:

mov eax, 4
mov ebx, 1
mov ecx, msgSort
mov edx, lenMsgSort
int 0x80

xor esi, esi

print_sort:

cmp esi, [n]
jge print_sort_done

mov eax, [array + esi*4]
call print_number

mov eax, 4
mov ebx, 1
mov ecx, space
mov edx, 1
int 0x80

inc esi
jmp print_sort

print_sort_done:

mov eax, 4
mov ebx, 1
mov ecx, newline
mov edx, 1
int 0x80

mov eax, [n]
xor edx, edx
mov ebx, 2
div ebx

cmp edx, 0
je even_n

; odd n
mov eax, [array + eax*4]
jmp print_median

even_n:
dec eax
mov eax, [array + eax*4]

print_median:

push eax      

mov eax, 4
mov ebx, 1
mov ecx, msgMed
mov edx, lenMsgMed
int 0x80

pop eax        

call print_number

mov eax, 4
mov ebx, 1
mov ecx, newline
mov edx, 1
int 0x80

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

.divloop:
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
