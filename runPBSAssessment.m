function resultsPbs = runPBSAssessment(Is, Project, Combination, Report, ResultCode)

%% Adding the paths containing the required .m files
addpath('C:\Dropbox\PBS\MatLab\_Global_Scripts\PBS_Data');
%% Checking booleans
Is = checkBooleans(Is);
%% This has to go here to prevent the folder path being changed during a TD run
Project.runFolderPath = strcat(Project.resultsFolderPath, '\Version_', Project.revision);
%% Setting matlab keys for run
% These can be changed as you loop through a project if required

if Is.yawD;     MatKey.yawD = {'YawD', ResultCode.yawD};       end
if Is.ra;       MatKey.ra = {'RA', ResultCode.ra};           end
if Is.hsto;     MatKey.hsto = {'RA', ResultCode.ra};         end
if Is.srt;      MatKey.srt = {'SRT', ResultCode.srt};        end
if Is.tasp;     MatKey.tasp = {'TASP', ResultCode.tasp};       end
if Is.lst;      MatKey.lst = {'LST', ResultCode.lst};         end
if Is.lsunt;    MatKey.lsunt = {'LSunT', ResultCode.lsunt};     end % unloaded is always the same in all cases
if Is.long;     MatKey.long = {'LST', ResultCode.lst};        end % use LST erd file if you are going to be calculating the longitudinal standards
if Is.axle;     MatKey.axle = {'AXLE', ResultCode.axle};       end

%%	Passing variables to PostProcess
[Project, ParDetails, Sprung, Axle, Hitch, Engine, Report, Dimensions, fullName, Lim, LimReport, resultsPbs, nLevels,...
    Is, PayloadLaden, Axle1, AxleU1, Tyre, Combination] =...
    runPBSManoeuvres(Is, Project, Combination, MatKey, Report);

if Is.carCarrier
    Project.revision = strcat(Project.revision, '_TD');
    
    if Is.yawD;     MatKey.yawD = {'YawD_TD', ResultCode.yawD_TD};    end
    if Is.ra;       MatKey.ra = {'RA_TD', ResultCode.ra_TD};        end
    if Is.hsto;     MatKey.hsto = {'RA_TD', ResultCode.ra_TD};      end
    if Is.srt;      MatKey.srt = {'SRT_TD', ResultCode.srt_TD};     end
    if Is.tasp;     MatKey.tasp = {'TASP_TD', ResultCode.tasp_TD};    end
    if Is.lst;      MatKey.lst = {'LST_TD', ResultCode.lst_TD};      end
    if Is.lsunt;    MatKey.lsunt = {'LSunT', ResultCode.lsunt_TD};     end % unloaded is always the same in all cases
    if Is.long;     MatKey.long = {'LST_TD', ResultCode.lst_TD};     end % use LST erd file if you are going to be calculating the longitudinal standards
    if Is.axle;     MatKey.axle = {'AXLE_TD', ResultCode.axle_TD};    end
    
    [Topdeck.Project, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, Topdeck.resultsPbs, ~, ~, Topdeck.PayloadLaden, ~, ~, ~, ~] = ...
        runPBSManoeuvres(Is, Project, Combination, MatKey, Report);
    
    %%	Writting results and combination parameters to report if a full assessment is being conducted
    if Is.fullPBS || Is.writeParameterLog
        writeLatexPBSAssessment(Project, Combination, ParDetails, Sprung, Axle, Hitch, Engine, Report, Dimensions,...
            fullName, Lim, LimReport, resultsPbs, nLevels, Is, PayloadLaden, Axle1, AxleU1, Tyre, Topdeck);
    end
else
    %%	Writting reslts and combination parameters to report if a full assessment is being conducted
    if Is.fullPBS || Is.writeParameterLog
        writeLatexPBSAssessment(Project, Combination, ParDetails, Sprung, Axle, Hitch, Engine, Report, Dimensions,...
            fullName, Lim, LimReport, resultsPbs, nLevels, Is, PayloadLaden, Axle1, AxleU1, Tyre);
    end
end

disp('-------------------------------------------------------------------------------------');
disp('	Analysis complete');
disp('-------------------------------------------------------------------------------------');

end