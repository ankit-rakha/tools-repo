// Calculate elapsed and processing time - CalTime.cpp
// No guarantees offered.
// usage:
// 1) download the program or copy the contents
// 2) g++ CalTime.cpp -o CalTime -lboost_system-mt -lboost_thread-mt
// 3) ./CalTime

#include <iostream>
#include <time.h>
#include <boost/thread/thread.hpp>

using namespace std;

int main()
{
	clock_t init = clock();
	int t0 = time(NULL);

	boost::this_thread::sleep( boost::posix_time::seconds(10) );
	//boost::this_thread::sleep( boost::posix_time::milliseconds(1000) );

	clock_t final = clock() - init;
	int t1 = time(NULL);

	cout << "Procesing time: " << (double)final / ((double)CLOCKS_PER_SEC) << endl;

	printf ("Elapsed time: %d secs\n", t1 - t0);

	return 0;
}
