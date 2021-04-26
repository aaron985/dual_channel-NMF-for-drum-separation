%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: drum automix
% Date: April 2021
%
% Description :
% This program is for drum automix with drum separating results.
% We are going to let A imitate B.
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

%% common parameter
% separation mythed
type1 = 'dual channel NMF_result';
% cost funtion of drum separation
type2 = 'Euclidean'; %Euclidean, Itakura Saito, KL

%%
% 1. scan all drum separation result
A_filename = dir(['../3.output/',type1,'/',type2,'/*.wav']);

% create initial W for NMF of b
initW = [];

%%  A process
for i = 1:length(A_filename)
    % 2-1. read audio of A
    [A_x,fs] = audioread(['../3.output/',type1,'/',type2,'/',A_filename(i).name]);

    % 2-2-1. the sum of audio data
    if i ==1
        A_audio_sum = zeros(size(A_x));
    end
    A_audio_sum = A_audio_sum + A_x;
    % 2-2-2. normalize to +-1
    A_audio_sum = A_audio_sum / max(abs(A_audio_sum));
    
    % 2-3-1. STFT parameter
    paramSTFT.blockSize = 2048;
    paramSTFT.hopSize = 256;
    paramSTFT.winFunc = hann(paramSTFT.blockSize);
    paramSTFT.reconstMirror = true;
    paramSTFT.appendFrame = true;
    paramSTFT.numSamples = length(A_audio_sum);
    % 2-3-2. STFT computation
    [~,A,P] = forwardSTFT(A_x,paramSTFT);
    clear A_x
    
    % 2-4.
    % magnitude cell of A
    A_magnitude_cell{i} = A;
    % phase cell of A
    A_phase_cell{i} = P;
    % initial W for NMF of b
    A = sum(A,2);
    initW = horzcat(initW,A);
    clear A P
end
disp('complete A process')
clear A_filename 

%% B process
% 3-1-1. read audio of B
[B_x,~] = audioread('../2.data/5.imitation_data_for_automix/d3_087_phrase_shuffle-blues_simple_fast_sticks.wav');
% 3-1-2. splite B into right and left channel
B_x1 = B_x(:,1);
B_x2 = B_x(:,2);
clear B_x

% 3-2-1. STFT parameter
paramSTFT.numSamples = length(B_x1);
% 3-2-2. STFT computation
[~,A1,~] = forwardSTFT(B_x1,paramSTFT);
[~,A2,~] = forwardSTFT(B_x2,paramSTFT);
clear B_x1 B_x2

% 3-3-1. NMF parameter
paramNMF.costFunc = 'EucDist';%EucDist %KLDiv %ISDiv
paramNMF.numIter = 15;
paramNMF.numComp = i;
paramNMF.initH = ones(i,size(A1,2));
paramNMF.initW = initW;
clear initW
% 3-3-2. NMF computation
[~,~,nmfV1] = NMF(A1, paramNMF);
[~,~,nmfV2] = NMF(A2, paramNMF);
clear paramNMF

% 3-4. alpha-Wiener filtering
B1_magnitude_cell = alphaWienerFilter(A1,nmfV1,1);
B2_magnitude_cell = alphaWienerFilter(A2,nmfV2,1);
disp('complete B process')
clear A1 A2 nmfV1 nmfV2

%% learning process
% 4-1. compute avarage energy of A and B 
for k = 1:i
    A_avarage(k) = norm(A_magnitude_cell{k});
    B1_avarage(k) = norm(B1_magnitude_cell{k});
    B2_avarage(k) = norm(B2_magnitude_cell{k});
end
clear k B1_magnitude_cell B2_magnitude_cell

% 4-2. let A imitate B
for k = 1:i
    result1_A_cell{k} = A_magnitude_cell{k}.*(B1_avarage(k)/A_avarage(k));
    result2_A_cell{k} = A_magnitude_cell{k}.*(B2_avarage(k)/A_avarage(k));
end
disp('complete learning process')
clear A_magnitude_cell k B1_avarage B2_avarage A_avarage

%% resynthesize to audio
% 5-1. STFT parameter
paramSTFT.numSamples = length(A_audio_sum);

% 5-2. resynthesize
for k = 1:i 
    
    Y1 = result1_A_cell{k}.*exp(1i * A_phase_cell{k});
    y1 = inverseSTFT(Y1, paramSTFT);
    % create zeros matrix
    if k == 1
        y1_sum = zeros(size(y1));
        y2_sum = zeros(size(y1));
    end
    y1_sum = y1_sum+y1;
    
    Y2 = result2_A_cell{k}.*exp(1i * A_phase_cell{k});
    y2 = inverseSTFT(Y2, paramSTFT);
    y2_sum = y2_sum+y2;
end
clear k i paramSTFT Y1 Y2 y1 y2 result1_A_cell result2_A_cell A_phase_cell

% 5-3. normalize to +-1
y1_sum = y1_sum./max(abs(y1_sum));
y2_sum = y2_sum./max(abs(y2_sum));
% 5-4. save result
y = horzcat(y1_sum,y2_sum);
audiowrite('../3.output/automix_result.wav',y,fs);
clear y1_sum y2_sum