function [changeT, gears, eff_gear, eff_diff, dif, gearsStart, eff_gearStart, eff_diffStart, difStart, Torquerpm, TorqueNm, Ie, It, gearshiftregime, engageTrpm, engageTNm] = getEngineData(engineModel, nTyres)

switch engineModel
    case 'Scania G460 ADR'
        % Engine: Scania DC13-106-460-Euro3 engine
        % Gearbox: Scania GRS905 gearbox
        changeT = 1897; %RPM where power is max, change down RPM
        
        gears =     [16.406	13.281	11.32	9.164	7.194	5.823	4.632	3.75	3.016	2.444	1.918	1.553	1.235	1];
        eff_gear =  [0.97	0.97	0.97	0.97	0.97	0.97	0.97	0.97	0.97	0.97	0.97	0.97	0.97	0.97];
        eff_diff = 0.97; %differential ratio
        dif = 3.07; %differential ratio
        
        gearsStart = gears; %Gears for startability - used if crawler gear available
        eff_gearStart = eff_gear; %Gears for startability - used if crawler gear available
        eff_diffStart = eff_diff; %Diff ratio for startability - used if dual differential
        difStart = dif; %Diff ratio for startability - used if dual differential
        
        Torquerpm = [1005	1356	1401	1465	1558	1603	1662	1771	1802	1897];
        TorqueNm =  [2251	2251	2177	2100	2000	1951	1899	1800	1772	1700];
    case 'Volvo D13A400 with AT2612F Gearbox'
        changeT = 1773; %RPM where power is max
        
        gears =     [14.94 11.28 9.04 7.09 5.54 4.35 3.44 2.7 2.08 1.63 1.27 1];
        eff_gear =  [0.97 0.97 0.97 0.97 0.97 0.97 0.97 0.97 0.97 0.97 0.97 0.97];
        
        eff_diff = 0.97; %differential efficiency
        dif = 3.090; %differential ratio
        
        gearsStart = gears; %Gears for startability - used if crawler gear available
        eff_gearStart = eff_gear; %Gears for startability - used if crawler gear available
        eff_diffStart = eff_diff; %Diff ratio for startability - used if dual differential
        difStart = dif; %Diff ratio for startability - used if dual differential
        
        Torquerpm = [600 698 769 836 903 950 998 1045 1399 1466 1553 1663 1773 1844 1891 1943 1986  2041 2088];
        TorqueNm =  [1268 1402 1504 1601 1708 1805 1901 2003 2003 1901 1805 1703 1601 1499 1402  1300 1199 1097 1000];
    case 'VW 17.250 with Dual Differential'
        changeT = 2500; %Torque where torque*rpm is max
        
        gears = [8.03 5.06 3.09 1.96 1.31 1];
        eff_gear = [0.96 0.96 0.96 0.96 0.96 0.96];
        eff_diff = 0.97;
        dif = 5.59; %standard diff ratio
        
        gearsStart = gears; %Gears for startability - used if crawler gear available
        eff_gearStart = eff_gear; %Gears for startability - used if crawler gear available
        eff_diffStart = 0.97; %Diff ratio for startability - used if dual differential
        difStart = 5.59; %Diff ratio for startability - used if dual differential
        
        Torquerpm = [900 1100 1300 1500 1600 1700 1900 2100 2300 2500];
        TorqueNm =  [624 835 900 900 900 888 846 786 739 725];
    otherwise
        error('ENGINE DOES NOT EXIST, PLEASE ADD THE ENGINE TO GetEngineData.m');
end

%----------------------------------------------------------------------------------------
%   Calculated engine properties
%----------------------------------------------------------------------------------------
Ie = 2.75; %engine inertia kg/m^2
It = nTyres*14; %tyre inertia kg/m^2

gearshiftregime = 2; % 1 for every gear 2 for every second

engageTrpm = Torquerpm(1); %Torque engagement rpm - between 800 & 1000 when clutch is fully released - look @ start of where graph is drawn **Should be the first point on the curve

if (max(TorqueNm)/2) < min(TorqueNm)
    engageTNm = max(TorqueNm)/2; %Torque engagement Nm - half of maximum torque as an estimate unless the min torque is lower than this
else
    engageTNm = min(TorqueNm);
end

