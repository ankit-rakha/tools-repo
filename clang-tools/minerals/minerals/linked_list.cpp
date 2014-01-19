#include <stdio.h>
#include <stdlib.h>
#include <iostream>

#include "linked_list.hpp"

using namespace std;

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// default constructor

linked_list::linked_list()
{
    printf("==> file: %s, function: %s, line: %d, message: Default constructor called ..\n\n", __FILE__, __FUNCTION__, __LINE__);
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// defaul destructor

linked_list::~linked_list()
{
    printf("==> file: %s, function: %s, line: %d, message: Default destructor called ..\n\n", __FILE__, __FUNCTION__, __LINE__);
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

long linked_list::get_time()
{
	struct timeval tv;
	gettimeofday(&tv, NULL);
	return (tv.tv_sec * 1000000) +  tv.tv_usec;
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

void linked_list::create_node(node_t **node, int counter)
{
    printf("==> file: %s, function: %s, line: %d, message: Creating node %d\n\n", __FILE__, __FUNCTION__, __LINE__, counter);
    
    *node = (node_t *) malloc (sizeof(node_t));
    
    if (*node == NULL)
    {
        printf("==> file: %s, function: %s, line: %d, message: Malloc failure while creating node %d\n\n", __FILE__, __FUNCTION__, __LINE__, counter);
    }
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

void linked_list::set_node_components(node_t *node, int data, node_t *head_node, int counter)
{
    
    printf("==> file: %s, function: %s, line: %d, message: Setting components for node %d\n\n", __FILE__, __FUNCTION__, __LINE__, counter);
    
    node->id = counter;
    node->val = data;
    node->next = head_node;
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

void linked_list::print_linked_list(node_t *head_node)
{
    printf("==> file: %s, function: %s, line: %d, message: Printing Linked List\n\n", __FILE__, __FUNCTION__, __LINE__);
    
    while (head_node)
    {
        printf("Node %d data: %lld\t", head_node->id, head_node->val);
        head_node = head_node->next;
    }
    
    printf("\n\n");
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++