%% Function Description
% 
% This function stores and returns the engine properties depending on the engine model as designated by a string
% 
%% Inputs
% 
% * engineModel: string indicating the engine make and model
% * nTyres: total number of tyres present on the combination
% 
%% Outputs
% 
% * Engine: structure containing all of the engine properties required to determine the longitudinal 
% 
%% Change Log
% 
% [0.1.0] - 2017-05-01
% 
% Added
% 
% * Changed output to a structure
%
function [Engine] = getEngineData(engineModel, nTyres)

switch engineModel
    case 'Scania G460 ADR'
        Engine.EngineModelDescription = 'Scania DC13-106-460-Euro3 engine';
        Engine.GearboxModelDescription =  'Scania GRS905';
        Engine.changeT = 1897; %RPM where power is max, change down RPM
        
        Engine.gearsLabels = {'CL'  'CH'    '1L'    '1H'    '2L'    '2H'    '3L'    '3H'    '4L'    '4H'    '5L'    '5H'    '6L'    '6H'};
        Engine.gears =     [16.406	13.281	11.32	9.164	7.194	5.823	4.632	3.75	3.016	2.444	1.918	1.553	1.235	1];
        Engine.eff_gear =  [0.97	0.97	0.97	0.97	0.97	0.97	0.97	0.97	0.97	0.97	0.97	0.97	0.97	0.97];
        Engine.eff_diff = 0.97; %differential ratio
        Engine.dif = 3.07; %differential ratio
        
        Engine.gearsStartLabels = Engine.gearsLabels;
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = Engine.eff_diff; %Diff ratio for startability - used if dual differential
        Engine.difStart = Engine.dif; %Diff ratio for startability - used if dual differential
        
        Engine.Torquerpm = [1005	1356	1401	1465	1558	1603	1662	1771	1802	1897];
        Engine.TorqueNm =  [2251	2251	2177	2100	2000	1951	1899	1800	1772	1700];
    case 'Volvo D13A400 with AT2612F Gearbox'
        Engine.EngineModelDescription = 'Volvo D13A400';
        Engine.GearboxModelDescription =  'Volvo AT2612F';
        
        Engine.changeT = 1773; %RPM where power is max, change down RPM
        Engine.gearsLabels = {'1'   '2'     '3'     '4'     '5'     '6'     '7'     '8'     '9'     '10'    '11'    '12'};
        Engine.gears =     [14.94   11.28   9.04    7.09    5.54    4.35    3.44    2.7     2.08    1.63    1.27    1];
        Engine.eff_gear =  [0.97    0.97    0.97    0.97    0.97    0.97    0.97    0.97    0.97    0.97    0.97    0.97];
        
        Engine.eff_diff = 0.97; %differential efficiency
        Engine.dif = 3.090; %differential ratio
        
        Engine.gearsStartLabels = Engine.gearsLabels;
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = Engine.eff_diff; %Diff ratio for startability - used if dual differential
        Engine.difStart = Engine.dif; %Diff ratio for startability - used if dual differential
        
        Engine.Torquerpm = [600     698     769     836     903     950     998     1045    1399    1466    1553    1663    1773    1844    1891    1943    1986    2041    2088];
        Engine.TorqueNm =  [1268    1402    1504    1601    1708    1805    1901    2003    2003    1901    1805    1703    1601    1499    1402    1300    1199    1097    1000];
    case 'VW 17.250 with Dual Differential'
        Engine.changeT = 2500; %Torque where torque*rpm is max
        
        Engine.gears = [8.03 5.06 3.09 1.96 1.31 1];
        Engine.eff_gear = [0.96 0.96 0.96 0.96 0.96 0.96];
        Engine.eff_diff = 0.97;
        Engine.dif = 5.59; %standard diff ratio
        
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = 0.97; %Diff ratio for startability - used if dual differential
        Engine.difStart = 5.59; %Diff ratio for startability - used if dual differential
        
        Engine.Torquerpm = [900 1100 1300 1500 1600 1700 1900 2100 2300 2500];
        Engine.TorqueNm =  [624 835 900 900 900 888 846 786 739 725];
    case 'Volvo D13A440 with AT2612F Gearbox'
        Engine.EngineModelDescription = 'Volvo D13A440';
        Engine.GearboxModelDescription =  'Volvo AT2612F ASO-C';
        Engine.changeT = 1800; % RPM where torque*rpm (power) is max
        
        Engine.gearsLabels = {'1'   '2'     '3'     '4'     '5'     '6'     '7'     '8'     '9'     '10'    '11'    '12'};
        Engine.gears =     [14.94	11.28	9.04	7.09	5.54	4.35	3.44	2.7     2.08	1.63	1.27	1.00];
        Engine.eff_gear =  [0.96   0.96    0.96     0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96];
        Engine.eff_diff = 0.97; % standard diff ratio
        Engine.dif = 3.09; % standard diff ratio
        
        Engine.gearsStartLabels = {'C'  '1'     '2'     '3'     '4'     '5'     '6'     '7'     '8'     '9'     '10'    '11'    '12'};
        Engine.gearsStart =     [19.38  14.94	11.28	9.04	7.09	5.54	4.35	3.44	2.7     2.08	1.63	1.27	1.00]; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart =  [0.96   0.96   0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96]; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = 0.97; % Diff ratio for startability - used if crawler gear available
        Engine.difStart = 3.09; % Diff ratio for startability - used if dual differential ratio is available
        
        Engine.Torquerpm = [600	621		688		749		810		856		901		929		965		996		1053	1394	1461	1540	1631	1714	1811	1860	1911	1951	1997	2033	2085];
        Engine.TorqueNm =  [1273	1305	1404	1499	1601	1704	1803	1893	1996	2099	2201	2205	2095	1996	1897	1803	1700	1601	1499	1404	1301	1203	1100];
    otherwise
        error('ENGINE DOES NOT EXIST, PLEASE ADD THE ENGINE TO GetEngineData.m');
end

%----------------------------------------------------------------------------------------
%   Calculated engine properties
%----------------------------------------------------------------------------------------
Engine.Ie = 2.75; %engine inertia kg/m^2
Engine.It = nTyres*14; %tyre inertia kg/m^2

Engine.gearshiftregime = 2; % 1 for every gear 2 for every second

Engine.engageTrpm = Engine.Torquerpm(1); %Torque engagement rpm - between 800 & 1000 when clutch is fully released - look @ start of where graph is drawn **Should be the first point on the curve

if (max(Engine.TorqueNm)/2) < min(Engine.TorqueNm)
    Engine.engageTNm = max(Engine.TorqueNm)/2; %Torque engagement Nm - half of maximum torque as an estimate unless the min torque is lower than this
else
    Engine.engageTNm = min(Engine.TorqueNm);
end

