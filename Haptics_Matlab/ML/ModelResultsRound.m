%%%%% This function loads a given training/test split for both the
%%%%% regression and classification learner and computes the exact
%%%%% accuracy, accuracy within one, precision, recall, and F1 scores

function [exact_reg,exact_class,near_reg,near_class,prec_reg,prec_class,rec_reg,rec_class,f1_reg,f1_class,pe_reg,pe_class] = ModelResultsRound(rounding,TrainTest,nTrees,time,icc,folder,omit)
 
    if nargin == 5
        folder = '';
    end
%     rounding = 1; TrainTest = 1; nTrees = 500; time = '0610152241'; icc = 1;
    close all;
    clearvars -except rounding TrainTest nTrees time icc folder omit
    
    if omit == 0 % no features removed
        fileomit = '';
        if TrainTest == 0
            filepart = 'CVPart';
            filename3 = strcat('cvpart',time,'.mat');
        elseif TrainTest == 1
            filepart = 'SubPart';
            filename3 = strcat('test_part',time,'.mat');
        end
        if rounding == 0
            fileround = 'Med';
            load(strcat('featuresMed',folder)); % use the median features
        elseif rounding == 1
            fileround = 'Round';
            load(strcat('featuresMean',folder)); % use the mean features
        end
    else % features removed
        if omit == 1 % PCA features removed
            fileomit = 'NoPCA';
        elseif omit == 2 % force features removed
            fileomit = 'NoForce';
        elseif omit == 3 % PCA and force features removed
            fileomit = 'NoForcePCA';
        end
        if TrainTest == 0
            filepart = 'CVPart';
            filename3 = strcat('cvpart',time,'.mat');
        elseif TrainTest == 1
            filepart = 'SubPart';
            filename3 = strcat('test_part',time,'.mat');
        end
        if rounding == 0
            fileround = 'Med';
            load(strcat('featuresMed',fileomite,folder)); % use the median features
        elseif rounding == 1
            fileround = 'Round';
            load(strcat('featuresMean',fileomit,folder)); % use the mean features
        end
    end

    filename1 = strcat('RegEnsembleSelect',fileround,filepart,fileomit,time,'.mat'); % load regression data
    filename2 = strcat('randForest',num2str(nTrees),'Trees',fileround,filepart,fileomit,time,'.mat'); % load classification data 
   
    load(filename3);
    if TrainTest == 0
        for i = 1:5
            test_part = test(cvpart{i});
            features_test = features(test_part);
            features_train = features(~test_part);
            [~, rate_train] = featureVector(features_train);
            [~, rate_test] = featureVector(features_test);
            ratings_train(:,i) = rate_train(:,i);
            ratings_test(:,i) = rate_test(:,i);
        end
    elseif TrainTest == 1
        test_part = subTestInd; % indices of trials to reserve for testing
        features_test = features(test_part); % select features for testing set
        features_train = features(~test_part); % select features for training set
        [~, ratings_train] = featureVector(features_train); % get ratings of training data
        [~, ratings_test] = featureVector(features_test); % get rtings of testing data
    end

%     if select
%         filename1 = strcat(filename1,'Select');
%     end

%     load(strcat(filename1,'.mat'));
    load(filename1)
    
    pred_reg_train = round(pred_train);
    pred_reg_train(pred_reg_train<1) = 1;
    pred_reg_test = round(pred_test);
    pred_reg_test(pred_reg_test<1) = 1;

    figure(1);clf;
    plot_pred(pred_reg_train, ratings_train);

    figure(2);clf;
    plot_pred(pred_reg_test, ratings_test);
    
    %% Precision and Recall Regression
    prec_reg = 999*ones(5,5);
    rec_reg = 999*ones(5,5);
    f1_reg = 999*ones(5,5);
    pe_reg = 999*ones(5,5);
    
    for i = 1:size(ratings_test,2)
        [p,r,f1,m] = PrecisionRecall(ratings_test(:,i),pred_reg_test(:,i));
        
        prec_reg(:,i) = p;
        rec_reg(:,i) = r;
        f1_reg(:,i) = f1;
        pe_reg(:,i) = sum(m',1);
        
    end
    
    %% Classification
    
    load(filename2)
        
    clear pred_train pred_test
    
    for i = 1:5
        if TrainTest == 0
            test_part = test(cvpart{i});
            features_test = features(test_part);
            features_train = features(~test_part);
            [feature_vector_train, ~] = featureVector(features_train);
            [feature_vector_test, ~] = featureVector(features_test);
        elseif TrainTest == 1
            test_part = subTestInd;
            features_test = features(test_part);
            features_train = features(~test_part);
            [feature_vector_train, ~] = featureVector(features_train);
            [feature_vector_test, ~] = featureVector(features_test);
        end
        
        [predClass_train{i},classifScore] = models{i}.predict(feature_vector_train(:,maxIndex{i})); 
        pred_train{i} = str2num(cell2mat(predClass_train{i}));

        [predClass_test{i},classifScore] = models{i}.predict(feature_vector_test(:,maxIndex{i})); 
        pred_test{i} = str2num(cell2mat(predClass_test{i}));
    end
    
    pred_class_train = cell2mat(pred_train);
    pred_class_test = cell2mat(pred_test);
    
    figure(3);clf;
    plot_pred(pred_class_train, ratings_train);

    figure(4);clf;
    plot_pred(pred_class_test, ratings_test);
    
    
     %% Precision and Recall Classification
    prec_class = 999*ones(5,5);
    rec_class = 999*ones(5,5);
    f1_class = 999*ones(5,5);
    pe_class = 999*ones(5,5);
    
    for i = 1:size(ratings_test,2)
        [p,r,f1,m] = PrecisionRecall(ratings_test(:,i),pred_class_test(:,i));
        
        prec_class(:,i) = p;
        rec_class(:,i) = r;
        f1_class(:,i) = f1;
        pe_class(:,i) = sum(m',1);         
    end
    
    %%
    
    IndThresh = 1;
    
    gears = {'Depth Perception','Bimanual Dexterity','Efficiency','Force Sensitivity','Robotic Control'};
    fprintf('\nGEARS Domain \t& Regression Learner \t& Classification Learner\\\\ \\hline\n')
    for i = 1:5
        [~,~,~,exact_reg(i)] = check_err(pred_reg_test(:,i),ratings_test(:,i), IndThresh);
        [~,~,~,exact_class(i)] = check_err(pred_class_test(:,i),ratings_test(:,i), IndThresh);
        fprintf('%s \t& %d\\%% \t& %d\\%% \\\\ \n',gears{i},round(exact_reg(i)*100),round(exact_class(i)*100))
    end
    
    fprintf('\nGEARS Domain \t& Regression Learner \t& Classification Learner\\\\ \\hline\n')
    for i = 1:5
        [~,~,near_reg(i),~] = check_err(pred_reg_test(:,i),ratings_test(:,i), IndThresh);
        [~,~,near_class(i),~] = check_err(pred_class_test(:,i),ratings_test(:,i), IndThresh);
        fprintf('%s \t& %d\\%% \t& %d\\%% \\\\ \n',gears{i},round(near_reg(i)*100),round(near_class(i)*100))
    end
    
    h1=figure('Color',[1,1,1]);
    fullscreen = get(0,'ScreenSize');
    set(h1,'Position',[0 0 fullscreen(3) fullscreen(4)])
    set(h1,'PaperOrientation','landscape');
    set(h1,'PaperUnits','normalized');
    set(h1,'PaperPosition', [0 0 1 1]);
    
    subfig = 5;
    for i = 1:subfig
        figaxes(i) = axes('Parent',h1,'YTick',1:5,'XTick',zeros(1,0),...
            'XColor',[1 1 1],'OuterPosition',[0 (subfig-i)/subfig 1 1/subfig],'FontSize',20,'YGrid','on');
            xlim(figaxes(i),[0.5 0.5+size(ratings_test,1)]); ylim(figaxes(i),[0.5 5.5]);
%             grid(figaxes(i),'on');
            title(figaxes(i),gears{i});
            hold(figaxes(i),'all');
            
            [rPlot, idx] = sort(ratings_test(:,i));
            plot(rPlot,'Parent',figaxes(i),'Color','b','Marker','o','MarkerSize',10,'LineStyle','none')
            plot(pred_reg_test(idx,i),'Parent',figaxes(i),'Color','r','Marker','x','MarkerSize',10,'LineStyle','none')
            plot(pred_class_test(idx,i),'Parent',figaxes(i),'Color','g','Marker','+','MarkerSize',10,'LineStyle','none')
    end
    
    
    
    figure1 = 'RawFigs/STBLearnerResults';
    print(h1,'-depsc2',figure1); 
    
    %% Computing ICC scores
    if icc
        IccType = {'A-k','A-1'};
        for k = 1:2
            testData = subTest(:,1)+2;
            data = STBData('SavedData', 'task', 1,'subject',testData);
            data = data(~cellfun(@(x)any(isnan(x(:))), {data.score}));

            Jeremy = [];
            David = [];
            Kris = [];
            for i = 1:length(data)
                Jeremy = [Jeremy;data(i).score(1,:)];
                if size(data(i).score,1)==3
                    fullIndex(i) = i;
                    Kris = [Kris;data(i).score(2,:)];
                    David = [David;data(i).score(3,:)];   
                end
            end

            GearsRegAll = [];
            GearsClassAll = [];
            GearsJeremyAll = [];
            fprintf('\n\\TextWrapCent{GEARS}{Domain} \t& \\TextWrapCent{Regression}{Learner} \t& \\TextWrapCent{Classification}{Learner} \t& \\TextWrapCent{Non-Expert}{Rater}\\\\ \\hline\n')
            for i = 1:5
                    GearsReg = [Kris(:,i),David(:,i),Jeremy(:,i),pred_reg_test(fullIndex~=0,i)];
                    GearsClass = [Kris(:,i),David(:,i),Jeremy(:,i),pred_class_test(fullIndex~=0,i)];
                    GearsJeremy = [Kris(:,i),David(:,i),Jeremy(fullIndex~=0,i)];
                    [rGearsReg, ~, ~, ~, ~, ~, ~] = ICC(GearsReg, IccType{k}, .05, 0);
                    [rGearsClass, ~, ~, ~, ~, ~, ~] = ICC(GearsClass, IccType{k}, .05, 0);
                    [rGearsJeremy, ~, ~, ~, ~, ~, ~] = ICC(GearsJeremy, IccType{k}, .05, 0);
                    fprintf('%s \t& %1.2f \t& %1.2f \t& %1.2f \\\\ \n',gears{i},rGearsReg,rGearsClass,rGearsJeremy)
                    if omit == 0 % no features removed
                        csvwrite(strcat('Stats/GearsReg',num2str(i),time,'.csv'),GearsReg);
                        csvwrite(strcat('Stats/GearsClass',num2str(i),time,'.csv'),GearsClass);
                        csvwrite(strcat('Stats/GearsJeremy',num2str(i),time,'.csv'),GearsJeremy);
                    elseif omit == 1 % PCA features removed
                        csvwrite(strcat('Stats/GearsRegNoPCA',num2str(i),time,'.csv'),GearsReg);
                        csvwrite(strcat('Stats/GearsClassNoPCA',num2str(i),time,'.csv'),GearsClass);
                        csvwrite(strcat('Stats/GearsJeremyNoPCA',num2str(i),time,'.csv'),GearsJeremy);
                    elseif omit == 2 % force features removed
                        csvwrite(strcat('Stats/GearsRegNoForce',num2str(i),time,'.csv'),GearsReg);
                        csvwrite(strcat('Stats/GearsClassNoForce',num2str(i),time,'.csv'),GearsClass);
                        csvwrite(strcat('Stats/GearsJeremyNoForce',num2str(i),time,'.csv'),GearsJeremy);
                    elseif omit == 3 % PCA and force features removed
                        csvwrite(strcat('Stats/GearsRegNoForcePCA',num2str(i),time,'.csv'),GearsReg);
                        csvwrite(strcat('Stats/GearsClassNoForcePCA',num2str(i),time,'.csv'),GearsClass);
                        csvwrite(strcat('Stats/GearsJeremyNoForcePCA',num2str(i),time,'.csv'),GearsJeremy);
                    end
                    GearsRegAll = [GearsRegAll;GearsReg];
                    GearsClassAll = [GearsClassAll;GearsClass];
                    GearsJeremyAll = [GearsJeremyAll;GearsJeremy];
            end
            [rGearsRegAll, ~, ~, ~, ~, ~, ~] = ICC(GearsRegAll, IccType{k}, .05, 0);
            [rGearsClassAll, ~, ~, ~, ~, ~, ~] = ICC(GearsClassAll, IccType{k}, .05, 0);
            [rGearsJeremyAll, ~, ~, ~, ~, ~, ~] = ICC(GearsJeremyAll, IccType{k}, .05, 0);
            fprintf('%s \t& %1.2f \t& %1.2f \t& %1.2f \\\\ \n','Overall',rGearsRegAll,rGearsClassAll,rGearsJeremyAll)
            if omit == 0 % no features removed
                csvwrite(strcat('Stats/GearsRegAll',time,'.csv'),GearsRegAll);
                csvwrite(strcat('Stats/GearsClassAll',time,'.csv'),GearsClassAll);
                csvwrite(strcat('Stats/GearsJeremyAll',time,'.csv'),GearsJeremyAll);
            elseif omit == 1 % PCA features removed
                csvwrite(strcat('Stats/GearsRegAllNoPCA',time,'.csv'),GearsRegAll);
                csvwrite(strcat('Stats/GearsClassAllNoPCA',time,'.csv'),GearsClassAll);
                csvwrite(strcat('Stats/GearsJeremyAllNoPCA',time,'.csv'),GearsJeremyAll);
            elseif omit == 2 % force features removed
                csvwrite(strcat('Stats/GearsRegAllNoForce',time,'.csv'),GearsRegAll);
                csvwrite(strcat('Stats/GearsClassAllNoForce',time,'.csv'),GearsClassAll);
                csvwrite(strcat('Stats/GearsJeremyAllNoForce',time,'.csv'),GearsJeremyAll);
            elseif omit == 3 % PCA and force features removed
                csvwrite(strcat('Stats/GearsRegAllNoForcePCA',time,'.csv'),GearsRegAll);
                csvwrite(strcat('Stats/GearsClassAllNoForcePCA',time,'.csv'),GearsClassAll);
                csvwrite(strcat('Stats/GearsJeremyAllNoForcePCA',time,'.csv'),GearsJeremyAll);
            end
        end
    end
   
end

