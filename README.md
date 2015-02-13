# venlab-xcorr-analysis

Spatial cross-correlation analysis scripts for Sayles Swarm data



This repository contains MATLAB scripts and data files nescessary to perform cross-correlation analyses on Sayles Swarm "SW" trials. Cross-correlation is a useful measure to quantify the degree to which neighbors in a crowd lead or follow one another. By convention, if cross-correlation is maximized at positive delays, this implies that the neighbor is leading the focal participant; and vice versa, negative delays imply following.



This analysis remains an unfinished work in progress, so expect some bumps and hiccups! In particular, the data import sections need to be cleaned up so they accept arbitrary files from the Sayles Swarm. There is also a bug with the heatmap script that results in the entire plot being shifted away from (0,0); theoretically, the plot still makes sense, but clearly there is a bug somewhere in the details. 
