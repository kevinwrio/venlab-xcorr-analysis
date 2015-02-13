% ========================================================================
% GENERATE CONTINUOUS DATA 'CHUNKS'
% 
% This function finds the longest chunks where all [16,20] helmets are
% present. It was created so that Adam Kiefer could do PCA and RQA
% analyses, which require continuous and overlapping time series. Keep in
% mind that this was a 'quick and dirty' script designed to get Adam the
% data as soon as possible, so it's not the cleanest code, it's not
% particularly well-commented (though it's not horrible), and the resulting
% format may not be in an ideal format for general use. 
% 
% Kevin Rio
% Created: May 2013
% Updated: February 2015
% ========================================================================


clear all;
close all;
load filtPos;


%% 16-helmet chunks
% ========================================================================
% === IDENTIFY TRIALS WITH 16 HELMETS PRESENT ===
% ========================================================================
num_trial = 2;  % first 2 trials are N = 16
num_helm = 16;
trial_count = 1;
for trial = 1:num_trial
    num_frame = length(Traj(trial).x);
    good_frame{trial_count} = zeros(num_frame,1);
                
    % identify and mark time-steps with all 16 helmets present
    for frame = 1:num_frame
        x_list = NaN(num_helm,1);
        for helm = 1:num_helm
            x_list(helm,1) = Traj(trial,helm).x(frame);
        end
        if isnan(mean(x_list)) == 0
            A = 'yes';
            good_frame{trial_count}(frame,1) = 1;
        end
    end
    
    trial_count = trial_count+1;
      
end

% ========================================================================
% === FIND LONGEST CHUNKS ===
% ========================================================================
num_chunks = 10;
chnk = struct;  
good_frame_comb = vertcat(good_frame{1},good_frame{2}); % combine both trials

count = 1;
chunk = 1;
while chunk <= num_chunks
    
    % find longest chunk
    [found,from,to] = findLongestZerosAndOnes(good_frame_comb,1);
    
    % if chunk exists ...
    if length(to) > 0
        
        % replace with 0's, to find next longest chunk
        good_frame_comb(from:to) = 0;
        
        % determine trial number
        if to <= 7888
            trial = 1;
        elseif to > 7888
            trial = 2;
            from = from-7888;
            to = to-7888;
        end
        
        % store data
        for helm = 1:num_helm
            chnk(count,helm).x = Traj(trial,helm).x(from:to);
            chnk(count,helm).y = Traj(trial,helm).y(from:to);
            chnk(count,helm).t = Traj(trial,helm).t(from:to);
            chnk_length(count,1) = to-from; % time-steps
            chnk_length(count,2) = (to-from)/60; % seconds
            chnk_length(count,3) = trial;  % trial number
        end
        
    end
    
    % go to next chunk
    chunk = chunk+1;
    count = count+1;
end

clearvars -except chnk chnk_length
save chunks16


%% 20-helmet chunks
% ========================================================================
% === IDENTIFY FRAMES WITH ALL 20 HELMETS PRESENT ===
% ========================================================================
num_trial = size(Traj,1);
num_helm = size(Traj,2);
for trial = 1:num_trial
    num_frame = size(Traj(trial).x);
    good_frame = zeros(num_frame);
    
    % exclude trials with <20 helmets
    if isnan(nanmean(Traj(trial,20).x)) == 0                                    
        
        % identify and mark time-steps with all 20 helmets present
        for frame = 1:num_frame
            x_list = NaN(num_helm,1);
            for helm = 1:num_helm
                x_list(helm,1) = Traj(trial,helm).x(frame);
            end
            if isnan(mean(x_list)) == 0
                good_frame(frame,1) = 1;
            end
        end
        
       
    end
end

% ========================================================================
% === FIND LONGEST CHUNKS ===
% ========================================================================
num_chunks = 10;
chnk = struct;
chunk = 1;
while chunk <= num_chunks
    
    % find longest chunk
    [found,from,to] = findLongestZerosAndOnes(good_frame,1);
    
    % replace with 0's, to find next longest chunk
    good_frame(from:to) = 0;
    
    % store data
    for helm = 1:num_helm
        chnk(chunk,helm).x = Traj(3,helm).x(from:to);
        chnk(chunk,helm).y = Traj(3,helm).y(from:to);
        chnk(chunk,helm).t = Traj(3,helm).t(from:to);
        chnk_length(chunk,1) = to-from; % time-steps
        chnk_length(chunk,2) = (to-from)/60; % seconds
    end
    
    % go to next chunk
    chunk = chunk+1;
end

clearvars -except chnk chnk_length
save chunks20
