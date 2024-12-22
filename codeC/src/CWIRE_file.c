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

    // Declare variables for the AVL, return variable, and data to read from the CSV.
    int h, ret_var;
    lint id, load, capacity; // Declare long integer types for the station ID, load, and capacity.
    char buffer[MAX_LEN]; // Declare a buffer to read each line from the CSV file.

    while (fgets(buffer, MAX_LEN, src_file)) // Start reading the file line by line.
    {   
        buffer[strcspn(buffer, "\n")] = '\0'; // Remove the newline character at the end of the line, if it exists.
        ret_var = sscanf(buffer, "%ld;%ld;%ld", &id, &capacity, &load);
        if (ret_var == 3) // Check if three values were successfully read (id, capacity, load).
        {   
            // If successful, insert the station into the AVL tree and update its height.
            pTree = insertAndSumAVL(pTree, CreateStation(id, capacity, load), &h); // Parse the values from the line into id, capacity, and load variables.
        } else
        {
            CWIRE_error(CSV_ERROR);
        }
    }
    // Close the source file after processing all lines.

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
        writeAVL(dest_file, pTree->LC); // Recursively write the left subtree to the destination file.
        fprintf(dest_file, "\n%ld:%ld:%ld", pTree->value.id, pTree->value.capacity, pTree->value.load); // Write the current node's station data (id, capacity, load) to the file in good format.
        writeAVL(dest_file, pTree->RC); // Recursively write the right subtree to the destination file.
    }
}

AVL* AVLtoCSV(char* dest_path, AVL* pTree){
    if (dest_path == NULL)
    {
        CWIRE_error(FILE_ERROR);
    }
    // Open the destination file in write mode.
    FILE* dest_file = fopen(dest_path, "w");
    if (dest_file == NULL)
    {
        fclose(dest_file);
        CWIRE_error(FILE_ERROR);
    }
    // Write the AVL tree data into the destination file.
    writeAVL(dest_file, pTree);

    // Return the AVL tree (the tree remains unchanged after writing to the file).
    return pTree;
}