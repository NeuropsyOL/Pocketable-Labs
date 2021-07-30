function [] = timing_analysis(save_plots)
%
% timing_analysis.m--
% For the timing test, we recorded two data streams at the same time: one stream contained keyboard
% events streamed by a little helper tool from the LSL repository [0]. The other stream was sent by
% SENDA running on the smartphone and it contained accelerometer data.
% In our test, we repeatedly hit the space bar of our keyboard with the phone while holding it
% sideways. Every hard contact of the phone with the space bar would create a marker in the input
% strea,m as well as a sharp and large event in the accelerometer sensor data.
% The marker time stamps are in this script compared to the time stamps corresponding to the peak of
% the accelerometer response.
% 
% [0] https://github.com/labstreaminglayer/App-Input
%
% Output arguments: 
%       - this function can output some plots, mainly for sanity check purposes if plot_now is set to
%       true
%       - additionally, it will print the lag (mean distance between marker and accelerometer response 
%       and jitter (std of the lag)
%
% Other m-files required:   
%       - load_xdf from here: https://github.com/xdf-modules/xdf-Matlab
%
%
% Developed in Matlab 9.8.0.1359463 (R2020a) Update 1 on PCWIN64
% at University of Oldenburg.
% Sarah Blum (sarah.blum@uol.de), 2021-04-22 15:09
%-------------------------------------------------------------------------

all = load_xdf('T4-30-4.xdf');
markers = all{1};
accelero = all{2};
% accelerometer channel which has the best orientation to detect the events
channel = 1;
sr = accelero.info.effective_srate;
plot_now = true;

% only keep those time stamps that correspond to 'SPACE pressed' and discard the following 'SPACE
% released' markers
indices = find(contains(markers.time_series,'SPACE pressed'));
markers.pressed_times = markers.time_stamps(indices);
markers.pressed_events = markers.time_series(indices);

% find peaks in accelerometer data
[pk_ampl, pk_indices] = findpeaks(accelero.time_series(channel,:), 'MinPeakHeight', 15,'MinPeakDistance', 20);

% if the sizes do not match, we missed peaks in the sensor data or we found too many. This is a
% rather weak test because it only checks the absolute amount of detected events, we could add a
% check for time difference between events and whether that matches the markers time differences
assert(size(pk_indices,2) == size(markers.pressed_events,2))

% metrics of timing test
lag = mean(abs(accelero.time_stamps(channel, pk_indices) - markers.pressed_times));
jitter = std(abs(accelero.time_stamps(channel, pk_indices) - markers.pressed_times));
disp(['Lag is ', num2str(round(lag*sr,2)), ' ms'])
disp(['Jitter is ', num2str(round(jitter*sr,2)), ' ms'])

%% only plots from here on
if plot_now
    % see whether data make sense
    figure;
    plot(accelero.time_stamps, accelero.time_series)
    hold on
    vline(markers.pressed_times, ':c', '')
    legend('Accelerometer X-Axis', 'Accelerometer Y-Axis', 'Accelerometer Z-Axis')
    axis tight

    % plot findpeaks 
    figure;
    findpeaks(accelero.time_series(channel,:), 'MinPeakHeight', 15, 'MinPeakDistance', 20);
    
    % look at the distribution of difference between marker and detected peaks
    figure;
    hist(accelero.time_stamps(pk_indices)*sr - markers.pressed_times*sr)
    title('Difference between detected peaks in accelerometer and keyboard markers [ms]')
    xlabel('Difference [ms]')
    ylabel('Count')
    if save_plots
        saveas(gcf, 'figs/timing_hist.png')
    end
    
    % plot some (randomly chosen) subsequent events with their corresponding marker
    figure('pos', [100,0,1000,1000])
    t = tiledlayout("flow");
    t.Title.String = 'Some subsequent events';
    epoch_size = 80; % samples
    % set seed to control random number generator used in randi()
    rng = 50;
    random_start_of_range = randi(100,1,1);
    how_many = 29;
    for e = random_start_of_range: random_start_of_range + how_many % size(markers.pressed_events,2)

        % define time area around the peak indices
        tv = pk_indices(e)-(epoch_size/2) : pk_indices(e)+(epoch_size/2);
        nexttile;
        plot(accelero.time_stamps(tv)/sr, accelero.time_series(channel,tv))
        hold on
        vline(markers.pressed_times(e)/sr, ':k', '')
        axis tight
        %ylim([-10, 100])
    end
    
    if save_plots
        saveas(gcf, 'figs/timing_some_trials.png')
    end
    
    % also, add an image for all events
    epoch_size = 20; % samples
    tv = zeros(1, epoch_size+1);
    C = zeros(size(markers.pressed_events,2), epoch_size+1);
    
    for im = 1: size(markers.pressed_events,2)

        % define time area around the peak indices
        tv = pk_indices(im)-(epoch_size/2) : pk_indices(im)+(epoch_size/2);
        C(im,:) = accelero.time_series(channel,tv);
        %plot(accelero.time_stamps(tv)/sr, accelero.time_series(channel,tv))
    end
    
    figure('pos', [100,100,600, 800])
    subplot(3,1,[1,2])
    %figure;imagesc(C ./ max(abs(C)));
    imagesc(C)
    title('All Accelerometer Responses to Keystrokes')
    ylabel('Trial')
    colorbar
    
    subplot(3,1,[3])
    plot(tv,C', 'color', [128,128,128]/255)
    hold on
    vline(tv(round(length(tv)/2)), 'k:')
    hold on
    plot(tv, mean(C,1), 'k')

    axis tight

    title('Averaged Accelerometer Response to Keystroke')
    ylabel('Amplitude')
    xlabel('Time')
    colorbar
         
%     % replace yticklabels, the amount of labels will depend on the size of the figure
%     handle = gca;
%     how_many = length(handle.YTick); 
%     %xticklabels(round(linspace((epoch_size/2)*-1, (epoch_size/2), how_many)))
%     xlabel('Time [samples]')
%     
    title('Timing Test Sensor Responses to Keystrokes')
    
    if save_plots
        saveas(gcf, 'figs/timing_image_new.png')
    end
end



end

