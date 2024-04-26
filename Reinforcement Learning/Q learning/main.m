clc,clear all


Data = load('data.mat');
dict = Data.dict;


M = 3;  
N = 3;  
Num = M*N;
ACTIONS = ['u','d','l','r'];  
State_num = factorial(Num)/2;
Q = zeros(State_num,length(ACTIONS));  
done = false;

%% Initialisation
% [stata] = Reset(M,Num);

%% Q-learning
EPSILON = 0.2;  % ε
gamma = 0.9;
ALPHA = 0.2;  % learning rate
MAX_ITER = 1000;  % maximum interation
mode = 2;
epochAvgReward = zeros(MAX_ITER,1);
for iter = 1:MAX_ITER
    if iter>0.2*MAX_ITER
        EPSILON = 0.005;
    end

    disp(['Traning times：',num2str(iter)]);
    [s,bk,done] = Reset(M,Num,mode);  
    totalReward = 0;
    itr_no = 0;
    while  ~done
        itr_no = itr_no+1;
       %greedy policy
        if rand > EPSILON
            s_ind = find(all(dict(:,1:Num) == s,2));
            [~,a] = max(Q(s_ind,:));
        else
            a = randi(length(ACTIONS));
        end
        action = ACTIONS(a);
        
        
        [s_new, bk_new, reward, done] = take_action(s, bk, a, M, Num, dict, done);
        
        % update Q table
        s_ind = find(all(dict(:,1:Num) == s,2));
        s_new_ind = find(all(dict(:,1:Num) == s_new,2));
        target = reward+gamma*max(Q(s_new_ind,:))*(1-done);
        Q(s_ind,a) = Q(s_ind,a) + ALPHA * (target - Q(s_ind,a));
        totalReward = totalReward + reward;
        s = s_new;
        bk = bk_new;
    end
    epochAvgReward(iter) = totalReward/itr_no;
end

plot((1:MAX_ITER)',epochAvgReward,'LineWidth',1.0);
xlabel('Episode')
ylabel('Average Total Reward')


[s,bk,done] = Reset(M,Num,mode);  
goal = [1:Num-1,0];
step = 0;
test_step = 300;
while step<test_step
    step = step+1;
    s_ind = find(all(dict(:,1:Num) == s,2));
    [~,a] = max(Q(s_ind,:));
    action = ACTIONS(a);
    disp(['current state：', num2str(s), '，action：', action]);
    [s_new, bk_new, reward, done] = take_action(s, bk, a, M, Num, dict, done);
    s = s_new;
    bk = bk_new;
    if isequal(s,goal)
        disp(['Successfully！,',num2str(step),'steps were taken']);
        break;
    end
end


