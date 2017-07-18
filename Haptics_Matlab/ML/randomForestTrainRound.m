%%%%% support vector regression test (from Sarah) converted for the STB data

%%%%% Performs training and testing of the random forest classification
%%%%% model for each GEARS metric

function [b,C,results,selectFeat,classifScore] = randomForestTrainRound(rounding,TrainTest,metric,leaf,nTrees,time,folder)
%     rounding = 1;
%     xVal = 1;
%     metric = 1;
%     leaf = 10;
%     nTrees = 100;
    clearvars -except design TrainTest rounding metric leaf nTrees time folder; close all;
    
    xvalfile = strcat('test_part',time,'.mat');
    cvpartfile = strcat('cvpart',time,'.mat');
    
    % Creates file name to save all data 
    if TrainTest == 0 % create CV partition file for train/test split
        if rounding == 0 % use median value for GEARS scores
            file = strcat('randForest',num2str(nTrees),'TreesMedCVPart',time,'.mat');
        elseif rounding == 1 % use mean value for GEARS score
            file = strcat('randForest',num2str(nTrees),'TreesRoundCVPart',time,'.mat');
        end
    elseif TrainTest == 1 % use subject familiarity for train/test split 
        if rounding == 0 % use median value for GEARS scores
            file = strcat('randForest',num2str(nTrees),'TreesMedSubPart',time,'.mat');
        elseif rounding == 1 % use mean value for GEARS scores 
            file = strcat('randForest',num2str(nTrees),'TreesRoundSubPart',time,'.mat');
        end
    end
    
    if exist(file,'file')
        load(file)
    else
        % Load feature set created during ForwardSelection
        disp('Loading Features...')
        if rounding == 0 % features with median GEARS scores
            if ~exist(strcat('featuresMean',folder,'.mat'),'file')
                error('Quitting. Please run FowardSelection.m')
            else
                load(strcat('featuresMed',folder,'.mat'));
            end
        elseif rounding == 1 % features with mean GEARS scores 
            if ~exist(strcat('featuresMean',folder,'.mat'),'file')
                error('Quitting. Please run FowardSelection.m')
            else
                load(strcat('featuresMean',folder,'.mat'));
            end
        end       

        % Load partition to split data into test and validation sets
        if TrainTest == 1 % using subject familiarity to perform train/test split
            if exist(xvalfile,'file')
                load(xvalfile)
                test_part = subTestInd;
            else % create partition using make_subject_partition function
                [subTest,subTestInd,subTrain,subTrainInd] = make_subject_partition(4);
                test_part = subTestInd;
                save(strcat('test_part',time,'.mat'),'subTest','subTestInd','subTrain','subTrainInd')
            end
%         else
%             if exist('test_part.mat','file')
%                     load test_part.mat
%                 else
%                     test_part = make_xval_partition(length(features), 10);
%                     test_part = test_part == 10;
%             end

            % Split features into training and testing
            features_test = features(test_part);
            features_train = features(~test_part);

            % Create feature vector for training set
            [feature_vector_train, ratings_train, index_train] = featureVector(features_train);    
            if rounding == 1 
                ratings_train = round(ratings_train);
            end
            % Create feature vector for testing set 
            [feature_vector_test, ratings_test, index_test] = featureVector(features_test);    
            if rounding == 1
                ratings_test = round(ratings_test);
            end
        elseif TrainTest == 0 % using CV partition to perform train/test split
            if exist(cvpartfile,'file')
                load(cvpartfile)
            else % create partition using make_cv_partition function
                cvpart = make_cv_partition(features)
                save(strcat('cvpart',time,'.mat'),'cvpart')
            end
            test_part = test(cvpart{metric});
            features_test = features(test_part);
            features_train = features(~test_part);
            
            % Create feature vector for training set
            [feature_vector_train, ratings_train, index_train] = featureVector(features_train); 
            if rounding == 1
                ratings_train = round(ratings_train);
            end
            % Create feature vector for testing set 
            [feature_vector_test, ratings_test, index_test] = featureVector(features_test); 
            if rounding == 1
                ratings_test = round(ratings_test);
            end            
       end         
    end
    
    

        % Build separate models for each grading metric
%         nMetric = size(ratings, 2)

    X = feature_vector_train; % assign training features to variable X
    Y = ordinal(ratings_train(:,metric)); % assign training ratings to variable Y as ordinal
    rng(9876,'twister');
    savedRng = rng; % save the current RNG settings
    
%     C = [0 1 1.5 2 2.5;1 0 1 1.5 2; 1.5 1 0 1 1.5;2 1.5 1 0 1;2.5 2 1.5 1 0]; % cost matrix
%     C = [0 1 2 3 4;1 0 1 2 3;2 1 0 1 2;3 2 1 0 1;4 3 2 1 0];
    C = [0 1 2^2 3^2 4^2;1 0 1 2^2 3^2;2^2 1 0 1 2^2;3^2 2^2 1 0 1;4^2 3^2 2^2 1 0]; % cost matrix for false predictions
    
    % resize cost matrix if there are no 1s in the training set 
    if ~any(ismember(ratings_train(:,metric),1))
        C = C(2:end,2:end);
    end
  
    % Plot the out-of-bag error for each bagged decision tree at eahc leaf size
    figure
    color = 'bgr';
    for ii = 1:length(leaf)
        % Reinitialize the random number generator, so that the
        % random samples are the same for each leaf size
        rng(savedRng);
        % Create a bagged decision tree for each leaf size and plot out-of-bag
        % error 'oobError'
        b = TreeBagger(nTrees,X,Y,'OOBPred','on','OOBVarImp','on','Prior','Empirical',...
                                 'MinLeaf',leaf(ii),'Cost',C,'PredictorNames',index_train);
        plot(b.oobError,color(ii));
        hold on;
    end
    
    xlabel('Number of grown trees');
    ylabel('Out-of-bag classification error');
    legtext = textscan(num2str(leaf),'%s');
    legend(legtext{1},'Location','NorthEast');
    title('Classification Error for Different Leaf Sizes');
    hold off;

    % Create bar plot of important features 
    figure
    bar(b.OOBPermutedVarDeltaError);
    xlabel('Feature number');
    ylabel('Out-of-bag feature importance');
    title('Feature importance results');

    oobErrorFullX = b.oobError; % saving important features
    
    % Train random forest model with select features
    if size(leaf,2)>1
        error('leaf has too many options')
    else
        
        % Sort the important features and take the top 30
        [sortedValues,sortIndex] = sort(b.OOBPermutedVarDeltaError(:),'descend');
        maxIndex{metric} = sortIndex(1:30);
        selectFeat = index_train(maxIndex{metric}); % index of important features

        X = feature_vector_train(:,maxIndex{metric}); % removes unselected features from feature vector
        rng(savedRng);
        % train random forest model 
        b = TreeBagger(nTrees,X,Y,'OOBPred','on','Prior','Empirical',...
                                  'MinLeaf',leaf,'Cost',C,'PredictorNames',index_train(maxIndex{metric}));

        oobErrorX246 = b.oobError;
        
        % Plot out-of-bag error
        figure
        plot(oobErrorFullX,'b');
        hold on;
        plot(oobErrorX246,'r');
        xlabel('Number of grown trees');
        ylabel('Out-of-bag classification error');
        legend({'All features', 'Select Features'},'Location','NorthEast');
        title('Classification Error for Different Sets of Predictors');
        hold off;
        
        b = b.compact; % save model as compact (removes superfulous items)

        models{metric} = b; % save model for given metric in models

        [predClass,classifScore] = b.predict(feature_vector_test(:,maxIndex{metric})); % run predictions on testing set with model 

%         C = confusionmat(categorical(ratings_test(:,metric)),categorical(predClass),...
%         'order',{'5' '4' '3' '2' '1'});
%         Cperc = diag(sum(C,2))\C;

        results{metric} = str2num(char(predClass))-ratings_test(:,metric); % subtract predicted scores from actual scores
        
        save(file,'models','maxIndex','index_train','feature_vector_train','ratings_train','index_test','feature_vector_test','ratings_test','results')
    end
end
