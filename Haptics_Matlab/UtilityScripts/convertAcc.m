clearvars

dataDir = 'SavedData';
subjectDirs = dir([dataDir '/Subject*']);

for i = 1:length(subjectDirs)
    trialFiles = dir([dataDir '/' subjectDirs(i).name  '/*.mat']);
        for j = 1:length(trialFiles)
            disp(['Trial : ' trialFiles(j).name]);
            data = load([dataDir '/' subjectDirs(i).name '/' trialFiles(j).name]);
            
            err = abs(mean(sqrt(sum(data.rawData(:,7:9).^2,2))) - 1);
            
            if err > 0.5
                data.rawData(:,7:15) = (data.rawData(:,7:15)-1.65)/(3.3/15);
                save([dataDir '/' subjectDirs(i).name '/' trialFiles(j).name],'-struct', 'data');
            end
        end
end