/**
 * @file CWIRE_debug.c
 * @author Ahmed A., Rémi S., Abdelwaheb A.
 * @brief debug functions 
 * @version 1.0
 * 
 * @copyright Copyright (c) 2024
 * 
 */
#include "CWIRE_debug.h"
#include "CWIRE_file.h"

/**
 * @brief Logs a debug message with file, function, and line information.
 *
 * @param file The name of the file where the debug message is.
 * @param function The name of the function where the debug message is.
 * @param line The line number where the debug message is.
 */
void CWIRE_debug_message(const char * file, const char * function, int line){
    FILE* logs = fopen(FILE_LOGS, "a");
    fprintf(logs,"\nfile : %s func : %s line :%d",file, function, line);
    fclose(logs);
}

/**
 * @brief Logs a debug message with an integer value, file, function, and line information.
 * 
 * @param value The integer value to log.
 * @param file The name of the file where the debug message is.
 * @param function The name of the function where the debug message is.
 * @param line The line number where the debug message is.
 */
void CWIRE_debug_message_value(int value, const char * file, const char * function, int line){
    FILE* logs = fopen(FILE_LOGS, "a");
    fprintf(logs,"\nfile : %s func : %s line :%d value: %d",file, function, line, value);
    fclose(logs);
}
/**
 * @brief Resets the log file.
 */
void log_reset(){
    FILE* logs = fopen(FILE_LOGS, "w");
    fclose(logs);
}