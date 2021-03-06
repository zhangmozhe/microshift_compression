function encoded_bitstream = ImportStream(filename)

%% Import data from text file.
% Script for importing data from the following text file:
%
%    C:\Users\Bo\OneDrive\Bit depth compression\further compression\bitstream.txt
%
% To extend the code to different selected data or a different text file,
% generate a function instead of a script.

% Auto-generated by MATLAB on 2016/12/28 11:33:27

%% Initialize variables.
delimiter = '';

%% Read columns of data as text:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename, 'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric text to numbers.
% Replace non-numeric text with NaN.
raw = repmat({''}, length(dataArray{1}), length(dataArray)-1);
for col = 1:length(dataArray) - 1
    raw(1:length(dataArray{col}), col) = dataArray{col};
end
numericData = NaN(size(dataArray{1}, 1), size(dataArray, 2));

%% Split data into numeric and cell columns.
rawNumericColumns = {};
rawCellColumns = raw(:, 1);

%% Allocate imported array to column variable names
VarName1 = rawCellColumns(:, 1);
encoded_bitstream = VarName1{1};
