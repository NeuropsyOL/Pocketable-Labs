function indices = find_matching_streams(data)
    % Iterate through input and return matching stream indices.
    % When recording with LSL, the streams are recorded with an index correspinding to their
    % detection order in the network at recording time. Therefore, the order is not known and cannot
    % be changed by the user.
    % in this function, we use the stream names to detect matching streams.
    
    % extract all stream names from the input data 
    all_stream_names = return_all_cell_names(data);
 
    
    % we want to ignore marker streams and do not return indices for them
    if any(contains(all_stream_names, 'Markers', 'IgnoreCase', true))
        indices = zeros(1, size(all_stream_names,2)/2);
    % in case of the sine wave recording, let's hardcode the indices for now
    %TODO generate rule here
    elseif any(contains(all_stream_names, 'Sine', 'IgnoreCase', true))
        indices = [1,2];
        return
    else
        % this is the normal case, where several streams were recorded from 2 devices at the same
        % time, both of them should contain (at least a subset of) the same streams
        indices = zeros(ceil(size(all_stream_names,2)/2), 2);
    end
    
    % loop through names, and then find the matching indices
    i = 1;
    for s = 1 : size(indices, 1)
       str_parts = strsplit(all_stream_names{s}, ' ');
       indexC = strfind(all_stream_names, str_parts{1});
       index_pair = find(~cellfun('isempty', indexC)); 
       % if the same index is found for one stream, then it was only recorded in one device. skip it
       % for the comparions and do not increase index for indices array
       if all(size(index_pair) == 1)
           continue
       else           
           indices(i,:) = index_pair;
           i = i + 1;
       end
    end
    
    % if we have skipped one row, then we need to remove the zeros and reshape to correct size
    dim2 = size(indices,2);
    indices = nonzeros(indices);
    dim1 = size(indices,1)/dim2;
    indices = reshape(indices, dim1,dim2);
    
    %TODO assert names are equal
end