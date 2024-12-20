/**
 * @file Station.h
 * @author Ahmed A., Rémi S., Abdelwaheb A.
 * @brief Station handling header
 * @version 1.0
 * 
 * @copyright Copyright (c) 2024
 * 
 */

#ifndef Station_H
#define Station_H
//Necessary includes for definitions and utilities 
#include "CWIRE_def.h" // Custom definitions for lint and related types
#include "CWIRE_error.h" // Error handling utilities 
#include "CWIRE_debug.h" // Debugging tools

/**
 * @struct station_struct
 * @brief Represents an electricity station.
 * This structure stores the essential data for an electricity station, including : 
 * -"id" : A unique identifier for the station.
 * -"capacity" : The maximum capacity of the station (in kWh).
 * -"load" : The current load on the station (in kWh).
 */

typedef struct station_struct
{
    lint id;
    lint capacity;
    lint load;
}Station;

/**
 * @brief Creates a new Station instance. 
 * @param id The unique identifier of the station.
 * @param capacity The maximum capacity of the station.
 * @param load The current load on the station.
 * @return The newly created Station.
 */
Station CreateStation(lint id, lint capacity, lint load);

#endif


