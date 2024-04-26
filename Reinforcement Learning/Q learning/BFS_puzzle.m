function [dict] = BFS_puzzle(start, goal)
% start: 3x3 matrix representing the starting state of the puzzle
% goal: 3x3 matrix representing the goal state of the puzzle
% visited: array with 1 at positions representing visited states
% prev: array with previous state for each visited state

% Initialize variables
queue = start;
M = size(queue,1);%number of rows
N = size(queue,2);%number of cloumns
n = M*N;
%Calculate the total number of squares on the puzzle board

queue = reshape(queue',1,n);%rerange

dict = [];
que_qi = []; % store the puzzle
que_bk = []; % store the blank
que_lv = []; % store the level
deep = 33;  % Traverse depth

X = [-1,-M,1,M];  % movement direction

%% start search

que_qi = [que_qi; queue];
que_bk = [que_bk;n];
que_lv = [que_lv;0];
dict(1,1:n) = queue;
dict(1,n+1) = 0;

lv = 0;

while lv < deep && ~isempty(que_qi)
    qi = que_qi(1,:);
    que_qi(1,:) = [];%Get the current state from the queue
    bk = que_bk(1);
    que_bk(1) = [];%Get the current blank location from the queue
    lv = que_lv(1,1);
    que_lv(1) = [];%Get the current levels from the queue
    
    direction = randperm(4);%Generate a random movement direction, shuffle the order
    for i = 1:4 %Traverse the four possible directions of movement
        aciton = direction(i);%Get current direction
        x = bk+X(aciton);%Calculate the moved position
        [dict, que_qi, que_bk, que_lv] = move(qi,bk,x,lv,dict,que_qi,que_bk,que_lv,M,n);
    end
end



end