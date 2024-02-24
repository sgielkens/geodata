function itm = getspl(str, i)
  itm = textscan(str,'%s');
  itm = itm{1,1};
  itm = itm{i,1};
end
