function data = plot_all_streams_quick(fname, figname)
    %
    % plot_all_streams_quick.m--
    %
    % Input arguments:
    %       - mandatory: the filename of the xdf file we want to load and plot
    %       - optional: the device name which recorded the xdf file
    %
    % Output arguments:
    %       the data that was loaded from the xdf file
    %
    % Other m-files required:
    %       load_xdf.m (liblsl) is used to load the xdf file
    %           - get it here: https://github.com/xdf-modules/xdf-Matlab
    %       saveAllOpenFigs.m is used to grab any open figure and save it
    %           - get it here: https://github.com/s4rify/Code-Snippets
    %
    % Developed in Matlab 9.8.0.1359463 (R2020a) Update 1 on PCWIN64
    % at University of Oldenburg.
    % Sarah Blum (sarah.blum@uol.de), 2021-02-19 09:47
    %-------------------------------------------------------------------------
    
    % figure props
    font_size = 12;
   
    if ~exist('figname')
        figname = 'default_fig_name';
    end
    
    % the filename without ending is going to be used as title and name of figure
    filename = fname;
    
    % figures are stored in this folder. create if it does not exist
    fig_folder = './figures';
    if ~exist(fig_folder, 'dir')
        mkdir(fig_folder);
    end
    
    % no clock sync for data from emulator
    data = load_xdf([filename], 'HandleClockSynchronization', true);
    
    
    % open a figure and dynamically create as many subplots as needed
    figure('pos', [100,0,1000,1000])
    t = tiledlayout("flow");
    t.Title.String = figname;
    
    for streams = 1: size(data,2)
        if contains(data{streams}.info.type, 'arker')
            continue
        end
        len = data{streams}.time_stamps(end) - data{streams}.time_stamps(1);
        fullname = data{streams}.info.name;
        name_parts = strsplit(fullname, ' ');
        shortname = name_parts{1};
        %shortname = data{streams}.info.name;
        sr = str2double(data{streams}.info.nominal_srate);
        e_sr = data{streams}.info.effective_srate;
        
        nexttile;
        plot(data{streams}.time_stamps./sr,...
            data{streams}.time_series);
        
        % plot(data{streams}.time_stamps, data{streams}.time_series);
        title([shortname,' (', num2str(round(len)), ' s)', ...
            ' effective sr: ', num2str(round(e_sr,2)), ' Hz']);
        set(findall(gcf,'-property','FontSize'),'FontSize', font_size)
        axis tight
    end
    
    % save the file with the devicename and/or filename
    saveAllOpenFigs(fig_folder, [filesep, figname]);
    disp('Figure saved!')
    close all
    
end
