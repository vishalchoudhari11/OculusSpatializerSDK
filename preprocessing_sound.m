%% This script is to preprocess the monophonic sound files and generate trajectories

%% Loading sound files

environment  = 'NewsSetting';
sound_files = ["Host", "Male1", "Male2", "Female1", "Female2"];

sound_data  = struct;

path = strcat("SoundSamples/", environment, "/");

for i = 1:1:length(sound_files)
    
    [y, Fs] = audioread(strcat(path, sound_files(i), ".wav"));
    sound_data = setfield(sound_data, sound_files(i), y);
    
end

%% Normalise their power

energies_pre_normalising  = zeros(1, length(sound_files));
energies_post_normalising = zeros(1, length(sound_files));

max_abs                   = zeros(1, length(sound_files));

for i = 1:1:length(sound_files)
    
    y = sound_data.(sound_files(i));
    energies_pre_normalising(i) = 1/length(y) * sum(y.^2);
    y = y/sqrt(energies_pre_normalising(i));
    energies_post_normalising(i) = 1/length(y) * sum(y.^2);
    
    sound_data = setfield(sound_data, sound_files(i), y);
    max_abs(i) = max(abs(y));
    
end

%% Scaling to ensure all sound samples take values from -1 to 1

scale_factor = max(max_abs);
energies_post_scaling = zeros(1, length(sound_files));

for i = 1:1:length(sound_files)
   
    y = sound_data.(sound_files(i));
    y = y/scale_factor;
    energies_post_scaling(i) =  1/length(y) * sum(y.^2);
    
    sound_data = setfield(sound_data, sound_files(i), y);
    
end

%% Generating trajectories

