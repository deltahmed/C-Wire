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
    if (argc != 4)
    {
        CWIRE_error(INCORRECT_ARGC_ERROR);
    }
    if (argv == NULL || argv[1] == NULL || argv[2] == NULL || argv[3] == NULL)
    {
        CWIRE_error(INCORRECT_ARGS_ERROR);
    }

    AVL* pTree = NULL;
    
    pTree = readCSVtoAVL(argv[1], pTree);

    AVLtoCSV(argv[2], pTree);

    pTree = freeAVL(pTree);

    return 0;
}