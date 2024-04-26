function [Puzzle,bk,done] = Reset(M,Num,mode)
%   mode:1;Initial state is randomly set
%   mode:2;Initial state fixed setting

if mode==1
    init = [1:Num-1,0];
    Puzzle = init;
    
    X = [-1,-M,1,M];  % direction of movement
    max_step = randi([400,800]);  
%   Randomly generate the number of moves
%   to control the initial number of movement steps
    step = 0;
    bk = Num;
    bk_p = -1;
    
    while step < max_step || Puzzle(end) ~= 0
        i = randi(4);
        x = bk+X(i);
        [Puzzle,bk,bk_p] = Trans(x,bk,bk_p,Puzzle);
%   Call the Trans function to realize the movement of blank
    end
else
    Puzzle = [3 6	7	2	0	1	4	8	5];
    bk = 5;
end


bk_p = -1;
step = 0;  % Prompt to count steps
done = 0;






end