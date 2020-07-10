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
% [0.2.0] - 2017-06-04
%
% *Fixed*
%
% * Removed the floating precision
% 
% [0.1.0] - 2017-05-02
% 
% *Added*
% 
% * First code

function pbsResultsTable = createTableLatexResults(fullName, Lim, LimReport, r, Report, nLevels, Is)
pbsResultsTable = {};

pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.STA        , '\%'       , num2str(r.STA) , computePBSLevel('>', r.STA, Lim.STA, nLevels), LimReport.STA); % C3 = [C1 C2] concatenates contents of cell arrays C1 & C2 into a cell array
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.GRAa       , '\%'       , num2str(r.GRAa) , computePBSLevel('>', r.GRAa, Lim.GRAa, nLevels), LimReport.GRAa);
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.GRAb       , 'km/h'    , num2str(r.GRAb) , computePBSLevel('>', r.GRAb, Lim.GRAb, nLevels), LimReport.GRAb);
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.ACC        , 's'       , num2str(r.ACC) , computePBSLevel('<', r.ACC, Lim.ACC, nLevels), LimReport.ACC);
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.SRTt       , 'g'       , num2str(r.SRTt)   , computePBSLevel('>', r.SRTt, Lim.SRT, nLevels), LimReport.SRT);
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.SRTtrrcu   , 'g'       , num2str(r.SRTtrrcu)   , computePBSLevel('>', r.SRTtrrcu, Lim.SRT, nLevels), LimReport.SRT);
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.YDC        , '-'       , num2str(r.YDC)    , computePBSLevel('>', r.YDC, Lim.YDC, nLevels), LimReport.YDC);
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.RA         , '-'       , num2str(r.RA)     , computePBSLevel('<', r.RA, Lim.RA, nLevels), LimReport.RA);
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.HSTO       , 'm'       , num2str(r.HSTO)   , computePBSLevel('<', r.HSTO, Lim.HSTO, nLevels), LimReport.HSTO);
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, [fullName.TASP '\tnote{1}']       , 'm'       , num2str(r.TASP)   , computePBSLevel('<', r.TASP, Lim.TASP, nLevels), LimReport.TASP);
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.LSSP       , 'm'       , num2str(r.LSSP)   , computePBSLevel('<', r.LSSP, Lim.LSSP, nLevels), LimReport.LSSP);
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.TS         , 'm'       , num2str(r.TS)     , computePBSLevel('<', r.TS, Lim.TS, nLevels), LimReport.TS);
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, [fullName.FS '\tnote{3}'], 'm'       , num2str(r.FS)     , computePBSLevel('<', r.FS, Lim.FS, nLevels), LimReport.FS);
if Is.semi %doesnt add MoD, DoM if it is not a SemiTrailer
    pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, [fullName.MoD '\tnote{2}']    , 'm', num2str(r.MoD)    , computePBSLevel('<', r.MoD, Lim.MoD, nLevels), LimReport.MoD);
    pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, [fullName.DoM '\tnote{2}']    , 'm', num2str(r.DoM)    , computePBSLevel('<', r.DoM, Lim.DoM, nLevels), LimReport.DoM);
end
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.STFD   , '\%', num2str(r.STFD)   , computePBSLevel('<', r.STFD, Lim.STFD, nLevels), LimReport.STFD);
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.LSSPu  , 'm', num2str(r.LSSPu)  , computePBSLevel('<', r.LSSPu, Lim.LSSP, nLevels), LimReport.LSSP);
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.TSu    , 'm', num2str(r.TSu)    , computePBSLevel('<', r.TSu, Lim.TS, nLevels), LimReport.TS);
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, [fullName.FSu '\tnote{3}'], 'm', num2str(r.FSu)   , computePBSLevel('<', r.FSu, Lim.FS, nLevels), LimReport.FS);
if Is.semi %Doesnt add MoDu, DoMu if it is not a SemiTrailer
    pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, [fullName.MoDu '\tnote{1}']   , 'm', num2str(r.MoDu)   , computePBSLevel('<', r.MoDu, Lim.MoD, nLevels), LimReport.MoD);
    pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, [fullName.DoMu '\tnote{1}']   , 'm', num2str(r.DoMu)   , computePBSLevel('<', r.DoMu, Lim.DoM, nLevels), LimReport.DoM);
end
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.STFDu  , '\%', num2str(r.STFDu)  , computePBSLevel('<', r.STFDu, Lim.STFD, nLevels), LimReport.STFD);

pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, '$\dagger$ 5.7*SRT'  , '-', num2str(5.7*r.SRTtrrcu, '%0.1f')  , '-', {'-' '-' '-' '-'});