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
% [1.1.0] - 2021-06-30
% *Added*
% * Comment: standardize to baseline 400 hp Volvo for 49 t and 440 for 56 t
% Use 3.09 diff and Volvo AT2612F
%
% [0.1.0] - 2017-05-15
% *Added*
% * First code

function [ r ] = getBaselineResults( baselineDescription )

switch baselineDescription
    case 'MAN HB4' %E:\PBS\Projects\P20221203_MAN-SA_MAN-HB3_Buscor\Baseline
        r.STA = 30;
        r.GRAa = 30;
        r.GRAb = 120;
        r.ACC = 13.96;
        r.SRTt = 0.53;
        r.SRTtrrcu = 0.53;
        r.YDC = 1;
        r.RA = 0.91;
        r.HSTO = 0.3;
        r.TASP = 2.75;
        r.LSSP = 5.2;
        r.TS = 0.35;
        r.FS = 1.3;
        r.STFD = 10;
        r.LSSPu = 5.2;
        r.TSu = 0.35;
        r.FSu = 1.3;
        r.STFDu = 9;
        
    case 'Afrit timber truck' %20200228-CSIR-PBS Assessment-Afrit 5 Axle Full Trailer with MB Arocs 3352-45 6x4-Rev1-st20200228
        r.STA = 17.0;
        r.GRAa = 26;
        r.GRAb = 94.0;
        r.ACC = 17.7;
        r.SRTt = 0.33;
        r.SRTtrrcu = 0.33;
        r.YDC = 0.25;
        r.RA = 2.14;
        r.HSTO = 0.9;
        r.TASP = 2.9;
        r.LSSP = 6.2;
        r.TS = 0.08;
        r.FS = 0.5;
        %r.MoD = 0.29; %Rigid not semi-trailer but results were given by CSIR
        %r.DoM = '-';
        r.STFD = 33;
        r.LSSPu = 6.2;
        r.TSu = 0.07;
        r.FSu = 0.5;
        %r.MoDu = 0.28; %Rigid not semi-trailer but results were given by CSIR
        %r.DoMu = '-';
        r.STFDu = 33;

    case 'Afrit timber truck' %20200228-CSIR-PBS Assessment-Afrit 5 Axle Full Trailer with MB Arocs 3352-45 6x4-Rev1-st20200228
        r.STA = 17.0;
        r.GRAa = 26;
        r.GRAb = 94.0;
        r.ACC = 17.7;
        r.SRTt = 0.33;
        r.SRTtrrcu = 0.33;
        r.YDC = 0.25;
        r.RA = 2.14;
        r.HSTO = 0.9;
        r.TASP = 2.9;
        r.LSSP = 6.2;
        r.TS = 0.08;
        r.FS = 0.5;
        %r.MoD = 0.29; %Rigid not semi-trailer but results were given by CSIR
        %r.DoM = '-';
        r.STFD = 33;
        r.LSSPu = 6.2;
        r.TSu = 0.07;
        r.FSu = 0.5;
        %r.MoDu = 0.28; %Rigid not semi-trailer but results were given by CSIR
        %r.DoMu = '-';
        r.STFDu = 33;

    case 'AfritBDoubleSkeletal56tonne' % E:\PBS\Projects\B2026001_Afrit_7A-B-Double_Skeletal_Volvo_FH_440_High-Cube
        r.STA = 25;
        r.GRAa = 25;
        r.GRAb = 91;
        r.ACC = 19.9;
        r.SRTt = 0.29;
        r.SRTtrrcu = 0.29;
        r.YDC = 0.3;
        r.RA = 1.27;
        r.HSTO = 0.6;
        r.TASP = 2.8;
        r.LSSP = 7.2;
        r.TS = 0.08;
        r.FS = 0.35;
        r.MoD = 0.46;
        r.DoM = 0.14;
        r.STFD = 30;
        r.LSSPu = 7.2;
        r.TSu = 0.07;
        r.FSu = 0.35;
        r.MoDu = 0.44;
        r.DoMu = 0.16;
        r.STFDu = 19;
        
    case 'AfritBDoubleTautliner56tonne' % E:\PBS\Projects\B2026002_Afrit_7A-B-Double_Tautliner_Volvo_FH_440
        r.STA = 25;
        r.GRAa = 25;
        r.GRAb = 91;
        r.ACC = 19.9;
        r.SRTt = 0.29;
        r.SRTtrrcu = 0.29;
        r.YDC = 0.3;
        r.RA = 1.21;
        r.HSTO = 0.5;
        r.TASP = 2.75;
        r.LSSP = 7.6;
        r.TS = 0.02;
        r.FS = 0.35;
        r.MoD = 0.5;
        r.DoM = 0.19;
        r.STFD = 29;
        r.LSSPu = 7.6;
        r.TSu = 0.02;
        r.FSu = 0.35;
        r.MoDu = 0.48;
        r.DoMu = 0.21;
        r.STFDu = 20;

    case '49 tonne semi fuel tanker' % E:\PBS\Library\Baseline Combinations\49 tonne GRW semi tanker
        % Below values are old
        r.STA = 30;
        r.GRAa = 30;
        r.GRAb = 95;
        r.ACC = 17.8;
        r.SRTt = 0.28;
        r.SRTtrrcu = 0.28;
        r.YDC = 0.36;
        r.RA = 0.93;
        r.HSTO = 0.4;
        r.TASP = 2.65;
        r.LSSP = 7.0;
        r.TS = 0.03;
        r.FS = 0.3;
        r.MoD = 0.09;
        r.DoM = -0.28;
        r.STFD = 31;
        r.LSSPu = 7.0;
        r.TSu = 0.03;
        r.FSu = 0.3;
        r.MoDu = 0.08;
        r.DoMu = -0.25;
        r.STFDu = 19;
        
    case '49 tonne semi fuel tanker (2021 GRW)' % E:\PBS\Library\Baseline Combinations\49 tonne semi fuel tanker (2021 GRW)
        r.STA = 30; % DON'T USE AS BASELINE USES DUALS
        r.GRAa = 30;
        r.GRAb = 104;
        r.ACC = 16.5;
        r.SRTt = 0.32;
        r.SRTtrrcu = 0.32;
        r.YDC = 0.46;
        r.RA = 1.02;
        r.HSTO = 0.4;
        r.TASP = 2.65;
        r.LSSP = 7.0;
        r.TS = 0.05;
        r.FS = 0.35;
        r.MoD = 0.23;
        r.DoM = -0.14;
        r.STFD = 38;
        r.LSSPu = 7.0;
        r.TSu = 0.05;
        r.FSu = 0.35;
        r.MoDu = 0.22;
        r.DoMu = -0.11;
        r.STFDu = 17;
        
    case '49 tonne semi LPG tanker (2021 Tank Clinic)' % E:\PBS\Library\Baseline Combinations\49 tonne semi LPG tanker (2021 Tank Clinic)
        r.STA = 25;
        r.GRAa = 30;
        r.GRAb = 88;
        r.ACC = 18;
        r.SRTt = 0.26;
        r.SRTtrrcu = 0.26;
        r.YDC = 0.38;
        r.RA = 1.02;
        r.HSTO = 0.5;
        r.TASP = 2.70;
        r.LSSP = 7.0;
        r.TS = 0.04;
        r.FS = 0.40;
        r.MoD = 0.52;
        r.DoM = 0.08;
        r.STFD = 24;
        r.LSSPu = 7.0;
        r.TSu = 0.04;
        r.FSu = 0.40;
        r.MoDu = 0.42;
        r.DoMu = 0.11;
        r.STFDu = 18;
        
    case '49 tonne semi tanker (2021 CA Muller)' % E:\PBS\Library\Baseline Combinations\49 tonne semi tanker (2021 CA Muller)
        r.STA = 25;
        r.GRAa = 30;
        r.GRAb = 86;
        r.ACC = 18.0;
        r.SRTt = 0.32;
        r.SRTtrrcu = 0.32;
        r.YDC = 0.43;
        r.RA = 1.03;
        r.HSTO = 0.5;
        r.TASP = 2.75;
        r.LSSP = 7.0;
        r.TS = 0.03;
        r.FS = 0.35;
        r.MoD = 0.07;
        r.DoM = -0.28;
        r.STFD = 26;
        r.LSSPu = 7.0;
        r.TSu = 0.03;
        r.FSu = 0.35;
        r.MoDu = 0.07;
        r.DoMu = -0.24;
        r.STFDu = 17;
        
    case '38 tonne Hendred semi LMT liquid metal transporter' % E:\PBS\Library\Baseline Combinations\38 tonne Hendred semi LMT liquid metal transporter
        r.STA = 22;
        r.GRAa = 30;
        r.GRAb = 86;
        r.ACC = 17.8;
        r.SRTt = 0.45;
        r.SRTtrrcu = 0.45;
        r.YDC = .43;
        r.RA = 1.32;
        r.HSTO = 0.4;
        r.TASP = 3.1;
        r.LSSP = 6.7;
        r.TS = 0.01;
        r.FS = 0.4;
        r.MoD = 0.2;
        r.DoM = -0.21;
        r.STFD = 27;
        r.LSSPu = 6.7;
        r.TSu = 0.01;
        r.FSu = 0.4;
        r.MoDu = 0.2;
        r.DoMu = -0.2;
        r.STFDu = 24;
        
    case 'Afrit B-double side tipper' %E:\PBS\Projects\P2020026_Unitrans_11A-A-Double_Afrit-Sidetipper-57m3_Volvo-FH64T3HA520\Baseline
        r.STA = 23;
        r.GRAa = 29;
        r.GRAb = 88;
        r.ACC = 18.1;
        r.SRTt = 0.29;
        r.SRTtrrcu = 0.29;
        r.YDC = 0.30;
        r.RA = 1.07;
        r.HSTO = 0.6;
        r.TASP = 3.0;
        r.LSSP = 7.7;
        r.TS = 0.02;
        r.FS = 0.35;
        r.MoD = 0.13;
        r.DoM = -0.08;
        r.STFD = 29;
        r.LSSPu = 7.6;
        r.TSu = 0.01;
        r.FSu = 0.35;
        r.MoDu = 0.12;
        r.DoMu = -0.07;
        r.STFDu = 21;
        
    case 'Afrit B-double tautliner' %E:\PBS\Projects\P2021005_BarloworldTransport_9A-B-Double_Afrit-Tautliner_Mercedes-Benz-Actros-3358LS\Baseline
        r.STA = 18.4;
        r.GRAa = 26.3;
        r.GRAb = 85.8;
        r.ACC = 17.45;
        r.SRTt = 0.28;
        r.SRTtrrcu = 0.28;
        r.YDC = 0.28;
        r.RA = 0.83;
        r.HSTO = 0.6;
        r.TASP = 2.75;
        r.LSSP = 7.8;
        r.TS = 0.01;
        r.FS = 0.35;
        r.MoD = 0.49;
        r.DoM = 0.16;
        r.STFD = 33;
        r.LSSPu = 7.8;
        r.TSu = 0.01;
        r.FSu = 0.35;
        r.MoDu = 0.48;
        r.DoMu = 0.19;
        r.STFDu = 19;
        
    case 'Afrit B-double side tipper (CSIR)' %Afrit previously called B-double side-tipper done by CSIR
        r.STA = 15;
        r.GRAa = 21;
        r.GRAb = 95;
        r.ACC = 17.6;
        r.SRTt = 0.38;
        r.SRTtrrcu = 0.38;
        r.YDC = 0.29;
        r.RA = 0.90;
        r.HSTO = 0.6;
        r.TASP = 2.9;
        r.LSSP = 7.6;
        r.TS = 0.02;
        r.FS = 0.4;
        r.MoD = 0.36;
        r.DoM = '-';
        r.STFD = 27;
        r.LSSPu = 7.6;
        r.TSu = 0.02;
        r.FSu = 0.3;
        r.MoDu = 0.36;
        r.DoMu = '-';
        r.STFDu = 27;
        
    case 'Alutip B-double side tipper' % Not sure where this comes from. Cannot find the baseline pic.
        r.STA = 27;
        r.GRAa = 30;
        r.GRAb = 87;
        r.ACC = 18.6;
        r.SRTt = 0.27;
        r.SRTtrrcu = 0.27;
        r.YDC = 0.31;
        r.RA = 0.96;
        r.HSTO = 0.6;
        r.TASP = 2.85;
        r.LSSP = 7.6;
        r.TS = 0.01;
        r.FS = 0.35;
        r.MoD = 0.08;
        r.DoM = -0.05;
        r.STFD = 30;
        r.LSSPu = 7.6;
        r.TSu = 0.01;
        r.FSu = 0.35;
        r.MoDu = 0.09;
        r.DoMu = -0.03;
        r.STFDu = 18;
        
    case 'CIMC B-double side tipper' %E:\PBS\Projects\P2020015_CIMC-SA_CIMC-9A-B-Double-Sidetipper_Volvo-FH480-6x4_MB-Actros-3352S\Baseline
        r.STA = 23;
        r.GRAa = 30;
        r.GRAb = 86;
        r.ACC = 18.1;
        r.SRTt = 0.29;
        r.SRTtrrcu = 0.29;
        r.YDC = 0.36;
        r.RA = 0.90;
        r.HSTO = 0.6;
        r.TASP = 3.0;
        r.LSSP = 7.8;
        r.TS = 0.04;
        r.FS = 0.3;
        r.MoD = 0.20;
        r.DoM = -0.15;
        r.STFD = 31;
        r.LSSPu = 7.7;
        r.TSu = 0.04;
        r.FSu = 0.3;
        r.MoDu = 0.2;
        r.DoMu = -0.11;
        r.STFDu = 19;
        
    case '50-50 Car-carrier'
        r.STA = 11;
        r.GRAa = 15;
        r.GRAb = 91;
        r.ACC = 16.7;
        r.SRTt = 0.37;
        r.SRTtrrcu = 0.37;
        r.YDC = 0.33;
        r.RA = 1.13;
        r.HSTO = 0.6;
        r.TASP = 2.9;
        r.LSSP = 6.5;
        r.TS = 0.50;
        r.FS = 0.6;
        r.MoD = '-';
        r.DoM = '-';
        r.STFD = 22;
        r.LSSPu = '-';
        r.TSu = '-';
        r.FSu = '-';
        r.MoDu = '-';
        r.DoMu = '-';
        r.STFDu = '-';
        
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
        
    case 'Short-long car-carrier (Maxiporter Mk2)' % See Wits-PBS assess-Unipower-Maxiporter Mk3 with Volvo FM400 FM62TR3HL
        r.STA = '-';
        r.GRAa = '-';
        r.GRAb = '-';
        r.ACC = '-';
        r.SRTt = 0.35;
        r.SRTtrrcu = 0.35;
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
        
        case 'Leader Bdouble tipper' % 
        r.STA = 29;
        r.GRAa = 30;
        r.GRAb = 98;
        r.ACC = 18.8;
        r.SRTt = 0.30;
        r.SRTtrrcu = 0.30;
        r.YDC = 0.3;
        r.RA = 1.06;
        r.HSTO = 0.5;
        r.TASP = 2.80;
        r.LSSP = 7.5;
        r.TS = 0.01;
        r.FS = 0.35;
        r.MoD = 0.28;
        r.DoM = -0.06;
        r.STFD = 30;
        r.LSSPu = 7.5;
        r.TSu = 0.01;
        r.FSu = 0.35;
        r.MoDu = 0.28;
        r.DoMu = -0.01;
        r.STFDu = 21;
    
    case 'Transpec Bdouble belly dumper 56 tonne' % 20191024-CSIR-PBS Assessment-Afrit 8 Axle B-Double Bottom Dumper with Volvo FH 64 T3HA 520 6x4-Rev1
        r.STA = 18;
        r.GRAa = 25;
        r.GRAb = 94;
        r.ACC = 17.7;
        r.SRTt = 0.41;
        r.SRTtrrcu = 0.41;
        r.YDC = 0.22;
        r.RA = 0.95;
        r.HSTO = 0.5;
        r.TASP = 2.87;
        r.LSSP = 8.1;
        r.TS = 0.01;
        r.FS = 0.4;
        r.MoD = 0.26;
        r.DoM = '-';
        r.STFD = 26;
        r.LSSPu = 8.1;
        r.TSu = 0.01;
        r.FSu = 0.4;
        r.MoDu = 0.25;
        r.DoMu = '-';
        r.STFDu = 26;
        % 5.7 * SRTrrcu
    case '2-axle-semi-and-2-axle-pup' % 56 tonne CA Muller 2-axle-semi-and-2-axle-pup
        % Should check and redo
        r.STA = 17;
        r.GRAa = 25;
        r.GRAb = 88;
        r.ACC = 18.3;
        r.SRTt = 0.28;
        r.SRTtrrcu = 0.54;
        r.YDC = 0.09;
        r.RA = 2.93;
        r.HSTO = 1;
        r.TASP = 2.75;
        r.LSSP = 6.7;
        r.TS = 0.04;
        r.FS = 0.5;
        r.MoD = 0.04;
        r.DoM = -0.27;
        r.STFD = 26;
        r.LSSPu = 6.6;
        r.TSu = 0.04;
        r.FSu = 0.5;
        r.MoDu = 0.03;
        r.DoMu = -0.26;
        r.STFDu = 29;
        % 5.7 * SRTrrcu
    
    case '49 tonne Afrit semi container carrier' % E:\PBS\Library\Baseline Combinations\49 tonne semi container carrier (GRW)
        r.STA = 27;
        r.GRAa = 30;
        r.GRAb = 90;
        r.ACC = 17.5;
        r.SRTt = 0.28;
        r.SRTtrrcu = 0.28;
        r.YDC = 0.5;
        r.RA = 1.30;
        r.HSTO = 0.4;
        r.TASP = 2.80;
        r.LSSP = 7.0;
        r.TS = 0.11;
        r.FS = 0.35;
        r.MoD = 0.67;
        r.DoM = 0.34;
        r.STFD = 30;
        r.LSSPu = 7.0;
        r.TSu = 0.10;
        r.FSu = 0.35;
        r.MoDu = 0.65;
        r.DoMu = 0.36;
        r.STFDu = 18;
        
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
        r.STFD = '-';
        r.LSSPu = '-';
        r.TSu = '-';
        r.FSu = '-';
        r.MoDu = '-';
        r.DoMu = '-';
        r.STFDu = '-';
end

