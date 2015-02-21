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
window = 30;
begTime = time-window;
endTime = time+window;
cHelm = Quant(trial).ctrHelm(time);
cMax = NaN(nHelm,1); % correlation in heading
rMax = NaN(nHelm,1); % correlation in speed
tMax = NaN(nHelm,2); % time delay

% Compute cross-correlation.
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

% Record the current position of the center helmet.
x0 = Traj(trial,cHelm).x(time);
y0 = Traj(trial,cHelm).y(time);

% Plot subtle lines connecting 'leading' helmets to center helmet.
for iHelm = 1:nHelm
    % Read in x, y, and heading.
    x = Traj(trial,iHelm).x(time);
    y = Traj(trial,iHelm).y(time);
    hdn = Traj(trial,iHelm).hdn(time);
    % Draw line.
    if iHelm ~= cHelm && mean(tMax(iHelm,:))/60 < 0
        plot([x x0],[y y0],'Color',[0.85 1 0.85],'LineWidth',5); hold on;
    end
end

% Plot position and heading of all helmets.
for iHelm = 1:nHelm
    % Read in x, y, and heading.
    x = Traj(trial,iHelm).x(time);
    y = Traj(trial,iHelm).y(time);
    hdn = Traj(trial,iHelm).hdn(time);
    % Plot center helmet (big and bold).
    if iHelm == cHelm
        xP = [x,x+0.6*cos(hdn)];
        yP = [y,y+0.6*sin(hdn)];
        plot(x,y,'.','Color',[0.3 0.3 0.3],'MarkerSize',100); hold on;
        plot(xP,yP,'Color',[0.3 0.3 0.3],'LineWidth',12); hold on;
    % Plot other helmets.
    else
        if isnan(cMax(iHelm,1)) == 0
            xP = [x,x+0.25*cos(hdn)];
            yP = [y,y+0.25*sin(hdn)];
            % Leaders in green.
            if mean(tMax(iHelm,:))/60 >= 0
                plot(x,y,'.','Color',[1 0.3 0.3],'MarkerSize',36); hold on;
                plot(xP,yP,'Color',[1 0.3 0.3],'LineWidth',3); hold on;
            % Followers in red.
            elseif mean(tMax(iHelm,:))/60 < 0
                plot(x,y,'.','Color',[0.3 1 0.3],'MarkerSize',36); hold on;
                plot(xP,yP,'Color',[0.3 1 0.3],'LineWidth',3); hold on;
            end
            % Time delay.
            space = 0.05;
            t = num2str(-mean(tMax(iHelm,:))/60);
            if length(t) < 4
                text(x+space,y-2*space,['t = ',t,' s'],'FontSize',10,'FontName', 'CMU Bright');
            else
                text(x+space,y-2*space,['t = ',t(1:4),' s'],'FontSize',10,'FontName', 'CMU Bright');
            end
        end
    end
end

% Aesthetics.
set(gca, 'FontName', 'CMU Bright','FontSize',12)
xlabel('x (m)','FontName','CMU Sans Serif','FontSize',20,'FontWeight','Bold')
ylabel('y (m)','FontName','CMU Bright','FontSize',20,'FontWeight','Bold')

