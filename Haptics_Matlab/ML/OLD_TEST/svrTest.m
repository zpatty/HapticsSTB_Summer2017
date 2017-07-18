%% support vector regression test (from Sarah) converted for the STB data

clearvars;
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

% n = length(features);
n = 10;
part = make_xval_partition(length(features), n);

preds = [];
[feature_vector, ratings] = featureVector(features);
% ratings = round(ratings);
% ratings = sum(ratings, 2);
% ratings = ratings.^5;
% ratings = double(ratings >3.5);
pred = zeros(size(ratings));
feature_vector = feature_vector(:, var(feature_vector) > 10);
k = 10;
for fold = 1:n
    fprintf('Fold %02d: ', fold);

    feature_train = feature_vector(part ~= fold,:);
    ratings_train = ratings(part ~= fold,:);
    
    %% standardize data for svr
    [X, muX, sigmaX] = zscore(feature_train);  
    coefs = pca(X);
    Xpca = X*coefs;
    
    % Build separate models for each grading metric
    nMetric = size(ratings, 2);
    models = cell(1,nMetric);
%     disp('Training Models');

    opt = glmnetSet;
    opt.alpha = 0;
    for i = 1:nMetric;
        fprintf('Metric %d ...', i);
        y = ratings_train(:,i); 
        models{i} = svmtrain(y, X, '-s 3 -q'); 
%         models{i} = svmtrain(y, X, '-s 0 -t 2 -q'); 
%         models{i} = cvglmnet(X,y, 'gaussian',opt);
        fprintf(repmat('\b', 1, 12));
    end

    %% predict labels for test data
    feature_test = feature_vector(part == fold,:);
    ratings_test = ratings(part == fold,:);

    Xtest = bsxfun(@rdivide,bsxfun(@minus, feature_test, muX), sigmaX); 
    Xtest(isnan(Xtest)) = 0;
    XtestPca = Xtest*coefs;
    
%     disp('Making Prediction');
    predictions = zeros(size(feature_test,1), nMetric); 
    for i = 1:nMetric
%         [predicted_label, accuracy, prob_estimates] = svmpredict(ratings_test(:,i), XtestPca(:,1:k), models{i},'-q');
        [predicted_label, accuracy, prob_estimates] = svmpredict(ratings_test(:,i), Xtest, models{i},'-q');
%         predicted_label = cvglmnetPredict(models{i}, Xtest, 'lambda_min');
        predictions(:,i) = predicted_label;
    end
    pred(part == fold,:) = predictions;
%     err = mse(predictions, ratings_test)
    fprintf(repmat('\b', 1, 9));

end

err = mse(pred, ratings)
err2 = mse(ratings, mean(ratings(:))*ones(size(ratings)))

figure(1);clf;

for i = 1:size(pred,2)
subplot(size(pred,2),1,i);
[rPlot, idx] = sort(ratings(:,i));
plot(rPlot,'bo');
hold on;
plot( pred(idx,i),'rx')
plot(xlim, mean(pred(~isnan(pred(:,i)),i))*[1 1],'k');
ylim([0 1.1*rPlot(end)])
end


