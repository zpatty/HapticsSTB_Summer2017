clear all; close all;
addpath('Stats')

LatexFig = '/Users/jeremybrown/Documents/Research_Documents/Penn_Haptics/Manuscripts/Conference/Brown2017-WHC-Squeeze/Figures/';

[~, ~, raw] = xlsread('/Stats/SurveyResultsAllPhases.xls');
survey = cell2mat(raw(3:end,:));
questions = raw(2,3:end);

[~, ~, extra] = xlsread('/Stats/SurveyResultsExtraQuestions.xls');
surveyE = cell2mat(extra(2:end,:));
questions = extra(1,2:end);

surveyE(surveyE(:,1)==2,:)=[]; % remove subject 2 from the analysis
surveyE(surveyE(:,1)==4,:)=[]; % remove subject 4 from the analysis

%%

Q3GroupAAvg = [21.4000000,26.4000000,32.4000000];    
Q3GroupAStd = [3.4727511,4.3197222,3.4146742];

Q3GroupBAvg = [42.0000000,55.4000000,58.4000000];
Q3GroupBStd = [4.4271887,7.3661387,6.1040970];

h1 = CreateFig;

axes1 = axes('Parent',h1,'XTick',[1 2 3],'YTick',[0 20 40 60 80 100],...
    'Fontname','Timesnewroman','LineWidth',1,'FontSize',20,...
    'ActivePositionProperty','OuterPosition');
xlim(axes1,[0.5 3.5]); ylim(axes1,[0 100])
xlabel(axes1,'Phase #');ylabel(axes1,'Response')
hold(axes1,'all')
errorbar('Parent',axes1,[.99,1.99,2.99],Q3GroupAAvg,Q3GroupAStd,'Color',[237,31,36]/255,...
    'LineWidth',1,'Marker','o','MarkerSize',10,'MarkerFaceColor',[237,31,36]/255,'LineStyle','-')
errorbar('Parent',axes1,[1.01,2.01,3.01],Q3GroupBAvg,Q3GroupBStd,'Color',[57,83,164]/255,...
    'LineWidth',1,'Marker','^','MarkerSize',10,'MarkerFaceColor',[57,83,164]/255,'LineStyle','--')
str = questions{3};
whtspc = isspace(str);
linebreak = find(whtspc(1:42)==1,1,'last')
title(axes1,{str(1:linebreak),str(linebreak+1:end)})
PrintFig(h1,'RawFigs/SigStats/SurveyQ3ByPhase','pdf')
PrintFig(h1,strcat(LatexFig,'SurveyQ3ByPhase'),'pdf')

%%

Q4GroupAAvg = [63.0000000,68.400000,71.6000000];
Q4GroupAStd = [9.5864488,3.613862,3.6823905];

Q4GroupBAvg = [51.2000000,57.4000000,52.000000];
Q4GroupBStd = [5.3609701,5.6621551,6.268971];

h2 = CreateFig;
axes2 = axes('Parent',h2,'XTick',[1 2 3],'YTick',[0 20 40 60 80 100],...
    'Fontname','Timesnewroman','LineWidth',1,'FontSize',20,...
    'ActivePositionProperty','OuterPosition');
xlim(axes2,[0.5 3.5]); ylim(axes2,[0 100])
xlabel(axes2,'Phase #');ylabel(axes2,'Response')
hold(axes2,'all')
errorbar('Parent',axes2,[.99,1.99,2.99],Q4GroupAAvg,Q4GroupAStd,'Color',[237,31,36]/255,...
    'LineWidth',1,'Marker','o','MarkerSize',10,'MarkerFaceColor',[237,31,36]/255,'LineStyle','-')
errorbar('Parent',axes2,[1.01,2.01,3.01],Q4GroupBAvg,Q4GroupBStd,'Color',[57,83,164]/255,...
    'LineWidth',1,'Marker','^','MarkerSize',10,'MarkerFaceColor',[57,83,164]/255,'LineStyle','--')
str = questions{4};
whtspc = isspace(str);
linebreak = find(whtspc(1:42)==1,1,'last')
title(axes2,{str(1:linebreak),str(linebreak+1:end)})
PrintFig(h2,'RawFigs/SigStats/SurveyQ4ByPhase','pdf')
PrintFig(h2,strcat(LatexFig,'SurveyQ4ByPhase'),'pdf')

%%

Q6GroupAAvg = [24.000000,25.8000000,17.6000000];
Q6GroupAStd = [14.352700,10.8461975,4.6216880];

Q6GroupBAvg = [49.6000000,53.8000000,47.4000000];
Q6GroupBStd = [10.6985980,5.9531504,8.5708809];

h3 = CreateFig;
axes3 = axes('Parent',h3,'XTick',[1 2 3],'YTick',[0 20 40 60 80 100],...
    'Fontname','Timesnewroman','LineWidth',1,'FontSize',20,...
    'ActivePositionProperty','OuterPosition');
xlim(axes3,[0.5 3.5]); ylim(axes3,[0 100])
xlabel(axes3,'Phase #');ylabel(axes3,'Response')
hold(axes3,'all')
errorbar('Parent',axes3,[.99,1.99,2.99],Q6GroupAAvg,Q6GroupAStd,'Color',[237,31,36]/255,...
    'LineWidth',1,'Marker','o','MarkerSize',10,'MarkerFaceColor',[237,31,36]/255,'LineStyle','-')
errorbar('Parent',axes3,[1.01,2.01,3.01],Q6GroupBAvg,Q6GroupBStd,'Color',[57,83,164]/255,...
    'LineWidth',1,'Marker','^','MarkerSize',10,'MarkerFaceColor',[57,83,164]/255,'LineStyle','--')
str = questions{6};
whtspc = isspace(str);
linebreak = find(whtspc(1:42)==1,1,'last')
title(axes3,{str(1:linebreak),str(linebreak+1:end)})
PrintFig(h3,'RawFigs/SigStats/SurveyQ6ByPhase','pdf')
PrintFig(h3,strcat(LatexFig,'SurveyQ6ByPhase'),'pdf')

%%

Q7GroupAAvg = [50.8000000,50.4000000,57.8000000];
Q7GroupAStd = [12.6388291,7.3864741,9.3026878];

Q7GroupBAvg = [30.2000000,57.4000000,42.6000000];
Q7GroupBStd = [2.5961510,7.6262704,6.5391131];

h4 = CreateFig;
axes4 = axes('Parent',h4,'XTick',[1 2 3],'YTick',[0 20 40 60 80 100],...
    'Fontname','Timesnewroman','LineWidth',1,'FontSize',20,...
    'ActivePositionProperty','OuterPosition');
xlim(axes4,[0.5 3.5]); ylim(axes4,[0 100])
xlabel(axes4,'Phase #');ylabel(axes4,'Response')
hold(axes4,'all')
errorbar('Parent',axes4,[.99,1.99,2.99],Q7GroupAAvg,Q7GroupAStd,'Color',[237,31,36]/255,...
    'LineWidth',1,'Marker','o','MarkerSize',10,'MarkerFaceColor',[237,31,36]/255,'LineStyle','-')
errorbar('Parent',axes4,[1.01,2.01,3.01],Q7GroupBAvg,Q7GroupBStd,'Color',[57,83,164]/255,...
    'LineWidth',1,'Marker','^','MarkerSize',10,'MarkerFaceColor',[57,83,164]/255,'LineStyle','--')
str = questions{7};
whtspc = isspace(str);
linebreak = find(whtspc(1:42)==1,1,'last')
title(axes4,{str(1:linebreak),str(linebreak+1:end)})
PrintFig(h4,'RawFigs/SigStats/SurveyQ7ByPhase','pdf')
PrintFig(h4,strcat(LatexFig,'SurveyQ7ByPhase'),'pdf')

%%
Q8GroupAAvg = [64.2000000,66.000000,74.4000000];
Q8GroupAStd = [10.0169856,6.008328,5.2687759];

Q8GroupBAvg = [48.8000000,60.6000000,68.4000000];
Q8GroupBStd = [7.8128100,4.6540305,4.3657760];

h5 = CreateFig;
axes5 = axes('Parent',h5,'XTick',[1 2 3],'YTick',[0 20 40 60 80 100],...
    'Fontname','Timesnewroman','LineWidth',1,'FontSize',20,...
    'ActivePositionProperty','OuterPosition');
xlim(axes5,[0.5 3.5]); ylim(axes5,[0 100])
xlabel(axes5,'Phase #');ylabel(axes5,'Response')
hold(axes5,'all')
errorbar('Parent',axes5,[.99,1.99,2.99],Q8GroupAAvg,Q8GroupAStd,'Color',[237,31,36]/255,...
    'LineWidth',1,'Marker','o','MarkerSize',10,'MarkerFaceColor',[237,31,36]/255,'LineStyle','-')
errorbar('Parent',axes5,[1.01,2.01,3.01],Q8GroupBAvg,Q8GroupBStd,'Color',[57,83,164]/255,...
    'LineWidth',1,'Marker','^','MarkerSize',10,'MarkerFaceColor',[57,83,164]/255,'LineStyle','--')
str = questions{8};
whtspc = isspace(str);
linebreak = find(whtspc(1:42)==1,1,'last')
title(axes5,{str(1:linebreak),str(linebreak+1:end)})
PrintFig(h5,'RawFigs/SigStats/SurveyQ8ByPhase','pdf')
PrintFig(h5,strcat(LatexFig,'SurveyQ8ByPhase'),'pdf')

%%

Q11GroupAAvg = [83.0000000,85.0000000,79.600000];
Q11GroupAStd = [9.1651514,4.0743098,3.867816];

Q11GroupBAvg = [87.800000,80.0000000,69.6000000];
Q11GroupBStd = [3.638681,5.7619441,6.6902915];

h6 = CreateFig;
axes6 = axes('Parent',h6,'XTick',[1 2 3],'YTick',[0 20 40 60 80 100],...
    'Fontname','Timesnewroman','LineWidth',1,'FontSize',20,...
    'ActivePositionProperty','OuterPosition');
xlim(axes6,[0.5 3.5]); ylim(axes6,[0 100])
xlabel(axes6,'Phase #');ylabel(axes6,'Response')
hold(axes6,'all')
errorbar('Parent',axes6,[.99,1.99,2.99],Q11GroupAAvg,Q11GroupAStd,'Color',[237,31,36]/255,...
    'LineWidth',1,'Marker','o','MarkerSize',10,'MarkerFaceColor',[237,31,36]/255,'LineStyle','-')
errorbar('Parent',axes6,[1.01,2.01,3.01],Q11GroupBAvg,Q11GroupBStd,'Color',[57,83,164]/255,...
    'LineWidth',1,'Marker','^','MarkerSize',10,'MarkerFaceColor',[57,83,164]/255,'LineStyle','--')
str = questions{11};
whtspc = isspace(str);
linebreak = find(whtspc(1:42)==1,1,'last')
title(axes6,{str(1:linebreak),str(linebreak+1:end)})
PrintFig(h6,'RawFigs/SigStats/SurveyQ11ByPhase','pdf')
PrintFig(h6,strcat(LatexFig,'SurveyQ11ByPhase'),'pdf')

%%

IntMagGroupAAvg = [55.009906,28.8550387,27.8783096];
IntMagGroupAStd = [7.302244,5.1301720,3.4383831];
IntMagGroupBAvg = [16.3658587,6.1202013,8.404283];
IntMagGroupBStd = [2.3531342,2.0988626,1.306037];


h7 = CreateFig;
axes7 = axes('Parent',h7,'XTick',[1 2 3],...
    'Fontname','Timesnewroman','LineWidth',1,'FontSize',20,...
    'ActivePositionProperty','OuterPosition');
xlim(axes7,[0.5 3.5]); ylim(axes7,[0 80])
xlabel(axes7,'Phase #');ylabel(axes7,'Integral of Force Magnitude (Ns)')
hold(axes7,'all')
errorbar('Parent',axes7,[.99,1.99,2.99],IntMagGroupAAvg,IntMagGroupAStd,'Color',[237,31,36]/255,...
    'LineWidth',1,'Marker','o','MarkerSize',10,'MarkerFaceColor',[237,31,36]/255,'LineStyle','-')
errorbar('Parent',axes7,[1.01,2.01,3.01],IntMagGroupBAvg,IntMagGroupBStd,'Color',[57,83,164]/255,...
    'LineWidth',1,'Marker','^','MarkerSize',10,'MarkerFaceColor',[57,83,164]/255,'LineStyle','--')
PrintFig(h7,'RawFigs/SigStats/IntMagByPhase','pdf')
% PrintFig(h7,strcat(LatexFig,'IntMagByPhase'),'eps')


%%
TimeGroupAAvg = [163.2476593,173.6162572,142.323173];
TimeGroupAStd = [11.531171,16.9435524,13.4904690];
TimeGroupBAvg = [192.7854170,169.344491,137.5313797];
TimeGroupBStd = [36.5994679,34.0005844,28.9231072];

h8 = CreateFig;
axes8 = axes('Parent',h8,'XTick',[1 2 3],...
    'Fontname','Timesnewroman','LineWidth',1,'FontSize',20,...
    'ActivePositionProperty','OuterPosition');
xlim(axes8,[0.5 3.5]); %ylim(axes8,[0 100])
xlabel(axes8,'Phase #');ylabel(axes8,'Duration (s)')
hold(axes8,'all')
errorbar('Parent',axes8,[.99,1.99,2.99],TimeGroupAAvg,TimeGroupAStd,'Color',[237,31,36]/255,...
    'LineWidth',1,'Marker','o','MarkerSize',10,'MarkerFaceColor',[237,31,36]/255,'LineStyle','-')
errorbar('Parent',axes8,[1.01,2.01,3.01],TimeGroupBAvg,TimeGroupBStd,'Color',[57,83,164]/255,...
    'LineWidth',1,'Marker','^','MarkerSize',10,'MarkerFaceColor',[57,83,164]/255,'LineStyle','--')
PrintFig(h8,'RawFigs/SigStats/TimeByPhase','pdf')
% PrintFig(h8,strcat(LatexFig,'TimeByPhase'),'eps')

%%

Q13 = surveyE(:,2);
Q14 = surveyE(:,3);
Q15 = surveyE(:,4);

Q13Avg = mean(Q13);
Q13Std = std(Q13)/sqrt(length(Q13));
Q14Avg = mean(Q14);
Q14Std = std(Q14)/sqrt(length(Q14));
Q15Avg = mean(Q15);
Q15Std = std(Q15)/sqrt(length(Q15));

h9 = CreateFig;
axes9 = axes('Parent',h9,'XTick',[1 2 3],'XTickLabel',{'Q13','Q14','Q15'},...
    'YTick',[0 20 40 60 80 100],'Fontname','Timesnewroman','LineWidth',1,...
    'FontSize',20,'ActivePositionProperty','OuterPosition');
xlim(axes9,[0.5 3.5]); ylim(axes9,[0 100])
xlabel(axes9,'Additional Survey Questions');ylabel(axes9,'Response')
hold(axes9,'all')
errorbar('Parent',axes9,[Q13Avg,Q14Avg,Q15Avg],[Q13Std,Q14Std,Q15Std],'Color',[166,124,82]/255,...
    'LineWidth',1,'Marker','o','MarkerSize',10,'MarkerFaceColor',[166,124,82]/255,'LineStyle','none')
% errorbar('Parent',axes9,[1.01,2.01,3.01],Q11GroupBAvg,Q11GroupBStd,'Color',[57,83,164]/255,...
%     'LineWidth',1,'Marker','^','MarkerSize',10,'MarkerFaceColor',[57,83,164]/255,'LineStyle','--')
PrintFig(h9,'RawFigs/SigStats/SurveyQ131415','pdf')
PrintFig(h9,strcat(LatexFig,'SurveyQ131415'),'pdf')
% 
% 
