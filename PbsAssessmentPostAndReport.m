function PbsAssessmentPostAndReport(Is, Project, Combination, Report)
%% Adding the paths containing the required .m files
addpath('C:\Dropbox\_Personal\Programming\Global_Matlab_Toolbox\Downloaded\latexTable');
addpath('C:\Dropbox\PBS\MatLab\Automated PBS Assessment\Automated Post Process');

%% This has to go here to prevent the folder path being changed during a TD run
Project.runFolderPath = strcat(Project.resultsFolderPath, '\Version_', Project.revision);
%% Setting matlab keys for run
% These can be changed as you loop through a project if required

if Is.carCarrier
    MatKey.yawD = 'YawD_FL';
    MatKey.ra = 'RA_FL';
    MatKey.hsto = 'RA_FL';
    MatKey.srt = 'Tilt_FL';
    MatKey.tasp = 'TASP_FL';
    MatKey.lst = 'LST_FL';
    MatKey.lsunt = 'LSunT'; %unloaded is always the same in all cases
else
    MatKey.yawD = 'YawD';
    MatKey.ra = 'RA';
    MatKey.hsto = 'RA';
    MatKey.srt = 'Tilt';
    MatKey.tasp = 'TASP';
    MatKey.lst = 'LST';
    MatKey.lsunt = 'LSunT'; %unloaded is always the same in all cases
end

%%	Passing variables to PostProcess
[Project, ParDetails, Sprung, Axle, Hitch, Engine, Report, Dimensions, fullName, Lim, LimReport, resultsPbs, nLevels,...
    Is, PayloadLaden, Axle1, AxleU1, Tyre] = PostProcessMultiChoice(Is, Project, Combination, MatKey, Report);

if Is.carCarrier
    Project.revision = strcat(Project.revision, '_TD');
    MatKey.yawD = 'YawD_TD';
    MatKey.ra = 'RA_TD';
    MatKey.hsto = 'RA_TD';
    MatKey.srt = 'Tilt_TD';
    MatKey.tasp = 'TASP_TD';
    MatKey.lst = 'LST_TD';
    MatKey.lsunt = 'LSunT'; %unloaded is always the same in all cases
    [Topdeck.Project, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, Topdeck.resultsPbs, ~, ~, Topdeck.PayloadLaden, ~, ~, ~] = ...
        PostProcessMultiChoice(Is, Project, Combination, MatKey, Report);
    
%%	Writting reslts and combination parameters to report
    writeToLatexPbsAssessment(Project, Combination, ParDetails, Sprung, Axle, Hitch, Engine, Report, Dimensions,...
        fullName, Lim, LimReport, resultsPbs, nLevels, Is, PayloadLaden, Axle1, AxleU1, Tyre, Topdeck);
else
    writeToLatexPbsAssessment(Project, Combination, ParDetails, Sprung, Axle, Hitch, Engine, Report, Dimensions,...
        fullName, Lim, LimReport, resultsPbs, nLevels, Is, PayloadLaden, Axle1, AxleU1, Tyre);
end

disp('-------------------------------------------------------------------------------------');
disp('	Analysis complete');
disp('-------------------------------------------------------------------------------------');
end