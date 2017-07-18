close all;
% clearvars;

FstopHP = 50;
FpassHP = 150;
AstopHP = 65;
ApassHP = 0.5;
Fs = 3e3;
fHP = designfilt('highpassiir','StopbandFrequency',FstopHP ,...
  'PassbandFrequency',FpassHP,'StopbandAttenuation',AstopHP, ...
  'PassbandRipple',ApassHP,'SampleRate',Fs,'DesignMethod','butter');

FstopHHP = 750;
FpassHHP = 1000;
AstopHHP = 65;
ApassHHP = 0.5;
fHHP = designfilt('highpassiir','StopbandFrequency',FstopHHP ,...
  'PassbandFrequency',FpassHHP,'StopbandAttenuation',AstopHHP, ...
  'PassbandRipple',ApassHHP,'SampleRate',Fs,'DesignMethod','butter');

FstopLP = 100;
FpassLP = 50;
AstopLP = 65;
ApassLP = 0.5;
fLP = designfilt('lowpassiir','StopbandFrequency',FstopLP ,...
  'PassbandFrequency',FpassLP,'StopbandAttenuation',AstopLP, ...
  'PassbandRipple',ApassLP,'SampleRate',Fs,'DesignMethod','butter');


% data = STBData('SavedData', 'task', 1);
data = data(~cellfun(@(x)any(isempty(x)), {data.score}));
thresh_range = 100:10:200;
c = [];
ratings = [];
for i = 1:length(data)
    ratings(i,:) = mean(data(i).score,1);
end

timebar = CTimeleft(length(thresh_range));
clear acc1 acc1H acc1L acc2 acc2H acc2L acc3 acc3H acc3L accProd fAcc2Prod fAcc2Prod
for i = 1:length(thresh_range)
for t = 1:length(data);
		fMag = sqrt(sum(data(t).forces.^2,2));
		
		% seperate accelerometer signals into low and high frequency components
		acc1 = filtfilt(fHP,double(sum(data(t).acc1,2)));
% 		acc1H = filtfilt(fHHP,double(sum(data(t).acc1,2)));
% 		acc1L = filtfilt(fLP,double(sum(data(t).acc1,2)));
% 		acc2 = filtfilt(fHP,double(sum(data(t).acc2,2)));
% 		acc2H = filtfilt(fHHP,double(sum(data(t).acc2,2)));
% 		acc2L = filtfilt(fLP,double(sum(data(t).acc2,2)));
%         acc3 = filtfilt(fHP,double(sum(data(t).acc3,2)));
%         acc3H = filtfilt(fHHP,double(sum(data(t).acc3,2)));
% 		acc3L = filtfilt(fLP,double(sum(data(t).acc3,2)));
%         accProd = acc1.*acc3;
		fAcc1Prod = acc1.*fMag;
% 		fAcc2Prod = acc3.*fMag;
        		% event counters

        window = 600;
		overlap = 0;

        counts(i,t) = counter(fAcc1Prod, thresh_range(i), window, overlap, @(x)sum(x.^2));
        
end

c(i,:) = corr(counts(i,:)', ratings);
timebar.timeleft();
end
beep
plot(thresh_range,abs(c),'o-');

%% Recorded thresholds

% thresh1 = [60 400 100 3000 10];
% thresh2 = [1500 1400 600 5000 30];