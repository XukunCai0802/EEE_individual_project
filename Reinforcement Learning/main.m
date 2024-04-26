  clc,clear all

%% Load data
Data = load('data.mat');
dict = Data.dict;

%% parametr of the game
M = 3;  % number of rows
N = 3;  % number of cloumns
Num = M*N;
ACTIONS = ['u','d','l','r'];  % u，d，l，r
State_num = factorial(Num)/2;
Q = zeros(State_num,length(ACTIONS));  % Qtable
done = false;


%% initalisation
%[stata] = Reset(M,Num);
%% Q-learning
EPSILON = 0.05;  % ε
gamma = 0.9;  % reward level
ALPHA = 0.2;  % learning rate
MAX_ITER = 10000;  % Maximum interation
mode = 2;
for iter = 1:MAX_ITER
    disp(['training times：',num2str(iter)]);
    [s,bk,done] = Reset(M,Num,mode);  % Initialise the state
    while  ~done
        % Greedy strategy, Choose action
        % If the random number is greater than ε, select the optimal action in the current Q table; otherwise, select the action randomly
        %action=policy(s,EPSILON,Q,ACTIONS,dict);
        if rand > EPSILON
            s_ind = all(dict(:,1:Num) == s,2);
            [~,a] = max(Q(s_ind,:));
        else
            a = randi(length(ACTIONS));
        end
        action = ACTIONS(a);

        %Take action, gain new state  and reward
        [s_new, bk_new, reward, done] =take_action(s, bk, a, M, Num, dict, done);

        %update Qtable
        s_ind = find(all(dict(:,1:Num) == s,2));
        s_new_ind = find(all(dict(:,1:Num) == s_new,2));
        target = reward+gamma*max(Q(s_new_ind,:))*(1-done);
        Q(s_ind,a) = Q(s_ind,a) + ALPHA * (target - Q(s_ind,a));
        
        s = s_new;
        bk = bk_new;
    end
end

% Execute optimal strategy
[s,bk,done] = Reset(M,Num,mode);  % Initialisation
goal = [1:Num-1,0];
step = 0;
test_step = 300;
while step<test_step
    step = step+1;
    s_ind = find(all(dict(:,1:Num) == s,2));
    [~,a] = max(Q(s_ind,:));
    action = ACTIONS(a);
    disp(['current state：', num2str(s), '，take action：', action]);
    [s_new, bk_new, reward, done] = take_action(s, bk, a, M, Num, dict, done);
    s = s_new;
    bk = bk_new;
    if isequal(s,goal)
        disp(['current state：', num2str(s)]);
        disp(['Completed successfully！,a total of ',num2str(step),' steps were performed']);
        break;
    end
end