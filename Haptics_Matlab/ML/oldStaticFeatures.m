function feat = oldStaticFeatures(data)

	Fstop = 100;
	Fpass = 200;
	Astop = 65;
	Apass = 0.5;
	Fs = 3e3;
	d = designfilt('highpassiir','StopbandFrequency',Fstop ,...
	  'PassbandFrequency',Fpass,'StopbandAttenuation',Astop, ...
	  'PassbandRipple',Apass,'SampleRate',Fs,'DesignMethod','butter');

    feat(length(data)) = struct();

	timebar = CTimeleft(length(data));

	for t = 1:length(data)

		fMag = sqrt(sum(data(t).forces.^2,2));
		acc1 = filtfilt(d,double(sum(data(t).acc1,2)));
		acc2 = filtfilt(d,double(sum(data(t).acc3,2)));

		%signal product features
		accProd = acc1.*acc2;
		fAcc1Prod = acc1.*fMag;
		fAcc2Prod = acc2.*fMag;
		
        % means
		fXmean = mean(data(t).forces(:,1));
		fYmean = mean(data(t).forces(:,2));
		fZmean = mean(data(t).forces(:,3));
		fMagmean = mean(fMag);
		acc1mean = mean(abs(acc1));
		acc2mean = mean(abs(acc2));
		accPmean = mean(abs(accProd));
		fAcc1Pmean = mean(abs(fAcc1Prod));
		fAcc2Pmean = mean(abs(fAcc2Prod));

		feat(t).mean = ...
		[fXmean, fYmean, fZmean, fMagmean, acc1mean, acc2mean, accPmean, fAcc1Pmean, fAcc2Pmean]';

		% std deviations
		fXstd = std(data(t).forces(:,1));
		fYstd = std(data(t).forces(:,2));
		fZstd = std(data(t).forces(:,3));
		fMagstd = std(fMag);
		acc1std = std(acc1);
		acc2std = std(acc2);
		accPstd = std(accProd);
		fAcc1Pstd = std(fAcc1Prod);
		fAcc2Pstd = std(fAcc2Prod);

		feat(t).std = ...
		[fXstd, fYstd, fZstd, fMagstd, acc1std, acc2std, accPstd, fAcc1Pstd, fAcc2Pstd]';

		%mins
		fXmin = min(data(t).forces(:,1));
		fYmin = min(data(t).forces(:,2));
		fZmin = min(data(t).forces(:,3));
		fMagmin = min(fMag);
		acc1min = min(acc1);
		acc2min = min(acc2);
		accPmin = min(accProd);
		fAcc1Pmin = min(fAcc1Prod);
		fAcc2Pmin = min(fAcc2Prod);
		feat(t).min = ...
		[fXmin, fYmin, fZmin, fMagmin, acc1min, acc2min, accPmin, fAcc1Pmin, fAcc2Pmin]';

		%maxs
		fXmax = max(data(t).forces(:,1));
		fYmax = max(data(t).forces(:,2));
		fZmax = max(data(t).forces(:,3));
		fMagmax = max(fMag);
		acc1max = max(acc1);
		acc2max = max(acc2);
		accPmax = max(accProd);
		fAcc1Pmax = max(fAcc1Prod);
		fAcc2Pmax = max(fAcc2Prod);
		feat(t).max = ...
		[fXmax, fYmax, fZmax, fMagmax, acc1max, acc2max, accPmax, fAcc1Pmax, fAcc2Pmax]';

		%range
		feat(t).range = feat(t).max - feat(t).min;

		%RMS
		fXrms = rms(data(t).forces(:,1));
		fYrms = rms(data(t).forces(:,2));
		fZrms = rms(data(t).forces(:,3));
		fMagrms = rms(fMag);
		acc1rms = rms(acc1);
		acc2rms = rms(acc2);
		accPrms = rms(accProd);
		fAcc1Prms = rms(fAcc1Prod);
		fAcc2Prms = rms(fAcc2Prod);
		feat(t).rms = ...
		[fXrms, fYrms, fZrms, fMagrms, acc1rms, acc2rms, accPrms, fAcc1Prms, fAcc2Prms]';

		% TSS
		fXss = sum(data(t).forces(:,1).^2);
		fYss = sum(data(t).forces(:,2).^2);
		fZss = sum(data(t).forces(:,3).^2);
		fMagss = sum(fMag.^2);
		acc1ss = sum(acc1.^2);
		acc2ss = sum(acc2.^2);
		accPss = sum(accProd.^2);
		fAcc1Pss = sum(fAcc1Prod.^2);
		fAcc2Pss = sum(fAcc2Prod.^2);
		feat(t).ss = ...
		[fXss, fYss, fZss, fMagss, acc1ss, acc2ss, accPss, fAcc1Pss, fAcc2Pss]';

		% Time
		% CONVERT TO FORCE DETECTION
		feat(t).time = data(t).duration;

		%% IMPLEMENT COUNTERS LATER...
		thresh1 = [50, 60, 60, 15, 5, 20, 10, 50];
		thresh2 = [140, 10, 30, 10, 10, 80, 50, 20];
		window = 100;
		overlap = 0;
		feat(t).counts1 = zeros(8,1);
		feat(t).counts1(1) = counter(data(t).forces(:,1), thresh1(1), window, overlap, @(x)sum(x.^2));
		feat(t).counts1(2) = counter(data(t).forces(:,2), thresh1(2), window, overlap, @(x)sum(x.^2));
		feat(t).counts1(3) = counter(data(t).forces(:,3), thresh1(3), window, overlap, @(x)sum(x.^2));
		feat(t).counts1(4) = counter(acc1, thresh1(4), window, overlap, @(x)sum(x.^2));
		feat(t).counts1(5) = counter(acc2, thresh1(5), window, overlap, @(x)sum(x.^2));
		feat(t).counts1(6) = counter(accProd, thresh1(6), window, overlap, @(x)sum(x.^2));
		feat(t).counts1(7) = counter(fAcc1Prod, thresh1(7), window, overlap, @(x)sum(x.^2));
		feat(t).counts1(8) = counter(fAcc2Prod, thresh1(8), window, overlap, @(x)sum(x.^2));

        feat(t).counts2 = zeros(8,1);
		feat(t).counts2(1) = counter(data(t).forces(:,1), thresh2(1), window, overlap, @(x)sum(x.^2));
		feat(t).counts2(2) = counter(data(t).forces(:,2), thresh2(2), window, overlap, @(x)sum(x.^2));
		feat(t).counts2(3) = counter(data(t).forces(:,3), thresh2(3), window, overlap, @(x)sum(x.^2));
		feat(t).counts2(4) = counter(acc1, thresh2(4), window, overlap, @(x)sum(x.^2));
		feat(t).counts2(5) = counter(acc2, thresh2(5), window, overlap, @(x)sum(x.^2));
		feat(t).counts2(6) = counter(accProd, thresh2(6), window, overlap, @(x)sum(x.^2));
		feat(t).counts2(7) = counter(fAcc1Prod, thresh2(7), window, overlap, @(x)sum(x.^2));
		feat(t).counts2(8) = counter(fAcc2Prod, thresh2(8), window, overlap, @(x)sum(x.^2));

        
        feat(t).gears = data(t).fam;
		% Update progess bar
		timebar.timeleft();
	end
end