% execute in PhD/SENDA_and_RECORDA_files/Scenario 2 
samsung = plot_all_streams_quick(['SAMSUNG.xdf'], 'LabRecorder Android', false);
labrec = plot_all_streams_quick(['PC.xdf'], 'LabRecorder Win', false);


%% find same value automatically and determine the shift between recordings
% use one channel  
A = samsung{1}.time_series(1,:);
B = labrec{1}.time_series(1,:);

% find most similar value
len = min(length(A), length(B));
[val,index] = min(abs(A(1:len) - B(1:len)));

% time-stamp difference is difference 
actual_time_difference = samsung{1}.time_stamps(index) - labrec{1}.time_stamps(index);
% % what is wrong here
% if actual_time_difference < 0 % second stream is ahead in time
%     samsung{1}.time_stamps = samsung{1}.time_stamps + abs(actual_time_difference);
% else
%     % the first stream was ahead
%     labrec{1}.time_stamps = labrec{1}.time_stamps - abs(actual_time_difference);
% end

% plot data on same time axis

interval = [5000:10000];

f = figure;
p1 = plot(samsung{1}.time_stamps(interval), samsung{1}.time_series(1,interval), 'Color', [0, 0, 0, 0.2]); 
hold on
p2 = plot(labrec{1}.time_stamps(interval), labrec{1}.time_series(1,interval), 'Color', [0.5, 0.3, 0.1, 0.2]);
hold off

legend('samsung', 'labrec')
axis tight

% samsung stream is 13 sec ahead    

