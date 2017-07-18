clearvars;
% disp('THIS SCRIPT DELETES EVERY SCORE CURRENTLY RECORDED')
% disp('ARE YOU SURE?')
% pause;

dataDir = 'SavedData';
subjectDirs = dir([dataDir '/Subject*']);

for i = 1:length(subjectDirs)
    trialFiles = dir([dataDir '/' subjectDirs(i).name  '/*.mat']);
        for j = 1:length(trialFiles)            
            score = [];
            rater = {};
            save([dataDir '/' subjectDirs(i).name '/' trialFiles(j).name], 'score','rater', '-append');
        end
end