function [crd_B]=AddNoise(n,p,lastcolumn,crd_B,scen)
    [randomly_added,lastcolumn] = mynormrnd(lastcolumn,0,0.0005,n-p+1,3);
    %~ mean_randomly_added_crd_B=num2str(mean(mean(randomly_added)))
    %~ std_dev_randomly_added_crd_B=num2str(std(randomly_added))
    for j=2:p
        crd_Bj = crd_B{j-1,scen};
        randomly_added(1,:)=[0 0 0]; % instr.point doesn't get noise
      crd_Bj = crd_Bj + randomly_added;
        crd_B{j-1,scen}=crd_Bj;
    end %for
