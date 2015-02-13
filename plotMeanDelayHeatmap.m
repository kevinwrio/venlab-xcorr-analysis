% ========================================================================
% PLOT MEAN DELAY HEATMAP
% This function generates a heatmap of the mean delay (i.e. the value that 
% maximizes cross-correlation) between a focal pedestrian and each of 
% his/her nearest neighbors. With sufficient data, a clear pattern emerges;
% namely, that delays are positive for neighbors in front [they lead] and
% negative for neighbors in back [they follow].
%
% Kevin Rio
% Created: January 2014
% Updated: February 2015
% ========================================================================

clear all; close all;
load filtPos;

% Trial information.
trial = 1;
count = 1;

% Take a series of 'snapshots' throughout the trial. For each snapshot,
% compute the cross-correlation -- and in particular, the time delay -- 
% between the focal participant and each neighbor. Spatially average these 
% values to generate a heat map showing the mean time delay centered around
% the focal participant. Feel free to play around with the start/end times
% in the first line, but be warned the script can take a long time to run 
% if you a large number of time points.
for time = 1000:1000:7001 

    % Initialization.
    cHelm = Quant(trial).ctrHelm(time);
    begTime = time-30;
    endTime = time+30;
    
    % Main loop.
    for iHelm = 1:nHelm
        if iHelm ~= cHelm
            
            % Compute cross-correlation in speed and heading. 
            hdnI = Traj(trial,iHelm).hdn; spdI = Traj(trial,iHelm).spd;
            hdnJ = Traj(trial,cHelm).hdn; spdJ = Traj(trial,cHelm).spd;
            if isnan(Traj(trial,iHelm).xR(time)) == 0 % if current helmet is valid, i.e. data exists
                xcorrMatrix(count,1) = Traj(trial,iHelm).xR(time); % x-coordinate in center helmet frame
                xcorrMatrix(count,2) = Traj(trial,iHelm).yR(time); % y-coordinate in center helmet frame
                [xcorrMatrix(count,3),xcorrMatrix(count,4)] = corrHdn(hdnI,hdnJ,begTime,endTime); % xcorr of heading
                [xcorrMatrix(count,5),xcorrMatrix(count,6)] = corrHdn(spdI,spdJ,begTime,endTime); % xcorr of speed
                count = count+1;
            end
            
        end
    end
end

% Heat map of mean delays. There's an unresolved bug with this section,
% such that the plot is not centered around (0,0), where the focal
% participant should be. Probably an issue with either (a) defining the
% grids or (b) doing the coordinate transformation such that the focal
% participant is located at (0,0) on each time step. 
figure(1)
x = xcorrMatrix(:,1);
y = xcorrMatrix(:,2);
value = xcorrMatrix(:,4)/60;
binSize = 0.25;
xBins = -4:binSize:4;
yBins = -4:binSize:4;
[nX,idX] = histc(x,xBins);
[nY,idY] = histc(y,yBins);
out = accumarray([idY idX], value', [], @mean); % heat map matrix
out(out==0) = NaN; % replace missing data with NaN
imagesc(xBins, yBins, out)
axis([-4.5 4.5 -4.5 4.5])
colormap('hot')
colormap(flipud(colormap)) % reverse colormap
colorbar % color legend
xlabel('x (m)')
ylabel('y (m)')
title('Speed: Mean Optimal Delay')

% Scatter plot of positive (leading) delays. Not entirely sure what the
% purpose of this figure was. I think it's meant to show where the
% 'leaders' are, relative to the focal participant. 
figure(2)
for i = 1:length(xcorrMatrix)
    if xcorrMatrix(i,4) < 0
        plot(xcorrMatrix(i,1),xcorrMatrix(i,2),'.'); hold on;
        axis([-4 4 -4 4])
        xlabel('x (m)')
        ylabel('y (m)')
    end
end
