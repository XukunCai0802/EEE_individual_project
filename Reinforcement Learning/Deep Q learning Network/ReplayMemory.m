% ReplayMemory.m : A class that stores transitions
%
% INPUTS :
%          capacity - replay memory transition
%
% OUTPUTS :
%          NONE
%
% EXAMPLE : 
%          repmem = ReplayMemory(5)
%


classdef ReplayMemory < handle
    properties
        capacity;
        memory = [];
    end
    methods
        % Initialization
        function obj = ReplayMemory(capacity)
            obj.capacity = capacity;
            obj.memory = [];
        end
        
        % push memory
        function obj = push(obj, transition)
            if isempty(obj.memory)
                obj.memory = [obj.memory; transition];
            elseif ~ismember(transition(1:HParams.M*HParams.N), obj.memory(:,1:HParams.M*HParams.N),'rows')
                if size(obj.memory,1) < obj.capacity
                    obj.memory = [obj.memory; transition]; 
                else
                    obj.memory(1, :) = [];
                    obj.memory = [obj.memory; transition];
                end
            end
        end
        
        % pop memory with ramdomly select
        function [samples] = sample(obj, batchSize)
            if size(obj.memory,1) < batchSize
                samples = obj.memory;
            else
                % ramdomly selected sample data from memory(reduced overfitting)
                indecies = randperm(size(obj.memory,1), batchSize);
                samples = obj.memory(indecies, :);
            end
        end
    end
end
            