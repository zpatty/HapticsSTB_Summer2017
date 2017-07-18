%%%% This file adds the variable video_time based on the recorded time from
%%%% the videos that were recorded. 

clear all; close all;

[~, ~, raw] = xlsread('RawDataDurations');
subj = cell2mat(raw(2:end,1));
video_time_matrix = cell2mat(raw(2:end,2:end));

for i = 1:length(subj)
    for j = 1:9
        data = STBData('SavedData','subject',subj(i),'task',j);
        video_time = video_time_matrix(i,j);
        save(data.filename, 'video_time','-append');
    end
end
