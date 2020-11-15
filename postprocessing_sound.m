%% Reading the output

out = readmatrix("output.csv");

%% Extracting L and R Channels

L_idx = 1:2:length(out);
R_idx = 2:2:length(out);

L = out(L_idx);
R = out(R_idx);

%% Writing audio file

audio_mat = [L R];
Fs = 44100;

audiowrite("Final_44100.wav", audio_mat, Fs);