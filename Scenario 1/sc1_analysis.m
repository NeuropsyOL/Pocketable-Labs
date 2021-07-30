function sc1_analysis(save_plots)
%
% sc1_analysis.m--
% In scenario 1, data were sent out from two physical smartphones to a PC. 
% On the phones, either a sine wave generator app was running (Scenario 1A), or sensor data 
% was streamed using Send-a (Scenario 1B). The sensor option was repeated with one, three and
% all available sensors.
%  
% Developed in Matlab 9.8.0.1359463 (R2020a) Update 1 on PCWIN64
% at University of Oldenburg.
% Sarah Blum (sarah.blum@uol.de), 2021-04-22 15:03
%-------------------------------------------------------------------------



% 1A: sine wave values 
plot_scatter = false;
compute_and_plot_correlation('Sine1.xdf', save_plots, plot_scatter)

% 1B: only one sensor 
plot_scatter = true;
compute_and_plot_correlation('sc1b-onesensor.xdf',  save_plots, plot_scatter);

% 1B: three sensors 
plot_scatter = true;
compute_and_plot_correlation('sc1b-manysensors.xdf',  save_plots, plot_scatter);

% 1B: all sensors (not included in paper)
%plot_scatter = true;
%compute_and_plot_correlation('sc1b_all_sensors.xdf',  save_plots,plot_scatter);
