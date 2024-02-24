function ind = findincell(cell, element)
  % Find index of element in cell.
  % If not found the output "ind" is -1.
  ind = -1;
  n = size(cell,1);
  for j = 1:n
    if (strcmp(cell{j,1}, element))
        ind = j;
    end
  end
end
