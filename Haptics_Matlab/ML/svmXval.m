function pred = svmXval(feature_vector, ratings)

n = length(feature_vector);
part = make_xval_partition(size(feature_vector,1), n);

pred = zeros(size(ratings));

for fold = 1:n
    
    feature_train = feature_vector(part ~= fold,:);
    ratings_train = ratings(part ~= fold,:);
    
    %% standardize data for svr
    [X, muX, sigmaX] = zscore(feature_train);  
    
    nMetric = size(ratings, 2);
    models = cell(1,nMetric);

    for i = 1:nMetric;
        y = ratings_train(:,i); 
        models{i} = svmtrain(y, X, '-s 3 -q'); 
    end

    %% predict labels for test data
    feature_test = feature_vector(part == fold,:);
    ratings_test = ratings(part == fold,:);

    Xtest = bsxfun(@rdivide,bsxfun(@minus, feature_test, muX), sigmaX); 
    Xtest(isnan(Xtest)) = 0;
    
    predictions = zeros(size(feature_test,1), nMetric); 
    for i = 1:nMetric
        [predicted_label, accuracy, prob_estimates] = svmpredict(ratings_test(:,i), Xtest, models{i},'-q');
        predictions(:,i) = predicted_label;
    end
    pred(part == fold,:) = predictions;
    
end
