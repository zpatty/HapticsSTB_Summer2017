function plotMom(obj, range)
    for i = 1:length(obj)
%         figure;
%         clf;
        if nargin == 1
        	plot(obj.plot_time,obj.moments);
        else
        	range = round(range*3000)+1;
        	plot(obj.plot_time(range(1):range(2)), obj.moments(range(1):range(2),:));
        end
        axis tight
        ylabel('Moment (N/m)')
        xlabel('Time (s)')
    	legend('Moment X', 'Moment Y', 'Moment Z');
        set(gcf, 'name',['STB Data (' num2str(obj(i).index) ') , Subject: ' num2str(obj(i).subj_id) ' Task: ' num2str(obj(i).task_id)])

    end
end