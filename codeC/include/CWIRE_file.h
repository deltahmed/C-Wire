/**
 * @file CWIRE_file_def.h
 * @author Ahmed A., Rayane M., Abdelwaheb A.
 * @brief Files definitions
 * @version 1.0
 * 
 * @copyright Copyright (c) 2024
 * 
 */

#ifndef CWIRE_FILE_H
#define CWIRE_FILE_H
#define FILE_LOGS "data/logs.txt"

#include "CWIRE_def.h"
#include "AVL.h"

AVL* readCSVtoAVL(char* src_path, AVL* pTree);
AVL* AVLtoCSV(char* dest_path, AVL* pTree);

#endif