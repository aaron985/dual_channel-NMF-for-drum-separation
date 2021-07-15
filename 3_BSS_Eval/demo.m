%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: bss evaluation
% Date: April 2021
%
% Description :
% This program is for evaluating the qualities of drum separation.
%
% References:
% Emmanuel Vincent, Rémi Gribonval, and Cédric Févotte,
%   "Performance measurement in blind audio source separation," IEEE Trans. on Audio,
%   Speech and Language Processing, 14(4):1462-1469, 2006.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc

% separation method
method = '1_1_dual_channel_NMF_for_drum_separation';

%%
% 1. read estimated sources
x_e_BD = audioread(['../',method,'/output/1_BD.wav',]);
x_e_SD = audioread(['../',method,'/output/2_SD.wav',]);
x_e_HH = audioread(['../',method,'/output/3_HH.wav',]);
x_e_T1 = audioread(['../',method,'/output/4_T1.wav',]);
x_e_T2 = audioread(['../',method,'/output/5_T2.wav',]);
x_e_FT = audioread(['../',method,'/output/6_FT.wav',]);
x_e = horzcat(x_e_BD,x_e_SD,x_e_HH,x_e_T1,x_e_T2,x_e_FT);
clear x_e_BD x_e_SD x_e_HH x_e_T1 x_e_T2 x_e_FT
x_e = x_e';

%2. read ture sources (ground truth)
x_t_BD = audioread('input_data/1_BD_ground_truth.wav');
x_t_SD = audioread('input_data/2_SD_ground_truth.wav');
x_t_HH = audioread('input_data/3_HH_ground_truth.wav');
x_t_T1 = audioread('input_data/4_T1_ground_truth.wav');
x_t_T2 = audioread('input_data/5_T2_ground_truth.wav');
x_t_FT = audioread('input_data/6_TF_ground_truth.wav');
x_t = horzcat(x_t_BD,x_t_SD,x_t_HH,x_t_T1,x_t_T2,x_t_FT);
clear x_t_BD x_t_SD x_t_HH x_t_T1 x_t_T2 x_t_FT
x_t = x_t';

% 3. BSS Eval
[SDR,SIR,SAR] = bss_eval_sources(x_e, x_t);

% 4. generate report
report = {"BD_SAR",SAR(1);"BD_SDR",SDR(1);"BD_SIR",SIR(1);...
    "SD_SAR",SAR(2);"SD_SDR",SDR(2);"SD_SIR",SIR(2);...
    "HH_SAR",SAR(3);"HH_SDR",SDR(3);"HH_SIR",SIR(3);...
    "T1_SAR",SAR(4);"T1_SDR",SDR(4);"T1_SIR",SIR(4);...
    "T2_SAR",SAR(5);"T2_SDR",SDR(5);"T2_SIR",SIR(5);...
    "FT_SAR",SAR(6);"FT_SDR",SDR(6);"FT_SIR",SIR(6)};