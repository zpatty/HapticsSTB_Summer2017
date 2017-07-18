clear all; close all;

data = STBData('SavedData_backup','subject',3:13);
data = data(~cellfun(@(x)any(ismember(x(:),4)), {data.subj_id}));

[~, ~, raw] = xlsread('RawDataDurations');

% get experiment
GrpA = data.group(1);
GrpB = data.group(2);

% %%%% removing Subject 4 Trial 1 %%%%%
% if ismember(GrpA(1).subj_id,4) && ismember(GrpA(1).trial,1)
%     GrpA(1).video_time = NaN;
%     GrpA(1).mag = NaN;
% else
%     error('Not subject 4 trial 1')
% end

resultsA = NaN*ones(9,4,length(GrpA)/9);
resultsB = NaN*ones(9,4,length(GrpB)/9);

for i=1:9
    trialA = GrpA.trial(i);
    trialB = GrpB.trial(i);
    for j=1:length(trialA)
        resultsA(i,1,j) = trialA(j).act_time;
        nanmag = trialA(j).mag;
        nanmag(nanmag<0.1)=NaN;
        zeromag = trialA(j).mag;
        zeromag(zeromag<0.1)=0;
        shiftmag = trialA(j).mag-0.1;
        shiftmag(shiftmag<0)=0;
        resultsA(i,2,j) = nanmean(nanmag);
        resultsA(i,3,j) = rms(zeromag);
        resultsA(i,4,j) = trapz(trialA(j).plot_time,shiftmag);
    end
    
    for j=1:length(trialB)
        resultsB(i,1,j) = trialB(j).act_time;
        nanmag = trialB(j).mag;
        nanmag(nanmag<0.1)=NaN;
        zeromag = trialB(j).mag;
        zeromag(zeromag<0.1)=0;
        shiftmag = trialB(j).mag-0.1;
        shiftmag(shiftmag<0)=0;
        resultsB(i,2,j) = nanmean(nanmag);
        resultsB(i,3,j) = rms(zeromag);
        resultsB(i,4,j) = trapz(trialB(j).plot_time,shiftmag);
    end
end

% %%%%% removing Subject 4 Trial 1 %%%%%
% resultsA(1,:,1) = NaN;

AvgResultsTrialA = nanmean(resultsA,3);
StdResultsTrialA = nanstd(resultsA,0,3);

AvgResultsTrialB = nanmean(resultsB,3);
StdResultsTrialB = nanstd(resultsB,0,3);

resultsPhase1A = resultsA(1:3,:,:);
resultsPhase2A = resultsA(4:6,:,:);
resultsPhase3A = resultsA(7:9,:,:);

resultsPhase1B = resultsB(1:4,:,:);
resultsPhase2B = resultsB(5:7,:,:);
resultsPhase3B = resultsB(8:9,:,:);

resultsPhase1ACat = cat(3,resultsA(1,:,:),resultsA(2,:,:),resultsA(3,:,:));
resultsPhase2ACat = cat(3,resultsA(4,:,:),resultsA(5,:,:),resultsA(6,:,:));
resultsPhase3ACat = cat(3,resultsA(7,:,:),resultsA(8,:,:),resultsA(9,:,:));

resultsPhase1BCat = cat(3,resultsB(1,:,:),resultsB(2,:,:),resultsB(3,:,:),resultsB(4,:,:));
resultsPhase2BCat = cat(3,resultsB(5,:,:),resultsB(6,:,:),resultsB(7,:,:));
resultsPhase3BCat = cat(3,resultsB(8,:,:),resultsB(9,:,:));

AvgResultsPhase1A = nanmean(resultsPhase1ACat,3);
AvgResultsPhase2A = nanmean(resultsPhase2ACat,3);
AvgResultsPhase3A = nanmean(resultsPhase3ACat,3);

AvgResultsPhase1B = nanmean(resultsPhase1BCat,3);
AvgResultsPhase2B = nanmean(resultsPhase2BCat,3);
AvgResultsPhase3B = nanmean(resultsPhase3BCat,3);

StdResultsPhase1A = nanstd(resultsPhase1ACat,0,3);
StdResultsPhase2A = nanstd(resultsPhase2ACat,0,3);
StdResultsPhase3A = nanstd(resultsPhase3ACat,0,3);

StdResultsPhase1B = nanstd(resultsPhase1BCat,0,3);
StdResultsPhase2B = nanstd(resultsPhase2BCat,0,3);
StdResultsPhase3B = nanstd(resultsPhase3BCat,0,3);

resultsPhaseFinalACat = [resultsA(3,:,:);resultsA(6,:,:);resultsA(9,:,:)];
resultsPhaseFinalBCat = [resultsB(4,:,:);resultsB(7,:,:);resultsB(9,:,:)];

AvgResultsPhaseFinalA = nanmean(resultsPhaseFinalACat,3);
AvgResultsPhaseFinalB = nanmean(resultsPhaseFinalBCat,3);

StdResultsPhaseFinalA = nanstd(resultsPhaseFinalACat,0,3);
StdResultsPhaseFinalB = nanstd(resultsPhaseFinalBCat,0,3);

resultsPhase1ABCat = cat(3,resultsPhase1ACat,resultsPhase1BCat);
resultsPhase2ABCat = cat(3,resultsPhase2ACat,resultsPhase2BCat);
resultsPhase3ABCat = cat(3,resultsPhase3ACat,resultsPhase3BCat);

AvgResultsPhase1AB = nanmean(resultsPhase1ABCat,3);
AvgResultsPhase2AB = nanmean(resultsPhase2ABCat,3);
AvgResultsPhase3AB = nanmean(resultsPhase3ABCat,3);

StdResultsPhase1AB = nanstd(resultsPhase1ABCat,0,3);
StdResultsPhase2AB = nanstd(resultsPhase2ABCat,0,3);
StdResultsPhase3AB = nanstd(resultsPhase3ABCat,0,3);

resultsPhaseFinalABCat = cat(3,resultsPhaseFinalACat,resultsPhaseFinalBCat);

AvgResultsPhaseFinalAB = nanmean(resultsPhaseFinalABCat,3);

StdResultsPhaseFinalAB = nanstd(resultsPhaseFinalABCat,0,3);

SqueezeData = zeros(length(data),10);
for i = 1:length(data)
    id = data(i).subj_id;
    group = data(i).group;
    trial = data(i).task_id;
    phase = data(i).phase;
    haptic = data(i).haptic;
    time = data(i).duration;
    act_time = data(i).act_time;
    Mag = nanmean(data(i).mag);
    Rms = rms(data(i).mag);
    shiftmag = data(i).mag-0.1;
    shiftmag(shiftmag<0)=0;
    Int = trapz(data(i).plot_time,shiftmag);
%     NaNmag = data(i).mag;
%     NaNmag(NaNmag<0.1)=NaN;
%     NaNmag = nanmean(NaNmag);
    SqueezeData(i,:) = [id,group,trial,phase,haptic,time,act_time,Mag,Rms,Int];
end

% %%%%% removing Subject 10 Trial 1 %%%%%
% SqueezeData(SqueezeData(:,1)==10 & SqueezeData(:,3)==1,6:end) = NaN;



id = unique(SqueezeData(:,1));
k=1;
SqueezeDataR = zeros(length(id),9);
for i = 1:length(id)
    sData = SqueezeData(SqueezeData(:,1)==id(i),:);
    group = unique(sData(:,2));
    trial = unique(sData(:,3));
    for j = 1:3
        phase = j;
        SqueezeDataR(k,:) = [id(i),group,phase,mean(sData(sData(:,4)==phase,5:end),1)]
        k=k+1;
    end
end



label = {'Sub','Group','Phase','Haptic','Time','ActiveTime','MeanMag','RmsMag','IntMag'};
SqueezeDataRTab = array2table(SqueezeDataR,'VariableNames',label);

writetable(SqueezeDataRTab,'Stats/SqueezeDataR.dat')

%%
h1 = figure(1)
hold on
errorbar(AvgResultsTrialA(:,1),StdResultsTrialA(:,1))
errorbar(AvgResultsTrialB(:,1),StdResultsTrialB(:,1))
legend('GroupA','GroupB')
xlabel('Trial #');ylabel('Mean Duration (s)')
print(h1,'RawFigs/DurationByGroupAllTrial','-dpdf')
h2 = figure(2)
hold on
errorbar(AvgResultsTrialA(:,2),StdResultsTrialA(:,2))
errorbar(AvgResultsTrialB(:,2),StdResultsTrialB(:,2))
legend('GroupA','GroupB')
xlabel('Trial #');ylabel('Mean Force Mag (N)')
print(h2,'RawFigs/ForceMagByGroupAllTrial','-dpdf')
h3 = figure(3)
hold on
errorbar(AvgResultsTrialA(:,3),StdResultsTrialA(:,3))
errorbar(AvgResultsTrialB(:,3),StdResultsTrialB(:,3))
legend('GroupA','GroupB')
xlabel('Trial #');ylabel('Mean Force RMS (N)')
print(h3,'RawFigs/ForceRmsByGroupAllTrial','-dpdf')
h4 = figure(4)
hold on
errorbar(AvgResultsTrialA(:,4),StdResultsTrialA(:,4))
errorbar(AvgResultsTrialB(:,4),StdResultsTrialB(:,4))
legend('GroupA','GroupB')
xlabel('Trial #');ylabel('Mean Force Integral (Ns)')
print(h4,'RawFigs/ForceIntByGroupAllTrial','-dpdf')

%%
h5 = figure(5)
hold on
errorbar([AvgResultsPhase1A(:,1),AvgResultsPhase2A(:,1),AvgResultsPhase3A(:,1)],[StdResultsPhase1A(:,1),StdResultsPhase2A(:,1),StdResultsPhase3A(:,1)]);
errorbar([AvgResultsPhase1B(:,1),AvgResultsPhase2B(:,1),AvgResultsPhase3B(:,1)],[StdResultsPhase1B(:,1),StdResultsPhase2B(:,1),StdResultsPhase3B(:,1)]);
legend('GroupA','GroupB')
xlabel('Phase #');ylabel('Mean Duration (s)')
print(h5,'RawFigs/DurationByGroupByPhase','-dpdf')
h6 = figure(6)
hold on
errorbar([AvgResultsPhase1A(:,2),AvgResultsPhase2A(:,2),AvgResultsPhase3A(:,2)],[StdResultsPhase1A(:,2),StdResultsPhase2A(:,2),StdResultsPhase3A(:,2)]);
errorbar([AvgResultsPhase1B(:,2),AvgResultsPhase2B(:,2),AvgResultsPhase3B(:,2)],[StdResultsPhase1B(:,2),StdResultsPhase2B(:,2),StdResultsPhase3B(:,2)]);
legend('GroupA','GroupB')
xlabel('Phase #');ylabel('Mean Force Mag (N)')
print(h6,'RawFigs/ForceMagByGroupByPhase','-dpdf')
h7 = figure(7)
hold on
errorbar([AvgResultsPhase1A(:,3),AvgResultsPhase2A(:,3),AvgResultsPhase3A(:,3)],[StdResultsPhase1A(:,3),StdResultsPhase2A(:,3),StdResultsPhase3A(:,3)]);
errorbar([AvgResultsPhase1B(:,3),AvgResultsPhase2B(:,3),AvgResultsPhase3B(:,3)],[StdResultsPhase1B(:,3),StdResultsPhase2B(:,3),StdResultsPhase3B(:,3)]);
legend('GroupA','GroupB')
xlabel('Phase #');ylabel('Mean Force RMS (N)')
print(h7,'RawFigs/ForceRmsByGroupByPhase','-dpdf')
h8 = figure(8)
hold on
errorbar([AvgResultsPhase1A(:,4),AvgResultsPhase2A(:,4),AvgResultsPhase3A(:,4)],[StdResultsPhase1A(:,4),StdResultsPhase2A(:,4),StdResultsPhase3A(:,4)]);
errorbar([AvgResultsPhase1B(:,4),AvgResultsPhase2B(:,4),AvgResultsPhase3B(:,4)],[StdResultsPhase1B(:,4),StdResultsPhase2B(:,4),StdResultsPhase3B(:,4)]);
legend('GroupA','GroupB')
xlabel('Phase #');ylabel('Mean Force Integral (Ns)')
print(h8,'RawFigs/ForceIntByGroupByPhase','-dpdf')

%%
h9 = figure(9)
hold on
errorbar(AvgResultsPhaseFinalA(:,1),StdResultsPhaseFinalA(:,1))
errorbar(AvgResultsPhaseFinalB(:,1),StdResultsPhaseFinalB(:,1))
legend('GroupA','GroupB')
xlabel('Last Trial Phase');ylabel('Mean Duration (s)')
print(h9,'RawFigs/DurationByGroupPhaseFinal','-dpdf')
h10 = figure(10)
hold on
errorbar(AvgResultsPhaseFinalA(:,2),StdResultsPhaseFinalA(:,2))
errorbar(AvgResultsPhaseFinalB(:,2),StdResultsPhaseFinalB(:,2))
legend('GroupA','GroupB')
xlabel('Last Trial Phase');ylabel('Mean Force Mag (N)')
print(h10,'RawFigs/ForceMagByGroupPhaseFinal','-dpdf')
h11 = figure(11)
hold on
errorbar(AvgResultsPhaseFinalA(:,3),StdResultsPhaseFinalA(:,3))
errorbar(AvgResultsPhaseFinalB(:,3),StdResultsPhaseFinalB(:,3))
legend('GroupA','GroupB')
xlabel('Last Trial Phase');ylabel('Mean Force RMS (N)')
print(h11,'RawFigs/ForceRmsByGroupPhaseFinal','-dpdf')
h12 = figure(12)
hold on
errorbar(AvgResultsPhaseFinalA(:,4),StdResultsPhaseFinalA(:,4))
errorbar(AvgResultsPhaseFinalB(:,4),StdResultsPhaseFinalB(:,4))
legend('GroupA','GroupB')
xlabel('Last Trial Phase');ylabel('Mean Force Integral (Ns)')
print(h12,'RawFigs/ForceIntByGroupPhaseFinal','-dpdf')

%%
h13 = figure(13)
hold on
errorbar([AvgResultsPhase1AB(:,1),AvgResultsPhase2AB(:,1),AvgResultsPhase3AB(:,1)],...
    [StdResultsPhase1AB(:,1),StdResultsPhase2AB(:,1),StdResultsPhase3AB(:,1)])
legend('Group A+B (avg)')
xlabel('Phase #');ylabel('Mean Duration (s)')
print(h13,'RawFigs/DurationGroupCombinedByPhase','-dpdf')
h14 = figure(14)
hold on
errorbar([AvgResultsPhase1AB(:,2),AvgResultsPhase2AB(:,2),AvgResultsPhase3AB(:,2)],...
    [StdResultsPhase1AB(:,2),StdResultsPhase2AB(:,2),StdResultsPhase3AB(:,2)])
legend('Group A+B (avg)')
xlabel('Phase #');ylabel('Mean Force Mag (N)')
print(h14,'RawFigs/ForceMagGroupCombinedByPhase','-dpdf')
h15 = figure(15)
hold on
errorbar([AvgResultsPhase1AB(:,3),AvgResultsPhase2AB(:,3),AvgResultsPhase3AB(:,3)],...
    [StdResultsPhase1AB(:,3),StdResultsPhase2AB(:,3),StdResultsPhase3AB(:,3)])
legend('Group A+B (avg)')
xlabel('Phase #');ylabel('Mean Force RMS (N)')
print(h15,'RawFigs/ForceRmsGroupCombinedByPhase','-dpdf')
h16 = figure(16)
hold on
errorbar([AvgResultsPhase1AB(:,4),AvgResultsPhase2AB(:,4),AvgResultsPhase3AB(:,4)],...
    [StdResultsPhase1AB(:,4),StdResultsPhase2AB(:,4),StdResultsPhase3AB(:,4)])
legend('Group A+B (avg)')
xlabel('Phase #');ylabel('Mean Force Integral (Ns)')
print(h16,'RawFigs/ForceIntGroupCombinedByPhase','-dpdf')

%%
h17 = figure(17)
hold on
errorbar(AvgResultsPhaseFinalAB(:,1),StdResultsPhaseFinalAB(:,1))
legend('Group A+B (avg)')
xlabel('Last Trial Phase');ylabel('Mean Duration (s)')
print(h17,'RawFigs/DurationGroupCombinedPhaseFinal','-dpdf')
h18 = figure(18)
hold on
errorbar(AvgResultsPhaseFinalAB(:,2),StdResultsPhaseFinalAB(:,2))
legend('Group A+B (avg)')
xlabel('Last Trial Phase');ylabel('Mean Force Mag (N)')
print(h18,'RawFigs/ForceMagGroupCombinedByPhase','-dpdf')
h19 = figure(19)
hold on
errorbar(AvgResultsPhaseFinalAB(:,3),StdResultsPhaseFinalAB(:,3))
legend('Group A+B (avg)')
xlabel('Last Trial Phase');ylabel('Mean Force RMS (N)')
print(h19,'RawFigs/ForceRmsGroupCombinedByPhase','-dpdf')
h20 = figure(20)
hold on
errorbar(AvgResultsPhaseFinalAB(:,4),StdResultsPhaseFinalAB(:,4))
legend('Group A+B (avg)')
xlabel('Last Trial Phase');ylabel('Mean Force Integral (Ns)')
print(h20,'RawFigs/ForceIntGroupCombinedByPhase','-dpdf')

%%

h21 = figure(21)
hold on 
for i = 1:size(resultsA,3)
    plot(resultsA(:,1,i),'b')
    plot(resultsB(:,1,i),'r')
end
legend('GroupA','GroupB')
xlabel('Trial #');ylabel('Mean Duration (s)')
print(h21,'RawFigs/DurationIndividualByTrial','-dpdf')

h22 = figure(22)
hold on
for i = 1:size(resultsA,3)
    plot(resultsA(:,2,i),'b')
    plot(resultsB(:,2,i),'r')
end
legend('GroupA','GroupB')
xlabel('Trial #');ylabel('Mean Force Mag (N)')
print(h22,'RawFigs/ForceMagIndividualByTrial','-dpdf')

h23 = figure(23)
hold on
for i = 1:size(resultsA,3)
    plot(resultsA(:,3,i),'b')
    plot(resultsB(:,3,i),'r')
end
legend('GroupA','GroupB')
xlabel('Trial #');ylabel('Mean Force RMS (N)')
print(h23,'RawFigs/ForceRmsIndividualByTrial','-dpdf')

h24 = figure(24)
hold on
for i = 1:size(resultsA,3)
    plot(resultsA(:,4,i),'b')
    plot(resultsB(:,4,i),'r')
end
legend('GroupA','GroupB')
xlabel('Trial #');ylabel('Mean Force Integral (Ns)')
print(h24,'RawFigs/ForceIntIndividualByTrial','-dpdf')

%%

h25 = figure(25)
label = {'1','2','3','4','5','6','7','8','9'}
dx = 0.02;
dy = 0.1;
hold on
for i = 1:size(resultsA,3)
    scatter(resultsA(:,2,i),resultsA(:,1,i),'b')
    text(resultsA(:,2,1)+dx,resultsA(:,1,1)+dy,label)
    scatter(resultsB(:,2,i),resultsB(:,1,i),'r')
    text(resultsB(:,2,1)+dx,resultsB(:,1,1)+dy,label)
end
legend('GroupA','GroupB')
