%%%%% Performs the training and testing for both the regression and
%%%%% classification models 

function randomForestAll(rounding,TrainTest,folder,nRuns)
close all; clc;
clearvars -except rounding TrainTest folder nRuns
leaf = [25,25,15,25,15];
nTrees = 500;
for i = 1:nRuns

    time = strcat(folder,'r',num2str(i));
    tic
    for j = 1:length(nTrees)
        for k = 1:5
            [b,c,results,maxIndex,postProb] = randomForestTrainRound(rounding,TrainTest,k,leaf(k),nTrees(j),time,folder);
        end
        toc
    end
    toc

    ensembleTestSelectFeaturesRoundCVPart(rounding,TrainTest,1,time,folder)
end