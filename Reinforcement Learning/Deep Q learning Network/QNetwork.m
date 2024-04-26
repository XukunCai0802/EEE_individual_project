% QNetwork.m : Q Network class
%
% INPUTS :
%          input size : input layer size
%          hidden sizes : hidden layer sizes
%          output size : output layer size
%          epochs : The number of epochs
%          mu : learning rate
%          mu_dec : learning rate decay rate
%          QNetwork hidden layer list (ex. [10 20])
%
% OUTPUTS :
%          QNetwork object
%
% EXAMPLE : 
%          net = QNetwork([10 20])
%
%   
%   

classdef QNetwork < handle
   properties (Access = 'private')
       net = [];
       inputps;
       outputps;
   end
   
   methods (Access = 'public')
       function obj = QNetwork(inputSize, hiddenSizes, outputSize)
           input_train = rand(inputSize, 25);
           output_train = rand(outputSize, 25);
           [inputn,inputps]=mapminmax(input_train,0,1);
           [outputn,outputps]=mapminmax(output_train);
%            obj.net = fitnet(hiddenSizes, 'trainlm');
           transform_func={'tansig','purelin'};
           train_func='trainlm';
%            obj.net = newff(inputn,outputn,hiddenSizes, 'trainlm');
           obj.net = newff(inputn,outputn,hiddenSizes, transform_func,train_func);
           obj.net.trainParam.mu = HParams.mu;
           obj.net.trainParam.epochs = HParams.epochs;
           obj.net.trainParam.mu_dec = HParams.mu_dec;
           obj.net.trainParam.showWindow = false;
           obj.net.trainParam.max_fail = 1000;
           obj.net = train(obj.net, inputn,outputn);
           obj.inputps = inputps;
           obj.outputps = outputps;
       end
       
       % get network parameters
       function params = getParams(obj)
%            params.weights = obj.net.IW;
%            params.biases = obj.net.b; 
           params.W1 = obj.net.iw{1,1};
           params.B1 = obj.net.b{1};
           params.W2 = obj.net.lw{2,1};
           params.B2 = obj.net.b{2};
%            params = getwb(obj.net);
       end
       
       % set network parameters
       function setParams(obj, params)

           obj.net.iw{1,1} = params.W1;  
           obj.net.lw{2,1} = params.W2;
           obj.net.b{1} = params.B1;
           obj.net.b{2} = params.B2; 
%            obj.net = setwb(obj.net, params);
       end
       
       %train
       function trainNetwork(obj, inputs, targets)
           [inputn,inputpS]=mapminmax(inputs,0,1);
           [outputn,outputpS]=mapminmax(targets);
           obj.inputps = inputpS;
           obj.outputps = outputpS;
           transform_func={'tansig','purelin'};
           train_func='trainlm';
           obj.net = newff(inputn,outputn,4,transform_func,train_func);
           obj.net.trainParam.showWindow = false;
%            obj.net = train(obj.net, inputs,targets);
           obj.net = train(obj.net, inputn,outputn);
%            an = obj.net(inputs);
           an=sim(obj.net,inputn);
           test_simu=mapminmax('reverse',an,obj.outputps);
           error = test_simu-targets;
       end
       
       % prediction
       function out = predict(obj, input)
           [inputn]=mapminmax('apply',input,obj.inputps);
%            out = obj.net(input);
           out = sim(obj.net,inputn);
           out=mapminmax('reverse',out,obj.outputps);
       end
   end
end