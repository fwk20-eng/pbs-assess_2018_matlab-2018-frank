function PbsAssessmentPostAndReport(Is, Project, Combination, Report)
%% Adding the paths containing the required .m files
addpath('C:\Dropbox\_Personal\Programming\Global_Matlab_Toolbox\Downloaded\latexTable');
addpath('C:\Dropbox\PBS\MatLab\Automated PBS Assessment\Automated Post Process');

%% Checking booleans
Is = checkBooleans(Is);
%% This has to go here to prevent the folder path being changed during a TD run
Project.runFolderPath = strcat(Project.resultsFolderPath, '\Version_', Project.revision);
%% Setting matlab keys for run
% These can be changed as you loop through a project if required

if Is.carCarrier
    if Is.yawD;     MatKey.yawD = 'YawD_FL';    end
    if Is.ra;       MatKey.ra = 'RA_FL';        end
    if Is.hsto;     MatKey.hsto = 'RA_FL';      end
    if Is.srt;      MatKey.srt = 'Tilt_FL';     end
    if Is.tasp;     MatKey.tasp = 'TASP_FL';    end
    if Is.lst;      MatKey.lst = 'LST_FL';      end
    if Is.lsunt;    MatKey.lsunt = 'LSunT';     end % unloaded is always the same in all cases
    if Is.long;     MatKey.long = 'LST_FL';     end % use LST erd file if you are going to be calculating the longitudinal standards
    if Is.axle; MatKey.axle = 'AXLE_FL';    end
else
    if Is.yawD;     MatKey.yawD = 'YawD';       end
    if Is.ra;       MatKey.ra = 'RA';           end
    if Is.hsto;     MatKey.hsto = 'RA';         end
    if Is.srt;      MatKey.srt = 'Tilt';        end
    if Is.tasp;     MatKey.tasp = 'TASP';       end
    if Is.lst;      MatKey.lst = 'LST';         end
    if Is.lsunt;    MatKey.lsunt = 'LSunT';     end % unloaded is always the same in all cases
    if Is.long;     MatKey.long = 'LST';        end % use LST erd file if you are going to be calculating the longitudinal standards
    if Is.axle; MatKey.axle = 'AXLE';       end
end

%%	Passing variables to PostProcess
[Project, ParDetails, Sprung, Axle, Hitch, Engine, Report, Dimensions, fullName, Lim, LimReport, resultsPbs, nLevels,...
    Is, PayloadLaden, Axle1, AxleU1, Tyre] = PostProcessMultiChoice(Is, Project, Combination, MatKey, Report);

if Is.carCarrier
    Project.revision = strcat(Project.revision, '_TD');
    
    if Is.yawD;     MatKey.yawD = 'YawD_TD';    end
    if Is.ra;       MatKey.ra = 'RA_TD';        end
    if Is.hsto;     MatKey.hsto = 'RA_TD';      end
    if Is.srt;      MatKey.srt = 'Tilt_TD';     end
    if Is.tasp;     MatKey.tasp = 'TASP_TD';    end
    if Is.lst;      MatKey.lst = 'LST_TD';      end
    if Is.lsunt;    MatKey.lsunt = 'LSunT';     end % unloaded is always the same in all cases
    if Is.long;     MatKey.long = 'LST_TD';     end % use LST erd file if you are going to be calculating the longitudinal standards
    if Is.axle;     MatKey.axle = 'AXLE_TD';    end
    
    [Topdeck.Project, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, Topdeck.resultsPbs, ~, ~, Topdeck.PayloadLaden, ~, ~, ~] = ...
        PostProcessMultiChoice(Is, Project, Combination, MatKey, Report);
    
%%	Writting reslts and combination parameters to report if a full assessment is being conducted
if Is.fullPBS
    writeToLatexPbsAssessment(Project, Combination, ParDetails, Sprung, Axle, Hitch, Engine, Report, Dimensions,...
        fullName, Lim, LimReport, resultsPbs, nLevels, Is, PayloadLaden, Axle1, AxleU1, Tyre, Topdeck);
end
else
%%	Writting reslts and combination parameters to report if a full assessment is being conducted
    if Is.fullPBS
        writeToLatexPbsAssessment(Project, Combination, ParDetails, Sprung, Axle, Hitch, Engine, Report, Dimensions,...
            fullName, Lim, LimReport, resultsPbs, nLevels, Is, PayloadLaden, Axle1, AxleU1, Tyre);
    end
end

disp('-------------------------------------------------------------------------------------');
disp('	Analysis complete');
disp('-------------------------------------------------------------------------------------');
end