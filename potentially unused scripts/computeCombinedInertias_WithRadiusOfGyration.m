%% --------------------------------------------------------------------------------------
%	This function combines inertias from a given inertia matrix
%----------------------------------------------------------------------------------------
function [inputsHeadings, inputs, resultsHeadings, vResults, totalMass, CoGx, CoGz] = computeCombinedInertias_WithRadiusOfGyration(vMass, vRx, vRy, vRz, vCoGx, vCoGy,vCoGz, vPitch)
%% --------------------------------------------------------------------------------------
%	USEFUL VARIABLES
%----------------------------------------------------------------------------------------
numObjects = length(vMass); % [-] Determines the number of vehicles being combined
totalMass = ceil(sum(vMass)); % [m]

%% --------------------------------------------------------------------------------------
%	CONVERTING TO MOMENT OF INERTIA FROM RADIUS OF GYRATION (I = mR^2)
%----------------------------------------------------------------------------------------
vIxx = vMass.*(vRx.^2); % [kg.m^2]
vIyy = vMass.*(vRy.^2); % [kg.m^2]
vIzz = vMass.*(vRz.^2); % [kg.m^2]
%% --------------------------------------------------------------------------------------
%	CALCULATING THE OVERALL CENTRE OF GRAVITY
%----------------------------------------------------------------------------------------
CoGx = ceil(sum(vCoGx.*vMass)/sum(vMass)); % [mm] Calculates the combined CoGx
CoGy = ceil(sum(vCoGy.*vMass)/sum(vMass)); % [mm] Calculates the combined CoGy
CoGz = ceil(sum(vCoGz.*vMass)/sum(vMass)); % [mm] Calculates the combined CoGz

%% --------------------------------------------------------------------------------------
%	COMBINING INERTIA TO THE NEW CENTRE OF GRAVITY
%----------------------------------------------------------------------------------------
Ixx_dash = ceil(sum(vIxx.*cosd(vPitch) + vIzz.*sind(vPitch) + vMass.*(vCoGz.*0.001-CoGz.*0.001).^2)); % [kg.m^2] Calculates the inertia about the CoG using the parallel axis theorem
Iyy_dash = ceil(sum(vIyy + vMass.*((vCoGz.*0.001-CoGz.*0.001).^2 + (vCoGx.*0.001-CoGx.*0.001).^2))); % [kg.m^2] Calculates the inertia about the CoG using the parallel axis theorem
Izz_dash = ceil(sum(vIzz.*cosd(vPitch) + vIxx.*sind(vPitch) + vMass.*(vCoGx.*0.001-CoGx.*0.001).^2)); % [kg.m^2] Calculates the inertia about the CoG using the parallel axis theorem

Rx_dash = round((Ixx_dash/totalMass)^0.5,3); % [m]
Ry_dash = round((Iyy_dash/totalMass)^0.5,3); % [m]
Rz_dash = round((Izz_dash/totalMass)^0.5,3); % [m]

%% --------------------------------------------------------------------------------------
%	GENERATING OUTPUTS TO PRINT TO FILE IF REQUIRED
%----------------------------------------------------------------------------------------
inputsHeadings = {'Mass' 'CoGx' 'CoGy' 'CoGz' 'Ixx' 'Iyy' 'Iyy' 'Rx' 'Ry' 'Rz' 'Pitch'};
inputs = [vMass; vCoGx; vCoGy; vCoGz; vIxx; vIyy; vIzz; vRx; vRy; vRz; vPitch]; %Generating a summary of all the inputs into a single matrix

resultsHeadings = {'Total mass' 'CoGx' 'CoGy' 'CoGz' 'Ixx_dash' 'Iyy_dash' 'Izz_dash' 'Rx_dash' 'Ry_dash' 'Rz_dash'};
vResults = [totalMass CoGx CoGy CoGz Ixx_dash Iyy_dash Izz_dash Rx_dash Ry_dash Rz_dash]; %Combining outputs for the output file
end