%{

## Description

This function reads in a textfile and reads in each line into a cell in a cell array

### Inputs
* File = Variable containing the contents of the file

## Change Log

[0.1.0] - 2017-04-17

Fixed
* Function name is now **readLinesFromFile** in order to be more consistent with Matlab naming conventions

```Matlab
%}

function [File] = readLinesFromFile(filename)
    
    fid = fopen(filename, 'r'); %Open the file for reading
    File = textscan(fid, '%s', 'delimiter', '\n'); %Reads the entire text file into the File variable
    fclose(fid); %close the file
    
    File = File{1,1}; %Extracting the variable from a 1x1 cell
 
end
