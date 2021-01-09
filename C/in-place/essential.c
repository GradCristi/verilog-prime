#include<stdlib.h>

// Checks whether or not 'x' is a prime number.
int isPrime(int x) { // PUSH
    if (x <= 1) {               // CMP | JLE, JG
        return 0;           // MOV | RET
    }
    if (x == 2) {               // CMP | JE, JNE
        return 1;            // MOV | RET
    }
    
    int i;                      // PUSH

    for (
        i = 2;                  // MOV
        i <= x/2;               // CMP | JLE, JG | SHL
        i++                     // INCR
    ) {
        if (x % i == 0) {       // ?
            return 0;       // MOV | RET
        }
    }

    return 1; // MOV | RET
}

// Loops through the array elements starting from position 'index' 
// and shift them all 1 place to the left until '0' is found
void shiftArray(int *array, int index) {    // PUSH
    int i;                                  // PUSH
    i = index;                              // MOV

    while (array[i+1] != 0) {               // CMP | JNE, JE
        array[i] = array[i+1];              // MOV, INCR
        i++;                                // INCR
    }

    array[i] = 0;                           // MOV
}

// Loops through the array and removes non-prime elements until '0' is found
void primeify(int *array) {
    int i;                                  // PUSH
    i = 0;                                  // MOV

    while (array[i] != 0) {                 // CMP | JNE, JE
         if ( isPrime(array[i]) == 0 ) {// CMP | JNE, JE | JMP
             shiftArray(array, i);          // JMP
         } else {                           // JNE
            i++;                            // INCR
         }
    }
}


// Generate a random array and primeify it
int main(void) {
    int * arr;                              // PUSH (MOV?   )

    primeify(arr);                          // JMP

    free(arr);                              // POP
    
    return 0;                               // MOV | RET
}
