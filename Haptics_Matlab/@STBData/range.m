function newObj = range(obj, r)
	if length(r) == 2
	    rangeIdx = (r(1)+1)*3000:r(2)+1*3000;
	else
		rangeIdx = r;
	end
    
    newObj(length(obj)) = STBData();

	for i = 1:length(obj)
        newObj(i) = obj(i);
 
        newObj(i).forces = obj(i).forces(rangeIdx,:);
        newObj(i).moments = obj(i).moments(rangeIdx,:);
        newObj(i).acc1 = obj(i).acc1(rangeIdx,:);
        newObj(i).acc2 = obj(i).acc2(rangeIdx,:);
        newObj(i).acc3 = obj(i).acc3(rangeIdx,:);
        newObj(i).plot_time = (0:length(rangeIdx)-1)/3000;
        newObj(i).duration = (length(rangeIdx)-1)/3000;
	end

end

