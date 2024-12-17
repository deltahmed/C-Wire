/**
 * @file CWIRE_debug.h
 * @author Ahmed A., Rémi S., Abdelwaheb A.
 * @brief debug file header
 * @version 1.0
 * 
 * @copyright Copyright (c) 2024
 * 
 */

#ifndef CWIRE_DEBUG_H
#define CWIRE_DEBUG_H

#include <stdio.h> 
#include <stdlib.h>
#include "CWIRE_def.h"

/**
 * @brief this macro call CWIRE_debug_message with the needed arguments.
 */
#define log() (CWIRE_debug_message(__FILE__,  __FUNCTION__, __LINE__))

/**
 * @brief This macro calls CWIRE_debug_message_value with the necessary arguments to log an integer value along with the file name, function name, and line number.
 * 
 * @param value The value logged.
 */
#define intlog(value) (CWIRE_debug_message_value(value, __FILE__,  __FUNCTION__, __LINE__))

void CWIRE_debug_message(const char * file, const char * function, int line);
void CWIRE_debug_message_value(int value, const char * file, const char * function, int line);
void log_reset();


#endif