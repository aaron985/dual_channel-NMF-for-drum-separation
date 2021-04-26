function [sum] = resynthesize(y_sum, nmfdA, P, paramSTFT, startP, endP)
%%% Input :
%%%         y_sum:     y_sum is empty matrix
%%%         nmfdA:     nmfdA is a cell-array of extracted source spectrograms from Wiener Filter
%%%         P:         P is the phase spectrogram (wrapped in -pi ... +pi) from STFT
%%%         startP:    startP is 'start point' of each instrument from pre-extractW
%%%         endP:      endP is 'end point' of each instrument from pre-extractW
%%% Output :
%%%         sum:       sum is sumup of every instrument's y

sum = y_sum;
for k = startP : endP
    Y = nmfdA{k} .* exp(1i * P);
    % re-synthesize, omitting the Griffin Lim iterations
    y = inverseSTFT(Y, paramSTFT);
    y = y/max(abs(y));
    %sum
    sum = sum+y;
end
%normalize y_sum to +-1
sum = sum/max(abs(sum));