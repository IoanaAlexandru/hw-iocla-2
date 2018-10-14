extern puts
extern printf
extern strlen
extern strstr

section .data
filename: db "/home/student/Downloads/Tema2/iocla-tema2-resurse/input.dat",0
inputlen: dd 2263
fmtstr: db "Key: %d",0xa,0

section .text
global main

; TODO: define functions and helper functions
next_word:
    push ebp
    mov ebp, esp

    push ebx
    call strlen             ; saves length in eax
    inc eax
    add ebx, eax
    
    leave
    ret

xor_strings:
    push ebp
    mov ebp, esp
    
    mov esi, [ebp + 8]
    mov edi, [ebp + 12]
    xor edx, edx
    xor eax, eax
    xor ecx, ecx
    
byte_by_byte:
    mov al, byte[esi + edx]
    test al, al
    je stop
    mov cl, byte[edi + edx]
    xor cl, al
    mov byte[esi + edx], cl
    inc edx
    loop byte_by_byte
    
stop:
    leave
    ret


rolling_xor:
    push ebp
    mov ebp, esp
    
    mov esi, [ebp + 8]
    
    push esi
    call strlen
    mov ecx, eax
    dec ecx
    
reverse_byte_by_byte:
    mov al, byte[esi + ecx]        ; last byte
    mov dl, byte[esi + ecx - 1]    ; penultimate byte
    xor al, dl
    mov byte[esi + ecx], al
    loop reverse_byte_by_byte
    
    leave
    ret
    
    
convert_byte:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp + 8]
    
    ; we assume the input is valid (0-9 a-f)
    ; digit: between 0 (0x30) and 9 (0x39)
digit:
    cmp eax, 0x40
    jg letter
    sub al, 0x30
    jmp byte_conversion_done

    ; letter: between a(0x61) and f(0x66)
letter:
    sub al, 0x57

byte_conversion_done:
    leave
    ret
    
   
convert_string:
    push ebp
    mov ebp, esp
    
    mov ecx, [ebp + 8]

    xor esi, esi        ; length of encoding
    xor edi, edi        ; length of result (esi/2)
    xor eax, eax
    xor edx, edx
    
convert:
    mov al, byte[ecx + esi]
    test al, al
    je string_conversion_done
    push eax
    call convert_byte
    shl eax, 4              ; multiply by 16
    mov edx, eax
    inc esi
    mov al, byte[ecx + esi]
    push eax
    call convert_byte
    add edx, eax
    mov byte[ecx + edi], dl
    inc edi
    inc esi
    jmp convert

string_conversion_done:
    mov byte[ecx + edi], 0
    inc edi
    cmp edi, esi
    jne string_conversion_done
    
    leave
    ret
    
      
xor_hex_strings:
    push ebp
    mov ebp, esp
    
    mov esi, [ebp + 8]    
    push esi
    call convert_string
    
    mov edi, [ebp + 12]
    push edi
    call convert_string
    
    pop edi
    pop esi
    push edi
    push esi
    
    call xor_strings
    
    leave
    ret
    
    
singlebyte_xor:
    push ebp
    mov ebp, esp
    
    xor edx, edx
    xor eax, eax
    
xor_every_byte:
    mov al, byte[esi + edx]
    test al, al
    je done
    xor al, cl
    mov byte[esi + edx], al
    inc edx
    jmp xor_every_byte
    
done:
    leave
    ret
 
    
find_force:
    push ebp
    mov ebp, esp
    
    xor edx, edx
    xor eax, eax
    dec edx
check:
    inc edx
    mov al, byte[esi + edx]
    test al, al
    je not_found
    cmp al, "f"
    jne check
    mov al, byte[esi + edx + 1]
    test al, al
    je not_found
    
    cmp al, "o"
    jne check
    mov al, byte[esi + edx + 2]
    test al, al
    je not_found
    cmp al, "r"
    jne check
    mov al, byte[esi + edx + 3]
    test al, al
    je not_found
    cmp al, "c"
    jne check
    mov al, byte[esi + edx + 4]
    test al, al
    je not_found
    cmp al, "e"
    jne check
    
found:
    mov eax, 1
not_found:
    leave
    ret
             
    
bruteforce_singlebyte_xor:
    push ebp
    mov ebp,esp
    
    mov esi, [ebp + 8]
    mov edi, [ebp + 12]
    
    mov ecx, 1
    dec ecx
    call singlebyte_xor
bruteforce:
    call singlebyte_xor
    inc ecx
    call singlebyte_xor
    call find_force
    test al, al
    je bruteforce
    mov byte[edi], cl
    
    leave
    ret
    

break_substitution:
    push ebp
    mov ebp, esp
    
    mov esi, [ebp + 8]
    mov edi, [ebp + 12]
    
substitution_table:
    mov byte[edi], 0x71      ; q
    mov byte[edi + 1], 0x61  ; a
    mov byte[edi + 2], 0x78  ; x
    mov byte[edi + 3], 0x62  ; b
    mov byte[edi + 4], 0x20  ; space
    mov byte[edi + 5], 0x63  ; c
    mov byte[edi + 6], 0x70  ; p
    mov byte[edi + 7], 0x64  ; d
    mov byte[edi + 8], 0x64  ; d
    mov byte[edi + 9], 0x65  ; e
    mov byte[edi + 10], 0x6C ; l
    mov byte[edi + 11], 0x66 ; f
    mov byte[edi + 12], 0x6F ; o
    mov byte[edi + 13], 0x67 ; g
    mov byte[edi + 14], 0x6D ; m
    mov byte[edi + 15], 0x68 ; h
    mov byte[edi + 16], 0x69 ; i
    mov byte[edi + 17], 0x69 ; i
    mov byte[edi + 18], 0x76 ; v
    mov byte[edi + 19], 0x6A ; j
    mov byte[edi + 20], 0x74 ; t
    mov byte[edi + 21], 0x6B ; k
    mov byte[edi + 22], 0x73 ; s
    mov byte[edi + 23], 0x6C ; l
    mov byte[edi + 24], 0x75 ; u
    mov byte[edi + 25], 0x6D ; m
    mov byte[edi + 26], 0x77 ; w
    mov byte[edi + 27], 0x6E ; n
    mov byte[edi + 28], 0x6A ; j
    mov byte[edi + 29], 0x6F ; o
    mov byte[edi + 30], 0x6B ; k
    mov byte[edi + 31], 0x70 ; p
    mov byte[edi + 32], 0x61 ; a
    mov byte[edi + 33], 0x71 ; q
    mov byte[edi + 34], 0x62 ; b
    mov byte[edi + 35], 0x72 ; r
    mov byte[edi + 36], 0x72 ; r
    mov byte[edi + 37], 0x73 ; s
    mov byte[edi + 38], 0x67 ; g
    mov byte[edi + 39], 0x74 ; t
    mov byte[edi + 40], 0x66 ; f
    mov byte[edi + 41], 0x75 ; u
    mov byte[edi + 42], 0x7A ; z
    mov byte[edi + 43], 0x76 ; v
    mov byte[edi + 44], 0x63 ; c
    mov byte[edi + 45], 0x77 ; w
    mov byte[edi + 46], 0x2E ; dot
    mov byte[edi + 47], 0x78 ; x
    mov byte[edi + 48], 0x68 ; h
    mov byte[edi + 49], 0x79 ; y
    mov byte[edi + 50], 0x79 ; y
    mov byte[edi + 51], 0x7A ; z
    mov byte[edi + 52], 0x65 ; e
    mov byte[edi + 53], 0x20 ; space
    mov byte[edi + 54], 0x6E ; n
    mov byte[edi + 55], 0x2E ; dot
    mov byte[edi + 56], 0x00 ; end

decrypt:
    xor edx, edx
    mov dl, byte[esi]
    test dl, dl
    je end
    cmp edx, 0x20
    jne not_space
    mov edx, 51
    jmp replace
not_space:
    cmp edx, 0x2E
    jne not_dot
    mov edx, 53
    jmp replace
not_dot:
    sub edx, 'a'    ; to obtain the index in the alphabet
    shl edx, 1      ; multiply by two
    dec edx
replace:
    xor eax, eax
    mov al, byte[edi + edx + 1]
    mov byte[esi], al
    inc esi
    jmp decrypt
end:
    leave
    ret


main:
    mov ebp, esp    ; for correct debugging
    push ebp
    mov ebp, esp
    sub esp, 2300
    
    ; fd = open("./input.dat", O_RDONLY);
    mov eax, 5
    mov ebx, filename
    xor ecx, ecx
    xor edx, edx
    int 0x80
    
    ; read(fd, ebp-2300, inputlen);
    mov ebx, eax
    mov eax, 3
    lea ecx, [ebp-2300]
    mov edx, [inputlen]
    int 0x80

    ; close(fd);
    mov eax, 6
    int 0x80

    ; all input.dat contents are now in ecx (address on stack)
    ; TASK 1: Simple XOR between two byte streams
    ; TODO: compute addresses on stack for str1 and str2
    ; TODO: XOR them byte by byte
    mov ebx, ecx        ; moving data address to ebx
    call next_word
    push ebx            ; push addr_str2
    sub ebx, eax        ; previous word
    push ebx            ; push addr_str1
    call xor_strings
    add esp, 8
    
    push ebx            ; push addr_str1
    call puts
    add esp, 4

    ; TASK 2: Rolling XOR
    ; TODO: compute address on stack for str3
    ; TODO: implement and apply rolling_xor function
    call next_word
    call next_word
    push ebx           ; push addr_str3
    call rolling_xor
    add esp, 4

    ; Print the second resulting string
    push ebx           ; push addr_str3
    call puts
    add esp, 4
	
    ; TASK 3: XORing strings represented as hex strings
    ; TODO: compute addresses on stack for strings 4 and 5
    ; TODO: implement and apply xor_hex_strings
    call next_word
    call next_word
    push eax           ; saving length for later
    push ebx           ; push addr_str5
    sub ebx, eax        ; previous word
    push ebx           ;push addr_str4
    call xor_hex_strings
    add esp, 8

    ; Print the third string
    push ebx           ;push addr_str4
    call puts
    add esp, 4
	
    ; TASK 4: decoding a base32-encoded string 
    ; TODO: compute address on stack for string 6
    ; TODO: implement and apply base32decode
    pop eax             ; retrieving previously saved length
    add ebx, eax        ; skipping str4 and str5
    add ebx, eax
    push ebx        ;push addr_str6
    call puts
    ;call base32decode
    add esp, 4

    ; Print the fourth string
    ;push addr_str6
    ;call puts
    ;add esp, 4

    ; TASK 5: Find the single-byte key used in a XOR encoding
    ; TODO: determine address on stack for string 7
    ; TODO: implement and apply bruteforce_singlebyte_xor
    sub esp, 1
    push esp            ;push key_addr
    call next_word
    push ebx            ;push addr_str7
    call bruteforce_singlebyte_xor
    add esp, 8

    ; Print the fifth string and the found key value
    push ecx            ;push keyvalue
    push ebx            ;push addr_str7
    call puts
    add esp, 4

    push fmtstr
    call printf
    add esp, 8

    ; TASK 6: Break substitution cipher
    ; TODO: determine address on stack for string 8
    ; TODO: implement break_substitution
    sub esp, 56
    push esp            ;push substitution_table_addr
    call next_word
    push ebx            ;push addr_str8
    call break_substitution
    add esp, 8

    ; Print final solution (after some trial and error)
    push ebx            ;push addr_str8
    call puts
    add esp, 4

    ; Print substitution table
    push esp            ;push substitution_table_addr
    call puts
    add esp, 4

    ; Phew, finally done
    xor eax, eax
    leave
    ret
