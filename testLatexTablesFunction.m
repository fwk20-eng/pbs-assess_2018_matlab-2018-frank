addpath('C:\Dropbox\_Personal\Programming\Global_Matlab_Toolbox');
addpath('C:\Dropbox\_Personal\Programming\Global_Matlab_Toolbox\Downloaded\latexTable');

%% Setting the input data
% LaTeX table data
input.data = {'Unit no.' 'Description' 'Axle configuration' 'Suspension type' 'Tyre size' 'Rim material'};
% LaTex table caption:
input.tableCaption = 'Test';
% LaTex table label:
input.tableLabel = 'tblTestTable';

%% Formatting the table
%('l'=left-justified, 'c'=centered,'r'=right-justified) 
input.tableColumnAlignment = 'c'; 
% % Switch table borders on/off:
input.tableBorders = 1; % 0 = borders off, 1 = borders on
% Switch table booktabs on/off:
input.booktabs = 1;

%% Formatting the output code
% % Switch to generate a complete LaTex document or just a table:
input.makeCompleteLatexDocument = 0;

%% Calling the function
latexTable(input);


