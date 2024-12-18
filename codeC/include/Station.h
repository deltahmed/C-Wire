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
#include "CWIRE_def.h"
#include "CWIRE_error.h"
#include "CWIRE_debug.h"

typedef struct station_struct
{
    lint id;
    lint capacity;
    lint load;
}Station;

Station CreateStation(lint id, lint capacity, lint load);

#endif



