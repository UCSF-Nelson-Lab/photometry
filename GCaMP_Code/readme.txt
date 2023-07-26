%% Edited by Rodrigo Paz (Alexandra Nelson Lab, UCSF) 26th July 2023

This set of functions extracts GCaMP Fiber Photometry data obtained with a TDT system 
and computes the number and amplitude of GCaMP transients over time. 

The experiment consists of MFB-lesioned 6-OHDA D1-cre or A2A-cre mice injected with 
cre-dependent GCaMP6f in dorsolateral striatum. Mice are placed in an open field arena and
the recording starts after 10 minutes of photobleaching (which is not recorded). 

Mice are recorded 30 minutes before levodopa injection, and 120 minutes after levodopa injection. 
The experiment includes video from 2 cameras and a TTL pulse from an arduino that 
indicates the moment of levodopa injection. AIMS (Abnormal involuntary movements) are scored during the recording

For more information about surgical implantation of fibers and experimental setup, see 
protocols.io/view/fiber-photometry-mouse-8epv59dbjg1b/v1

List of functions:
	photometryGCaMPdataExtraction.m : extracts data 
	CaTransientsDetection.m : analyze number and amplitude of GCaMP transients over time
	
Auxiliary functions needed: 
	TDTSDK functions (available at https://github.com/tdtneuro/TDTMatlabSDK)
	spect_filter.m
	isosbestic_correction.m
	pbFit.m