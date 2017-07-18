function cvpart = make_cv_partition(features)

[feature_vector, ratings] = featureVector(features);

for i = 1:size(ratings,2)
    cvpart{i} = cvpartition(ratings(:,i),'holdout',0.1);
end