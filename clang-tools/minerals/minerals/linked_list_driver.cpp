#include<stdlib.h>
#include<stdio.h>

#include "linked_list.hpp"

using namespace std;

int main()
{
    int num_nodes = 0;
    printf("==> Please enter the number of nodes that you would like your linked list to have: \n\n");
    cin >> num_nodes;
    printf("==> About to create a linked list of %d nodes ..\n\n", num_nodes);
    
    
    linked_list linked_list_instance;
    
    // for generating random data to be stored in linked list nodes
    
    srand((unsigned int)linked_list_instance.get_time());
    
    linked_list::node_t *current_node, *head_node;
    
    head_node = NULL;
    
    // create and set components of node in linked list
    
    for (int counter = 1; counter <= num_nodes; counter++)
    {
        // create node
        
        linked_list_instance.create_node(&current_node, counter);
        
        // set components of node
        
        linked_list_instance.set_node_components(current_node, rand() % 1000000000, head_node, counter);
        
        // set head node to current node
        
        head_node = current_node;
    }
    
    // set current node to the head node
    
    current_node = head_node;
    
    // traverse and print the newly formed linked list
    
    linked_list_instance.print_linked_list(current_node);
    
    return 0;
    
}