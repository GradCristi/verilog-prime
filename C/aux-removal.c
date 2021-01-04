#include <stdio.h>
#include<string.h>

// we need to create a program that removes all non prime numbers from a vector
//so first of all we need to create a method to test if a number is prime or not
//2nd of all we need to create a method to add to an auxiliary vector all the information we need
//and just overwrite them afterwards

//function to test if the number is prime or not, returns 1 if it is, 0 if not
int isPrime(int a) {
	int flag = 1; //innocent until proven guilty 
	int k;
	//we cycle to see if our number does not divide by any numbers between 1 and a/2
	for (k = 2; k <= a / 2; k++) {
		if (a % k == 0) {
			flag = 0;
		}
	}
	return flag;
}




int main() {
	int i,j = 0;
	//vector received(this is a placeholder)
	int vector[] = { 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 };
	//auxiliary vector, filled with 0
	int aux[sizeof(vector) / sizeof(int)] = {0};

	//go through all the variabiles in vector
	//if they are prime, write them in aux
	for (i = 0; i < sizeof(vector) / sizeof(int); i++) {
		if (isPrime(vector[i])) {									 
			aux[j] = vector[i];
			j = j + 1;
		}
	}

	//we rewrite the vector with our aux
	for (i = 0; i < sizeof(aux) / sizeof(int); i++) {
		vector[i] = aux[i];
	}

	//print out the result
	for (i = 0; i < sizeof(aux) / sizeof(int); i++) {	
		printf("%d\n", vector[i]);
	}
}

