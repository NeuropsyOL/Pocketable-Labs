function [] = sc2_analysis(save_plots)
%
% sc2_analysis.m--
% In this scenario, data were sent from a PC running a custom Matlab script:
% Shared_Functions/send_eeg_and_markers.m
% Data were recorded by Record-a and LabRecorder simultaneously.
% In our analysis, we compare data recorded on PC and on phone and expect a high correlation if
% Record-a records the same way LabRecorder does.
%
%
% Developed in Matlab 9.8.0.1359463 (R2020a) Update 1 on PCWIN64
% at University of Oldenburg.
% Sarah Blum (sarah.blum@uol.de), 2021-04-22 15:02
%-------------------------------------------------------------------------

% ALL GOOD
save_plots = save_plots;
load_and_compare_PC_smartphone('sc2-PC.xdf', 'sc2-PHONE.xdf', save_plots);
