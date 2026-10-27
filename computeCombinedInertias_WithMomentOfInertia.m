%This function combines inertias from a given inertia matrix
%   2020-06-24
%   Changed ceil to round
function [vResults] = computeCombinedInertias_WithMomentOfInertia(vMass, vIxx, vIyy, vIzz, vCoGx, vCoGy,vCoGz) %vIxx, vIyy, vIzz, vCoGx, vCoGy,vCoGz)
%====INPUTS=========================================
vPitch = zeros(1, length(vMass)); %Rotation of vehicles along the pitch axis [deg] - set to 0 as a standard
%====CALCULATIONS=========================================
%----Useful variables-------------------------------------
numObjects = length(vMass); %Determines the number of vehicles being combined
mInputs = [vMass; vCoGx; vCoGy; vCoGz; vIxx; vIyy; vIzz; vPitch]; %Generating a summary of all the inputs into a single matrix
totalMass = round(sum(vMass));

%----Converting------------------------

%----Combined Centre of Gravity---------------------------
CoGx = round(sum(vCoGx.*vMass)/sum(vMass)); %Calculates the combined CoGx
CoGy = round(sum(vCoGy.*vMass)/sum(vMass)); %Calculates the combined CoGy
CoGz = round(sum(vCoGz.*vMass)/sum(vMass)); %Calculates the combined CoGz

%----Combined Inertial Properties------------------------
Ixx_dash = round(sum(vIxx.*cosd(vPitch) + vIzz.*sind(vPitch) + vMass.*(vCoGz.*0.001-CoGz.*0.001).^2)); %Calculates the inertia about the CoG using the parallel axis theorem
Iyy_dash = round(sum(vIyy + vMass.*((vCoGz.*0.001-CoGz.*0.001).^2 + (vCoGx.*0.001-CoGx.*0.001).^2))); %Calculates the inertia about the CoG using the parallel axis theorem
Izz_dash = round(sum(vIzz.*cosd(vPitch) + vIxx.*sind(vPitch) + vMass.*(vCoGx.*0.001-CoGx.*0.001).^2)); %Calculates the inertia about the CoG using the parallel axis theorem

vResults = [totalMass CoGx CoGy CoGz Ixx_dash Iyy_dash Izz_dash]; %Combining outputs for the output file
end