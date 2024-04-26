clc, clear all


% Define starting and goal states for the puzzle
% start = [2 5 3; 1 4 8; 7 0 6];
start = [1 2 3; 4 5 6; 7 8 0];
goal = [1 2 3; 4 5 6; 7 8 0];

% Run BFS to find all possible states of the puzzle
dict = BFS_puzzle(start, goal);

save("data.ma" + ...
    "t","dict");