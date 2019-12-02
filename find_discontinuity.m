function [dis,nparts] = find_discontinuity(dvec,fvec,mvec)

global CTRL_PARS;

z = 1;
y = 0;
nparts = 1;
if (CTRL_PARS.TrainOn == 1)
    dfac = 5;
end;
if (CTRL_PARS.TrainOn == 4);
    dfac = 1;
end;
for n = 1:length(dvec)
    minpartsize = length(dvec)/((1/2*length(dvec))*10^-3);
    if (CTRL_PARS.TrainOn == 3)
%        dfac = fvec(n);
        dfac = 1;
    end;
    if (CTRL_PARS.TrainOn == 2)
        dfac = fvec(n)*(1/mvec(n));
    end;
    if (n==1)
        dmsave_val = dvec(n);
        dmsave = 1;
    end;
    if (n ~= 1)
        dm_prev = dvec(n-1);
        dm = dvec(n);
        if (((dm-dm_prev)>=(0.2*dfac))||((dm-dmsave_val>=(0.2*dfac))))
            dis(z,1) = n;
            dis(z,2) = (dm-dm_prev);
            dis(z,3) = dm_prev;
            dis(z,4) = dm;
            if (z~=1)
                dis(z,5) = dis(z,1)-dis(dmsave,1);
            else
                dis(z,5) = n;
            end;
            if (dis(z,5)>=minpartsize)
                dis(z,6) = 1;
                dmsave = z;
                dmsave_val = dm;
            else
                dis(z,6) = 0;
            end;
            z = z + 1;      
        end
    end
end
nparts = 1;
for n = 1:length(dis)
    if(dis(n,6) ==1)
        nparts = nparts + 1;
    end;
end;