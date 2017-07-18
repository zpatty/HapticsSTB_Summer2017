function group = whichGroupOld(sub)

data = STBData('SavedData_backup');
group1=[];
group2=[];
for i = 5:sub
    average_mag(i) = mean([mean(data.subject(i).trial(1).mag) mean(data.subject(i).trial(2).mag)]);
    if sub ~=3 && sub ~= 4
            data.subject(3).trial(1).group_id = 1;
            group(3)=1;
            group1(1)= mean([mean(data.subject(3).trial(1).mag) mean(data.subject(3).trial(2).mag)]);
            data.subject(4).trial(1).group_id = 2;
            group(4)=2;
            group2(1) = mean([mean(data.subject(4).trial(1).mag) mean(data.subject(4).trial(2).mag)]);
        
        
    if abs(length(group1)-length(group2)) <= 2
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
        if length(group1) > length(group2)
                data.subject(i).trial(1).group_id = 2;
                group(i)=2;
        else
                data.subject(i).trial(1).group_id = 1;
                group(i)=1;
        end
    end
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
