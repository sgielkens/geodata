pnt = {'M'; '67.0000'; '83.0000'; ';' ;'En'; 'dit'; 'ook'}
keep = pnt(1:3, 1)
%result = cellfun(@(x,y) x(ismember(x,cell2mat(y))),pnt,keep,'uni',false)
