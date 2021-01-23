; calculeaza recursiv suma numerelor de la 1 la n
; RC - rezultatul
; RA - n = 10
; BB - pentru adresa

; initializari
mov     XA,             0x000f          ; 0010 000 0 11 000 100     2304 000f
mov     XB,             0x0010          ; 0010 000 0 11 000 101     a304 0010
mov     BB,             0x0000          ; 0010 000 0 11 000 111     e304 0000
mov     RA,             0x000a          ; 0010 000 0 11 000 000     0304 000a
mov     RC,             [XB]            ; 0000 000 1 00 010 101     a880
mov     IS,             [XA + 1]        ; 0000 000 1 10 011 100     3980 0001
call    BB+0x0016                       ; 0000 100 0 10 000 111     e110 0016
jmp     BB+0x000d                       ; 0000 101 0 10 000 111     e150 000d

; urmeaza 1 cuvint cu valoarea 0x0001 si 6 cuvinte cu valoarea 0x0000

; functie care calculeaza suma numerelor de la 1 la n
; RA -> n
; RC -> suma
cmp     RA,             [BB + XA + 0]   ; 0100 010 1 10 000 010     41a2 0000
jne     +4                              ; 1001 110 0 00 000 100     2039
mov     RC,             0x0001          ; 0010 000 0 11 000 010     4304 0001
ret                                     ; 1000 100 0 00 000 000     0011
push    RA                              ; 0000 010 0 11 000 000     0320
sub     RA,             [XB - 1]        ; 0101 010 1 10 000 101     a1aa ffff
call    BB+0x0016                       ; 0000 100 0 10 000 111     e110 0016
pop     RA                              ; 0000 011 0 11 000 000     0360
add     RC, RA                          ; 0101 000 0 11 000 010     430a
ret                                     ; 1000 100 0 00 000 000     0011
