function plan = buildfile
import matlab.buildtool.tasks.*

% Extract tasks from local functions
plan = buildplan(localfunctions);

% CodeIssues task
plan("check") = CodeIssuesTask(Results=["results/codeissues.sarif"; ...
                                        "results/codeissues.mat"]);

% Test task
tTask = TestTask("tests", ...
    SourceFiles = "code", ...
    IncludeSubfolders = true,...
    TestResults = fullfile("results","tests","index.html"),...
    RunOnlyImpactedTests=true); 

tTaskWithMatlabTest = tTask.addCodeCoverage( ...
    fullfile("results","coverage","index.html"), ...
    MetricLevel = "condition"); % Note: Change MetricLevel to "statement" 
                                % if you do not have MATLAB Test
plan("test") = tTaskWithMatlabTest;

% Clean task
plan("clean") = CleanTask();

% Define dependencies
plan("compile").Dependencies = "test";
plan("test").Dependencies = "generateSimFun";
plan("generateSimFun").Dependencies = "check";

% Define inputs and outputs
proj = currentProject;
plan("generateSimFun").Inputs = fullfile(proj.RootFolder,"code","*.sbproj");
plan("generateSimFun").Outputs = fullfile(proj.RootFolder,"code","*.mat");
plan("test").Inputs = fullfile(proj.RootFolder,"code","*");
plan("compile").Inputs = fullfile(proj.RootFolder,"code",["*.mat","*.mlapp","graystyle.m"]);
plan("compile").Outputs = fullfile(proj.RootFolder,"WebAppArchive");

% Set default task
plan.DefaultTasks = "compile";

end

function generateSimFunTask(~)
    % Generate SimFunction and associated MAT file for app to run
    generateSimFun();
end

function compileTask(~)
    % Compile App into Web App

    proj = currentProject;
    rootFolder = proj.RootFolder; % Get the root folder of the project

    imgFiles = dir(fullfile(rootFolder,"code","images","*.*"));
    imgFiles = string({imgFiles.name}');
    imgFiles = fullfile(rootFolder,"code","images",imgFiles(~matches(imgFiles,[".",".."])));
    codeFiles = dir(fullfile(rootFolder,"code","*.m"));
    codeFiles = string({codeFiles.name}');
    codeFiles = fullfile(rootFolder,"code",setdiff(codeFiles,"generateSimFun.m"));

    MATfilename = dir(fullfile(rootFolder,"code","*.mat"));
    MATfilename = fullfile(rootFolder,"code",MATfilename.name);
    s = load(MATfilename,"dependenciesSimFun");

    appDependencies = [MATfilename; s.dependenciesSimFun; ...
        codeFiles; imgFiles];
    appfilename = fullfile(rootFolder,"code","TMDDApp.mlapp");

    compiler.build.webAppArchive(appfilename,...
        AdditionalFiles=appDependencies,OutputDir="WebAppArchive");

end
