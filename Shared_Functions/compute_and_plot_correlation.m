function  compute_and_plot_correlation(fname, save_plots, plot_data)
    %
    % compute_and_plot_correlation.m--
    %
    % Input arguments: A valid xdf file recorded in our Scenario 1 which contains
    % data from SENDA or Sine Wave app running on two smartphones at the same time, 
    % recorded by the LabRecorder Windows.
    % For details please refer to the manuscript.
    %
    % Output arguments: This function creates a plot, displays it and conditionally saves it in a
    % figures folder. Additionally, the function computes correlation values between streams
    % of the same type which are displayed when executing function.
    %
    % Other m-files required:
    %       saveAllOpenFigs.m
    %       load_xdf.m (https://github.com/xdf-modules/xdf-Matlab)
    %
    % Developed in Matlab 9.8.0.1359463 (R2020a) Update 1 on PCWIN64
    % at University of Oldenburg.
    % Sarah Blum (sarah.blum@uol.de), 2021-03-03 14:40
    %-------------------------------------------------------------------------

    
    % figures are stored in this folder. create if it does not exist
    fig_folder = './figures';
    if ~exist(fig_folder, 'dir')
        mkdir(fig_folder);
    end


    % load file
    data = load_xdf([pwd,filesep,fname],...
        'HandleClockSynchronization', true,...
        'HandleJitterRemoval', true, ...
        'Verbose', false);
    data_uncorrected = load_xdf([pwd,filesep,fname],...
        'HandleClockSynchronization', true, ...
        'HandleJitterRemoval', false,...
        'Verbose', false);
    
    all_indices = find_matching_streams(data);
    disp(['Effective sampling rates: ', ...
        data{all_indices(1,1)}.info.name, ': ', ...
        num2str(data{all_indices(1,1)}.info.effective_srate), ' and ', ...
        data{all_indices(1,2)}.info.name, ' : ', ...
        num2str(data{all_indices(1,2)}.info.effective_srate)])
    
    % correlate all channels for every sensor between phones
    [c,L] = correlate_all_channels(data, all_indices, fname, plot_data);
    disp(['For Scenario: ', fname(1:end-4),':'])
    disp(['Correlation of ', num2str(c,5), ' between phones' ])
    disp(['Lag between recordings of ', num2str(L), ' samples'])
    
    % plot data
    if save_plots || plot_data
        if contains(fname, 'Sine')
            sine_wave_plot(data, data_uncorrected, c,L, fig_folder, fname, save_plots)
        else
            my_stream_plot(data, all_indices, c,L, fig_folder, fname, save_plots)
        end
    end
    %explore_sampling_rate_over_time(data, save_plots);
end


function explore_sampling_rate_over_time(data, save_plots)
    figure('pos', [100,100,800,900], 'rend','painters')
    sgtitle('Histogram of differences between time stamps (nominal sr = 250 Hz)')
    
    max_y = size(data{1}.time_stamps,2);
    
    subplot(2,2,1)
    hist(diff(data{1}.time_stamps))
    %title([data{1}.info.name])
    title('Phone 1') 
    xlim([0, 0.03])
    
    subplot(2,2,2)
    hist(diff(data{2}.time_stamps))
    %title([data{2}.info.name])
    title('Phone 2')
    xlim([0, 0.03])
    
    subplot(2,2,3)
    plot(diff(data{1}.time_stamps), '.')
    %title([data{1}.info.name])
    axis tight
    ylim([0.004 0.03])
    
    subplot(2,2,4)
    plot(diff(data{2}.time_stamps), '.')
    %title([data{2}.info.name])
    axis tight
    ylim([0.004 0.03])
    
    if save_plots
        saveas(gcf, './figures/1a_sr_over_time.png')
        close all
    end
    
end

% Helper function for a plot
function my_stream_plot(data, all_indices, sensor_correlations,lags, fig_folder, filename, save_plots)
    blue = [51, 107, 196]/255;
    orange = [222, 136, 24]/255;
    colors = {blue , orange};
    
    % create a new figure with nice renderer and defined size
    figure('pos', [100,100,800,900], 'rend','painters')
    sgtitle('Detrended sensor data');
    pl = 1; % subplot index
    for stream_indices = 1:size(all_indices,1)
        
        for phones = 1:2 % phones
            % information for the current data
            current_data = data{all_indices(stream_indices,phones)};
            color = colors{phones};
            whole_name = strsplit(current_data.info.name, ' ');
            name = whole_name{1};
            
            % plot
            subplot(size(all_indices,1),1,pl);
            p = plot(current_data.time_stamps,...
                detrend(current_data.time_series'), ...
                'Color', color ...
                );
            ylabel('Amplitude')
            title([name, ...
                ', correlation : ', num2str(round(sensor_correlations(stream_indices),2)), ...
                ', shift : ', num2str(lags(stream_indices)), ' sample(s)']);
            
            % plot sensor values from both phones into the same plot
            hold on
            axis tight
        end
        pl = pl + 1;
        
    end
    % add xlabel only for last plot, is the same for all of them
    xlabel('Time [samples]')
    hold off
    
    % save figure
    if save_plots
        %saveAllOpenFigs(fig_folder, [filename(1:end-4)])
        %close all
    end
end

