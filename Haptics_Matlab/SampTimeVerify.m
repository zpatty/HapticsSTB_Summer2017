%%%%%%% This code is used to investigate what the sample time was for the
%%%%%%% data files, since the sample rate has been slowed down by the servo
%%%%%%% I/O

clear all; close all;

data = STBData('SavedData','subject',3:13);
data = data(~cellfun(@(x)any(ismember(x(:),4)), {data.subj_id}));

for i=1:length(data)
    SampRate(i) = length(data(i).plot_time)/data(i).video_time;
end