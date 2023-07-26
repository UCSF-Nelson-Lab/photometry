%% This code reads photometry data (acquired with a TDT system), extracts GCaMP and isosbestic signals, performs isosbestic correction and
% corrects for photobleaching using an exponential decay function. It also
% extracts TTL pulses from 2 cameras and an arduino. 
% This code is intended to work with 3 hour-long files 

% functions needed: 
% TDTSDK functions (available at https://github.com/tdtneuro/TDTMatlabSDK)
% spect_filter.m
% isosbestic_correction.m
% pbFit.m

%% Step 1: Extract TDT data 
folder = 'E:\LID_project\Photometry\Data\rp230306d\rp230306d-230501-102749'; % folder containing TDT data
% folder = uigetdir('E:\LID_project\Photometry\Data'); Can also use this function
Data.fulldata = TDTbin2mat(folder);    %TDTbin2mat (function provided by TDT) reads TDT data into matlab

%% Step 2: Extract GCaMP and isosbestic signal
[spectTimes,photoSig,isoSig] = spect_filter(Data.fulldata); % extract data
fs = double(1/nanmedian(diff(spectTimes)));   % sampling frequency
TDT.photoSig = photoSig;   % GCaMP
TDT.isoSig = isoSig;  % isosbestic
TDT.t = spectTimes;   % timestamps for GCaMP and isosbestic
%% Step 3: Perform isosbestic correction
TDT.photoSig_corrected = isosbestic_correction(TDT.photoSig,TDT.isoSig);
%% Step 4: Perform exponential correction (photobleaching) 
TDT.photoSig_correctedExpCorr = pbFit(TDT.photoSig_corrected);
%% Setp 5: Save data into TDT struct
TDT.fs = fs;                                 % sampling frequency
TDT.folder = folder;                         % folder with raw TDT data
TDT.info = Data.fulldata.info;               % metadata
TDT.Cam1 = Data.fulldata.epocs.Cam1.onset;   % Timestamps of TTLs for Cam1
TDT.Cam2 = Data.fulldata.epocs.Cam2.onset;   % Timestamps of TTLs for Cam2
TDT.TTL1 = Data.fulldata.epocs.TTL1.onset;   % Timestamps of TTLs for Arduino
%% Step 6: Plot data for quality check
figure;
subplot(4,1,1)
plot(TDT.t, TDT.photoSig)
xlabel('Time (s)')
ylabel('F')
title('GCaMP')
subplot(4,1,2)
plot(TDT.t, TDT.isoSig)
xlabel('Time (s)')
ylabel('F')
title('Isosbestic')
subplot(4,1,3)
plot(TDT.t, TDT.photoSig_corrected)
xlabel('Time (s)')
ylabel('dF/F')
title('dF/F')
subplot(4,1,4)
plot(TDT.t, TDT.photoSig_correctedExpCorr)
xlabel('Time (s)')
ylabel('dF/F')
title('dF/F exponential correction')
%% Step 7: Save data
% data will be saved inside the same folder of the TDT raw data and with
% the name of the recording 
clearvars -except TDT
save(strcat(TDT.folder, '/', TDT.info.blockname));




