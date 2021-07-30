function [highest_correlation, shift] = correlate_all_channels(data, indices,fname,do_plot)
    %
    % correlate_all_channels.m--
    % Compute pairwise channel cross-correlation for every matching sensor.
    %
    % Input arguments:
    %       data: struct containing all recorded data
    %       indices: index-pairs for the matching sensors in both recordings
    %
    % Output arguments:
    %       highest_correlation: the maximum correlation between all channels for every sensor
    %       lag_between_devices_smpls: the lag at the highest correlation
    %
    %
    %
    % Developed in Matlab 9.8.0.1359463 (R2020a) Update 1 on PCWIN64
    % at University of Oldenburg.
    % Sarah Blum (sarah.blum@uol.de), 2021-05-11 08:19
    %-------------------------------------------------------------------------
    % compute correlation and lag for all channel combinations between both
    % recordings for all sensors. This function returns the highest correlation for every snesor type found
    % among all correlations of all channels. It also returns the matching lag at highest correlation.
    
    % the indices contain pairwise (phone 1 and 2) the same sensor data
    % accelerometer phone 1 and 2, then gyro phone 1 and 2 and so on
    for s = 1:size(indices,1)
        
        % extract sensor information
        str_parts = strsplit(data{indices(s,1)}.info.name, ' ');
        sensor_name = str_parts{1};
        
        % how many channel for this sensor
        nbchan = str2double(data{indices(s,1)}.info.channel_count);
        
        % trim all channel data from the current sensor from phone 1 and phone 2
        A = data{indices(s,1)}.time_series;
        T1 = data{indices(s,1)}.time_stamps;
        
        B = data{indices(s,2)}.time_series;
        T2 = data{indices(s,2)}.time_stamps;
        common_len_original_sr = min(length(A), length(B));
        
        % resample both signals to smaller sampling rate for cross-correlation only
        new_sr = min(round(data{indices(s,1)}.info.effective_srate),round(data{indices(s,2)}.info.effective_srate));
        
        % before we can resample, we need to make sure that signals are zero-centered, otherwise the
        % resample function might induce imprecisions. 
        A = A - mean(A,2);
        B = B - mean(B,2);
        
        % resample to new sampling rate
        [A_res, T1_res] = resample(double(A)', T1, new_sr);
        [B_res, T2_res] = resample(double(B)', T2, new_sr);
        
        % and trim both time series to common length 
        % by using the shorter data recording of the current sensor pair to define the common length
        common_len = min(length(A_res), length(B_res));
        A_res_trimmed = A_res(1:common_len, :)';
        B_res_trimmed = B_res(1:common_len, :)';
        T1_trimmed = T1_res(1:common_len);
        T2_trimmed = T2_res(1:common_len);
        
        % in the case of Scenario 2, trim more from beginnig and end since we recorded data in one
        % file that was not present in the other file. Therefore, the overall correlation is reduced
        % which is only an artefact of the later start of the recording for one file.
        if contains(fname, 'sc2') 
            cc = 1;
            for ii = 1: nbchan
                for jj = 1: nbchan
                    [my_c(cc,:), my_lags(cc,:)] = xcorr(double(A_res_trimmed(ii,1000:6000)),...
                                                        double(B_res_trimmed(jj,1000:6000)), 'coeff');
                    % store the maximum of the correlation (pos or neg) with its corresponding lag
                    [val(cc),lags(cc)] = max(abs(my_c(cc,:)));
                    % store the channelpairs for every comparison for later lookup which channelpair
                    % yielded the highest correlation
                    lookup_table_channelpairs(cc,:) = [ii, jj];
                    cc = cc+1;
                end
            end
            % one of the channels correlated the highest, return this as result
            [max_corr, channel_index] = max(val);
            % also store the lag between phone 1 and phone 2 corresponding to the highest correlation
            shift(s) = length(A_res_trimmed) - lags(channel_index);
            highest_correlation(s) =  max_corr;
        else
            % for all channel combinations, correlate channels from the phones: 1-1, 1-2, 1-3,...
            % this loop is used to determine the initial shift between signals.
            % this shift can then be applied to find the common beginning & end of the shorter measurement
            
            % initialize variables for the current data
            my_c = zeros(nbchan*nbchan, (size(A_res_trimmed,2)*2)-1);
            my_lags = zeros(nbchan*nbchan, (size(A_res_trimmed,2)*2)-1);
            val = zeros(1, nbchan*nbchan);
            lags = zeros(1, nbchan*nbchan);
            max_corr = Inf;
            channel_index = 0; % this will eventually contain the index of the channel pair with the highest corr
            cc = 1;
            for ii = 1: nbchan
                for jj = 1: nbchan
                    [my_c(cc,:), my_lags(cc,:)] = xcorr(double(A_res_trimmed(ii,:)),...
                                                        double(B_res_trimmed(jj,:)), 'coeff');
                    % store the maximum of the correlation (pos or neg) with its corresponding lag
                    [val(cc),lags(cc)] = max(abs(my_c(cc,:)));
                    % store the channelpairs for every comparison for later lookup which channelpair
                    % yielded the highest correlation
                    lookup_table_channelpairs(cc,:) = [ii, jj];
                    cc = cc+1;
                end
            end
            % one of the channels correlated the highest, return this as result
            [max_corr, channel_index] = max(val);
            % also store the lag between phone 1 and phone 2 corresponding to the highest correlation
            shift(s) = length(A_res_trimmed) - lags(channel_index);
            highest_correlation(s) =  max_corr;
        end
        
        % plot the channel with the highest correlation in time domain and as scatter plot
        if do_plot
           % corr_plot(A_res_trimmed,B_res_trimmed,T1_trimmed,T2_trimmed, ...
            %   lookup_table_channelpairs, channel_index,shift(s),max_corr, fname, sensor_name);
           
            % we want to plot the not-resampled data, but the original data!
            corr_plot(A(:, 1:common_len_original_sr),B(:, 1:common_len_original_sr),...
                T1(1:common_len_original_sr),T2(1:common_len_original_sr), lookup_table_channelpairs, ...
                channel_index,shift(s), max_corr, fname, sensor_name);
        end
    end
    
end

function corr_plot(A, B, T1,T2, channel_pairs, max_corr_i, shift, max_corr, fname, sensor_name)
    % skip step count, this sensor did not detect a step in the measurement
    if strcmp('StepCount', sensor_name)
        return
    end
    
    % in scenario 2 and 3, the validation recording was being conducted on a different device, 
    % therefore, the respective time stamps reflect the respective clock and they cannot be 
    % synced by LSL because they were recorded into two different files. 
    % In a normal recording, this would not be the case, every stream would then be recorded into
    % one single xdf file, thereby enabling normal LSL synchronization.
    % To plot them together, we have to align the signals
    % which we can do either by usinf the same time_stamps for both signals, or plot them here
    % without time information altogether
   
    range = (abs(shift))+1:round(length(A)/2); % plot some section, make sure not to run out of bounds
    figure('pos', [100,100,350,550], 'rend','painters')
    
    % plot on the same time scale if scenario 2 or 3 to align signals in the plot
    if contains(fname, 'sc2') || contains(fname, 'sc3')
        range = round(length(A)/4) : length(A);
        plot(T2(range), detrend(A(channel_pairs(max_corr_i),range))')
        hold on
        plot(T2(range), detrend(B(channel_pairs(max_corr_i),range))')
        axis tight
        legend('PC', 'Phone')
        xlabel('Time')
        ylabel('Amplitude')
        % a scatter plot does not make sense here, since the scatter does not take time into account. 
        % Therefore, the linear relation between strongly-deviated signals will always be low.         
        
        sgtitle({[sensor_name, ' correlation: ', num2str(max_corr)]})
        set(findall(gcf,'-property','FontSize'),'FontSize',12)
    % in any normal recording scenario, as for example in scenario 1, we can use the respective time
    % stamps and streams are aligned by LSL.
    else
        subplot(2,1,1)
        plot(T1(range), detrend(A(channel_pairs(max_corr_i),range))')
        hold on
        plot(T2(range), detrend(B(channel_pairs(max_corr_i),range))')
        axis tight
        xt = xticks;
        subplot(2,1,2)
        scatter(A(channel_pairs(max_corr_i),range), B(channel_pairs(max_corr_i),range), '.')
        axis square
        sgtitle({[sensor_name, ' signals from two sources on respective time axes'], ...
        [' highest correlating channel ', num2str(channel_pairs(max_corr_i,:)),...
        ' ( ', num2str(max_corr), ')'], ...
        [' at ', num2str(shift), ' samples']})
    end
    
%     % debug: demonstrate shift effect
%     figure;
%     subplot(2,2,1)
%     plot(A(1,[1:200]));hold on; plot(B(1,([1:200]+shift)));title('Shifted signal section')
%     subplot(2,2,2)
%     plot(A(1,[1:200]));hold on; plot(B(1,([1:200])));title('Non-Shifted signal section')
%     
%     subplot(2,2,3)
%     scatter( A(1,[1:length(A)-shift]), B(1,([1:length(B)-shift]+shift)));title('Shifted signals')
%     subplot(2,2,4)
%     scatter( A(1,[1:length(A)-shift]), B(1,([1:length(B)-shift])));title('Non-Shifted signals')
    
%     figure('pos', [100,100,500,800], 'rend','painters')
%     subplot(2,1,1)
%     plot(A(1,:))
%     hold on
%     plot(B(1,:))
%     title('Unshifted signals')
%     subplot(2,1,2)
%     plot(A(1,:))
%     hold on
%     plot(B(1,1+shift:end))
%     title('Shifted signals')
%     


    % figures are stored in this folder. create if it does not exist
    fig_folder = './figures';
    if ~exist(fig_folder, 'dir')
        mkdir(fig_folder);
    end
    saveas(gcf, [[fig_folder, filesep, fname(1:end-4)], sensor_name,  '_scatter_plot'])
    saveas(gcf, [[fig_folder, filesep, fname(1:end-4)], sensor_name, '_scatter_plot.png'])
    %close all
end