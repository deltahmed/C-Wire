/**
 * @file CWIRE_math.h
 * @author Ahmed A., Rémi S., Abdelwaheb A.
 * @brief Maths handling header
 * @version 1.0
 * 
 * @copyright Copyright (c) 2024
 * 
 */

#ifndef CWIRE_MATH
#define CWIRE_MATH

#include "CWIRE_error.h"

int mod(int a, int b);
int max(int a, int b);
int min(int a, int b);
int max3(int a, int b, int c);
int min3(int a, int b, int c);
int randint(int a, int b);
int is_in(int x, int a, int b);
int stick_in_range(int x,int a,int b);

#endif



