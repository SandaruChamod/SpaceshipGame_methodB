/* Space
 * Author: Sandaru Kalapuge
 * Creation date: 11/16/2021
 */
MACHINE
    Space
    
/* Constants */
CONSTANTS
    SpaceGrid,
    SpaceXaxisRange,
    SpaceYaxisRange,
    StarBase,
    HomeBase,
    Asteroids
    
/* Definition & Declaration of the constants */ 
PROPERTIES
    SpaceXaxisRange <: NAT1 &
    SpaceXaxisRange = 1..12 &
    
    SpaceYaxisRange <: NAT1 &
    SpaceYaxisRange = 1..7 &
    
    SpaceGrid : NAT1 <-> NAT1 &
    SpaceGrid = SpaceXaxisRange * SpaceYaxisRange &
    
    StarBase : NAT1 <-> NAT1  & 
    StarBase = {(6 |-> 4)} &
    
    Asteroids : NAT1 <-> NAT1  &
    Asteroids = {(3 |-> 2), (3 |-> 5), (5 |-> 4), (6 |-> 7), (7 |-> 1), (7 |-> 5), (7 |-> 7), (8 |-> 3),(10 |-> 6),(11 |-> 2), (12 |-> 5)} &
    
    HomeBase : NAT1 <-> NAT1  & 
    HomeBase = {(1 |-> 1)} 

END