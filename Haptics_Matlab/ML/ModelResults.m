function [exact_reg,exact_class,near_reg,near_class] = ModelResults(rounding,TrainTest,nTrees,time,icc)
%     rounding = 1; TrainTest = 1; nTrees = 500; time = '0610152241'; icc = 1;
    close all;
    clearvars -except rounding TrainTest nTrees time icc
    
    if rounding == 0
        fileround = 'Med';
        load featuresMed
    elseif rounding == 1
        fileround = 'Floor';
        load featuresMean
    end
    
    if TrainTest == 0
        filepart = 'CVPart';
        filename3 = strcat('cvpart',time,'.mat');
    elseif TrainTest == 1
        filepart = 'SubPart';
        filename3 = strcat('test_part',time,'.mat');
    end

    filename1 = strcat('RegEnsembleSelect',fileround,filepart,time,'.mat');
    filename2 = strcat('randForest',num2str(nTrees),'Trees',fileround,filepart,time,'.mat');
   
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
        test_part = subTestInd;
        features_test = features(test_part);
        features_train = features(~test_part);
        [~, ratings_train] = featureVector(features_train);
        [~, ratings_test] = featureVector(features_test);
    end

%     if select
%         filename1 = strcat(filename1,'Select');
%     end

%     load(strcat(filename1,'.mat'));
    load(filename1)
    
    pred_reg_train = floor(pred_train);
    pred_reg_train(pred_reg_train<1) = 1;
    pred_reg_test = floor(pred_test);
    pred_reg_test(pred_reg_test<1) = 1;
    
    figure(1);clf;
    plot_pred(pred_reg_train, ratings_train);

    figure(2);clf;
    plot_pred(pred_reg_test, ratings_test);
    
    
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
            'XColor',[1 1 1],'OuterPosition',[0 (subfig-i)/subfig 1 1/subfig],'FontSize',20);
            xlim(figaxes(i),[0.5 0.5+size(ratings_test,1)]); ylim(figaxes(i),[0.5 5.5]);
            grid(figaxes(i),'on');
            title(figaxes(i),gears{i});
            hold(figaxes(i),'all');
            
            [rPlot, idx] = sort(ratings_test(:,i));
            plot(rPlot,'Parent',figaxes(i),'Color','b','Marker','o','MarkerSize',10,'LineStyle','none')
            plot(pred_reg_test(idx,i),'Parent',figaxes(i),'Color','r','Marker','x','MarkerSize',10,'LineStyle','none')
            plot(pred_class_test(idx,i),'Parent',figaxes(i),'Color','g','Marker','+','MarkerSize',10,'LineStyle','none')
    end
    
    figure1 = 'RawFigs/STBLearnerResults';
    print(h1,'-depsc2',figure1); 
    
    
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
                    GearsReg = [Kris(:,i),David(:,i),pred_reg_test(fullIndex~=0,i)];
                    GearsClass = [Kris(:,i),David(:,i),pred_class_test(fullIndex~=0,i)];
                    GearsJeremy = [Kris(:,i),David(:,i),Jeremy(fullIndex~=0,i)];
                    [rGearsReg, ~, ~, ~, ~, ~, ~] = ICC(GearsReg, IccType{k}, .05, 0);
                    [rGearsClass, ~, ~, ~, ~, ~, ~] = ICC(GearsClass, IccType{k}, .05, 0);
                    [rGearsJeremy, ~, ~, ~, ~, ~, ~] = ICC(GearsJeremy, IccType{k}, .05, 0);
                    fprintf('%s \t& %1.2f \t& %1.2f \t& %1.2f \\\\ \n',gears{i},rGearsReg,rGearsClass,rGearsJeremy)
                    csvwrite(strcat('Stats/GearsReg',num2str(i),time,'.csv'),GearsReg);
                    csvwrite(strcat('Stats/GearsClass',num2str(i),time,'.csv'),GearsClass);
                    csvwrite(strcat('Stats/GearsJeremy',num2str(i),time,'.csv'),GearsJeremy);
                    GearsRegAll = [GearsRegAll;GearsReg];
                    GearsClassAll = [GearsClassAll;GearsClass];
                    GearsJeremyAll = [GearsJeremyAll;GearsJeremy];
            end
            [rGearsRegAll, ~, ~, ~, ~, ~, ~] = ICC(GearsRegAll, IccType{k}, .05, 0);
            [rGearsClassAll, ~, ~, ~, ~, ~, ~] = ICC(GearsClassAll, IccType{k}, .05, 0);
            [rGearsJeremyAll, ~, ~, ~, ~, ~, ~] = ICC(GearsJeremyAll, IccType{k}, .05, 0);
            fprintf('%s \t& %1.2f \t& %1.2f \t& %1.2f \\\\ \n','Overall',rGearsRegAll,rGearsClassAll,rGearsJeremyAll)
            csvwrite(strcat('Stats/GearsRegAll',time,'.csv'),GearsRegAll);
            csvwrite(strcat('Stats/GearsClassAll',time,'.csv'),GearsClassAll);
            csvwrite(strcat('Stats/GearsJeremyAll',time,'.csv'),GearsJeremyAll);
        end
    end
end


  

%     for i = 1:5
%         scoreTrain1{i} = ratings(:,1)==i;
%         scoreTrain2{i} = ratings(:,2)==i;
%         scoreTrain3{i} = ratings(:,3)==i;
%         scoreTrain4{i} = ratings(:,4)==i;
%         scoreTrain5{i} = ratings(:,5)==i;
% 
%         predTrain1{i} = pred(scoreTrain1{i},1);
%         predTrain2{i} = pred(scoreTrain2{i},2);
%         predTrain3{i} = pred(scoreTrain3{i},3);
%         predTrain4{i} = pred(scoreTrain4{i},4);
%         predTrain5{i} = pred(scoreTrain5{i},5);
% 
%         muTrain1 = cellfun(@mean,predTrain1);
%         muTrain2 = cellfun(@mean,predTrain2);
%         muTrain3 = cellfun(@mean,predTrain3);
%         muTrain4 = cellfun(@mean,predTrain4);
%         muTrain5 = cellfun(@mean,predTrain5);
% 
%         sigTrain1 = cellfun(@std,predTrain1);
%         sigTrain2 = cellfun(@std,predTrain2);
%         sigTrain3 = cellfun(@std,predTrain3);
%         sigTrain4 = cellfun(@std,predTrain4);
%         sigTrain5 = cellfun(@std,predTrain5);
%         
%         scoreTest1{i} = ratings_val(:,1)==i;
%         scoreTest2{i} = ratings_val(:,2)==i;
%         scoreTest3{i} = ratings_val(:,3)==i;
%         scoreTest4{i} = ratings_val(:,4)==i;
%         scoreTest5{i} = ratings_val(:,5)==i;
% 
%         predTest1{i} = pred(scoreTest1{i},1);
%         predTest2{i} = pred(scoreTest2{i},2);
%         predTest3{i} = pred(scoreTest3{i},3);
%         predTest4{i} = pred(scoreTest4{i},4);
%         predTest5{i} = pred(scoreTest5{i},5);
% 
%         muTest1 = cellfun(@mean,predTest1);
%         muTest2 = cellfun(@mean,predTest2);
%         muTest3 = cellfun(@mean,predTest3);
%         muTest4 = cellfun(@mean,predTest4);
%         muTest5 = cellfun(@mean,predTest5);
% 
%         sigTest1 = cellfun(@std,predTest1);
%         sigTest2 = cellfun(@std,predTest2);
%         sigTest3 = cellfun(@std,predTest3);
%         sigTest4 = cellfun(@std,predTest4);
%         sigTest5 = cellfun(@std,predTest5);
% 
%         figure(1);clf;
%         plot((0:5),(0:5),'k')
%         hold on
%         errorbar(muTrain1,sigTrain1,'Color','r')
%         errorbar(muTest1,sigTest1,'Color','b')
% 
%         figure(2);clf;
%         plot((0:5),(0:5),'k')
%         hold on
%         errorbar(muTrain2,sigTrain2,'Color','r')
%         errorbar(muTest2,sigTest2,'Color','b')
% 
%         figure(3);clf;
%         plot((0:5),(0:5),'k')
%         hold on
%         errorbar(muTrain3,sigTrain3,'Color','r')
%         errorbar(muTest3,sigTest3,'Color','b')
% 
%         figure(4);clf;
%         plot((0:5),(0:5),'k')
%         hold on
%         errorbar(muTrain4,sigTrain4,'Color','r')
%         errorbar(muTest4,sigTest4,'Color','b')
% 
%         figure(5);clf;
%         plot((0:5),(0:5),'k')
%         hold on
%         errorbar(muTrain5,sigTrain5,'Color','r')
%         errorbar(muTest5,sigTest5,'Color','b')
% 
%    
%         [predClass{i},classifScore] = models{i}.predict(feature_vector(:,maxIndex{i})); 
%         pred{i} = str2num(cell2mat(predClass{i}));
% 
%         [predClass_val{i},classifScore] = models{i}.predict(feature_vector_val(:,maxIndex{i})); 
%         pred_val{i} = str2num(cell2mat(predClass_val{i}));
% 
% 
%         figure(1)
%         plot_pred(cell2mat(pred), ratings);
%         figure(2)
%         plot_pred(cell2mat(pred_val), ratings_val);
%     
%     end