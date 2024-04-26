clc;
clear all;

%% Load data
Data = load('data.mat');
dict = Data.dict;

%% parametr of the game
M = 3;  % number of rows
N = 3;  % number of cloumns
Num = M*N;
ACTIONS = ['u','d','l','r'];

%% Neural Network Architecture
inputSize = Num; % Input size for the neural network
hiddenLayerSize = [10 5]; % Hidden layer sizes
outputSize = length(ACTIONS); % Output size

% Define neural network architecture
net = feedforwardnet(hiddenLayerSize);
net = configure(net, inputSize);
net.layers{1}.transferFcn = 'relu';
net.layers{2}.transferFcn = 'relu';
net.layers{3}.transferFcn = 'softmax';
net.performFcn = 'crossentropy';

% Training parameters
net.trainParam.lr = 0.01;
net.trainParam.epochs = 100;
net.trainParam.miniBatchSize = 32;
net.trainParam.max_fail = 10;

% Initialize Q-table
Q = zeros(State_num, outputSize);

%% Q-learning
EPSILON = 0.05;
gamma = 0.9;
ALPHA = 0.2;
MAX_ITER = 1000;
mode = 2;

for iter = 1:MAX_ITER
    disp(['Training iteration: ', num2str(iter)]);
    
    % Initialize state
    [s, bk, done] = Reset(M, Num, mode);
    
    while ~done
        % Greedy strategy for action selection
        if rand > EPSILON
            s_ind = all(dict(:, 1:Num) == s, 2);
            [~, a] = max(Q(s_ind, :));
        else
            a = randi(length(ACTIONS));
        end
        action = ACTIONS(a);
        
        % Take action and observe new state and reward
        [s_new, bk_new, reward, done] = take_action(s, bk, a, M, Num, dict, done);
        
        % Update Q-table using neural network
        s_ind = find(all(dict(:, 1:Num) == s, 2));
        s_new_ind = find(all(dict(:, 1:Num) == s_new, 2));
        
        % Encode current state and new state
        X_train = s;
        X_new_train = s_new;
        
        % Convert actions to one-hot encoding
        y_train = zeros(1, outputSize);
        y_train(a) = 1;
        
        y_new = zeros(1, outputSize);
        [~, a_new] = max(Q(s_new_ind, :));
        y_new(a_new) = 1;
        
        % Train neural network
        [net, ~] = train(net, X_train', y_train');
        
        % Predict Q-values for current and new states
        Q(s_ind, :) = net(X_train');
        Q(s_new_ind, :) = net(X_new_train');
        
        % Update state and bookkeeping
        s = s_new;
        bk = bk_new;
    end
end

%% Execute optimal strategy
[s, bk, done] = Reset(M, Num, mode);
goal = [1:Num-1, 0];
step = 0;
test_step = 300;
while step < test_step
    step = step + 1;
    s_ind = find(all(dict(:, 1:Num) == s, 2));
    [~, a] = max(Q(s_ind, :));
    action = ACTIONS(a);
    disp(['Current state: ', num2str(s), ', take action: ', action]);
    [s_new, bk_new, reward, done] = take_action(s, bk, a, M, Num, dict, done);
    s = s_new;
    bk = bk_new;
    if isequal(s, goal)
        disp(['Current state: ', num2str(s)]);
        disp(['Completed successfully! Total steps: ', num2str(step)]);
        break;
    end
end