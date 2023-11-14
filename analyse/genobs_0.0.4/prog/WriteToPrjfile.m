function mesg = WriteToPrjfile(progdir, prjdir, NetworkName, sbase, crd, dim)
  mesg = {};
  % Write MOVE3 PRJ-file
  fName = strrep(NetworkName,' ','_');
  fName = strcat(fName, '.prj');
  fName=fullfile(prjdir, 'output', fName);

  prjfile = fullfile(progdir, 'Default.prj');
  copyfile(prjfile, fName, 'f');

  stop = false;
  sbasestr = {};
  if dim==1 || dim==2 || dim==3
    dims = num2str(dim);
    dimstr   = ['Dimension           ', dims];
    sb = size(sbase,2);
    if sb<dim && sb>=0
      stop = true;
      if sb>0
        text_mesg = ['*** Error: too few base points in ini-file. ', ...
                     'There should be ', dims, '.' ];
        mesg = AddMessage(mesg, {text_mesg});
      else
        [s_str, an] = plural_or_singular(dim);
        str_i = str_ini_or_MOVE3(s_str, an);
        text_mesg = ['*** No base points found in ini-file. ', ...
                     'There should be ', dims, '.', str_i];
        mesg = AddMessage(mesg, {text_mesg});        
      end
    else % sb==dim or sb<0
      for d=1:dim
        if point_not_yet_chosen(sbase, d) 
          point_exists = check_point_name(sbase{d}, crd);
          if point_exists
              ds = num2str(d);
              sbasestr{d} = ['BaseStation', ds, '        ', sbase{d}];
          else
              mesg = AddMessage(mesg, error_sbase(sbase{d}, dim));
              stop = true;
              break
          end
        else
          mesg = AddMessage(mesg, ['*** Error: S-base point ', ...
                 sbase{d}, ' appears more than once in ini-file']);
          stop = true;
          break        
        end
      end
   
      if ~stop
        if dim==1
            s_str = '';
        else
            s_str = 's';
        end
        mesg = AddMessage(mesg, {['Chosen S-base point', s_str, ':']});
        for d=1:dim
            txtfileinsert(fName, sbasestr{d}, 42+d);
            mesg = AddMessage(mesg, {['  ', sbase{d}]});
        end
      end
    end
  else
      mesg = AddMessage(mesg, {'*** Error: dimension parameter is wrong: dim = ', dim});
  end
  txtfilechange(fName, dimstr, 12);
end

% ###

function point_exists = check_point_name(pname, crd)

  point_exists = false;
  point_list = crd{1,1};
  found = findincell(point_list, pname);
  if found>-1
    point_exists = true;
  end
  
end

% ###

function error_mesg = error_sbase(point_name, dim)

  [s_str, an] = plural_or_singular(dim);
  str_i = str_ini_or_MOVE3(s_str, an);
  error_mesg = ['*** Error: S-base point ', ...
    point_name, ' is not found in coord.txt.', str_i];
end

function not_chosen = point_not_yet_chosen(sbase, d)
  not_chosen = true;
  for i=1:d-1
     if sbase{i}==sbase{d}
       not_chosen = false;
     end
  end
end

function   [s_str, an] = plural_or_singular(dim)
  if dim > 1
    s_str = 's';
    an = '';
  else
    s_str = '';
    an = 'an ';
  end
end

function str_i = str_ini_or_MOVE3(s_str, an)
  str_i = [sprintf('%s\n', ''), ...
    '*** Change it in the ini-file, or choose', ...
    sprintf('%s\n', ''), ...
    '*** ', an, 'S-base point', s_str, ...
    ' in MOVE3 (base points; basispunten).'];
end