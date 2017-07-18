function plotForces(obj, range)
    for i = 1:length(obj)
%         CreatFig
        clf;
            if nargin == 1
            	plot(obj(i).plot_time,obj(i).forces);
            else
            	range = range*3000+1;
            	plot(obj(i).plot_time(range(1):range(2)), obj(i).forces(range(1):range(2),:));
            end
        
        axis tight
        ylabel('Force (N)')
        xlabel('Time (s)')
    	legend('Force X', 'Force Y', 'Force Z');
        set(gcf, 'name',['STB Data (' num2str(obj(i).index) ') , Subject: ' num2str(obj(i).subj_id) ' Task: ' num2str(obj(i).task_id)])
    end
end