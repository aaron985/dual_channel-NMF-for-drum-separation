%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: dictionaryW_pre_extract for score informed
% Date: April 2021
%
% Description :
% This program is for converting audioes to dictionaryW (magnitude
% spectrogram) of NMF. And this program is especially for score informed.
%
% References:
% Patricio LÃ³pez-Serrano, Christian Dittmar, YiÄŸitcan Ã–zer, and Meinard
%     MÃ¼ller
%     NMF Toolbox: Music Processing Applications of Nonnegative Matrix
%     Factorization
%     In Proceedings of the International Conference on Digital Audio Effects
%     (DAFx), 2019.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc

% data input Path
inpPath = '../2.data/1.dictionaryW_wav/score_informed_data/';

% STFT Parameter
paramSTFT.blockSize = 2048;
paramSTFT.hopSize = 256;
paramSTFT.winFunc = hann(paramSTFT.blockSize);
paramSTFT.reconstMirror = true;
paramSTFT.appendFrame = true;

% scan wav files
file = dir([inpPath,'*.wav']);

for i = 1:length(file)
    i
    
    % read audio
    [x,~] = audioread([inpPath,file(i).name]);
    
    % STFT parameter
    paramSTFT.numSamples = length(x);
    
    % STFT computation
    [~,A,~] = forwardSTFT(x,paramSTFT);
    
    %sum all A column
    A = sum(A,2);
    
    %Normalize A
    A = A/norm(A);
    
    %save feature
    dictionaryW(:,i) = A;
end

save('./dictionaryW(for score informed).mat','dictionaryW');