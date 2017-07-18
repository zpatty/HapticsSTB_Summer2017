clear all; close all;
data = STBData('SavedData');

data = data(~cellfun(@(x)any(ismember(x(:),10)), {data.subj_id}));%remove subject 10
data = data(~cellfun(@(x)any(ismember(x(:),11)), {data.subj_id}));%remove subject 11
data = data(~cellfun(@(x)any(ismember(x(:),12)), {data.subj_id}));%remove subject 12

GrpA = data.group(1);%no feedback group
GrpB = data.group(2);%feedback group


% groupA = [3,5,6,8,10,13,15,17,19,20,22,24,26,29]; %no feedback group
% groupB = [1,2,4,7,9,11,12,14,16,18,21,23,25,27,28,]; %feedback group
%% Stores rating data in to (NxMxP) matrix where N-GEARS domains, M-trials(1-5), P-subjects(1-13)

for i = 1:5
    trialA = GrpA.trial(i);
    trialB = GrpB.trial(i);
    for j = 1:length(trialA)
        resultsN(:,i,j) = trialA(j).reg_rating';
    end
    for j = 1:length(trialB)
        resultsF(:,i,j) = trialB(j).reg_rating';
    end
end

%% Create separate (MxN) matrix for each GEARS domain where N-subjects, M-trials

% DPraw = permute(resultsF(1,:,:),[3,2,1]);
% BDraw = permute(resultsF(2,:,:),[3,2,1]);
% Eraw  = permute(resultsF(3,:,:),[3,2,1]);
% FSraw = permute(resultsF(4,:,:),[3,2,1]);
% RCraw = permute(resultsF(5,:,:),[3,2,1]);
% 
% DPdiff = [diff(DPraw,1,2),DPraw(:,end)-DPraw(:,1)];
% BDdiff = [diff(BDraw,1,2),BDraw(:,end)-BDraw(:,1)];
% Ediff  = [diff(Eraw,1,2),Eraw(:,end)-Eraw(:,1)];
% FSdiff = [diff(FSraw,1,2),FSraw(:,end)-FSraw(:,1)];
% RCdiff = [diff(RCraw,1,2),RCraw(:,end)-RCraw(:,1)];


%%

% PegLearningRawDataR = zeros(length(data),9);
% for i = 1:length(data)
%     id = data(i).subj_id;
%     group = data(i).group;
%     trial = data(i).trialnum;
%     GEARSscore = data(i).reg_rating;
%     DPscore = GEARSscore(1);
%     BDscore = GEARSscore(2);
%     Escore = GEARSscore(3);
%     FSscore = GEARSscore(4);
%     RCscore = GEARSscore(5);
%     SUMscore = sum(GEARSscore); 
%    
%     PegLearningRawDataR(i,:) = [id,group,trial,BDscore,DPscore,Escore,FSscore,RCscore,SUMscore];
% end

DP = [];
BD = [];
E = [];
FS = [];
RC = [];
OV = [];
DPraw = [];
BDraw = [];
Eraw = [];
FSraw = [];
RCraw = [];
OVraw = [];
subs = unique(data.subject)
for i = 1:length(subs)
    id = subs(i);
    trials = data.subject(id);
    group = trials(1).group;
    for j=1:length(trials)
        DP(i,j)=trials(j).reg_rating(1);
        BD(i,j)=trials(j).reg_rating(2);
        E(i,j)=trials(j).reg_rating(3);
        FS(i,j)=trials(j).reg_rating(4);
        RC(i,j)=trials(j).reg_rating(5);
        OV(i,j) = sum(trials(j).reg_rating);
    end
    DPraw(i,:) = [id,group,1,DP(i,:)];
    BDraw(i,:) = [id,group,2,BD(i,:)];
    Eraw(i,:) =  [id,group,3,E(i,:)];
    FSraw(i,:) = [id,group,4,FS(i,:)];
    RCraw(i,:) = [id,group,5,RC(i,:)];
    OVraw(i,:) = [id,group,6,OV(i,:)];

end

PegLearningRawDataR = [DPraw;BDraw;Eraw;FSraw;RCraw;OVraw];
    
label = {'Sub','Group','Domain','Trial1','Trial2','Trial3','Trial4','Trial5'};
RawGearsDataRTab = array2table(PegLearningRawDataR,'VariableNames',label);

writetable(RawGearsDataRTab,'Stats/PegTrainRawGearsDataR.dat')

DiffData = [diff(PegLearningRawDataR(:,4:end),1,2),PegLearningRawDataR(:,end)-PegLearningRawDataR(:,4)];

PegLearningDiffDataR = [PegLearningRawDataR(:,1:3),DiffData];

% subs = unique(PegLearningRawDataR(:,1));
% k=1;
% 
% for i = 1:length(subs)
%     id = subs(i);
%     results = PegLearningRawDataR(PegLearningRawDataR(:,1)==id,2:end);
%     results = sortrows(results,2);
%     group = results(1,1);
%     GearsDiff = [diff(results(:,3:end),1,1);results(end,3:end)-results(1,3:end)];
%     for j=1:size(GearsDiff,1)
%         PegLearningDiffDataR(k,:) = [id,group,j,GearsDiff(j,:)];
%         k=k+1;
%     end    
% end

label = {'Sub','Group','Domain','Diff12','Diff23','Diff34','Diff45','Diff15'};
DiffGearsDataRTab = array2table(PegLearningDiffDataR,'VariableNames',label);

writetable(RawGearsDataRTab,'Stats/PegTrainDiffGearsDataR.dat')
    
% %%%%% removing Subject 4 Trial 1 %%%%%
% SqueezeDataR(SqueezeDataR(:,1)==4 & SqueezeDataR(:,3)==1,6:end) = NaN;
