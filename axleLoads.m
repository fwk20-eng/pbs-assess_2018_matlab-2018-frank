%This calculator serves to calculate the load distributions on each of the
%combinations axles.
%----------------------------------------------------------
%Changelogs
%Ver 1.0
%   -> First iteration, adapted from PostProcess 1.14 from Frank
%   -> Added functionality to display axle loads on the ground
%   -> Added functionality to display the loading tables directly & save to
%   excel
%----------------------------------------------------------
%% Initialisation
clear;
%% File saving
isSave = 0;
fileName = 'test10';
savePath = 'C:\Users\deiss\Desktop';
sheetName = 'axleLoads';
%% Grouping & Loadsharing
groupingHeadings = {'Steer' 'Drive' 'Lead Trailer' 'Follower Trailer'}; %Enter a description for each axle group
grouping = {[1]; [2:3]; [4:6]; [7:9]}; % Axles numbers in each axle group. Nb cell dim must be greater than mchas dim by 1
loadshare1 = [1 0.5 0.5 (1/3)*ones(1,6)]; % Normal loadsharing numbers
%loadshare2 = [1 1 0.5 0.5]; % Startability loadsharing numbers
%% Axle properties
mAxle = [750 1300 1300 850*ones(1,3) 850*ones(1,3)]; % axle masses
xAxle = [0 3.2 4.57 6.89 8.25 9.61 3.99 5.35 6.710]; % distances back of axles. Relative to steer axle on unit 1 and relative to hitch points (hps)on all following vehicles
zAxle = [0.497 0.507 0.507 0.514*ones(1,3) 0.514*ones(1,3)];  % TruckSim model
Ndrive = [2:3]; % driven axles unit numbers
nSteer = 1; % number of steer axles for STFD
%% Dolly
dollys = []; % Vehicle unit numbers with no reference points (dolly's do not have RPs)%
%% Vehicle unit coupling
rollCoupled = [true true]; %true for 5th wheel, false for pintle (zero roll stiffness)
loadCoupled = [true true]; %false if unit can stand independantly and is pulled only
%% Hitch points
lprime = 3.885 - 0.685 + 3*0.05; % Hitch can be moved in increments of 50mm
l = [lprime 8.840]; % distances back of hitch points. Relative to steer axle on unit 1 and relative to previous hitch points (hps)on all following vehicles
h = [1.399 1.320]; 
%% Sprung Mass and CoG for Lead and Trailer units
mChas = [6932 4400 3950]; % 
xChas = [1.207 5.269 3.806]; %
zChas = [1.200 1.533 1.615]; %
%% Payload
mMax = 24000; % Maximum equal payload for trailer unit 1&2
%Unit 1 payload mass and CoG
dLoad{:,1} = {'Driver'};
mLoad{:,1} = [75]';
xLoad{:,1} = [-0.218]';
zLoad{:,1} = [1.815]';
% Unit 2 payload mass and CoG
dLoad{:,2} = {'Coal'};
mLoad{:,2} = [mMax+50]'; %Total payload for leader trailer = 24050 kg
xLoad{:,2} = [3.500-0.1]'; %Accounting for hitch offset
zLoad{:,2} = [2.474]'; %
% Unit 3 payload mass and CoG
dLoad{:,3} = {'Coal'};
mLoad{:,3} = [mMax+1150]'; %Total payload for follower trailer = 25150 kg
xLoad{:,3} = [3.500+0.465]'; %Accounting for hitch offset from the front of the bin
zLoad{:,3} = [2.475]'; %
%% Calculated variables
nAxles = length(mAxle); %
%% Processing
processAxleLoads(fileName, savePath, grouping, groupingHeadings, loadshare1, loadCoupled, l, mAxle, xAxle, mChas, xChas, mLoad, xLoad, dLoad);
%processAxleLoads(fileName, savePath, 'axleLoadsRound', grouping, groupingHeadings, loadshare1, loadCoupled, l, mAxle, xAxle, mChas, xChas, mLoad, xLoad, dLoad, 1);