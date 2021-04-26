%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: dual channel NMF
% Date: April 2021
%
% Description :
% This program is for drum separation with NMF and NMFD. The sources are
% drum overhead microphones. We are going to separate bass drum, sanre
% drum, Hihat, tom1, tom2, floor tom, crash cymbal and ride cymbal.
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

% scan all source audio
filename = dir('../2.data/3.separation_data/*.wav');
%%
% 1-1 read source audio
for i = 1:2:length(filename)
    i
    [x_R,fs] = audioread(['../2.data/3.separation_data/',filename(i+1).name]);
    [x_L,~] = audioread(['../2.data/3.separation_data/',filename(i).name]);
    % 1-2 let x_R and x_L the same length
    if length(x_R)<length(x_L)
        x_L = x_L(1:length(x_R),:);
    elseif length(x_R)>length(x_L)
        x_R = x_R(1:length(x_L),:);
    end
    
    %%
    % 2-1 STFT parameter
    paramSTFT.blockSize = 2048;
    paramSTFT.hopSize = 256;
    paramSTFT.winFunc = hann(paramSTFT.blockSize);
    paramSTFT.reconstMirror = true;
    paramSTFT.appendFrame = true;
    paramSTFT.numSamples = length(x_R);
    
    % 2-2 STFT computation
    [X_R,A_R,P_R] = forwardSTFT(x_R,paramSTFT);
    [~,A_L,P_L] = forwardSTFT(x_L,paramSTFT);
    clear x_R x_L
    
    % 2-3 compute the proportion db of two channel
    db_r = sum(mag2db(sum(A_R,2)),1)/size(A_R,1);
    db_l = sum(mag2db(sum(A_L,2)),1)/size(A_L,1);
    db_R = (db_r/(db_r+db_l));
    db_L = (db_l/(db_r+db_l));
    clear db_r db_l
    
    %%
    % 3.get dimensions and time and freq resolutions
    [numBins,numFrames] = size(X_R);
    deltaT = paramSTFT.hopSize / fs;
    deltaF = fs / paramSTFT.blockSize;
    clear X_R
    
    %% dual channel NMF parameters
    % 4-1. computer NMF components number
    load dictionaryW_length.mat
    numComp = sum([dictionaryW_length{2,:}]);
    % 4-2. NMF common parameters
    numIter = 15;
    numTemplateFrames = 64;
    % 4-3. NMF initialW
    initW = importdata('./dictionaryW.mat');
    % 4-4. NMF initial H
    paramActivations.numComp = numComp;
    paramActivations.numFrames = numFrames;
    initH = initActivations(paramActivations,'uniform');
    clear paramActivations
    % 4-5. convert initial W and H to single and gpu Array
    initW = gpuArray(single(initW));
    initH = gpuArray(single(initH));
    
    % 4-6.NMF parameter
    paramNMF.costFunc = 'EucDist';%EucDist %KLDiv %ISDiv
    paramNMF.numIter = numIter;
    paramNMF.numComp = numComp;
    paramNMF.initW = initW;
    paramNMF.initH = initH;
    paramNMF.Hthreshold = 1e-8;
    clear initH initW
    
    %% dual channel NMF
    % 5-1. Update HR and HL
    [WR,HR] = NMF(A_R,paramNMF);
    [WL,HL] = NMF(A_L,paramNMF);
    
    % 5-2. update u, WR and WL
    u = eye(numComp)+0.0001;
    Wr = WR';
    WR = WR';
    WL = WL';
    %
    paramNMF.initW = u;
    paramNMF.initH = WR;
    [u,WR] = NMF(WL,paramNMF);
    paramNMF.initW = u;
    paramNMF.initH = WL;
    [u,WL] = NMF(Wr,paramNMF);
    %
    WR = WR';
    WL = WL';
    clear Wr
    
    % 5-3. update HL, WL, HR, WR
    paramNMF.initW = WR;
    paramNMF.initH = HR;
    [WR,HR] = NMF(A_R,paramNMF);
    paramNMF.initW = WL;
    paramNMF.initH = HL;
    [WL,HL] = NMF(A_L,paramNMF);
    disp('complete dual channel NMF')
    clear paramNMF
    
    %% NMFD for separating right channel
    % 6-1. save right channel initial W after dual channel NMF
    dictW = WR;
    save ./dictW.mat dictW;
    clear WR dictW
    % 6-2. initial W for NMFD
    paramTemplates.deltaF = deltaF;
    paramTemplates.numComp = numComp;
    paramTemplates.numBins = numBins;
    paramTemplates.numTemplateFrames = numTemplateFrames;
    initW = initTemplates(paramTemplates,'drums');
    clear numBins
    
    % 6-3. NMFD parameter
    paramNMFD.numComp = numComp;
    paramNMFD.numIter = numIter;
    paramNMFD.numFrames = numFrames;
    paramNMFD.numTemplateFrames = numTemplateFrames;
    paramNMFD.initW = initW;
    paramNMFD.initH = HR;
    clear numFrames numTemplateFrames initW HR numComp numIter
    % 6-4. NMFD
    [WR,HR,nmfdV_R] = NMFD(A_R,paramNMFD);
    disp('complete right channel NMFD')
    
    %% right channel alpha-Wiener filtering
    % 7-1.alpha-Wiener filtering
    nmfdV_R = cellfun(@gather, nmfdV_R, 'uniformOutput', false);
    nmfdA_R = alphaWienerFilter(A_R,nmfdV_R,1);
    clear nmfdV_R
    disp('complete right channel alpha Wiener filter')
    
    %% right channel visualize
    % 8-1 convert to cpu array
    WR = cellfun(@gather, WR, 'uniformOutput', false);
    HR = gather(HR);
    % 8-2. visualize parameter
    paramVis.deltaT = deltaT;
    paramVis.deltaF = deltaF;
    paramVis.endeSec = 15;
    paramVis.fontSize = 14;
    % 8-3 generate plot
    visualizeComponentsNMF(A_R, WR, HR, nmfdA_R, paramVis);
    % 8-4 save plot
    saveas(gcf,['../3.output/',filename(i+1).name(1:end-4),'.png'])
    close(gcf)
    clear A_R WR HR deltaT deltaF
    
    %%  NMFD for separating left channel
    % 6-1. save left channel initial W after dual channel NMF
    dictW = WL;
    save ./dictW.mat dictW;
    clear WR dictW
    % 6-2. initial W for NMFD
    initW = initTemplates(paramTemplates,'drums');
    clear paramTemplates
    delete dictW.mat
    
    % 6-3. NMFD parameter
    paramNMFD.initW = initW;
    paramNMFD.initH = HL;
    clear initW HL
    % 6-4. NMFD
    [WL,HL,nmfdV_L] = NMFD(A_L,paramNMFD);
    disp('complete left channel NMFD')
    
    %% left channel alpha-Wiener filtering
    % 7. alpha-Wiener filtering
    nmfdV_L = cellfun(@gather, nmfdV_L, 'uniformOutput', false);
    nmfdA_L = alphaWienerFilter(A_L,nmfdV_L,1);
    clear nmfdV_L
    disp('complete left channel alpha Wiener filter')
    
    %% left channel visualize
    % 8-1 convert to cpu array
    WL = cellfun(@gather, WL, 'uniformOutput', false);
    HL = gather(HL);
    % 8-2. visualize parameter
    % same as right channel 8-2
    % 8-3 generate plot
    visualizeComponentsNMF(A_L, WL, HL, nmfdA_L, paramVis);
    clear paramVis
    % 8-4 save plot
    saveas(gcf,['../3.output/',filename(i).name(1:end-4),'.png'])
    close(gcf)
    clear A_L WL HL
    
    %%
    % 9. resynthesize(combine right and left channel)
    for instrument = dictionaryW_length(1,:)
        %empty matrix
        y_sum_R = zeros(paramSTFT.numSamples,1);
        y_sum_L = zeros(paramSTFT.numSamples,1);
        
        switch char(instrument)
            case 'BD'
                if dictionaryW_length{2,1} ~= 0
                    BD_R = resynthesize(y_sum_R, nmfdA_R, P_R, paramSTFT, 1, dictionaryW_length{2,1});
                    BD_L = resynthesize(y_sum_L, nmfdA_L, P_L, paramSTFT, 1, dictionaryW_length{2,1});
                    BD = BD_R*db_R+BD_L*db_L;
                    BD = BD/max(abs(BD));
                    audiowrite(['../3.output/',filename(i).name(1:end-8),'_1.BD','.wav'],BD, fs);
                    clear BD_R BD_L BD y_sum_R y_sum_L
                else
                    continue
                end
            case 'SD'
                if dictionaryW_length{2,2} ~= 0
                    SD_R = resynthesize(y_sum_R, nmfdA_R, P_R, paramSTFT, dictionaryW_length{2,1}+1, sum([dictionaryW_length{2,1:2}]));
                    SD_L = resynthesize(y_sum_L, nmfdA_L, P_L, paramSTFT, dictionaryW_length{2,1}+1, sum([dictionaryW_length{2,1:2}]));
                    SD = SD_R*db_R+SD_L*db_L;
                    SD = SD/max(abs(SD));
                    audiowrite(['../3.output/',filename(i).name(1:end-8),'_2.SD','.wav'],SD, fs);
                    clear SD_R SD_L SD y_sum_R y_sum_L
                else
                    continue
                end
            case 'HH'
                if dictionaryW_length{2,3} ~= 0
                    HH_R = resynthesize(y_sum_R, nmfdA_R, P_R, paramSTFT, sum([dictionaryW_length{2,1:2}])+1, sum([dictionaryW_length{2,1:3}]));
                    HH_L = resynthesize(y_sum_L, nmfdA_L, P_L, paramSTFT, sum([dictionaryW_length{2,1:2}])+1, sum([dictionaryW_length{2,1:3}]));
                    HH = HH_R*db_R+HH_L*db_L;
                    HH = HH/max(abs(HH));
                    audiowrite(['../3.output/',filename(i).name(1:end-8),'_3.HH','.wav'],HH, fs);
                    clear HH_R HH_L HH y_sum_R y_sum_L
                else
                    continue
                end
            case 'Tom1'
                if dictionaryW_length{2,4} ~= 0
                    T1_R = resynthesize(y_sum_R, nmfdA_R, P_R, paramSTFT, sum([dictionaryW_length{2,1:3}])+1, sum([dictionaryW_length{2,1:4}]));
                    T1_L = resynthesize(y_sum_L, nmfdA_L, P_L, paramSTFT, sum([dictionaryW_length{2,1:3}])+1, sum([dictionaryW_length{2,1:4}]));
                    T1 = T1_R*db_R+T1_L*db_L;
                    T1 = T1/max(abs(T1));
                    audiowrite(['../3.output/',filename(i).name(1:end-8),'_4.T1','.wav'],T1, fs);
                    clear T1_R T1_L T1 y_sum_R y_sum_L
                else
                    continue
                end
            case 'Tom2'
                if dictionaryW_length{2,5} ~= 0
                    T2_R = resynthesize(y_sum_R, nmfdA_R, P_R, paramSTFT, sum([dictionaryW_length{2,1:4}])+1, sum([dictionaryW_length{2,1:5}]));
                    T2_L = resynthesize(y_sum_L, nmfdA_L, P_L, paramSTFT, sum([dictionaryW_length{2,1:4}])+1, sum([dictionaryW_length{2,1:5}]));
                    T2 = T2_R*db_R+T2_L+db_L;
                    T2 = T2/max(abs(T2));
                    audiowrite(['../3.output/',filename(i).name(1:end-8),'_5.T2','.wav'],T2, fs);
                    clear T2_R T2_L T2 y_sum_R y_sum_L
                else
                    continue
                end
            case 'Floor Tom'
                if dictionaryW_length{2,6} ~= 0
                    FT_R = resynthesize(y_sum_R, nmfdA_R, P_R, paramSTFT, sum([dictionaryW_length{2,1:5}])+1, sum([dictionaryW_length{2,1:6}]));
                    FT_L = resynthesize(y_sum_L, nmfdA_L, P_L, paramSTFT, sum([dictionaryW_length{2,1:5}])+1, sum([dictionaryW_length{2,1:6}]));
                    FT = FT_R*db_R+FT_L*db_L;
                    FT = FT/max(abs(FT));
                    audiowrite(['../3.output/',filename(i).name(1:end-8),'_6.FT','.wav'],FT, fs);
                    clear FT_R FT_L FT y_sum_R y_sum_L
                else
                    continue
                end
            case 'Crash'
                if dictionaryW_length{2,7} ~= 0
                    Crash_R = resynthesize(y_sum_R, nmfdA_R, P_R, paramSTFT, sum([dictionaryW_length{2,1:6}])+1, sum([dictionaryW_length{2,1:7}]));
                    Crash_L = resynthesize(y_sum_L, nmfdA_L, P_L, paramSTFT, sum([dictionaryW_length{2,1:6}])+1, sum([dictionaryW_length{2,1:7}]));
                    Crash = Crash_R*db_R+Crash_L+db_L;
                    Crash = Crash/max(abs(Crash));
                    audiowrite(['../3.output/',filename(i).name(1:end-8),'_7.Crash','.wav'],Crash, fs);
                    clear Crash_R Crash_L Crash y_sum_R y_sum_L
                else
                    continue
                end
            case 'Ride'
                if dictionaryW_length{2,8} ~= 0
                    Ride_R = resynthesize(y_sum_R, nmfdA_R, P_R, paramSTFT, sum([dictionaryW_length{2,1:7}])+1, sum([dictionaryW_length{2,1:8}]));
                    Ride_L = resynthesize(y_sum_L, nmfdA_L, P_L, paramSTFT, sum([dictionaryW_length{2,1:7}])+1, sum([dictionaryW_length{2,1:8}]));
                    Ride = Ride_R*db_R+Ride_L+db_L;
                    Ride = Ride/max(abs(Ride));
                    audiowrite(['../3.output/',filename(i).name(1:end-8),'_8.Ride','.wav'],Ride, fs);
                    clear Ride_R Ride_L Ride y_sum_R y_sum_L
                else
                    continue
                end
                
        end
    end
end