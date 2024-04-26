function [Dict,Que_qi,Que_bk,Que_lv] = move(qi,blank,x,level,Dict,Que_qi,Que_bk,Que_lv,m,n)
%qi: a vector containing states
%blank: location of blank
%x:the position to move to
%level: the level or number of steps to move
%Dict: A matrix used to store the visited state
%Que_qi: A column vector used to store state vectors
%Que_bk: A column vector used to store blank positions
%Que_lv: A column vector used to store the level or step number
%m: represents the number of rows of the matrix.
%n: represents the number of columns of the matrix.

if x < 1 || x > n || blank == x
    return
end
%If x outside the legal range (less than 1 or greater than the number of columns n), or blank is equal to x, the move is illegal and returns directly.
if abs(mod(blank-1,m)-mod(x-1,m))>1
    return
end
%If blank and x are not on the same line, it means that the move is also illegal and returns directly
temp = qi;
tt = temp(x);
temp(x) = temp(blank);
temp(blank) = tt;
%Swap the elements of position x and blank in qi to simulate the effect of movement

if any(all(Dict(:,1:n)==temp,2))
    return
end
%If the exchanged state already exists in the Dict,and will be returned directly
Dict = [Dict;[temp,level+1]];
Que_qi = [Que_qi;temp];
Que_bk = [Que_bk;x];
Que_lv = [Que_lv;level+1];





end