%% Function Description
% 
% This function stores the results of various different baseline vehicles
% 
%% Inputs
% 
% * baselineDescription: must be part of the switch statement, determines which baseline combination results to use
% 
%% Outputs
% 
% * r: baseline results
% 
%% Change Log
% 
% [0.1.0] - 2017-05-15
%
% *Added*
% 
% * First code

function [ r ] = getBaselineResults( baselineDescription )

switch baselineDescription
    case '2-Axle Semi-Trailer'
        r.STA = 20;
        r.GRAa = 20;
        r.GRAb = 98;
        r.ACC = 18.7;
        r.SRTt = 0.3;
        r.SRTtrrcu = 0.3;
        r.YDC = 0.48;
        r.RA = 1.16;
        r.HSTO = 0.3;
        r.TASP = 2.7;
        r.LSSP = 7.2;
        r.TS = 0.07;
        r.FS = 0.6;
        r.MoD = 0.37;
        r.DoM = -0.05;
        r.STFD = 29;
        r.LSSPu = 7.5;
        r.TSu = 0.03;
        r.FSu = 0.6;
        r.MoDu = 0.39;
        r.DoMu = -0.03;
        r.STFDu = 21;
    case 'B-double Car-carrier' % This may be due for an update
        r.STA = '-';
        r.GRAa = '-';
        r.GRAb = '-';
        r.ACC = '-';
        r.SRTt = 0.35;
        r.SRTtrrcu = '-';
        r.YDC = 0.09;
        r.RA = 1.82;
        r.HSTO = 0.7;
        r.TASP = 3.0;
        r.LSSP = 6.7;
        r.TS = 0.66;
        r.FS = 0.7;
        r.MoD = '-';
        r.DoM = '-';
        r.STFD = 34;
        r.LSSPu = '-';
        r.TSu = '-';
        r.FSu = '-';
        r.MoDu = '-';
        r.DoMu = '-';
        r.STFDu = '-';
    case 'Car-carrier Semi-trailer' % C:\Dropbox\PBS\Library\_Baseline Combinations\Semi-trailer Car-carrier_UnipowerFlexiporterMk1_RenaultMidlum 
        r.STA = 13;
        r.GRAa = 24;
        r.GRAb = 90;
        r.ACC = 15.7;
        r.SRTt = 0.44;
        r.SRTtrrcu = 0.44;
        r.YDC = 0.30;
        r.RA = 1.16;
        r.HSTO = 0.4;
        r.TASP = 2.9;
        r.LSSP = 6.7;
        r.TS = 0.2;
        r.FS = 0.4;
        r.MoD = 0.71;
        r.DoM = 0.50;
        r.STFD = 13;
        r.LSSPu = '-';
        r.TSu = '-';
        r.FSu = '-';
        r.MoDu = '-';
        r.DoMu = '-';
        r.STFDu = '-';       
    otherwise
        display('No baseline matching that baseline description is available')
        r.STA = '-';
        r.GRAa = '-';
        r.GRAb = '-';
        r.ACC = '-';
        r.SRTt = '-';
        r.SRTtrrcu = '-';
        r.YDC = '-';
        r.RA = '-';
        r.HSTO = '-';
        r.TASP = '-';
        r.LSSP = '-';
        r.TS = '-';
        r.FS = '-';
        r.MoD = '-';
        r.DoM = '-';
        r.STFD = 34;
        r.LSSPu = '-';
        r.TSu = '-';
        r.FSu = '-';
        r.MoDu = '-';
        r.DoMu = '-';
        r.STFDu = '-';        
end

end

