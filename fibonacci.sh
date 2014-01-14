#!/bin/bash

# --Fibonacci series--
# --Make executable: chmod +x fibonacci.sh--
# --Usage: ./fibonacci.sh 15--

if [ $# -ne 1 ]; then
	
	echo "==> Usage: ./fibonacci.sh number_of_elements_in_fibonacci_series"
	exit -1
	
fi

# --How many elements of fibonacci series you want to display--

total_elements="$1"

# --First element--

first_element=0

# --Second element--

second_element=1

# --Print first two elements--

printf "$first_element\t$second_element"

# --Generate all other elements

for ((counter=1;counter<=total_elements-2;counter++));do

 third_element=$((first_element+second_element))
 first_element="$second_element"
 second_element="$third_element"

printf "\t$third_element"

done

# --Print an extra line for formatting--

echo ""



