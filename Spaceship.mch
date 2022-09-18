/* Spaceship
 * Author: Sandaru Kalapuge
 * Creation date: 11/17/2021
 */
MACHINE
    Spaceship
   
/* Provide read access to Spaceship machine */ 
SEES
    Space
    
/* Sets */
SETS
    MOVEMENT_TYPES = { NORMAL_MOVE, WRAP_DRIVE_MOVE };
    ANSWERS  = { Yes, No }

DEFINITIONS
    /* Responsible for check whether the spaceship has enough power to reduce */
    hasEnoughPowerToReduce(power, powerToBeReduced) == (power >= powerToBeReduced)
    
/* Constants */
CONSTANTS
    NormalMovePowerUsage,
    WrapDrivePowerUsage,
    AsteroidCrashPowerUsage
    
/* Constants declaration and initialization */
PROPERTIES
    NormalMovePowerUsage : NAT1 &
    NormalMovePowerUsage = 5 &
    
    WrapDrivePowerUsage : NAT1 &
    WrapDrivePowerUsage = 20 &
    
    AsteroidCrashPowerUsage : NAT1 &
    AsteroidCrashPowerUsage = 10 
    
/* Variable definition */
VARIABLES
    xPoint,
    yPoint,
    asteroidCollisionsCount,
    spaceshipPower,
    spaceshipLocation,
    spaceshipPath
    
/* Variable declaration */
INVARIANT
    xPoint : SpaceXaxisRange &
    yPoint : SpaceYaxisRange &
    asteroidCollisionsCount : NAT &
    spaceshipPower: NAT &
    spaceshipLocation : SpaceGrid &
    spaceshipPath : seq(SpaceGrid)
    
/* Variable initialization */
INITIALISATION
    xPoint := 1 ||
    yPoint := 1 ||
    asteroidCollisionsCount := 0 ||
    spaceshipPower := 0 ||
    spaceshipLocation := (1 |-> 1) ||
    spaceshipPath := [(1 |-> 1)]
    
/* Operations */
OPERATIONS
    
    /* Responsible for move the spaceship */
    move(xPosition, yPosition, type) =
        PRE xPosition: NAT1 & yPosition: NAT1 & type <: MOVEMENT_TYPES
        THEN
            xPoint, yPoint := xPosition, yPosition ||
            spaceshipLocation := xPosition |-> yPosition ||
            spaceshipPath := spaceshipPath <- (xPosition |-> yPosition) ||
            
            /* Check whether it's normal move */
            IF (NORMAL_MOVE : type)
            THEN
                spaceshipPower := spaceshipPower - NormalMovePowerUsage
            /* When it's wrap drive move */            
            ELSE
                spaceshipPower := spaceshipPower - WrapDrivePowerUsage
            END
    END;
    
    /* Responsible for handle asteroid collision */
    handleAsteroidCollision(movementType) =
        PRE movementType <: MOVEMENT_TYPES
        THEN
            asteroidCollisionsCount := succ(asteroidCollisionsCount) ||
            
            /* Check whether it's normal move */
            IF (NORMAL_MOVE : movementType)
            THEN
                IF (hasEnoughPowerToReduce(spaceshipPower, (AsteroidCrashPowerUsage + NormalMovePowerUsage)))
                THEN
                    spaceshipPower := spaceshipPower - AsteroidCrashPowerUsage - NormalMovePowerUsage
                ELSE
                    spaceshipPower := 0
                END                
            /* When it's wrap drive move */            
            ELSE
                IF (hasEnoughPowerToReduce(spaceshipPower, (AsteroidCrashPowerUsage + WrapDrivePowerUsage)))
                THEN
                    spaceshipPower := spaceshipPower - AsteroidCrashPowerUsage - WrapDrivePowerUsage
                ELSE
                    spaceshipPower := 0   
                END                
            END
    END;
    
    /* Responsible for reset the spaceship */
    reset(power) = 
        PRE power : NAT1
        THEN   
            spaceshipPower := power ||
            xPoint, yPoint := 1, 1 ||
            spaceshipLocation := (1 |-> 1) ||
            spaceshipPath := [(1|->1)] ||
            asteroidCollisionsCount := 0       
    END; 
    
    /* Responsible for provide visited regions */
    regions <-- RegionsVisited = 
        BEGIN
            regions := ran(spaceshipPath)
    END;
    
    /* Responsible for provide the status of the spaceship */
    count, power, location <-- MissionStatus =
        BEGIN
            count := asteroidCollisionsCount ||
            power := spaceshipPower ||
            location := spaceshipLocation
    END;
    
    /* Responsible for check whether the spaceship is docked at star base */ 
    notification <-- DockedAtStarbase = 
        PRE 
            notification : ANSWERS
        THEN
            /* Check whether the spaceship is located at the star base */
            IF spaceshipLocation : StarBase
            THEN
                notification := Yes
            /* When the spaceship is not located at the star base */            
            ELSE
                notification := No
            END
    END
END

