%% This script is to preprocess the monophonic sound files and generate trajectories

%% Loading sound files

environment  = 'SamplesCheck';
sound_files = ["male", "female", "male_kid", "female_kid"];

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

%% Writing processed sound files

for i = 1:1:length(sound_files)
    
    writepath = "ToCPP/";
    
    y = sound_data.(sound_files(i));
    audiowrite(strcat(writepath, "Processed_", sound_files(i), ".wav"), y, Fs);
    
end

%% Generating trajectories

trajectory_data = struct;

rng(11);

for i = 1:1:length(sound_files)
    
    y = sound_data.(sound_files(i));
    dt = 1/Fs;
    t = 0:1:length(y) - 1;
    t = t * dt;
    
    w = 0:15:90;
    phi = rand(1, length(w)) * 360;
    
    trajectory = zeros(1, length(y));
    
    
    for j = 1:1:length(w)
        trajectory = trajectory + cosd(w(j) * t + phi(j));
    end
    
    min_t = min(trajectory);
    max_t = max(trajectory);
    
    trajectory = (trajectory - min_t) * (1/(max_t - min_t)) * 180;
    trajectory_data = setfield(trajectory_data, sound_files(i), trajectory);
    
end

%% Determining x_lim

min_len = 0;

for i = 1:1:length(sound_files)
    
    y = sound_data.(sound_files(i));
    
    if i == 1
        min_len = length(y);
    elseif length(y) < min_len
        min_len = length(y);
    end
    
end


%% Plotting trajectories

figure('Position', [10 10 2000 1200]);

for i = 1:1:length(sound_files)
    
    subplot(length(sound_files), 1, i);
    
    y = sound_data.(sound_files(i));
    dt = 1/Fs;
    t = 0:1:length(y) - 1;
    t = t * dt;
    
    trajectory = trajectory_data.(sound_files(i));
    N = length(trajectory);
    
    ang_vel = string(int32(mean( abs(trajectory(2:N) - trajectory(1:N-1))   /dt)));
    
    
    plot(t, trajectory, 'linewidth', 2, 'DisplayName', strcat(sound_files(i), " - ", ang_vel, " degrees/s")); 
    ylabel("Azimuthal Angle", 'FontSize', 15, 'FontWeight', 'bold');
    xlabel("Time [in s]", 'FontSize', 15, 'FontWeight', 'bold');

    set(gca,'FontSize', 15);
%     title('Trajectory of Sound Sources', 'FontSize', 15, 'FontWeight', 'bold');
    legend('FontSize', 13, 'FontWeight', 'bold', 'Location', 'best', 'Interpreter', 'none');
    xlim([0, t(min_len)]);
    grid on;
    
end

%% Processing trajectories

d = 5; % metres

%% Writing out processed sound files and trajectories in CSV

for i = 1:1:length(sound_files)
   
    writepath = "ToCPP/";
    
    y = sound_data.(sound_files(i));
    writematrix(y, strcat(writepath, sound_files(i), "_", string(Fs), ".csv"));
    
    trajectory = trajectory_data.(sound_files(i));
    trajectory = trajectory';
    
    buffer_size = 512;
    
    idx = 1:buffer_size:length(y);
    
    trajectory_comp = trajectory(idx);
    
    xyz_data = zeros(length(trajectory_comp), 3);
    
    for j = 1:1:length(trajectory_comp)
        
        xyz_data(j, 1) = d * cosd(trajectory_comp(j)); % x 
        xyz_data(j, 2) = 0; % y
        xyz_data(j, 3) = -d * sind(trajectory_comp(j)); % z
        
    end
   
    writematrix(xyz_data, strcat(writepath, sound_files(i), "_", "xyz", ".csv"));
    
end
