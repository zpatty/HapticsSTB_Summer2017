function feat = staticFeatures(data)

	F1 = 150;
	F2 = 750;
	Fs = 3e3;
% 	fHP = designfilt('bandpassiir','StopbandFrequency',FstopHP ,...
% 	  'PassbandFrequency',FpassHP,'StopbandAttenuation',AstopHP, ...
% 	  'PassbandRipple',ApassHP,'SampleRate',Fs,'DesignMethod','butter');
    fHP = designfilt('bandpassfir','FilterOrder',20, ...
         'CutoffFrequency1',F1,'CutoffFrequency2',F2, ...
         'SampleRate',Fs);

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

    feat(length(data)) = struct();

	timebar = CTimeleft(length(data));
    k = 1;
	for t = 1:length(data)

		fMag = sqrt(sum(data(t).forces.^2,2));
		
		% seperate accelerometer signals into low and high frequency components
		acc1 = filtfilt(fHP,double(sum(data(t).acc1,2)));
		acc1H = filtfilt(fHHP,double(sum(data(t).acc1,2)));
		acc1L = filtfilt(fLP,double(sum(data(t).acc1,2)));
		acc2 = filtfilt(fHP,double(sum(data(t).acc2,2)));
		acc2H = filtfilt(fHHP,double(sum(data(t).acc2,2)));
		acc2L = filtfilt(fLP,double(sum(data(t).acc2,2)));
        acc3 = filtfilt(fHP,double(sum(data(t).acc3,2)));
        acc3H = filtfilt(fHHP,double(sum(data(t).acc3,2)));
		acc3L = filtfilt(fLP,double(sum(data(t).acc3,2)));
       
		%signal product features
		accProd = acc1.*acc3;
		fAcc1Prod = acc1.*fMag;
		fAcc2Prod = acc3.*fMag;
		
		% orienation features

        % find orientation from accelerometer
        [r1, p1] = acc_orientation(data(t).acc1);
        [r2, p2] = acc_orientation(data(t).acc2);
        [r3, p3] = acc_orientation(data(t).acc3);
        
        raw_features = {data(t).forces(:,1),data(t).forces(:,2),data(t).forces(:,3),fMag,...
            acc1,acc1H,acc1L,acc2,acc2H,acc2L,acc3,acc3H,acc3L,...
            accProd,fAcc1Prod,fAcc2Prod,...
            r1, p1, r2, p2, r3, p3, ...
            diff(r1), diff(p1), diff(r2), diff(p2), diff(r3), diff(p3)};
        
        feat(k).mean = extract_feature(@(x) mean(abs(x)), raw_features{:});
        feat(k).std = extract_feature(@std, raw_features{:});
        feat(k).min = extract_feature(@min, raw_features{:});
        feat(k).max = extract_feature(@max, raw_features{:});
        feat(k).max = extract_feature(@max, raw_features{:});
        feat(k).rms = extract_feature(@rms, raw_features{:});
        feat(k).tss = extract_feature(@(x) sum(x.^2), raw_features{:});

		%range
		feat(k).range = feat(k).max - feat(k).min;

		% Time
        feat(k).total_time = data(t).duration;
        feat(k).time = (find(fMag>0.25,1,'last') - find(fMag>0.25, 1))/3000;
        
        % add features for idle time at beginning
        % add feature for percentage of time active/idle
        
		% event counters
		thresh1 = [60 400 100 3000 10];
        thresh2 = [1500 1400 600 5000 30];
        
		window = 600;
		overlap = 0;
		feat(k).counts1 = zeros(13,1);
        feat(k).counts1(1) = counter(fMag, thresh1(1), window, overlap, @(x)sum(x.^2));
		feat(k).counts1(2) = counter(data(t).forces(:,1), thresh1(2), window, overlap, @(x)sum(x.^2));
		feat(k).counts1(3) = counter(data(t).forces(:,2), thresh1(2), window, overlap, @(x)sum(x.^2));
		feat(k).counts1(4) = counter(data(t).forces(:,3), thresh1(2), window, overlap, @(x)sum(x.^2));
		feat(k).counts1(5) = counter(acc1, thresh1(3), window, overlap, @(x)sum(x.^2));
		feat(k).counts1(6) = counter(acc1H, thresh1(3), window, overlap, @(x)sum(x.^2));
		feat(k).counts1(7) = counter(acc2, thresh1(4), window, overlap, @(x)sum(x.^2));
		feat(k).counts1(8) = counter(acc2H, thresh1(4), window, overlap, @(x)sum(x.^2));
		feat(k).counts1(9) = counter(acc3, thresh1(3), window, overlap, @(x)sum(x.^2));
		feat(k).counts1(10) = counter(acc3H, thresh1(3), window, overlap, @(x)sum(x.^2));
		feat(k).counts1(11) = counter(accProd, thresh1(4), window, overlap, @(x)sum(x.^2));
		feat(k).counts1(12) = counter(fAcc1Prod, thresh1(5), window, overlap, @(x)sum(x.^2));
		feat(k).counts1(13) = counter(fAcc2Prod, thresh1(5), window, overlap, @(x)sum(x.^2));

        feat(k).counts2 = zeros(13,1);
		feat(k).counts2(1) = counter(fMag, thresh2(1), window, overlap, @(x)sum(x.^2));
		feat(k).counts2(2) = counter(data(t).forces(:,1), thresh2(2), window, overlap, @(x)sum(x.^2));
		feat(k).counts2(3) = counter(data(t).forces(:,2), thresh2(2), window, overlap, @(x)sum(x.^2));
		feat(k).counts2(4) = counter(data(t).forces(:,3), thresh2(2), window, overlap, @(x)sum(x.^2));
		feat(k).counts2(5) = counter(acc1, thresh2(3), window, overlap, @(x)sum(x.^2));
		feat(k).counts2(6) = counter(acc1H, thresh2(3), window, overlap, @(x)sum(x.^2));
		feat(k).counts2(7) = counter(acc2, thresh2(4), window, overlap, @(x)sum(x.^2));
		feat(k).counts2(8) = counter(acc2H, thresh2(4), window, overlap, @(x)sum(x.^2));
		feat(k).counts2(9) = counter(acc3, thresh2(3), window, overlap, @(x)sum(x.^2));
		feat(k).counts2(10) = counter(acc3H, thresh2(3), window, overlap, @(x)sum(x.^2));
		feat(k).counts2(11) = counter(accProd, thresh2(4), window, overlap, @(x)sum(x.^2));
		feat(k).counts2(12) = counter(fAcc1Prod, thresh2(5), window, overlap, @(x)sum(x.^2));
		feat(k).counts2(13) = counter(fAcc2Prod, thresh2(5), window, overlap, @(x)sum(x.^2));

		% Extract ratings
        if size(data(t).score,1) == 1
            feat(k).gears = data(t).score';
        else
            for i = 1:size(data(t).score,1)
                feat(k).gears = data(t).score(i,:)';
                k = k+1;
                feat(k) = feat(k-1);
            end
        end
        
        k = k+1;

		% Update progess bar
		timebar.timeleft();

	end
end