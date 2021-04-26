function [output,dictW_width] = dictionaryW_slection_concatenation(list)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: dictionaryW_slection_concatenation
% Date: April 2021
%
% Description :
% This fuction is for concatenating dictionartW matrixes you selecting.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% calculate each instrument's length
list_num = length(list);
% empty matrix
output = [];

% load dictionaryW
for i = 1:list_num
    temp_out = importdata(['./',list{i},'.mat']);
    
    % concatenated matrix
    output = horzcat(output,temp_out);
    clear temp_out
end

% concatenated matrix length for NMF components
dictW_width = size(output,2);