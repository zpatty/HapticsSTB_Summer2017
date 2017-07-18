%%%%%% Using this m-file to try and understand why the forces from GroupB
%%%%%% are systematically lower than those from GroupA

clear all; close all;

data = STBData('SavedData','subject',3:13);
data = data(~cellfun(@(x)any(ismember(x(:),4)), {data.subj_id}));

GrpA = data.group(1);
GrpB = data.group(2);

CreateFig
for i = 1:9
    j = randi(length(data));
    hold on
    plot(data(j).mag,'r')
    plot(sqrt(sum(data(j).forces.^2,2)),'ob')
    sprintf('Subject %d, Trial %d, Group %d',data(j).subj_id,data(j).task_id,data(j).group_id)
    pause;
    cla
end 


%%

clear all; close all;

data = STBData('SavedData','subject',3:13);
data = data(~cellfun(@(x)any(ismember(x(:),4)), {data.subj_id}));

GrpA = data.group(1);
GrpB = data.group(2);

h1 = CreateFig;
for i = 1:length(GrpA)
    plot(GrpA(i).forces);
    hold on
end
xlim([0 7000]);ylim([-10 6]);
PrintFig(h1,'RawFigs/GroupA_ForceXYZ','pdf')

h2 = CreateFig;
for i = 1:length(GrpB)
    plot(GrpB(i).forces);
    hold on
end
xlim([0 7000]);ylim([-10 6]);
PrintFig(h2,'RawFigs/GroupB_ForceXYZ','pdf')



