function write_results

global CTRL_PARS INPUT_DATA PROFILER_DATA SIM_RESULTS;

fid = fopen('Results.csv', 'wt');
for p = 1:CTRL_PARS.NTest
    Truth = SIM_RESULTS.Truth{p}
    Estimate = SIM_RESULTS.Estimate{p}
    Part_Idx = SIM_RESULTS.Part_Idx{p}
    Error = SIM_RESULTS.Error{p}
    for n = 1:length(Truth)
        fprintf(fid, '%2.8f', Truth(n));
        fprintf(fid, '%s', ',');
        fprintf(fid, '%2.8f', Estimate{p}(n));
        fprintf(fid, '%s', ',');
        fprintf(fid, '%2.8f', Part_Idx{p}(n));
        fprintf(fid, '%s', ',');
        fprintf(fid, '%2.8f', Error{p}(n));
        fprintf(fid, '\n');
    end;
    fprintf(fid, '\n');
end;
fclose(fid)
