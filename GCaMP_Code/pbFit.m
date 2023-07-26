function oSig = pbFit(iSig)
% Original file from Anatol Kreitzer Lab (2020) 
% modified by Rodrigo Paz (2023)
% Photobleach fit. This applies a double exponential to segments of the
% signal. 

x = [1:size(iSig,1)]'; % vector of frame indicies
f = fit(x,iSig,'exp2');
pb = (f.a)*exp(f.b.*x) + (f.c)*exp(f.d.*x);
% offset required? 
oSig = iSig./pb;



