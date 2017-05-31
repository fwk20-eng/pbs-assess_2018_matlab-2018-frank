%% Function Description
%
% Post Processor that processes the results from TruckSim, outputing a summary of results in graphical form as well as
% in an Excel spreadsheet
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
%% Future Additions
%
% * Extract axle loadings from MatLab Files to add/compare to MatLab (use a static procedure in TruckSim to get
%   accurate loadings)
% * Have function that checks input parameters are correct
% * Do artic angle and artic angle rate for Yaw Damping
% * Do summary of all elements in r
%
%
%% Checks and corrections
%
% * Does the programme work for truck trailer combination with dolleys?
% * Correct STFD
% * Correct SRT for lift of all Fz except steer.
% * Check SRTrrcu
%
% [0.8.0]
%
% * Neaten up the code, to aid in modifications to allow car-carriers
%
% [0.7.0] - 2017-05-13
%
% * Added the ability to write the results to the report.
%
% [0.6.0] - 2017-05-12
%
% *Fixed*
%
% * Improved some variable names. Work still needs to be done in this regard
% * Improved variable pass-through
%
% *Added*
%
% * PBS Assessment copying of template and edition according to Report structure details
%
% [0.5.0] - 2017-05-10
%
% *Added*
%
% * Added Latex Table Generation
%
%
%% [0.4.0] - 2017-05-02
%
% *Added*
%
% * Moved unchanged code from project file to the main postprocess file
%
%% [0.3.0] - 2017-05-01
%
% *Added*
%
% * TruckSim data has now been extracted and no longer needs to be manually entered.
% * Variables to be input have been shortened with the use of structures. (Variables beginning with a capital letter)
%
%% [0.2.0] - Date Unknown
%
% *Added*
%
% * Check for the lateral acceleration in the YawD manoeuvre (Program will now generate an error if the lateral
% acceleration is outside of the range 0.19 < LatAccel < 0.21 for the lead unit)
% * Check for the lateral error in the RA manoeuvre (Program will now generate an error if the lateral error is above
%   30 mm)
% * Added a new function to generate an auto log file with the Project.runNotes which can be appended even if no data is saved

%% [0.1.0] - Date Unknown
%
% * Completely removed PBS functions from the input file
% * Each project will now get its own PostProcess file of the format a000_PostProcess - the a to move it to the top of
%   the folder
% * Added functionality to choose which PBS manoeuvres to run
% * Results will only be saved for a full PBS analysis

%% NOTES:
% 1. List of inputs from TruckSim listed in "Inputs required from TruckSim.xls" file in this folder

%% Beginning of function
function [Project, ParDetails, Sprung, Axle, Hitch, Engine, Report, Dimensions, fullName, Lim, LimReport, resultsPbs, nLevels, Is, PayloadLaden, Axle1, AxleU1, Tyre] =...
    PostProcessMultiChoice(Is, Project, Combination, MatKey, Report)
%% Preamble
%% Generate the required file paths and perform the necessary checks for the assessment
[Project, ParDetails, Is] = generateFilePaths(Project, MatKey, Is);

createRunLog(Is, Project);

% With the new data extraction, the project needs to be saved in order to run, so Is.save may be redundant 
if Is.save
    copyTruckSimRunFiles(MatKey, Project, Is);
    [Tyre, Axle, Hitch, Sprung, Dimensions, PayloadLaden, PayloadUnladen] = getTruckSimSimulationData(ParDetails);
    [Engine] = getEngineData(Combination.engineModel, Tyre.NumberOff);
    
    writeToExcelAxleLoads(Project, Sprung, PayloadLaden, Axle, Hitch, Combination, Is);
end
%%	Constants
warning off

g = 9.81; % [g] CONFIRM WITH FRANK IF THIS IS NECESSARY
nLevels = 4;    % PBS levels - should correspond to size of cell arrays in setLims function
radial = 1; %radial = 1 for radial tyres else = 0 if bias ply
muPeakSteer = 1;       % not sure why but TS also uses 1.0 for their STFD calcs
RAinputAy = 0.15;      % [g] normally 0.15 for RA test completed at 88km/h %% CONFIRM WITH FRANK IF THIS IS NECESSARY
SRTrollThresh = 30;    % PBS rules
%%	Execute PBS manoeuvres if required
if Is.pbs
    Sprung.numberOffUnits = length(Sprung.MassArray);      % includes Combination.dollys

    fullName = setFullNames();
    [Lim, LimReport] = setLims(Is);
    
    [mSprung, XcgSprung, HcgSprung] = detSprung(Sprung.MassArray, Sprung.MassCoGxPosition, Sprung.MassCoGzPosition, PayloadLaden.MassCell, PayloadLaden.CoGxPositionCell, PayloadLaden.CoGzPositionCell); % Determine sprung mass properties of each vehicle unit
    [mSprungU, XcgSprungU, HcgSprungU] = detSprung(Sprung.MassArray, Sprung.MassCoGxPosition, Sprung.MassCoGzPosition, PayloadUnladen.MassCell, PayloadUnladen.CoGxPositionCell, PayloadUnladen.CoGzPositionCell); % Determine sprung mass properties of each vehicle unit in unloaded configuration
    [mTotal x z] = determineCOG(Sprung.MassArray, Sprung.MassCoGxPosition, Sprung.MassCoGzPosition, Axle.UnsprungMassArray, Axle.XPositionArray, Axle.ZPositionArray, Axle.Grouping, PayloadLaden.MassCell, PayloadLaden.CoGxPositionCell, PayloadLaden.CoGzPositionCell); % Determine sprung mass properties of each vehicle unit
   
    Axle1 = AxleLoade(0, Axle.UnsprungMassArray, Axle.XPositionArray, Axle.ZPositionArray, Hitch.XPositionArray, Hitch.ZPositionArray, mSprung, XcgSprung, HcgSprung, Axle.Grouping, Combination.loadshare1, Hitch.LoadCoupledArray); %Loaded axles loads for normal operation
    Axle2 = AxleLoade(0, Axle.UnsprungMassArray, Axle.XPositionArray, Axle.ZPositionArray, Hitch.XPositionArray, Hitch.ZPositionArray, mSprung, XcgSprung, HcgSprung, Axle.Grouping, Combination.loadshare2, Hitch.LoadCoupledArray); %Loaded axles loads for Startability
    AxleU1 = AxleLoade(0, Axle.UnsprungMassArray, Axle.XPositionArray, Axle.ZPositionArray, Hitch.XPositionArray, Hitch.ZPositionArray, mSprungU, XcgSprungU, HcgSprungU, Axle.Grouping, Combination.loadshare1, Hitch.LoadCoupledArray); %Unloaded axles loads for normal operation
    AxleU2 = AxleLoade(0, Axle.UnsprungMassArray, Axle.XPositionArray, Axle.ZPositionArray, Hitch.XPositionArray, Hitch.ZPositionArray, mSprungU, XcgSprungU, HcgSprungU, Axle.Grouping, Combination.loadshare2, Hitch.LoadCoupledArray); %Unloaded axle loads for Startability, which is not required
    AxleLoading = [[1:Axle.NumberOff]; Combination.loadshare1; Axle1; AxleU1; Combination.loadshare2; Axle2; AxleU2];%Raw axle loading values
    roundAxleLoading = [[1:Axle.NumberOff]; Combination.loadshare1; round(Axle1,0); round(AxleU1,0); Combination.loadshare2; round(Axle2,0); round(AxleU2,0)];%Rounded axle loadings
    
    if Is.long
        [r.STA, r.GRAa, r.GRAb, r.ACC] = LONG_solve(mTotal, Combination.frontalAreaForDrag, radial, Combination.ch, Combination.cd, Combination.ce, Engine.gears, Engine.eff_gear, Engine.gearsStart, Engine.eff_gearStart, Engine.eff_diff, Engine.dif, Engine.eff_diffStart, Engine.difStart, Engine.Torquerpm, Engine.TorqueNm, Engine.engageTrpm, Engine.engageTNm, Engine.changeT, Tyre.RollingRadius, Engine.Ie, Engine.It, Axle.Driven, Engine.gearshiftregime, Project.savePath, Project.runKey, Is.plotOn, Is.save, Axle.UnsprungMassArray, Axle.XPositionArray, Axle.ZPositionArray, Hitch.XPositionArray, Hitch.ZPositionArray, mSprung, XcgSprung, HcgSprung, Axle.Grouping, Combination.loadshare1, Combination.loadshare2, Hitch.LoadCoupledArray);
    end
    if Is.yawD
        r.YDC = YawD_solve(Sprung.numberOffUnits, Project.savePath, Project.truckSimRunsPath, Project.runKey, MatKey.yawD, Is.plotOn, Is.save);
    end
    if Is.ra
        r.RA = RA_solve(mSprung, HcgSprung, Hitch.RollCoupledArray, Combination.dollys, Project.savePath, Project.truckSimRunsPath, Project.runKey, MatKey.ra, Is.plotOn, Is.save);
    end
    if Is.hsto
        r.HSTO = HSTO_solve(Axle.NumberOff, Combination.totalLength, Project.savePath, Project.truckSimRunsPath, Project.runKey, MatKey.hsto, Is.plotOn, Is.save);
    end
    if Is.srt
        [r.SRTt, r.SRTtrrcu] = SRTt_solve(Axle.NumberOff, Axle.NumberOffSteer, Lim.SRT(Combination.pbsLevelDesired), SRTrollThresh, mSprung, HcgSprung,  Hitch.RollCoupledArray, Combination.dollys, Project.savePath, Project.truckSimRunsPath, Project.runKey, MatKey.srt, Is.plotOn, Is.save);
    end
    if Is.tasp
        r.TASP = TASP_solve(Sprung.numberOffUnits, Combination.dollys, Project.savePath, Project.truckSimRunsPath, Project.runKey, MatKey.tasp, Is.plotOn, Is.save);
    end
    if Is.lst
        [r.LSSP, r.TS, r.FS, r.MoD, r.DoM, r.STFD] = LSTurn_solve(Sprung.numberOffUnits, Combination.dollys, Dimensions.MaxWidthLaden, Axle.SteerAxleOverallWidth, Axle.NumberOffSteer, muPeakSteer, true, Project.savePath, Project.truckSimRunsPath, Project.runKey, MatKey.lst, Is.plotOn, Is.save);
    end
    if Is.lsunt
        [r.LSSPu,r.TSu,r.FSu,r.MoDu,r.DoMu,r.STFDu] = LSTurn_solve(Sprung.numberOffUnits, Combination.dollys, Dimensions.MaxWidthUnladen, Axle.SteerAxleOverallWidth, Axle.NumberOffSteer, muPeakSteer, false, Project.savePath, Project.truckSimRunsPath, Project.runKey, MatKey.lsunt, Is.plotOn, Is.save);
    end
    
    if Is.fullPBS %SRT required for this to work
        Lim.RA = setLimsRA(r);
    end
    
    disp('-------------------------------------------------------------------------------------')
    disp('	Results')
    disp('-------------------------------------------------------------------------------------')
    resultsPbs = r;
    disp(r);
    editLogWithRunResults(Project, Is, r)

    %% Adding functionality to remove the .mat files from the runs directory
    removeMFilesFromTruckSimRunsFolder(Project, Is);
    warning on
    
    %% Write data to excel
    writeToExcelPbsResults(Lim, fullName, nLevels, Project, AxleLoading, Is, roundAxleLoading, r, Combination);
end
end