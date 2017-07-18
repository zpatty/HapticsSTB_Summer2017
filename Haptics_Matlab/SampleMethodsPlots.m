
clear all; close all;

data = STBData('SavedData','subject',3:13);
data = data(~cellfun(@(x)any(ismember(x(:),4)), {data.subj_id}));

i=4;

mag = data(i).mag;
pos = data(i).pos;
pos(pos<100) = 100;
pos(pos>150) = 150;
pos(mag<0.1) = 100;
time = data(i).plot_time;


h1 = CreateFig;

axes1 = axes('Parent',h1,'YTick',[0 0.1 1 2 3 4],'OuterPosition',[0 1/2 1 1/2],...
    'XColor',[1,1,1],'Fontname','Timesnewroman','FontSize',20,'YTickLabel',...
    {'0','','1','2','3','4'},'LineWidth',1);
xlim(axes1,[0 time(end)]);
 ylabel(axes1,'Force Magnitude (N)')
hold(axes1,'all')

axes2 = axes('Parent',h1,'YTick',[100 110 120 130 140 ceil(max(pos))],...
    'OuterPosition',[0 0 1 1/2],'Fontname','Timesnewroman',...
    'LineWidth',1,'FontSize',20);
xlim(axes2,[0 time(end)]); ylim(axes2,[floor(min(pos)) ceil(max(pos))])
xlabel(axes2,'Time (s)'); ylabel(axes2,'Servo Angle ($$^\circ$$)','Interpreter','latex')

hold(axes2,'all')

plot(time,mag,'Parent',axes1,'Color',[102,45,145]/255,'LineWidth',1)
plot(time,pos,'Parent',axes2,'Color',[247,147,30]/255,'LineWidth',1)
hline = refline(axes1,[0 0.1]);
set(hline,'Color',[0,0,0,0.5],'LineStyle','--','LineWidth',2)
text(axes1,0.3,0.3,'0.1N Threshold','Color',[0,0,0,0.5],'Fontname','Timesnewroman','FontSize',14)


PrintFig(h1,'RawFigs/SamplePerformance','pdf')
PrintFig(h1,'/Users/jeremybrown/Documents/Research_Documents/Penn_Haptics/Manuscripts/Conference/Brown2017-WHC-Squeeze/Figures/SamplePerformance','pdf')