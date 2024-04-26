%This function is to exchange the current blank position and the target position x in a given puzzle state. 
%During the exchange, the board state and blank positions are updated, and the updated state and position are returned.

function [Puzzle,blank,blank_p] = Trans(x,blank,blank_p,Puzzle)
%Trans puzzle state change function

Num = size(Puzzle,2);
%Get the number of columns of the Puzzle

if x < 1 || x >= Num || blank == x
%Check whether the input position x is out of bounds or the same as the current blank position, if so, return directly    
    return;
end

if abs(mod(x-1,M)-mod(blank-1,M))>1 % Exceeds the board range
    return;
end

Puzzle(blank) = Puzzle(x);
Puzzle(x) = 0;
blank_p = blank;
blank = x;




end