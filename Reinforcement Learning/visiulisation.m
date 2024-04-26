clc, clear all

%% Load data
Data = load('data.mat');
dict = Data.dict;

%% Parameters of the game
M = 3;  % number of rows
N = 3;  % number of columns
Num = M * N;
ACTIONS = ['u', 'd', 'l', 'r'];  % u, d, l, r
State_num = factorial(Num) / 2;
Q = zeros(State_num, length(ACTIONS));  % Q-table
done = false;
total_reward = 0;
total_rewards = 0;

%% Initialization
%[state] = Reset(M,Num);
%% Deep Q-Network (DQN)
EPSILON = 0.05;  % ε
gamma = 0.9;  % discount factor
ALPHA = 0.5;  % learning rate
MAX_ITER = 10000;  % Maximum iteration
mode = 2;
for iter = 1:MAX_ITER
    disp(['Training iteration: ', num2str(iter)]);
    [s, bk, done] = Reset(M, Num, mode);  % Initialize the state
    while ~done
        % Epsilon-greedy strategy for action selection
        if rand > EPSILON
            s_ind = all(dict(:, 1:Num) == s, 2);
            [~, a] = max(Q(s_ind, :));
        else
            a = randi(length(ACTIONS));
        end
        action = ACTIONS(a);

        % Take action, obtain new state and reward
        [s_new, bk_new, reward, done] = take_action(s, bk, a, M, Num, dict, done);

        % Update Q-table using Bellman equation
        s_ind = find(all(dict(:, 1:Num) == s, 2));
        s_new_ind = find(all(dict(:, 1:Num) == s_new, 2));
        target = reward + gamma * max(Q(s_new_ind, :)) * (1 - done);
        Q(s_ind, a) = Q(s_ind, a) + ALPHA * (target - Q(s_ind, a));

        s = s_new;
        bk = bk_new;
   % Visualization
   total_reward = total_reward + Q(s_ind, a);
   total_rewards = total_rewards + reward;
    end
    reward_history(iter) = total_reward;
    rewards_history(iter) = total_rewards;
end

   figure;
   plot(reward_history);
   title('Q-learning Training Rewards');
   xlabel('Episode');
   ylabel('Total Reward');
   figure;
   plot(rewards_history);
   title('Q-learning Training Rewards');
   xlabel('Episode');
   ylabel('Total Reward');