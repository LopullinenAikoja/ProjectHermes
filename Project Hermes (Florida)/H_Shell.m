warning off
global CTRL_PARS INPUT_DATA PROFILER_DATA SIM_RESULTS;
CTRL_PARS = struct;
CTRL_PARS.TrainOn = 4;
CTRL_PARS.SortBy = 14+CTRL_PARS.TrainOn;
CTRL_PARS.NSamples = 7;
CTRL_PARS.Sample_Type(1:5) = 2;
CTRL_PARS.Sample_Type(6) = 1;
CTRL_PARS.Sample_Type(7) = 0;
CTRL_PARS.Remove_Nulls(1:6) = 1;
CTRL_PARS.Remove_Nulls(7) = 0;
CTRL_PARS.Do_Date = 1;
CTRL_PARS.NRegs = 11;
CTRL_PARS.LearnMode = 1;
CTRL_PARS.ForwardMode = 0;
CTRL_PARS.NTest = 1;
CTRL_PARS.TestPtr = [2,1,8];
INPUT_DATA = struct;
INPUT_DATA.VarNames(1) = {'early1a'};
INPUT_DATA.VarNames(2) = {'early2a'};
INPUT_DATA.VarNames(3) = {'early3a'};
INPUT_DATA.VarNames(4) = {'early4a'};
INPUT_DATA.VarNames(5) = {'early5a'};
INPUT_DATA.VarNames(6) = {'poor_a'};
INPUT_DATA.VarNames(7) = {'unredeemed_a'};
for n = 1:CTRL_PARS.NSamples
    INPUT_DATA.Vars(n) = genvarname(INPUT_DATA.VarNames(n));
    INPUT_DATA.Data{n} = eval(INPUT_DATA.Vars{n});
end;
PROFILER_DATA = struct;
PROFILER_DATA.NBetas = 0;
PROFILER_DATA.BetaVecs(1:CTRL_PARS.NRegs,1:18) = zeros(1:CTRL_PARS.NRegs,1:18);
PROFILER_DATA.DataMats(1:CTRL_PARS.NSamples) = cell(1,CTRL_PARS.NSamples);
PROFILER_DATA.NProfiles = 0;
PROFILER_DATA.Profiles(1:CTRL_PARS.NRegs,1:18) = zeros(1:CTRL_PARS.NRegs,1:18);
PROFILER_DATA.DisPart(1:CTRL_PARS.NSamples) = cell(1,CTRL_PARS.NSamples);
PROFILER_DATA.ErrorMetrics(1:CTRL_PARS.NSamples) = cell(1,CTRL_PARS.NSamples);
PROFILER_DATA.BetaWeights(1:CTRL_PARS.NRegs,1:18) = zeros(1:CTRL_PARS.NRegs,1:18);
SIM_RESULTS = struct;
SIM_RESULTS.Truth(1:CTRL_PARS.NSamples) = cell(1,CTRL_PARS.NSamples);
SIM_RESULTS.Estimate (1:CTRL_PARS.NSamples) = cell(1,CTRL_PARS.NSamples);
SIM_RESULTS.Error(1:CTRL_PARS.NSamples) = cell(1,CTRL_PARS.NSamples);
SIM_RESULTS.Part_Idx(1:CTRL_PARS.NSamples) = cell(1,CTRL_PARS.NSamples);
NTest = 10;
if (CTRL_PARS.LearnMode == 1)
    hermes_profiler_training
end;
forward_model
