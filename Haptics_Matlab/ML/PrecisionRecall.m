function [precision,recall,F1,M] = PrecisionRecall(Actual,Predicted)
    
    M = confusionmat(Actual,Predicted,'order',[1,2,3,4,5]);
    
    precision = diag(M') ./ sum(M',2);

    recall = diag(M') ./ sum(M',1)';
    
    check = isnan(precision)+~isnan(recall);
    
    precision(check==2)=0;
    
%     F1 = [];
    
    F1 = 2*(precision.*recall)./(precision+recall);
    
    F1(check==2)=0;

end


%% helpful links
% http://stackoverflow.com/questions/22915003/is-there-any-function-to-calculate-precision-and-recall-using-matlab
% http://www.mathworks.com/help/stats/confusionmat.html
