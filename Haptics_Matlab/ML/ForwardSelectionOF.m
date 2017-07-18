%%%%% Performs feature selection using SVM an stores the selected features
%%%%% in a cell named selectFeatures

%%%%% this version uses only selected features 

function ForwardSelectionOF(rounding,time,omit)
clearvars -except rounding time omit
addpath('LIBSVM');
addpath('glmnet_matlab');

if omit == 1 % PCA features removed
    filename1 = strcat('MLRunfeaturesMedNoPCA',num2str(time),'.mat');
    filename2 = strcat('featuresMeanNoPCA',num2str(time),'.mat');
elseif omit == 2 % force features removed
    filename1 = strcat('MLRunfeaturesMedNoForce',num2str(time),'.mat');
    filename2 = strcat('featuresMeanNoForce',num2str(time),'.mat');
elseif omit == 3 % PCA and force features removed
    filename1 = strcat('MLRunfeaturesMedNoForcePCA',num2str(time),'.mat');
    filename2 = strcat('featuresMeanNoForcePCA',num2str(time),'.mat');
end

if rounding == 0 % create/load feature set with median GEARS scores
    if ~exist(filename1,'file') % create feature set
        % load data and remove trials with NaN for scores
        if ~exist('data')
            data = STBData('SavedData', 'task', 1);
            data = data(~cellfun(@(x)any(isnan(x(:))), {data.score}));
        end
        % load demographic data and save subject ID and familiarity 
        num = xlsread('DemographicSurvey.xls');
        subjects = num(1:end, 5);
        fam = num(1:end, 11);
        
        % store the familiarity information in data
        for i = 1:length(data)
            data(i).fam = fam(subjects==data(i).subj_id);
        end

        % remove trials that haven't been rated yet
        data = data(~cellfun(@isempty, {data.score}));

        % compute features without rounding GEARS scores (median value
        % used)
        disp('Extracting Features...')
        features = staticFeaturesOF(data,rounding,omit);
        if omit == 2
            features = featurePCA(features);
        end
        save(filename1, 'features');
    else % load existing feature set 
        disp('Loading Features...')
        load(filename1);
        features = features(~cellfun(@isempty,{features.gears}));
    end
elseif rounding == 1 % create/load feature set with mean GEARS scores
    if ~exist(filename2,'file') % create feature set
        % load data and remove trials with NaN scores 
        if ~exist('data')
            data = STBData('SavedData', 'task', 1);
            data = data(~cellfun(@(x)any(isnan(x(:))), {data.score}));
        end
    
        % load demographic data and save subject ID and familiarity
        num = xlsread('DemographicSurvey.xls');
        subjects = num(1:end, 5);
        fam = num(1:end, 11);
    
         % store the familiarity information in data
        for i = 1:length(data)
            data(i).fam = fam(subjects==data(i).subj_id);
        end
    
        % remove trials that haven't been rated yet
        data = data(~cellfun(@isempty, {data.score}));
    
        % compute features without rounding GEARS scores (median value
        % used)
        disp('Extracting Features...')
        features = staticFeaturesOF(data,rounding,omit);
        if omit == 2
            features = featurePCA(features);
        end
        save(filename2, 'features');
    else % load existing feature set 
        disp('Loading Features...')
        load(filename2);
        features = features(~cellfun(@isempty,{features.gears}));
    end
end

% initialize variables
preds = [];
kept_pred = [];
final_idx = {};
final_index = {};
[feature_vector, ratings, index] = featureVector(features); % loads feature vector, ratings, and feature index
% ratings = floor(ratings);
% % ratings = round(ratings);
% ratings = sum(ratings,2);

for metric = 1:size(ratings, 2) % runs the feature selection for each metric
    features_test = feature_vector; %initializes the set of features to test to be the entire set
    features_kept = []; %initializes the features to keep to 0
    index_test = index; % name of features to test
    index_kept = {}; % kept features
    kept_idx = zeros(size(features_test,2),1); %initializes the variable to hold the index of kept features
    j = 1;
    lastErr = 100; %initialize the last error to be the max 100%
    for f = 1:size(feature_vector,2) %iterates through the entire set of features
        err = zeros(size(features_test,2),1); %initializes the error vector
        for i = 1:size(features_test,2) %iterates through the number of features being tested
            pred = svmXval([features_kept features_test(:,i)], ratings(:,metric)); %trains the SVM model using the kept features and a new feature
            err(i) = norm(pred- ratings(:,metric),1); %computes the error in the prediction 
        end
        [minErr, idx] = min(err); %finds the minimum error and which index it occurs at 
        features_kept = [features_kept features_test(:,idx)]; %stores the features that minimized the error
        index_kept = [index_kept index_test{idx}]; %stores the name of the features that minimized the error
        features_test(:,idx) = []; %remove kept features from features that still need testing
        index_test(idx) = []; %remove kept features name from testing set
        kept_idx(j) = idx; %stores the index of the kept features 
        j = j+1;
        
        if minErr > lastErr %stops program if error stops decreasing with new features
            break
        end
        lastErr = minErr; %stores current minimum error for comparison on next iteration
        disp(f);
    end

    kept_idx(j:end) = []; %removes extra placeholders for kept indexes
    final_idx{end+1} = kept_idx; %stores the indices of the kept features for a given metric
    final_index{end+1} = index_kept'; %stores the name the features that minimized error for a given metric
    kept_pred(:,metric) = svmXval(features_kept, ratings(:,metric)); %trains the SVM model using the kept features
end

% Store the slected feature index (searching by feature name) 
for i=1:length(final_index)
    metric_index = [];
    for j=1:length(final_index{i})
        metric_index(j) = find(strcmp(final_index{i}{j},index));
    end
    total_index{i} = metric_index;
end
selectFeatures = total_index;

if rounding == 0
    if omit == 1 % PCA features removed
        save(strcat('SelectFeaturesMedNoPCA',num2str(time),'.mat'),'selectFeatures')
    elseif omit == 2 % force features removed
        save(strcat('SelectFeaturesMedNoForce',num2str(time),'.mat'),'selectFeatures')
    elseif omit == 3 % PCA and force features removed
        save(strcat('SelectFeaturesMedNoForcePCA',num2str(time),'.mat'),'selectFeatures')
    end
elseif rounding == 1
    if omit == 1 % PCA features removed
        save(strcat('SelectFeaturesMeanNoPCA',num2str(time),'.mat'),'selectFeatures')
    elseif omit == 2 % force features removed
        save(strcat('SelectFeaturesMeanNoForce',num2str(time),'.mat'),'selectFeatures')
    elseif omit == 3 % PCA and force features removed
        save(strcat('SelectFeaturesMeanNoForcePCA',num2str(time),'.mat'),'selectFeatures')
    end
end

