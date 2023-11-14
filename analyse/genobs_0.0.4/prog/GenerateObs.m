function [dh, s, alpha, beta, obs, mesg] = GenerateObs(crd, obs, dim);

  ProcessingPossible = false;
  if ~isempty(crd)
    if ~isempty(obs)
      ProcessingPossible = true;
    end
  end
  
  if ~ProcessingPossible
    dh = [];
    s = [];
    alpha = [];
    beta = [];
    obs = {{}};
    mesg = {};
  else
    n = size(crd{1,2},1);
    m = size(obs{1,1},1);

    % Distances, directions and zenith angles are computed
    % from the coordinates

    % The observation sets and point names as read from the files
    % "obs.txt" and "coord.txt" (and put in cell arrays) are put in 
    % more handy Matlab vectors.
    instr = obs{1,1};
    target = obs{1,2};
    pntnm = crd{1,1};
    
    % The coordinates (not the point names) are copied from
    % the cell array crd to the matrix crdxyz.
    % For dim==1 also the columns for x and y are copied.
    ncol = dim;
    if dim==1
      ncol = 3;
    end
    crdxyz = zeros(n,ncol);
    for k=1:ncol
      crdxyz(:, k) = crd{1,k+1};
    end

    % A loop along all observation sets to generate the observations
    % (without noise).
    
    % An anonymous function to throw an error if necessary
    warning = @(pnt) char({['*** Error: point "' pnt '" in file ' ...
                            '"obs.txt" has not been'];
                           ['           found in file "coord.txt"']});
    % Initialisations
    dh = [];
    s = [];
    alpha_pi = [];
    beta_pi = [];
    mesg = {};
    PointsToBeRemoved = [];
    
    % Loop along all observation sets (as read from "obs.txt").
    for i = 1:m
      stop = false;
      instri = instr{i,1};
      from = findincell(pntnm, instri);
      if from == -1
        mesg = AddMessage(mesg, warning(instri));
        stop = true;
      end
      targeti = target{i,1};
      to = findincell(pntnm, targeti);
      if to == -1
        mesg = AddMessage(mesg, warning(targeti));
        stop = true;
      end
      if stop
        PointsToBeRemoved = [PointsToBeRemoved; i];
      else
        for k=1:ncol % (ncol==dim for dim==2 or dim==3, but ncol==3 for dim==1)
          crdf(k) = crdxyz(from,k);
          crdt(k) = crdxyz(to,k);
          diffvec(k) = (crdt(k)-crdf(k))^2;
        end
        
        si = sqrt(sum(diffvec));
        s = [s; si];

        if dim==1
          for k=1:3
            crdf(k) = crdxyz(from,k);
            crdt(k) = crdxyz(to,k);
          end
          difz = crdt(3)-crdf(3);
          dh = [dh; difz];

        else % dim==2 || dim==3
          
          alphai = atan2((crdt(1)-crdf(1)),(crdt(2)-crdf(2)));
          while alphai<0 alphai=alphai+2*pi(); end
          alpha_pi = [alpha_pi; alphai];
        end % if dim==1
      
        if dim==3
          % Zenith angles are computed from the coordinates and heights
          % beta = atan2(sqrt((crd(i,1)-crd(1,1))^2+(crd(i,2)-crd(1,2))^2),(crd(i,3)-crd(1,3)));
        
          difxy = (crdt(1)-crdf(1))^2 + (crdt(2)-crdf(2))^2;
          difz  = crdt(3)-crdf(3);
          betai = atan2(sqrt(difxy), difz);
          while betai<0 betai=betai+2*pi(); end
          beta_pi = [beta_pi; betai];
        end % if dim==3
      end % if stop
    end % for i=1:m
    
    obs = RemovePoints(obs, PointsToBeRemoved);
    
    if dim>1
      alpha = alpha_pi * 200/pi();
    else
      alpha = [];
    end % if dim>1
    
    if dim==3
      beta = beta_pi * 200/pi();
    else
      beta = [];
    end % if dim==3
    
  end % if ~ProcessingPossible
end % function GenerateObs
