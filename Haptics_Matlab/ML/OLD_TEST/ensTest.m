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
ratings = ratings+1;

kerr = zeros(80,1);
for k = 1:1    
for fold = 1:n

    feature_train = feature_vector(part ~= fold,:);
    ratings_train = ratings(part ~= fold,:);
    
    %% standardize data for svr
    [X, muX, sigmaX] = zscore(feature_train);  
    coefs = pca(X);
    Xpca = X*coefs;
    Xpca = Xpca(:,1:k);
    % Build separate models for each grading metric
    nMetric = size(ratings, 2);
    models = cell(1,nMetric);

    b = mnrfit(feature_train, ratings_train);
    model = svmtrain(ratings_train, Xpca, '-s 1 -t 2 -b 1 -q');
    %% predict labels for test data
    feature_test = feature_vector(part == fold,:);
    ratings_test = ratings(part == fold,:);

    Xtest = bsxfun(@rdivide,bsxfun(@minus, feature_test, muX), sigmaX); 
    Xtest(isnan(Xtest)) = 0;
    XtestPca = Xtest*coefs;
    XtestPca = XtestPca(:,1:k);
    
    lrprob = mnrval(b, XtestPca);
    [predicted_label, accuracy, svmprob] = svmpredict(ratings_test, XtestPca, model, '-b 1 -q'); 

    [~, predictions] = max((lrprob + svmprob)/2, [], 2);
    [~, lrpredictions] = max(lrprob, [], 2);
%     predictions(predictions == 1) = -1;
%     predictions(predictions == 2) = 1;
    
    pred(part == fold) = predictions;
    err(fold) = mean(predictions ~= ratings_test);
    lrerr(fold) = mean( lrpredictions ~= ratings_test);
    svmerr(fold) = mean(predicted_label ~= ratings_test);
end

kerr(k) = mean(err);
klrerr(k) = mean(lrerr);
ksvmerr(k) = mean(svmerr);
disp(kerr(k));
preds(:,end+1) = pred;

end

figure(1);
clf;
plot(kerr,'bo');
hold on;
plot(klrerr,'rx');
plot(ksvmerr,'g+');

figure(2);
clf;
[rsort, idx] = sort(ratings);
[~, maxidx] = min(kerr(1:k));
plot(rsort,'bo')
hold on
plot(preds(idx, maxidx), 'rx');
