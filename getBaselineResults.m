%% Function Description
% 
% Describe the function here
% 
%% Inputs
% 
% * variable: description
% 
%% Outputs
% 
% * variable: description
% 
%% Change Log
% 
% [0.1.0] - 2017-01-01
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
end

end

