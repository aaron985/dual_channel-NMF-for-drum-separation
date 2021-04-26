%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: dictionaryW_pre_extract
% Date: April 2021
%
% Description :
% This program is for converting audioes to dictionaryW (magnitude
% spectrogram) of NMF.
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

% data input path
inpPath = '../2.data/1.dictionaryW_wav/';
% instrument list
instrument = {'1.BD','2.SD','3.HH','4.Tom1','5.Tom2','6.Floor Tom','7.Crash','8.Ride'};
 
% STFT parameter
paramSTFT.blockSize = 2048;  
paramSTFT.hopSize = 256;
paramSTFT.winFunc = hann(paramSTFT.blockSize);
paramSTFT.reconstMirror = true;
paramSTFT.appendFrame = true;

% scan folders in every instrument path
for a = 1:8 %1:8
    a
    folder = dir([inpPath,instrument{a}]);
    
    % scan wav files in every folder
    for b = 3:length(folder)
        file = dir(strcat([inpPath,instrument{a},'/',folder(b).name,'/'], '*.wav'));
        
        for c = 1:length(file)
        % read audio
        [x,~] = audioread([inpPath,instrument{a},'/',folder(b).name,'/',file(c).name]);
        
        % STFT Parameter
        paramSTFT.numSamples = length(x);
        
        % STFT Computation
        [~,A,~] = forwardSTFT(x,paramSTFT);

        % sum all A column
        A = sum(A,2);
        
        % normalize A
        A = A/norm(A);
        
        % save feature
        matrix(:,c) = A;
        savepath = [char(['../2.data/2.dictionaryW_mat/',instrument{a},'/']) folder(b).name,'.mat'];
        save (savepath, 'matrix');
        end
    end
end