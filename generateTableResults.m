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

function pbsResultsTable = generateTableResults(fullName, Lim, LimReport, r, Report, nLevels, Is)
pbsResultsTable = {};

pbsResultsTable = AppenderReport(pbsResultsTable, fullName.STA        , '\%'       , num2str(r.STA, '%0.2f') , checkLevel('>', r.STA, Lim.STA, nLevels), LimReport.STA); % C3 = [C1 C2] concatenates contents of cell arrays C1 & C2 into a cell array
pbsResultsTable = AppenderReport(pbsResultsTable, fullName.GRAa       , '\%'       , num2str(r.GRAa, '%0.2f') , checkLevel('>', r.GRAa, Lim.GRAa, nLevels), LimReport.GRAa);
pbsResultsTable = AppenderReport(pbsResultsTable, fullName.GRAb       , 'km/h'    , num2str(r.GRAb, '%0.2f') , checkLevel('>', r.GRAb, Lim.GRAb, nLevels), LimReport.GRAb);
pbsResultsTable = AppenderReport(pbsResultsTable, fullName.ACC        , 's'       , num2str(r.ACC, '%0.2f') , checkLevel('<', r.ACC, Lim.ACC, nLevels), LimReport.ACC);
pbsResultsTable = AppenderReport(pbsResultsTable, fullName.SRTt       , 'g'       , num2str(r.SRTt, '%0.2f')   , checkLevel('>', r.SRTt, Lim.SRT, nLevels), LimReport.SRT);
pbsResultsTable = AppenderReport(pbsResultsTable, fullName.SRTtrrcu   , 'g'       , num2str(r.SRTtrrcu, '%0.2f')   , checkLevel('>', r.SRTtrrcu, Lim.SRT, nLevels), LimReport.SRT);
pbsResultsTable = AppenderReport(pbsResultsTable, fullName.YDC        , '-'       , num2str(r.YDC, '%0.2f')    , checkLevel('>', r.YDC, Lim.YDC, nLevels), LimReport.YDC);
pbsResultsTable = AppenderReport(pbsResultsTable, fullName.RA         , '-'       , num2str(r.RA, '%0.2f')     , checkLevel('<', r.RA, Lim.RA, nLevels), LimReport.RA);
pbsResultsTable = AppenderReport(pbsResultsTable, fullName.HSTO       , 'm'       , num2str(r.HSTO, '%0.2f')   , checkLevel('<', r.HSTO, Lim.HSTO, nLevels), LimReport.HSTO);
pbsResultsTable = AppenderReport(pbsResultsTable, fullName.TASP       , 'm'       , num2str(r.TASP, '%0.2f')   , checkLevel('<', r.TASP, Lim.TASP, nLevels), LimReport.TASP);
pbsResultsTable = AppenderReport(pbsResultsTable, fullName.LSSP       , 'm'       , num2str(r.LSSP, '%0.2f')   , checkLevel('<', r.LSSP, Lim.LSSP, nLevels), LimReport.LSSP);
pbsResultsTable = AppenderReport(pbsResultsTable, fullName.TS         , 'm'       , num2str(r.TS, '%0.2f')     , checkLevel('<', r.TS, Lim.TS, nLevels), LimReport.TS);
pbsResultsTable = AppenderReport(pbsResultsTable, fullName.FS         , 'm'       , num2str(r.FS, '%0.2f')     , checkLevel('<', r.FS, Lim.FS, nLevels), LimReport.FS);
if Is.semi %doesnt add MoD, DoM if it is not a SemiTrailer
    pbsResultsTable = AppenderReport(pbsResultsTable, fullName.MoD    , 'm', num2str(r.MoD, '%0.2f')    , checkLevel('<', r.MoD, Lim.MoD, nLevels), LimReport.MoD);
    pbsResultsTable = AppenderReport(pbsResultsTable, fullName.DoM    , 'm', num2str(r.DoM, '%0.2f')    , checkLevel('<', r.DoM, Lim.DoM, nLevels), LimReport.DoM);
end
pbsResultsTable = AppenderReport(pbsResultsTable, fullName.STFD   , '\%', num2str(r.STFD, '%0.2f')   , checkLevel('<', r.STFD, Lim.STFD, nLevels), LimReport.STFD);
pbsResultsTable = AppenderReport(pbsResultsTable, fullName.LSSPu  , 'm', num2str(r.LSSPu, '%0.2f')  , checkLevel('<', r.LSSPu, Lim.LSSP, nLevels), LimReport.LSSP);
pbsResultsTable = AppenderReport(pbsResultsTable, fullName.TSu    , 'm', num2str(r.TSu, '%0.2f')    , checkLevel('<', r.TSu, Lim.TS, nLevels), LimReport.TS);
pbsResultsTable = AppenderReport(pbsResultsTable, fullName.FSu    , 'm', num2str(r.FSu, '%0.2f')   , checkLevel('<', r.FSu, Lim.FS, nLevels), LimReport.FS);
if Is.semi %Doesnt add MoDu, DoMu if it is not a SemiTrailer
    pbsResultsTable = AppenderReport(pbsResultsTable, fullName.MoDu   , 'm', num2str(r.MoDu, '%0.2f')   , checkLevel('<', r.MoDu, Lim.MoD, nLevels), LimReport.MoD);
    pbsResultsTable = AppenderReport(pbsResultsTable, fullName.DoMu   , 'm', num2str(r.DoMu, '%0.2f')   , checkLevel('<', r.DoMu, Lim.DoM, nLevels), LimReport.DoM);
end
pbsResultsTable = AppenderReport(pbsResultsTable, fullName.STFDu  , '\%', num2str(r.STFDu, '%0.2f')  , checkLevel('<', r.STFDu, Lim.STFD, nLevels), LimReport.STFD);