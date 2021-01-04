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

// Generate a random array and primeify it
int main(void) {
    // Generate sample data
    int *arr = generate();

    free(arr);
    return 0;
}