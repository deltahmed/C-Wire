/**
 * @file AVL.c
 * @author Ahmed A., Rémi S., Abdelwaheb A.
 * @brief AVL handling functions
 * @version 1.0
 * 
 * @copyright Copyright (c) 2024
 * 
 */


#include "AVL.h"
#include "CWIRE_def.h"
#include "CWIRE_error.h"
#include "CWIRE_debug.h"
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

/**
 * @brief Validates the data of a Station structure.
 * @param station The structure to validate.
 * @return int Return 1 if the data is valid; otherwise, 0.
 */
int validateStationData(Station station){
    if(station.id <= 0)
    {
        CWIRE_error(CSV_ERROR);
        return 0;
    }
    if(station.capacity < 0)
    {
        CWIRE_error(CSV_ERROR);
        return 0;
    }
    if(station.load < 0)
    {
        CWIRE_error(CSV_ERROR);
        return 0;
    }
    return 1;
}

/**
 * @brief Creates a new AVL tree node.
 * @param e The value to store in the new node.
 * @return A pointer to the new AVL node.
 */
AVL* CreateAVL(Station e)
{
    if(!validateStationData(e))
    {
        return NULL;
    }
    AVL* new = (AVL* )malloc(sizeof(AVL));
    if (new == NULL)
    {
        CWIRE_error(ALLOCATION_ERROR);
    }
    new->value = e; 
    new->LC = NULL; 
    new->RC = NULL; 
    new->balance = 0;    
    return new;
}

/**
 * @brief Performs a left rotation on the given AVL node.
 * @param a The AVL node to rotate.
 * @return The new root node after rotation.
 */
AVL* LeftRotation(AVL* a)
{
    if(a == NULL || a->RC == NULL) return a;
    
    AVL* pivot = a->RC; 
    int balance_a = a->balance, balance_p = pivot->balance;

    a->RC = pivot->LC; 
    pivot->LC = a;     

    a->balance = balance_a - max(balance_p, 0) - 1;
    pivot->balance = min3(balance_a - 2, balance_a + balance_p - 2, balance_p - 1);

    return pivot; 
}

/**
 * @brief Performs a right rotation on the given AVL node.
 * @param a The AVL node to rotate.
 * @return The new root node after rotation.
 */
AVL* RightRotation(AVL* a)
{
    if(a == NULL || a->LC == NULL)
    {
        return a;
    }
    
    AVL* pivot = a->LC; 
    int balance_a = a->balance, balance_p = pivot->balance;

    a->LC = pivot->RC; 
    pivot->RC = a;     

    a->balance = balance_a - min(balance_p, 0) + 1;
    pivot->balance = max3(balance_a + 2, balance_a + balance_p + 2, balance_p + 1);

    return pivot;
}

/**
 * @brief Performs a right rotation on the given AVL node.
 * @param a The AVL node to rotate.
 * @return The new root node after rotation.
 */
AVL* doubleLeftRotation(AVL* a)
{
    if(a == NULL || a->RC == NULL) 
    {
        return a;
    }

    a->RC = RightRotation(a->RC);
    return LeftRotation(a);
}

/**
 * @brief Performs a double right rotation on the given AVL node.
 * @param a The AVL node to rotate.
 * @return The new root node after rotation.
 */
AVL* doubleRightRotation(AVL* a)
{
    if(a == NULL || a->LC == NULL)
    {
        return a;
    } 

    a->LC = LeftRotation(a->LC);
    return RightRotation(a);
}

/**
 * @brief Balances an AVL tree node based on its balance factor.
 * @param a The AVL node to balance.
 * @return The balanced AVL node.
 */
AVL* balanceAVL(AVL* a)
{
    if(a == NULL)
    {
        return a;
    }
    if (a->balance >= 2)
    {
        if (a->RC->balance >= 0)
        {
            return LeftRotation(a); 
        }
        else
        {
            return doubleLeftRotation(a); 
        }
    }
    else if (a->balance <= -2)
    { 
        if (a->LC->balance <= 0)
        {
            return RightRotation(a);
        }
        else
        {
            return doubleRightRotation(a);
        }
    }
    return a;
}

/**
 * @brief Inserts a value into an AVL tree and balances it.
 * @param a The root of the AVL tree.
 * @param e The value to insert.
 * @param h A pointer to an integer that tracks if the tree height changes.
 * @return The new root of the AVL tree after insertion and balancing.
 */
AVL* insertAndSumAVL(AVL* a, Station e, int *h)
{
    if(!validateStationData(e))
    {
        return a;
    }
    if (a == NULL)
    {          
        *h = 1; 
        return CreateAVL(e);
    }
    else if (e.id < a->value.id)
    { 
        a->LC = insertAndSumAVL(a->LC, e, h);
        *h = -*h; 
    }
    else if (e.id > a->value.id)
    { 
        a->RC = insertAndSumAVL(a->RC, e, h);
    }
    else
    {   
        a->value.load += e.load;
        if (!a->value.capacity)
        {
            a->value.capacity = e.capacity;
        }
        *h = 0;
        return a;
    }

    
    if (*h != 0)
    {
        a->balance += *h;
        a = balanceAVL(a);
        *h = (a->balance == 0) ? 0 : 1; 
    }
    return a;
}

/**
 * @brief Free the memory allocated to the AVL
 * @param a The root of the AVL tree.
 * @return NULL
 */
AVL* freeAVL(AVL* a){
    if (a != NULL)
    {
        a->LC = freeAVL(a->LC);
        a->RC = freeAVL(a->RC);
        free(a);
    }
    return NULL;
    
}

/**
 * @brief Sums the consumption (load) of stations of a specific type.
 * @param root The root of the AVL tree.
 * @param type The type of the station to filter.
 * @return The total load of stations of the specific type.
 */
long sumConsumptionByType(AVL* root, StationType type)
{
    if(root == NULL)
    {
        return 0;
    }

    long leftSum = sumConsumptionByType(root->LC, type);
    long rightSum = sumConsumptionByType(root->RC, type);
    long currentLoad = (root->value.type == type) ? root->value.load : 0;

    return leftSum + rightSum + currentLoad;
}