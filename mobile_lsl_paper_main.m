function [] = mobile_lsl_paper_main()
%
% mobile_lsl_paper_main.m--
% This is the main analysis script for the paper 'Lab Streaming Layer on Smartphones: Data Streaming
% and Data Recording'.
% In this script, the single analysis functions for all validation scenarios and the timing test can be called
% independently. 
%
% Other m-files required:   
%   load_xdf.m (e.g. from here https://github.com/xdf-modules/xdf-Matlab)
%
%
% Developed in Matlab 9.8.0.1359463 (R2020a) Update 1 on PCWIN64
% at University of Oldenburg.
% Sarah Blum (sarah.blum@uol.de), 2021-06-11 08:26
%-------------------------------------------------------------------------

% Set save_plots to false if plots should not be saved
save_plots = true;

% change to script directory, this is the root directory for all following directories
[filepath,name,ext] = fileparts(matlab.desktop.editor.getActiveFilename);
cd(filepath)

% temporarily add shared functions folder to path and remove them later
addpath(genpath('Shared_Functions'))

% Scenarios
cd([filepath, filesep, 'Scenario 1'])
sc1_analysis(save_plots)

cd([filepath, filesep, 'Scenario 2'])
sc2_analysis(save_plots)

cd([filepath, filesep, 'Scenario 3'])
sc3_analysis(save_plots)

cd([filepath, filesep, 'Timing'])
timing_analysis(save_plots)

[filepath,name,ext] = fileparts(matlab.desktop.editor.getActiveFilename);
cd(filepath)

% eventually, remove shared functions
rmpath(genpath('Shared_Functions'))

