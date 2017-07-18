%% support vector regression test (from Sarah) converted for the STB data

clearvars;
close all;

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
feature_vector = feature_vector(:, var(feature_vector) > 10);

n = 10;
part = make_xval_partition(length(features), n);

ratings = round(ratings);

nMetric = size(ratings, 2);
pred = zeros(size(ratings));
for fold = 1:n
    
    fprintf('Fold %02d: ', fold);
    
    feature_train = feature_vector(part~=fold, :);
    feature_test = feature_vector(part==fold, :);
    
    for i = 1:nMetric
        fprintf('Metric %d ...', i);
        r = false(length(ratings(:,i)),max(ratings(:)));
        for j = 1:max(ratings(:));
            r(ratings(:,i) == j,j) = j;
        end
        
        r_train = r(part~=fold, :);
        r_test = r(part==fold,:);
    
        hiddenLayerSize = 100;
        net = patternnet(hiddenLayerSize);

        net.divideParam.trainRatio = 0.9;
        net.divideParam.valRatio = 0.0;
        net.divideParam.testRatio = 0.1;
        net.trainParam.showWindow = false;

        [net,tr] = train(net,feature_train',r_train');

        outputs = net(feature_test');

        [~,p] = max(outputs,[],1);

        pred(part==fold,i) = p;
        fprintf(repmat('\b', 1, 12));
    end
    fprintf(repmat('\b', 1, 9));
end
fprintf('\n');
figure(1);clf;

domains = {'Depth Perception', 'Bimanual Dexterity', 'Efficiency', 'Force Sensitivity', 'Robotic Control'};

for i = 1:nMetric
subplot(nMetric,1,i);

if (nMetric == 5);
    title(domains{i});
    hold on;
end

[rPlot, idx] = sort(ratings(:,i));
plot(rPlot,'bo');
hold on;
plot( pred(idx,i),'rx')
plot(xlim, mean(pred(~isnan(pred(:,i)),i))*[1 1],'k');
ylim([0 1.1*rPlot(end)]);

end

disp(mean(pred~=ratings))

