% This is a function to sort participants into relatively even groups based
% on average force in the first two trials.

function group = whichGroup(sub)

loadSubjectData('RawData', 'SavedData', sub); % convert csv to mat files

data = STBData('SavedData'); % create objects for tasks
group1=[]; 
group2=[];


for i = 3:sub
    % calculate average force through two trials for each participant
    average_mag(i) = mean([mean(data.subject(i).trial(1).mag) mean(data.subject(i).trial(2).mag)]);
    % set subject 1 to group 1 and subject 2 to group 2
    if sub ~=1 && sub ~= 2
            data.subject(1).trial(1).group_id = 1;
            group(1)=1;
            group1(1)= mean([mean(data.subject(1).trial(1).mag) mean(data.subject(1).trial(2).mag)]);
            data.subject(2).trial(1).group_id = 2;
            group(2)=2;
            group2(1) = mean([mean(data.subject(2).trial(1).mag) mean(data.subject(2).trial(2).mag)]);
        
        
    if abs(length(group1)-length(group2)) <= 2 % if difference between groups is small
        
        % these cases determine where to put the subject based on average
        % force and the relative average force of the groups
        if mean(group1) > mean(group2) && average_mag(i) > mean(group2) 
                data.subject(i).trial(1).group_id = 2;
                group(i)= 2;
        elseif mean(group1) > mean(group2) && average_mag(i) < mean(group2)
                data.subject(i).trial(1).group_id = 1;
                group(i)=1;
        elseif mean(group1) < mean(group2) && average_mag(i) < mean(group1)
                data.subject(i).trial(1).group_id = 2;
                group(i)=2;
        elseif mean(group1) < mean(group2) && average_mag(i) > mean(group1)
                data.subject(i).trial(1).group_id = 1;
                group(i)=1;
        else
            disp('error');
        end
    else
        % if the difference between groups is large, subject is
        % automatically placed in the smaller group regardless of relative
        % forces
        if length(group1) > length(group2)
                data.subject(i).trial(1).group_id = 2;
                group(i)=2;
        else
                data.subject(i).trial(1).group_id = 1;
                group(i)=1;
        end
    end
    % creates arrays of average forces for each subject and separates 
        if data.subject(i).trial(1).group_id == 1
            group1(end+1) = average_mag(i);
        elseif data.subject(i).trial(1).group_id == 2
            group2(end+1) = average_mag(i);
        end
%         
    end
end

disp(mean(group1))
disp(mean(group2))
