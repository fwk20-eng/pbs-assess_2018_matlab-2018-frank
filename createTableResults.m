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

function results = createTableResults(r, Lim, fullName, nLevels, Is)

results = {}; %Allows for a non-square matrix

results = addResultsRow(results, 'Standard'      , 'Units', 'Value', 'NTC Level Met', [1:nLevels]);

if Is.long
    results = addResultsRow(results, fullName.STA        , '%'       , r.STA , computePBSLevel('>', r.STA, Lim.STA, nLevels), Lim.STA); % C3 = [C1 C2] concatenates contents of cell arrays C1 & C2 into a cell array
    results = addResultsRow(results, fullName.GRAa       , '%'       , r.GRAa, computePBSLevel('>', r.GRAa, Lim.GRAa, nLevels), Lim.GRAa);
    results = addResultsRow(results, fullName.GRAb       , 'km/h'    , r.GRAb, computePBSLevel('>', r.GRAb, Lim.GRAb, nLevels), Lim.GRAb);
    results = addResultsRow(results, fullName.ACC        , 's'       , r.ACC , computePBSLevel('<', r.ACC, Lim.ACC, nLevels), Lim.ACC);
end
if Is.srt
    results = addResultsRow(results, fullName.SRTt       , 'g'       , r.SRTt   , computePBSLevel('>', r.SRTt, Lim.SRT, nLevels), Lim.SRT);
    results = addResultsRow(results, fullName.SRTtrrcu   , 'g'       , r.SRTtrrcu   , computePBSLevel('>', r.SRTtrrcu, Lim.SRT, nLevels), Lim.SRT);
end
if Is.yawD
    results = addResultsRow(results, fullName.YDC        , '-'       , r.YDC    , computePBSLevel('>', r.YDC, Lim.YDC, nLevels), Lim.YDC);
end
if Is.ra
    results = addResultsRow(results, fullName.RA         , '-'       , r.RA     , computePBSLevel('<', r.RA, Lim.RA, nLevels), Lim.RA);
end
if Is.hsto
    results = addResultsRow(results, fullName.HSTO       , 'm'       , r.HSTO   , computePBSLevel('<', r.HSTO, Lim.HSTO, nLevels), Lim.HSTO);
end
if Is.tasp
    results = addResultsRow(results, fullName.TASP       , 'm'       , r.TASP   , computePBSLevel('<', r.TASP, Lim.TASP, nLevels), Lim.TASP);
end
if Is.lst
    results = addResultsRow(results, fullName.LSSP       , 'm'       , r.LSSP   , computePBSLevel('<', r.LSSP, Lim.LSSP, nLevels), Lim.LSSP);
    results = addResultsRow(results, fullName.TS         , 'm'       , r.TS     , computePBSLevel('<', r.TS, Lim.TS, nLevels), Lim.TS);
    results = addResultsRow(results, fullName.FS         , 'm'       , r.FS     , computePBSLevel('<', r.FS, Lim.FS, nLevels), Lim.FS);
    if Is.semi,%doesnt add MoD, DoM if it is not a SemiTrailer
        results = addResultsRow(results, fullName.MoD    , 'm', r.MoD    , computePBSLevel('<', r.MoD, Lim.MoD, nLevels), Lim.MoD);
        results = addResultsRow(results, fullName.DoM    , 'm', r.DoM    , computePBSLevel('<', r.DoM, Lim.DoM, nLevels), Lim.DoM);
    end
    results = addResultsRow(results, fullName.STFD   , '%', r.STFD   , computePBSLevel('<', r.STFD, Lim.STFD, nLevels), Lim.STFD);
end
if Is.lsunt
    results = addResultsRow(results, fullName.LSSPu  , 'm', r.LSSPu  , computePBSLevel('<', r.LSSPu, Lim.LSSP, nLevels), Lim.LSSP);
    results = addResultsRow(results, fullName.TSu    , 'm', r.TSu    , computePBSLevel('<', r.TSu, Lim.TS, nLevels), Lim.TS);
    results = addResultsRow(results, fullName.FSu    , 'm', r.FSu    , computePBSLevel('<', r.FSu, Lim.FS, nLevels), Lim.FS);
    if Is.semi, %Doesnt add MoDu, DoMu if it is not a SemiTrailer
        results = addResultsRow(results, fullName.MoDu   , 'm', r.MoDu   , computePBSLevel('<', r.MoDu, Lim.MoD, nLevels), Lim.MoD);
        results = addResultsRow(results, fullName.DoMu   , 'm', r.DoMu   , computePBSLevel('<', r.DoMu, Lim.DoM, nLevels), Lim.DoM);
    end
    results = addResultsRow(results, fullName.STFDu  , '%', r.STFDu  , computePBSLevel('<', r.STFDu, Lim.STFD, nLevels), Lim.STFD);
end

end