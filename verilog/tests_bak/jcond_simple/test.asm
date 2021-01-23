; RA <- 15
xor     RA,             RA              ; 0101 110 0 11 000 000     033a
inc     RA                              ; 0001 000 0 11 000 000     0308
shl     RA                              ; 0001 100 0 11 000 000     0318
shl     RA                              ; 0001 100 0 11 000 000     0318
shl     RA                              ; 0001 100 0 11 000 000     0318
shl     RA                              ; 0001 100 0 11 000 000     0318
dec     RA                              ; 0001 001 0 11 000 000     0348

; RB, RC, XA, XB <- 0
xor     RB,             RB              ; 0101 110 0 11 001 001     933a
xor     RC,             RC              ; 0101 110 0 11 010 010     4b3a
xor     XA,             XA              ; 0101 110 0 11 100 100     273a
xor     XB,             XB              ; 0101 110 0 11 101 101     b73a

; BA <- 1
xor     BA,             BA              ; 0101 110 0 11 110 110     6f3a
inc     BA                              ; 0001 000 0 11 000 110     6308

; BB <- 1;
xor     BB,             BB              ; 0101 110 0 11 111 111     ff3a
inc     BB;                             ; 0001 000 0 11 000 111     e308

; RB <- RA
; RA <- 0
inc     RB                              ; 0001 000 0 11 000 001     8308
dec     RA                              ; 0001 001 0 11 000 000     0348
jne     -2                              ; 1001 110 0 11 111 110     7f39

; BB <- 0x8000
; RC <- 15
; XA <- 1 + 2 + 3 + ... + 15
; XB <- 1 + 3 + 5 + ... + 15
shl     BB                              ; 0001 100 0 11 000 111     e318
inc     RC                              ; 0001 000 0 11 000 010     4308
test    RC,             BA              ; 0100 100 0 11 110 010     4f12
jz      +2                              ; 1001 010 0 00 000 010     4029
add     XB,             RC              ; 0101 000 0 11 010 101     ab0a
add     XA,             RC              ; 0101 000 0 11 010 100     2b0a
cmp     RC,             RB              ; 0100 010 0 11 001 010     5322
jb      -7                              ; 1001 000 1 11 111 001     9f89

; jump to start
neg     BB                              ; 0001 010 0 11 000 111     e328
jo      -27                             ; 1001 010 1 11 100 101     a7a9