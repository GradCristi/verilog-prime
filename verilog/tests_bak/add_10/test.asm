; descending memory locations starting from ffff contain -1, -2, -3, -4, -5, -6, -7, -8
xor     RA,             RA              ; 0101 110 0 11 000 000     033a
xor     RB,             RB              ; 0101 110 0 11 001 001     933a
xor     RC,             RC              ; 0101 110 0 11 010 010     4b3a
xor     IS,             IS              ; 0101 110 0 11 011 011     db3a
xor     XA,             XA              ; 0101 110 0 11 100 100     273a
xor     XB,             XB              ; 0101 110 0 11 101 101     b73a
xor     BA,             BA              ; 0101 110 0 11 110 110     6f3a
xor     BB,             BB              ; 0101 110 0 11 111 111     ff3a
dec     XA                              ; 0001 001 0 11 000 100     2348
dec     XB                              ; 0001 001 0 11 000 101     a348
dec     XB                              ; 0001 001 0 11 000 101     a348
add     BA,             XA              ; 0101 000 0 11 100 110     670a
add     BA,             XB              ; 0101 000 0 11 101 110     770a
add     BB,             BA              ; 0101 000 0 11 110 111     ef0a
add     BB,             BA              ; 0101 000 0 11 110 111     ef0a

add     RA,             [XA - 0]        ; 0101 000 1 10 000 100     218a 0000
add     RB,             [XA - 1]        ; 0101 000 1 10 001 100     318a ffff
add     RC,             [XA - 2]        ; 0101 000 1 10 010 100     298a fffe
add     IS,             [XA - 3]        ; 0101 000 1 10 011 100     398a fffd
add     [XA -  8],      RA              ; 0101 000 0 10 000 100     210a fff8
add     [XA -  9],      RB              ; 0101 000 0 10 001 100     310a fff7
add     [XA - 10],      RC              ; 0101 000 0 10 010 100     290a fff6
add     [XA - 11],      IS              ; 0101 000 0 10 011 100     390a fff5

add     RA,             [XA + 0]        ; 0101 000 1 10 000 100     218a 0000
add     RB,             [XB + 0]        ; 0101 000 1 10 001 101     b18a 0000
add     RC,             [BA + 0]        ; 0101 000 1 10 010 110     698a 0000
add     IS,             [BB + 0]        ; 0101 000 1 10 011 111     f98a 0000
add     [XA - 12],      RA              ; 0101 000 0 10 000 100     210a fff4
add     [XB - 12],      RB              ; 0101 000 0 10 001 101     b10a fff4
add     [BA - 12],      RC              ; 0101 000 0 10 010 110     690a fff4
add     [BB - 12],      IS              ; 0101 000 0 10 011 111     f90a fff4

add     IS,             [BA + XA + 0]   ; 0101 000 1 10 011 000     198a 0000
add     RC,             [BA + XB + 0]   ; 0101 000 1 10 010 001     898a 0000
add     RB,             [BB + XA + 0]   ; 0101 000 1 10 001 010     518a 0000
add     RA,             [BB + XB + 0]   ; 0101 000 1 10 000 011     c18a 0000
add     [BA + XA - 12], IS              ; 0101 000 0 10 011 000     190a fff4
add     [BA + XB - 12], RC              ; 0101 000 0 10 010 001     890a fff4
add     [BB + XA - 12], RB              ; 0101 000 0 10 001 010     510a fff4
add     [BB + XB - 12], RA              ; 0101 000 0 10 000 011     c10a fff4
