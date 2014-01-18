#include <iostream>

#include <vector>

#include <iomanip>

using namespace std;

// Create a sorted vector

void createVector( vector<int> &vect1, const int size ){

for ( int counter = 0; counter < size; ++counter ){

vect1.push_back( arc4random() % 100 + 1 );

}

sort( vect1.begin(), vect1.end() );

}

// Display index

void displayIndex( vector<int> const &vect1 ){

for ( int counter = 0; counter < vect1.size(); ++counter ){

cout << setw (10) << counter;

}

cout << endl;

}

// Display vector

void displayVector( vector<int> const &vect1 ){

for ( int counter = 0; counter < vect1.size(); ++counter ){

cout << setw (10) << vect1[ counter ];

}

cout << endl;

displayIndex( vect1 );

cout << endl;

}

// Binary search - doesn't take care of duplicate entries

long binarySearch( vector<int> const &vect1, const int key ){

long first_element = 0;

long last_element = vect1.size() - 1;

int counter1 = 0;

while( first_element <= last_element ){

++counter1;

long mid_element = ( first_element + last_element ) / 2;

cout << "Round " << counter1 << endl << endl;

cout << "First element: " << vect1[ first_element ] << " at position: " << first_element << endl;

cout << "Mid element: " << vect1[ mid_element ] << " at position: " << mid_element << endl;

cout << "Last element: " << vect1[ last_element ] << " at position: " << last_element << endl;

cout << "Key is: " << key << endl << endl;

if ( key > vect1[ mid_element ] ){

first_element = mid_element + 1;

}

else if( key < vect1[ mid_element ] ){

last_element = mid_element - 1;

}

else if( key == vect1[ mid_element ] ){

return mid_element;

}

}

return -1;

}

int main( int argc, char * argv[], char **envp, char **apple ){

vector<int> vect1;

const int size = 10;

int key = 0;

// Create a vector of random integers

createVector( vect1, size );

// Display vector

displayVector( vect1 );

cout << endl << "Enter a number to search: ";

cin >> key;

// Search an element in vector

long retval;

retval = binarySearch( vect1, key );

if ( retval >= 0 ){

cout << key << " found at position: " << retval << endl;

}

else{

cout << key << " not found" << endl;

}

return 0;

}
