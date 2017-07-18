%% support vector regression test (from Sarah) converted for the STB data
function ensembleTestSelectFeatures(rounding,TrainTest,loocv,time)
    tic
    clearvars -except rounding loocv TrainTest time;
    addpath('LIBSVM');
    addpath('glmnet_matlab');
    xvalfile = strcat('test_part',time,'.mat');
    cvpartfile = strcat('cvpart',time,'.mat');

    
    % If a features.mat file exists, load that instead
    disp('Loading Features...')
    if rounding == 0
        if ~exist('SelectFeaturesMed.mat','file')
            error('Quitting EnsembleTest. Please run FowardSelection.m')
        else
            load featuresMed.mat;
            load SelectFeaturesMed.mat;
        end
    elseif rounding == 1
        if ~exist('SelectFeaturesMean.mat','file')
            error('Quitting EnsembleTest. Please run FowardSelection.m')
        else
            load featuresMean.mat;
            load SelectFeaturesMean.mat;
        end
    end
%         load features.mat;
%         load SelectFeatures.mat;
  

%     Load partition to split data into test and validation sets
    if TrainTest == 1
        if exist(xvalfile,'file')
            load(xvalfile)
            test_part = subTestInd;
        else
            [subTest,subTestInd,subTrain,subTrainInd] = make_subject_partition(4);
            test_part = subTestInd;
            save(strcat('test_part',time,'.mat'),'subTest','subTestInd','subTrain','subTrainInd')
        end
        
         % Split dataset into testing and validation
        features_test = features(test_part);
        features_train = features(~test_part);

        % Create xval partition for testing set
        if loocv
            n = length(features_train);
        else
            n = 10;
        end
        part = make_xval_partition(length(features_train), n);

        preds = [];
        [feature_vector_train, ratings_train] = featureVector(features_train);
    elseif TrainTest == 0
        if exist(cvpartfile,'file')
            load(cvpartfile)
        else
            cvpart = make_cv_partition(features_train);
            save(strcat('cvpart',time,'.mat'),'cvpart')
        end
    end
        
    
%     if rounding == 1
% %         ratings = round(ratings);
%         ratings_train = floor(ratings_train);
%     end
    
%     nMetric = size(ratings, 2);
    nMetric = 5;
    models = cell(1,nMetric);

    for i = 1:nMetric;
        if TrainTest == 0 
            test_part = test(cvpart{i});
            features_test = features(test_part);
            features_train = features(~test_part);
            if loocv
            n = length(features_train);
            else
                n = 10;
            end
            part = make_xval_partition(length(features_train), n);

            preds = [];
            [feature_vector_train, ratings_train] = featureVector(features_train);
        end
        
        for fold = 1:n
        fprintf('Fold %03d: ', fold);
        
        if rounding == 1
    %         ratings = round(ratings);
            ratings_train = floor(ratings_train);
        end

        % Build separate models for each grading metri

%         for i = 1:nMetric;
                
            selectfeature_vector_train = feature_vector_train(:,selectFeatures{i});
            selectfeatures_train = selectfeature_vector_train(part ~= fold,:);
            selectratings_train = ratings_train(part ~= fold,:);
            % standardize data for svr
            [X, muX, sigmaX] = zscore(selectfeatures_train);  
            fprintf('Metric %d ...', i);
            y = selectratings_train(:,i); 
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

%             selectfeature_vector = feature_vector(:,selectFeatures{i});
            % split out testing trials
            selectfeatures_test = selectfeature_vector_train(part == fold,:);
            selectratings_test = ratings_train(part == fold,:);
            predictions = zeros(size(selectfeatures_test,1), nMetric);
%             feature_train = selectfeature_vector(part ~= fold,:);
%             [X, muX, sigmaX] = zscore(feature_train); 

            % Standardize training data
            Xtest = bsxfun(@rdivide,bsxfun(@minus, selectfeatures_test, muX), sigmaX); 
            Xtest(isnan(Xtest)) = 0;

            [predicted_label1, accuracy, prob_estimates] = svmpredict(selectratings_test(:,i), Xtest, models1{i},'-q');
            predicted_label2 = cvglmnetPredict(models2{i}, Xtest, 'lambda_1se');
            predicted_label3 = predict(models3{i}, Xtest);
            predicted_label4 = predict(models4{i}, Xtest);
            predictions1 = predicted_label1;
            predictions2 = predicted_label2;
            predictions3 = predicted_label3;
            predictions4 = predicted_label4;
%         end

        pred_train1(part == fold,i) = predictions1;
        pred_train2(part == fold,i) = predictions2;
        pred_train3(part == fold,i) = predictions3;
        pred_train4(part == fold,i) = predictions4;
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
    pred_train = (pred_train1 + pred_train2 + pred_train3 + pred_train4)/4;
    pred_train(isnan(pred_train)) = 1;

%     TotThresh = 3;
%     fprintf('Total Err: \n');
%     fprintf('Ensemble: ');
%     check_err(pred, ratings, TotThresh);
%     fprintf('SVR: ');
%     check_err(pred1, ratings, TotThresh);
%     fprintf('CVGLMNET: ');
%     check_err(pred2, ratings, TotThresh);
%     fprintf('Regression Tree: ');
%     check_err(pred3, ratings, TotThresh);
%     fprintf('KNN: ');
%     check_err(pred4, ratings, TotThresh);
% 
%     IndThresh = 1;
%     fprintf('Ensemble Metric Error: \n');
%     fprintf('Depth Perception: ');
%     check_err(pred(:,1), ratings(:,1), IndThresh);
%     fprintf('Bimanual Dexterity: ');
%     check_err(pred(:,2), ratings(:,2), IndThresh);
%     fprintf('Efficiency: ');
%     check_err(pred(:,3), ratings(:,3), IndThresh);
%     fprintf('Force Sensitivity: ');
%     check_err(pred(:,4), ratings(:,4), IndThresh);
%     fprintf('Robotic Control: ');
%     check_err(pred(:,5), ratings(:,5), IndThresh);

    % Run entire testing dataset against validation set
    

    for i = 1:nMetric;
        if TrainTest == 0 
            test_part = test(cvpart{i});
            features_test = features(test_part);
            features_train = features(~test_part);
            [feature_vector_train, ratings_train] = featureVector(features_train);
        end
        [X, muX, sigmaX] = zscore(feature_vector_train(:,selectFeatures{i}));
        y = ratings_train(:,i); 
        models1{i} = svmtrain(y, X, '-s 3 -q'); 
        models2{i} = cvglmnet(X, y, 'gaussian');
        models3{i} = fitrtree(X, y);
        models4{i} = fitcknn(X,y,'NumNeighbors',3);
    end
    
%     if rounding
% %         ratings_val = round(ratings_val);
%         ratings_test = floor(ratings_test);
%     end
    
    for i = 1:nMetric
        if TrainTest == 0 
            test_part = test(cvpart{i});
            features_test = features(test_part);
            features_train = features(~test_part);
            [feature_vector_train, ratings_train] = featureVector(features_train);
        end
        [feature_vector_test, ratings_test] = featureVector(features_test);
        if rounding
    %         ratings_val = round(ratings_val);
            ratings_test = floor(ratings_test);
        end
        selectfeature_vector_test = feature_vector_test(:,selectFeatures{i});
        [X, muX, sigmaX] = zscore(feature_vector_train(:,selectFeatures{i}));
        Xtest = bsxfun(@rdivide,bsxfun(@minus, selectfeature_vector_test, muX), sigmaX); 
        Xtest(isnan(Xtest)) = 0;
        [pred_test1(:,i), accuracy, prob_estimates] = svmpredict(ratings_test(:,i), Xtest, models1{i},'-q');
        pred_test2(:,i) = cvglmnetPredict(models2{i}, Xtest, 'lambda_1se');
        pred_test3(:,i) = predict(models3{i}, Xtest);
        pred_test4(:,i) = predict(models4{i}, Xtest);
    end

    pred_test = (pred_test1 + pred_test2 + pred_test3 + pred_test4)/4;
    pred_test(isnan(pred_test)) = 1;

%     fprintf('Final Error: \n');
%     fprintf('Ensemble: ');
%     check_err(pred_val, ratings_val, IndThresh);
%     fprintf('Depth Perception: ');
%     check_err(pred_val(:,1), ratings_val(:,1), IndThresh);
%     fprintf('Bimanual Dexterity: ');
%     check_err(pred_val(:,2), ratings_val(:,2), IndThresh);
%     fprintf('Efficiency: ');
%     check_err(pred_val(:,3), ratings_val(:,3), IndThresh);
%     fprintf('Force Sensitivity: ');
%     check_err(pred_val(:,4), ratings_val(:,4), IndThresh);
%     fprintf('Robotic Control: ');
%     check_err(pred_val(:,5), ratings_val(:,5), IndThresh);

    figure(1);clf;
    plot_pred(pred_train, ratings_train);

    figure(2);clf;
    plot_pred(pred_test, ratings_test);

    if rounding == 0
        fileround = 'Med';
    elseif rounding == 1
        fileround = 'Floor';
    end
    
    if TrainTest == 0
        filepart = 'CVPart';
    elseif TrainTest == 1
        filepart = 'SubPart';
    end
    
%     if loocv
%         fileloocv = 'LOOCV';
%     else
%         fileloocv = '10Fold';
%     end

    save(strcat('RegEnsembleSelect',fileround,filepart,time,'.mat'), 'ratings_train', 'ratings_test', ...
        'models1','models2','models3','models4',...
        'pred_test', 'pred_test1', 'pred_test2', 'pred_test3', 'pred_test4',...
        'pred_train', 'pred_train1', 'pred_train2', 'pred_train3', 'pred_train4');
end
