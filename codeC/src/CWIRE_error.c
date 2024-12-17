/**
 * @file CWIRE_error.c
 * @author Ahmed A., Rémi S., Abdelwaheb A.
 * @brief Error handling
 * @version 1.0
 * 
 * @copyright Copyright (c) 2024
 * 
 */

#include "CWIRE_error.h"
#include "CWIRE_colors.h"

/**
 * @brief Displays an error message and exits the program.
 *
 * @param message The error message to display.
 * @param type The error type (enum Error) which is used as the exit code.
 */
void show_error(char * message, Error type){
    fprintf(stderr,"\n%s%s%s C error no : %s%d%s \n\n", CWIRE_COLOR_BRIGHT_MAGENTA, message, CWIRE_COLOR_RESET, CWIRE_COLOR_BRIGHT_RED, type, CWIRE_COLOR_RESET); 
    exit(type);
}

/**
 * @brief Displays an error message with file, function, and line information, then exits the program.
 *
 * @param message The error message to display.
 * @param type The error type (enum Error) which is used as the exit code.
 * @param file The name of the file where the error occurred.
 * @param function The name of the function where the error occurred.
 * @param line The line number where the error occurred.
 */
void show_error_line(char * message, Error type, const char * file, const char * function, int line){
    fprintf(stderr,"\n%s%s%s C error no : %s%d%s\n", CWIRE_COLOR_BRIGHT_MAGENTA, message, CWIRE_COLOR_RESET, CWIRE_COLOR_BRIGHT_RED, type, CWIRE_COLOR_RESET);
    fprintf(stderr,"Occurred in file : `%s%s%s`, in function : `%s%s%s`, in line : %s%d%s \n\n", CWIRE_COLOR_BRIGHT_RED, file, CWIRE_COLOR_RESET, CWIRE_COLOR_BRIGHT_RED, function, CWIRE_COLOR_RESET, CWIRE_COLOR_BRIGHT_RED, line, CWIRE_COLOR_RESET ); 

    exit(type);
}


/**
 * @brief Handles the various error types and displays the appropriate error messages.
 *
 * This function checks the error type and calls the appropriate error display function 
 * with a specific message, including the file, function, and line number if necessary.
 *
 * @param type The error type (enum Error) which determines the error message.
 * @param file The name of the file where the error occurred.
 * @param function The name of the function where the error occurred.
 * @param line The line number where the error occurred.
 */
void CWIRE_error_function(Error type, const char * file, const char * function, int line){
    switch (type)
    {
    case ALLOCATION_ERROR:
        show_error("Allocation failed, check the ram usage.", ALLOCATION_ERROR);
        break;
    case INCORRECT_ARGS_ERROR:
        show_error("Invalid Arguments. try : ./CWIRE_C <src_file>.csv  <dest_file>.csv ", INCORRECT_ARGS_ERROR);
        break;
    case INCORRECT_ARGC_ERROR:
        show_error("Invalid Number of Arguments. try : ./CWIRE_C <src_file>.csv  <dest_file>.csv ", INCORRECT_ARGC_ERROR);
        break;
    case NOT_CSV_ERROR:
        show_error("An File error occured on of the files is not a .csv file", NOT_CSV_ERROR);
        break;
    case CSV_ERROR:
        show_error("Invalid CSV Format", CSV_ERROR);
        break;
    case VALUE_ERROR:
        show_error_line("A Value error occured.", VALUE_ERROR, file, function, line);
        break;
    case FILE_ERROR:
        show_error_line("An File error occured.", FILE_ERROR, file, function, line);
        break;
    default:
        show_error_line("An UNDEFINED_ERROR error occured.", UNDEFINED_ERROR, file, function, line);
        break;
    }
}