% DQNLearner.m : A class that learn Deep Q Networks class
%
% INPUTS :
%          Policy network
%          Target network
%
% OUTPUTS :
%          None
%
% EXAMPLE : 
%          None
%
%   
%   

classdef DQNLearner < handle
   properties (Access = 'private')
       policyNet;
       targetNet;
       replayMemory;
       env;
       
       epsilon;
       epsilonDecay;
       gamma;
       totalReward;
       bonus;
       maxIttr;
       updateCount;
       State_num;
       Num;
       dict;
       ALPHA;
       
       Q;
       Qtable; % Q table
       
       epochAvgReward = [];
       epochLength = [];
       testTotalReward = [];
   end
   
   methods (Access = 'public')
       function obj = DQNLearner()
           % replay memory
           obj.replayMemory = ReplayMemory(HParams.bufferSize);
           
           % Hyper params
           obj.epsilon = HParams.epsilon;
           obj.epsilonDecay = HParams.epsilonDecay;
           obj.gamma = HParams.gamma;
           obj.maxIttr = HParams.maxIttr;
           obj.updateCount = 0;
           obj.Num = 9;
           obj.State_num = factorial(obj.Num)/2;
           obj.Qtable = zeros(obj.State_num,4); 
           data = load('data.mat');
           obj.dict = data.dict;
           obj.ALPHA = 0.2;  
           
           % Environment (cart-pole)
           obj.env = Environment([4	3 0	7 1 5 8	2 6], 3, false);
           [state, bk, action, reward, next_state, next_bk,done] = obj.env.doAction(1);
           obj.replayMemory.push([state, action, reward, next_state, done]);
           
           % build Q networks
           obj.policyNet = QNetwork(length(state), [4], obj.env.actionCardinality);
           obj.targetNet = QNetwork(length(state), [4], obj.env.actionCardinality);
           obj.targetNet.setParams(obj.policyNet.getParams());
       end
       
       function train(obj)
           for epochs = 1:HParams.maxEpoch
               % Reset the parameters
               disp(['Training times：',num2str(epochs)]);
               obj.totalReward = 0;
               obj.bonus = 0;
               obj.env.goal = false;
               
               % epsilon decay
               obj.epsilon = obj.epsilon * obj.epsilonDecay;
               if epochs>200
                   obj.epsilon = 0.005;
               end
               
               % initialize environment
               mode = 2;
               obj.env.randomInitState(mode);
               
               for itr_no = 1:obj.maxIttr
                   % step#1 in DQN Algorithm
                   Action = obj.selectAction();
                   % step#2 in DQN Algorithm
                   [state, bk, action, reward, next_state, next_bk ,done] = obj.env.doAction(Action);
                   % step#3 in DQN Algorithm
                   obj.replayMemory.push([state, action, reward, next_state, done]);
                   s_ind = find(all(obj.dict(:,1:obj.Num) == state,2));
                   s_new_ind = find(all(obj.dict(:,1:obj.Num) == next_state,2));
                   target = reward+obj.gamma*max(obj.Qtable(s_new_ind,:))*(1-done);
                   obj.Qtable(s_ind,action) = obj.Qtable(s_ind,action) + obj.ALPHA * (target - obj.Qtable(s_ind,action));
                   obj.env.state = next_state;
                   obj.env.bk = next_bk;
                   
                   % Aggregate the total reward for every epoch
                   obj.totalReward = obj.totalReward + reward;
                   
                   if obj.env.resetCode
                       break;
                   end
               end
               
               % Store the average reward and epoch length for plotting
               obj.epochAvgReward(epochs) = obj.totalReward / itr_no;
               obj.epochLength(epochs) = itr_no;
               
               if itr_no == obj.maxIttr
                   disp(['Episode', num2str(epochs), ':maxIttr Condition reached! - Average Reward:', num2str(obj.epochAvgReward(epochs))])
               elseif obj.env.goal == true
                   disp(['Episode', num2str(epochs), ', steps(', num2str(itr_no), '/',num2str(obj.maxIttr), ') ',  ': Successfully restored!! - Average Reward:', num2str(obj.epochAvgReward(epochs))]);
                   obj.env.resetCode = false;
               else
                   disp(['Episode', num2str(epochs), ':Reset Condition reached! - Average Reward:', num2str(obj.epochAvgReward(epochs))])
               end
               
               % step#4 in DQN Algorithm
               obj.trainOnMemory() % Batch training using replay memory
           end
           plot((1:HParams.maxEpoch)',obj.epochAvgReward,'LineWidth',1.0)
           xlabel('Episode')
           ylabel('Average Total Reward')
           title('DQN')

       end
       
       % DQN Test
       function DQNTest(obj, simLength)
           obj.env.simOnOff = 0;
           obj.testTotalReward = 0;
           obj.epsilon = -Inf;
%            obj.env.initSim();
           mode = 2;
           obj.env.randomInitState(mode);
           obj.env.goal = false;
           disp('Strat testing.......')
           for testIter = 1:simLength
               Action = obj.selectAction();
               disp(['current state：', num2str(obj.env.state), '，action：', obj.env.actions(Action)]);
               [~, ~, ~, reward, next_state, next_bk, done] = obj.env.doAction(Action);
               obj.env.state = next_state;
               obj.env.bk = next_bk;
               obj.testTotalReward = obj.testTotalReward + reward;
               if done
                   if isequal(obj.env.state,obj.env.target)
                       disp(['Successfully！,',num2str(testIter),'steps were taken']);
                   else
                       disp('Failed！！');
                   end
                   break;
               end
           end
       end
   end
   
   methods (Access = 'private')
       % generate Policy Q values
       function Qval = genQValue(obj, state)
           Qval = obj.policyNet.predict(state');
       end
       
       % generate Target Q values
       function Qval = genTargetQValue(obj, state)
           Qval = obj.targetNet.predict(state');
       end
       
       function selectedAction = selectAction(obj)
           % epsilon greedy
           if rand <= obj.epsilon
               actionIndex = randi(obj.env.actionCardinality, 1);
           else
               s_ind = find(all(obj.dict(:,1:obj.Num) == obj.env.state,2));
               [~,actionIndex] = max(obj.Qtable(s_ind,:));
%                obj.Q = obj.genQValue(obj.env.state);
%                [~, actionIndex] = max(obj.Q);
           end
               
           selectedAction = actionIndex;
       end
       
       % replay train
       function trainOnMemory(obj)
           samples = obj.replayMemory.sample(HParams.sampleSize);
           stateBatch = samples(:, 1:obj.env.Num);
           actionBatch = samples(:, obj.env.Num+1);
           rewardBatch = samples(:, obj.env.Num+2);
           nextstateBatch = samples(:, obj.env.Num+3:obj.env.Num+11);
           doneBatch = samples(:, obj.env.Num+12);
           valueBatch = zeros(length(obj.env.actions), 1);
           
%            for count = 1:size(samples, 1)
%                value = zeros(4, 1);
%                aIdx = find(~(1:4 - actionBatch(count)));
%                % calc reward
%                if doneBatch(count)
%                    value(aIdx) = rewardBatch(count);
%                else
%                    value(aIdx) = rewardBatch(count) + obj.gamma * max(obj.genTargetQValue(nextstateBatch(count, :))); 
%                end
%                valueBatch(:, count) = value;
%            end

           for count = 1:size(samples, 1)
               value = zeros(4, 1);
               sIdx = find(all(obj.dict(:,1:obj.Num) == stateBatch(count,:),2));
               value = (obj.Qtable(sIdx,:))';
               valueBatch(:, count) = value;
           end  
           
           % main network update
           obj.policyNet.trainNetwork(stateBatch', valueBatch);           
           
           % network copy every wanted episode number
           obj.updateCount = obj.updateCount + 1;
           if mod(obj.updateCount, HParams.targetUpdate) == 0
               disp('targetNet Update!') % update target network
%                obj.targetNet.setParams(obj.policyNet.getParams());
               obj.targetNet = obj.policyNet;
           end
       end
   end
end