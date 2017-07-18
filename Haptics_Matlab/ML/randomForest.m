%% support vector regression test (from Sarah) converted for the STB data
function [model,ErrTrain,Err_val,Pred,Pred_val,ratings,ratings_val] = randomForest(rounding,Xval,metric,leaf,nTrees)
    clearvars -except rounding Xval metric leaf nTrees;

    if ~exist('SelectFeatures.mat','file')
        error('Quitting EnsembleTest. Please run FeatureSelection.m')
    else
        % If a features.mat file exists, load that instead
        disp('Loading Features...')
        load features.mat;
        load SelectFeatures.mat;
    end

    % Load partition to split data into test and validation sets
    if xVal
        [subTest,subTestInd,subTrain,subTrainInd] = make_subject_partition(2);
        test_part = subTestInd;
    else
        if exist('test_part.mat','file')
                load test_part.mat
            else
                test_part = make_xval_partition(length(features), 10);
                test_part = test_part == 10;
        end
    end

    % Split dataset into testing and validation
    features_val = features(test_part);
    features = features(~test_part);

    % Create xval partition for testing set
   
    [feature_vector, ratings] = featureVector(features);
    
    if rounding
        ratings = round(ratings);
    end
    

        % Build separate models for each grading metric
%         nMetric = size(ratings, 2);
        nMetric = 1;
        models = cell(1,nMetric);

%         for i = 1:nMetric;
            [X, muX, sigmaX] = zscore(feature_vector);  
            fprintf('Metric %d ...', metric);
            y = ordinal(ratings(:,metric));
            rng(9876,'twister');
            savedRng = rng; % save the current RNG settings
            
            for ii = 1:length(leaf)
               % Reinitialize the random number generator, so that the
               % random samples are the same for each leaf size
               rng(savedRng);
               % Create a bagged decision tree for each leaf size and plot out-of-bag
               % error 'oobError'
               b = TreeBagger(nTrees,X,Y,'OOBPred','on',...
                                         'CategoricalPredictors',6,...
                                         'MinLeaf',leaf(ii));
               plot(b.oobError,color(ii));
               hold on;
            end
            model = TreeBagger(nTrees, X, y, 'Prior', 'Empirical','OOBPred','On','OOBVarImp','On');
            
            figure(i)
            oobErrorBaggedEnsemble = oobError(model{i});
            plot(oobErrorBaggedEnsemble)
            xlabel 'Number of grown trees';
            ylabel 'Out-of-bag classification error';

            
            
            predicted_label = predict(model{i},X);
            ErrTrain(:,i) = error(model{i},X,ratings(:,i));
            Pred(:,i) = predicted_label;
            
            fprintf(repmat('\b', 1, 12));
            
%         end

    [feature_val_vec, ratings_val] = featureVector(features_val);

    if rounding
        ratings_val = round(ratings_val);
    end
%     
    for i = 1:nMetric
        if FeatSel
            selectfeature_val_vec = feature_val_vec(:,selectFeatures{i});
            [X, muX, sigmaX] = zscore(feature_vector(:,selectFeatures{i}));
        else
            selectfeature_val_vec = feature_val_vec;
            [X, muX, sigmaX] = zscore(feature_vector);
        end
        Xtest = bsxfun(@rdivide,bsxfun(@minus, selectfeature_val_vec, muX), sigmaX); 
        Xtest(isnan(Xtest)) = 0;
        Pred_val(:,i) = predict(model{i},Xtest);
        Err_val(:,i) = error(model{i},Xtest,ratings_val(:,i));
    end

% 
%     save(strcat('resultsSQRTLogPCA',fileround,fileloocv,'Select.mat'), 'ratings', 'ratings_val', ...
%         'pred_val', 'pred_val1', 'pred_val2', 'pred_val3', 'pred_val4',...
%         'pred', 'pred1', 'pred2', 'pred3', 'pred4');
end
