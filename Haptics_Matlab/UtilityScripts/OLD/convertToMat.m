clearvars;

testDir = '/Volumes/STB2/STB_Test_Data';
testDirs = dir(testDir);
subjectDirs = {};
for i = 1:length(testDirs)
	if strncmp(testDirs(i).name, 'Subject', 7)
		subjectDirs{end+1} = testDirs(i).name;
	end
end

problemFiles = {};

for i = 1:length(subjectDirs)
	trialFiles = dir([testDir '/' subjectDirs{i} '/*.csv']);
    disp(subjectDirs{i})
    mkdir(['SavedData/' subjectDirs{i}])
	for j = 1:length(trialFiles)
		fileName = trialFiles(j).name
        
        try
            disp('Loading...')
            rawData = single(csvread([ testDir '/' subjectDirs{i} '/' fileName]));
            disp('Saving...')
            save(['SavedData/' subjectDirs{i} '/' fileName(1:end-4)], 'rawData');
        catch
            disp(['Problem with ' fileName])
            problemFiles{end+1} = fileName;
        end
        clear rawData

	end

end

problemFiles