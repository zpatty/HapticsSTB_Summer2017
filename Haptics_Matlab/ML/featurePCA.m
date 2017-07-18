%%%%% Computes the PCA of the feature set then addes the first three
%%%%% features to the set

function feat = featurePCA(features)

    [feature_vector, ratings, index] = featureVector(features);
    [coeff,score,latent,tsquared,explained] = pca(feature_vector);

    pc1 = score(:,1);
    pc2 = score(:,2);
    pc3 = score(:,3);

    for i = 1:length(features)
        features(i).pc1 = pc1(i);
        features(i).pc2 = pc2(i);
        features(i).pc3 = pc3(i);
    end
    
    feat = features;
end