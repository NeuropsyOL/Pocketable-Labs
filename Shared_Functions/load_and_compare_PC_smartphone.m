function [] = load_and_compare_PC_smartphone(file_one, file_two, save_plots)
    %
    % load_and_compare_PC_smartphone.m--
    % One file contains data recorded with the LabRecorder Windows (file_PC), the other
    % file contains data recorder with our Android recorder app (file_phone).
    % This script loads both files and computes a correlation between data on matching channels.
    % The correlation is expected to be very near to 1 and very similar between channels.
    % In theory, we could compute the difference instead of the correlation, but since we need to start
    % the recordings manually on both the PC and the smartphone, data will be shifted in the recordings
    % which is no result of the recording software, but only a result of the human starting the
    % recordings manually.
    %
    % Input arguments:
    %       Two xdf files, one recorded on one device, the other potentially recorded on a different device
    %
    % Output arguments:
    %       No arguments, but information about correlation and data loss is printed
    %
    % Other m-files required:
    %       load_xdf.m
    %
    % Example usage:
    %       load_and_compare_PC_smartphone('PC.xdf','PHONE.xdf')
    %
    % Developed in Matlab 9.8.0.1359463 (R2020a) Update 1 on PCWIN64
    % at University of Oldenburg.
    % Sarah Blum (sarah.blum@uol.de), 2021-03-26 13:21
    %-------------------------------------------------------------------------
    plot_data = true;
    
    % figures are stored in this folder. create if it does not exist
    if save_plots
        fig_folder = './figures';
        if ~exist(fig_folder, 'dir')
            mkdir(fig_folder);
        end
    end
    
    % load files, clock sync on or off does not make a difference for us, we leave it on for the
    % report to follow the recommended guidelines in using LSL
    one = load_xdf([pwd, filesep, file_one], 'HandleClockSynchronization', true, 'HandleJitterRemoval', true);
    two = load_xdf([pwd, filesep, file_two], 'HandleClockSynchronization', true, 'HandleJitterRemoval', true);
        
%     for i = 1: size(one,2)  
%         if strcmp(one{i}.info.type, 'Markers') || strcmp(two{i}.info.type, 'Markers')
%             continue
%         disp(['Effective sampling rates: ', ...
%             one{i}.info.name, ': ', ...
%             num2str(one{i}.info.effective_srate), ' and ', ...
%             two{i}.info.name, ' : ', ...
%             num2str(two{i}.info.effective_srate)])
%         end
%     end

    
    % find out which indices correspond to the same stream types:
    indices = find_matching_streams([one,two]);
    % correlate_all_channels is also producing plots
    [c,L] = correlate_all_channels([one, two], indices, file_one, plot_data);

    disp(['For Scenario: ', file_one(1:end-4),':'])
    disp(['Correlation of ', num2str(c,5)])
    disp(['Lag between recordings of ', num2str(L), ' samples'])
%     
%     r = [500:800];
%     figure
%     subplot(2,1,1)
%     plot(one{1}.time_stamps(r), one{1}.time_series(1,r))
%     subplot(2,1,2)
%     plot(two{2}.time_stamps(r), two{2}.time_series(1,r))
%     
end

