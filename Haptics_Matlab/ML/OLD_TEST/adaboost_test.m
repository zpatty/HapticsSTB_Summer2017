function [test_err, margins] = adaboost_test(boost, Yw_test, Ytest)
% Generates predictions for AdaBoost on new data.
%
% Usage:
%
%   TEST_ERR MARGINS = adaboost_test(BOOST, YW_TEST, YTEST)
%
% Returns the predictions by Adaboost given a weighted combination of weak
% learners stored in the struct BOOST. YW is the predictions of the same
% pool of weak learners for the new data.
n = size(Ytest,1);
T = numel(boost.h);
% Compute test error and margin
Yhat = zeros(size(Ytest, 1), 1);

test_err = zeros(1,T);
margins = cell(1, T);
t0 = CTimeleft(T);

for t = 1:T
    t0.timeleft();

    Yhat = Yhat + boost.alpha(t)*Yw_test(:,boost.h(t));% ADD THE t'th ROUND PREDICTIONS HERE
    
    test_err(t) = 1/n * sum(sign(Yhat) ~= Ytest);% YOUR CODE HERE
    margins{t} = 1/sum(boost.alpha(1:t)).* ...
        sum(repmat(boost.alpha(1:t),n,1).*Yw_test(:,boost.h(1:t)).*repmat(Ytest,1,t),2);% YOUR CODE HERE
end
