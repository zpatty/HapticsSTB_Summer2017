function plotAcc(obj, arg1, arg2)
    
for i = 1:length(obj)
    figure;
    clf;
        if nargin == 1
            ax1 = subplot(3,1,1);
            plot(obj(i).plot_time(1:1:end),obj(i).acc1(1:1:end,:));ylabel('Acc (g)');
            ax2 = subplot(3,1,2);
            plot(obj(i).plot_time(1:1:end),obj(i).acc2(1:1:end,:));ylabel('Acc (g)');
            ax3 = subplot(3,1,3);
            plot(obj(i).plot_time(1:1:end),obj(i).acc3(1:1:end,:));ylabel('Acc (g)');
            linkaxes([ax1 ax2 ax3], 'x');
            axis tight
        elseif nargin == 2
            if isscalar(arg1)
                switch arg1
                    case 1
                        plot(obj(i).plot_time,obj(i).acc1);
                    case 2
                        plot(obj(i).plot_time,obj(i).acc2);
                    case 3
                        plot(obj(i).plot_time,obj(i).acc3);
                end
                ylabel('Acc (g)')
            else
                range = round(arg1*3000)+1;
                if diff(range) <= 30
                    range = range(1):range(2);
                else
                    range = range(1):100:range(2);
                end
                ax1 = subplot(3,1,1);
                plot(obj(i).plot_time(range),obj(i).acc1(range,:));
                ax2 = subplot(3,1,2);
                plot(obj(i).plot_time(range),obj(i).acc2(range,:));
                ax3 = subplot(3,1,3);
                plot(obj(i).plot_time(range),obj(i).acc3(range,:));
                linkaxes([ax1 ax2 ax3], 'x');
                axis tight                
            end
        else
            if isscalar(arg1)
                acc = arg1;
                range = round(arg2*3000);
            else
                acc = arg2;
                range = round(arg1*3000)+1;
            end

            if diff(range) <= 30
                range = range(1):range(2);
            else
                range = range(1):100:range(2);
            end
                
            switch acc
                case 1
                    plot(obj(i).plot_time(range(1):range(2)), obj(i).acc1(range(1):range(2),:));
                case 2
                    plot(obj(i).plot_time(range(1):range(2)), obj(i).acc2(range(1):range(2),:));
                case 3
                    plot(obj(i).plot_time(range(1):range(2)), obj(i).acc3(range(1):range(2),:));
            end
        end
        axis tight
        ylabel('Acc (g)');
        xlabel('Time (s)')
        legend('Acc X', 'Acc Y', 'Acc Z');
        set(gcf, 'name',['STB Data (' num2str(obj(i).index) ') , Subject: ' num2str(obj(i).subj_id) ' Task: ' num2str(obj(i).task_id)])

end

end