%% --------------------------------------------------------------------------------------
%	Change Log
%----------------------------------------------------------------------------------------
%% 2021-02-27
%   Added first code
%   Code assumes tank is full for now
%% Inputs as follows:
%densityPayload - density of the payload
%massPayload - mass of the payload
%densityTank - density of the tank material
%massTank - mass of the tank
%aTank - internal elliptical width of the tank
%bTank - internal elliptical height of the tank
%lTank - internal length of the tank
%tTank - thickness of the tank material
%hBottom - height of first liquid to fill tank above ground
%fileName
%savePath
%runKey
%sheetName
%isSaveExcel - saves results to Excel
%isSavePlot - plots results and saves figure
% Units mm and kg. roh=1000e-9 water. 833e-9 coal. 7850e-9 steel.
function [m, hcog] = computeTankerCoG(densityPayload, massPayload, densityTank, massTank, aTank, bTank, lTank, tTank, hBottom, fileName, savePath, runKey, sheetName, isSaveExcel, isSavePlot)
[htot, hcog, Ixx, Iyy, Izz, massPayload] = inertia_calc(densityPayload, massPayload, aTank, bTank, lTank); %Payload
[hcog1, massTank, Ixx1, Iyy1, Izz1] = inertia_calc1(densityTank, massTank, aTank, bTank, lTank, tTank); %Tank

%% --------------------------------------------------------------------------------------
%	Combining Inertias for TruckSim
%----------------------------------------------------------------------------------------
vMass = [massPayload massTank]; %Mass of each inertial entity [kg]
vIxx = [Ixx Ixx1].*10^-6; %Roll inertia for each inertial entity [kg.m^2]
vIyy = [Iyy Iyy1].*10^-6; %Pitch inertia for each inertial entity [kg.m^2]
vIzz = [Izz Izz1].*10^-6;%; %Yaw inertia for each inertial entity [kg.m^2]
vCoGx = [lTank*0.5 lTank*0.5]; %x coordinate of CoG relative
vCoGy = [0 0]; %y coordinate of CoG relative to centre of vehicle [mm]
vCoGz = [hcog hcog1] + hBottom; %z coordinate of CoG relative to the road surface [mm]

xcogPayload = vCoGx(1);
m=massPayload;
combinedInertias = computeCombinedInertias_WithMomentOfInertia(vMass, vIxx, vIyy, vIzz, vCoGx, vCoGy, vCoGz);
%% --------------------------------------------------------------------------------------
%	Plotting results
%----------------------------------------------------------------------------------------
if isSavePlot
    figure('name', 'TankCoG');
    axis equal
    hold on;
    plotTank(aTank, bTank);
    %plotTankLoad(aTank, bTank,);
    plot(0,hcog,'ko','markersize',6);
    plot(0,hcog,'k+','markersize',10);
    h1=plot([0 0],[0 hcog],'color','k');
    xAxisLengthVector=xlim;
    xAxisLength=xAxisLengthVector(2)-xAxisLengthVector(1);
    yAxisLengthVector=ylim;
    yAxisLength=yAxisLengthVector(2)-yAxisLengthVector(1);
    t1=text(xAxisLength*0.02,hcog/2,num2str(hcog,'%.0f'),'Rotation',90);
    set(gcf,'PaperPosition',[0 0 16 11])
    set(gca,'Xgrid','on');
    set(gca,'Ygrid','on');
    savePlot(savePath, runKey, sheetName)
    
    %% --------------------------------------------------------------------------------------
    %	Printing results to Excel
    %----------------------------------------------------------------------------------------
    if isSaveExcel
        inputHeadings = {'Payload mass input [kg]' 'Payload density [kg/m^3]' 'Loaded Volume [m^3]' 'Tank wall thickness [mm]' 'Tank density [kg/m^3]' 'Ancilliary load factor [-]' 'Load height from top of tank [mm]'};
        inputs = [massPayload round(densityPayload*10^9) round((massPayload/(densityPayload*10^9)),3) tTank round(densityTank*10^9) 1 0];
        resultsHeadings = {'Payload load height [mm]' 'Payload mass [kg]' 'Payload CoGx [mm]' 'Payload CoGy [mm]' 'Payload CoGz rel. to ground [mm]' 'Payload Ixx [kg.m^2]' 'Payload Iyy [kg.m^2]' 'Payload Izz [kg.m^2]' 'Payload Rx [m]' 'Payload Ry [m]' 'Payload Rz [m]' 'Tank mass [kg]' 'Tank CoGx' 'Tank CoGy' 'Tank CoGz rel. to ground [mm]' 'Tank Ixx [kg.m^2]' 'Tank Iyy [kg.m^2]' 'Tank Izz [kg.m^2]' 'Combined Mass [kg]' 'Combined CoGx rel. to hitch [mm]' 'Combined CoGy [mm]' 'Combined CoGz rel. to ground [mm]' 'Combined Ixx [kg.m^2]' 'Combined Iyy [kg.m^2]' 'Combined Izz [kg.m^2]' 'Combined Rx [m]' 'Combined Ry [m]' 'Combined Rz [m]'};
        results = [round([htot massPayload vCoGx(1) vCoGy(1) vCoGz(1) Ixx*10^-6 Iyy*10^-6 Izz*10^-6],1) round([((Ixx*10^-6)/massPayload)^0.5 ((Iyy*10^-6)/massPayload)^0.5 ((Izz*10^-6)/massPayload)^0.5],4) round([massTank vCoGx(2) vCoGy(2) vCoGz(2) Ixx1*10^-6 Iyy1*10^-6 Izz1*10^-6 combinedInertias],1) round([(combinedInertias(5)/combinedInertias(1))^0.5 (combinedInertias(6)/combinedInertias(1))^0.5 (combinedInertias(7)/combinedInertias(1))^0.5],4)] ;
        writeExcelInertia_WithMomentOfInertia(fileName, savePath, inputHeadings, resultsHeadings, inputs, results, sheetName);
    end
    payloadSummary = {'Payload mass output [kg]', massPayload;...
        'Payload density [kg/m^3]', densityPayload*10^9;...
        'Load height from top of tank [mm]', (bTank-htot);...
        'Payload CoGz rel. to ground [mm]', (hcog+hBottom);...
        'Payload CoGx rel. to hitch [mm]', xcogPayload;...
        'Payload Rx [m]', ((Ixx*10^-6)/massPayload)^0.5;...
        'Payload Ry [m]', ((Iyy*10^-6)/massPayload)^0.5;...
        'Payload Rz [m]', ((Izz*10^-6)/massPayload)^0.5;...
        'Loaded Volume [m^3]', (massPayload/(densityPayload*10^9));...
        'Tank mass [kg]', massTank;...
        } %Results to display in PostProcessor
end
end

function [hcog1, massTank, Ixx1, Iyy1, Izz1]=inertia_calc1(densityTank, massTank, aTank, bTank, lTank, tTank) %Tank
hcog1=bTank;
massTank=massTank;
a=aTank;
b=bTank;
l=lTank;
t=tTank;
Ixx1=1/4*massTank*(a^2+b^2)+massTank*(a+b)*t*(a*b*l+2*a*t*l+2*b*t*l+2*a*b*t)/(2*a*t*l+2*b*t*l+2*a*b*t);
Iyy1=1/4*massTank*(b^2)+1/12*massTank*(l^2)+(b*t+1/3*l*t)*(a*b*l+2*a*t*l+2*b*t*l+2*a*b*t)/(2*a*t*l+2*b*t*l+2*a*b*t);
Izz1=1/4*massTank*(a^2)+1/12*massTank*(l^2)+(a*t+1/3*l*t)*(a*b*l+2*a*t*l+2*b*t*l+2*a*b*t)/(2*a*t*l+2*b*t*l+2*a*b*t);
end

function [htot, hcog, Ixx, Iyy, Izz, massPayload]=inertia_calc(densityPayload, massPayload, aTank, bTank, lTank); %Payload
htot=bTank*2;
hcog=bTank;
massPayload=massPayload;
Ixx=1/4*massPayload*(aTank^2+bTank^2);
Iyy=1/4*massPayload*bTank^2+1/12*massPayload*lTank^2;
Izz=1/4*massPayload*aTank^2+1/12*massPayload*lTank^2;
end

function plotTank(aTank, bTank)
xCoords=aTank*cos([0:1:360]*pi/180);
yCoords=bTank*sin([0:1:360]*pi/180)+bTank;
plot(xCoords,yCoords)
axis equal;
end

