/**
 * @file CWIRE_error.h
 * @author Ahmed A., Rémi S., Abdelwaheb A.
 * @brief Error handling header
 * @version 1.0
 * 
 * @copyright Copyright (c) 2024
 * 
 */

#ifndef CWIRE_ERROR
#define CWIRE_ERROR

#include <stdio.h> 
#include <stdlib.h>


/**
 * @brief This macro calls the CWIRE_error_function with the necessary arguments to show where the ARA error is.
 *
 * @param type The type of error to log, represented by the Error enum.
 */
#define CWIRE_error(type) (CWIRE_error_function(type, __FILE__,  __FUNCTION__, __LINE__))

/**
 * @brief Enumeration of all possible ARA error types.
 */
typedef enum __error_enum {
    UNDEFINED_ERROR = 1000,
    ALLOCATION_ERROR,
    VALUE_ERROR,
    FILE_ERROR,
    INCORRECT_ARGS,
    INCORRECT_ARGC,
    
}Error;

void show_error(char * message, Error type);
void show_error_line(char * message, Error type, const char * file, const char * function, int line);
void CWIRE_error_function(Error type, const char * file, const char * function, int line);



#endif


