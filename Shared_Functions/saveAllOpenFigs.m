function[] = saveAllOpenFigs(pathout,fname)
    try
        close('EEGLAB v2019.1');                      % VERY IMPORTANT!!!
    catch
    end

    hfigs = get(0, 'children');                      %Get list of figures

    for m = 1:length(hfigs)
        figure(hfigs(m));                                   %Bring Figure to foreground
        %set(gcf, 'Position', get(0, 'Screensize'));         % make full screen

        %if isempty(hfigs(m).Name)
        %hfigs(m).Name = [num2str(hfigs(m).Number), '_' ,hfigs(m).Name];
        %hfigs(m).Name = input('Filename? (0 to skip)\n', 's')   %Prompt user
        %end

        filename = [pathout, filesep, hfigs(m).Name, fname];
        if ~exist(pathout)
            mkdir(pathout)
        end
        %filename = [pathout,filesep, fname];
        %saveas(hfigs(m), [filename '.fig']);                     % Matlab .FIG file
        saveas(hfigs(m), [filename '.png']);                      % Standard PNG graphics file
        %eval(['print -painters -depsc ', filename, '.eps']);     % trick matlab into correctly saving it as eps
    end
end