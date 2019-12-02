function hermes_profiler_training
global CTRL_PARS INPUT_DATA PROFILER_DATA SIM_RESULTS;
prepdata;   
nB(1:CTRL_PARS.NSamples) = 0;
for p = 1:CTRL_PARS.NSamples
    r = PROFILER_DATA.DataMats{p}(:,:);
    [rsm,dpm,np,ssz] = parter_new(r,p);
    for n = 1:np
        rp(1:ssz(n),1:12,n,p) = rsm(1:ssz(n),1:12,n);
        dp(1:ssz(n),1:4,n,p) = dpm(1:ssz(n),1:4,n);
        dp(1:ssz(n),5,n,p) = rsm(1:ssz(n),12,n);
        r_loc_a(1:ssz(n),1:11,n) = rsm(1:ssz(n),1:11,n);
        d_loc_a(1:ssz(n),1,n) = dpm(1:ssz(n),CTRL_PARS.TrainOn,n);
        r_loc(1:ssz(n),1:11) = r_loc_a(1:ssz(n),1:11,n);
        d_loc(1:ssz(n),1) = d_loc_a(1:ssz(n),1,n);
        [b_l, bint_l, r_l] = regress(d_loc,r_loc);
        b_a(1:11,n) = b_l(1:11);r_a(1:ssz(n),n) = r_l(1:ssz(n));
        b(1:11,n,p) = b_a(1:11,n),re(1:ssz(n),n,p) = r_a(1:ssz(n),n);
        b_l = []; bint_1 = []; r_l = [];
        err(1:ssz(n),n,p) = get_relative_error(d_loc(1:ssz(n)),re(1:ssz(n),n,p), ssz(n));
        me(1,n,p) = mean(abs(err(:,n,p)));
        stm(1,n,p) = std(abs(err(:,n,p)));            
    end;
    sZ{p} = ssz;
    nB(p) = np;
    if (p>1)
        if (CTRL_PARS.Sample_Type(p) ~= CTRL_PARS.Sample_Type(p-1))
            if (p==6)
                npb = p-1;
                N_Beta = min(nB(1:npb))+nB(p);
            elseif (p==7)
                N_Beta = N_Beta + 2;
            end;               
        end;
    end;
end;
PROFILER_DATA.NBetas = N_Beta;
[Beta_Sort, nbm] = betamax(b,nB,N_Beta);
PROFILER_DATA.BetaVecs(1:11,1:PROFILER_DATA.NBetas) = Beta_Sort;
PROFILER_DATA.NProfiles = N_Beta;
rk = 0;
for p = 1:CTRL_PARS.NSamples
    ssz = sZ{p};
    szm(p) = max(ssz);
end;
profile_mat(1:12,1:PROFILER_DATA.NBetas) = zeros;
for p = 1:CTRL_PARS.NSamples
    ssz = sZ{p};
    if (CTRL_PARS.Sample_Type(p) == 2)
        npar = nB(p);
        rk = rk+1;        
        for n = 1:nB(p)
            nend = ssz(n);
            rp_loc(1:nend,1:12) = rp(1:nend,1:12,n,p);
%            rp_loc(1:nend,12) = dp(1:nend,5,n,p);
            rm_med(1:12,n) = median(rp_loc(1:nend,1:12)).';
            if (p>1)
                rm_sav(:,n) = rm_sav(:,n)+rm_med(:,n);
                rm_med = [];
            else
                rm_sav(:,n) = rm_med(:,n);
                rm_med = [];
            end;
        end
        if (p==5)
            rm_mean = rm_sav/5;
        end;
    end;
    if (CTRL_PARS.Sample_Type(p) == 1)
        for n = 1:nB(p)
            rm_poor(1:ssz(n),1:12,n) = rp(1:ssz(n),1:12,n,p);
        end;            
    end;
    if (CTRL_PARS.Sample_Type(p) == 0)
        rm_unredeemed(1:ssz,1:12) = rp(1:ssz,1:12,1,p);
        profile_mat(:,1) = median(rm_unredeemed).';
    end;    
end;
for n = 2:(nbm+1)
    nend = sZ{6}(n-1);
    rmp_loc(1:nend,1:12) = rm_poor(1:nend,1:12,(n-1));
    profile_mat(1:12,n) = median(rmp_loc(:,1:12)).';
    rmp_loc = [];
end;
n_extra = npar+1;
for n = 1:nB(1)
    rmm_loc(1:12,n) = rm_mean(1:12,n);
    proe(1:12,n) = rmm_loc(1:12,n);
end;
nbh = round(1/2*nB(1));
bhe = median(proe.').';
for n = (nbm+2):(nbm+nbh+2)
    nbc = n-nbm;
    profile_mat(1:12,n) = proe(1:12,nbc);
end;
nbc = nbm+nbh+3;
nbd = nbc+1;
profile_mat(1:12,nbc) = bhe;
for n = nbd:N_Beta
    nbc = (n - nbm - 2);
    profile_mat(1:12,n) = proe(1:12,nbc);
end;
PROFILER_DATA.Profiles = profile_mat(1:12,1:PROFILER_DATA.NBetas);
for n = 1:11
    for m = 1:N_Beta
        if (profile_mat(n,m)>0)
            BetaWeight(n,m) = Beta_Sort(n,m)/profile_mat(n,m);
        else
            BetaWeight(n,m) = Beta_Sort(n,m);
        end;
    end;
end;
PROFILER_DATA.BetaWeights(1:11,1:PROFILER_DATA.NBetas) = BetaWeight(1:11,1:N_Beta);
% write_betas_write_profiles;