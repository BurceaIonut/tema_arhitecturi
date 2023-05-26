    DOSSEG
    .MODEL SMALL
    .STACK 32
    .DATA
encoded     DB  80 DUP(0)
temp        DB  '0x', 160 DUP(0)
fileHandler DW  ?
filename    DB  'in/in.txt', 0          ; Trebuie sa existe acest fisier 'in/in.txt'!
outfile     DB  'out/out.txt', 0        ; Trebuie sa existe acest director 'out'!
message     DB  80 DUP(0)
msglen      DW  ?
padding     DW  0
iterations  DW  0 
x           DW  ?
x0          DW  ?
a           DW  0
b           DW  0
secunda     DB ?
sutimi      DB ?
Nume        DB 'Burcea'
L_Nume      equ $ - Nume 
Prenume     DB 'Ionut'
L_Prenume   equ $ - Prenume
Alfabet     DB 'Bqmgp86CPe9DfNz7R1wjHIMZKGcYXiFtSU2ovJOhW4ly5EkrqsnAxubTV03a=L/d'
    .CODE
START:
    MOV     AX, @DATA
    MOV     DS, AX

    CALL    FILE_INPUT                  ; NU MODIFICATI!
    
    CALL    SEED                        ; TODO - Trebuie implementata

    CALL    ENCRYPT                     ; TODO - Trebuie implementata
    
    CALL    ENCODE                      ; TODO - Trebuie implementata
    
                                        ; Mai jos se regaseste partea de
                                        ; afisare pe baza valorilor care se
                                        ; afla in variabilele x0, a, b, respectiv
                                        ; in sirurile message si encoded.
                                        ; NU MODIFICATI!
    MOV     AH, 3CH                     ; BIOS Int - Open file
    MOV     CX, 0
    MOV     AL, 1                       ; AL - Access mode ( Write - 1 )
    MOV     DX, OFFSET outfile          ; DX - Filename
    INT     21H
    MOV     [fileHandler], AX           ; Return: AX - file handler or error code

    CALL    WRITE                       ; NU MODIFICATI!

    MOV     AH, 4CH                     ; Bios Int - Terminate with return code
    MOV     AL, 0                       ; AL - Return code
    INT     21H
FILE_INPUT:
    MOV     AH, 3DH                     ; BIOS Int - Open file
    MOV     AL, 0                       ; AL - Access mode ( Read - 0 )
    MOV     DX, OFFSET fileName         ; DX - Filename
    INT     21H
    MOV     [fileHandler], AX           ; Return: AX - file handler or error code

    MOV     AH, 3FH                     ; BIOD Int - Read from file or device
    MOV     BX, [fileHandler]           ; BX - File handler
    MOV     CX, 80                      ; CX - Number of bytes to read
    MOV     DX, OFFSET message          ; DX - Data buffer
    INT     21H
    MOV     [msglen], AX                ; Return: AX - number of read bytes

    MOV     AH, 3EH                     ; BIOS Int - Close file
    MOV     BX, [fileHandler]           ; BX - File handler
    INT     21H

    RET
SEED:
    MOV     AH, 2CH                     ; BIOS Int - Get System Time
    INT     21H
    MOV     [secunda], DH
    MOV     [sutimi], DL
    MOV     AL, CH
    mov     AH, 0
    MOV     BX, 3600
    mul     BX
    PUSH    DX
    PUSH    AX
    MOV     AL, CL
    mov     AH, 0
    MOV     BX, 60
    MUL     BX
    POP     CX
    ADD     AX, CX
    MOV     BL, [secunda]
    mov     BH, 0
    add     AX, BX
    MOV     BX, 100
    mul     BX
    MOV     CX, AX
    POP     AX
    PUSH    DX
    mov     BX, 100
    MUL     BX
    pop     DX
    add     DX, AX
    mov     ax, cx
    mov     bl, [sutimi]
    mov     bh, 0
    add     ax, bx
    mov     bx, 255
    div     bx
    mov     [x], DX
    mov     [x0], DX
    MOV     [x], 13
    MOV     [x0], 13
    CALL GENERATE_A
    CALL GENERATE_B
    mov     AX, [a]
    MOV     BX, 255
    mov     dx, 0
    div     BX
    MOV     [a], DX
     mov    AX, [b]
    MOV     BX, 255
    mov     dx, 0
    div     BX
    MOV     [b], DX
    MOV [a], 104
    MOV [b], 200

                                        ; TODO1: Completati subrutina SEED
                                        ; astfel incat la final sa fie salvat
                                        ; in variabila 'x' si 'x0' continutul 
                                        ; termenului initial
    RET
GENERATE_A:
    MOV     SI, OFFSET Prenume
    MOV     CX, [L_Prenume]
    LOOP_A:
    MOV     AX, [a]
    MOV     BL, [SI]
    mov     BH, 0
    ADD     AX, BX
    INC     SI
    mov     [a], AX
    LOOP LOOP_A
    mov     DX, 0
    MOV     BX, 255
    div     BX
    mov     [a], DX
    RET
GENERATE_B:
    MOV     SI, OFFSET Nume
    MOV     CX, [L_Nume]
    LOOP_B:
    MOV     AX, [b]
    MOV     BL, [SI]
    mov     BH, 0
    ADD     AX, BX
    INC     SI
    mov     [b], AX
    LOOP LOOP_B
    mov     dx, 0
    MOV     BX, 255
    div     BX
    mov     [b], DX
    RET
ENCRYPT:
    MOV     CX, [msglen]
    MOV     SI, OFFSET message
BUCLA:
    MOV     AX, [x]
    xor     [SI], AX
    INC     SI
    CMP     CX, 1
    JE      SARI
    CALL RAND
SARI:
    LOOP BUCLA
                                                ; TODO3: Completati subrutina ENCRYPT
                                            ; astfel incat in cadrul buclei sa fie
                                            ; XOR-at elementul curent din sirul de
                                            ; intrare cu termenul corespunzator din
                                            ; sirul generat, iar mai apoi sa fie generat
                                            ; si termenul urmator
    RET
RAND:
    MOV     DX, 0
    MOV     AX, [x]
    MOV     BX, [a]
    MUL     BX
    MOV     BX, [b]
    add     AX, BX
    MOV     BX, 255
    div     BX
    mov     [x], DX
                                            ; TODO2: Completati subrutina RAND, astfel incat
                                            ; in cadrul acesteia va fi calculat termenul
                                            ; de rang n pe baza coeficientilor a, b si a 
                                            ; termenului de rang inferior (n-1) si salvat
                                            ; in cadrul variabilei 'x'

    RET
ENCODE:
    MOV SI, OFFSET message
    MOV DI, OFFSET encoded
    MOV AX, [msglen]
    MOV DX, 0
    MOV BX, 8
    MUL BX
    MOV DX, 0
    MOV BX, 24
    DIV BX
    CMP DX, 0
    JE ENCODING
    CMP DX, 8
    JE ADD_2
    CMP DX, 10H
    JE ADD_1
ADD_1:
    MOV AX, [msglen]
    INC AX
    MOV [padding], 1
    JMP ENCODING
ADD_2:
    MOV AX, [msglen]
    ADD AX, 2
    MOV [padding], 2
ENCODING:
    MOV AX, [msglen]
    MOV DX, [padding]
    ADD AX, DX
    MOV DX, 0
    MOV BX, 3
    DIV BX
    MOV CX, AX
    MOV SI, OFFSET message
ENCODING_LOOP:
    MOV DI, OFFSET Alfabet
    MOV AL, 252
    MOV AH, 0
    MOV BX, 3
    AND BX, [SI]
    AND AX, [SI]
    SAR AX, 2
    ADD DI, AX
    MOV AX, [DI]
    MOV AH, 0
    MOV DI, OFFSET Alfabet
    PUSH SI
    MOV SI, OFFSET encoded
    ADD SI, [iterations]
    MOV byte ptr [SI], AL
    MOV DX, [iterations]
    INC DX
    MOV [iterations], DX
    POP SI
    INC SI
    MOV AX, 240
    AND AX, [SI]
    SAR AX, 4
    SAL BX, 4
    OR  AX, BX
    MOV BX, 15
    AND BX, [SI]
    ADD DI, AX
    MOV AX, [DI]
    MOV AH, 0
    MOV DI, OFFSET Alfabet
    PUSH SI
    MOV SI, OFFSET encoded
    ADD SI, [iterations]
    MOV byte ptr [SI], AL
    MOV DX, [iterations]
    INC DX
    MOV [iterations], DX
    POP SI
    INC SI
    MOV AX, 192
    AND AX, [SI]
    SAR AX, 6
    SAL BX, 2
    OR  BX, AX
    ADD DI, BX
    MOV BX, 63
    AND BX, [SI]
    MOV AX, [DI]
    MOV AH, 0
    MOV DI, OFFSET Alfabet
    PUSH SI
    MOV SI, OFFSET encoded
    ADD SI, [iterations]
    CMP BX, 0
    JE  VERIFICA_PADDING1
    JMP NORMAL1
VERIFICA_PADDING1:
    CMP CX, 1
    JNE NORMAL1
    MOV DX, [padding]
    CMP DX, 1
    JE  NORMAL1
    CMP DX, 2
    JE ADD_PADDING1
    JMP NORMAL1
ADD_PADDING1:
    MOV AL, '+'
NORMAL1:
    MOV byte ptr [SI], AL
    MOV DX, [iterations]
    INC DX
    MOV [iterations], DX
    POP SI
    ADD DI, BX
    MOV AX, [DI]
    MOV AH, 0
    MOV DI, OFFSET Alfabet
    INC SI
    PUSH SI
    MOV SI, OFFSET encoded
    ADD SI, [iterations]
    CMP BX, 0
    JE VERIFICA_PADDING2
    JMP NORMAL2
VERIFICA_PADDING2:
    CMP CX, 1
    JNE NORMAL2
    MOV DX, [padding]
    CMP DX, 1
    JGE  ADD_PADDING2
    JMP NORMAL2
ADD_PADDING2:
    MOV AL, '+'
NORMAL2:
    MOV byte ptr [SI], AL
    MOV DX, [iterations]
    INC DX
    MOV [iterations], DX
    POP SI
    DEC CX
    CMP CX, 0
    JE  FINAL
    JMP ENCODING_LOOP
FINAL:
                                            ; TODO4: Completati subrutina ENCODE, astfel incat
                                            ; in cadrul acesteia va fi realizata codificarea
                                            ; sirului criptat pe baza alfabetului COD64 mentionat
                                            ; in enuntul problemei si rezultatul va fi stocat                                        ; in cadrul variabilei encoded
    RET
WRITE_HEX:
    MOV     DI, OFFSET temp + 2
    XOR     DX, DX
DUMP:
    MOV     DL, [SI]
    PUSH    CX
    MOV     CL, 4

    ROR     DX, CL
    
    CMP     DL, 0ah
    JB      print_digit1

    ADD     DL, 37h
    MOV     byte ptr [DI], DL
    JMP     next_digit

print_digit1:  
    OR      DL, 30h
    MOV     byte ptr [DI] ,DL
next_digit:
    INC     DI
    MOV     CL, 12
    SHR     DX, CL
    CMP     DL, 0ah
    JB      print_digit2

    ADD     DL, 37h
    MOV     byte ptr [DI], DL
    JMP     AGAIN

print_digit2:    
    OR      DL, 30h
    MOV     byte ptr [DI], DL
AGAIN:
    INC     DI
    INC     SI
    POP     CX
    LOOP    dump
    
    MOV     byte ptr [DI], 10
    RET
WRITE:
    MOV     SI, OFFSET x0
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21h

    MOV     SI, OFFSET a
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET b
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET x
    MOV     CX, 1
    CALL    WRITE_HEX    
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET message
    MOV     CX, [msglen]
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, [msglen]
    ADD     CX, [msglen]
    ADD     CX, 3
    INT     21h

    MOV     AX, [iterations]
    MOV     BX, 4
    ;MUL     BX
    MOV     CX, AX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET encoded
    INT     21H

    MOV     AH, 3EH                     ; BIOS Int - Close file
    MOV     BX, [fileHandler]           ; BX - File handler
    INT     21H
    RET
    END START