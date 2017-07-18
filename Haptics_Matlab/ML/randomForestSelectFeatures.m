%% support vector regression test (from Sarah) converted for the STB data
function [model,ErrTrain,Err_val,Pred,Pred_val,ratings,ratings_val] = randomForestSelectFeatures(rounding,FeatSel,nTrees)
    tic
    clearvars -except rounding FeatSel nTrees;

    if ~exist('SelectFeatures.mat','file')
        error('Quitting EnsembleTest. Please run FeatureSelection.m')
    else
        % If a features.mat file exists, load that instead
        disp('Loading Features...')
        load features.mat;
        load SelectFeatures.mat;
    end

    % Load partition to split data into test and validation sets
    if exist('test_part.mat','file')
        load test_part.mat
    else
        test_part = make_xval_partition(length(features), 10);
        test_part = test_part == 10;
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
        nMetric = size(ratings, 2);
        models = cell(1,nMetric);

        for i = 1:nMetric;
            if FeatSel
                selectfeature_vector = feature_vector(:,selectFeatures{i});
            else
                selectfeature_vector = feature_vector;
            end
            [X, muX, sigmaX] = zscore(selectfeature_vector);  
            fprintf('Metric %d ...', i);
            y = ratings(:,i);
            rng(1);
            model{i} = TreeBagger(nTrees, X, y, 'Prior', 'Empirical','OOBPred','On','OOBVarImp','On');
            
            figure(i)
            oobErrorBaggedEnsemble = oobError(model{i});
            plot(oobErrorBaggedEnsemble)
            xlabel 'Number of grown trees';
            ylabel 'Out-of-bag classification error';

            
            
            predicted_label = predict(model{i},X);
            ErrTrain(:,i) = error(model{i},X,ratings(:,i));
            Pred(:,i) = predicted_label;
            
            fprintf(repmat('\b', 1, 12));
            
        end

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
toc
end
