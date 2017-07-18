function problemFiles = loadSubjectData(testDir, targetDir, subjects)
% Reads the .mat files produced by the the STB into the .mat format we need for analysis

if nargin == 2
	subjects = [];
end

testDirs = dir(testDir);
subjectDirs = {};
for i = 1:length(testDirs)
	if strncmp(testDirs(i).name, 'Subject', 7)
		subjectDirs{end+1} = testDirs(i).name;
	end
end

if ~isempty(subjects)
	subjDirDes = sprintf('Subject%03d ', subjects);
	subjDirDes = strsplit(subjDirDes);
	subjDirDes(end) = [];
	subjectDirs = subjectDirs(ismember(subjectDirs, subjDirDes));
end

problemFiles = {};

for i = 1:length(subjectDirs)
	trialFiles = dir([testDir '/' subjectDirs{i} '/*.csv']);
    disp(subjectDirs{i})
    mkdir([targetDir '/' subjectDirs{i}])
	for j = 1:length(trialFiles)
		fileName = trialFiles(j).name;
        
        try
            disp('Loading...')
            rawData = single(csvread([ testDir '/' subjectDirs{i} '/' fileName]));
            load([ testDir '/' subjectDirs{i} '/' fileName]);
            rawData = single(rawData);
%             disp('Checking acc data')
%             err = abs(mean(sqrt(sum(rawData(:,7:9).^2,2))) - 1);
%             if err > 0.2
%             	disp('Acc data in V, converting to gs');
%                 rawData(:,7:15) = (rawData(:,7:15)-1.65)/(3.3/15);
%             end
            disp('Adding placeholder youtube address, use addYoutube.m to finalize')
            youtube_short = '';
            youtube = ['youtu.be/' youtube_short];
            score = [];
            rater = {};
            video_time = [];
            disp('Saving...')
            save([targetDir '/' subjectDirs{i} '/' fileName(1:end-4)], 'rawData', 'youtube', 'youtube_short', 'score', 'rater', 'video_time');
        catch ME
            disp(ME.message);
            disp(['Problem with ' fileName])
            problemFiles{end+1} = fileName;
        end
        clear rawData
	end

end

end