%%%%% Runs both the regression and classification training and testing
%%%%% models and saves everything in a folder with run date. 

clear all; close all; clc;

time = datestr(now, 'mmddyyHHMM');
mkdir(strcat('MLRun_',num2str(time)))
addpath(strcat('MLRun_',num2str(time)))
% cd(strcat('MLRun_',num2str(time)))

% run('../ML/Test.m')

ForwardSelection(1,time);
randomForestAll(1,1,time,5);
% randomForestAll(1,1,time);
% randomForestAll(1,1,time);
% randomForestAll(1,1,time);
% randomForestAll(1,1,time);