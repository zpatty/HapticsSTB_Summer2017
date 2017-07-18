%%%%% Calculates the set of features.

function feat = staticFeatures(data,rounding)
% data = STBData('SavedData', 'task', 1,'subject',3);
% data = data(1);
% rounding = 1;

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
    fBP = designfilt('bandpassiir', 'FilterOrder', 8,...
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
	for t = 1:length(data)

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

%         [Acc1Tot,trunc] = proj321_OA(AccXzero(:,1),AccYzero(:,1),AccZzero(:,1));
%         [Acc2Tot,trunc] = proj321_OA(AccXzero(:,2),AccYzero(:,2),AccZzero(:,2));
%         [Acc3Tot,trunc] = proj321_OA(AccXzero(:,3),AccYzero(:,3),AccZzero(:,3));

        [Acc1Tot,trunc] = proj321_OA(AccX(:,1),AccY(:,1),AccZ(:,1));
        [Acc2Tot,trunc] = proj321_OA(AccX(:,2),AccY(:,2),AccZ(:,2));
        [Acc3Tot,trunc] = proj321_OA(AccX(:,3),AccY(:,3),AccZ(:,3));
        
        clear Acc
		
		% seperate accelerometer signals into low and high frequency components
		acc1 = filtfilt(fBP,Acc1Tot);
		acc1H = filtfilt(fHHP,Acc1Tot);
		acc1L = filtfilt(fLP,Acc1Tot);
		acc2 = filtfilt(fBP,Acc2Tot);
		acc2H = filtfilt(fHHP,Acc2Tot);
		acc2L = filtfilt(fLP,Acc2Tot);
        acc3 = filtfilt(fBP,Acc3Tot);
        acc3H = filtfilt(fHHP,Acc3Tot);
		acc3L = filtfilt(fLP,Acc3Tot);

%         acc1 = filtfilt(fHP,double(sum(data(t).acc1,2)));
% 		acc1H = filtfilt(fHHP,double(sum(data(t).acc1,2)));
% 		acc1L = filtfilt(fLP,double(sum(data(t).acc1,2)));
% 		acc2 = filtfilt(fHP,double(sum(data(t).acc2,2)));
% 		acc2H = filtfilt(fHHP,double(sum(data(t).acc2,2)));
% 		acc2L = filtfilt(fLP,double(sum(data(t).acc2,2)));
%         acc3 = filtfilt(fHP,double(sum(data(t).acc3,2)));
%         acc3H = filtfilt(fHHP,double(sum(data(t).acc3,2)));
% 		acc3L = filtfilt(fLP,double(sum(data(t).acc3,2)));

		%signal product features
		accHProd = acc1H.*acc3H;
		fAcc1HProd = acc1H.*fMag(1:trunc);
		fAcc2HProd = acc3H.*fMag(1:trunc);
        
        accProd = acc1.*acc3;
		fAcc1Prod = acc1.*fMag(1:trunc);
		fAcc2Prod = acc3.*fMag(1:trunc);
        
        accLProd = acc1L.*acc3L;
		fAcc1LProd = acc1L.*fMag(1:trunc);
		fAcc2LProd = acc3L.*fMag(1:trunc);
        
        

%         accProd = acc1.*acc3;
% 		fAcc1Prod = acc1.*fMag;
% 		fAcc2Prod = acc3.*fMag;
		% orientation features

        % find orientation from accelerometer
        [r1, p1] = acc_orientation(data(t).acc1);
        [r2, p2] = acc_orientation(data(t).acc2);
        [r3, p3] = acc_orientation(data(t).acc3);
        
       %%
        raw_featuresABS = {data(t).forces(:,1),data(t).forces(:,2),data(t).forces(:,3),fMag,... %force data and their magnitude 
            abs(acc1),abs(acc1H),abs(acc1L),abs(acc2),abs(acc2H),abs(acc2L),abs(acc3),abs(acc3H),abs(acc3L),... %acceleration data (total, high, low)
            abs(accHProd),abs(fAcc1HProd),abs(fAcc2HProd),abs(accProd),abs(fAcc1Prod),abs(fAcc2Prod),abs(accLProd),abs(fAcc1LProd),abs(fAcc2LProd),... %product features
            r1, p1, r2, p2, r3, p3, ... %orientation data (roll and pitch)
            diff(r1), diff(p1), diff(r2), diff(p2), diff(r3), diff(p3)}; %angular velocity data (roll rate and pitch rate)
        
        raw_features = {data(t).forces(:,1),data(t).forces(:,2),data(t).forces(:,3),fMag,... %force data and their magnitude 
            acc1,acc1H,acc1L,acc2,acc2H,acc2L,acc3,acc3H,acc3L,... %acceleration data (total, high, low)
            accHProd,fAcc1HProd,fAcc2HProd,accProd,fAcc1Prod,fAcc2Prod,accLProd,fAcc1LProd,fAcc2LProd... %product features
            r1, p1, r2, p2, r3, p3, ... %orientation data (roll and pitch)
            diff(r1), diff(p1), diff(r2), diff(p2), diff(r3), diff(p3)};
        
        feat(k).mean = extract_feature(@(x) mean(x), raw_featuresABS{:}); %compute mean of all features
        feat(k).std = extract_feature(@std, raw_features{:}); %compute standard dev of all features 
        feat(k).min = extract_feature(@min, raw_features{:}); %compute min of all features
        feat(k).max = extract_feature(@max, raw_features{:}); %compute max of all features 
%         feat(k).max = extract_feature(@max, raw_features{:}); %compute max of all features
        feat(k).rms = extract_feature(@rms, raw_features{:}); %compute rms of all features
        %feat(k).tss = extract_feature(@(x) sum(x.^2), raw_features{:}); %compute sum of squares of all features
        feat(k).tss = extract_feature(@(x) sum(bsxfun(@minus,x,mean(x)).^2), raw_features{:}); %compute sum of squares of all features

        %force integral
%         timeVec = 0:1/3000:data(1).duration;        
        feat(k).int = [extract_feature(@(x) trapz(0:1/3000:(length(x)-1)/3000,x), raw_featuresABS{1:22});... 
                       extract_feature(@(x) trapz(0:1/100:(length(x)-1)/100,x), raw_featuresABS{23:34})];
        
        
		%range
		feat(k).range = feat(k).max - feat(k).min; %compute range of all features

		% Time
        feat(k).total_time = data(t).duration; %compute total time of trial
        feat(k).time = (find(fMag>0.25,1,'last') - find(fMag>0.25, 1))/3000; %compute active trial time (based on force reading)
        
        feat(k).sqrt_total_time = sqrt(feat(k).total_time); % compute sqrt(time)
        feat(k).sqrt_time = sqrt(feat(k).time);
        
        feat(k).log_total_time = log10(feat(k).total_time);
        feat(k).log_time = log10(feat(k).time);
        % add features for idle time at beginning
        % add feature for percentage of time active/idle
        
%         [feature_vector, ratings] = featureVector(features)
%         coeff = pca(
        
		% event counters
		thresh1 = [60 400 100 3000 10]; % lower threshold 
        thresh2 = [1500 1400 600 5000 30]; % upper threshold
        
		window = 600;
		overlap = 0;
% 		feat(k).counts1 = zeros(13,1);
%         feat(k).counts1(1) = counter(fMag, thresh1(1), window, overlap, @(x)sum(x.^2)); % force mag thresh1 event counter
% 		feat(k).counts1(2) = counter(data(t).forces(:,1), thresh1(2), window, overlap, @(x)sum(x.^2)); % force x thresh1 event counter
% 		feat(k).counts1(3) = counter(data(t).forces(:,2), thresh1(2), window, overlap, @(x)sum(x.^2)); % force y thresh1 event counter
% 		feat(k).counts1(4) = counter(data(t).forces(:,3), thresh1(2), window, overlap, @(x)sum(x.^2)); % force z thresh1 event counter
% 		feat(k).counts1(5) = counter(acc1, thresh1(3), window, overlap, @(x)sum(x.^2)); % acc1 thresh1 event counter
% 		feat(k).counts1(6) = counter(acc1H, thresh1(3), window, overlap, @(x)sum(x.^2)); % acc1 high freq thresh1 event counter
% 		feat(k).counts1(7) = counter(acc2, thresh1(4), window, overlap, @(x)sum(x.^2)); % acc2 thresh1 event counter
% 		feat(k).counts1(8) = counter(acc2H, thresh1(4), window, overlap, @(x)sum(x.^2)); % acc2 high freq thresh1 event counter
% 		feat(k).counts1(9) = counter(acc3, thresh1(3), window, overlap, @(x)sum(x.^2)); % acc3 thresh1 event counter
% 		feat(k).counts1(10) = counter(acc3H, thresh1(3), window, overlap, @(x)sum(x.^2)); % acc3 high freq thresh1 event counter
% 		feat(k).counts1(11) = counter(accProd, thresh1(4), window, overlap, @(x)sum(x.^2)); % acc1*acc3 thresh1 event counter
% 		feat(k).counts1(12) = counter(fAcc1Prod, thresh1(5), window, overlap, @(x)sum(x.^2)); % fMag*acc1 thresh1 event counter
% 		feat(k).counts1(13) = counter(fAcc2Prod, thresh1(5), window, overlap, @(x)sum(x.^2)); % fMag*acc3 thresh1 event counter
% 
%         feat(k).counts2 = zeros(13,1);
% 		feat(k).counts2(1) = counter(fMag, thresh2(1), window, overlap, @(x)sum(x.^2));
% 		feat(k).counts2(2) = counter(data(t).forces(:,1), thresh2(2), window, overlap, @(x)sum(x.^2));
% 		feat(k).counts2(3) = counter(data(t).forces(:,2), thresh2(2), window, overlap, @(x)sum(x.^2));
% 		feat(k).counts2(4) = counter(data(t).forces(:,3), thresh2(2), window, overlap, @(x)sum(x.^2));
% 		feat(k).counts2(5) = counter(acc1, thresh2(3), window, overlap, @(x)sum(x.^2));
% 		feat(k).counts2(6) = counter(acc1H, thresh2(3), window, overlap, @(x)sum(x.^2));
% 		feat(k).counts2(7) = counter(acc2, thresh2(4), window, overlap, @(x)sum(x.^2));
% 		feat(k).counts2(8) = counter(acc2H, thresh2(4), window, overlap, @(x)sum(x.^2));
% 		feat(k).counts2(9) = counter(acc3, thresh2(3), window, overlap, @(x)sum(x.^2));
% 		feat(k).counts2(10) = counter(acc3H, thresh2(3), window, overlap, @(x)sum(x.^2));
% 		feat(k).counts2(11) = counter(accProd, thresh2(4), window, overlap, @(x)sum(x.^2));
% 		feat(k).counts2(12) = counter(fAcc1Prod, thresh2(5), window, overlap, @(x)sum(x.^2));
% 		feat(k).counts2(13) = counter(fAcc2Prod, thresh2(5), window, overlap, @(x)sum(x.^2));

		% Extract ratings
        if size(data(t).score,1) == 1
            feat(k).gears = data(t).score';
        else
            for i = 1:size(data(t).score,1)
                if rounding == 0
                    feat(k).gears = median(data(t).score',2); % if rated by more than 1 rater, treat as individual observation
                elseif rounding == 1
                    feat(k).gears = mean(data(t).score',2);
                end               
%                 k = k+1;
%                 feat(k) = feat(k-1); % copies previous features over
            end
        end
        
        k = k+1;

		% Update progess bar
		timebar.timeleft();

	end
end