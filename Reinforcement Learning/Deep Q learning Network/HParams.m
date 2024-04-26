% HParams.m : Hyper parameters class
%
% INPUTS :
%          NONE
% OUTPUTS :
%          NONE
%
% EXAMPLE : 
%          HParams.mu
%
%   
%   

classdef HParams < handle
    
    properties (Constant)
        maxEpoch = 400;
        maxIttr = 50;

        % Environment parameters
        M = 3;  % 横向格子数目
        N = 3;  % 纵向格子数目
        % Q Network parameters
        mu = 0.01;
        epochs = 100;
        mu_dec = 0.8;
        
        % Agent parameters
        gamma = 0.9;
        batch = 1;
        epsilon = 0.2;
        epsilonDecay = 1;
        testtotalReward = [];
        targetUpdate = 2;
       
        bufferSize = 32;
        sampleSize = 32;
        simChoice;
    end

end

