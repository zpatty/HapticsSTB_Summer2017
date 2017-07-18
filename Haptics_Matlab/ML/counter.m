function [count, loc, winds] = counter(data, threshold, window, overlap, fun)
if nargin <= 3
    overlap = 0;
end
if nargin <= 4
	fun = @mean;
end

winDisp = window - overlap;
numWins = floor((length(data) - window)/winDisp);

count = 0;
loc = zeros(numWins, 1);
winds = zeros(numWins, 1);
% timebar = CTimeleft(numWins);
for i = 0:numWins-1
    winds(i+1) = fun(data((1:window)+winDisp*i));
	if  winds(i+1) >= threshold
		count = count + 1;
		loc(count) = 1+winDisp*i;
    end
%     timebar.timeleft();
end

loc(count+1:end) = [];




