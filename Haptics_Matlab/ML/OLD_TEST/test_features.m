clearvars;
close all;
load features;
load results;

fields = fieldnames(features);
novice = sum(ratings,2) < median(sum(ratings,2));
expert = ~novice;

for i = 1:length(fields)
    cf = [features.(fields{i})]';

    for j = 1:length(features(1).(fields{i}))
        figure(1);clf;hold on;
        for k = 1:5
            subplot(5,1,k); hold on
            scatter(ratings(novice,k), cf(novice,j));
            scatter(ratings(expert,k), cf(expert,j));            
        end
        fprintf('Feature: %s, Column: %d\n', fields{i}, j)
        pause
    end
end
