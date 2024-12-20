/**
 * @file AVL.h
 * @author Ahmed A., Rémi S., Abdelwaheb A.
 * @brief AVL handling header
 * @version 1.0
 * 
 * @copyright Copyright (c) 2024
 * 
 */

#ifndef AVL_H
#define AVL_H
#include "CWIRE_def.h"
#include "CWIRE_error.h"
#include "CWIRE_debug.h"
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "Station.h"


/**
 * @struct AVL (avl_struct)
 * @brief Structure representing a node in an AVL (Adelson-Velsky and Landis) tree.
 */
typedef struct avl_struct
{
    /**
     * @brief Value stored in the node.
     */
    Station value;              

    /**
     * @brief Balance factor of the node.
     */
    int balance;            

    /**
     * @brief Pointer to the left child node.
     */
    struct avl_struct *LC; 

    /**
     * @brief Pointer to the right child node.
     */
    struct avl_struct *RC; 
} AVL;


AVL* CreateAVL(Station e);
AVL* LeftRotation(AVL* a);
AVL* RightRotation(AVL* a);
AVL* doubleLeftRotation(AVL* a);
AVL* doubleRightRotation(AVL* a);
AVL* balanceAVL(AVL* a);
AVL* insertAndSumAVL(AVL* a, Station e, int *h);
AVL* freeAVL(AVL* a);
int validateStationData(Station station);
			
#endif