/**
 * @file Station.c
 * @author Ahmed A., Rémi S., Abdelwaheb A.
 * @brief Station handling functions
 * @version 1.0
 * 
 * @copyright Copyright (c) 2024
 * 
 */


#include "Station.h"

/**
 * @brief Creates a new Station.
 * @param id The Station identifier.
 * @param capacity 
 * @param load 
 * @return the Station.
 */
Station CreateStation(lint id, lint capacity, lint load)
{
    Station new;
    new.id = id;
    new.capacity = capacity;
    new.load = load;
    return new;
}