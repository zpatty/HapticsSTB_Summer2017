
data = STBData('SavedData', 'task', 1,'subject',3);
data = data(1);

% %% Design FIR bandpass filter
% F1 = 100;
% F2 = 750;
% Fs = 3e3;
% % 	fHP = designfilt('bandpassiir','StopbandFrequency',FstopHP ,...
% % 	  'PassbandFrequency',FpassHP,'StopbandAttenuation',AstopHP, ...
% % 	  'PassbandRipple',ApassHP,'SampleRate',Fs,'DesignMethod','butter');
% fHP = designfilt('bandpassfir','FilterOrder',20, ...
%      'CutoffFrequency1',F1,'CutoffFrequency2',F2, ...
%      'SampleRate',Fs);
% 
% %% Design IIR highpass filter
% FstopHHP = 750;
% FpassHHP = 1000;
% AstopHHP = 65;
% ApassHHP = 0.5;
% fHHP = designfilt('highpassiir','StopbandFrequency',FstopHHP ,...
%   'PassbandFrequency',FpassHHP,'StopbandAttenuation',AstopHHP, ...
%   'PassbandRipple',ApassHHP,'SampleRate',Fs,'DesignMethod','butter');
% 
% %% Design IIR lowpass filter
% FstopLP = 100;
% FpassLP = 50;
% AstopLP = 65;
% ApassLP = 0.5;
% fLP = designfilt('lowpassiir','StopbandFrequency',FstopLP ,...
%   'PassbandFrequency',FpassLP,'StopbandAttenuation',AstopLP, ...
%   'PassbandRipple',ApassLP,'SampleRate',Fs,'DesignMethod','butter');

    %% Design IIR bandpass filter
	Fs = 3000;  % Sampling Frequency
    FpassBP1 = 20;          % First Passband Frequency
    FpassBP2 = 100;         % Second Passband Frequency
    ApassBP  = 0.1;         % Passband Ripple (dB)
%       fHP = designfilt('bandpassiir','StopbandFrequency1',FstopHP1,...
%          'PassbandFrequency1',FpassHP1,'StopbandFrequency2',FstopHP2,...
%          'PassbandFrequency2',FpassHP2,'StopbandAttenuation1',AstopHP1,...
%          'StopbandAttenuation2',AstopHP2,'PassbandRipple',ApassHP,...
%          'SampleRate',Fs,'DesignMethod','butter','MatchExactly','stopband');
    fHP = designfilt('bandpassiir', 'FilterOrder', 8,...
        'PassbandFrequency1', FpassBP1, 'PassbandFrequency2', FpassBP2,...
        'PassbandRipple', ApassBP, 'SampleRate', Fs);

%     h  = fdesign.bandpass(Fstop1, Fpass1, Fpass2, Fstop2, Astop1, Apass, ...
%                       Astop2, Fs);
%     fHP = design(h, 'butter', 'MatchExactly', match);

    %% Design IIR highpass filter

    FstopHHP = 90;          % Stopband Frequency
    FpassHHP = 100;         % Passband Frequency
    AstopHHP = 65;          % Stopband Attenuation (dB)
    ApassHHP = 0.5;         % Passband Ripple (dB)
    
    fHHP = designfilt('highpassiir','StopbandFrequency',FstopHHP ,...
	  'PassbandFrequency',FpassHHP,'StopbandAttenuation',AstopHHP, ...
	  'PassbandRipple',ApassHHP,'SampleRate',Fs,'DesignMethod','butter',...
      'MatchExactly','passband');

%     % Construct an FDESIGN object and call its BUTTER method.
%     h  = fdesign.highpass(Fstop, Fpass, Astop, Apass, Fs);
%     fHHP = design(h, 'butter', 'MatchExactly', match);
    %% Design IIR lowpass filter

    FpassLP = 20;          % Passband Frequency
    FstopLP = 30;          % Stopband Frequency
    ApassLP = 0.5;         % Passband Ripple (dB)
    AstopLP = 65;          % Stopband Attenuation (dB)
   
    fLP = designfilt('lowpassiir','StopbandFrequency',FstopLP ,...
	  'PassbandFrequency',FpassLP,'StopbandAttenuation',AstopLP, ...
	  'PassbandRipple',ApassLP,'SampleRate',Fs,'DesignMethod','butter',...
      'MatchExactly','passband');
% 
%     % Construct an FDESIGN object and call its BUTTER method.
%     h  = fdesign.lowpass(Fpass, Fstop, Apass, Astop, Fs);
%     fLP = design(h, 'butter', 'MatchExactly', match);
%%
feat(length(data)) = struct();

timebar = CTimeleft(length(data));
k = 1;
t = 1;

fMag = sqrt(sum(data(t).forces.^2,2)); %force magnitude

Acc(:,:,1)  = double(data(t).acc1);
Acc(:,:,2)  = double(data(t).acc2);
Acc(:,:,3)  = double(data(t).acc3);

AccX = [Acc(:,1,1),Acc(:,1,2),Acc(:,1,3)];
AccY = [Acc(:,2,1),Acc(:,2,2),Acc(:,2,3)];
AccZ = [Acc(:,3,1),Acc(:,3,2),Acc(:,3,3)];

AccXzero = bsxfun(@minus, AccX, mean(AccX));
AccYzero = bsxfun(@minus, AccY, mean(AccY));
AccZzero = bsxfun(@minus, AccZ, mean(AccZ));

[Acc1TotZ,trunc] = proj321_OA(AccXzero(:,1),AccYzero(:,1),AccZzero(:,1));
[Acc2TotZ,trunc] = proj321_OA(AccXzero(:,2),AccYzero(:,2),AccZzero(:,2));
[Acc3TotZ,trunc] = proj321_OA(AccXzero(:,3),AccYzero(:,3),AccZzero(:,3));

[Acc1Tot,trunc] = proj321_OA(AccX(:,1),AccY(:,1),AccZ(:,1));
[Acc2Tot,trunc] = proj321_OA(AccX(:,2),AccY(:,2),AccZ(:,2));
[Acc3Tot,trunc] = proj321_OA(AccX(:,3),AccY(:,3),AccZ(:,3));

clear Acc
%%
% seperate accelerometer signals into low and high frequency components
acc1 = filtfilt(fHP,Acc1Tot);
acc1H = filtfilt(fHHP,Acc1Tot);
acc1L = filtfilt(fLP,Acc1Tot);
acc2 = filtfilt(fHP,Acc2Tot);
acc2H = filtfilt(fHHP,Acc2Tot);
acc2L = filtfilt(fLP,Acc2Tot);
acc3 = filtfilt(fHP,Acc3Tot);
acc3H = filtfilt(fHHP,Acc3Tot);
acc3L = filtfilt(fLP,Acc3Tot);
%%
%signal product features
accProd = acc1.*acc3;
fAcc1Prod = acc1.*fMag(1:trunc);
fAcc2Prod = acc3.*fMag(1:trunc);

% orientation features


% find orientation from accelerometer
[r1, p1] = acc_orientation(data(t).acc1);
[r2, p2] = acc_orientation(data(t).acc2);
[r3, p3] = acc_orientation(data(t).acc3);



%%
close all

h1=figure('Color',[1,1,1]);
fullscreen = get(0,'ScreenSize');
set(h1,'Position',[0 0 fullscreen(3) fullscreen(4)])
set(h1,'PaperOrientation','landscape');
set(h1,'PaperUnits','normalized');
set(h1,'PaperPosition', [0 0 1 1]);
hold on
plot(AccX(:,1))
plot(AccY(:,1))
plot(AccZ(:,1))
legend('XRaw','YRaw','ZRaw')
print(h1,'-dpdf','RawFigs/RawAccel');

h2=figure('Color',[1,1,1]);
fullscreen = get(0,'ScreenSize');
set(h2,'Position',[0 0 fullscreen(3) fullscreen(4)])
set(h2,'PaperOrientation','landscape');
set(h2,'PaperUnits','normalized');
set(h2,'PaperPosition', [0 0 1 1]);
hold on
plot(AccXzero(:,1))
plot(AccYzero(:,1))
plot(AccZzero(:,1))
legend('XZero','YZero','ZZero')
print(h2,'-dpdf','RawFigs/ZeroAccel')

h3=figure('Color',[1,1,1]);
fullscreen = get(0,'ScreenSize');
set(h3,'Position',[0 0 fullscreen(3) fullscreen(4)])
set(h3,'PaperOrientation','landscape');
set(h3,'PaperUnits','normalized');
set(h3,'PaperPosition', [0 0 1 1]);
hold on
plot(Acc1Tot)
legend('dft321')
print(h3,'-dpdf','RawFigs/dft321Accel')


h4=figure('Color',[1,1,1]);
fullscreen = get(0,'ScreenSize');
set(h4,'Position',[0 0 fullscreen(3) fullscreen(4)])
set(h4,'PaperOrientation','landscape');
set(h4,'PaperUnits','normalized');
set(h4,'PaperPosition', [0 0 1 1]);
hold on
plot(Acc1Tot)
plot(Acc1TotZ)
% plot(AccXzero(:,1))
% plot(AccYzero(:,1))
% plot(AccZzero(:,1))
plot(AccX(:,1))
plot(AccY(:,1))
plot(AccZ(:,1))
legend('dft321','dft321Z','XZero','YZero','ZZero')
print(h4,'-dpdf','RawFigs/dft321ZeroAccel')

h5=figure('Color',[1,1,1]);
fullscreen = get(0,'ScreenSize');
set(h5,'Position',[0 0 fullscreen(3) fullscreen(4)])
set(h5,'PaperOrientation','landscape');
set(h5,'PaperUnits','normalized');
set(h5,'PaperPosition', [0 0 1 1]);
hold on
plot(acc1H)
plot(acc1)
plot(acc1L)
legend('dft321HighFreq','dft321MidFreq','dft321LowFreq')
print(h5,'-dpdf','RawFigs/dft321AccelHML')

h6=figure('Color',[1,1,1]);
fullscreen = get(0,'ScreenSize');
set(h6,'Position',[0 0 fullscreen(3) fullscreen(4)])
set(h6,'PaperOrientation','landscape');
set(h6,'PaperUnits','normalized');
set(h6,'PaperPosition', [0 0 1 1]);
hold on
plot(r1)
plot(p1)
legend('roll','pitch')
print(h6,'-dpdf','RawFigs/RollPitch')
