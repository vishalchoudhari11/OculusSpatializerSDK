%% Prepare workspace

clc;
clear all;

%% Parameters for trajectory generation

trial_len = 120;  %s
Fs        = 1000; % Hz downsampled for quickness for trajectory

no_trials = 10;

dt = 1/Fs;
t = 0:1:(Fs * trial_len) - 1;
t = t * dt;

%% Generate pairs of trajectories

LOAD = 1;

gap_durn    = 3; % s
gap_samples = Fs * gap_durn;

common_idx_start = gap_samples + 1;
common_idx_stop  = length(t);

no_pairs = 1000;

if LOAD ~= 1

    conv1_traj = zeros(no_pairs, length(t));
    conv2_traj = zeros(no_pairs, length(t));

    rng(11);

    pair_ctr = 1;

    while pair_ctr <= 1000

        w = 0:0.5:30; % deg/s
        a = gausswin(length(w), 10);

        % Conv 1

        phi = rand(1, length(w)) * 360;
        trajectory1 = zeros(1, length(t));

        for j = 1:1:length(w)
            trajectory1 = trajectory1 + a(j) * cosd(w(j) * t + phi(j));
        end

        trajectory1 = normalise_trajectory(trajectory1);

        % Conv 2

        phi = rand(1, length(w)) * 360;
        trajectory2 = zeros(1, length(t));

        for j = 1:1:length(w)
            trajectory2 = trajectory2 + a(j) * cosd(w(j) * t + phi(j));
        end

        trajectory2 = normalise_trajectory(trajectory2);

        % Check if meets criteria

        if abs(trajectory2(common_idx_start) - trajectory1(common_idx_start)) > 90

            conv1_traj(pair_ctr, :) = trajectory1;
            conv2_traj(pair_ctr, :) = trajectory2;

            fprintf("\n Found pair: %d/%d", pair_ctr, no_pairs);

            pair_ctr = pair_ctr + 1;

        end


    end
    
    save('trajectory_data_1000Hz_1000pairs.mat', 'conv1_traj', 'conv2_traj');
    
else
    
    load('trajectory_data_1000Hz_1000pairs.mat');
    
end

%% Visualise 10 of them (randomly sampled)

pairs_to_visualise = randi([1, 1000], 1, 10);
figure('Position', [10 10 2000 1200]);

for ctr = 1:1:10
    
    subplot(5, 2, ctr);
    
    idx = pairs_to_visualise(ctr);
    
    traj1 = conv1_traj(idx, :);
    traj2 = conv2_traj(idx, :);
    traj2 = traj2(common_idx_start : end);
    
    ang_vel1 = string(int32(mean( abs(traj1(2:end) - traj1(1:end-1)) /dt)));
    ang_vel2 = string(int32(mean( abs(traj2(2:end) - traj2(1:end-1)) /dt)));
    
    plot(t, traj1, 'linewidth', 2, 'DisplayName', strcat("IDX: " + string(idx) + ", Conv 1: ", ang_vel1, " degrees/s")); hold on;
    plot(t(common_idx_start:end), traj2, 'linewidth', 2, 'DisplayName', strcat("IDX: " + string(idx) + ", Conv 2: ", ang_vel2, " degrees/s")); hold on;
    xline(t(common_idx_start), '--k', 'linewidth', 2, 'HandleVisibility','off');
    legend('FontSize', 13, 'FontWeight', 'bold', 'Location', 'best', 'Interpreter', 'none');
    
    ylim([0 180]);
    
    if ctr == 9 || ctr == 10
        xlabel("Time [in s]", 'FontSize', 10, 'FontWeight', 'bold');
        ylabel("Azimuthal Angle", 'FontSize', 10, 'FontWeight', 'bold');
    end
    
end

%% Calculate joint histograms, joint entropies and average veloctites

velo1_traj = zeros(no_pairs, 1);
velo2_traj = zeros(no_pairs, 1);

joint_entropy = zeros(no_pairs, 1);

for ctr = 1:1:no_pairs
    
    traj1 = conv1_traj(ctr, :);
    traj2 = conv2_traj(ctr, :);
    
    % Extract only that duration during which both conversations coexist
    
    traj1 = traj1(common_idx_start : end);
    traj2 = traj2(common_idx_start : end);
    
    % Extract velocities
    
    ang_vel1 = string(int32(mean( abs(traj1(2:end) - traj1(1:end-1)) /dt)));
    ang_vel2 = string(int32(mean( abs(traj2(2:end) - traj2(1:end-1)) /dt)));
    
    velo1_traj(ctr) = ang_vel1;
    velo2_traj(ctr) = ang_vel2;
    
    % Calculate the joint histogram
    
    Xedges = 0:10:180;
    Yedges = 0:10:180;
    
    N = histcounts2(traj1, traj2, Xedges, Yedges);
    this_je = calc_joint_entropy(N);
    
    joint_entropy(ctr) = this_je;
    
end

%% Visualise the histogram of joint entropies

figure;
entropy_hist = histogram(joint_entropy);
max_poss_entropy = calc_joint_entropy(ones(18, 18));
xline(max_poss_entropy, '--k', 'linewidth', 2, 'HandleVisibility','off');
xlabel("Joint Entropy", 'FontSize', 10, 'FontWeight', 'bold');
ylabel("Number of cases", 'FontSize', 10, 'FontWeight', 'bold');


%% Now obtain the top 10 pairs of trajectories with highest entropies

[sorted_joint_entropy, sorted_idxs] = sort(joint_entropy, 'descend');
top_10_idxs = sorted_idxs(1: 10);

%% Now obtain the top 5 and bottom 5 pairs of trajectories

remove_last = 10;
mix_5 = [sorted_idxs(1: 8); sorted_idxs(end-(1 + remove_last):end-(remove_last))];

%% Visualise these top 10 pairs of trajectories with highest entropies

% pairs_to_visualise = mix_5;
figure('Position', [10 10 2000 1200]);

for ctr = 1:1:10
    
    subplot(5, 2, ctr);
    
    idx = pairs_to_visualise(ctr);
    
    traj1 = conv1_traj(idx, :);
    traj2 = conv2_traj(idx, :);
    traj2 = traj2(common_idx_start : end);
    
    ang_vel1 = string(int32(mean( abs(traj1(2:end) - traj1(1:end-1)) /dt)));
    ang_vel2 = string(int32(mean( abs(traj2(2:end) - traj2(1:end-1)) /dt)));
    
    plot(t, traj1, 'linewidth', 2, 'DisplayName', strcat("IDX: " + string(idx) + ", Conv 1: ", ang_vel1, " degrees/s")); hold on;
    plot(t(common_idx_start:end), traj2, 'linewidth', 2, 'DisplayName', strcat("IDX: " + string(idx) + ", Conv 2: ", ang_vel2, " degrees/s")); hold on;
    xline(t(common_idx_start), '--k', 'linewidth', 2, 'HandleVisibility','off');
    legend('FontSize', 13, 'FontWeight', 'bold', 'Location', 'best', 'Interpreter', 'none');
    
    ylim([0 180]);
    
    if ctr == 9 || ctr == 10
        xlabel("Time [in s]", 'FontSize', 10, 'FontWeight', 'bold');
        ylabel("Azimuthal Angle", 'FontSize', 10, 'FontWeight', 'bold');
    end
    
end


%% Visualise their Bivariate Normalised Histograms one by one too 

% pairs_to_visualise = mix_5;

for ctr = 1:1:10
   
    idx = pairs_to_visualise(ctr);
    
    traj1 = conv1_traj(idx, :);
    traj2 = conv2_traj(idx, :);

    traj1 = traj1(common_idx_start : end);
    traj2 = traj2(common_idx_start : end);
    
    Xedges = 0:10:180;
    Yedges = 0:10:180;

    N = histcounts2(traj1, traj2, Xedges, Yedges);
    N = N/sum(N, 'all');

    figure('Name', 'Histogram ' + string(ctr), 'Position', [20 20 900 900]);
    imagesc(N);
    colormap(jet);
    colorbar;
    ticks = 0.5:1:18.5;
    xticks(ticks);
    yticks(ticks);
    xticklabels(Xedges);
    yticklabels(Yedges);
    set(gca,'XAxisLocation','top');
    ylabel("Trajectory 1");
    xlabel("Trajectory 2");
    title("IDX: " + string(idx) + ", Bivariate Normalised Histogram, H(\theta_1, \theta_2) = " + string(round(calc_joint_entropy(N), 2)), 'FontSize', 15);
    grid on;
    set(gca,'FontSize', 13);
    ax = gca;
    ax.GridLineStyle = '-';
    ax.GridColor = 'w';
    ax.GridAlpha = 1;% maximum line opacity
    
    
end

%% Vizualise cumulatively for the top10

% pairs_to_visualise = mix_5;

N_cum = zeros(18, 18);

for ctr = 1:1:10
    
    idx = pairs_to_visualise(ctr);
    
    traj1 = conv1_traj(idx, :);
    traj2 = conv2_traj(idx, :);

    traj1 = traj1(common_idx_start : end);
    traj2 = traj2(common_idx_start : end);
    
    Xedges = 0:10:180;
    Yedges = 0:10:180;

    N = histcounts2(traj1, traj2, Xedges, Yedges);
    N_cum = N_cum + N;
    
end

N_cum = N_cum/sum(N_cum, 'all');

figure('Name', 'Histogram Cumulative', 'Position', [20 20 900 900]);
imagesc(N_cum);
colormap(jet);
colorbar;
ticks = 0.5:1:18.5;
xticks(ticks);
yticks(ticks);
xticklabels(Xedges);
yticklabels(Yedges);
set(gca,'XAxisLocation','top');
ylabel("Trajectory 1");
xlabel("Trajectory 2");
title("Bivariate Normalised Histogram, H(\theta_1, \theta_2) = " + string(round(calc_joint_entropy(N_cum), 2)), 'FontSize', 15);
grid on;
set(gca,'FontSize', 13);
ax = gca;
ax.GridLineStyle = '-';
ax.GridColor = 'w';
ax.GridAlpha = 1;% maximum line opacity

%% Plotting a Bivariate Normalised Histogram

ctr = 100;

traj1 = conv1_traj(ctr, :);
traj2 = conv2_traj(ctr, :);

traj1 = traj1(common_idx_start : end);
traj2 = traj2(common_idx_start : end);

% traj1 = ones(1, length(traj1)) * 45;
% traj2 = ones(1, length(traj2)) * 165;

Xedges = 0:10:180;
Yedges = 0:10:180;

N = histcounts2(traj1, traj2, Xedges, Yedges);
N = N/sum(N, 'all');

figure('Name', 'Histogram', 'Position', [20 20 900 900]);
imagesc(N);
colormap(jet);
colorbar;
ticks = 0.5:1:18.5;
xticks(ticks);
yticks(ticks);
xticklabels(Xedges);
yticklabels(Yedges);
set(gca,'XAxisLocation','top');
ylabel("Trajectory 1");
xlabel("Trajectory 2");
title("Bivariate Normalised Histogram, H(\theta_1, \theta_2) = " + string(round(calc_joint_entropy(N), 2)), 'FontSize', 15);
grid on;
set(gca,'FontSize', 13);
ax = gca;
ax.GridLineStyle = '-';
ax.GridColor = 'w';
ax.GridAlpha = 1;% maximum line opacity

% xlim([ticks(1) ticks(end)]);
% ylim([ticks(1) ticks(end)]);
% axis equal;

%% Randomly sample 10 pairs from the set of 1000 pairs and obtain J_E

rng(11);

no_sample_times = 1000;
idx_sampled = zeros(no_sample_times, 10);
je_sampled = zeros(no_sample_times, 1);

for ctr = 1:1:no_sample_times
   
    to_sample = randi([1, 1000], 1, 10);
    this_accu_N = zeros(18, 18);
    
    for ctr2 = 1:1:length(to_sample)
        
        idx = to_sample(ctr2);
        
        traj1 = conv1_traj(idx, :);
        traj2 = conv2_traj(idx, :);
        
        traj1 = traj1(common_idx_start : end);
        traj2 = traj2(common_idx_start : end);
        
        this_N = histcounts2(traj1, traj2, Xedges, Yedges);
        
        this_accu_N = this_accu_N + this_N;
        
    end
    
    je_sampled(ctr) = calc_joint_entropy(this_accu_N);
    idx_sampled(ctr, :) = to_sample;
    
    fprintf("\n CTR: %d, JE: %f, MAX: %f", ctr, round(je_sampled(ctr), 2), round(max(je_sampled), 2));
    
end
%% Save best pairs

save('best_traj_pairs.mat', 'idx_sampled', 'je_sampled');

%% Sort top 10

[sorted_sampled_joint_entropy, sorted_idxs] = sort(je_sampled, 'descend');
top_10_pop_sapmles_idxs = sorted_idxs(1: 10);

pairs_to_visualise = idx_sampled(top_10_pop_sapmles_idxs(2), :);

%%  - - - OLD - - - 

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

%% 

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

%%

function norm_traj = normalise_trajectory(trajectory)
    
    min_t = min(trajectory);
    max_t = max(trajectory);
    
    norm_traj = (trajectory - min_t) * (1/(max_t - min_t)) * 180;
    
end

%% 

function je = calc_joint_entropy(N)
    
    je = 0;

    N_norm = N/sum(N, 'all');
    no_rows = size(N_norm, 1);
    no_cols = size(N_norm, 2);

    for row_ctr = 1:1:no_rows
        for col_ctr = 1:1:no_cols
            if N_norm(row_ctr, col_ctr) ~= 0
                je = je + N_norm(row_ctr, col_ctr) * log2(N_norm(row_ctr, col_ctr));
            end
        end
    end
    
    je = -je;
    
end

%% 

function je = calc_joint_entropy_traj(traj1, traj2, start_idx)

    traj1 = traj1(start_idx : end);
    traj2 = traj2(start_idx : end);
    
    Xedges = 0:10:180;
    Yedges = 0:10:180;

    N = histcounts2(traj1, traj2, Xedges, Yedges);
    je = calc_joint_entropy(N);

end