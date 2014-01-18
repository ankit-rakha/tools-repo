#include <iostream>

using namespace std;

// No need to use #include <cstdlib> AND #include <ctime>

// Create an array of integers

void createArray( int *ptr_create, const int size ){

// srand( static_cast<unsigned>( time( NULL ) ) );

for ( int counter = 0; counter < size; ++counter ){

//array_dev[ counter ] = rand() % 100 + 1;
 *( ptr_create + counter ) = arc4random() % 100 + 1;
 }
}

// Display elements of array

void displayArray( int *ptr_disp, const int size ){
 for ( int counter = 0; counter < size; ++counter ){
//cout << *( ptr_disp + counter ) << " ";
 cout << *ptr_disp << " ";
 ++ptr_disp;
 }
}

// Implementing a linear search algorithm

int linearSearch( int array_search[], const int size, int key ){

for ( int counter = 0; counter < size; ++counter ){
 if ( key == array_search[ counter ] ){
 return counter;
 }
 }

return -1;
}

// main function

int main(int argc, char * argv[], char **envp, char **apple){

const int size = 10;

int array_init[ size ]={}, key = 0;

createArray( array_init, size );

displayArray( array_init, size );

cout << endl << "Enter the key to be searched: ";
 cin >> key;

int retval=linearSearch( array_init, size, key );

if ( retval >= 0 ){
 cout << key << " found at position " << retval << endl;
 }
 else{
 cout << key << " not found" << endl;
 }
 return 0;
}


