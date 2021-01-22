;; Initializare registre:

inc     RA                              ; 0001 000 0 11 000 000     0308
inc     RA                              ; 0001 000 0 11 000 000     0308
inc     RA                              ; 0001 000 0 11 000 000     0308
; RA should be 3

inc     RB                              ; 0001 000 0 11 000 001     8308
shl     RB                              ; 0001 100 0 11 000 001     8318
; RB should be 2

inc     RC                              ; 0001 000 0 11 000 010     4308
; RC should be 1

dec     XA                              ; 0001 001 0 11 000 100     2348
; XA should be -1 (0xffff)

dec     XB                              ; 0001 001 0 11 000 101     a348
dec     XB                              ; 0001 001 0 11 000 101     a348
; XB should be -2 (0xfffe)

add     BA, XA                          ; 0101 000 0 11 100 110     670a
add     BA, XB                          ; 0101 000 0 11 101 110     770a
; BA should be -3 (0xfffd)

add     BB, BA                          ; 0101 000 1 11 111 110     7f8a
add     BB, BA                          ; 0101 000 1 11 111 110     7f8a
; BB should be -6 (0xfffa)

;;--------------------------------------------------------------------------

;; Instructiuni pentru testare cu 2 operanzi:

add     RA, [XA]                        ; 0101 000 1 00 000 100     208a
; RA = 3, [XA] = 1
; RA should be 4
; IND should be _____ (0x0000)

adc     RB, [XB]                        ; 0101 001 1 00 001 101     b0ca
; RB = 2, [XB] = -2 (0xfffe), C = 0
; RB should be 0
; IND should be P_Z_C (0x0015)

sub     RC, [BA]                        ; 0101 010 1 00 010 110     68aa
; RC = 1, [BA] = -32767 (0x8001)
; RC should be -32768 (0x8000)
; IND should be _S_OC (0x000b)

sbb     IS, [BB]                        ; 0101 011 1 00 011 111     f8ea
; IS = 0, [BB] = -32766 (0x8002), C = 1
; IS should be 32765 (0x7ffd)
; IND should be P___C (0x0011)

cmp     RA, [BA + XB]                   ; 0100 010 1 00 000 001     80a2
; RA = 4, [BA + XB] = -6 (0xfffa)
; RA should be 4
; IND should be P___C (0x0011)

test    RA, [BB + XA]                   ; 0100 100 1 00 000 010     4092
; RA = 4, [BB + XA] = 0x8000
; RA should be 4
; IND should be P_Z__ (0x0014)


cmp     [BA], RC                        ; 0100 010 0 00 010 110     6822
; [BA] = -32767 (0x8001), RC = -32768 (0x8000)
; [BA] should be -32767 (0x8001)
; IND should be _____ (0x0000)

cmp     [BA + XB], RA                   ; 0100 010 0 00 000 001     8022
; [BA + XB] = -6 (0xfffa), RA = 4
; BA + XB] should be -6 (0xfffa)
; IND should be _S___ (0x0008)

test    [BB + XA], RA                   ; 0100 100 0 00 000 010     4012
; [BB + XA] = 0x8000, RA = 4
; [BB + XA] should be 0x8000
; IND should be P_Z__ (0x0014)


add     [XA], XA                        ; 0101 000 0 00 100 100     240a
; [XA] = 1, XA = 0xffff
; [XA] should be 0
; IND should be P_Z_C (0x0015)

adc     [XB], IS                        ; 0101 001 0 00 011 101     b84a
; [XB] = -2 (0xfffe), IS = 32765 (0x7ffd), C = 1
; [XB] should be 32764 (0x7ffc)
; IND should be ____C (0x0001)

cmp     [BA], RA                        ; 0100 010 0 00 000 110     6022
; [BA] = -32767 (0x8001), RA = 4
; [BA] should be -32767 (0x8001)
; IND should be P__O_ (0x0012)

sbb     [BB], RC                        ; 0101 011 0 00 010 111     e86a
; [BB] = -32766 (0x8002), RC = -32768 (0x8000), C  = 0
; [BB] should be 2
; IND should be _____ (0x0000)

xor     [BA + XA], RC                   ; 0101 110 0 00 010 000     083a
; [BA + XA] = 0xcccc, RC = 0x8000
; [BA + XA] should be 0x4ccc
; IND should be _____ (0x0000)

and     [BB + XB], IS                   ; 0101 100 0 00 011 011     d81a
; [BB + XB] = 0xaaaa, IS = 0x7ffd
; [BB + XB] should be 0x2aa8
; IND should be P____ (0x0010)

;;--------------------------------------------------------------------------

;; Reinitializare registre de adresa:

xor     XA, XA                          ; 0101 110 0 11 100 100     273a
inc     XA                              ; 0001 000 0 11 000 100     2308
; XA should be 1

xor     XB, XB                          ; 0101 110 0 11 101 101     b73a
inc     XB                              ; 0001 000 0 11 000 101     a308
inc     XB                              ; 0001 000 0 11 000 101     a308
; XB should be 2

xor     BA, BA                          ; 0101 110 0 11 110 110     6f3a
add     BA, XA                          ; 0101 000 1 11 110 100     2f8a
add     BA, XB                          ; 0101 000 1 11 110 101     af8a
; BA should be 3

xor     BB, BB                          ; 0101 110 0 11 111 111     ff3a
add     BB, BA                          ; 0101 000 1 11 111 110     7f8a
add     BB, BA                          ; 0101 000 1 11 111 110     7f8a
; BB should be 6

;;--------------------------------------------------------------------------

;; Instructiuni pentru testare cu 1 operand:
inc     [XA]                            ; 0001 000 0 00 000 100     2008
; [XA] = 776 (0x0308)
; [XA] should be 777 (0x0309)
; IND should be P____ (0x0010)

dec     [XB]                            ; 0001 001 0 00 000 101     a048
; [XB] = 776 (0x0308)
; [XB] should be 775 (0x0307)
; IND should be _____ (0x0000)

neg     [BA]                            ; 0001 010 0 00 000 110     6028
; [BA] = -31992 (0x8308)
; [BA] should be 31992 (0x7cf8)
; IND should be P___C (0x0011)

not     [BB]                            ; 0001 011 0 00 000 111     e068
; [BB] = 0x2348
; [BB] should be 0xdcb7
; IND should be _S___ (0x0008)

sar     [BA + XA]                       ; 0001 110 0 00 000 000     0038
; [BA + XA] = -31976 (0x8318)
; [BA + XA] should be -15988 (0xc18c)
; IND should be PS___ (0x0018)

shl     [BA + XB]                       ; 0001 100 0 00 000 001     8018
; [BA + XB] = 17160 (0x4308)
; [BA + XB] should be 34320 (0x8610)
; IND should be PS_O_ (0x001a)

shr     [BB + XA]                       ; 0001 101 0 00 000 010     4058
; [BB + XA] = 41800 (0xa348)
; [BB + XA] should be 20900 (0x51a4)
; IND should be P__O_ (0x0012)
