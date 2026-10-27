%% --------------------------------------------------------------------------------------
%	Change Log
%----------------------------------------------------------------------------------------
%%   2016-10-09
%   * Added isSaveExcel
%       0: Will not plot or save results to excel
%       1: Will plot and save results to excel
%% 2016-11-01
%   *Added print summary for postprocess window
%   *Added radii of gyration to the output for ease of entering into
%   TruckSim
%%  2016-11-02
%   *Added h_bin as a variable to input
%   *Renamed h_off as x_hitch
%% 2016-12-07
%   Changed profile of the bin to the new one sent by SATB
%% 2017-03-27
%   Added the functionality to continually add new bin models
%% 2020-03-21
%   Added more comments
%% 2020-06-24
%   Added more comments
%   Added Afrit 48 m3 bin
%   If bin overflows then mout is calculated and put in spreadsheet
%   Corrected loaded volume
%   Simple 1 m3 cube to check. Gives CoGH 501 mm if 1 mm bin and L=1000
%   Simple 4 m3 T to check. Gives CoGH 1251 mm if 1 mm bin and L=1000
%% 2020-07-02
%   Added CIMC 40 and 48 m3 bin
%   Corrected plot of bin so doesn't assume first height is at h(1)
%% 2020-09-09
%   Added Aluip 58 and 40 m3 bin
%   Reprogrammed so that bin does not have to be symmetric about the y-axis
%   Calculates the y0 as well
%% 2020-09-21
%   Added Afrit 45 m3 bin (2020)
%   Same as 48 m3 bin but reduced length
%% 2020-10-10
%   Added Aluip 55 m3 bin
%% 2025-01-19
%   Added 40 ft bin, changed 20 ft bin dimensions, added isDome, removed
%   isLiquid
%% Inputs as follows:
%binModel - e.g. 'Afrit 40 m3'
%angleRepose - angle of repose of load, taken usually as 0.1 deg i.e. flat
%roh - density
%m - mass
%x_hitch - x-distance from hitch to inside wall of bucket i.e. touch bulk ore (-ve forward and +ve back)
%h_bin - height to the bottom surface of where the ore will start loading.
%NB bin profile will always have lowest height 0 and add h_bin to VCoGz
%fileName
%savePath
%runKey
%sheetName
%isSaveExcel - saves results to Excel
%isSavePlot - plots results and saves figure
%isDome - uses new method of dome and not triangle
% Units mm and kg. roh=1000e-9 water. 833e-9 coal. 7850e-9 steel.
function [m, hcog, xcogPayload] = computeTipperBinCoG(binModel, angleRepose, roh, m, x_hitch, h_bin, fileName, savePath, runKey, sheetName, isSaveExcel, isSavePlot, isDome)
switch binModel
    case 'Simple cube 1 m3'
        buc_wl = [    1000    1000]/2;
        buc_wr = -[   1000    1000]/2;
        buc_h = [   0       1000];
        L = 1000; %[mm]
        f_anc = 1;
        t = 1; %[mm] Plate thickness
        roh1 = 1000e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
        % gives CoG height at 500
    case 'Simple cube 1 m3 offset'
        buc_wl = [  0       0];
        buc_wr = -[  1000    1000];
        buc_h = [   0       1000];
        L = 1000; %[mm]
        f_anc = 1;
        t = 1; %[mm] Plate thickness
        roh1 = 1000e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
        % gives CoG height at 500
    case 'Simple box 3 m3'
        buc_wl = [   1000    1000]/2;
        buc_wr = -[   1000    1000]/2;
        buc_h = [   0       1000];
        L = 3000; %[mm]
        f_anc = 1;
        t = 1; %[mm] Plate thickness
        roh1 = 1000e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
        % gives CoG height at 500
    case 'Simple T 4 m3'
        buc_wl = [   1000    1000 3000 3000]/2;
        buc_wr =-[   1000    1000 3000 3000]/2;
        buc_h = [   0       1000 1000 2000];
        L = 1000; %[mm]
        f_anc = 1;
        t = 1; %[mm] Plate thickness
        roh1 = 1000e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
        % gives CoG height at 125
    case 'Simple T 4 m3 by 4'
        buc_wl = [   1000    1000 3000 3000]/2;
        buc_wr =-[   1000    1000 3000 3000]/2;
        buc_h = [   0       1000 1000 2000];
        L = 4000; %[mm]
        f_anc = 1;
        t = 1; %[mm] Plate thickness
        roh1 = 1000e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
        % gives CoG height at 1250
    case 'Simple triangle /|'
        buc_wl =[   0    -1000];
        buc_wr =[  -1000 -1000];
        buc_h = [   0   1000];
        L = 1000; %[mm]
        f_anc = 1;
        t = 1; %[mm] Plate thickness
        roh1 = 1000e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
        % gives CoG height at 333
    case 'Simple triangle \|'
        buc_wl =[      0        0];
        buc_wr =[      0    -1000];
        buc_h = [      0     1000];
        L = 1000; %[mm]
        f_anc = 1;
        t = 1; %[mm] Plate thickness
        roh1 = 1000e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
        % gives CoG height at 667
    case 'Simple square'
        buc_wl =[      0.05        0.05];
        buc_wr =[     -0.05       -0.05];
        buc_h = [      0     500];
        L = 0.1; %[mm]
        f_anc = 1;
        t = 500; %[mm] Plate thickness
        roh1 = 1000e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
        % gives CoG height at 500
    case 'Thin square slice'
        buc_wl = [    1000    1000]/2;
        buc_wr = -[   1000    1000]/2;
        buc_h = [   0       1];
        L = 1000; %[mm]
        f_anc = 1;
        t = 1; %[mm] Plate thickness
        roh1 = 1000e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
        % gives CoG height at 500      
    case '20 foot container'
        buc_wl = [   2330    2330]/2;
        buc_wr =-[   2330    2330]/2;
        buc_h = [   0        2350];
        L = 5867; %[mm]
        f_anc = 1;
        t = 3; %[mm] 
        roh1 = 7850e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
    case '40 foot container'
        buc_wl = [   2330    2330]/2;
        buc_wr =-[   2330    2330]/2;
        buc_h = [   0        2350];
        L = 11998; %[mm]
        f_anc = 1.736993;
        t = 3; %[mm] 
        roh1 = 7850e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
    case 'Afrit 6 m drop size'
        buc_wl = [   2487    2487]/2;
        buc_wr =-[   2487    2487]/2;
        buc_h = [   0       1196-2.5];
        L = 6006; %[mm]
        f_anc = 2.347;
        t = 2.5; %[mm] Plate thickness 2.5 acc.to D718-86 
        roh1 = 7850e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
    case 'Afrit 40 m3'
        buc_wl = [   565     797     963    1349    1646    1797    2030    2143    2448]/2;
        buc_wr =-[   565     797     963    1349    1646    1797    2030    2143    2448]/2;
        buc_h =  [   0       133     133     209     685     735    1078    1120    1568];
        L = 7000; %[mm]
        f_anc = 1.8;
        t = 4; %[mm] Plate thickness acc.to D718-28 SHEET 1 OF 2 21/06/16
        roh1 = 7850e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
    case 'Afrit 40 m3 mk4'
        buc_wl = [   518     786    1130    1382    1770    1849    1964    2058    2190    2366]/2;
        buc_wr =-[   518     786    1130    1382    1770    1849    1964    2058    2190    2366]/2;
        buc_h =  [   0        49      49     116     295     589     653     997    1061    1474];
        L = 7000; %[mm]
        f_anc = 1.8;
        t = 3; %[mm] Plate thickness acc.to D718-28 SHEET 1 OF 2 21/06/16
        roh1 = 7850e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
    case 'Afrit 45 m3'
        buc_wl = [   566     794     1132    1347    1549    1682    1964    2069    2444]/2;
        buc_wr =-[   566     794     1132    1347    1549    1682    1964    2069    2444]/2;
        buc_h = [   0       133     133     212     539     627     1090    1136    1767];
        L = 7000; %[mm]
        f_anc = 1.8;
        t = 3; %[mm] Plate thickness acc.to D718-28 SHEET 1 OF 2 21/06/16
        roh1 = 7850e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
    case 'Afrit 45 m3 (2020)'
        buc_wl = [   516     786     1130    1455    1682    1813    1915    2016    2126    2227    2357    2424]/2;
        buc_wr =-[   516     786     1130    1455    1682    1813    1915    2016    2126    2227    2357    2424]/2;
        buc_h = [   0       49      49      133     231     305     615     675     998     1058    1408    1590];
        L = 7000; %[mm]
        f_anc = 1.7276460957429;
        t = 3; %[mm]
        roh1 = 7850e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
    case 'Afrit 48 m3'
        buc_wl = [   516     786     1130    1455    1682    1813    1915    2016    2126    2227    2357    2424]/2;
        buc_wr =-[   516     786     1130    1455    1682    1813    1915    2016    2126    2227    2357    2424]/2;
        buc_h = [   0       49      49      133     231     305     615     675     998     1058    1408    1590];
        L = 7600; %[mm]
        f_anc = 1.5389;
        t = 4; %[mm] Plate thickness acc.to D718-70A  SHEET 1 OF 2 24/06/2020
        roh1 = 7850e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
    case 'Afrit 50 m3'
        buc_wl = [   561     785     1127    1339    1629    1738    1999    2104    2333    2454]/2;
        buc_wr =-[   561     785     1127    1339    1629    1738    1999    2104    2333    2454]/2;
        buc_h = [   0       130     130     208     680     719     1296    1344    1779    1980];
        L = 7000; %[mm]
        f_anc = 1.653265;
        t = 3; %[mm] Plate thickness acc.to D718-70A  SHEET 1 OF 2 24/06/2020
        roh1 = 7850e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
    case 'Afrit 57 m3 (2020)'
        buc_wl = [   516     786     1130    1455    1682    1813    1915    2016    2126    2227    2357    2424]/2;
        buc_wr =-[   516     786     1130    1455    1682    1813    1915    2016    2126    2227    2357    2424]/2;
        buc_h = [   0       49      49      133     231     305     615     675     998     1058    1408    1590];
        L = 9000; %[mm]
        f_anc = 1.7276460957429;
        t = 3; %[mm]
        roh1 = 7850e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
    case 'Alutip 40 m3 nonsymmetrical' %In ISO z-up coordinates Y is +ve to the left
        buc_wl =-[-188.5	-271.0	-387.4	-428.3	-494.4	-536.8	-555.0	-655.8	-752.3	-840.8	-918.1	-982.0	-1034.8	-1090.1	-1109.0	-1109.0	-1140.0	-1140.0	-1109.0	-1109.0];
        buc_wr =-[188.5     271.0	387.4	428.3	494.4	536.8	591.1	661.2	726.6	782.8	825.9	853.0	873.7	910.1	949.2	986.0	1002.2	1035.1	1051.3	1156.0];
        buc_h =  [0.0       96.0	96.0	153.9	153.9	96.0	96.0	105.2	132.3	175.4	231.6	297.0	373.0	506.6	650.0	785.0	844.5	965.3	1024.7	1409.0];
        L = 6987; %[mm]
        f_anc = 2.4434736;
        t = 5; %[mm]
        roh1 = 2700e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
    case 'Alutip 45 m3 nonsymmetrical' %In ISO z-up coordinates Y is +ve to the left. ESTIMATED
        buc_wl =-[0.0	-188.5	-271.0	-387.4	-428.3	-494.4	-536.8	-555.0	-655.8	-752.3	-840.8	-918.1	-982.0	-1034.8	-1090.1	-1109.0	-1109.0	-1140.0	-1140.0	-1109.0	-1109.0];
        buc_wr =-[0.0	188.5	271.0	387.4	428.3	494.4	536.8	591.1	661.2	726.6	782.8	825.9	853.0	870.9	902.3	936.0	967.8	981.8	1010.2	1024.2	1156.0];
        buc_h =  [0.0	0.0	96.0	96.0	153.9	153.9	96.0	96.0	105.2	132.3	175.4	231.6	297.0	373.0	506.6	650.0	785.0	844.5	965.3	1024.7	1660.0];
        L = 6987; %[mm]
        f_anc = 2.4;
        t = 5; %[mm]
        roh1 = 2700e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
    case 'Alutip 50 m3 nonsymmetrical' %In ISO z-up coordinates Y is +ve to the left
        buc_wl =-[-188.5	-271.0	-387.4	-428.3	-494.4	-536.8	-555.0	-655.8	-752.3	-840.8	-918.1	-982.0	-1034.8	-1090.1	-1109.0	-1109.0	-1140.0	-1140.0	-1109.0	-1109.0];
        buc_wr =-[188.5     271.0	387.4	428.3	494.4	536.8	591.1	661.2	726.6	782.8	825.9	853.0	873.6	909.9	948.9	985.6	1001.7	1034.5	1050.7	1233.0];
        buc_h =  [0.0       96.0	96.0	153.9	153.9	96.0	96.0	105.2	132.3	175.4	231.6	297.0	373.0	506.6	650.0	785.0	844.5	965.3	1024.7	1696.0];
        L = 7467; %[mm]
        f_anc = 2.231244;
        t = 5; %[mm]
        roh1 = 2700e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
    case 'Alutip 52 m3 nonsymmetrical' %In ISO z-up coordinates Y is +ve to the left
        buc_wl =-[-188.5	-271.0	-387.4	-428.3	-494.4	-536.8	-555.0	-655.8	-752.3	-840.8	-918.1	-982.0	-1034.8	-1090.1	-1109.0	-1109.0	-1140.0	-1140.0	-1109.0	-1109.0];
        buc_wr =-[188.5     271.0	387.4	428.3	494.4	536.8	591.1	661.2	726.6	782.8	825.9	853.0	873.6	909.9	948.9	985.6	1001.7	1034.5	1050.7	1249.0];
        buc_h =  [0.0       96.0	96.0	153.9	153.9	96.0	96.0	105.2	132.3	175.4	231.6	297.0	373.0	506.6	650.0	785.0	844.5	965.3	1024.7	1755.0];
        L = 7467; %[mm]
        f_anc = 2.210076;
        t = 5; %[mm]
        roh1 = 2700e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
    case 'Alutip 58 m3 nonsymmetrical' %In ISO z-up coordinates Y is +ve to the left
        buc_wl =-[-188.5	-271.0	-387.4	-428.3	-494.4	-536.8	-555.0	-655.8	-752.3	-840.8	-918.1	-982.0	-1034.8	-1090.1	-1109.0	-1109.0	-1140.0	-1140.0	-1109.0	-1109.0];
        buc_wr =-[188.5     271.0	387.4	428.3	494.4	536.8	591.1	661.2	726.6	782.8	825.9	853.0	873.6	909.9	948.9	985.6	1001.7	1034.5	1050.7	1299.0];
        buc_h =  [0.0       96.0	96.0	153.9	153.9	96.0	96.0	105.2	132.3	175.4	231.6	297.0	373.0	506.6	650.0	785.0	844.5	965.3	1024.7	1939.0];
        L = 7467; %[mm]
        f_anc = 2.144691653;
        t = 5; %[mm]
        roh1 = 2700e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
    case 'Alutip 47 m3 symmetrical' %In ISO z-up coordinates Y is +ve to the left
        buc_wl =-[0.0	-205.5	-283.0	-470.9	-510.1	-577.8	-617.0	-715.2	-802.9	-874.8	-925.2	-951.5	-1064.5	-1164.5];
        buc_wr =-[0.0	205.5	283.0	470.9	510.1	577.8	617.0	715.2	802.9	874.8	925.2	951.5	1064.5	1164.5];
        buc_h =  [0.0	0.0	94.0	94.0	142.7	142.7	94.0	120.3	169.7	241.2	327.5	404.7	1325.4	1633.0];
        L = 7500; %[mm]
        f_anc = 2.2;
        t = 5; %[mm]
        roh1 = 2700e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
    case 'Alutip 52 m3 symmetrical' %In ISO z-up coordinates Y is +ve to the left
        buc_wl =-[0.0	-205.5	-283.0	-470.9	-510.1	-577.8	-617.0	-715.2	-802.9	-874.8	-925.2	-951.5	-1085.5	-1164.5];
        buc_wr =-[0.0	205.5	283.0	470.9	510.1	577.8	617.0	715.2	802.9	874.8	925.2	951.5	1085.5	1164.5];
        buc_h =  [0.0	0.0	94.0	94.0	142.7	142.7	94.0	120.3	169.7	241.2	327.5	404.7	1496.0	1783.0];
        L = 7601; %[mm] %Changed from 7500 to 7601 19/10/2020
        f_anc = 2.2;
        t = 5; %[mm]
        roh1 = 2700e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
    case 'Alutip 55 m3 symmetrical' %In ISO z-up coordinates Y is +ve to the left
        buc_wl =-[0.0	-205.5	-283.0	-470.9	-510.1	-577.8	-617.0	-713.1	-799.3	-869.0	-918.6	-944.5	-1096.0	-1164.5];
        buc_wr =-[0.0	205.5	283.0	470.9	510.1	577.8	617.0	713.1	799.3	869.0	918.6	944.5	1096.0	1164.5];
        buc_h =  [0.0	0.0	94.0	94.0	142.7	142.7	94.0	116.8	170.2	239.5	325.8	427.0	1661.0	1883.0];
        L = 7500; %[mm]
        f_anc = 2.2;
        t = 5; %[mm]
        roh1 = 2700e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
    case 'CIMC 28 m3 (2021)'
        buc_wl = [   351     851     1117    1354    1535    1659    1979   2105    2406]/2;
        buc_wr =-[   351     851     1117    1354    1535    1659    1979   2105    2406]/2;
        buc_h =  [   49      0       0       76      181     304     931    977     1549];
        L = 4965;
        f_anc = 1.681651;
        t = 4; %[mm]
        roh1 = 7850e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
    case 'CIMC 40 m3'
        buc_wl = [   351     851     1117    1341    1515    1626    2333]/2;
        buc_wr =-[   351     851     1117    1341    1515    1626    2333]/2;
        buc_h = [   49      0       0       81      186     311     1546];
        L = 7200;
        f_anc = 1.572302;
        t = 4; %[mm]
        roh1 = 7850e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
    case 'CIMC 48 m3'
        buc_wl = [   351     851     1119    1438    1702    1896    2384]/2;
        buc_wr =-[   351     851     1119    1438    1702    1896    2384]/2;
        buc_h = [   49      0       0       62      167     301     1551];
        L = 7650; %[mm]Checked Volumes by hand = -225.2x10^6 0 606.4x10^6 ...
        f_anc = 1.7035;
        t = 4; %[mm]
        roh1 = 7850e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
    case 'LTB 19m3 Leader'
        buc_wl = [700 800 1600 2592]/2;
        buc_wr =-[700 800 1600 2592]/2;
        buc_h =  [0 200 200 1512]; %
        L = 5960; %[mm]
        f_anc = 2.003;
        t = 4; %[mm] Plate thickness acc.to D718-28 SHEET 1 OF 2 21/06/16
        roh1 = 7850e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
    case 'LTB 16m3 Follower'
        buc_wl = [1600 2592]/2;
        buc_wr =-[1600 2592]/2;
        buc_h =  [0 1117]; %
        L = 7200; %[mm]
        f_anc = 2.003;
        t = 4; %[mm] Plate thickness acc.to D718-28 SHEET 1 OF 2 21/06/16
        roh1 = 7850e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment        
    case 'LTB 12m3 Leader'
        buc_wl = [1600 2592]/2;
        buc_wr =-[1600 2592]/2;
        buc_h =  [0 1226]; %1226 = 2820-1590-4
        L = 5460; %[mm]
        f_anc = 2.003;
        t = 4; %[mm] Plate thickness acc.to D718-28 SHEET 1 OF 2 21/06/16
        roh1 = 7850e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
    case 'LTB 15m3 Follower'
        buc_wl = [1600 2592]/2;
        buc_wr =-[1600 2592]/2;
        buc_h =  [0 1226]; %1226 = 2636-1406-4
        L = 6000; %[mm]
        f_anc = 2.003;
        t = 4; %[mm] Plate thickness acc.to D718-28 SHEET 1 OF 2 21/06/16
        roh1 = 7850e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment 
    case 'SATB 50 m3'
        buc_wl = [   200     309     1125    1355    1565    1707    1786    1979    2081    2238    2453]/2;
        buc_wr =-[   200     309     1125    1355    1565    1707    1786    1979    2081    2238    2453]/2;
        buc_h = [   0       45      45      142     142     201     425     506     847     916     1635];
        L = 7500; %[mm]
        f_anc = 1.8; %[-] Ancilliaries loading factor (to take into account the ancilliary equipment such as pistons, mechanicals etc)
        t = 3; %[mm] Plate thickness acc.to D718-28 SHEET 1 OF 2 21/06/16
        roh1 = 7850e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
    otherwise
        error('THE REQUESTED BIN MODEL DOES NOT EXIST, PLEASE ADD DATA FOR THIS BIN INTO getBinCoG.m');
end
bet = angleRepose;
%% --------------------------------------------------------------------------------------
%	Calculations & Plotting
%----------------------------------------------------------------------------------------
[htot, hcog, ycog, Ixx, Iyy, Izz, wl, wr, mout] = inertia_calc(buc_wl,buc_wr,buc_h,roh,m,L,bet,isDome);
% Payload heights relative to bin bottom, inertias, width at top and mout
% Estimate approximate bucket mass, cog, Ixx, Iyy and Izz
[hcog1, ycog1, m1, Ixx1, Iyy1, Izz1] = inertia_calc1(buc_wl,buc_wr,buc_h,roh1,t,L); % Bucket - CoG heights relative to the bottom of the bin

%% --------------------------------------------------------------------------------------
%	Combining Inertias for TruckSim
%----------------------------------------------------------------------------------------
vMass = [mout m1]; %Mass of each inertial entity [kg]
vIxx = [Ixx Ixx1].*10^-6; %Roll inertia for each inertial entity [kg.m^2]
vIyy = [Iyy Iyy1].*10^-6; %Pitch inertia for each inertial entity [kg.m^2]
vIzz = [Izz Izz1].*10^-6;%; %Yaw inertia for each inertial entity [kg.m^2]
vCoGx = [L*0.5 L*0.5] + x_hitch; %x coordinate of CoG relative to steer axle (if on superstructure) or hitch point (if trailer load) [mm] including hitch offsets (x_hitch)
vCoGy = [ycog ycog1]; %y coordinate of CoG relative to centre of vehicle [mm]
vCoGz = [hcog hcog1] + h_bin; %z coordinate of CoG relative to the road surface [mm]

xcogPayload = vCoGx(1);
combinedInertias = computeCombinedInertias_WithMomentOfInertia(vMass, vIxx, vIyy, vIzz, vCoGx, vCoGy, vCoGz);
%% --------------------------------------------------------------------------------------
%	Plotting results
%----------------------------------------------------------------------------------------
if isSavePlot
    figure('name', 'BinCoG');
    axis equal
    hold on;
    plotbucketout(buc_wl,buc_wr,buc_h);
    plotload(buc_wl,buc_wr,buc_h,wl,wr,htot,bet,isDome);
    plot(ycog,hcog,'ko','markersize',6);
    plot(ycog,hcog,'k+','markersize',10);
    h1=plot([ycog ycog],[0 hcog],'color','k');
    h2=plot([0 ycog],[hcog hcog],'color','k');
    xAxisLengthVector=xlim;
    xAxisLength=xAxisLengthVector(2)-xAxisLengthVector(1);
    yAxisLengthVector=ylim;
    yAxisLength=yAxisLengthVector(2)-yAxisLengthVector(1);
    t1=text(ycog+xAxisLength*0.02,hcog/2,num2str(hcog,'%.0f'),'Rotation',90);
    t2=text(ycog/2,hcog+yAxisLength*0.02,num2str(ycog,'%.0f'));
    set(gcf,'PaperPosition',[0 0 16 11])
    set(gca,'Xgrid','on');
    set(gca,'Ygrid','on');
    savePlot(savePath, runKey, sheetName)
    
    %% --------------------------------------------------------------------------------------
    %	Printing results to Excel
    %----------------------------------------------------------------------------------------
    if isSaveExcel
        inputHeadings = {'Payload mass input [kg]' 'Payload density [kg/m^3]' 'Loaded Volume [m^3]' 'Bin wall thickness [mm]' 'Bin density [kg/m^3]' 'Ancilliary load factor [-]' 'Angle of repose [deg]' 'Load height from top of bin [mm]', 'Modelled as a Dome'};
        inputs = [m round(roh*10^9) round((mout/(roh*10^9)),6) t roh1/f_anc*10^9 f_anc bet round((buc_h(length(buc_h))-htot),1) isDome];
        resultsHeadings = {'Payload load height [mm]' 'Payload mass [kg]' 'Payload CoGx [mm]' 'Payload CoGy [mm]' 'Payload CoGz rel. to ground [mm]' 'Payload Ixx [kg.m^2]' 'Payload Iyy [kg.m^2]' 'Payload Izz [kg.m^2]' 'Payload Rx [m]' 'Payload Ry [m]' 'Payload Rz [m]' 'Bucket mass [kg]' 'Bucket CoGx' 'Bucket CoGy' 'Bucket CoGz rel. to ground [mm]' 'Bucket Ixx [kg.m^2]' 'Bucket Iyy [kg.m^2]' 'Bucket Izz [kg.m^2]' 'Combined Mass [kg]' 'Combined CoGx rel. to hitch [mm]' 'Combined CoGy [mm]' 'Combined CoGz rel. to ground [mm]' 'Combined Ixx [kg.m^2]' 'Combined Iyy [kg.m^2]' 'Combined Izz [kg.m^2]' 'Combined Rx [m]' 'Combined Ry [m]' 'Combined Rz [m]'};
        results = [round([htot mout vCoGx(1) vCoGy(1) vCoGz(1) Ixx*10^-6 Iyy*10^-6 Izz*10^-6],1) round([((Ixx*10^-6)/mout)^0.5 ((Iyy*10^-6)/mout)^0.5 ((Izz*10^-6)/mout)^0.5],4) round([m1 vCoGx(2) vCoGy(2) vCoGz(2) Ixx1*10^-6 Iyy1*10^-6 Izz1*10^-6 combinedInertias],1) round([(combinedInertias(5)/combinedInertias(1))^0.5 (combinedInertias(6)/combinedInertias(1))^0.5 (combinedInertias(7)/combinedInertias(1))^0.5],4)] ;
        writeExcelInertia_WithMomentOfInertia(fileName, savePath, inputHeadings, resultsHeadings, inputs, results, sheetName);
    end
    payloadSummary = {'Payload mass output [kg]', mout;...
        'Payload density [kg/m^3]', roh*10^9;...
        'Load height from top of bin [mm]', (buc_h(length(buc_h))-htot);...
        'Payload CoGz rel. to ground [mm]', (hcog+h_bin);...
        'Payload CoGx rel. to hitch [mm]', xcogPayload;...
        'Payload Rx [m]', ((Ixx*10^-6)/mout)^0.5;...
        'Payload Ry [m]', ((Iyy*10^-6)/mout)^0.5;...
        'Payload Rz [m]', ((Izz*10^-6)/mout)^0.5;...
        'Loaded Volume [m^3]', (mout/(roh*10^9));...
        'Angle of repose [deg]', bet;...
        'Bucket mass [kg]', m1;...
        'Modelled as a Dome', isDome;...        
        } %Results to display in PostProcessor
end
end

function [hcog1, ycog1, m1, Ixx1, Iyy1, Izz1]=inertia_calc1(buc_wl,buc_wr,buc_h,roh,t,L) %Bucket
%
% Front and back plate. Analysed individually.
volumeFrontOrBackPlate=(buc_wl(2:end)+buc_wl(1:end-1)-buc_wr(2:end)-buc_wr(1:end-1))/2.*(buc_h(2:end)-buc_h(1:end-1))*t;
volumeFrontOrBackPlateTotal=sum(volumeFrontOrBackPlate);
massFrontOrBackPlate=roh*volumeFrontOrBackPlate;
massFrontOrBackPlateTotal=roh*volumeFrontOrBackPlateTotal;
%
hcogFrontOrBackPlate=CentroidZtrapeziod(buc_h(2:end)-buc_h(1:end-1),buc_wl(2:end)-buc_wr(2:end),buc_wl(1:end-1)-buc_wr(1:end-1))+buc_h(1:end-1);
hcogFrontOrBackPlateTotal=sum(hcogFrontOrBackPlate.*massFrontOrBackPlate)/massFrontOrBackPlateTotal;
ycogFrontOrBackPlate=CentroidYtrapeziod(buc_wl(2:end)-buc_wr(2:end),buc_wl(1:end-1)-buc_wr(1:end-1),buc_wr(2:end)-buc_wr(1:end-1))+buc_wr(1:end-1);
ycogFrontOrBackPlateTotal=sum(ycogFrontOrBackPlate.*massFrontOrBackPlate)/massFrontOrBackPlateTotal;
%
ixxFrontOrBackPlate=Ixxc(buc_h(2:end)-buc_h(1:end-1),buc_wl(2:end)-buc_wr(2:end),buc_wl(1:end-1)-buc_wr(1:end-1),buc_wr(2:end)-buc_wr(1:end-1),massFrontOrBackPlate);
IxxFrontOrBackPlate=sum(ixxFrontOrBackPlate)+sum(massFrontOrBackPlate.*((hcogFrontOrBackPlate-hcogFrontOrBackPlateTotal).^2+(ycogFrontOrBackPlate-ycogFrontOrBackPlateTotal).^2));
iyyFrontOrBackPlate=Iyyc(buc_h(2:end)-buc_h(1:end-1),buc_wl(2:end)-buc_wr(2:end),buc_wl(1:end-1)-buc_wr(1:end-1),2*t,massFrontOrBackPlate);
IyyFrontOrBackPlate=sum(iyyFrontOrBackPlate)+sum(massFrontOrBackPlate.*(hcogFrontOrBackPlate-hcogFrontOrBackPlateTotal).^2)+massFrontOrBackPlateTotal*L^2/4;
izzFrontOrBackPlate=Izzc(buc_wl(2:end)-buc_wr(2:end),(buc_wl(1:end-1)-buc_wr(1:end-1)),buc_wr(2:end)-buc_wr(1:end-1),2*t,massFrontOrBackPlate);
IzzFrontOrBackPlate=sum(izzFrontOrBackPlate)+sum(massFrontOrBackPlate.*(ycogFrontOrBackPlate-ycogFrontOrBackPlateTotal).^2)+massFrontOrBackPlateTotal*L^2/4;
%
% Bottom and side plates
w0=(buc_wr(1)+buc_wl(1))/2;
plateDeltaYL=+buc_wl(1:end)-[w0 buc_wl(1:end-1)];
plateDeltaYR=-buc_wr(1:end)+[w0 buc_wr(1:end-1)];
plateDeltaH =buc_h(1:end)-[buc_h(1) buc_h(1:end-1)];
anglePlateL =atan2d(plateDeltaH,plateDeltaYL);
anglePlateR =atan2d(plateDeltaH,plateDeltaYR);
plateWidthL=(plateDeltaYL.^2+plateDeltaH.^2).^0.5;
plateWidthR=(plateDeltaYR.^2+plateDeltaH.^2).^0.5;
totalPlateWidth=sum([plateWidthL plateWidthR]);
%
plateHcogL=[0 (buc_h(2:end)+buc_h(1:end-1))/2]-t/2*cosd(anglePlateL);
plateHcogR=[0 (buc_h(2:end)+buc_h(1:end-1))/2]-t/2*cosd(anglePlateR);
plateYcogL=(buc_wl(1:end)+[w0 buc_wl(1:end-1)])/2+t/2*sind(anglePlateL);
plateYcogR=(buc_wr(1:end)+[w0 buc_wr(1:end-1)])/2-t/2*sind(anglePlateR);
%
plateLength=L+2*t;
plateMassL=plateWidthL*plateLength*t*roh;
plateMassR=plateWidthR*plateLength*t*roh;
massBackAndSidesTotal=sum([plateMassL plateMassR]);
massTotal=massFrontOrBackPlateTotal*2+massBackAndSidesTotal; %Total mass of empty bin
%
hcog1=sum(([plateHcogL plateHcogR hcogFrontOrBackPlateTotal]).*([plateMassL plateMassR massFrontOrBackPlateTotal*2]))/massTotal;
ycog1=sum(([plateYcogL plateYcogR ycogFrontOrBackPlateTotal]).*([plateMassL plateMassR massFrontOrBackPlateTotal*2]))/massTotal;
m1=massTotal;
%
Ixx1=sum([1/12*plateMassL.*([(plateDeltaYL).^2+(plateDeltaH).^2]) +plateMassL.*(hcog1-plateHcogL).^2 +plateMassL.*(ycog1-plateYcogL).^2])... %left plates
    +sum([1/12*plateMassR.*([(plateDeltaYR).^2+(plateDeltaH).^2]) +plateMassR.*(hcog1-plateHcogR).^2 +plateMassR.*(ycog1-plateYcogR).^2])... %right plates
    +2*IxxFrontOrBackPlate+2*massFrontOrBackPlateTotal*(hcog1-hcogFrontOrBackPlateTotal)^2+2*massFrontOrBackPlateTotal*(ycog1-ycogFrontOrBackPlateTotal)^2; %front and back plates
Iyy1=sum([1/12*plateMassL.*([                 +(plateDeltaH).^2]) +plateMassL.*(hcog1-plateHcogL).^2                                   ])... %left plates
    +sum([1/12*plateMassR.*([                 +(plateDeltaH).^2]) +plateMassR.*(hcog1-plateHcogR).^2                                   ])... %right plates
    +2*IyyFrontOrBackPlate+2*massFrontOrBackPlateTotal*(hcog1-hcogFrontOrBackPlateTotal)^2+2*massFrontOrBackPlateTotal*(L/2+t/2)^2; %front and back plates
Izz1=sum([1/12*plateMassL.*([(plateDeltaYL).^2                 ])                                   +plateMassL.*(ycog1-plateYcogL).^2])... %left plates
    +sum([1/12*plateMassR.*([(plateDeltaYR).^2+(plateDeltaH).^2])                                   +plateMassR.*(ycog1-plateYcogR).^2])... %right plates
    +2*IzzFrontOrBackPlate+2*massFrontOrBackPlateTotal*(L/2+t/2)^2+2*massFrontOrBackPlateTotal*(ycog1-ycogFrontOrBackPlateTotal).^2; %front and back plates
end

function [htot, hcog, ycog, Ixx, Iyy, Izz, wl, wr, mout]=inertia_calc(buc_wl,buc_wr,buc_h,roh,m,L,bet,isDome); %Ore
Vbuc_nh=(buc_wl(2:end)-buc_wr(2:end)+(buc_wl(1:end-1)-buc_wr(1:end-1))).*(buc_h(2:end)-buc_h(1:end-1))/2*L; % No heap = nh
% Below calculate Vbuc which is with heap
% A_dome = (w^2*(90*sin((pi*bet)/90) - pi*bet))/(360*(cos((pi*bet)/90) - 1))
% V_dome = (w^3*pi*(cos((pi*bet)/180) - 1)^2*(cos((pi*bet)/180) + 2))/(24*sin((bet*pi)/180)^3)
if isDome %using sliced sausage or cylindrical tank: V1 is the inside bits and V2 is made up of the outside bits
    % V1heap inside heap or prism: vector of the heap on each layer
    wA=[buc_wl(2:end-1)-buc_wr(2:end-1)]; %bottom width
    wB=buc_wl(2:end)-buc_wr(2:end); %top width
    V1heap=(wB.^2*(90*sin((pi*bet)/90) - pi*bet))/(360*(cos((pi*bet)/90) - 1)).*(L-wB) - ...
        [0 (wA.^2*(90*sin((pi*bet)/90) - pi*bet))/(360*(cos((pi*bet)/90) - 1)).*(L-wA)];
    % V2heap outside heap or cone
    V2heap=(wB.^3*pi*(cos((pi*bet)/180) - 1)^2*(cos((pi*bet)/180) + 2))/(24*sin((bet*pi)/180)^3) - ...
           [0 (wA.^3*pi*(cos((pi*bet)/180) - 1)^2*(cos((pi*bet)/180) + 2))/(24*sin((bet*pi)/180)^3)];
else %using triangular prism: V1 is the inside bits and V2 is made up of the outside bits
    % V1heap inside heap or prism: vector of the heap on each layer
    %V1heap=((buc_wl(2:end)-buc_wr(2:end))/4*tand(bet).*(buc_wl(2:end)-buc_wr(2:end)).*(L-(buc_wl(2:end)-buc_wr(2:end)))) - [0 ((buc_wl(2:end-1)-buc_wr(2:end-1))/4*tand(bet).*(buc_wl(2:end-1)-buc_wr(2:end-1)).*(L-(buc_wl(2:end-1)-buc_wr(2:end-1))))];
    %              height                             *  width * length
    % V2heap outside heap or cone
    %V2heap=(( buc_wl(2:end)-buc_wr(2:end) ).^3*pi*(cos((pi*bet)/180) - 1)^2*(cos((pi*bet)/180) + 2))/(24*sin((bet*pi)/180)^3) - ...
    %      (([0 buc_wl(2:end-1)-buc_wr(2:end-1)]).^3*pi*(cos((pi*bet)/180) - 1)^2*(cos((pi*bet)/180) + 2))/(24*sin((bet*pi)/180)^3);
    wA=[buc_wl(2:end-1)-buc_wr(2:end-1)]; %bottom width
    wB=buc_wl(2:end)-buc_wr(2:end); %top width
    V1heap=0.5*wB.*wB/2*tand(bet).*(L-wB) -...
           [0 0.5*wA.*wA/2*tand(bet).*(L-wA)];
    % V2heap outside heap or cone
    V2heap=(wB.^3*pi*(cos((pi*bet)/180) - 1)^2*(cos((pi*bet)/180) + 2))/(24*sin((bet*pi)/180)^3) - ...
           [0 (wA.^3*pi*(cos((pi*bet)/180) - 1)^2*(cos((pi*bet)/180) + 2))/(24*sin((bet*pi)/180)^3)];    
end
Vbuc=Vbuc_nh+V1heap+V2heap;
Vtot=sum(Vbuc);
mbuc=roh*Vbuc;
mbuc_nh=roh*Vbuc_nh;
mtot=roh*Vtot;
mbuccum=cumsum(mbuc);
mbuccum_nh=cumsum(mbuc_nh);
ind=find(m<mbuccum,1,'first');
if isempty(ind)
    htot=buc_h(end);
    wl=buc_wl(end);
    wr=buc_wr(end);
    ind=length(mbuccum);
    disp(['Bucket overflows. Maximum m = ' num2str(mbuccum(end))]) ;
    mout=mbuccum(end);
else
    h1=buc_h(ind); % To bottom height
    h2=buc_h(ind+1); % To upper height
    dh12=h2-h1; % Distance in height between upper height and lower height
    w1=buc_wl(ind)-buc_wr(ind); % Lower width
    w2=buc_wl(ind+1)-buc_wr(ind+1); % Upper width
    a=(w2-w1)/dh12; % Coefficient a for w = a*dh+b
    b=w1; % Coefficient b for w = a*dh+b
    if ind == 1,
        top_layerV = m/roh;
    else
        top_layerV = (m-mbuccum_nh(ind-1))/roh;
    end
    if isDome
        if (w1^2/4*tand(bet)*(L-w1)+pi*w1^3/24*tand(bet))*roh>m %MUST correct
            disp(['The bucket does not have enough material to fill the floor of the bucket. Expect unreliable results.']) ;
        end
    else
        if (w1^2/4*tand(bet)*(L-w1)+pi*w1^3/24*tand(bet))*roh>m %MUST correct
            disp(['The bucket does not have enough material to fill the floor of the bucket. Expect unreliable results.']) ;
        end
    end
    if isDome
        % E:\_Frank\1 Research\Calculations\9MOI_TipperBins\20250119 Analysis
        %((a^3*pi*(cos((pi*bet)/180) - 1)^2*(cos((pi*bet)/180) + 2))/(24*sin((bet*pi)/180)^3) - (a^3*(90*sin((pi*bet)/90) - pi*bet))/(360*cos((pi*bet)/90) - 360))*dh^3 + ((L*a)/2 - (2*a^2*b*(90*sin((pi*bet)/90) - pi*bet))/(360*cos((pi*bet)/90) - 360) + (a^2*(90*sin((pi*bet)/90) - pi*bet)*(L - b))/(360*cos((pi*bet)/90) - 360) + (a^2*b*pi*(cos((pi*bet)/180) - 1)^2*(cos((pi*bet)/180) + 2))/(8*sin((bet*pi)/180)^3))*dh^2 + (L*b - (a*b^2*(90*sin((pi*bet)/90) - pi*bet))/(360*cos((pi*bet)/90) - 360) + (2*a*b*(90*sin((pi*bet)/90) - pi*bet)*(L - b))/(360*cos((pi*bet)/90) - 360) + (a*b^2*pi*(cos((pi*bet)/180) - 1)^2*(cos((pi*bet)/180) + 2))/(8*sin((bet*pi)/180)^3))*dh + (b^2*(90*sin((pi*bet)/90) - pi*bet)*(L - b))/(360*cos((pi*bet)/90) - 360) + (b^3*pi*(cos((pi*bet)/180) - 1)^2*(cos((pi*bet)/180) + 2))/(24*sin((bet*pi)/180)^3) == m1/roh
        c3=((a^3*pi*(cos((pi*bet)/180) - 1)^2*(cos((pi*bet)/180) + 2))/(24*sin((bet*pi)/180)^3) - (a^3*(90*sin((pi*bet)/90) - pi*bet))/(360*cos((pi*bet)/90) - 360));
        c2=((L*a)/2 - (2*a^2*b*(90*sin((pi*bet)/90) - pi*bet))/(360*cos((pi*bet)/90) - 360) + (a^2*(90*sin((pi*bet)/90) - pi*bet)*(L - b))/(360*cos((pi*bet)/90) - 360) + (a^2*b*pi*(cos((pi*bet)/180) - 1)^2*(cos((pi*bet)/180) + 2))/(8*sin((bet*pi)/180)^3));
        c1=(L*b - (a*b^2*(90*sin((pi*bet)/90) - pi*bet))/(360*cos((pi*bet)/90) - 360) + (2*a*b*(90*sin((pi*bet)/90) - pi*bet)*(L - b))/(360*cos((pi*bet)/90) - 360) + (a*b^2*pi*(cos((pi*bet)/180) - 1)^2*(cos((pi*bet)/180) + 2))/(8*sin((bet*pi)/180)^3));
        c0=(b^2*(90*sin((pi*bet)/90) - pi*bet)*(L - b))/(360*cos((pi*bet)/90) - 360) + (b^3*pi*(cos((pi*bet)/180) - 1)^2*(cos((pi*bet)/180) + 2))/(24*sin((bet*pi)/180)^3) - top_layerV;
        dhall=roots([c3 c2 c1 c0]); %cubic of dh
        htot=min(dhall(dhall>0))+h1;
    else %prism
        % E:\_Frank\1 Research\Calculations\9MOI_TipperBins\20250119 Analysis
        %((a^3*pi*(cos((pi*bet)/180) - 1)^2*(cos((pi*bet)/180) + 2))/(24*sin((bet*pi)/180)^3) - (a^3*tan((pi*bet)/180))/4)*dh^3 + ((L*a)/2 - (a^2*b*tan((pi*bet)/180))/2 + (a^2*tan((pi*bet)/180)*(L - b))/4 + (a^2*b*pi*(cos((pi*bet)/180) - 1)^2*(cos((pi*bet)/180) + 2))/(8*sin((bet*pi)/180)^3))*dh^2 + (L*b - (a*b^2*tan((pi*bet)/180))/4 + (a*b*tan((pi*bet)/180)*(L - b))/2 + (a*b^2*pi*(cos((pi*bet)/180) - 1)^2*(cos((pi*bet)/180) + 2))/(8*sin((bet*pi)/180)^3))*dh + (b^2*tan((pi*bet)/180)*(L - b))/4 + (b^3*pi*(cos((pi*bet)/180) - 1)^2*(cos((pi*bet)/180) + 2))/(24*sin((bet*pi)/180)^3) == m1/roh
        c3=((a^3*pi*(cos((pi*bet)/180) - 1)^2*(cos((pi*bet)/180) + 2))/(24*sin((bet*pi)/180)^3) - (a^3*tan((pi*bet)/180))/4);
        c2=((L*a)/2 - (a^2*b*tan((pi*bet)/180))/2 + (a^2*tan((pi*bet)/180)*(L - b))/4 + (a^2*b*pi*(cos((pi*bet)/180) - 1)^2*(cos((pi*bet)/180) + 2))/(8*sin((bet*pi)/180)^3));
        c1=(L*b - (a*b^2*tan((pi*bet)/180))/4 + (a*b*tan((pi*bet)/180)*(L - b))/2 + (a*b^2*pi*(cos((pi*bet)/180) - 1)^2*(cos((pi*bet)/180) + 2))/(8*sin((bet*pi)/180)^3));
        c0=(b^2*tan((pi*bet)/180)*(L - b))/4 + (b^3*pi*(cos((pi*bet)/180) - 1)^2*(cos((pi*bet)/180) + 2))/(24*sin((bet*pi)/180)^3) - top_layerV;        
        dhall=roots([c3 c2 c1 c0]); %cubic of dh
        htot=min(dhall(dhall>0))+h1;
    end
end
mout=m;
%
% Non heaped layers first. NB nh stands for no heap
buc_wr(ind+1)=buc_wr(ind)+(buc_wr(ind+1)-buc_wr(ind))*(htot-buc_h(ind))/(buc_h(ind+1)-buc_h(ind));
buc_wl(ind+1)=buc_wl(ind)+(buc_wl(ind+1)-buc_wl(ind))*(htot-buc_h(ind))/(buc_h(ind+1)-buc_h(ind));
buc_h(ind+1)=htot;
buc_wr=buc_wr(1:ind+1);
buc_wl=buc_wl(1:ind+1);
buc_h=buc_h(1:ind+1);
Vbuc_nh=((buc_wl(2:end)-buc_wr(2:end))+(buc_wl(1:end-1)-buc_wr(1:end-1))).*(buc_h(2:end)-buc_h(1:end-1))/2*L ;
Vtot_nh=sum(Vbuc_nh);
mbuc_nh=roh*Vbuc_nh;
mtot_nh=roh*Vtot_nh;
mbuccum_nh=cumsum(mbuc_nh);
h_nh=CentroidZtrapeziod(buc_h(2:ind+1)-buc_h(1:ind),(buc_wl(2:ind+1)-buc_wr(2:ind+1)),(buc_wl(1:ind)-buc_wr(1:ind)))+buc_h(1:ind);
y_nh=CentroidYtrapeziod((buc_wl(2:ind+1)-buc_wr(2:ind+1)),(buc_wl(1:ind)-buc_wr(1:ind)),(buc_wr(2:ind+1)-buc_wr(1:ind)))+buc_wr(1:ind);
%%
%A_dome = (w^2*(90*sin((pi*bet)/90) - pi*bet))/(360*(cos((pi*bet)/90) - 1))
%hcog_A_dome = (w*(1080*cos((pi*bet)/180)^2*sin((pi*bet)/180) - 6*bet*pi*cos((pi*bet)/180) + 4*bet*pi*sin((pi*bet)/180) - 3*bet*w*pi*cos((pi*bet)/180)))/(2160*cos((pi*bet)/180)^3 - 2160*cos((pi*bet)/180) + 12*bet*pi*sin((pi*bet)/180))
%V_dome = (w^3*pi*(cos((pi*bet)/180) - 1)^2*(cos((pi*bet)/180) + 2))/(24*sin((bet*pi)/180)^3)
%hcog_V_dome = -(w*(2*cos((pi*bet)/180) + cos((pi*bet)/180)^2 - 3))/(4*sin((pi*bet)/90) + 16*sin((pi*bet)/180))
%
% Heaped layer on top
w=buc_wl(ind+1)-buc_wr(ind+1);
wl=buc_wl(ind+1); %left
wr=buc_wr(ind+1); %right
if isDome
    V1heap=((w^2*(90*sin((pi*bet)/90) - pi*bet))/(360*(cos((pi*bet)/90) - 1)))*(L-w); %Middle bit
    V2heap= (w^3*pi*(cos((pi*bet)/180) - 1)^2*(cos((pi*bet)/180) + 2))/(24*sin((bet*pi)/180)^3); %Edge bits
    m1heap=V1heap*roh;
    m2heap=V2heap*roh;
    h1= - (2*w*sin((pi*bet)/180)^2)/(3*(sin((pi*bet)/90) - (pi*bet)/90)) - (w*cos((pi*bet)/180))/(2*sin((pi*bet)/180))+ htot; %Middle bits
    h2=-(w*(2*cos((pi*bet)/180) + cos((pi*bet)/180)^2 - 3))/(4*sin((pi*bet)/90) + 16*sin((pi*bet)/180)) + htot; %Edge bits
    y1=(buc_wl(ind+1)+buc_wr(ind+1))/2;
    y2=(buc_wl(ind+1)+buc_wr(ind+1))/2;
else
    V1heap=w^2/4*tand(bet)*(L-w); %Middle bit
    V2heap= (w^3*pi*(cos((pi*bet)/180) - 1)^2*(cos((pi*bet)/180) + 2))/(24*sin((bet*pi)/180)^3); %Edge bits
    m1heap=V1heap*roh;
    m2heap=V2heap*roh;
    h1=w*tand(bet)/2/3+htot; % CoG height of prism 1/3 up total height
    h2=-(w*(2*cos((pi*bet)/180) + cos((pi*bet)/180)^2 - 3))/(4*sin((pi*bet)/90) + 16*sin((pi*bet)/180)) + htot; %Edge bits
    y1=(buc_wl(ind+1)+buc_wr(ind+1))/2;
    y2=(buc_wl(ind+1)+buc_wr(ind+1))/2;
end
%
mbuc=[mbuc_nh m1heap m2heap];
mtot=sum(mbuc);
h=[h_nh h1 h2];
hcog=sum(h.*mbuc)/mtot;
y=[y_nh y1 y2];
ycog=sum(y.*mbuc)/mtot;
%
%Ixx=Ixxc(h,a,b,c,m)
%Iyy=Iyyc(h,a,b,L,m
%Izz=Izzc(a,b,c,L,m)
h_for_i = (buc_h(2:ind+1)-buc_h(1:ind));
a_for_i = (buc_wl(2:ind+1)-buc_wr(2:ind+1));
b_for_i = (buc_wl(1:ind)-buc_wr(1:ind));
c_for_i = buc_wr(2:ind+1)-buc_wr(1:ind);
L_for_i = L;
% Used for both isDome and !isDome, close enough approximation
ixx=[Ixxc(h_for_i,a_for_i,b_for_i,c_for_i,mbuc_nh) Ixxc(w*tand(bet)/2,0,w,w/2,m1heap) 3/80*m2heap*(w*tand(bet)/2)^2+3/20*m2heap*(w/2)^2];
iyy=[Iyyc(h_for_i,a_for_i,b_for_i,L,mbuc_nh) Iyyc(w*tand(bet)/2,0,w,L-w,m1heap) m2heap*(3/80*(w*tand(bet)/2)^2+(3/20-1/4/pi^2)+(L/2-w/2+w/2/2/pi)^2)];
izz=[Izzc(a_for_i,b_for_i,c_for_i,L,mbuc_nh) Izzc(0,w,w/2,L-w,m1heap) m2heap*((3/10-4/pi^2)*(w/2)^2+(L/2-w/2+w/2/2/pi)^2)];    
Ixx=sum(ixx)+sum(mbuc.*[(h-hcog).^2+(y-ycog).^2]);
Iyy=sum(iyy)+sum(mbuc.*(h-hcog).^2);
Izz=sum(izz)+sum(mbuc.*(y-ycog).^2);
end

function cz=CentroidZtrapeziod(h,a,b) %trapezoid y-CoG relative to bottom left cnr
%      | c |  a  |
%           -----   -
%          /     |
%         /      |  h
%        /       |
%        --------   -
%       |    b   |
%
% https://www.efunda.com/math/areas/trapezoid.cfm
% E:\_Frank\Research\Calculations\9MOI\Trapezoid.png
cz=h/3.*(b+2.*a)./(a+b);
end

function cy=CentroidYtrapeziod(a,b,c) %trapezoid x-CoG relative to bottom left cnr
cy=(2.*a.*c+a.^2+c.*b+a.*b+b.^2)./3./(a+b);
end

function Ixx=Ixxc(h,a,b,c,m) %trapezoid
Ixx=(2.*(4.*h.^2.*a.*b+h.^2.*b.^2+h.^2.*a.^2+4.*a.*b.*c.^2+3.*a.^2.*b.*c-3.*a.*b.^2.*c+a.^4+b.^4+2.*a.^3.*b+a.^2.*c.^2+a.^3.*c+2.*a.*b.^3-c.*b.^3+b.^2.*c.^2))/36./(a+b).^2.*m;
end

function Iyy=Iyyc(h,a,b,L,m) %trapezoid
Iyy=(h.^2.*(2+4*a.*b./(a+b).^2)/36+L^2/12).*m;
end

function Izz=Izzc(a,b,c,L,m) %trapezoid
Izz=((2*(4.*a.*b.*c.^2+3.*a.^2.*b.*c-3*a.*b.^2.*c+a.^4+b.^4+2*a.^3.*b+a.^2.*c.^2+a.^3.*c+2*a.*b.^3-b.^3.*c+b.^2.*c.^2))/36./(a+b).^2+L.^2/12).*m;
end

function plotbucketout(buc_wl,buc_wr,buc_h)
set(gca,'XDir','reverse')
sta_wl=[0];
sta_wr=[0];
sta_h=[buc_h(1)];
for i=1:length(buc_h)
    plot([sta_wl(1) buc_wr(i)],[sta_h(1) buc_h(i)],'k-');
    plot([sta_wr(1) buc_wl(i)],[sta_h(1) buc_h(i)],'k-');
    sta_wl=buc_wr(i);
    sta_wr=buc_wl(i);
    sta_h=buc_h(i);
end
axis equal;
end

function plotload(buc_wl,buc_wr,buc_h,wl,wr,htot,bet,isDome)
set(gca,'XDir','reverse')
w=wl-wr;
centre_x=(wl+wr)/2;
y1=buc_h(find(htot>buc_h,1,'last'));
y2=htot;
x1=buc_wl(find(htot>buc_h,1,'last'));
x2=wl;
if isDome
    centre_y = htot-(w/2)/tand(bet);
    radius = (w/2)/sind(bet);
    x_pts = sind([-bet:1:bet])*radius+centre_x;
    y_pts = cosd([-bet:1:bet])*radius+centre_y;
    plot(x_pts,y_pts,'k-');
else
    plot([wl centre_x],[htot htot+tand(bet)*w/2],'k-');
    plot([wr centre_x],[htot htot+tand(bet)*w/2],'k-');
end
end