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
% [0.1.0] - 2017-06-24
%
% *Added*
%
% * First code

function results = generateResults(r, Lim, fullName, nLevels, Is)

results = {}; %Allows for a non-square matrix

results = Appender(results, 'Standard'      , 'Units', 'Value', 'NTC Level Met', [1:nLevels]);

if Is.long
    results = Appender(results, fullName.STA        , '%'       , r.STA , checkLevel('>', r.STA, Lim.STA, nLevels), Lim.STA); % C3 = [C1 C2] concatenates contents of cell arrays C1 & C2 into a cell array
    results = Appender(results, fullName.GRAa       , '%'       , r.GRAa, checkLevel('>', r.GRAa, Lim.GRAa, nLevels), Lim.GRAa);
    results = Appender(results, fullName.GRAb       , 'km/h'    , r.GRAb, checkLevel('>', r.GRAb, Lim.GRAb, nLevels), Lim.GRAb);
    results = Appender(results, fullName.ACC        , 's'       , r.ACC , checkLevel('<', r.ACC, Lim.ACC, nLevels), Lim.ACC);
end
if Is.srt
    results = Appender(results, fullName.SRTt       , 'g'       , r.SRTt   , checkLevel('>', r.SRTt, Lim.SRT, nLevels), Lim.SRT);
    results = Appender(results, fullName.SRTtrrcu   , 'g'       , r.SRTtrrcu   , checkLevel('>', r.SRTtrrcu, Lim.SRT, nLevels), Lim.SRT);
end
if Is.yawD
    results = Appender(results, fullName.YDC        , '-'       , r.YDC    , checkLevel('>', r.YDC, Lim.YDC, nLevels), Lim.YDC);
end
if Is.ra
    results = Appender(results, fullName.RA         , '-'       , r.RA     , checkLevel('<', r.RA, Lim.RA, nLevels), Lim.RA);
end
if Is.hsto
    results = Appender(results, fullName.HSTO       , 'm'       , r.HSTO   , checkLevel('<', r.HSTO, Lim.HSTO, nLevels), Lim.HSTO);
end
if Is.tasp
    results = Appender(results, fullName.TASP       , 'm'       , r.TASP   , checkLevel('<', r.TASP, Lim.TASP, nLevels), Lim.TASP);
end
if Is.lst
    results = Appender(results, fullName.LSSP       , 'm'       , r.LSSP   , checkLevel('<', r.LSSP, Lim.LSSP, nLevels), Lim.LSSP);
    results = Appender(results, fullName.TS         , 'm'       , r.TS     , checkLevel('<', r.TS, Lim.TS, nLevels), Lim.TS);
    results = Appender(results, fullName.FS         , 'm'       , r.FS     , checkLevel('<', r.FS, Lim.FS, nLevels), Lim.FS);
    if Is.semi,%doesnt add MoD, DoM if it is not a SemiTrailer
        results = Appender(results, fullName.MoD    , 'm', r.MoD    , checkLevel('<', r.MoD, Lim.MoD, nLevels), Lim.MoD);
        results = Appender(results, fullName.DoM    , 'm', r.DoM    , checkLevel('<', r.DoM, Lim.DoM, nLevels), Lim.DoM);
    end
    results = Appender(results, fullName.STFD   , '%', r.STFD   , checkLevel('<', r.STFD, Lim.STFD, nLevels), Lim.STFD);
end
if Is.lsunt
    results = Appender(results, fullName.LSSPu  , 'm', r.LSSPu  , checkLevel('<', r.LSSPu, Lim.LSSP, nLevels), Lim.LSSP);
    results = Appender(results, fullName.TSu    , 'm', r.TSu    , checkLevel('<', r.TSu, Lim.TS, nLevels), Lim.TS);
    results = Appender(results, fullName.FSu    , 'm', r.FSu    , checkLevel('<', r.FSu, Lim.FS, nLevels), Lim.FS);
    if Is.semi, %Doesnt add MoDu, DoMu if it is not a SemiTrailer
        results = Appender(results, fullName.MoDu   , 'm', r.MoDu   , checkLevel('<', r.MoDu, Lim.MoD, nLevels), Lim.MoD);
        results = Appender(results, fullName.DoMu   , 'm', r.DoMu   , checkLevel('<', r.DoMu, Lim.DoM, nLevels), Lim.DoM);
    end
    results = Appender(results, fullName.STFDu  , '%', r.STFDu  , checkLevel('<', r.STFDu, Lim.STFD, nLevels), Lim.STFD);
end

end