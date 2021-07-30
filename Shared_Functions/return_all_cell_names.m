function cell_names = return_all_cell_names(in_cell)
   for i = 1: size(in_cell,2)
      cell_names{i} = in_cell{i}.info.name; 
   end
end