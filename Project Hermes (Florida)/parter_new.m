function [rs, d, nparts, ssz] = parter_new(r,p)

global CTRL_PARS;
global PROFILER_DATA;

sb = CTRL_PARS.SortBy;
dv = r(:,sb);
fv = r(:,1);
mv = r(:,15);
[dis, nparts] = find_discontinuity(dv,fv,mv);
np = nparts;
PROFILER_DATA.DisPart{p} = {dis};
if (CTRL_PARS.Sample_Type(p)==0)
    dis = 0;
    nparts = 1;
    rs(:,1:12,1) = r(:,1:12);
    d(:,1:4,1) = r(:,15:18);
    ssz(1) = length(r);
elseif (CTRL_PARS.Sample_Type(p)==1)
    c = 1;
    for n = 1:length(dis)
        if (dis(n,6) == 1);
            if (n==1)
                lbound(c) = 1;
                ubound(c) = dis(n,1)-1;
                np = n;
                c = c + 1;
            elseif (n~=length(dis))
                lbound(c) = dis(np,1);
                ubound(c) = dis(n,1)-1;
                np = n;
                c = c + 1;
            else
                lbound(c) = dis(np,1);
                ubound(c) = length(r);
                np = n;
            end;
        end;
    end;
    nparts = nparts-1;
    for n = 1:nparts
        for o = lbound(n):ubound(n)
            rs((o-lbound(n)+1),1:12,n) = r(o,1:12);
            d((o-lbound(n)+1),1:4,n) = r(o,15:18);
        end;
    ssz(n) = ubound(n)-lbound(n)+1;
    end;
else
    c = 1;
    for n = 1:length(dis)
        if (dis(n,6) == 1);
            if (n==1)
                lbound(c) = 1;
                ubound(c) = dis(n,1)-1;
                np = n;
                c = c + 1;
            elseif (n~=length(dis))
                lbound(c) = dis(np,1);
                ubound(c) = dis(n,1)-1;
                np = n;
                c = c + 1;
            else
                lbound(c) = dis(np,1);
                ubound(c) = dis(n,1)-1;
                np = n;
                c = c + 1;
                lbound(c) = dis(np,1);
                ubound(c) = length(r);
            end;
            nparts = c;
        end;
    end;
    for n = 1:nparts
        for o = lbound(n):ubound(n)
            rs((o-lbound(n)+1),1:12,n) = r(o,1:12);
            d((o-lbound(n)+1),1:4,n) = r(o,15:18);
        end;
    ssz(n) = ubound(n)-lbound(n)+1;
    end;
end;