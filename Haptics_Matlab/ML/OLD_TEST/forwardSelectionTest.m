%% support vector regression test (from Sarah) converted for the STB data

% clearvars;
addpath('lib2');
addpath('glmnet_matlab');

if ~exist('features.mat','file')
    data = STBData('SavedData', 'task', 1);
    data = data(~cellfun(@(x)any(isnan(x(:))), {data.score}));
    
    num = xlsread('DemographicSurvey.xls');
    subjects = num(1:end, 5);
    fam = num(1:end, 11);
    
    for i = 1:length(data)
        data(i).fam = fam(subjects==data(i).subj_id);
    end
    
    data = data(~cellfun(@isempty, {data.score}));
    
    disp('Extracting Features...')
    features = staticFeatures(data);
    save('features.mat', 'features');
else
    disp('Loading Features...')
    load features.mat;
    features = features(~cellfun(@isempty,{features.gears}));
end

%% obtain feature and rating matrices

preds = [];
kept_pred = [];
final_idx = {};
[feature_vector, ratings, index] = featureVector(features);
% % ratings = round(ratings);
% ratings = sum(ratings,2);

for metric = 1:size(ratings, 2)
    features_test = feature_vector;
    features_kept = [];
    kept_idx = zeros(size(features_test,2),1);
    j = 1;
    lastErr = 100;
    for f = 1:size(feature_vector,2)
        err = zeros(size(features_test,2),1);
        for i = 1:size(features_test,2)
            pred = svmXval([features_kept features_test(:,i)], ratings(:,metric));
            err(i) = norm(pred- ratings(:,metric),1);
        end
        [minErr, idx] = min(err);
        features_kept = [features_kept features_test(:,idx)];
        features_test(:,idx) = [];
        kept_idx(j) = idx;
        j = j+1;
        
        if minErr > lastErr
            break
        end
        lastErr = minErr;
        disp(f);
    end

    kept_idx(j:end) = [];
    final_idx{end+1} = kept_idx;
    kept_pred(:,metric) = svmXval(features_kept, ratings(:,metric));
end
figure(1);clf;


domains = {'Depth Perception', 'Bimanual Dexterity', 'Efficiency', 'Force Sensitivity', 'Robotic Control'};
nMetric = size(ratings,2);
for i = 1:nMetric
subplot(nMetric,1,i);

if (nMetric == 5);
    title(domains{i});
    hold on;
end

pred(:,i) = svmXval(feature_vector(:,final_idx{i}), ratings(:,i));
[rPlot, idx] = sort(ratings(:,i));
plot(rPlot,'bo');
hold on;
plot( pred(idx),'rx')
plot(xlim, mean(pred(~isnan(pred)))*[1 1],'k');
ylim([0 1.1*rPlot(end)]);

end

beep;
