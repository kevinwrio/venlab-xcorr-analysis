% ========================================================================
% PLOT INSTANTANEOUS DELAYS
% 
% This function plots the instantaneous delays (cross-correlation) between
% a focal pedestrian and its nearest neighbors. Helps visualize the
% quantities that are averaged to generate the heatmap in meanDelayHeatmap.
% Each neighbor is represented as a circle with a 'nose' pointing in its
% current heading direction; red lines depict negative delays, i.e.
% neighbors that lead the focal participant.
% 
% Kevin Rio
% Created: January 2014
% Updated: February 2015
% ========================================================================

clear all; close all
load filtPos

% Trial information.
trial = 1;
time = 3600;

% Initialization.
cHelm = Quant(trial).ctrHelm(time);
window = 30;
begTime = time-window;
endTime = time+window;

% Main loop.
cMax = NaN(nHelm,1); % correlation in heading
rMax = NaN(nHelm,1); % correlation in speed
tMax = NaN(nHelm,2); % time delay
for iHelm = 1:nHelm
    
    % If current helmet equals the center helmet, return NaN's. 
    if iHelm == cHelm
        cMax(iHelm,1) = NaN;
        rMax(iHelm,1) = NaN;
        tMax(iHelm,1:2) = NaN;
    
    % Compute correlation in speed and heading, and optimal delays.
    else
        hdnI = Traj(trial,iHelm).hdn;
        hdnJ = Traj(trial,cHelm).hdn;
        [cMax(iHelm,1),tMax(iHelm,1)] = corrHdn(hdnI,hdnJ,begTime,endTime);
        [rMax(iHelm,1),tMax(iHelm,2)] = corrSpd(hdnI,hdnJ,begTime,endTime);
    end
    
end

% Plot current position and heading for all helmets.
x0 = Traj(trial,cHelm).x(time);
y0 = Traj(trial,cHelm).y(time);
for iHelm = 1:nHelm
    
    % Read in x, y, and heading. 
    x = Traj(trial,iHelm).x(time)-x0;
    y = Traj(trial,iHelm).y(time)-y0;
    hdn = Traj(trial,iHelm).hdn(time);

    % Plot center helmet (big and bold).
    if iHelm == cHelm
        xP = [x,x+0.6*cos(hdn)];
        yP = [y,y+0.6*sin(hdn)];
        plot(x,y,'.','Color',[0 0.8 0],'MarkerSize',72); hold on;
        plot(xP,yP,'Color',[0 0.8 0],'LineWidth',8); hold on;
    
    % Plot other helmets.
    else
        if isnan(cMax(iHelm,1)) == 0
            
            % Plot helmet and heading. 
            xP = [x,x+0.3*cos(hdn)];
            yP = [y,y+0.3*sin(hdn)];
            plot(x,y,'.','Color',[0.3 1 0.3],'MarkerSize',36); hold on;
            plot(xP,yP,'Color',[0.3 1 0.3],'LineWidth',3); hold on;
            
            % Display cMax, rMax, and tMax next to each helmet.
            space = 0.1;
            r = num2str(rMax(iHelm,1));
            c = num2str(cMax(iHelm,1));
            t = num2str((mean(tMax(iHelm,:)))/60); % avg of spd and hdn
            % t = num2str(tMax(iHelm,1)/60); % computed with heading only
            if length(t) < 4
                text(x+0.1,y-2*space,['t = ',t,' s'],'FontSize',8);
            else
                text(x+0.1,y-2*space,['t = ',t(1:4),' s'],'FontSize',8);
            end
            % text(x+0.1,y,['r = ',r(1:4)],'FontSize',8); % display r
            % text(x+0.1,y-space,['C = ',c(1:4)],'FontSize',8); % display C
            
            % Draw red lines connecting neighbors with negative delays.
            if mean(tMax(iHelm,:))/60 < 0
                plot([x 0],[y 0],'r'); hold on;
            end
 
        end
    end
end

% Add axis labels.
xlabel('x (m)')
ylabel('y (m)')
