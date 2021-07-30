function [] = sc3_analysis(save_plots)
%
% sc3_analysis.m--
% In this scenario, Send-a and Record-a were running on the same smartphone while a validation recording was
% performed in parallel on the PC using LabRecorder.
% The phones were kept lying on a table for 30 minutes and sensor data were streamed and recorded.
% In our analysis, the xdf recorded by LabRecorder was compared with the xdf recorded by Record-a.
%
% Developed in Matlab 9.8.0.1359463 (R2020a) Update 1 on PCWIN64
% at University of Oldenburg.
% Sarah Blum (sarah.blum@uol.de), 2021-04-22 15:03
%-------------------------------------------------------------------------

% this was not part of the paper
% load_and_compare_PC_smartphone('sc3-pc-short.xdf', 'sc3-phone-short.xdf', save_plots)

% ALL GOOD
load_and_compare_PC_smartphone('sc3-pc-long.xdf', 'sc3-phone-long.xdf', save_plots)
