%% Prepare workspace

clc;
clear all;

%% Geenrate trajectories

trial_len = 120; %s
Fs        = 1000; % Hz downsampled for quickness

no_trials = 10;

trajectory_data = struct;

rng(11);

dt = 1/Fs;
t = 0:1:(Fs * trial_len) - 1;
t = t * dt;

for i = 1:1:no_trials*2
    
    trial_no = ceil(i/2);
    
    w = 0:0.5:30; % deg/s
    a = gausswin(length(w), 10);
    phi = rand(1, length(w)) * 360;
    
    trajectory = zeros(1, length(t));
    
    for j = 1:1:length(w)
        trajectory = trajectory + a(j) * cosd(w(j) * t + phi(j));
    end
    
    min_t = min(trajectory);
    max_t = max(trajectory);
    
    trajectory = (trajectory - min_t) * (1/(max_t - min_t)) * 180;
    L = tukeywin(length(t), 0.1);
    trajectory = trajectory';
    
    if mod(i, 2) == 0
        trajectory = L.*trajectory;
        trajectory_data = setfield(trajectory_data, "Trial_" + string(trial_no) + "_B" ,trajectory);
    else
        trajectory = 180 - L.*trajectory;
        trajectory_data = setfield(trajectory_data, "Trial_" + string(trial_no) + "_A" ,trajectory);
    end
    
end

%% For further processing

save('trajectory_data_all_trials_1000Hz', 'trajectory_data');

%% Plot trajectories

trial_no = 2;

figure('Position', [10 10 2000 1200]);

for i = 1:1:2
    
    subplot(2, 1, i);
    
    if i == 1
        trajectory = trajectory_data.("Trial_" + string(trial_no) + "_A");
    elseif i == 2
        trajectory = trajectory_data.("Trial_" + string(trial_no) + "_B"); 
    end
    N = length(trajectory);
    
    ang_vel = string(int32(mean( abs(trajectory(2:N) - trajectory(1:N-1))   /dt)));
    
    
    plot(t, trajectory, 'linewidth', 2, 'DisplayName', strcat("Trial_" + string(trial_no) + "_A", " - ", ang_vel, " degrees/s")); 
    ylabel("Azimuthal Angle", 'FontSize', 15, 'FontWeight', 'bold');
    xlabel("Time [in s]", 'FontSize', 15, 'FontWeight', 'bold');

    set(gca,'FontSize', 15);
%     title('Trajectory of Sound Sources', 'FontSize', 15, 'FontWeight', 'bold');
    legend('FontSize', 13, 'FontWeight', 'bold', 'Location', 'best', 'Interpreter', 'none');
    xlim([0, 120]);
    grid on;
    
end

%% Plot some histograms

%% Single trial

trial_no = 1;
plot_2d_hist(trajectory_data.("Trial_" + string(trial_no) + "_A"), trajectory_data.("Trial_" + string(trial_no) + "_B"), "Conv A", "Conv B", "Trial: " + string(trial_no))

%% All trials

ConvA_Locs = [];
ConvB_Locs = [];

for trial_no = 1:1:10
    
    this_A = trajectory_data.("Trial_" + string(trial_no) + "_A");
    this_B = trajectory_data.("Trial_" + string(trial_no) + "_B");
    
    ConvA_Locs = [ConvA_Locs; this_A ];
    ConvB_Locs = [ConvB_Locs; this_B ];
    
end

plot_2d_hist(ConvA_Locs, ConvB_Locs, "Conv A", "Conv B", "All trials")

%% Function to generate 2-D Histogram

function plot_2d_hist(x, y, label_x, label_y, title_name)

    X = [x, y];
    figure('Position', [10 10 1200 1200]);
%     hist3(X, 'Nbins', [20, 20]);
    hist3(X, 'Nbins', [20, 20], 'CDataMode', 'auto', 'FaceColor', 'interp');
    [N, c] = hist3(X, 'Nbins', [20, 20], 'CDataMode', 'auto', 'FaceColor', 'interp');
    xlabel(label_x);
    ylabel(label_y);
    colorbar
%     view(2)
    title(title_name)
    set(gca,'FontSize', 15, 'FontWeight', 'bold');
%     xlim([20 180]);
%     ylim([20 180]);
%     axis equal;

    figure('Position', [10 10 1200 1200]);
    
    % Clipping
    thresh = 10000;
    N(N>thresh) = thresh;
    
    imagesc(c{1}([1 end]),c{2}([1 end]),N');
    xlabel(label_x);
    ylabel(label_y);
    colorbar
    set(gca,'FontSize', 15, 'FontWeight', 'bold');
    title(title_name + " (thresholded)")
    xlim([-10 190]);
    ylim([-10 190]);
    axis xy equal
    
    
end