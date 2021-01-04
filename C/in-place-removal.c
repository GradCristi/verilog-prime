#include <stdlib.h>
#include <time.h>
#include <stdio.h>

// boolean values
#define TRUE 1
#define FALSE 0

// array parameters
#define SIZE 100
#define MINVAL 1
#define MAXVAL 100

// This function is only implemented for testing purposes.
// It generates an array of SIZE elements, all being random integers
int *generate() {
    // Seed random number generator
    time_t t;
    srand((unsigned) time(&t));

    int i; // element index
    int *array = (int*)calloc(SIZE, sizeof(int));
    if (array == NULL) {
        printf("err: Memory allocation failed!");
        exit(1);
    }

    // fill array with random numbers
    for (i = 0; i < SIZE; i = i + 1) {
        array[i] = rand() % MAXVAL + MINVAL;
    }

    return array;
}

// Loops through an array and prints each element until '0' is found
void printArray(int *array) {
    int i = 0;

    while (array[i] != 0) {
        printf("%d ", array[i]);
        i++;
    }
    printf("\n");
}

// Checks whether or not 'x' is a prime number.
int isPrime(int x) {
    int i;

    for (i = 2; i < x/2; i++) {
        if (x % i == 0) {
            return FALSE;
        }
    }

    return TRUE;
}

// Loops through the array elements starting from position 'index' 
// and shift them all 1 place to the left until '0' is found
void shiftArray(int *array, int index) {
    int i = index;

    while (array[i+1] != 0) {
        array[i] = array[i+1];
        i++;
    }

    array[i] = 0;
}

// Loops through the array and removes non-prime elements until '0' is found
void primeify(int *array) {
    int i = 0;

    while (array[i] != 0) {
         if ( isPrime(array[i]) == FALSE ) {
             shiftArray(array, i);
         } else {
            i++;
         }
    }
}


// Generate a random array and primeify it
int main(void) {
    // Generate sample data
    int *arr = generate();

    // Print sample data
    printf("Original array: \n");
    printArray(arr);

    free(arr);
    return 0;
}