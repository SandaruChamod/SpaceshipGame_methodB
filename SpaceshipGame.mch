/* SpaceshipGame
 * Author: Sandaru Kalapuge
 * Creation date: 11/17/2021
 */
MACHINE
    SpaceshipGame

/* Includes Space and Spaceship machines to the Game */
INCLUDES
    Space, Spaceship

/* Promote Spaceship machine's mentioned operations */
PROMOTES
    RegionsVisited, MissionStatus, DockedAtStarbase

/* Sets */
SETS
    GAME_STATUSES = { WON, LOST, NOT_OVER };
    NOTIFICATIONS = { 
        MOVED_UP,
        Game_WON,
        Game_LOST,
        MOVED_DOWN,
        MOVED_FORWARD,
        Game_Not_Over,
        MOVED_BACKWARD,
        MOVED_SUCCESFULLY,
        NO_ENOUGH_POWER_TO_MOVE,
        THE_GAME_HAS_BEEN_STARTED,
        INVAILD_MOVE_PLEASE_TRY_AGAIN,
        SPACE_SHIP_IS_OCCUPIED_BY_AN_ASTEROID,
        GAME_OVER_SPACE_SHIP_RAN_OUT_OUT_POWER,
        CONGRATULATIONS_YOU_HAVE_ARRIVED_TO_THE_STAR_BASE
    }
    
/* Definitions */
DEFINITIONS
    /* GUI Animations */
    
    /* Responsible for visualize regions of the space */
    ANIMATION_FUNCTION == ({ row, col, index | col : SpaceXaxisRange & row : SpaceYaxisRange & index = 1 });
    /* Responsible for visualize asteroids */
    ANIMATION_FUNCTION1 == ({ row, col, index | col : SpaceXaxisRange & row : SpaceYaxisRange  & index = 0 & (col , 8 - row) : Asteroids });
    /* Responsible for visualize spaceship */
    ANIMATION_FUNCTION2 == ({ row, col, index | col : SpaceXaxisRange & row : SpaceYaxisRange & index = 3 & col = xPoint & row = (8 - yPoint) });
    /* Responsible for visualize star base */
    ANIMATION_FUNCTION3 == ({ row, col, index | col : SpaceYaxisRange & row : SpaceYaxisRange  & index = 2 & (col , row) : StarBase });
    /* Responsible for visualize docked at star base*/
    ANIMATION_FUNCTION4 == ({ row, col, index | col : SpaceXaxisRange & row : SpaceYaxisRange  & index = 4 & {spaceshipLocation} = StarBase & (col, row) : StarBase });
   
    
    /* Responsible for check whether the given location is within the regions of the space */
    isWithinRegionsOfSpace(xValue, yValue) == (( xValue |-> yValue ) : SpaceGrid );
    
    /* Responsible for check whether the given location is occupied by an asteroid */
    isOccupiedByAnAsteroid(xValue, yValue) == (( xValue |-> yValue ) : Asteroids );
    
    /* Responsible for check whether the spaceship has enough power to continue moving */
    hasEnoughPowerToMove(remainingPower, powerToBeReduced) == (remainingPower >= powerToBeReduced);
    
    /* Images for GUI */
    ANIMATION_IMG0 == "/images/asteroid.png";
    ANIMATION_IMG1 == "/images/region.png";
    ANIMATION_IMG2 == "/images/starbase.png";
    ANIMATION_IMG3 == "/images/spaceship.png";
    ANIMATION_IMG4 == "/images/starbaseDocked.png";
    
/* Definition of variables */
VARIABLES
    gameStatus
    
/* Declaration of variables */
INVARIANT
    gameStatus <: GAME_STATUSES
    
/* Initialization of the variables */
INITIALISATION
    gameStatus := { NOT_OVER }
    
/* Operations */    
OPERATIONS
    
    /* Responsible for move the spaceship up */
    notification <-- MoveUp =
        PRE
            notification : NOTIFICATIONS & NOT_OVER : gameStatus     
        THEN
            /* Check whether the spaceship has enough power to make a normal move */
            IF (hasEnoughPowerToMove(spaceshipPower, NormalMovePowerUsage))
            THEN
                /* Check whether the movement is within the region of the space */  
                IF (isWithinRegionsOfSpace(xPoint, succ(yPoint)))
                THEN
                    /* Check whether the spaceship is not occupied by an asteroid */
                    IF (not(isOccupiedByAnAsteroid(xPoint, succ(yPoint))))
                    THEN
                        /* Check whether the spaceship reaches to the star base */
                        IF ((xPoint |-> succ(yPoint)) : StarBase)
                        THEN
                            move(xPoint, succ(yPoint), { NORMAL_MOVE }) ||
                            notification := CONGRATULATIONS_YOU_HAVE_ARRIVED_TO_THE_STAR_BASE ||
                            gameStatus := { WON }
                        /* When the spaceship not reaches to the star base */                        
                        ELSE
                            /* Check whether the spaceship has enough power to continue moving */ 
                            IF (hasEnoughPowerToMove((spaceshipPower - NormalMovePowerUsage), NormalMovePowerUsage))
                            THEN
                                move(xPoint, succ(yPoint), { NORMAL_MOVE }) ||
                                notification := MOVED_UP||
                                gameStatus := { NOT_OVER }
                            /* When the spaceship has no enough power to continue moving */
                            ELSE
                                move(xPoint, succ(yPoint), { NORMAL_MOVE }) ||
                                notification := GAME_OVER_SPACE_SHIP_RAN_OUT_OUT_POWER ||
                                gameStatus := { LOST }
                            END                            
                        END 
                    /* When the spaceship is occupied by an asteroid */
                    ELSE
                        /* Check whether the spaceship has enough power to continue moving */
                        IF (hasEnoughPowerToMove((spaceshipPower - NormalMovePowerUsage - AsteroidCrashPowerUsage), NormalMovePowerUsage))
                        THEN
                            handleAsteroidCollision({ NORMAL_MOVE }) ||
                            notification := SPACE_SHIP_IS_OCCUPIED_BY_AN_ASTEROID ||
                            gameStatus := { NOT_OVER }
                        /* When the spaceship has no enough power to continue moving */
                        ELSE
                            handleAsteroidCollision({ NORMAL_MOVE }) ||
                            notification := SPACE_SHIP_IS_OCCUPIED_BY_AN_ASTEROID ||
                            gameStatus := { LOST }
                        END
                    END
                /* When the given location is out of the regions of the space */  
                ELSE
                    notification := INVAILD_MOVE_PLEASE_TRY_AGAIN
                END                
            ELSE
                /* When the spaceship has no enough power to move */  
                notification :=  NO_ENOUGH_POWER_TO_MOVE ||
                gameStatus := { LOST }
            END            
    END;  
    
    /* Responsible for move the spaceship down */
    notification <-- MoveDown =
        PRE
            notification : NOTIFICATIONS & NOT_OVER : gameStatus     
        THEN
            /* Check if the spaceship has enough power to make a normal move */
            IF (hasEnoughPowerToMove(spaceshipPower, NormalMovePowerUsage))
            THEN
                /* Check whether the movement is within the region of the space */
                IF (isWithinRegionsOfSpace(xPoint, pred(yPoint)))
                THEN
                    /* Check whether the spaceship is not occupied by an asteroid */
                    IF (not(isOccupiedByAnAsteroid(xPoint, pred(yPoint))))
                    THEN
                        /* Check whether the spaceship reaches to the star base */
                        IF ((xPoint |-> pred(yPoint)) : StarBase)
                        THEN
                            move(xPoint, pred(yPoint), { NORMAL_MOVE }) ||
                            notification := CONGRATULATIONS_YOU_HAVE_ARRIVED_TO_THE_STAR_BASE ||
                            gameStatus := { WON }
                        /* When the spaceship not reaches to the star base */                        
                        ELSE
                            /* Check whether the spaceship has enough power to continue moving */
                            IF (hasEnoughPowerToMove((spaceshipPower - NormalMovePowerUsage), NormalMovePowerUsage))
                            THEN
                                move(xPoint, pred(yPoint), { NORMAL_MOVE }) ||
                                notification := MOVED_DOWN||
                                gameStatus := { NOT_OVER }
                            /* When the spaceship has no enough power to continue moving */
                            ELSE
                                move(xPoint, pred(yPoint), { NORMAL_MOVE }) ||
                                notification := GAME_OVER_SPACE_SHIP_RAN_OUT_OUT_POWER ||
                                gameStatus := { LOST }
                            END                            
                        END      
                    ELSE
                        /* Check whether the spaceship has enough power to continue moving */
                        IF (hasEnoughPowerToMove((spaceshipPower - NormalMovePowerUsage - AsteroidCrashPowerUsage), NormalMovePowerUsage))
                        THEN
                            handleAsteroidCollision({ NORMAL_MOVE }) ||
                            notification := SPACE_SHIP_IS_OCCUPIED_BY_AN_ASTEROID ||
                            gameStatus := { NOT_OVER }
                        /* When the spaceship has no enough power to continue moving */
                        ELSE
                            handleAsteroidCollision({ NORMAL_MOVE }) ||
                            notification := SPACE_SHIP_IS_OCCUPIED_BY_AN_ASTEROID ||
                            gameStatus := { LOST }
                        END
                    END    
                ELSE
                    /* When the given location is out of the regions of the space */
                    notification := INVAILD_MOVE_PLEASE_TRY_AGAIN
                END                
            ELSE
                /* When the spaceship has no enough power to move */  
                notification :=  NO_ENOUGH_POWER_TO_MOVE ||
                gameStatus := { LOST }
            END            
    END; 
    
    /* Responsible for move the spaceship foreword */
    notification <-- MoveForward =
        PRE
            notification : NOTIFICATIONS & NOT_OVER : gameStatus     
        THEN
            /* Check if the spaceship has enough power to make a normal move */
            IF (hasEnoughPowerToMove(spaceshipPower, NormalMovePowerUsage))
            THEN
                /* Check whether the movement is within the region of the space */
                IF (isWithinRegionsOfSpace(succ(xPoint), yPoint))
                THEN
                    /* Check whether the spaceship is not occupied by an asteroid */
                    IF (not(isOccupiedByAnAsteroid(succ(xPoint), yPoint)))
                    THEN
                        /* Check whether the spaceship reaches to the star base */
                        IF ((succ(xPoint) |-> yPoint) : StarBase)
                        THEN
                            move(succ(xPoint), yPoint, { NORMAL_MOVE }) ||
                            notification := CONGRATULATIONS_YOU_HAVE_ARRIVED_TO_THE_STAR_BASE ||
                            gameStatus := { WON }
                        /* When the spaceship not reaches to the star base */
                        ELSE
                            /* Check whether the spaceship has enough power to continue moving */
                            IF (hasEnoughPowerToMove((spaceshipPower - NormalMovePowerUsage), NormalMovePowerUsage))
                            THEN
                                move(succ(xPoint), yPoint, { NORMAL_MOVE }) ||
                                notification := MOVED_FORWARD||
                                gameStatus := { NOT_OVER }
                            /* When the spaceship has no enough power to continue moving */
                            ELSE
                                move(succ(xPoint), yPoint, { NORMAL_MOVE }) ||
                                notification := GAME_OVER_SPACE_SHIP_RAN_OUT_OUT_POWER ||
                                gameStatus := { LOST }
                            END                            
                        END      
                    ELSE
                        /* Check whether the spaceship has enough power to continue moving */
                        IF (hasEnoughPowerToMove((spaceshipPower - NormalMovePowerUsage - AsteroidCrashPowerUsage), NormalMovePowerUsage))
                        THEN
                            handleAsteroidCollision({ NORMAL_MOVE }) ||
                            notification := SPACE_SHIP_IS_OCCUPIED_BY_AN_ASTEROID ||
                            gameStatus := { NOT_OVER }
                        /* When the spaceship has no enough power to continue moving */
                        ELSE
                            handleAsteroidCollision({ NORMAL_MOVE }) ||
                            notification := SPACE_SHIP_IS_OCCUPIED_BY_AN_ASTEROID ||
                            gameStatus := { LOST }
                        END
                    END    
                ELSE
                    /* When the given location is out of the regions of the space */
                    notification := INVAILD_MOVE_PLEASE_TRY_AGAIN
                END                
            ELSE
                /* When the space ship has no enough power to move */  
                notification :=  NO_ENOUGH_POWER_TO_MOVE ||
                gameStatus := { LOST }
            END            
    END;
    
    /* Responsible for move the spaceship backward */
    notification <-- MoveBackward =
        PRE
            notification : NOTIFICATIONS & NOT_OVER : gameStatus     
        THEN
            /* Check if the spaceship has enough power to make a normal move */
            IF (hasEnoughPowerToMove(spaceshipPower, NormalMovePowerUsage))
            THEN
                /* Check whether the movement is within the region of the space */
                IF (isWithinRegionsOfSpace(pred(xPoint), yPoint))
                THEN
                    /* Check whether the spaceship is not occupied by an asteroid */
                    IF (not(isOccupiedByAnAsteroid(pred(xPoint), yPoint)))
                    THEN
                        /* Check whether the spaceship reaches to the star base */
                        IF ((pred(xPoint) |-> yPoint) : StarBase)
                        THEN
                            move(pred(xPoint), yPoint, { NORMAL_MOVE }) ||
                            notification := CONGRATULATIONS_YOU_HAVE_ARRIVED_TO_THE_STAR_BASE ||
                            gameStatus := { WON }
                        /* When the spaceship not reaches to the star base */                        
                        ELSE
                            /* Check whether the spaceship has enough power to continue moving */
                            IF (hasEnoughPowerToMove((spaceshipPower - NormalMovePowerUsage), NormalMovePowerUsage))
                            THEN
                                move(pred(xPoint), yPoint, { NORMAL_MOVE }) ||
                                notification := MOVED_BACKWARD||
                                gameStatus := { NOT_OVER }
                            /* When the spaceship has no enough power to continue moving */
                            ELSE
                                move(pred(xPoint), yPoint, { NORMAL_MOVE }) ||
                                notification := GAME_OVER_SPACE_SHIP_RAN_OUT_OUT_POWER ||
                                gameStatus := { LOST }
                            END                            
                        END      
                    ELSE
                        /* Check whether the spaceship has enough power to continue moving */
                        IF (hasEnoughPowerToMove((spaceshipPower - NormalMovePowerUsage - AsteroidCrashPowerUsage), NormalMovePowerUsage))
                        THEN
                            handleAsteroidCollision({ NORMAL_MOVE }) ||
                            notification := SPACE_SHIP_IS_OCCUPIED_BY_AN_ASTEROID ||
                            gameStatus := { NOT_OVER }
                        /* When the spaceship has no enough power to continue moving */
                        ELSE
                            handleAsteroidCollision({ NORMAL_MOVE }) ||
                            notification := SPACE_SHIP_IS_OCCUPIED_BY_AN_ASTEROID ||
                            gameStatus := { LOST }
                        END
                    END    
                ELSE
                    /* When the given location is out of the regions of the space */
                    notification := INVAILD_MOVE_PLEASE_TRY_AGAIN
                END                
            ELSE
                /* When the spaceship has no enough power to move */  
                notification :=  NO_ENOUGH_POWER_TO_MOVE ||
                gameStatus := { LOST }
            END            
    END;
    
    /* Responsible for perform a wrap drive */
    notification <-- EngageWarpDrive(xPosition, yPosition) =
        PRE
            notification : NOTIFICATIONS & xPosition: SpaceXaxisRange & yPosition: SpaceYaxisRange & NOT_OVER : gameStatus
        THEN
            /* Check if the spaceship has enough power to make a wrap drive move */
            IF (hasEnoughPowerToMove(spaceshipPower, WrapDrivePowerUsage))
            THEN
                /* Check whether the movement is within the region of the space */
                IF (isWithinRegionsOfSpace(xPosition, yPosition))
                THEN
                    /* Check whether the spaceship is not occupied by an asteroid */
                    IF (not(isOccupiedByAnAsteroid(xPosition, yPosition)))
                    THEN
                        /* Check whether the spaceship reaches to the star base */
                        IF ((xPosition |-> yPosition) : StarBase)
                        THEN
                            move(xPosition, yPosition, { WRAP_DRIVE_MOVE }) ||
                            notification := CONGRATULATIONS_YOU_HAVE_ARRIVED_TO_THE_STAR_BASE ||
                            gameStatus := { WON }
                        /* When the spaceship not reaches to the star base */
                        ELSE
                            /* Check whether the spaceship has enough power to continue moving */
                            IF (hasEnoughPowerToMove((spaceshipPower - WrapDrivePowerUsage), NormalMovePowerUsage))
                            THEN
                                move(xPosition, yPosition, { WRAP_DRIVE_MOVE }) ||
                                notification := MOVED_SUCCESFULLY ||
                                gameStatus := { NOT_OVER }
                            /* When the spaceship has no enough power to continue moving */
                            ELSE
                                move(xPosition, yPosition, { WRAP_DRIVE_MOVE }) ||
                                notification := GAME_OVER_SPACE_SHIP_RAN_OUT_OUT_POWER ||
                                gameStatus := { LOST }
                            END                            
                        END      
                    ELSE
                        /* Check whether the spaceship has enough power to continue moving */
                        IF (hasEnoughPowerToMove((spaceshipPower - WrapDrivePowerUsage - AsteroidCrashPowerUsage), NormalMovePowerUsage))
                        THEN
                            handleAsteroidCollision({ WRAP_DRIVE_MOVE }) ||
                            notification := SPACE_SHIP_IS_OCCUPIED_BY_AN_ASTEROID ||
                            gameStatus := { NOT_OVER }
                        /* When the spaceship has no enough power to continue moving */
                        ELSE
                            handleAsteroidCollision({ WRAP_DRIVE_MOVE }) ||
                            notification := SPACE_SHIP_IS_OCCUPIED_BY_AN_ASTEROID ||
                            gameStatus := { LOST }
                        END
                    END    
                ELSE
                    /* When the given location is out of the regions of the space */
                    notification := INVAILD_MOVE_PLEASE_TRY_AGAIN
                END                
            ELSE
                /* When the spaceship has no enough power to move */
                notification :=  NO_ENOUGH_POWER_TO_MOVE ||
                gameStatus := { LOST }
            END            
    END;
    
    /* Responsible for start a new game */
    notification <-- NewGame(power) =
        PRE power : NAT1
        THEN
            reset(power) ||
            notification := THE_GAME_HAS_BEEN_STARTED ||
            gameStatus := { NOT_OVER }
    END;      
    
    /* Responsible for provide the status of the game */
    notification <-- GameStatus =
        PRE 
            notification : NOTIFICATIONS
        THEN
            /* Check whether the game is in "Won" status */
            IF (WON : gameStatus)
            THEN
                notification := Game_WON
            /* Check whether the game is in "Lost" status */            
            ELSIF (LOST : gameStatus)
            THEN
                notification := Game_LOST
            /* When the game is in "Not Over" status */            
            ELSE
                notification := Game_Not_Over
            END                 
    END        
END
