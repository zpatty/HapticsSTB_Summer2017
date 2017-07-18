clear all; close all;

addpath('Stats')
[~, ~, raw] = xlsread('/Stats/SurveyResultsAllPhases.xls');
survey = cell2mat(raw(3:end,:));
questions = raw(2,3:end);

survey(survey(:,1)==2,:)=[]; % remove subject 2 from the analysis
survey(survey(:,1)==4,:)=[]; % remove subject 4 from the analysis

surveyA = survey(ismember(survey(:,1),[4,5,7,9,11,12]),:) % Group A results
surveyB = survey(ismember(survey(:,1),[3,6,8,10,13]),:) % Group B results

surveyAphase1avg = mean(surveyA(surveyA(:,2)==1,3:end),1);
surveyAphase2avg = mean(surveyA(surveyA(:,2)==2,3:end),1);
surveyAphase3avg = mean(surveyA(surveyA(:,2)==3,3:end),1);

surveyBphase1avg = mean(surveyB(surveyB(:,2)==1,3:end),1);
surveyBphase2avg = mean(surveyB(surveyB(:,2)==2,3:end),1);
surveyBphase3avg = mean(surveyB(surveyB(:,2)==3,3:end),1);

surveyAphase1std = std(surveyA(surveyA(:,2)==1,3:end),0,1);
surveyAphase2std = std(surveyA(surveyA(:,2)==2,3:end),0,1);
surveyAphase3std = std(surveyA(surveyA(:,2)==3,3:end),0,1);

surveyBphase1std = std(surveyB(surveyB(:,2)==1,3:end),0,1);
surveyBphase2std = std(surveyB(surveyB(:,2)==2,3:end),0,1);
surveyBphase3std = std(surveyB(surveyB(:,2)==3,3:end),0,1);

resultsAavg = [surveyAphase1avg;surveyAphase2avg;surveyAphase3avg];
resultsBavg = [surveyBphase1avg;surveyBphase2avg;surveyBphase3avg];

resultsAstd = [surveyAphase1std;surveyAphase2std;surveyAphase3std];
resultsBstd = [surveyBphase1std;surveyBphase2std;surveyBphase3std];

GroupA = [surveyA(:,1),1*ones(size(surveyA,1),1),surveyA(:,2:end)];
GroupB = [surveyB(:,1),2*ones(size(surveyB,1),1),surveyB(:,2:end)];

SqueezeSurveyR = [GroupA;GroupB];

% %%%%% removing Subject 4 Trial 1 %%%%%
% SqueezeSurveyR(SqueezeSurveyR(:,1)==4 & SqueezeSurveyR(:,3)==1,4:end) = NaN;

label = {'Sub','Group','Phase','Q1','Q2','Q3','Q4','Q5','Q6','Q7','Q8','Q9','Q10','Q11','Q12'};
SqueezeSurveyRTab = array2table(SqueezeSurveyR,'VariableNames',label);

writetable(SqueezeSurveyRTab,'Stats/SqueezeSurveyR.dat')

%% Plot figures

for i = 1:12

    h(i) = CreateFig;
    hold on
    errorbar(resultsAavg(:,i),resultsAstd(:,i))
    errorbar(resultsBavg(:,i),resultsBstd(:,i))
    legend('GroupA','GroupB')
    xlabel('Phase #');ylabel('Results')
    title(questions{i})
    PrintFig(h(i),strcat('RawFigs/SurveyQ',num2str(i),'ByGroup'),'pdf')

end


%% Extra Questions

addpath('Stats')
[~, ~, extra] = xlsread('/Stats/SurveyResultsExtraQuestions.xls');
surveyE = cell2mat(extra(2:end,:));
questions = extra(1,2:end);

surveyE(surveyE(:,1)==2,:)=[]; % remove subject 2 from the analysis
surveyE(surveyE(:,1)==4,:)=[]; % remove subject 4 from the analysis

