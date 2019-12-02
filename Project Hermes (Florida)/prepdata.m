function prepdata

global CTRL_PARS INPUT_DATA PROFILER_DATA;

% rmats(1:65535,1:11,1:CTRL_PARS.NSamples) = zeros;
for p = 1:CTRL_PARS.NSamples
    if (CTRL_PARS.Do_Date == 0);
        if (CTRL_PARS.Remove_Nulls(p) == 1)
            [PROFILER_DATA.DataMats{p}, nu] = nullify(INPUT_DATA.Data{p});
        else
            PROFILER_DATA.DataMats{p} = INPUT_DATA.Data{p}(:,:);
        end;    
    end;
    if (CTRL_PARS.Do_Date == 1);
        if (CTRL_PARS.Remove_Nulls(p) == 1)
            [PROFILER_DATA.DataMats{p}, nu] = nullify(INPUT_DATA.Data{p});
        else
            PROFILER_DATA.DataMats{p} = INPUT_DATA.Data{p};
        end;    
    end;    
    temp_mat = getrmat(PROFILER_DATA.DataMats{p}(:,:));   
    temp_mat = sortrows(temp_mat,CTRL_PARS.SortBy);
    PROFILER_DATA.DataMats{p} = temp_mat;
    temp_mat = [];
end;