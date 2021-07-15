# dual_channel-NMF-for-drum-separation
This project containts the implementation of drum separation and evaluating the result of drum separation.

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
