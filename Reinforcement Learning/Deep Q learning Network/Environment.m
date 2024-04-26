% Environment.m : TicTacToe environment class
%
% INPUTS :
%         start points : state param [ x, x', theta, theta']
%         simChoice : cart-pole simultes on
%
% OUTPUTS :
%          QNetwork object
%
% EXAMPLE : 
%          repmem = QNetwork([10 20])
%
%   
%   

classdef Environment < handle
    
    properties (Access = 'public')
        
        state = [];
        bk = [];
        M = [];
        N = [];
        Num = [];
        dict = [];
        target = [];
%         timeStep = [];
%         massCart = [];
%         massPole = [];
%         poleLength = [];
%         gravity = [];
%         substeps = [];
        actionCardinality = [];
        actions = [];
%         pendLimitAngle = [];
%         cartLimitRange = [];
        reward = [];
        bonus = [];
        goal = [];
        resetCode = [];
        simOnOff;
        panel;
        cart;
        pole
        dot;
        arrow;
        totalMass;
        polemassLeng;
    end
    
    methods (Access = 'public')
        
        function obj = Environment(startpoint,startbk,simChoice)
            
            if nargin == 0                
                obj.state = [4	3	0	7	1	5	8	2	6];
                obj.bk = 3;
                obj.simOnOff = 0;                
            else
                obj.state = startpoint;
                obj.bk = startbk;
                obj.simOnOff = simChoice;                
            end
%             obj.timeStep = 0.02;
%             obj.massCart = 5;
%             obj.massPole = 0.5;
%             obj.totalMass = obj.massCart + obj.massPole;
%             obj.gravity = 9.81;
%             obj.poleLength = 1;
%             obj.polemassLeng = obj.massPole * obj.poleLength;
%             obj.substeps = 1;
            obj.M = HParams.M;
            obj.N = HParams.N;
            obj.Num = obj.M*obj.N;
            obj.reward = 0;
            obj.bonus = 0;
            obj.actions = ['u','d','l','r'];
            obj.actionCardinality = length(obj.actions);
            obj.target = [1:obj.Num-1,0];
            Data = load('data.mat');        
            obj.dict = Data.dict;
%             obj.pendLimitAngle = deg2rad(45);
%             obj.cartLimitRange = 10;
            
            if obj.simOnOff == 1
                obj.initSim()
            end
            
        end
        
        function [state,bk,Action,reward,next_state,next_bk,done] = doAction(obj,Action)
            
            state = obj.state;
            bk = obj.bk;
            [next_state,next_bk,reward,done] = obj.getNextState(Action);
            obj.resetCode = done;
            
            % debug print
%             if Action == 1
%                 direction = 'right';
%             else
%                 direction = 'left';
%             end
            direction = obj.actions(Action);
            disp(['direction : ', direction, ' state : ', num2str(state), ' bk : ', num2str(bk)]);
            
            % return value update : reward, done/ simulate cart-pole
%             obj.checkIfGoalReached();            
%             reward = obj.reward;            
%             done = obj.resetCode;
            
            if obj.simOnOff == 1
                obj.simCartpole(next_state);
            end
            
        end
        
        % initialization state variables
        function randomInitState(obj, mode)
            if mode==1
                init = [1:obj.Num-1,0];
                qipan = init;
                X = [-1,-obj.M,1,obj.M];  
                max_step = randi([400,800]);  
                step = 0;
                Bk = obj.Num;
                bk_p = -1;
                while step < max_step || qipan(end) ~= 0
                    i = randi(4);
                    x = Bk+X(i);
                    [qipan,Bk,bk_p] = Trans(x,Bk,bk_p,qipan);
                end
                obj.state = qipan;
                obj.bk = Bk;
            else
                obj.state = [4	3	0	7	1	5	8	2	6];
                obj.bk = 3;
            end

        end
        
        % update reward & terminal value
        function checkIfGoalReached(obj)
            
            obj.generateReward();
               
            if abs(obj.state(3)) < deg2rad(5)
               obj.bonus = 10;
               obj.goal = true;
               obj.resetCode = false;
            else
               obj.bonus = 1;
               obj.resetCode = false;
            end
            
            if abs(obj.state(3)) >  obj.pendLimitAngle                
               obj.bonus = 0;     %punishement for falling down
               obj.resetCode = true;
            end
               
            if abs(obj.state(1)) > obj.cartLimitRange                
               obj.bonus = 0;     %punishement for moving too far
               obj.resetCode = true;
            end
            
            obj.reward = obj.reward + obj.bonus;
            obj.goal = false;
            obj.bonus = 0;
        end
        
        function initSim(obj)            
            drawcartpend(obj.state, obj.massPole, obj.massCart, obj.poleLength);
        end
    end
    
    methods(Access = 'private')
        
        % update state values using kinematics equation
        function [next_state,next_bk,reward,done] = getNextState(obj, action)

            X = [-obj.M,obj.M,-1,1];  
            State = obj.state;
            Bk = obj.bk;
            x = Bk+X(action);
            if x<1 || x>obj.Num  
                next_state = State;
                next_bk = Bk;
                done = 1;
                reward = -100;
                return;
            end

            if abs(mod(x-1,obj.M)-mod(Bk-1,obj.M))>1 
                next_state = State;
                next_bk = Bk;
                done = 1;
                reward = -100;
                return;
            end

            next_state = State;
            next_state(Bk) = next_state(x);
            next_state(x) = 0;
            next_bk = x;
            if isequal(next_state,obj.target)
                reward = 100;
                obj.goal = true;
                done = 1;
            else
                done = 0;
                next_state_ind = find(all(obj.dict(:,1:obj.Num) == next_state,2));
                reward = -obj.dict(next_state_ind,obj.Num+1);
            end

%             force = action(1) * 50;
%             x = obj.state(1);
%             x_dot = obj.state(2);
%             theta = obj.state(3);
%             theta_dot = obj.state(4);
% 
%             costheta = cos(theta);
%             sintheta = sin(theta);

            % calculate angular velocity, velocity
%             temp = (force + obj.polemassLeng * theta_dot * theta_dot * sintheta) / obj.totalMass;
%             thetaacc = (obj.gravity * sintheta - costheta * temp) / (obj.poleLength * (4.0/3.0 - obj.massPole * costheta * costheta / obj.totalMass));
%             xacc = temp - obj.polemassLeng * thetaacc * costheta / obj.totalMass;

            % update state param
%             x = x + obj.timeStep * x_dot;
%             x_dot = x_dot + obj.timeStep * xacc;
%             theta = theta + obj.timeStep * theta_dot;
%             theta_dot = theta_dot + obj.timeStep * thetaacc;
%             
%             next_state = [x, x_dot, theta, theta_dot];
        end
        
        % get pre-reward(always 0)
        function generateReward(obj)            
            obj.reward = 0;
        end
        
        % simulate cart-pole
        function simCartpole(obj, state)            
            drawcartpend(state, obj.massPole, obj.massCart, obj.poleLength);
        end        
    end    
end