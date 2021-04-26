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

% scan all source audio
filename = dir('../2.data/3.separation_data/*.wav');
% separation mythed
type1 = 'dual channel NMF_result';
% cost funtion of drum separation
type2 = 'Euclidean'; %Euclidean, Itakura Saito, KL

%%
A = {};
for i = 1:2:length(filename)
    i
    
    % 1. read estimated sources
    x_e_BD = audioread(['../3.output/',type1,'/',type2,'/',filename(i).name(1:end-8),'_1.BD','.wav']);
    x_e_SD = audioread(['../3.output/',type1,'/',type2,'/',filename(i).name(1:end-8),'_2.SD','.wav']);
    x_e_HH = audioread(['../3.output/',type1,'/',type2,'/',filename(i).name(1:end-8),'_3.HH','.wav']);
    x_e_T1 = audioread(['../3.output/',type1,'/',type2,'/',filename(i).name(1:end-8),'_4.T1','.wav']);
    x_e_T2 = audioread(['../3.output/',type1,'/',type2,'/',filename(i).name(1:end-8),'_5.T2','.wav']);
    x_e_FT = audioread(['../3.output/',type1,'/',type2,'/',filename(i).name(1:end-8),'_6.FT','.wav']);
    x_e = horzcat(x_e_BD,x_e_SD,x_e_HH,x_e_T1,x_e_T2,x_e_FT);
    clear x_e_BD x_e_SD x_e_HH x_e_T1 x_e_T2 x_e_FT
    x_e = x_e';
    
    %2. read ture sources
    x_t_BD = audioread(['../2.data/4.bss_true_source_data/',filename(i).name(1:end-8),'_1.BD','.wav']);
    x_t_SD = audioread(['../2.data/4.bss_true_source_data/',filename(i).name(1:end-8),'_2.SD','.wav']);
    x_t_HH = audioread(['../2.data/4.bss_true_source_data/',filename(i).name(1:end-8),'_3.HH','.wav']);
    x_t_T1 = audioread(['../2.data/4.bss_true_source_data/',filename(i).name(1:end-8),'_4.T1','.wav']);
    x_t_T2 = audioread(['../2.data/4.bss_true_source_data/',filename(i).name(1:end-8),'_5.T2','.wav']);
    x_t_FT = audioread(['../2.data/4.bss_true_source_data/',filename(i).name(1:end-8),'_6.FT','.wav']);
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
    % tag the filename 
    report{length(report)+1,1} = filename(i).name(1:end-8);
    % concatenate all result
    A = horzcat(A,report);
end

% 5. save the result
writecell(A, ['../3.output/',type1,'_eval','_',type2,'.csv']);