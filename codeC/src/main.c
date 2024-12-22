/**
 * @file main.c
 * @author Ahmed A., Rémi S., Abdelwaheb A.
 * @brief Main
 * @version 1.0
 * 
 * @copyright Copyright (c) 2024
 * 
 */


#include "CWIRE_def.h"
#include "CWIRE_error.h"
#include "CWIRE_file.h"
#include "AVL.h"

int main(int argc, char** argv){
    if (argc != 3)
    {
        CWIRE_error(INCORRECT_ARGC_ERROR);
    }
    if (argv == NULL || argv[1] == NULL || argv[2] == NULL)
    {
        CWIRE_error(INCORRECT_ARGS_ERROR);
    }
    
    AVL* pTree = NULL;

    // Call the function to read the data from the input CSV file and insert it into the AVL tree.
    // The first argument is the input file path (argv[1]), and the second argument is the tree (initially NULL).
    pTree = readCSVtoAVL(argv[1], pTree);

    // Call the function to write the AVL tree data to the output CSV file.
    // The second argument is the output file path (argv[2]), and the tree (pTree) is the data to write.
    AVLtoCSV(argv[2], pTree);

    pTree = freeAVL(pTree);

    return 0;
}