/**
 * @file CWIRE_file.c
 * @author Ahmed A., Rémi S., Abdelwaheb A.
 * @brief Files Handeling functions 
 * @version 1.0
 * 
 * @copyright Copyright (c) 2024
 * 
 */

#include "CWIRE_file.h"
#include "AVL.h"

/**
 * @brief The file to open in read mode
 * @param filename The root of the AVL tree is passed to the function, initialized to NULL if it is empty
 * @return The new root of the complete AVL tree is returned
 */
AVL* readCSVtoAVL(char* src_path, AVL* pTree){
    if (src_path == NULL)
    {
        CWIRE_error(FILE_ERROR);
    }
    
    FILE* src_file = fopen(src_path, "r");
    if (src_file == NULL)
    {
        fclose(src_file);
        CWIRE_error(FILE_ERROR);
    }
    
    int h, ret_var;
    lint id, load, capacity;
    char buffer[MAX_LEN];

    if (fgets(buffer, MAX_LEN, src_file) == NULL) {
        fclose(src_file);
        CWIRE_error(FILE_ERROR);
    }
    while (fgets(buffer, MAX_LEN, src_file))
    {   
        buffer[strcspn(buffer, "\n")] = '\0';
        ret_var = sscanf(buffer, "%ld;%ld;%ld", &id, &load, &capacity);
        if (ret_var == 3)
        {   
            pTree = insertAndSumAVL(pTree, CreateStation(id, capacity, load), &h);
        } else
        {
            CWIRE_error(CSV_ERROR);
        }
    }
    fclose(src_file);
    return pTree;
}

void writeAVL(FILE* dest_file, AVL* pTree){
    if (dest_file == NULL)
    {
        CWIRE_error(FILE_ERROR);
    }
    if (pTree != NULL)
    {
        writeAVL(dest_file, pTree->LC);
        fprintf(dest_file, "%ld:%ld:%ld", pTree->value.id, pTree->value.capacity, pTree->value.load);
        writeAVL(dest_file, pTree->RC);
    }
}


AVL* AVLtoCSV(char* dest_path, AVL* pTree){
    if (dest_path == NULL)
    {
        CWIRE_error(FILE_ERROR);
    }
    
    FILE* dest_file = fopen(dest_path, "w");
    if (dest_file == NULL)
    {
        fclose(dest_file);
        CWIRE_error(FILE_ERROR);
    }
    
    writeAVL(dest_file, pTree);


    return pTree;
}