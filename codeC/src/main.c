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
    
    FILE* src_file = fopen(argv[1], "r");
    if (src_file == NULL)
    {
        fclose(src_file);
        CWIRE_error(FILE_ERROR);
    }
    
    AVL* pTree = NULL;
    Station actual;

    int h, ret_var;
    lint id, load, capacity;
    char buffer[MAX_LEN];

    if (fgets(buffer, MAX_LEN, src_file) == NULL) {
        fclose(src_file);
        CWIRE_error(FILE_ERROR);
    }
    printf("%s\n", argv[3]);
    while (fgets(buffer, MAX_LEN, src_file))
    {   
        buffer[strcspn(buffer, "\n")] = '\0';
        ret_var = sscanf(buffer, "%ld;%ld;%ld", &id, &load, &capacity);
        if (ret_var == 3)
        {   
            printf("%ld:%ld:%ld\n", id, load, capacity);
            /*
            actual.id = id;
            actual.capacity = capacity;
            actual.load = load;
            pTree = insertAndSumAVL(pTree, actual, &h);*/
        } else
        {
            CWIRE_error(CSV_ERROR);
        }
        
        
        
    }
    fclose(src_file);

    //FILE* dest_file = fopen(argv[2], "w");
    
    
    
    
    return 0;
}