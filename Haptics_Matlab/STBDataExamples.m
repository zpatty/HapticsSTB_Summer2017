%% Don't run this entire script at once! Just run each cell to see what it does
return;

%% Loading Data
clearvars;

% Load all data stored in the SavedData folder into STBData array
data = STBData('SavedData');

% Load data for task #1
data = STBData('SavedData', 'task', 1);

% Load data for subject #3
data = STBData('SavedData', 'subject', 1);

% Load data for subject #3 doing task #1, optional arguments order doesnt matter
data = STBData('SavedData', 'task', 1, 'subject', 3);

%% Indexing Data
clearvars;
data = STBData('SavedData');

% Return array elements from subject #3
data.subject(3)

% Returns subject, task id, and trial# associated with an element
data(1).subject
data(1).subj_id
data(1).trial

% Returns array elements for task #1
data.task(1)

% Returns array elements for trial 1
data.trial(1)

% Can use subject, task, and trial at same time (both of these work)
data.subject(3).task(1).trial(1)
data.task(1).subject(3).trial(1)

% List methods associated with STBData
methods(data)

%% Plotting
clearvars
% Plot forces, moments, and accelerations
data(1).plotForces
% Can also give a range (same for all plotting functions)
data(1).plotForces([0 1])

% Plot moments
data(1).plotMoments

%Plot accelerometer data
data(1).plotAcc

%Plot single accelerometer
data(1).plotAcc(1)

%% Generating Surveys
clearvars;
% Load task data

% task = 1;
task = 2;
% task = 3;
data = STBData('SavedData', 'task', task);

% Remove trials that will be used for calibration survey
[Index,Subject] = RemoveSubTrialsCal(data,task,2);

% Generate calibration survery 
Caldata = data(Index{1});
genSurvey(Caldata,sprintf('SurveyT%d_Cal1.txt',task));

Caldata = data(Index{2});
genSurvey(Caldata,sprintf('SurveyT%d_Cal2.txt',task));

% Generate 10-trial partitions for survey
ind = Index{1}|Index{2};
data(ind) = [];
part = make_xval_partition(numel(data), ceil(numel(data)/10));

% Generate surveys
for survey = unique(part)
    genSurvey(data(part == survey), sprintf('SurveyT%d_%02d.txt',task, survey));
end

%% Generate Survey without Trials that Have already been scored
clearvars;

data = STBData('SavedData', 'task', 1);

unscoredData = data(cellfun(@isempty, {data.score}));

% Generate 10-trial partitions for survey
part = make_xval_partition(numel(unscoredData), ceil(numel(unscoredData)/10));

% Generate surveys
for survey = unique(part)
    genSurvey(unscoredData(part == survey), sprintf('Survey%02d.txt', survey));
end

%% Parse ratings from completed survey

parseRatings('STB_GEARS_Rating_T1_2nd_Round.xls')


%% Loading new subject data

% loadSubjectData(Unprocessed Data Dir, Dir to save processed data, subject
% to load (omit if you want everthing));
addpath UtilityScripts
loadSubjectData('/Volumes/HAMR_LAB1/HapticTrainingStudyData', 'SavedData',1);

% for double precision, use the following: 
loadSubjectDataDouble('/Volumes/HAMR_LAB1/HapticTrainingStudyData', 'SavedDataDouble',3);

%% Adding 