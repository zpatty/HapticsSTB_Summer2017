
function [err, max_err, near, exact] = check_err(pred, ratings, threshold)

% Function to print current error metrics, also prints out latex to make reports


err = sqrt(mean((pred(:)- ratings(:)).^2));
max_err = max(abs(pred(:) - ratings(:)));
near = mean(abs(pred(:)-ratings(:)) <= threshold);
exact = mean(abs(pred(:)-ratings(:)) == 0); 

% fprintf('%f & %f & %f \\\\ \\hline \n', err, max_err, near);
% fprintf('RMSE: %f, MAX: %f, FRAC WITHIN %d: %f, Exact: %f \n', err, max_err, threshold, near, exact);
