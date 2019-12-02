function forward_model
global CTRL_PARS;
global INPUT_DATA;
global PROFILER_DATA;
global SIM_RESULTS;

pk = 0;
% If Forward Function is set for random sampling, get random sample
% indices: if input test sample is unknown, get 25%, if input sample is
% early redeemed, get 15%, if poor, get 10%. Don't sample unredeemed.

% Note 3/28/12: Only known remaining bug is in random sample generation. 
for p = 1:CTRL_PARS.NTest
    if (CTRL_PARS.ForwardMode == 0)
        if (CTRL_PARS.Sample_Type(CTRL_PARS.TestPtr(p))>2)
            pk(1) = pk(1)+1;
            pk(p+1) = p;
            nrecords(pk(1)) = round(length(PROFILER_DATA.DataMats{CTRL_PARS.TestPtr(p)})*0.25);
            r_sample(pk(1)) = ceil(nrecords(pk(1)).*rand(nrecords(pk(1))));        
        elseif (CTRL_PARS.Sample_Type(CTRL_PARS.TestPtr(p))==2)
            pk(1) = pk(1)+1;
            pk(p+1) = p;        
            nrecords(pk(1)) = round(length(PROFILER_DATA.DataMats{CTRL_PARS.TestPtr(p)})*0.15);
            r_sample = ceil(nrecords(pk(1)).*rand(nrecords(pk(1))));
        elseif (CTRL_PARS.Sample_Type(CTRL_PARS.TestPtr(p)==1))
            pk(1) = pk(1)+1;
            pk(p+1) = p;          
            nrecords(pk(1)) = round(length(PROFILER_DATA.DataMats{CTRL_PARS.TestPtr(p)})*0.10);
            r_sample(pk(1)) = ceil(nrecords(pk(1)).*rand(nrecords(pk(1)))); 
        end;
    else
    end
end;
for p = 1:CTRL_PARS.NTest
    if (CTRL_PARS.ForwardMode == 0) % In random sample mode, get random samples for each set.
        which_set = pk(p+1);
        sel_set = PROFILER_DATA.DataMats{CTRL_PARS.TestPtr(which_set)};
        for m = 1:nrecords(p)
            rs_sample(m,:,p) = sel_set(r_sample(m),:);
        end;
        if (p==1)
           s_sample(1:nrecords(p),:,p) = rs_sample(1:nrecords(p),:,p);
           sample_size(p) = nrecords(p);
        else
           s_sample((nrecords(p-1)+1):(nrecords(p-1)+nrecords(p)),:,p) = rs_sample(1:nrecords(p),:,p);
           sample_size(p) = sample_size(p)+nrecords(p);
        end;
        s_sample_t3(:,1:4,p) = s_sample(:,15:18,p);
        s_sample_3 = s_sample;
        SIM_RESULTS.Truth{p} = s_sample_t3(:,CTRL_PARS.TrainOn,p);
    else  % If simulating whole data set, get whole data set and sample size
        ps_sample = INPUT_DATA.Data{CTRL_PARS.TestPtr};
        ps_sample = getrmat(ps_sample);
        nrecords(p) = length(ps_sample);
        if (p==1)
            s_sample(1:nrecords(p),:,p) = ps_sample(1:nrecords(p),:,p);
            sample_size = nrecords(p);
        else
            s_sample((nrecords(p-1)+1):(nrecords(p-1)+nrecords(n)+1),:) = ps_sample(1:nrecords(p),:);
            sample_size = sample_size+nrecords(p);
        end;
        s_sample_t3(:,1:4,p) = s_sample(:,15:18,p);
        s_sample_3 = s_sample;
        SIM_RESULTS.Truth{p} = s_sample_t3(:,CTRL_PARS.TrainOn,p);  % Store Truth vector
    end;
end
for p = 1:CTRL_PARS.NTest    % Loop over N Test Samples
    for n = 1:sample_size
        for m = 1:18
            s_sample(n,m) = s_sample_3(n,m,p);                  % Get current sample (NxM from NxMxP)
            % s_sample(n,13:18,p) = 0;                                      
        end
    end
    s_sample_t(:,:) = s_sample_t3(:,1:4,p);               % Get Truth/Derived Value Matrix (Nx4 from Nx4xP)
    s_sample_t = s_sample_t(:,CTRL_PARS.TrainOn);       % Select Truth Vector - Select by TrainOn Parameter (Nx1)
    for n = 1:sample_size                               % Loop over all rows in sample matrix
        for o = 1:PROFILER_DATA.NBetas                  % Loop over N Betas / N Profiles
            for m = 1:11                                % Loop over data points used in calculation
                if (PROFILER_DATA.Profiles(m,o) ~= 0)   % Avoid Divide by Zero Errors where Profile Entry is 0                                                       
                    match_score(m,o,n) = (s_sample(n,m)-PROFILER_DATA.Profiles(m,o))/PROFILER_DATA.Profiles(m,o)*PROFILER_DATA.BetaWeights(m,o);
                    % Calculate match score/vector space distance normalized relative
                    % to profile values, then weight score by
                    % beta(m,o)/profile(m,o)
                else
                    match_score(m,o,n) = (s_sample(n,m)-PROFILER_DATA.Profiles(m,o));
                    % If profile data point is zero, match score/vsd is
                    % the simple difference between points. Un-weighted, as
                    % corresponding beta weight would be undefined and is
                    % only a placeholder with a value identical to the
                    % corresponding beta.
                end;    
            end; % close loop over regressors
            match_score(12,o,n) = (s_sample(n,12)-PROFILER_DATA.Profiles(12,o))/PROFILER_DATA.Profiles(12,o);
            % Calculate match score & vector distance for assessment
            % (outside m-loop due to lack of corresponding beta weight.
            % Normalized by profile value; weighting would require
            % reinstatement of assessment in training/simulation.
            m_score(n,o) = sum(match_score(:,o,n))/12;
            % Get mean match score (already weighted) for current data point (n) and 
            % beta vector (o).            
        end;
        % m_score is now a [1 x N_Betas] vector; match_score is now
        % [12 x N_Betas x Data Point)
        m_score_a(n,:) = abs(m_score(n,:));
        % Get absolute value of mean match scores
        [least_mean_vspace(n), best_match(n)] = min(m_score_a(n,:));
        % Get value and index for least mean vector space / best match
        % for data-point N.
        for r = 1:11
            m_sign(r) = sign(match_score(r,best_match(n),n));
        end;                
        % Perhaps the following adjustment code should go before best match
        % determination. 
        m_norm = norm(match_score(:,best_match(n),n));  %Get norm of 12x1 best match scores
        for r = 1:11 % Loop over values used in forward calculation.
            rms = m_norm/sqrt(abs(sum(match_score(:,best_match(n),n))));
            % Calculate Root-Mean-Square of match vector (magnitude of
            % given vector for scaling)
            rms_adjust = (rms*least_mean_vspace(n))*m_sign(r);
            % Calculate (current) RMS adjustment value by scaling vector
            % distance by vector magnitude and assign proper sign.
            vspace_rms_adjust(r) = (rms_adjust/11)*match_score(r,best_match(n),n);
            % Calculate adjustment value for column R of current sample
            % vector - 1/11th of RMS adjustment value (crude approximation
            % - later versions should distribute according to significance
            % - * match score for element R in column corresponding to best
            % profile match.
            s_sample_adjust(n,r) = s_sample(n,r)+vspace_rms_adjust(r);
            % adjust element R of sample data point N by adding
            % vspace_rms_adjust value (which may be negative)
        end;
        s_sample_adjust(n,12) = s_sample(n,12); % Transfer non-adjusted assessment value into row 12 of adjusted sample
        % End of adjustment code.
        for m = 1:11 % Main Forward Calculation loop
            y_hat(m) = s_sample_adjust(n,m)*PROFILER_DATA.BetaVecs(m,best_match(n));
            % Calculate dot-product manually y(m) = sample(n,m)*Beta(m,best_match)
        end;
        Estimate(n) = sum(y_hat); % Finish dot-product calculation to generate expectation value
        Part_Idx(n) = best_match(n); % Store best matching partition
        if (CTRL_PARS.LearnMode == 1) % Calculate Relative Error if Truth is Known
            if (s_sample_t(n)==0) % If Truth Value is 0, Calculate Error Relative to Estimate
                Error(n) = ((s_sample_t(n)-Estimate(n))/Estimate(n))*100;
            else % Otherwise Calculate Relative Error
                Error(n) = ((s_sample_t(n)-Estimate(n))/s_sample_t(n))*100;
            end;            
        end;
    end;
    SIM_RESULTS.Estimate{p} = {Estimate}; % Store Estimated Values for sample P
    SIM_RESULTS.Part_Idx{p} = {Part_Idx}; % Store Partition Indexes for sample P
    if (CTRL_PARS.LearnMode == 1)
        SIM_RESULTS.Error{p} = {Error};   % If truth is known, store Relative Errors on P
    end;
end; %End P-loop - Move on to Next sample or end simulation
write_results; %Write results to file