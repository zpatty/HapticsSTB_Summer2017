clearvars;

dataDir = 'SavedData';
subjectDirs = dir([dataDir '/Subject*']);

redo = false;

for i = 1:length(subjectDirs)
    trialFiles = dir([dataDir '/' subjectDirs(i).name  '/*.mat']);
        for j = 1:length(trialFiles)
            flag = true;
            if ~redo
                load([dataDir '/' subjectDirs(i).name '/' trialFiles(j).name], 'youtube_short');
                if length(youtube_short) == 11
                    continue
                end
            end
                
            while true
                disp(['Trial : ' trialFiles(j).name]);
                youtube_short = input('Youtube address?: ', 's');
                if length(youtube_short) == 11
                    disp('valid address');
                    break
                else
                    disp('Invalid address! Try again!')
                end
            end
            
            youtube = ['youtu.be/' youtube_short];
            save([dataDir '/' subjectDirs(i).name '/' trialFiles(j).name], 'youtube','youtube_short', '-append');
        end
end