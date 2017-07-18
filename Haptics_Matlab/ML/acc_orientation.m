function [pitch, roll] = acc_orientation(acc1)

h  = fdesign.lowpass('Nb,Na,F3dB', 8, 8, 1, 100);
lp = design(h, 'butter');


% need to look at decimate (lowpass filter before downsampling)
acc100Hz = [decimate(decimate(double(acc1(:,1)),10),3),decimate(decimate(double(acc1(:,2)),10),3),decimate(decimate(double(acc1(:,3)),10),3)];
accF = filtfilt(lp.sosMatrix,lp.ScaleValues, acc100Hz);
% accF = double(x.acc1(1:3:end,:));

accFn = accF./repmat(sqrt(sum(accF.^2,2)),1,3);

roll = atan2(accFn(:,2), accFn(:,3));
roll = filtfilt(lp.sosMatrix,lp.ScaleValues, double(roll));

pitch = atan2(-accFn(:,1), sqrt(sum(accFn(:,2:3).^2,2)));
pitch = filtfilt(lp.sosMatrix,lp.ScaleValues, double(pitch));