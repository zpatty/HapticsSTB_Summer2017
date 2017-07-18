function retrieveYoutube(dataDir)

if nargin == 0
    dataDir = 'SavedData';
end

[~, currentFolder, ~] = fileparts(pwd);

if strcmp(currentFolder, 'UtilityScripts')
    f = fopen('youtube.txt');
    ! python retrieveYoutube.py
else
    f = fopen('UtilityScripts/youtube.txt');
    ! python UtilityScripts/retrieveYoutube.py
end

videos = textscan(f, '%s %s', 'whitespace',',');
for i = 1:length(videos{1})
    videos{1}{i}([10 16])= '-';
    videos{1}{i}([7 13])= '_';
end


subjectDirs = dir([dataDir '/Subject*']);
problemFiles = {};
savedVideos = false(size(videos{1}));

for i = 1:length(subjectDirs)
    trialFiles = dir([dataDir '/' subjectDirs(i).name  '/*.mat']);
        for j = 1:length(trialFiles)
%             load([dataDir '/' subjectDirs(i).name '/' trialFiles(j).name], 'youtube_short');
            try
                videoIdx = strncmpi(videos{1}, trialFiles(j).name,18);
                if sum(videoIdx) == 0;
                    error('Video not found!')
                end
                savedVideos(videoIdx) = true;
                youtube_short = videos{2}{videoIdx}; 
                youtube = ['youtu.be/' youtube_short];
                save([dataDir '/' subjectDirs(i).name '/' trialFiles(j).name], 'youtube','youtube_short', '-append');
            catch ME
                disp(ME.message);
                disp(['Problem with ' trialFiles(j).name]);
                problemFiles{end+1} = trialFiles(j).name;
            end
        end
end

if any(savedVideos ~= 1)
    disp('Not all videos saved!..')
    unsavedVideos = videos{1}(~savedVideos);
    for i = 1:sum(~savedVideos)
        disp(unsavedVideos{i});
    end
    
end

makeLookup(dataDir)
end