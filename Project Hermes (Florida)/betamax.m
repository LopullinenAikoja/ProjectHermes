function [b,nbm] = betamax(betas,np,nb)

global CTRL_PARS PROFILER_DATA;


k = 0;
c = 0;    
bh_temp(11,1:nb) = zeros;
for p = 1:CTRL_PARS.NSamples
    if (CTRL_PARS.Sample_Type(p)==2)
        for n = 1:11
            for m = 1:np(p)
                bh_temp(n,m) = bh_temp(n,m)+betas(n,m,p);
            end;
        end;
        k = k + 1;
    end;
    if (CTRL_PARS.Sample_Type(p)==1)
        for n = 1:11
            for m = 1:np(p)
                bm_temp(n,m) = betas(n,m,p);
            end;
        end;
        nbm = np(p)
    end;
    if (CTRL_PARS.Sample_Type(p)==0)
        bl_temp(1:11,1) = betas(1:11,1,p);
    end;
end;
for n = 1:11
    for m = 1:np(1)
        bh_temp(n,m) = bh_temp(n,m)/k;
    end;
    bh_temp(n,np(1)+1) = median(bh_temp(n,1:np(1)));
end;
nbeta = np(1);
nbh = (1/2*nbeta)
b(1:11,1) = bl_temp(1:11,1);
b(1:11,2:(nbm+1)) = bm_temp(1:11,1:nbm);
b(1:11,(nbm+2):(nbm+nbh+1)) = bh_temp(1:11,1:nbh);
b(1:11,(nbm+nbh+2)) = bh_temp(1:11,(np(1)+1));
b(1:11,(nbm+nbh+3):nb) = bh_temp(1:11,(nbh+1):np(1));               