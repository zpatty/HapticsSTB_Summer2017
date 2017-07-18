%% support vector regression test (from Sarah) converted for the STB data
function [b,C,results,selectFeat,classifScore] = randomForestTrain(rounding,TrainTest,metric,leaf,nTrees,time)
%     rounding = 1;
%     xVal = 1;
%     metric = 1;
%     leaf = 10;
%     nTrees = 100;
    clearvars -except design TrainTest rounding metric leaf nTrees time; close all;
    
    xvalfile = strcat('test_part',time,'.mat');
    cvpartfile = strcat('cvpart',time,'.mat');
    
    if TrainTest == 0
        if rounding == 0
            file = strcat('randForest',num2str(nTrees),'TreesMedCVPart',time,'.mat');
        elseif rounding == 1
            file = strcat('randForest',num2str(nTrees),'TreesFloorCVPart',time,'.mat');
        end
    elseif TrainTest == 1
        if rounding == 0
            file = strcat('randForest',num2str(nTrees),'TreesMedSubPart',time,'.mat');
        elseif rounding == 1
            file = strcat('randForest',num2str(nTrees),'TreesFloorSubPart',time,'.mat');
        end
    end
    
    if exist(file,'file')
        load(file)
    else
        % If a features.mat file exists, load that instead
        disp('Loading Features...')
        if rounding == 0
            if ~exist('featuresMed.mat','file')
                error('Quitting EnsembleTest. Please run FowardSelection.m')
            else
                load featuresMed.mat;
            end
        elseif rounding == 1
            if ~exist('featuresMean.mat','file')
                error('Quitting EnsembleTest. Please run FowardSelection.m')
            else
                load featuresMean.mat;
            end
        end       

        % Load partition to split data into test and validation sets
        if TrainTest == 1
            if exist(xvalfile,'file')
                load(xvalfile)
                test_part = subTestInd;
            else
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

        % Split dataset into testing and validation
            features_test = features(test_part);
            features_train = features(~test_part);

            % Create xval partition for testing set

            [feature_vector_train, ratings_train, index_train] = featureVector(features_train);    
            if rounding 
                ratings_train = floor(ratings_train);
            end
            [feature_vector_test, ratings_test, index_test] = featureVector(features_test);    
            if rounding
                ratings_test = floor(ratings_test);
            end
        elseif TrainTest == 0
            if exist(cvpartfile,'file')
                load(cvpartfile)
            else
                cvpart = make_cv_partition(features)
                save(strcat('cvpart',time,'.mat'),'cvpart')
            end
            test_part = test(cvpart{metric});
            features_test = features(test_part);
            features_train = features(~test_part);
            [feature_vector_train, ratings_train, index_train] = featureVector(features_train); 
            if rounding 
                ratings_train = floor(ratings_train);
            end
            
            [feature_vector_test, ratings_test, index_test] = featureVector(features_test); 
            if rounding
                ratings_test = floor(ratings_test);
            end            
       end         
    end
    
    

        % Build separate models for each grading metric
%         nMetric = size(ratings, 2)

    X = feature_vector_train;
    Y = ordinal(ratings_train(:,metric));
    rng(9876,'twister');
    savedRng = rng; % save the current RNG settings
    
%     C = [0 1 1.5 2 2.5;1 0 1 1.5 2; 1.5 1 0 1 1.5;2 1.5 1 0 1;2.5 2 1.5 1 0]; % cost matrix
%     C = [0 1 2 3 4;1 0 1 2 3;2 1 0 1 2;3 2 1 0 1;4 3 2 1 0];
    C = [0 1 2^2 3^2 4^2;1 0 1 2^2 3^2;2^2 1 0 1 2^2;3^2 2^2 1 0 1;4^2 3^2 2^2 1 0];
    
    
    if ~any(ismember(ratings_train(:,metric),1))
        C = C(2:end,2:end);
    end
  
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

    figure
    bar(b.OOBPermutedVarDeltaError);
    xlabel('Feature number');
    ylabel('Out-of-bag feature importance');
    title('Feature importance results');

    oobErrorFullX = b.oobError;
    
    if size(leaf,2)>1
        error('leaf has too many options')
    else

        [sortedValues,sortIndex] = sort(b.OOBPermutedVarDeltaError(:),'descend');
        maxIndex{metric} = sortIndex(1:30);
        selectFeat = index_train(maxIndex{metric});

        X = feature_vector_train(:,maxIndex{metric});
        rng(savedRng);
        b = TreeBagger(nTrees,X,Y,'OOBPred','on','Prior','Empirical',...
                                  'MinLeaf',leaf,'Cost',C,'PredictorNames',index_train(maxIndex{metric}));

        oobErrorX246 = b.oobError;

        figure
        plot(oobErrorFullX,'b');
        hold on;
        plot(oobErrorX246,'r');
        xlabel('Number of grown trees');
        ylabel('Out-of-bag classification error');
        legend({'All features', 'Select Features'},'Location','NorthEast');
        title('Classification Error for Different Sets of Predictors');
        hold off;

        b = b.compact;

        models{metric} = b;

        [predClass,classifScore] = b.predict(feature_vector_test(:,maxIndex{metric}));

        C = confusionmat(categorical(ratings_test(:,metric)),categorical(predClass),...
        'order',{'5' '4' '3' '2' '1'});
        Cperc = diag(sum(C,2))\C;

        results{metric} = str2num(char(predClass))-ratings_test(:,metric);
        
        save(file,'models','maxIndex','index_train','feature_vector_train','ratings_train','index_test','feature_vector_test','ratings_test','results')
    end
end
