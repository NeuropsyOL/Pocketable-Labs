function [] = sine_wave_plot(data_corrected, data_uncorrected, sensor_correlations,lags, fig_folder, filename, save_plot)
%
% Developed in Matlab 9.8.0.1359463 (R2020a) Update 1 on PCWIN64
% at University of Oldenburg.
% Sarah Blum (sarah.blum@uol.de), 2021-06-11 09:28
%-------------------------------------------------------------------------

    blue = [51, 107, 196]/255;
    orange = [222, 136, 24]/255;
    colors = {blue , orange};
    
    r = 100:900;
    
    % create a new figure with nice renderer and defined size
    figure('pos', [100,100,700,400], 'rend','painters')
    %sgtitle('Sine wave signal from both phones');
    sgtitle(['Segment of sine wave signals from both phones.']);
    

    subplot(2,1,1)
    plot(data_corrected{1}.time_stamps(r), data_corrected{1}.time_series(5,r))
    hold on
    plot(data_corrected{1}.time_stamps(r), data_corrected{2}.time_series(5,r))
    axis tight
    title('Data plotted on the same time scale.')
    
    subplot(2,1,2)
    plot(data_uncorrected{1}.time_stamps(r), data_uncorrected{1}.time_series(5,r))
    hold on
    plot(data_uncorrected{2}.time_stamps(r), data_uncorrected{2}.time_series(5,r))
    axis tight
    title('Data plotted on their respective time scales, showing deviation over time.')
    
    % save figure
    if save_plot
        saveAllOpenFigs(fig_folder, [filename(1:end-4), '_sc1_sine_waves_deviation'])
    end
end