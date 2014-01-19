#ifndef __data_structures__linked_list__
#define __data_structures__linked_list__

#include <iostream>
#include <sys/time.h>

class linked_list
{
	
public:
	
	/*
     create a node -- node is basically a struct
	 that contains data and pointer to next node
     */
    
	struct node
    {
        long long val;
        int id;
        struct node *next;
    };
    
    typedef struct node node_t;
    
    // default constructor
	
    linked_list();
    
    // default destructor
    
    ~linked_list();
    
    long get_time();
    
    void create_node(node_t **node, int counter);
    
    void set_node_components(node_t *node, int data, node_t *head_node, int counter);
    
    void print_linked_list(node_t *head_node);
    
};


#endif /* defined(__data_structures__linked_list__) */
