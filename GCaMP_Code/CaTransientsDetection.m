%% Detect the number and amplitude of transients before and after levodopa injection (TDT.TTL1)

%% Step 1: load manually TDT struct obtained with the function photometryGCaMPanalysis to the workspace

%% Step 2: Detect Ca transients (this section might take a while)

time = TDT.t;
CaSmooth = smooth(TDT.photoSig_correctedExpCorr, 100);  % smooth dF/F if necessary to reduce noise

init = find(time > 1, 1); % index de 1 segundo
k = 1;
j = 1;
h = 1;
start = 0;
for i=init:length(CaSmooth)

    secEnd = find(time > (time(i)+1), 1);       
    secStart = find(time > (time(i)-1), 1);    

    if start == 0
        if CaSmooth(i, 1) > 1.01                 % detects transients above 1% (cab be changed depending on the experiment)
            if mean(CaSmooth(i:secEnd, 1)) > 1    % if the signal stays high for 1 second
                Ca_start(k) = i-1;                % then it is a transient and it saves the timestamp
                k = k + 1;
                start = 1;                       % transient detected, so start = 1 (flag)
            end
        end
    else
        if CaSmooth(i,1) < 1.01                       % now detect the end of the transient
            if mean(CaSmooth(i:secEnd, 1)) < 1.01
                Ca_end(j) = i+1; 
                j = j + 1;
                start = 0;                 % transiend ended so flag start = 0
                maxCa(h) = max(CaSmooth(Ca_start(end):Ca_end(end)));   % save the amplitude of the transient (max dF/F)
                h = h+1;
            end
        end
    end
end
% Save the transient data inside a struct TDT.TRANSIENTS
TDT.TRANSIENTS.Ca_start = Ca_start;   % timestamps for the transient start
TDT.TRANSIENTS.Ca_end = Ca_end;       % timestamps for the transient end
TDT.TRANSIENTS.maxCa = maxCa;         % amplitude (in dF/F) of the transient

% Note that the timestamps for Ca_start is not exactly locked to the moment when the Ca signal starts increasing. 
% It corresponds, instead, to the time when the signal reaches the threshold of 1% change 
% Because GCaMP is slow, there might be a difference of hundreds of miliseconds to
% seconds between these 2 events.
% This code is meant to analyze the NUMBER of transients over time
%% Step 3: Plot dF/F and transients for quality check
time = TDT.t;
CaSmooth = smooth(TDT.photoSig_correctedExpCorr, 100);
figure;
plot(time,CaSmooth, 'LineWidth', 1)
hold on
scatter(time(TDT.TRANSIENTS.Ca_start), CaSmooth(TDT.TRANSIENTS.Ca_start), 'bo', 'filled')
hold on
scatter(time(TDT.TRANSIENTS.Ca_end), CaSmooth(TDT.TRANSIENTS.Ca_end), 'ro', 'filled')
xline(TDT.TTL1)
xlabel('Time(s)', 'FontSize', 18)
ylabel('Ca (dF/F)', 'FontSize', 18)
legend(['dF/F'], ['Transient starts'], ['Transient ends'], 'FontSize', 10)

%% Step 4: Bin number of transients in 1 min bin, with t=0 being levodopa injection
% Since levodopa was injected after 30 minutes of recordings and the
% recording lasted 120 min after levodopa, we will have 150 minutes (bins)

binnedTransientsNumber = zeros (1, 150);      % new data with number of transients in 1 min bin
binnedTransientsAmplitude = zeros (1, 150);  % new data with transient amplitude in 1 min bin
time = TDT.t;          % time
CaSmooth = smooth(TDT.photoSig_correctedExpCorr, 100);
DOPA = TDT.TTL1;      % timestamp for L_DOPA injection
fs = TDT.fs;          % sampling frequency

secInit = DOPA-60*30;

for k = 1:150
    A = repmat(secInit, [1 length(time)]);
    [minValue,closestIndex] = min(abs(A-time)); 
    AA = find(TDT.TRANSIENTS.Ca_start > closestIndex & TDT.TRANSIENTS.Ca_start < closestIndex+round(fs*60));
    numberT = numel(AA);
    binnedTransientsNumber(k) = numberT;

    D = find(Ca_start>closestIndex, 1, 'First');
    E = find(Ca_start>closestIndex+round(fs*60), 1, 'First');

    binnedTransientsAmplitude(k) = mean(maxCa(D:E));
    secInit = time(closestIndex+round(fs*60));
end
% Save the data inside the TDT struct
TDT.TRANSIENTS.binnedTransientsNumber = binnedTransientsNumber;
TDT.TRANSIENTS.binnedTransientsAmplitude = binnedTransientsAmplitude;


%% Step 5: Plot histograms with Transient number and amplitude over time
time = -30:1:119; % -30 min before L-DOPA inj, 0 = L-DOPA inj and 119 min after
figure
subplot(2,1,1) 
plot(time, TDT.TRANSIENTS.binnedTransientsNumber, 'LineWidth', 3)   % transient number
xlim([-29 120])
xlabel('Time From L-DOPA injection')
ylabel('Number of transients')

subplot(2,1,2)
plot(time, TDT.TRANSIENTS.binnedTransientsAmplitude, 'LineWidth', 3) % transient amplitude
xlim([-29 120])
xlabel('Time From L-DOPA injection')
ylabel('Amplitude of transients')

%% Save data inside the same mat file 
clearvars -except TDT
save(strcat(TDT.folder, '/', TDT.info.blockname));
