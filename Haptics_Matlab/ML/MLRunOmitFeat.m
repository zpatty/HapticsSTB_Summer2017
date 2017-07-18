%%%%% Runs both the regression and classification training and testing
%%%%% models and saves everything in a folder with run date. 

%%%%% This version allows certain features to be removed from the data set

function MLRunOmitFeat(omit,time)
% clear all; close all; clc;

% omit = 2;

% time = datestr(now, 'mmddyyHHMM');
% time = '1030151927';
addpath(strcat('MLRun_',time));
if omit == 1 % accel features removed
    mkdir(strcat('MLRunNoPCA_',num2str(time)))
    addpath(strcat('MLRunNoPCA_',num2str(time)))
elseif omit == 2 % force features removed
    mkdir(strcat('MLRunNoForce_',num2str(time)))
    addpath(strcat('MLRunNoForce_',num2str(time)))
elseif omit == 3 % PCA and force features removed
    mkdir(strcat('MLRunNoForcePCA_',num2str(time)))
    addpath(strcat('MLRunNoForcePCA_',num2str(time)))
end

 
% cd(strcat('MLRun_',num2str(time)))

% run('../ML/Test.m')

ForwardSelectionOF(1,time,omit);
randomForestAllOF(1,1,time,5,omit);

end
% randomForestAll(1,1,time);
% randomForestAll(1,1,time);
% randomForestAll(1,1,time);
% randomForestAll(1,1,time);