function WriteToTcofile(crd, NetworkName, prjdir, idprec, idhgt, dim)
  % Write the approximate coodinates (without random errors) to a MOVE3 TCO-file
  
  crdline=[];
  crdline = {'MOVE3 V4.2.1 TCO file'};
  crdline = [crdline ; '$'];
  crdline = [crdline ; NetworkName];
  crdline = [crdline ; '$'];
  crdline = [crdline ; 'PROJECTION LOCAL'];
  crdline = [crdline ; '$'];

  ptnm = crd{1,1};
  crdx = crd{1,2};
  crdy = crd{1,3};
  if dim==1 || dim==3
    crdz = crd{1,4};
  end
  n = size(ptnm, 1);
  
  ptnm_spc = AddSpaces(ptnm);
  
  width = '12';
  frm = ['%' width '.4f'];
  for i=1:n
    ppnr = ptnm_spc{i,1};
    xcrd = sprintf(frm, crdx(i,1));
    ycrd = sprintf(frm, crdy(i,1));
    if dim==1 || dim==3
      zcrd = sprintf(frm, crdz(i,1));
    else
      zcrd = '0';
    end
    idpr = sprintf(frm, idprec);
    if dim==1 || dim==3
      idhg = sprintf(frm, idhgt);
    else
      idhg = sprintf(frm, 0);
    end
    crdline=[crdline ; [ppnr '    ' xcrd '    ' ycrd '  ' zcrd '  IP  ' idpr '  ' idhg]];
  end
  crdline = [crdline ; '$'];
  
  fName = strrep(NetworkName,' ','_');
  fName = strcat(fName, '.tco');
  fName=fullfile(prjdir, 'output', fName);
  fid = fopen(fName,'w');
  if fid ~= -1
    ncrdline=size(crdline,1);
    for i=1:ncrdline
      fprintf(fid,'%s\r\n',strtrim(char(crdline(i,1:end))));
    end
  end
  fclose(fid);
end
