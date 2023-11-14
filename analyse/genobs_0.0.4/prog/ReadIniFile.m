function [IniData, mesg] = ReadIniFile(IniFile)
    % Reads all parameters in ini-file. It uses the function inifile.m. 
    % For its documentation see that file
    % Output is stored in the structure IniData:
    %

    if (is_octave) 
        warning('off', 'Octave:possible-matlab-short-circuit-operator');
    end

    keys = inifile(IniFile,'readall');

    % Default values
    pnt=0;
    IniData.dim      = -1;
    IniData.idprec   = 0.0005;
    IniData.idhgt    = 0.0005;
    IniData.SigmaDHA = 0;
    IniData.SigmaDHB = 0.0003;
    IniData.SigmaDHC = 0;
    IniData.sfixed   = 0.001;
    IniData.srel     = 0;
    IniData.a.fixed  = 0.0003;
    IniData.a.rel    = 0;
    IniData.z.fixed  = 0.0003;
    IniData.z.rel    = 0;
    IniData.sbase    = {};
    mesg             = {};
    nsbase           = 0;

    % Functions
    function [res, mesg] = getunitandvalue(strng, mesg)
        f = @(value, factor) num2str(str2num(value) * factor);
        n = size(strng,1);
        if n == 0
            strng = '0';
            n = 1;
        end        
        if n > 0
            res.value = strng{1,1};
            if n > 1
                res.unit = strng{2,1};
                unitrange = {'mm'; 'cm'; 'm'; 'ppm'; 
                             'gon'; 'mgon'; 'gon.km';
                             'mm/wt(km)'; 'mm/km'};
                if ~ismember(res.unit, unitrange)
                  i = size(mesg,1)+1;
                  mesg{i, 1} = ['*** Error: wrong unit used in ini-file: ', res.unit];
                else
                    switch res.unit
                        case 'mm'
                            res.value = f(res.value, 0.001);
                        case 'cm'
                            res.value = f(res.value, 0.01);
                        case 'm'
                            res.value = f(res.value, 1);
                        case 'ppm'
                            res.value = f(res.value, 1);
                        case 'gon'
                            res.value = f(res.value, 1);
                        case 'mgon'
                            res.value = f(res.value, 0.001);
                        case 'gon.km'
                            res.value = f(res.value, 1);
                        case 'mm/wt(km)'
                            res.value = f(res.value, 0.001);
                        case 'mm/km'
                            res.value = f(res.value, 0.001);
                    end % switch
                end
            end
        end
    end
    
    function [valuestr, mesg] = getvalue(str, mesg)
        valuestr = textscan(keys{i,4},'%s');
        valuestr = valuestr{1,1};
        [valuestr, mesg] = getunitandvalue(valuestr, mesg);
        valuestr = str2num(valuestr.value);   
    end
    
    n=size(keys,1);
    for i=1:n
        switch keys{i,1}
        
            case 'dimensie'
                switch keys{i,3}(1:3)
                    case 'dim'
                        key = keys{i,4};
                        if isnan(str2double(key))
                            IniData.dim = key;
                        else
                            IniData.dim = str2num(key);
                        end
                end % switch
                
            case 'bestanden'
                switch keys{i,3}(1:4)
                    case 'proj'
                        IniData.project=keys{i,4};
                end % switch

            case 'parameters'
                switch keys{i,3}(1:4)
                    case 'sbas'
                        nsbase = nsbase + 1;
                        IniData.sbase{nsbase} = keys{i,4};
                    case 'idpr'
                        [IniData.idprec, mesg] = getvalue(keys{i,4}, mesg);
                    case 'idhg'
                        [IniData.idhgt, mesg] = getvalue(keys{i,4}, mesg);
                    case 'sdha'
                        [IniData.SigmaDHA, mesg] = getvalue(keys{i,4}, mesg);
                    case 'sdhb'
                        [IniData.SigmaDHB, mesg] = getvalue(keys{i,4}, mesg);
                    case 'sdhc'
                        [IniData.SigmaDHC, mesg] = getvalue(keys{i,4}, mesg);
                    case 'sfix'
                        [IniData.sfixed, mesg] = getvalue(keys{i,4}, mesg);
                    case 'srel'
                        [IniData.srel, mesg] = getvalue(keys{i,4}, mesg);
                    case 'afix'
                        [IniData.a.fixed, mesg] = getvalue(keys{i,4}, mesg);
                    case 'arel'
                        [IniData.a.rel, mesg] = getvalue(keys{i,4}, mesg);
                    case 'zfix'
                        [IniData.z.fixed, mesg] = getvalue(keys{i,4}, mesg);
                    case 'zrel'
                        [IniData.z.rel, mesg] = getvalue(keys{i,4}, mesg);
                end % switch
        end % switch     
    end % for
end % function ReadIniFile
