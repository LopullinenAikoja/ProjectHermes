function [err] = get_relative_error(tt,rr,mx)

for n = 1:mx
    if (tt(n) ~= 0)
        err(n) = (rr(n)/tt(n))*100;
    else
        err(n) = 0;
    end;
end;

