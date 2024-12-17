/**
 * @file CWIRE_math.c
 * @author Ahmed A., Rémi S., Abdelwaheb A.
 * @brief Useful Maths functions 
 * @version 1.0
 * 
 * @copyright Copyright (c) 2024
 * 
 */
#include "CWIRE_math.h"

/**
 * @brief Calculates the modulus of two integers, ensuring a positive result.
 * @param a The dividend.
 * @param b The divisor.
 * @return The positive remainder of `a` divided by `b`.
 */
int mod(int a, int b){
    int r = a % b;
    return r < 0 ? r + b : r;
}

/**
 * @brief Returns the maximum of two integers.
 *
 * @param a The first integer.
 * @param b The second integer.
 * @return The max of the two integers.
 */
int max(int a, int b){
    return a < b ? b : a;
}

/**
 * @brief Returns the minimum of two integers.
 *
 * @param a The first integer.
 * @param b The second integer.
 * @return The min of the two integers.
 */
int min(int a, int b){
    return a > b ? b : a;
}

/**
 * @brief Returns the maximum of 3 integers.
 *
 * @param a The first integer.
 * @param b The second integer.
 * @param c The third integer.
 * @return The max of the 3 integers.
 */
int max3(int a, int b, int c){
    return max(a, max(b, c));
}

/**
 * @brief Returns the minimum of 3 integers.
 *
 * @param a The first integer.
 * @param b The second integer.
 * @param c The third integer.
 * @return The min of the 3 integers.
 */
int min3(int a, int b, int c){
    return min(a, min(b, c));
}

/**
 * @brief Generates a random integer in the range [a, b[.
 *
 * @param a The minimum value (inclusive).
 * @param b The maximum value (exclusive).
 * @return A random integer in the range [a, b[
 * @throw VALUE_ERROR if `a` is greater than `b`.
 */
int randint(int a, int b){
    if (a > b)
    {
        CWIRE_error(VALUE_ERROR);
    }
    if (a == b)
    {
        return a;
    }
    return a + rand()%(b-a);
}


/**
 * @brief Checks if a value is within a specified range [a, b].
 *
 * @param x The value to check.
 * @param a The minimum value.
 * @param b The maximum value.
 * @return true if `x` is within the range [a, b].
 * @return false if not.
 */
int is_in(int x, int a, int b){
    return x <= max(a,b) && x >= min(a,b);
    
}

/**
 * @brief stick a value within a specified range (order of a and b dont count).
 *
 * This function ensures that `x` is within the range [a, b] and stick it ito the range
 *
 * @param x The value to stick.
 * @param a The minimum value.
 * @param b The maximum value.
 * @return The sticked value.
 */
int stick_in_range(int x,int a,int b){
    if (x < a)
    {
        return a;
    }
    if (x > b)
    {
        return b;
    }
    return x;
    
}