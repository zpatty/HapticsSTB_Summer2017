
if ~exist('data', 'var')
data = STBData('SavedData', 'task', 1, 'subject',3);
end

FstopHP = 100;
FpassHP = 200;
AstopHP = 65;
ApassHP = 0.5;
Fs = 3e3;
fHP = designfilt('highpassiir','StopbandFrequency',FstopHP ,...
  'PassbandFrequency',FpassHP,'StopbandAttenuation',AstopHP, ...
  'PassbandRipple',ApassHP,'SampleRate',Fs,'DesignMethod','butter');


% d = filtfilt(fHP, double(sum(data(1).acc1,2)));
% d = sqrt(sum(data(1).forces.^2,2));
% d = data(1).forces(:,1);
acc1 = filtfilt(fHP,double(sum(data(1).acc1,2)));
acc3 = filtfilt(fHP,double(sum(data(1).acc3,2)));
fMag = sqrt(sum(data(1).forces.^2,2));

% d = acc1.*acc3;
d = fMag.*acc1;
thresh = 50;
window = 600;
overlap = 0;
func = @(x)sum(x.^2);


[c, loc, winds] = counter(d, thresh, window, overlap, func);

windsPlot = repmat(winds, 1,window - overlap)';

figure(1);
clf;
plot(d);
hold on;
plot([loc loc]', repmat([-1 1], length(loc),1)','ko', 'linewidth', 0.5);

