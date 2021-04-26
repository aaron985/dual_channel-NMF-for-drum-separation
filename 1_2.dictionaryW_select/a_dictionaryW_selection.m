%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: dictionaryW_selection
% Date: April 2021
%
% Description :
% This program is for selecting dictionaryW accroding to which instruments
% you need to separate.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc

%%
% dictionaryW.mat input path
dictW_path = '../2.data/2.dictionaryW_mat/';

%%
% select what instruments do you need to separate
for instrument = {'BD','SD','HH','Tom1','Tom2','Floor Tom','Crash','Ride'}
    switch char(instrument)
        case 'BD'
            % select Bass Drum dictionaryW          
             Bass_Drum = {[dictW_path,'1.BD/DW_Collectors_Maple(24_16)']...
                         [dictW_path, '1.BD/Grestch_USA_Maple(22_16)']};            
            [BD,BD_len] = dictionaryW_slection_concatenation(Bass_Drum);
            clear Bass_Drum
            
        case 'SD'
            % select Snare Drum dictionaryW
             Snare_Drum = {[dictW_path,'2.SD/DW_Collectors Maple(14_6.5)']...
                          [dictW_path,'2.SD/Ludwig_Carl_Palmer_Venus(14_3.7)']};              
            [SD,SD_len] = dictionaryW_slection_concatenation(Snare_Drum);
            clear Snare_Drum
            
        case 'HH'
            % select HiHat dictionaryW
             HiHat = {[dictW_path,'3.HH/Meinl_Byzance_Brilliant_Fast(14)']
                     [dictW_path,'3.HH/Sabian_AAX_mini(12)']};      
            [HH,HH_len] = dictionaryW_slection_concatenation(HiHat);
            clear HiHat
            
        case 'Tom1'
            % select Tom1 dictionaryW
            Tom1 = {[dictW_path,'4.Tom1/DW_Collectors_Maple(10_9)']...
                    [dictW_path,'4.Tom1/Gretsch_USA_Maple(10_8)']};
            [T1,T1_len] = dictionaryW_slection_concatenation(Tom1);
            clear Tom1
            
        case 'Tom2'
            % select Tom2 dictionaryW
            Tom2 = {[dictW_path,'5.Tom2/DW_Collectors_Maple(12_10)']...
                    [dictW_path,'5.Tom2/Gretsch_USA_Maple(12_8)']};
            [T2,T2_len] = dictionaryW_slection_concatenation(Tom2);
            clear Tom2
            
        case 'Floor Tom'
            % select Floor Tom dictionaryW
            Floor_Tom = {[dictW_path,'6.Floor Tom/DW_Collectors_Maple(14_12)']...
                         [dictW_path,'6.Floor Tom/DW_Collectors_Maple(16_14)']...
						 [dictW_path,'6.Floor Tom/Gretsch_USA_Maple(14_14)']};
            [FT,FT_len] = dictionaryW_slection_concatenation(Floor_Tom);
            clear Floor_Tom
            
        case 'Crash'
            % select Crash dictionaryW
            Crash_Cymbal = {[dictW_path,'7.Crash/Bell_Paiste_Signature_Bell(8)']...
                            [dictW_path,'7.Crash/China_Meinl_Byzance_Brilliant(18)']...
                            [dictW_path,'7.Crash/Splash_Meinl_Byzance_Brilliant(8)']...
                            [dictW_path,'7.Crash/Stack_Paiste_Meinl_Stack(12_14)']};
            [Crash,Crash_len] = dictionaryW_slection_concatenation(Crash_Cymbal);
            clear Crash_Cymbal
            
        case 'Ride'
            % select Crash dictionaryW
            Ride_Cymbal = {[dictW_path,'8.Ride/Meinl_MB_10_Bell_Blast_Ride(20)']...
                            [dictW_path,'8.Ride/Paiste_2002(22)']};
            [Ride,Ride_len] = dictionaryW_slection_concatenation(Ride_Cymbal);
            clear Ride_Cymbal
    end
end

%%
% concatenate all instruments dictionaryW
dictionaryW = horzcat(BD,SD,HH,T1,T2,FT,Crash,Ride);

% all instruments dictionaryW's length
dictionaryW_length = {'BD', 'SD', 'HH','Tom1','Tom2','Floor Tom','Crash', 'Ride'; BD_len, SD_len, HH_len,T1_len,T2_len,FT_len,Crash_len,0};

% Save result
save('dictionaryW.mat','dictionaryW')
save('dictionaryW_length.mat','dictionaryW_length')