%% support vector regression test (from Sarah) converted for the STB data

clearvars;
addpath('lib2');


if ~exist('features.mat','file')
    data = STBData('SavedData');
    
    num = xlsread('DemographicSurvey.xls');
    subjects = num(1:end, 5);
    fam = num(1:end, 11);
    
    for i = 1:length(data)
        data(i).fam = fam(subjects==data(i).subj_id);
    end
    
    disp('Extracting Features...')
    features = staticFeatures(data);
    save('features.mat', 'features');
else
    disp('Loading Features...')
    load features.mat;
end

%% obtain feature and rating matrices

n = 10;
part = make_xval_partition(length(features), n);

err = zeros(n,1);
pred = zeros(length(features),1);
preds = [];
[feature_vector, ratings] = featureVector(features);
ratings = double(ratings > 2.5);

t = 5;
kerr = [];

for k = 5 
    for fold = 1:n

        feature_train = feature_vector(part ~= fold,:);
        ratings_train = ratings(part ~= fold,:);
        
        %% standardize data for svr
        [X, muX, sigmaX] = zscore(feature_train);  
        coefs = pca(X);
        Xpca = X*coefs;
        Xpca = Xpca(:,1:k);

        % Cluster Data
        try
            gm = fitgmdist(Xpca,2);
            kclust = cluster(gm,Xpca);
        catch
            err(fold) = 1;
            pred(part == fold) = 2;
            continue;
        end
%         kclust = kmeans(Xpca, 2);

        % Assign cluster lables
        clust1 = mode(ratings_train(kclust == 1));
        clust2 = mode(ratings_train(kclust == 2));

        clust = zeros(size(ratings_train));
        clust(kclust == 1) = clust1;
        clust(kclust == 2) = clust2;

%         fprintf('Cluster 1: %1d, Cluster 2: %2d \n', clust1, clust2);

        %% predict labels for test data
        feature_test = feature_vector(part == fold,:);
        ratings_test = ratings(part == fold,:);

        Xtest = bsxfun(@rdivide,bsxfun(@minus, feature_test, muX), sigmaX); 
        Xtest(isnan(Xtest)) = 0;
        XtestPca = Xtest*coefs;
        XtestPca = XtestPca(:,1:k);
        
        predictions = round(knn_test(t,feature_train, clust, feature_test));

        pred(part == fold) = predictions;
        err(fold) = mean(predictions ~= ratings_test);
        
        options = statset('Display','final');
        gm = fitgmdist(Xpca,2,'Options',options);
        idx = cluster(gm,Xpca);
        cluster1 = (idx == 1);
        cluster2 = (idx == 2);
        scatter(Xpca(cluster1,1),Xpca(cluster1,2),10,'r+');
        hold on
        scatter(Xpca(cluster2,1),Xpca(cluster2,2),10,'bo');
        hold off
        legend('Cluster 1','Cluster 2','Location','NW')
        pause
    end

    kerr(end+1) = mean(err);
    disp(kerr(end));
    preds(:,end+1) = pred;

end

figure(1);
clf;
plot(kerr,'bo');

figure(2);
clf;
[rsort, idx] = sort(ratings);
[~, maxidx] = min(kerr);
plot(rsort,'bo')
hold on
plot(preds(idx, maxidx), 'rx');
