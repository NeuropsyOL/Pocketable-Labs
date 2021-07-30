function send_eeg_and_markers()

% instantiate the library
disp('Loading library...');
lib = lsl_loadlib();

% make a new stream outlet
% the name (here MyMarkerStream) is visible to the experimenter and should be chosen so that
% it is clearly recognizable as your MATLAB software's marker stream
% The content-type should be Markers by convention, and the next three arguments indicate the
% data format (1 channel, irregular rate, string-formatted).
% The so-called source id is an optional string that allows for uniquely identifying your
% marker stream across re-starts (or crashes) of your script (i.e., after a crash of your script
% other programs could continue to record from the stream with only a minor interruption).

marker_info = lsl_streaminfo(lib,'MyTestMarkerStream','Markers',1,0,'cf_string','matlabtestmarkerstream');
eeg_info = lsl_streaminfo(lib,'MyTestEEGStream','EEG',8,100,'cf_float32','matlabtesteegstream');

disp('Opening marker and EEG outlet...');
marker_outlet = lsl_outlet(marker_info);
eeg_outlet = lsl_outlet(eeg_info);

% send markers and EEG data into the outlet
disp('Now transmitting marker and data...');
markers = {'These', 'are', 'markers', 'sent', 'from', 'Matlab'};
m = 1; % marker index to send them in order (to check whether some go missing)

% create some index so that we can determine when to send out markers
index = 0;
while index < 10^6

    % send out EEG samples with a sampling rate of 100 Hz
    current_sample = randn(8,1);
    %disp(current_sample)
    eeg_outlet.push_sample(current_sample);
    
    % sometimes, also send out a marker
    % coin_flip = rand(1,1);
    % if coin_flip > 0.99
    if mod(index,300) == 0
        % send markers in order and reset index if we reach end of array
        marker_outlet.push_sample({markers{m}});
        disp({markers{m}})
        if m < length(markers)
            m = m + 1;
        else
            m = 1;
        end
    end
    index = index + 1;
    pause(0.01);
end