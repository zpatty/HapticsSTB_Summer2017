%% support vector regression test (from Sarah) converted for the STB data
function ensembleTestSelectFeatures(rounding,part,loocv,time)
    tic
    clearvars -except rounding loocv part time;
    addpath('LIBSVM');
    addpath('glmnet_matlab');
    xvalfile = strcat('test_part',time,'.mat');
    cvpartfile = strcat('cvpart',time,'.mat');

    if ~exist('SelectFeatures.mat','file')
        error('Quitting EnsembleTest. Please run FeatureSelection.m')
    else
        % If a features.mat file exists, load that instead
        disp('Loading Features...')
        load features.mat;
        load SelectFeatures.mat;
    end

%     Load partition to split data into test and validation sets
    if part == 1
        if exist(xvalfile,'file')
            load(xvalfile)
            test_part = subTestInd;
        else
            [subTest,subTestInd,subTrain,subTrainInd] = make_subject_partition(4);
            test_part = subTestInd;
            save(strcat('test_part',time,'.mat'),'subTest','subTestInd','subTrain','subTrainInd')
        end
        
         % Split dataset into testing and validation
        features_val = features(test_part);
        features = features(~test_part);

        % Create xval partition for testing set
        if loocv
            n = length(features);
        else
            n = 10;
        end
        part = make_xval_partition(length(features), n);

        preds = [];
        [feature_vector, ratings] = featureVector(features);
    elseif part == 0
        if exist(cvpartfile,'file')
            load(cvpartfile)
        else
            cvpart = make_cv_partition(features)
            save(strcat('cvpart',time,'.mat'),'cvpart')
        end
    end
        
    
    if rounding
%         ratings = round(ratings);
        ratings = floor(ratings);
    end
    
%     nMetric = size(ratings, 2);
    nMetric = 5;
    models = cell(1,nMetric);

    for i = 1:nMetric;
        if part == 0 
            test_part = test(cvpart{i});
            features_val = features(test_part);
            features = features(~test_part);
            if loocv
            n = length(features);
            else
                n = 10;
            end
            part = make_xval_partition(length(features), n);

            preds = [];
            [feature_vector, ratings] = featureVector(features);
        end
        
        for fold = 1:n
        fprintf('Fold %03d: ', fold);

        % Build separate models for each grading metri

%         for i = 1:nMetric;
                
            selectfeature_vector = feature_vector(:,selectFeatures{i});
            feature_train = selectfeature_vector(part ~= fold,:);
            ratings_train = ratings(part ~= fold,:);
            % standardize data for svr
            [X, muX, sigmaX] = zscore(feature_train);  
            fprintf('Metric %d ...', i);
            y = ratings_train(:,i); 
            % LIBSVM SVR
            models1{i} = svmtrain(y, X, '-s 3 -t 2 -q'); 
            % Elastic net using GLMNET
            models2{i} = cvglmnet(X,y, 'gaussian');
            % Regression tree
            models3{i} = fitrtree(X, y);
            % KNN 
            models4{i} = fitcknn(X,y,'NumNeighbors',3);
            fprintf(repmat('\b', 1, 12));
%         end


%         for i = 1:nMetric

            selectfeature_vector = feature_vector(:,selectFeatures{i});
            % split out testing trials
            feature_test = selectfeature_vector(part == fold,:);
            ratings_test = ratings(part == fold,:);
            predictions = zeros(size(feature_test,1), nMetric);
            feature_train = selectfeature_vector(part ~= fold,:);
            [X, muX, sigmaX] = zscore(feature_train); 

            % Standardize training data
            Xtest = bsxfun(@rdivide,bsxfun(@minus, feature_test, muX), sigmaX); 
            Xtest(isnan(Xtest)) = 0;

            [predicted_label1, accuracy, prob_estimates] = svmpredict(ratings_test(:,i), Xtest, models1{i},'-q');
            predicted_label2 = cvglmnetPredict(models2{i}, Xtest, 'lambda_1se');
            predicted_label3 = predict(models3{i}, Xtest);
            predicted_label4 = predict(models4{i}, Xtest);
            predictions1(:,i) = predicted_label1
            predictions2(:,i) = predicted_label2;
            predictions3(:,i) = predicted_label3;
            predictions4(:,i) = predicted_label4;
%         end

        pred1(part == fold,i) = predictions1;
        pred2(part == fold,i) = predictions2;
        pred3(part == fold,i) = predictions3;
        pred4(part == fold,i) = predictions4;
        fprintf(repmat('\b', 1, 10));
        predictions1 = [];
        predictions2 = [];
        predictions3 = [];
        predictions4 = [];
        predictions5 = [];
        end
    end
    toc
    % Average predictions together
    pred = (pred1 + pred2 + pred3 + pred4)/4;
    pred(isnan(pred)) = 1;

    TotThresh = 3;
    fprintf('Total Err: \n');
    fprintf('Ensemble: ');
    check_err(pred, ratings, TotThresh);
    fprintf('SVR: ');
    check_err(pred1, ratings, TotThresh);
    fprintf('CVGLMNET: ');
    check_err(pred2, ratings, TotThresh);
    fprintf('Regression Tree: ');
    check_err(pred3, ratings, TotThresh);
    fprintf('KNN: ');
    check_err(pred4, ratings, TotThresh);

    IndThresh = 1;
    fprintf('Ensemble Metric Error: \n');
    fprintf('Depth Perception: ');
    check_err(pred(:,1), ratings(:,1), IndThresh);
    fprintf('Bimanual Dexterity: ');
    check_err(pred(:,2), ratings(:,2), IndThresh);
    fprintf('Efficiency: ');
    check_err(pred(:,3), ratings(:,3), IndThresh);
    fprintf('Force Sensitivity: ');
    check_err(pred(:,4), ratings(:,4), IndThresh);
    fprintf('Robotic Control: ');
    check_err(pred(:,5), ratings(:,5), IndThresh);

    % Run entire testing dataset against validation set
    

    for i = 1:nMetric;
        if part == 0 
            test_part = test(cvpart{i});
            features_val = features(test_part);
            features = features(~test_part);
            [feature_vector, ratings] = featureVector(features);
        end
        [X, muX, sigmaX] = zscore(feature_vector(:,selectFeatures{i}));
        y = ratings(:,i); 
        models1{i} = svmtrain(y, X, '-s 3 -q'); 
        models2{i} = cvglmnet(X, y, 'gaussian');
        models3{i} = fitrtree(X, y);
        models4{i} = fitcknn(X,y,'NumNeighbors',3);
    end
    
    if rounding
%         ratings_val = round(ratings_val);
        ratings_val = floor(ratings_val);
    end
    
    for i = 1:nMetric
        if part == 0 
            test_part = test(cvpart{i});
            features_val = features(test_part);
            features = features(~test_part);
            [feature_vector, ratings] = featureVector(features);
        end
        [feature_val_vec, ratings_val] = featureVector(features_val);
        selectfeature_val_vec = feature_val_vec(:,selectFeatures{i});
        [X, muX, sigmaX] = zscore(feature_vector(:,selectFeatures{i}));
        Xtest = bsxfun(@rdivide,bsxfun(@minus, selectfeature_val_vec, muX), sigmaX); 
        Xtest(isnan(Xtest)) = 0;
        [pred_val1(:,i), accuracy, prob_estimates] = svmpredict(ratings_val(:,i), Xtest, models1{i},'-q');
        pred_val2(:,i) = cvglmnetPredict(models2{i}, Xtest, 'lambda_1se');
        pred_val3(:,i) = predict(models3{i}, Xtest);
        pred_val4(:,i) = predict(models4{i}, Xtest);
    end

    pred_val = (pred_val1 + pred_val2 + pred_val3 + pred_val4)/4;
    pred_val(isnan(pred_val)) = 1;

    fprintf('Final Error: \n');
    fprintf('Ensemble: ');
    check_err(pred_val, ratings_val, IndThresh);
    fprintf('Depth Perception: ');
    check_err(pred_val(:,1), ratings_val(:,1), IndThresh);
    fprintf('Bimanual Dexterity: ');
    check_err(pred_val(:,2), ratings_val(:,2), IndThresh);
    fprintf('Efficiency: ');
    check_err(pred_val(:,3), ratings_val(:,3), IndThresh);
    fprintf('Force Sensitivity: ');
    check_err(pred_val(:,4), ratings_val(:,4), IndThresh);
    fprintf('Robotic Control: ');
    check_err(pred_val(:,5), ratings_val(:,5), IndThresh);

    figure(1);clf;
    plot_pred(pred, ratings);

    figure(2);clf;
    plot_pred(pred_val, ratings_val);

    if rounding
        fileround = 'Round';
    else
        fileround = '';
    end
    
    if loocv
        fileloocv = 'LOOCV';
    else
        fileloocv = '10Fold';
    end

    save(strcat('resultsSQRTLogPCA',fileround,fileloocv,'Select',time,'.mat'), 'ratings', 'ratings_val', ...
        'models1','models2','models3','models4',...
        'pred_val', 'pred_val1', 'pred_val2', 'pred_val3', 'pred_val4',...
        'pred', 'pred1', 'pred2', 'pred3', 'pred4');
end
