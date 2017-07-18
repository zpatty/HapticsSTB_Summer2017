%% support vector regression test (from Sarah) converted for the STB data

clearvars;
addpath('lib2');


if ~exist('features.mat','file')
    data = STBData('SavedData');
    
    num = xlsread('DemographicSurvey.xls');
    subjects = num(1:end, 5);
    fam = num(1:end, 11);
    
    for i = 1:length(data)
        data(i).fam = fam(subjects==data(i).subj_id);
    end
    
    disp('Extracting Features...')
    features = staticFeatures(data);
    save('features.mat', 'features');
else
    disp('Loading Features...')
    load features.mat;
end

%% obtain feature and rating matrices

n = 10;
part = make_xval_partition(length(features), n);

err = zeros(n,1);
pred = zeros(length(features),1);
preds = [];
[feature_vector, ratings] = featureVector(features);
ratings = double(ratings > 2.5);
feature_vector = zscore(feature_vector);
for t = 1:50
    err = [];
for fold = 1:10
    feature_train = feature_vector(part ~= fold,:);
    ratings_train = ratings(part ~= fold,:); 

    %% predict labels for test data
    feature_test = feature_vector(part == fold,:);
    ratings_test = ratings(part == fold,:);
    
    predictions = round(knn_test(t,feature_train, ratings_train, feature_test));
    
    pred(part == fold) = predictions;
    err(end+1) = mean(predictions ~= ratings_test);
%     err(end+1) = sqrt(mean((predictions- ratings_test).^2));
%     acc(end+1) = mean(predictions- ratings_test);
end

disp(mean(err))
terr(t) = mean(err);
preds(:,end+1) = pred;
end

figure(1);
clf;
plot(terr,'bo');

figure(2);
clf;
[rsort, idx] = sort(ratings);
[~, maxidx] = min(terr);
plot(rsort,'bo')
hold on
plot(preds(idx, maxidx), 'rx');
