function photoSig = isosbestic_correction(photoSig,isoSig)
% performs isosbestic correction and returns photoSig with dF/F
% Takes input from demodulated signal (spect_filter.m)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REMOVE OUTLIERS TO GET BEST FIT: (SO I DON'T FIT SHIT THAT HAPPENS WHEN
% TDT IS TURNED ON/OFF:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
z_sig = zscore(photoSig);
z_iso = zscore(isoSig);
a = find(z_sig<-10 | z_sig>10);
b = find(z_iso<-10 | z_iso>10);
rmIdx = union(a,b);
caSig_rm = photoSig; %caSig_rm(rmIdx) = []; % Removing signal >10std below mean
iso_rm = isoSig; %iso_rm(rmIdx) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIT SIGNAL AND GET dF/F
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b = glmfit(iso_rm,caSig_rm);
iso_scaled = b(1) + isoSig*b(2);
photoSig = 1 + (photoSig-iso_scaled)./iso_scaled;

