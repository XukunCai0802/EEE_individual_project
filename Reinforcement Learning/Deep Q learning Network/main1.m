% main.m : A script for DQN demo
%
% INPUTS :
%          NONE
% OUTPUTS :
%          NONE
%
% EXAMPLE : 
%          NONE
%
%   
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialization
clear all; clc; close all;

% Create DQNLearner
TicTacToeQlearn = DQNLearner();

% Training
TicTacToeQlearn.train();

% Testing
test_simSteps = 100;
TicTacToeQlearn.DQNTest(test_simSteps);