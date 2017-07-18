function [vector] = extract_feature(feature_fun, varargin)
	
	vector = zeros(length(varargin), 1);

	for i = 1:length(varargin)
		vector(i) = feature_fun(varargin{i});
    end
end