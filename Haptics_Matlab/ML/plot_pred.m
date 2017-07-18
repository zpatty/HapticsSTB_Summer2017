function plot_pred(pred, ratings)

    domains = {'Depth Perception', 'Bimanual Dexterity', 'Efficiency', 'Force Sensitivity', 'Robotic Control'};
    nMetric = size(ratings,2);
    for i = 1:nMetric
        subplot(nMetric,1,i);

        if (nMetric == 5);
            title(domains{i});
            set(gca, 'Ytick', 1:5);
            ylabel({'GEARS';'Scores'})
            hold on;
        else
            set(gca, 'Ytick', 1:round(max(ratings)*1.1));
            ylabel('Combined GEARS')
        end

        hold on;

        [rPlot, idx] = sort(ratings(:,i));
        plot(rPlot,'bo');
        plot( pred(idx,i),'rx')
        ylim([0 1.1*rPlot(end)]);
        set(gca,'XTickLabel','', 'Xtick', [])
        grid on;    
    end
    % legend('Manual Rating', 'Predicted Rating', 'location', 'southeast')