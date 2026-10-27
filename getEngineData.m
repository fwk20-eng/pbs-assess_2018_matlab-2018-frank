%% Function Description
%
% This function stores and returns the engine properties depending on the engine model as designated by a string
%
%% Inputs
%
% * engineModel: string indicating the engine make and model
% * Tyre.NumberOff: total number of tyres present on the combination
%
%% Outputs
%
% * Engine: structure containing all of the engine properties required to determine the longitudinal
%
%% Change Log
%% [0.8.0] - 2022-12-18
% * Added MAN D2066 LF49 engine and MAN_TipMatic 12 26 OD
%% [0.7.0] - 2021-04-02
% * Brought define of Engine.gearshiftregime=2 to front.
% * Allows gearshiftregime to redefined=1 for small engines and 6 sp. gear.
%% [0.6.0] - 2020-07-16
% * Corrected Engine.engageTNm to be choose minimum of 75%max torque and
% first value not minimum torque as it could choose end value
%% [0.5.0] - 2020-07-01
% * Changed Engine.engageTNm to be 75% of maximum Torque and no longer 50%
% See 20200701DuncanPrinceCompareLongitudinalCalcs.docx
% Removed incorrect Engine.changeT from gearbox data in Volvo gearboxes
% [0.4.0] - 2020-06-12
% * Changed all efficiences to 0.96 for gears 0.98 for 1:1 and diff 0.96
%% [0.3.0] - 2018-04-14
% * User may now enter a custom diff ratio if required - diff ratio eventually to be replaced by user entry.
% * Updated to a structure input dataset to improve the functionality
%% [0.2.0] - 2017-06-03
% * Seperated the engines from the gearboxes
%% [0.1.0] - 2017-05-01
% * Added changed output to a structure
function [Engine] = getEngineData(Combination, Tyre)
%%   Calculated engine properties
Engine.Ie = 2.75; %engine inertia 2.75 kg/m^2
Engine.It = Tyre.NumberOff*14; %tyre inertia 14 kg/m^2

%% Engine
switch Combination.engineModel
        case 'DAF MX-13 355 kW'
        
        Engine.EngineModelDescription = 'DAF MX-13 355 kW';
        Engine.changeT = 1800; %Sensible value on curve
        Engine.Torquerpm = [700	854	1002	1244	1429	1601	1800];%    2100];
        Engine.TorqueNm =  [1598	2004	2495	2500	2273	2107	1780];%    1458];
        Engine.PowerNomHP = 480;
        
        case 'DAF MX-13 390 kW'        
        Engine.EngineModelDescription = 'DAF MX-13 390 kW';
        Engine.changeT = 1800; %Sensible value on curve
        Engine.Torquerpm = [700     779     842     911     998     1099	1202	1305	1396	1511	1613	1711	1790	1844	1888	1943];%    2100];
        Engine.TorqueNm =  [1697	1955	2153	2324	2599	2599	2599	2599	2598	2428	2292	2137	1966	1767	1582	1350];
        Engine.PowerNomHP = 530;
        
        case 'Hino E13C-BF'
        
        Engine.EngineModelDescription = 'Hino E13C-BF';
        Engine.changeT = 2000; %RPM where power is max, change down RPM
        Engine.Torquerpm = [1000	1061	1134	1233	1332	1431	1490	1530	1630	1729	1828	1927	2000];%    2100];
        Engine.TorqueNm =  [2062	2158	2160	2158	2160	2148	2117	2064	1943	1827	1724	1615	1545];%    1458];
        Engine.PowerNomHP = 450;
        
    case 'Hino J08E-WH'
        
        Engine.EngineModelDescription = 'Hino J08E-WH';
        Engine.changeT = 2400; %RPM where power is max, change down RPM
        Engine.Torquerpm = [1000	1420	1810	2208	2400];
        Engine.TorqueNm =  [767     792     793     778     760];
        Engine.PowerNomHP = 260;

    case 'Paccar MX340'
        
        Engine.EngineModelDescription = 'Paccar MX340';
        Engine.changeT = 2060; %RPM where power is max, change down RPM
        Engine.Torquerpm = [1031	1376	1533	1687	1834	1958	2060];
        Engine.TorqueNm =  [2301	2301	2138	1996	1871	1774	1700];
        Engine.PowerNomHP = 460;
        
    case 'MAN D2066 LF49'
        
        Engine.EngineModelDescription = 'MAN D2066 LF49 - 400 HP';
        Engine.changeT = 1900; %RPM where power is max, change down RPM
        Engine.Torquerpm = [1000	1033	1095	1157	1218	1280	1342	1404	1466	1528	1590	1652	1714	1775	1837	1887	1900];
        Engine.TorqueNm =  [1896	1896	1896	1896	1896	1896	1896	1887	1861	1818	1761	1701	1643	1585	1527	1481	1478];
        Engine.PowerNomHP = 400;

    case 'MAN D2676LF03 Euro 2'
        
        Engine.EngineModelDescription = 'MAN D2676 LF03';
        Engine.changeT = 1800; %RPM where power is max, change down RPM
        Engine.Torquerpm = [1000	1100	1200	1300	1400	1500	1600	1700	1800	1900];
        Engine.TorqueNm =  [2300	2300	2300	2295	2256	2177	2072	1954	1849	1738];
        Engine.PowerNomHP = 480;
  
    case 'MAN D2676 LE424 520 PS'
        
        Engine.EngineModelDescription = 'MAN D2676 520 PS';
        Engine.changeT = 1800; %RPM where power is max, change down RPM
        Engine.Torquerpm = [600	700	800	900	1000	1100	1200	1600	1800];
        Engine.TorqueNm =  [1010	1112	1270	1395	1657	2051	2277	2277	2029];
        Engine.PowerNomHP = 520;
        
    case 'MAN D2676 LF06'
        
        Engine.EngineModelDescription = 'MAN D2676 LF06';
        Engine.changeT = 1900; %RPM where power is max, change down RPM
        Engine.Torquerpm = [1054	1102	1201	1300	1365	1401	1434	1900];
        Engine.TorqueNm =  [2501	2501	2501	2500	2500	2492	2472	1996];
        Engine.PowerNomHP = 530;
 
    case 'Mercedes-Benz OM 460 (294 kW)'
        
        Engine.EngineModelDescription = 'Mercedes-Benz OM 460 Euro III (294 kW)';
        Engine.changeT = 1700; %RPM where power is max, change down RPM
        Engine.Torquerpm = [995     1058	1113	1209	1250	1305	1401	1456	1511	1552	1632	1701	1798];
        Engine.TorqueNm =  [1903	1918	1907	1893	1891	1898	1886	1864	1834	1794	1708	1630	1527];
        Engine.PowerNomHP = 400;
        
    case 'Mercedes-Benz OM 460 (330 kW)'
        
        Engine.EngineModelDescription = 'Mercedes-Benz OM 460 Euro III (330 kW)';
        Engine.changeT = 1800; %RPM where power is max, change down RPM
        Engine.Torquerpm = [998     1099	1199	1298	1397	1497	1596	1698	1798	1898];
        Engine.TorqueNm =  [2206	2226	2211	2216	2201	2141	2025	1884	1784	1704];
        Engine.PowerNomHP = 450;       
        
    case 'Mercedes-Benz OM 471 (330 kW)'
        
        Engine.EngineModelDescription = 'Mercedes-Benz OM 471 Euro IV (330 kW)';
        Engine.changeT = 1800; %RPM where power is max, change down RPM
        Engine.Torquerpm = [997     1099	1198	1299	1398	1498	1599	1698	1798	1899];
        Engine.TorqueNm =  [2213	2234	2207	2202	2181	2123	2008	1882	1766	1593];
        Engine.PowerNomHP = 450;
        
    case 'Mercedes-Benz OM 473 (380 kW)'
        
        Engine.EngineModelDescription = 'Mercedes-Benz OM 473 Euro III (380 kW)';
        Engine.changeT = 1800; %RPM where power is max, change down RPM
        Engine.Torquerpm = [1012	1049	1085	1122	1159	1196	1233	1270	1306	1343	1380	1417	1454	1490	1527	1564	1601	1638	1675	1711	1748	1785	1822	1859	1896	1932	1956];
        Engine.TorqueNm =  [2589	2590	2590	2586	2577	2575	2575	2575	2567	2553	2534	2501	2461	2414	2358	2300	2237	2184	2130	2087	2046	2013	1978	1935	1860	1745	1627];
        Engine.PowerNomHP = 520;
        
    case 'Mercedes-Benz OM 473 (425 kW)'
        
        Engine.EngineModelDescription = 'Mercedes-Benz OM 473 Euro III (425 kW)';
        Engine.changeT = 1800; %RPM where power is max, change down RPM
        Engine.Torquerpm = [1002	1101	1200	1300	1401	1502	1601	1701	1801	1900];
        Engine.TorqueNm =  [2793	2804	2783	2784	2768	2686	2546	2375	2209	1950];
        Engine.PowerNomHP = 580;
        
    case 'Mercedes-Benz OM 501 LA (331 kW)'
        
        Engine.EngineModelDescription = 'Mercedes-Benz OM 501 LA (331 kW)';
        Engine.changeT = 1800; %RPM where power is max, change down RPM
        Engine.Torquerpm = [1007	1054	1091	1127	1163	1200	1236	1272	1308	1345	1383	1418	1455	1492	1530	1564	1654	1693	1750	1876	1952	1997];
        Engine.TorqueNm =  [2059	2163	2205	2205	2194	2189	2183	2179	2175	2157	2144	2134	2117	2096	2070	2040	1948	1907	1823	1657	1507	1404];
        Engine.PowerNomHP = 450;
        
    case 'Mercedes-Benz OM 502 LA (390 kW)'
        
        Engine.EngineModelDescription = 'Mercedes-Benz OM 502 LA (390 kW)';
        Engine.changeT = 1800; %RPM where power is max, change down RPM
        Engine.Torquerpm = [1000	1100	1200	1300	1400	1500	1600	1700	1800	1900	2000];
        Engine.TorqueNm =  [2502	2502	2475	2440	2405	2362	2301	2196	2082	1898	1645];
        Engine.PowerNomHP = 530;
        
    case 'Scania DC13-107-410'
        
        Engine.EngineModelDescription = 'Scania DC13-107-410 Euro 3';
        Engine.changeT = 1900; %RPM where power is max, change down RPM
        Engine.Torquerpm = [1000	1200	1350	1400	1600	1800	1900];
        Engine.TorqueNm =  [2000	2000	2000	1938	1739	1571	1513];
        Engine.PowerNomHP = 410;

    case 'Scania DC13-189-420'
        
        Engine.EngineModelDescription = 'Scania DC13-189-420 Euro 3';
        Engine.changeT = 1800; %RPM where power is max, change down RPM
        Engine.Torquerpm = [900	1260	1391	1543	1678	1800];
        Engine.TorqueNm =  [2300	2300	2095	1898	1752	1639];
        Engine.PowerNomHP = 420;

    case 'Scania DC13-106-460'
        
        Engine.EngineModelDescription = 'Scania DC13-106-460-Euro3 engine';
        Engine.changeT = 1897; %RPM where power is max, change down RPM
        Engine.Torquerpm = [1005	1356	1401	1465	1558	1603	1662	1771	1802	1897];
        Engine.TorqueNm =  [2251	2251	2177	2100	2000	1951	1899	1800	1772	1700];
        Engine.PowerNomHP = 460;

        
    case 'Scania DC13 190 460'
        
        Engine.EngineModelDescription = 'Scania DC13 190 460 hp engine';
        Engine.changeT = 1800; %RPM where power is max, change down RPM
        Engine.Torquerpm = [900	1289	1400	1550	1675	1800];
        Engine.TorqueNm =  [2400	2400	2234	2044	1912	1795];
        Engine.PowerNomHP = 460;
        
    case 'Scania DC13 146 L01'
        
        Engine.EngineModelDescription = 'Scania DC13 146 L01 500 hp engine';
        Engine.changeT = 1800; %RPM where power is max, change down RPM
        Engine.Torquerpm = [900	1320	1428	1511	1619	1800];
        Engine.TorqueNm =  [2650	2650	2459	2324	2171	1954];
        Engine.PowerNomHP = 500;

    case 'Scania DC13-146-500'
        
        Engine.EngineModelDescription = 'Scania DC13 146 L01 500 hp engine';
        Engine.changeT = 1800; %RPM where power is max, change down RPM
        Engine.Torquerpm = [900	1320	1428	1511	1619	1800];
        Engine.TorqueNm =  [2650	2650	2459	2324	2171	1954];
        Engine.PowerNomHP = 500;

     case 'Scania DC13-191-520'
        
        Engine.EngineModelDescription = 'Scania DC13 191 520 hp engine';
        Engine.changeT = 1800; %RPM where power is max, change down RPM
        Engine.Torquerpm = [900	1303	1399	1514	1628	1800];
        Engine.TorqueNm =  [2645	2645	2551	2400	2242	2030];
        Engine.PowerNomHP = 520;

    case 'Scania DC13-184-550'
        
        Engine.EngineModelDescription = 'Scania DC13 184 550 hp engine';
        Engine.changeT = 1800; %RPM where power is max, change down RPM
        Engine.Torquerpm = [900	1350	1462	1590	1683	1800];
        Engine.TorqueNm =  [2800	2800	2592	2402	2279	2140];
        Engine.PowerNomHP = 550;
        
    case 'Scania DC16-111-560'
        
        Engine.EngineModelDescription = 'Scania DC16 111 560 hp engine';
        Engine.changeT = 1900; %RPM where power is max, change down RPM
        Engine.Torquerpm = [1000	1400	1503	1602	1749	1900];
        Engine.TorqueNm =  [2700	2700	2531	2400	2225	2072];
        Engine.PowerNomHP = 560;
        
    case 'Scania DC16-03-580'
        
        Engine.EngineModelDescription = 'Scania DC16-106-460-Euro3 engine';
        Engine.changeT = 1898; %RPM where power is max, change down RPM
        Engine.Torquerpm = [1001	1103	1304	1552	1731	1898];
        Engine.TorqueNm =  [2627	2700	2700	2520	2314	2154];
        Engine.PowerNomHP = 580;

    case 'SHACMAN WP13H560E68A'
        
        Engine.EngineModelDescription = 'Weichai Power WP13H560E68A';
        Engine.changeT = 1600 %RPM where power is max, change down RPM
        Engine.Torquerpm = [900	1300	1600];
        Engine.TorqueNm =  [2585	2585	2460];
        Engine.PowerNomHP = 560;
        
case 'SINOTRUK MC13.54-50'
        
        Engine.EngineModelDescription = 'SINOTRUK MC13.54-50';
        Engine.changeT = 1900; %RPM where power is max, change down RPM
        Engine.Torquerpm = [ 600     800     900    1000    1400    1600    1800    1900];
        Engine.TorqueNm =  [1200    1800    2200    2500    2500    2280    2080    1995];
        Engine.PowerNomHP = 540;
        
    case 'UD GH11E'
        Engine.EngineModelDescription = 'UD GH11E';
        Engine.changeT = 1900; %RPM where power is max, change down RPM
        Engine.Torquerpm = [900	1400	1800	1900];
        Engine.TorqueNm =  [2240	2240	1835	1739];
        Engine.PowerNomHP = 490;
        
    case 'Volvo D11A330'
        Engine.EngineModelDescription = 'Volvo D11A330';
        Engine.changeT = 1952; %RPM where power is max, change down RPM
        Engine.Torquerpm = [950     1001	1296	1397	1952	2032	2098];
        Engine.TorqueNm =  [1398	1651	1653	1609	1176	941     804];
        Engine.PowerNomHP = 330;
        
    case 'Volvo D13A400'
        % Checked against engine_various_database_dsccat
        Engine.EngineModelDescription = 'Volvo D13A400';
        Engine.changeT = 1773; %RPM where power is max, change down RPM
        Engine.Torquerpm = [600     698     769     836     903     950     998     1045    1399    1466    1553    1663    1773    1844    1891    1943    1986    2041    2088];
        Engine.TorqueNm =  [1268    1402    1504    1601    1708    1805    1901    2003    2003    1901    1805    1703    1601    1499    1402    1300    1199    1097    1000];
        Engine.PowerNomHP = 400;
        
    case 'Volvo D13A440'
        
        Engine.EngineModelDescription = 'Volvo D13A440';
        Engine.changeT = 1760; % RPM where torque*rpm (power) is max
        Engine.Torquerpm = [600	804	906	985	1050	1400	1493	1600	1760	1807	1917	2093];
        Engine.TorqueNm =  [1271	1589	1819	2073	2201	2204	2064	1929	1754	1700	1473	1084];
        Engine.PowerNomHP = 440;
        
    case 'Volvo D13A480'
        
        Engine.EngineModelDescription = 'Volvo D13A480';
        Engine.changeT = 1800; %RPM where power is max, change down RPM
        Engine.Torquerpm = [617	656	708	813	885	946	976	999	1001	1042	1097	1137	1291	1394	1488	1584	1806	1853	1897	1933	1956	1978	2030	2103];
        Engine.TorqueNm =  [1325	1377	1448	1593	1748	1997	2186	2326	2376	2410	2421	2418	2419	2416	2265	2127	1866	1759	1650	1558	1502	1449	1323	1165];
        Engine.PowerNomHP = 480;
        
    case 'Volvo D13A520'
        
        Engine.EngineModelDescription = 'Volvo D13A520';
        Engine.changeT = 1800; % RPM where torque*rpm (power) is max
        Engine.Torquerpm = [600   807  990 1047 1449 1813 2100];
        Engine.TorqueNm =  [1263 1693 2387 2503 2507 2027 1260];
        Engine.PowerNomHP = 520;
        
    case 'Volvo D16C610'
        
        Engine.EngineModelDescription = 'Volvo D16C610';
        Engine.changeT = 1700; % RPM where torque*rpm (power) is max
        Engine.Torquerpm = [878     949     1003	1395	1511	1622	1700	1797	1858];
        Engine.TorqueNm =  [2428	2753	2804	2809	2742	2636	2540	2151	1670];
        Engine.PowerNomHP = 610;
        
    case 'VW 17.250'
        
        Engine.EngineModelDescription = 'VW 17.250';
        Engine.changeT = 2500; %Torque where torque*rpm is max
        Engine.Torquerpm = [900 1100 1300 1500 1600 1700 1900 2100 2300 2500];
        Engine.TorqueNm =  [624 835 900 900 900 888 846 786 739 725];
        Engine.PowerNomHP = 250;
        
    case 'NTC B-Double 6x4 Engine'
        
        Engine.EngineModelDescription = 'NTC B-Double 6x4 Engine';
        Engine.changeT = 2000; %RPM where power is max, change down RPM
        Engine.Torquerpm = [600	    800	    1000	1200	1400	1600	1800	2000];
        Engine.TorqueNm =  [1273.2	1611.4	2148.6	2212.3	2203.2	1933.7	1718.9	1265.3];
        
    otherwise
        error('ENGINE DOES NOT EXIST, PLEASE ADD THE ENGINE TO GetEngineData.m');
end

%% Gearbox
Engine.engageTNm = 2000; % Large value which will be corrected below.
switch Combination.gearboxModel
    case 'DAF ZF ASTRONIC 12 AS 2331 OD'
        
        Engine.GearboxModelDescription =  'DAF ZF ASTRONIC 12 AS 2331 OD';
        
        Engine.gearsLabels = {'1'   '2'     '3'     '4'    '5'      '6'     '7'     '8'     '9'     '10'    '11'    '12'};
        Engine.gears =     [12.33   9.59    7.44    5.78    4.57    3.55    2.70    2.10    1.63    1.27    1.00    0.78];
        Engine.eff_gear =  [0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.98    0.96];
        Engine.eff_diff = 0.96; %differential efficiency
        Engine.dif = 3.71; %differential ratio
        
        Engine.gearsStartLabels = Engine.gearsLabels;
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = Engine.eff_diff; %Diff ratio for startability - used if dual differential
        Engine.difStart = Engine.dif; %Diff ratio for startability - used if dual differential
        Engine.gearshiftregime = 1; % 1 for every gear 2 for every second

    case 'DAF ZF Overdrive TraXon 12TX2621TD'
        
        Engine.GearboxModelDescription =  'DAF ZF Overdrive TraXon 12TX2621TD';
        
        Engine.gearsLabels = {'1'   '2'     '3'     '4'    '5'      '6'     '7'     '8'     '9'     '10'    '11'    '12'};
        Engine.gears =     [16.688 12.924 9.926 7.688 5.895 4.565 3.655 2.831 2.174 1.684 1.291 1];
        Engine.eff_gear =  [0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.98];
        Engine.eff_diff = 0.96; %differential efficiency
        Engine.dif = 2.83; %differential ratio
        
        Engine.gearsStartLabels = Engine.gearsLabels;
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = Engine.eff_diff; %Diff ratio for startability - used if dual differential
        Engine.difStart = Engine.dif; %Diff ratio for startability - used if dual differential
        Engine.gearshiftregime = 1; % 1 for every gear 2 for every second

    case 'Hino ZF16 TX2440TO'
        
        Engine.GearboxModelDescription =  'Hino ZF16 TX2440TO';
        
        Engine.gearsLabels = {'1L'  '1H'    '2L'    '2H'    '3L'    '3H'    '4L'    '4H'    '5L'    '5H'    '6L'    '6H'    '7L'    '7H'    '8L'    '8H'};
        Engine.gears =     [14.682  12.048  9.919   8.139   6.780   5.564   4.565   3.746   3.216   2.639   2.173   1.783   1.485   1.219   1.000   0.821];
        Engine.eff_gear =  [0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96    0.98    0.96];
        Engine.eff_diff = 0.96; %differential efficiency
        Engine.dif = 3.900; %differential ratio
        
        Engine.gearsStartLabels = Engine.gearsLabels;
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = Engine.eff_diff; %Diff ratio for startability - used if dual differential
        Engine.difStart = Engine.dif; %Diff ratio for startability - used if dual differential
        Engine.gearshiftregime = 2; % 1 for every gear 2 for every second. n.b. Hino has 16 gears which is too many for low power
    
    case 'Hino MX06'
        
        Engine.GearboxModelDescription =  'Hino MX06';
        
        Engine.gearsLabels = {'1'   '2'     '3'     '4'    '5'      '6'};
        Engine.gears =     [6.515   4.173   2.672   1.711  1.00    0.702];
        Engine.eff_gear =  [0.96    0.96    0.96    0.96    0.98    0.96 ];
        Engine.eff_diff = 0.96; %differential efficiency
        Engine.dif = 5.857; %differential ratio
        
        Engine.gearsStartLabels = Engine.gearsLabels;
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = Engine.eff_diff; %Diff ratio for startability - used if dual differential
        Engine.difStart = Engine.dif; %Diff ratio for startability - used if dual differential
        Engine.gearshiftregime = 1; % 1 for every gear 2 for every second

        
     case 'MAN TipMatic 12 26 OD'
        
        Engine.GearboxModelDescription =  'MAN TipMatic 12 26 OD';
        
        Engine.gearsLabels = {'1'   '2'     '3'     '4'    '5'      '6'     '7'     '8'     '9'     '10'    '11'    '12'};
        Engine.gears =     [12.92 9.98 7.67 5.94 4.57 3.53 2.83 2.19 1.68 1.30 1.00 0.77];
        Engine.eff_gear =  [0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.98    0.96];
        Engine.eff_diff = 0.96; %differential efficiency
        Engine.dif = 3.36; %differential ratio
        
        Engine.gearsStartLabels = Engine.gearsLabels;
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = Engine.eff_diff; %Diff ratio for startability - used if dual differential
        Engine.difStart = Engine.dif; %Diff ratio for startability - used if dual differential
        Engine.gearshiftregime = 1; % 1 for every gear 2 for every second
        
     case 'MAN TipMatic 12 28 OD'
        
        Engine.GearboxModelDescription =  'MAN TipMatic 12 28 OD';
        
        Engine.gearsLabels = {'1'   '2'     '3'     '4'    '5'      '6'     '7'     '8'     '9'     '10'    '11'    '12'};
        Engine.gears =     [12.92 9.98 7.67 5.94 4.57 3.53 2.83 2.19 1.68 1.30 1.00 0.77];
        Engine.eff_gear =  [0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.98    0.96];
        Engine.eff_diff = 0.96; %differential efficiency
        Engine.dif = 4.11; %differential ratio
        
        Engine.gearsStartLabels = Engine.gearsLabels;
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = Engine.eff_diff; %Diff ratio for startability - used if dual differential
        Engine.difStart = Engine.dif; %Diff ratio for startability - used if dual differential
        Engine.gearshiftregime = 1; % 1 for every gear 2 for every second
    
    case 'MAN ZF ASTRONIC 12 AS 2331 OD'
        
        Engine.GearboxModelDescription =  'MAN ZF ASTRONIC 12 AS 2331 OD';
        
        Engine.gearsLabels = {'1'   '2'     '3'     '4'    '5'      '6'     '7'     '8'     '9'     '10'    '11'    '12'};
        Engine.gears =     [12.33   9.59    7.44    5.78    4.57    3.55    2.70    2.10    1.63    1.27    1.00    0.78];
        Engine.eff_gear =  [0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.98    0.96];
        Engine.eff_diff = 0.96; %differential efficiency
        Engine.dif = 4.11; %differential ratio
        
        Engine.gearsStartLabels = Engine.gearsLabels;
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = Engine.eff_diff; %Diff ratio for startability - used if dual differential
        Engine.difStart = Engine.dif; %Diff ratio for startability - used if dual differential
        Engine.gearshiftregime = 1; % 1 for every gear 2 for every second
        
    case 'MAN ZF 12AS 2530 SG'
        
        Engine.GearboxModelDescription =  'MAN ZF 12AS 2530 SG';
        
        Engine.gearsLabels = {'1'   '2'     '3'     '4'     '5'     '6'     '7'     '8'     '9'     '10'    '11'    '12'};
        Engine.gears =     [12.33	9.59	7.43	5.78	4.56	3.55	2.7	    2.1	    1.63	1.26	1	    0.78];
        Engine.eff_gear =  [0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.98	0.96];
        Engine.eff_diff = 0.96; %differential efficiency
        Engine.dif = 3.36; %differential ratio
        
        Engine.gearsStartLabels = Engine.gearsLabels;
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = Engine.eff_diff; %Diff ratio for startability - used if dual differential
        Engine.difStart = Engine.dif; %Diff ratio for startability - used if dual differential
        Engine.gearshiftregime = 1; % 1 for every gear 2 for every second
        
    case 'Mercedes Powershift G281-12'
        
        Engine.GearboxModelDescription =  'Mercedes Powershift G281-12';
        
        Engine.gearsLabels = {'1'   '2'     '3'     '4'     '5'     '6'     '7'     '8'     '9'     '10'    '11'    '12'};
        Engine.gears =     [14.93	 11.64	9.02	7.04	 5.64	 4.4	  3.4	  2.65	 2.05	 1.6	 1.28	 1];
        Engine.eff_gear =  [0.96	 0.96	  0.96	0.96	 0.96	 0.96	  0.96	0.96	 0.96	 0.96	 0.96	 0.98];
        Engine.eff_diff = 0.96; %differential efficiency
        Engine.dif = 3.077; %differential ratio
        
        Engine.gearsStartLabels = Engine.gearsLabels;
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = Engine.eff_diff; %Diff ratio for startability - used if dual differential
        Engine.difStart = Engine.dif; %Diff ratio for startability - used if dual differential
        Engine.gearshiftregime = 1; % 1 for every gear 2 for every second
        
    case 'Mercedes G330-12'
        
        Engine.GearboxModelDescription =  'Mercedes G330-12';
        
        Engine.gearsLabels = {'1'   '2'     '3'     '4'     '5'     '6'     '7'     '8'     '9'     '10'    '11'    '12'};
        Engine.gears =     [11.763	9.02	7.035	5.452	4.4	3.41	2.645	2.05	1.599	1.239	1	0.775];
        Engine.eff_gear =  [0.96	 0.96	  0.96	0.96	 0.96	 0.96	  0.96	0.96	 0.96	 0.96	 0.98	 0.96];
        Engine.eff_diff = 0.96; %differential efficiency
        Engine.dif = 4.333; %differential ratio
        
        Engine.gearsStartLabels = Engine.gearsLabels;
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = Engine.eff_diff; %Diff ratio for startability - used if dual differential
        Engine.difStart = Engine.dif; %Diff ratio for startability - used if dual differential
        Engine.gearshiftregime = 1; % 1 for every gear 2 for every second
        
    case 'Scania G33CH'
        Engine.GearboxModelDescription =  'Scania G33CH';
        Engine.gearsLabels = {'CL'  'CH'    '1'    '2'    '3'    '4'    '5'    '6'    '7'    '8'    '9'    '10'    '11'    '12'};
        Engine.gears =     [20.81	16.16	12.57	9.71	7.56	5.87	4.54	3.53	2.76	2.15	1.66	1.29	1		0.78];
        Engine.eff_gear =  [0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.98	0.96];
        Engine.eff_diff = 0.96; %differential ratio
        Engine.dif = 3.07; %differential ratio
        
        Engine.gearsStartLabels = Engine.gearsLabels;
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = Engine.eff_diff; %Diff ratio for startability - used if dual differential
        Engine.difStart = Engine.dif; %Diff ratio for startability - used if dual differential
        Engine.gearshiftregime = 1; % 1 for every gear 2 for every second
        Engine.engageTNm = 1600; % Anton email about the propshaft
        
    case 'Scania GRS905'
        Engine.GearboxModelDescription =  'Scania GRS905';
        Engine.gearsLabels = {'CL'  'CH'    '1L'    '1H'    '2L'    '2H'    '3L'    '3H'    '4L'    '4H'    '5L'    '5H'    '6L'    '6H'};
        Engine.gears =     [16.406	13.281	11.32	9.164	7.194	5.823	4.632	3.75	3.016	2.444	1.918	1.553	1.235	1];
        Engine.eff_gear =  [0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.98];
        Engine.eff_diff = 0.96; %differential ratio
        Engine.dif = 3.07; %differential ratio
        
        Engine.gearsStartLabels = Engine.gearsLabels;
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = Engine.eff_diff; %Diff ratio for startability - used if dual differential
        Engine.difStart = Engine.dif; %Diff ratio for startability - used if dual differential
        Engine.gearshiftregime = 1; % 1 for every gear 2 for every second
        Engine.engageTNm = 1600; % Anton email about the propshaft
        
    case 'Scania GRSO 905/925' %previously Scania GRSO925S
        Engine.GearboxModelDescription =  'Scania GRSO 905/925';
        Engine.gearsLabels = {'CL'  'CH'    '1L'    '1H'    '2L'    '2H'    '3L'    '3H'    '4L'    '4H'    '5L'    '5H'    '6L'    '6H'};
        Engine.gears =     [13.281	10.625	9.164	7.331	5.823	4.659	3.750	3.000	2.440	1.955	1.553	1.242	1.000	0.800];
        Engine.eff_gear =  [0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.98	0.96];
        Engine.eff_diff = 0.96; %differential ratio
        Engine.dif = 4.05; %differential ratio
        
        Engine.gearsStartLabels = Engine.gearsLabels;
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = Engine.eff_diff; %Diff ratio for startability - used if dual differential
        Engine.difStart = Engine.dif; %Diff ratio for startability - used if dual differential
        Engine.gearshiftregime = 1; % 1 for every gear 2 for every second
        Engine.engageTNm = 1600; % Anton email about the propshaft

    case 'Scania GRSO 905/925' %previously Scania GRSO925S
        Engine.GearboxModelDescription =  'Scania GRSO 905/925';
        Engine.gearsLabels = {'CL'  'CH'    '1L'    '1H'    '2L'    '2H'    '3L'    '3H'    '4L'    '4H'    '5L'    '5H'    '6L'    '6H'};
        Engine.gears =     [13.281	10.625	9.164	7.331	5.823	4.659	3.750	3.000	2.440	1.955	1.553	1.242	1.000	0.800];
        Engine.eff_gear =  [0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.98	0.96];
        Engine.eff_diff = 0.96; %differential ratio
        Engine.dif = 4.05; %differential ratio
        
        Engine.gearsStartLabels = Engine.gearsLabels;
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = Engine.eff_diff; %Diff ratio for startability - used if dual differential
        Engine.difStart = Engine.dif; %Diff ratio for startability - used if dual differential
        Engine.gearshiftregime = 1; % 1 for every gear 2 for every second
        Engine.engageTNm = 1600; % Anton email about the propshaft

    case 'SHACMAN F16JZ26'
        Engine.GearboxModelDescription =  'FAST F16JZ26';
        Engine.gearsLabels = {'1' '2' '3' '4' '5' '6' '7' '8' '9' '10' '11' '12' '13' '14' '15' '16'};
        Engine.gears = [17.09 14.13 11.82 9.77 8.09 6.69 5.47 4.52 3.78  3.13  2.61 2.16 1.79 1.48 1.21 1.00];
        Engine.eff_gear = [0.96 0.96 0.96 0.96 0.96 0.96 0.96 0.96 0.96 0.96 0.96 0.96 0.96 0.96 0.96 0.98];
        Engine.eff_diff = 0.96; %differential efficiency
        Engine.dif = 2.846;

        Engine.gearsStartLabels = Engine.gearsLabels;
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = Engine.eff_diff; %Diff ratio for startability - used if dual differential
        Engine.difStart = Engine.dif; %Diff ratio for startability - used if dual differential
        Engine.gearshiftregime = 2; % 1 for every gear 2 for every second
        Engine.engageTNm = 1600; % Anton has used this value otherwise it would be 1993 for 560 hp

      case 'ZF 12TX2621 TD'
        Engine.GearboxModelDescription =  'ZF 12TX2621 TD';
        Engine.gearsLabels = {'1'    '2'    '3'    '4'      '5'    '6'      '7'    '8'      '9'    '10'    '11'    '12'};
        Engine.gears =     [16.69   12.92	9.93	7.69	5.90	4.57	3.66	2.83	2.17	1.68	1.29		1   ];
        Engine.eff_gear =  [0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.98	0.96];
        Engine.eff_diff = 0.96; %differential ratio
        Engine.dif = 2.85; %differential ratio
        
        Engine.gearsStartLabels = Engine.gearsLabels;
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = Engine.eff_diff; %Diff ratio for startability - used if dual differential
        Engine.difStart = Engine.dif; %Diff ratio for startability - used if dual differential
        Engine.gearshiftregime = 1; % 1 for every gear 2 for every second
        
    case 'UD AT612F'
        % Checked against gearbox_various_database_dsccat
        Engine.GearboxModelDescription =  'UD AT612F';
        Engine.gearsLabels = {'1'   '2'     '3'     '4'     '5'     '6'     '7'     '8'     '9'     '10'    '11'    '12'};
        Engine.gears =     [14.94   11.73   9.04    7.09    5.54    4.35    3.44    2.7     2.08    1.63    1.27    1];
        Engine.eff_gear =  [0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.98];
        Engine.eff_diff = 0.96; %differential efficiency
        Engine.dif = 4.333;

        Engine.gearsStartLabels = Engine.gearsLabels;
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = Engine.eff_diff; %Diff ratio for startability - used if dual differential
        Engine.difStart = Engine.dif; %Diff ratio for startability - used if dual differential
        Engine.gearshiftregime = 1; % 1 for every gear 2 for every second
    
    case 'Volvo AT2612D'
        % Checked against gearbox_various_database_dsccat
        Engine.GearboxModelDescription =  'Volvo AT2612D';
        Engine.gearsLabels = {'1'   '2'     '3'     '4'     '5'     '6'     '7'     '8'     '9'     '10'    '11'    '12'};
        Engine.gears =     [14.94   11.73   9.04    7.09    5.54    4.35    3.44    2.7     2.08    1.63    1.27    1];
        Engine.eff_gear =  [0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.98];
        Engine.eff_diff = 0.96; %differential efficiency
        Engine.dif = 2.85; %differential ratio 2.79 2.83 2.85 3.08 3.09 3.10 and others also available

        Engine.gearsStartLabels = Engine.gearsLabels;
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = Engine.eff_diff; %Diff ratio for startability - used if dual differential
        Engine.difStart = Engine.dif; %Diff ratio for startability - used if dual differential
        Engine.gearshiftregime = 1; % 1 for every gear 2 for every second
        
    case 'Volvo AT2612F'
        % Checked against gearbox_various_database_dsccat
        Engine.GearboxModelDescription =  'Volvo AT2612F';
        Engine.gearsLabels = {'1'   '2'     '3'     '4'     '5'     '6'     '7'     '8'     '9'     '10'    '11'    '12'};
        Engine.gears =     [14.94   11.28   9.04    7.09    5.54    4.35    3.44    2.7     2.08    1.63    1.27    1];
        Engine.eff_gear =  [0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.98];
        Engine.eff_diff = 0.96; %differential efficiency
        Engine.dif = 3.09; %differential ratio 2.79 2.83 2.85 3.08 3.09 3.10
        
        Engine.gearsStartLabels = Engine.gearsLabels;
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = Engine.eff_diff; %Diff ratio for startability - used if dual differential
        Engine.difStart = Engine.dif; %Diff ratio for startability - used if dual differential
        Engine.gearshiftregime = 1; % 1 for every gear 2 for every second
        
    case 'Volvo AT2612F ASO-C'
        
        Engine.GearboxModelDescription =  'Volvo AT2612F ASO-C';     
        Engine.gearsLabels = {'C'  '1'     '2'     '3'     '4'     '5'     '6'     '7'     '8'     '9'     '10'    '11'    '12'};
        Engine.gears =     [19.38  14.94	11.28	9.04	7.09	5.54	4.35	3.44	2.7     2.08	1.63	1.27	1.00]; %Gears for startability - used if crawler gear available
        Engine.eff_gear =  [0.96   0.96   0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.98]; %Gears for startability - used if crawler gear available
        Engine.eff_diff = 0.96; % Diff ratio for startability - used if crawler gear available
        Engine.dif = 3.09; % Diff ratio for startability - used if dual differential ratio is available

        Engine.gearsStartLabels = Engine.gearsLabels;
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = Engine.eff_diff; %Diff ratio for startability - used if dual differential
        Engine.difStart = Engine.dif; %Diff ratio for startability - used if dual differential
        Engine.gearshiftregime = 1; % 1 for every gear 2 for every second
        
    case 'Volvo ATO3112F'
        
        Engine.GearboxModelDescription =  'Volvo ATO3112F';
        
        Engine.gearsLabels = {'1'   '2'     '3'     '4'     '5'     '6'     '7'     '8'     '9'     '10'    '11'    '12'};
        Engine.gears =     [11.73    9.21  7.09     5.57   4.35     3.41    2.70    2.12    1.63    1.28    1.00   0.78];
        Engine.eff_gear =  [0.96   0.96    0.96     0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.98    0.96];
        Engine.eff_diff = 0.96; % standard diff ratio
        Engine.dif = 4.11; % standard diff ratio
        
        Engine.gearsStartLabels = Engine.gearsLabels;
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = Engine.eff_diff; %Diff ratio for startability - used if dual differential
        Engine.difStart = Engine.dif; %Diff ratio for startability - used if dual differential
        Engine.gearshiftregime = 1; % 1 for every gear 2 for every second
        
     case 'Volvo AT2612G ASO-ULC'
        
        Engine.GearboxModelDescription =  'Volvo AT2612G ASO-ULC';
        
        Engine.gearsLabels = {'C1' 'C2'  '1'     '2'     '3'     '4'     '5'     '6'     '7'     '8'     '9'     '10'    '11'    '12'};
        Engine.gears =     [32.04  19.38  14.94	11.28	9.04	7.09	5.54	4.35	3.44	2.7     2.08	1.63	1.27	1.00]; %Gears for startability - used if crawler gear available
        Engine.eff_gear =  [0.96    0.96   0.96   0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.98]; %Gears for startability - used if crawler gear available
        Engine.eff_diff = 0.96; % Diff ratio for startability - used if crawler gear available
        Engine.dif = 3.09; % Diff ratio for startability - used if dual differential ratio is available
        
        Engine.gearsStartLabels = Engine.gearsLabels;
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = Engine.eff_diff; %Diff ratio for startability - used if dual differential
        Engine.difStart = Engine.dif; %Diff ratio for startability - used if dual differential        
        Engine.gearshiftregime = 1; % 1 for every gear 2 for every second
        
     case 'Volvo AT2612G'
        
        Engine.GearboxModelDescription =  'Volvo AT2612G';
        
        Engine.gearsLabels = {'1'     '2'     '3'     '4'     '5'     '6'     '7'     '8'     '9'     '10'    '11'    '12'};
        Engine.gears =     [14.94	11.28	9.04	7.09	5.54	4.35	3.44	2.7     2.08	1.63	1.27	1.00]; %Gears for startability - used if crawler gear available
        Engine.eff_gear =  [0.96   0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.98]; %Gears for startability - used if crawler gear available
        Engine.eff_diff = 0.96; % Diff ratio for startability - used if crawler gear available
        Engine.dif = 3.09; % Diff ratio for startability - used if dual differential ratio is available
        
        Engine.gearsStartLabels = Engine.gearsLabels;
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = Engine.eff_diff; %Diff ratio for startability - used if dual differential
        Engine.difStart = Engine.dif; %Diff ratio for startability - used if dual differential        
        Engine.gearshiftregime = 1; % 1 for every gear 2 for every second
        
    case 'Volvo ATO3112F ASO-C'
        
        Engine.GearboxModelDescription =  'Volvo ATO3112F ASO-C';
        
        Engine.gearsLabels = {'1'   '2'     '3'     '4'     '5'     '6'     '7'     '8'     '9'     '10'    '11'    '12'};
        Engine.gears =     [11.73    9.21  7.09     5.57   4.35     3.41    2.70    2.12    1.63    1.28    1.00   0.78];
        Engine.eff_gear =  [0.96   0.96    0.96     0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.98    0.96];
        Engine.eff_diff = 0.96; % standard diff ratio
        Engine.dif = 4.11; % standard diff ratio
        
        Engine.gearsStartLabels = {'C'  '1'     '2'     '3'     '4'     '5'     '6'     '7'     '8'     '9'     '10'    '11'    '12'};
        Engine.gearsStart =     [17.54  11.73    9.21  7.09     5.57   4.35     3.41    2.70    2.12    1.63    1.28    1.00   0.78]; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart =  [0.96   0.96   0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.98    0.96]; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = 0.96; % Diff ratio for startability - used if crawler gear available
        Engine.difStart = 4.11; % Diff ratio for startability - used if dual differential ratio is available
        Engine.gearshiftregime = 1; % 1 for every gear 2 for every second
        
    case 'VW 17.250 with dual differential - source correct model name'
        
        Engine.gears = [8.03 5.06 3.09 1.96 1.31 1];
        Engine.eff_gear = [0.96 0.96 0.96 0.96 0.96 0.98];
        Engine.eff_diff = 0.96;
        Engine.dif = 5.59; %standard diff ratio
        
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = 0.96; %Diff ratio for startability - used if dual differential
        Engine.difStart = 5.59; %Diff ratio for startability - used if dual differential
        Engine.gearshiftregime = 1; % 1 for every gear 2 for every second
        
    case 'NTC B-Double 6x4 Gearbox'
        
        Engine.GearboxModelDescription =  'NTC B-Double 6x4 Gearbox';
        
        Engine.gearsLabels = {'1'   '2'     '3'     '4'     '5'     '6'     '7'     '8'     '9'     '10'    '11'    '12'};
        Engine.gears =     [14.94	11.73	9.04	7	    5.54	4.35	3.44	2.7	    2.08	1.63	1.27	1];
        Engine.eff_gear =  [0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.96	0.98];
        Engine.eff_diff = 0.96; %differential efficiency
        Engine.dif = 3.07; %differential ratio
        
        Engine.gearsStartLabels = Engine.gearsLabels;
        Engine.gearsStart = Engine.gears; %Gears for startability - used if crawler gear available
        Engine.eff_gearStart = Engine.eff_gear; %Gears for startability - used if crawler gear available
        Engine.eff_diffStart = Engine.eff_diff; %Diff ratio for startability - used if dual differential
        Engine.difStart = Engine.dif; %Diff ratio for startability - used if dual differential
        Engine.gearshiftregime = 1; % 1 for every gear 2 for every second
        
    otherwise
        error('GEARBOX DOES NOT EXIST, PLEASE ADD THE GEARBOX TO getEngineData.m');
end
%%   Calculated engine properties

if isfield(Combination, 'diffRatio')
    Engine.dif = Combination.diffRatio; % Allowing the user to enter a custom diff ratio
    Engine.difStart = Combination.diffRatio; % Allowing the user to enter a custom diff ratio
end

if Engine.Torquerpm(1)<800
    Engine.engageTrpm = 800; %Torque engagement rpm is set to 800 if torque graph goes lower
    Engine.engageTNm = min([max(Engine.TorqueNm)*0.75, interp1(Engine.Torquerpm,Engine.TorqueNm,800,'linear',0), Engine.engageTNm]); %choose the minimum
else
    Engine.engageTrpm = Engine.Torquerpm(1); %Torque engagement rpm is either 800 rpm or min on graph if not go that low
    Engine.engageTNm = min([max(Engine.TorqueNm)*0.75,Engine.TorqueNm(1), Engine.engageTNm]);
end
disp('check');
end