%% Reading the output

readpath = "FromCPP/";
filename = "male+female+malePolish";
out = readmatrix(strcat(readpath, filename, ".csv"));

%% Extracting L and R Channels

% Normalising 

out = out/max(abs(out));

L_idx = 1:2:length(out);
R_idx = 2:2:length(out);

L = out(L_idx);
R = out(R_idx);

%% Writing audio file

writepath = "Spatialized/";

audio_mat = [L R];
Fs = 44100;

audiowrite(strcat(writepath, filename, ".wav"), audio_mat, Fs);