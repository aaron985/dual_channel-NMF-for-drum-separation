# dual_channel-NMF-for-drum-separation
This project containts the implementation of drum separation and evaluating the result of drum separation.

C. -Y. Cai, Y. -H. Su and L. Su, "Dual-channel Drum Separation for Low-cost Drum Recording Using Non-negative Matrix Factorization," 2021 Asia-Pacific Signal and Information Processing Association Annual Summit and Conference (APSIPA ASC), 2021, pp. 17-22.

## 1_1_dual_channel_NMF_for_drum_separation
This program is running with GPU. In dual-channel framework, we consider using NMFD for drum separation, and its initial template and activation matrices are estimated using NMF over the magnitude spectrogram of the training data.

1. replace the input source in input forlder
2. run demo.m

## 1_2_single_channel_NMF_for_drum_separation
This program is running with GPU. In single channel framework, we consider using NMFD for drum separation, but its initial template and activation matrices are not estimated using NMF.

1. replace the input source in input forlder
2. run demo.m

## 1_3_dual_channel_score_informed_NMF_for_drum_separation
This program is running with GPU. In score informed framework, drum separation, initial template and activation estimating are the same as dual-channel framework. The difference is the initial template and activation estimating are updated with onsets and drum type annotations.

In drums.txt, the number 1 to 9 stand for each instrument.
- 1：Bass Drum
- 2：Snare drum
- 3：Closed hi-hat
- 4：open hi-hat
- 5：Tom-tom 1
- 6：Tom-tom 2
- 7：Floor tom
- 8：Crash cymbal
- 9：Ride cymbal

1. replace the input source in input forlder
2. replare the annotations in input forlder
3. run demo.m

## 2_panning_imitation_for_drum_automix
Panning imitation is the task to estimate the panning level of each instrument in the input signal as well as in a wellrecorded drum set signal, such that the panning condition of the input can be converted to the wellrecorded one.

1. replace the drum separation result from 1_1, 1_2 or 1_3 in input forlder
2. replace the wet_mix, wellrecorded singal, in input forlder
3. run demo.m

## 3_BSS_Eval
We use the BSS Eval 3.0 toolkit to evaluate the performance of source separation and panning imitation.

1. replace the ground thuth in input forlder
2. run demo.m
