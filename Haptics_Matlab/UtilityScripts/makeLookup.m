function makeLookup(dataDir)
	subjectDirs = dir([dataDir '/Subject*']);

	nTrials = zeros(length(subjectDirs), 1);

    for i = 1:length(subjectDirs)
    	nTrials(i) = length(dir([dataDir '/' subjectDirs(i).name '/*.mat']));
    end

    % Using youtube link as key
    key{sum(nTrials)} = [];
    % Filename location is value
    value{sum(nTrials)} = [];

    k = 1;
    for i = 1:length(subjectDirs)
    	trialFiles = dir([dataDir '/' subjectDirs(i).name  '/*.mat']);
		for j = 1:length(trialFiles)
            disp(['Loading: ' trialFiles(j).name])

            fileName = [dataDir '/' subjectDirs(i).name '/' trialFiles(j).name];
            load(fileName, 'video_time');

            key{k} = video_time;
            value{k} = fileName;

            k = k+1;
            clear video_time
		end
    end

    lookup = containers.Map(key, value);

    save([dataDir '/lookup.mat'], 'lookup');
end
