%%%%% this function select n subjects to reserve for the testing set.
%%%%% Subjects are randomly selected from each familiarity rating (1-4). If
%%%%% n is greater than 4, ...


function [subTest,subTestInd,subTrain,subTrainInd] =  make_subject_partition(n)

if ~exist('subjectFam.mat','file')
    data = STBData('SavedData', 'task', 1);
    data = data(~cellfun(@(x)any(isnan(x(:))), {data.score}));
    
    for i = 1:length(data)
        subRaw(i,:) = (data(i).subj_id)-2;
    end
    subAct = unique(subRaw);    
    num = xlsread('DemographicSurvey.xls');
    subjectFam = [num(1:end, 5)-2,num(1:end, 11)];
    subjectFam = sortrows(subjectFam,1);
    subjectFam = subjectFam(subAct,:);
    save('subjectFam.mat','subjectFam','subRaw');
else
    load subjectFam.mat
end

for i = 1:n
    samp = subjectFam(subjectFam(:,2)==i,:);
    subExcl(i) = samp(randperm(length(samp),1),1);
end
while size(subExcl,2)<n || any(ismember(subExcl,18)) || any(ismember(subExcl,24))
    for i = 1:n
        samp = subjectFam(subjectFam(:,2)==i,:);
        subExcl(i) = samp(randperm(length(samp),1),1);
    end
end
subTest = subjectFam(ismember(subjectFam(:,1),subExcl),:);
subTestInd = ismember(subRaw,subExcl);
subTrain = subjectFam(~ismember(subjectFam(:,1),subExcl),:);
subTrainInd = ~ismember(subRaw,subExcl);
end

