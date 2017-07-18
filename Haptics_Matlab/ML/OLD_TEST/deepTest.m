%% support vector regression test (from Sarah) converted for the STB data

clearvars;
close all;
addpath(genpath('DeepLearnToolbox'));

if ~exist('features.mat','file')
    data = STBData('SavedData', 'task', 1);
    data = data(~cellfun(@(x)any(isnan(x(:))), {data.score}));
    
    num = xlsread('DemographicSurvey.xls');
    subjects = num(1:end, 5);
    fam = num(1:end, 11);
    
    for i = 1:length(data)
        data(i).fam = fam(subjects==data(i).subj_id);
    end
    
    data = data(~cellfun(@isempty, {data.score}));
    
    disp('Extracting Features...')
    features = staticFeatures(data);
    save('features.mat', 'features');
else
    disp('Loading Features...')
    load features.mat;
    features = features(~cellfun(@isempty,{features.gears}));
end

%% obtain feature and rating matrices

[feature_vector, ratings] = featureVector(features);

n = 10;
part = make_xval_partition(length(features), n);

ratings = round(ratings);
nMetric = size(ratings, 2);

for fold = 1:n
    
    fprintf('Fold %f \n', fold);
    feature_train = feature_vector(part~=fold, :);
    feature_test = feature_vector(part==fold, :);
    
    for i = 1:nMetric
        r = false(length(ratings(:,i)),max(ratings(:)));
        for j = 1:max(ratings(:));
            r(ratings(:,i) == j,j) = j;
        end
        r = ratings(:,i);
        r_train = r(part~=fold, :);
        r_test = r(part==fold,:);
    
        hiddenLayerSize = 50;
        net = patternnet(hiddenLayerSize);

        net.divideParam.trainRatio = 0.7;
        net.divideParam.valRatio = 0.0;
        net.divideParam.testRatio = 0.3;
        net.trainParam.showWindow = false;

        [net,tr] = train(net,feature_train',r_train');

        outputs = net(feature_test');

        [~,p] = max(outputs,[],1);
        pred(part==fold,i) = p';
    end
end
figure(1);clf;
for i = 1:size(pred,2)
subplot(size(pred,2),1,i);
[rPlot, idx] = sort(ratings(:,i));
% rPlot = ratings; idx = 1:length(ratings);
plot(rPlot,'bo');
hold on;
plot( pred(idx,i),'rx')
plot(xlim, mean(pred(~isnan(pred(:,i)),i))*[1 1],'k');
ylim([0 1.1*rPlot(end)])
end

disp(mean(pred~=ratings))

