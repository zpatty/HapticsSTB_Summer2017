%This class is used to create objects for each trial with the listed
%properties

classdef STBData < handle
	
	properties
		subj_id % subject number (eg. 1-30)
		task_id % task number (eg. 1-9)
		forces % 3 axis matrix of forces
		moments % 3 axis matrix of moments
		acc1 % 3 axis matrix of accelerations for each accelerometer
		acc2
		acc3
        pos % programmed posistion of servo motor
        mag % scalar magnitude of forces
		duration % time of the trial
		plot_time % 
        act_time
        video_time
		time 
        index
        filename
        youtube
        youtube_short
        score
        rater
        fam
        trialnum
        group_id % experiment group
        phase % phase of the trial
        haptic
	end

	methods 
        % initialize object, dataDir is the directory containing the data
        % 
		function obj = STBData(dataDir, varargin)
			if nargin ~= 0 % makes sure there is an argument
                
	            subjectDirs = dir([dataDir '/sub*']); % gets a list of subject directories in the data directory
	            subjFound = obj.findSubj(subjectDirs); % extracts subject numbers
	            nTrials = zeros(length(subjectDirs),1); % initializes vector nx1 where n is the number of trials

	            p = inputParser; % input arguments and parser
                p.addOptional('task', 1:9, @(x) all(ismember(x, [1 2 3 4 5 6 7 8 9])));
                p.addOptional('subject', subjFound, @(x) all(ismember(x, subjFound)));
                p.addOptional('group',1:2, @(x) all(ismember(x, [1 2])));
                p.parse(varargin{:});
                inputs = p.Results;

                subjectDirs = subjectDirs(ismember(subjFound, inputs.subject)); % chooses only the subjects specified in the optional input
                
                % loop to obtain the number of trials
	            for i = 1:length(subjectDirs)
	            	nTrials(i) = length(dir([dataDir '/' subjectDirs(i).name '/*.mat'])); 
                end

	            obj(sum(nTrials)) = STBData(); % instantiates an object for each trial

	            k = 1;
                % loop through each subject
                for i = 1:length(subjectDirs)
	            	trialFiles = dir([dataDir '/' subjectDirs(i).name  '/*.mat']); % pull the trial file names
                    disp(subjectDirs(i).name); 
                    % loop through each trial
					for j = 1:length(trialFiles)
						if any(ismember(str2double(trialFiles(j).name(10)),inputs.task)) % only looks at specified tasks
		            		disp(['Loading: ' trialFiles(j).name]) 
		            		% Load rawData, rating(not recorded yet) and
		            		% youtube address from .mat
                            trialOrd = sort({trialFiles.name}); % sort by trial order
                            % loading and updating properties
                            load([dataDir '/' subjectDirs(i).name '/' trialOrd{j}], 'rawData', 'youtube', 'youtube_short', 'score', 'rater','video_time');
                            
                            %setting the properties
                            obj(k).filename = [dataDir '/' subjectDirs(i).name '/' trialFiles(j).name]; 
                            obj(k).youtube = youtube; 
                            obj(k).youtube_short = youtube_short;  
		                    obj(k).forces = rawData(:,1:3); %#ok<NODEF>
		                    obj(k).moments = rawData(:,4:6);
		                    obj(k).acc1 = rawData(:,7:9);
		                    obj(k).acc2 = rawData(:,10:12);
		                    obj(k).acc3 = rawData(:,13:15);
                            obj(k).pos  = rawData(:,16);
                            obj(k).mag  = rawData(:,17);
		                    obj(k).duration = (size(rawData,1)-1)/16.73;
		                    obj(k).plot_time = (0:size(rawData,1)-1)/16.73;
                            obj(k).act_time = (find(obj(k).mag>0.1,1,'last') - find(obj(k).mag>0.1, 1))/16.73;
                            obj(k).video_time = video_time;

		                    obj(k).time = datetime(trialFiles(j).name(13:end-4), 'InputFormat', 'MM-dd_HH-mm');

		                    obj(k).subj_id = str2double(trialFiles(j).name(2:4));
		                    obj(k).task_id = str2double(trialFiles(j).name(10));
	                        
                            obj(k).score = score;
                            obj(k).rater = rater;
                            
                            
                            obj(k).trialnum = str2double(trialFiles(j).name(10));
                            
                            % manual truncation of file
%                             if obj(k).subj_id==10 & obj(k).task_id==1
%                                 trunc = find(obj(k).plot_time>obj(k).video_time,1,'first');
%                                 rawData = rawData(1:trunc,:);
%                                 obj(k).forces = rawData(:,1:3); %#ok<NODEF>
%                                 obj(k).moments = rawData(:,4:6);
%                                 obj(k).acc1 = rawData(:,7:9);
%                                 obj(k).acc2 = rawData(:,10:12);
%                                 obj(k).acc3 = rawData(:,13:15);
%                                 obj(k).pos  = rawData(:,16);
%                                 obj(k).mag  = rawData(:,17);
%                                 obj(k).duration = (size(rawData,1)-1)/16.73;
%                                 obj(k).plot_time = (0:size(rawData,1)-1)/16.73;
%                                 obj(k).act_time = (find(obj(k).mag>0.1,1,'last') - find(obj(k).mag>0.1, 1))/16.73;
%                                 obj(k).video_time = video_time;
%                             end
                                
                            % group and phase property assignment
                            
                                if ismember(obj(k).subj_id,[1,3,5,7,8,10,11])
                                    obj(k).group_id = 0;
                                    if ismember(obj(k).task_id,[1,2,3])
                                        obj(k).phase = 1;
                                    elseif ismember(obj(k).task_id,[4,5,6])
                                        obj(k).phase = 2;
                                    elseif ismember(obj(k).task_id,[7,8,9])
                                        obj(k).phase = 3;
                                    end
                                elseif ismember(obj(k).subj_id,[2,4,6,9,12,13])
                                    obj(k).group_id = 0;
                                    if ismember(obj(k).task_id,[1,2,3,4])
                                        obj(k).phase = 1;
                                    elseif ismember(obj(k).task_id,[5,6,7])
                                        obj(k).phase = 2;
                                    elseif ismember(obj(k).task_id,[8,9])
                                        obj(k).phase = 3;
                                    end
                                end
                            
                            % haptics or no haptics
                            if ismember(obj(k).phase, [1,3])
                                obj(k).haptic = 0;
                            elseif ismember(obj(k).phase,2)
                                obj(k).haptic = 1;
                            end
                            
                            
                            obj(k).index = k;
                            
                            k = k +1;
                            
                            clear rawData youtube youtube_short score rater
                        else
                            disp('error')
                        end
					end
                end
                obj(k:end) = [];
			end
        end
        
        % method to index by subject ID (see STBDataExamples)
		function val = subject(obj, subjDes)
			if (isequal(size(obj), [1 1]) || nargin == 1)
				val = [obj.subj_id];
			else
				val = obj([obj.subj_id] == subjDes);
			end
        end
        
        % method to index by task ID
		function val = task(obj, taskDes)
			if (isequal(size(obj), [1 1]) || nargin == 1)
				val = [obj.task_id];
			else
				val = obj([obj.task_id] == taskDes);
			end
        end
        
        % method to index by Trial ID
        function val = trial(obj, trialDes)
            if (isequal(size(obj), [1 1]) || nargin == 1)
                val = [obj.trialnum];
            else
                val = obj([obj.trialnum] == trialDes);
            end
        end
        
        % method to index by group ID
        function val = group(obj,groupDes)
            if (isequal(size(obj), [1 1]) || nargin == 1)
                val = [obj.group_id];
            else
                val = obj([obj.group_id] == groupDes);
            end
        end
        
        % method to extract the subject number from the directory name
        function subjects = findSubj(~, subjectDirs)
        	subjects = zeros(size(subjectDirs));
            for i = 1:length(subjects)
        		subjects(i) = str2double(subjectDirs(i).name(end-2:end));
            end
        	subjects = sort(subjects);
        end
    
        plotMom(obj, range)
        plotForces(obj, range)
        plotAcc(obj, arg1, arg2)
        newObj = range(rangeIdx)

    end

end