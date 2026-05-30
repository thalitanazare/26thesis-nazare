%% ================================================================
%  Pitch EOM (article model) + A_inf + radiation (Cummins via Prony)
%  + hydrostatic restoring + equivalent mooring [Mode A / Mode B]
%  + QBlade imported disturbances: wind (v[t]) and wave (eta[t])
%    -> internal calculation of the excitation forces F_wind(t), F_wave(t)
%
%  States: x = [theta; thetad; z1..zn], where z_i is radiation memory
%
%  EOM:
%    J*thetadd + sum(z_i) + B_theta*thetad + (C_h+K_m)*theta
%      = 2(Fr l1 + Ft l2 - Fp l4) sin(theta)
%        + (w1 + T_rotor) l1 cos(theta) + w2 l3 cos(theta) - d(u1+u2) cos(theta)
% ================================================================

clear all; clc; close all;

%% ========================= SECTION 0 - BASE PARAMETERS ====================
% --- masses / gravity (same as in the article)
mr = 350000;     % rotor + nacelle [kg]
mt = 347460;     % tower [kg]
mp = 12187000;   % platform [kg]
g  = 9.81;       % gravity [m/s^2]

Fr = mr*g;  Ft = mt*g;  Fp = mp*g;

% --- geometric moment arms (same as in the original script)
l1 = 90 + 32.8;       % [m] hub -> system CM
l2 = 64 + 32.8;       % [m] tower -> system CM
l3 = 32.8;            % [m] wave-force moment arm
l4 = 40.612 - 32.8;   % [m] platform CM relative to system CM
d  = 9;               % [m] base semidiameter (article)

% --- article inertia: J_art = Delta/3
Delta = (d^2+3*l4^2)*mp + 6*l1^2*mr + 4*l2^2*mt;
J_art = Delta/3;

% --- hydrostatic restoring and mooring
C_h = 5.18e7;                   % 7[N m/rad] pitch hydrostatic stiffness
EA_line = 1.9e9;  L_line = 151.73;  R_fair = 40;  nLines = 2; %1.5 36
K_m = nLines*(EA_line/L_line)*R_fair^2; % [N m/rad] equivalent mooring stiffness
D_m = 2.02e9;                      % [N m s/rad] equivalent damping
B_h = 0.0;                         % [N m s/rad] linear hydrodynamic damping (pitch)

% --- WAMIT/HydroDyn radiation file (.1)
file_rad = 'tlpmit.1.txt';

% --- number of exponentials for radiation memory
nExp = 8;   % (4–8 is usually sufficient)

% --- initial condition and time windows
theta0_deg = 10;                   % *** START AT ZERO *** initial displacement [deg]
theta0     = deg2rad(theta0_deg); % [rad]
thetad0    = 0;                   % [rad/s]
Tfree      = 100;                 % [s] free decay
%Tdist      = 300;                 % [s] (will be adjusted from the input files)
dt         = 0.1;      % [s] time step

% --- INPUT FILES (QBlade): time [s], column 2 = signal
file_wind = 'QB_wind_12.txt';   % col2: v_wind [m/s] (at the reference height)
file_wave = 'QB_wave_12.txt';   % col2: eta(t) [m] (surface elevation)
file_pitch_qb = 'QB_pitch_12.txt';

%% ========================= SECTION 1 - RADIATION MODEL (AUTOMATIC) ==============
% Read A55(omega) and B55(omega), then build the kernel K(t)
[A55, B55, omega] = read_wamit_1_pitch(file_rad);
if isempty(omega)
    error('Failed to read %s. Check format/columns.', file_rad);
end

A_inf = A55(end);                         % high-frequency added mass
tK = (0:dt:100)';                         % time window used to fit the kernel
Kt = build_kernel_from_B(omega, B55, tK); % kernel K(t)
[a,b] = fit_prony_exp(Kt, tK, nExp);      % K(t) ≈ Σ a_i e^{-b_i t}
n = length(a);

Jstar   = J_art + A_inf;                  % effective inertia
B_theta = B_h + D_m;                      % lumped damping

%% ========================= SECTION 2 - QBlade DISTURBANCE PREPROCESSING ===============
% 2.1 Read raw QBlade time series
[t_wind_raw, v_wind_raw] = read_signal_txt(file_wind); % [s], [m/s]
[t_wave_raw, eta_raw]    = read_signal_txt(file_wave); % [s], [m]

% Set Tdist from the longest available time range
Tdist = max([t_wind_raw(:); t_wave_raw(:)]);
t_dist = (0:dt:Tdist)';

% 2.2 Interpolate raw signals onto a common time grid
v_wind = interp1(t_wind_raw, v_wind_raw, t_dist, 'linear', 'extrap'); % use 0 instead of extrap if zero outside the data range is preferred
eta    = interp1(t_wave_raw,  eta_raw,    t_dist, 'linear', 'extrap');

% 2.3 Aerodynamic/hydrodynamic parameters used to convert signals into forces
% --- WIND (effective frontal drag)
rho_air = 1.225;              % [kg/m^3]
C_d     = 0.47;               % 0.47[-] effective drag coefficient (adjust if needed)
r       = 62;                 % [m] rotor radius (5 MW example); adjust to your case
A_proj  = pi*r^2;             % [m^2] effective frontal area
% Wind force
F_wind = 0.5 * rho_air * C_d * A_proj .* (v_wind.^2);   % [N]

% --- WAVE (linear Froude-Krylov force over an equivalent frontal area)
rho = 1025;                   % [kg/m^3] seawater
Wp = 18;                      % [m] characteristic frontal width (adjust if needed)
draft = 47.89;                % [m] draft
water_depth = 200;            % [m] water depth
A_cross = draft * Wp;         % [m^2] equivalent submerged frontal area

% Estimate the peak frequency of eta(t) to compute k from the dispersion relation
[fp, omega_p] = peak_frequency_from_timeseries(t_dist, eta);
k_p = solve_dispersion(omega_p, water_depth, g);   % [1/m]
Gamma_k = cosh(k_p*draft) / cosh(k_p*water_depth); % vertical attenuation

% Wave force (linear approximation: pressure ~ rho*g*eta*Gamma_k)
F_wave = rho * g * A_cross * Gamma_k .* eta;       % [N]

% 2.4 Map the force signals into the EOM using continuous function handles
w1_fun = @(t) interp1(t_dist, F_wind, t, 'linear', 0); % wind -> l1
w2_fun = @(t) interp1(t_dist, F_wave, t, 'linear', 0); % wave -> l3

%% ========================= SECTION 3 - NONLINEAR EQUATION OF MOTION ==================
% States: x = [theta; thetad; z1..zn]
eom = @(t,x,Ctot,Btot, w1,w2, u1,u2) eom_article_plus( ...
           t,x,Fr,Ft,Fp,l1,l2,l3,l4,d, Jstar,Ctot,Btot,a,b, w1,w2,u1,u2);

%% ========================= SECTION 4 - NONLINEAR TIME-DOMAIN SIMULATIONS =========================
opts = odeset('RelTol',1e-9,'AbsTol',1e-9);

% (A) Free decay: equivalent mooring included, no external disturbances
x0A   = [theta0; thetad0; zeros(n,1)];
CtotA = C_h + K_m;           % must be positive
BtotA = B_theta;
w1A = @(t) 0; w2A = @(t) 0;
u1A = @(t,th) 0; u2A = @(t,th) 0;

[tA, xA] = ode45(@(t,x) eom(t,x,CtotA,BtotA,w1A,w2A,u1A,u2A), [0 Tfree], x0A, opts);
thetaA_deg = rad2deg(xA(:,1));

% (B) With QBlade disturbances + equivalent mooring
x0B   = [deg2rad(0); 0; zeros(n,1)];   % *** START AT ZERO ***
CtotB = C_h + K_m;
BtotB = B_theta;
u1B = @(t,th) 0; u2B = @(t,th) 0;

[tB, xB] = ode45(@(t,x) eom(t,x,CtotB,BtotB,w1_fun,w2_fun,u1B,u2B), [0 Tdist], x0B, opts);
thetaB_deg = rad2deg(xB(:,1));



%% ========================= SECTION 5 - BASIC FFT AND QBlade COMPARISON =========
% Compare pitch via FFT (peak) + global stats; damping (ζ) via log decrement.


% 5.1 Read QBlade and resample to simulation grid (tB)
[t_qb_raw, pitch_qb_deg_raw] = read_signal_txt(file_pitch_qb); % degrees
pitch_qb_deg = interp1(t_qb_raw, pitch_qb_deg_raw, tB, 'linear', 'extrap');
pitch_mod_deg = thetaB_deg;  % model

% 5.2 Basic stats
stat_mean_model = mean(pitch_mod_deg,'omitnan');
stat_std_model  = std(pitch_mod_deg,0,'omitnan');
stat_rms_model  = sqrt(mean(pitch_mod_deg.^2,'omitnan'));
stat_rng_model  = max(pitch_mod_deg) - min(pitch_mod_deg);

stat_mean_qb = mean(pitch_qb_deg,'omitnan');
stat_std_qb  = std(pitch_qb_deg,0,'omitnan');
stat_rms_qb  = sqrt(mean(pitch_qb_deg.^2,'omitnan'));
stat_rng_qb  = max(pitch_qb_deg) - min(pitch_qb_deg);

% 5.3 FFT single-sided (same dt, same N)
[F, A_model] = simple_fft_single_sided(tB, pitch_mod_deg - stat_mean_model);
[~, A_qb   ] = simple_fft_single_sided(tB, pitch_qb_deg  - stat_mean_qb);

% 5.4 Peak frequency (dominant)
[Ap_model, idxM] = max(A_model);  fp_model = F(idxM);
[Ap_qb,    idxQ] = max(A_qb);     fp_qb    = F(idxQ);

% 5.5 Damping (ζ) via logarithmic decrement using first two peaks
zeta_model = logdec_damping(tB, pitch_mod_deg);
zeta_qb    = logdec_damping(tB, pitch_qb_deg);


%% ========================= SECTION 6 - FREQUENCY SPECTRUM (Welch PSD) =========
% Compare power spectral density (PSD) with higher frequency resolution.

% Sampling frequency
dtB = mean(diff(tB));
FsB = 1/dtB;

% Define parameters for Welch
nfft = 2^14;                      % larger FFT size = finer resolution
window = hanning(2^12);           % window length (adjust for smoothness vs resolution)
noverlap = round(length(window)/2); % 50% overlap

% PSD via Welch with custom parameters
[psd_model, f_model] = pwelch(pitch_mod_deg - mean(pitch_mod_deg), window, noverlap, nfft, FsB);
[psd_qb,    f_qb   ] = pwelch(pitch_qb_deg  - mean(pitch_qb_deg), window, noverlap, nfft, FsB);
%% ========================= SECTION 7 - LINEAR STATE-SPACE VERSION =================
% Linearized around θ≈0:  sinθ≈θ, cosθ≈1
% States: x = [θ; θdot; z1..zn]
% θddot = ( (G - Ctot)*θ  - Btot*θdot  - sum(z) + l1*w1 + l3*w2 - d(u1+u2) ) / J*
% zdot_i = -b_i z_i + a_i θdot
% Here we keep u1=u2=0 (same as case B). Inputs = [w1; w2]. Output y = θ.

% ---- build state-space matrices (case B parameters) ----
Ggrav  = (Fr*l1 + Ft*l2 - Fp*l4);   % gravity linear gain
CtotB  = C_h + K_m;                  % same as section 4 (B)
BtotB  = B_theta;

A = zeros(2+n);
A(1,2) = 1;
A(2,1) = (Ggrav - CtotB)/Jstar;
A(2,2) = -BtotB/Jstar;
A(2,3:end) = -(1/Jstar)*ones(1,n);
% z dynamics
A(3:end,2) = a(:);
A(3:end,3:end) = -diag(b);

% inputs: [w1; w2]
Bw = zeros(2+n,2);
Bw(2,1) = l1/Jstar;   % w1
Bw(2,2) = l3/Jstar;   % w2

% output θ only
Cout = [1, zeros(1,1+n)];
Dout = zeros(1,2);

sysSS = ss(A,Bw,Cout,Dout);

% ---- (A) free-decay in state-space (same ICs as section 4A) ----
x0A_ss = [deg2rad(theta0_deg); thetad0; zeros(n,1)];
tA_ss = (0:dt:Tfree)';                      % uniform time vector
yA_ss  = initial(sysSS, x0A_ss, tA_ss);     % θ (rad)
thetaA_ss_deg = rad2deg(yA_ss);

% ---- (B) disturbances in state-space (same inputs as section 4B) ----
% build input arrays on t_dist grid
w1_series = arrayfun(w1_fun, t_dist);  % [N]
w2_series = arrayfun(w2_fun, t_dist);  % [N]
U = [w1_series, w2_series];

x0B_ss = [0; 0; zeros(n,1)];           % start at zero
yB_ss  = lsim(sysSS, U, t_dist, x0B_ss);
thetaB_ss_deg = rad2deg(yB_ss);

%% --------- Plots: free decay and disturbances (time series) -------------
% Free decay: EOM vs SS (subplots)
figure;

% Subplot 1 - Motion Equation
subplot(2,1,1);
plot(tA, thetaA_deg, 'LineWidth',1.5); grid on;
xlabel('Time [s]', 'FontName','Times New Roman', 'FontSize',20);
ylabel('\theta [deg]', 'FontName','Times New Roman', 'FontSize',20);
legend('Motion Equation', 'FontName','Times New Roman', 'FontSize',20, 'Location','best');
set(gca, 'FontName','Times New Roman', 'FontSize',20);

% Subplot 2 - Linear State-Space Model
subplot(2,1,2);
plot(tA_ss, thetaA_ss_deg, 'LineWidth',1.5); grid on;
xlabel('Time [s]', 'FontName','Times New Roman', 'FontSize',20);
ylabel('\theta [deg]', 'FontName','Times New Roman', 'FontSize',20);
legend('Linear State-Space Model', 'FontName','Times New Roman', 'FontSize',20, 'Location','best');
set(gca, 'FontName','Times New Roman', 'FontSize',20);

% Disturbances: 3 subplots (EOM, State-space, QBlade)
figure;

% Subplot 1
subplot(3,1,1);
plot(tB, thetaB_deg, 'LineWidth',1.5); grid on;
xlabel('Time [s]', 'FontName','Times New Roman', 'FontSize',20);
ylabel('\theta [deg]', 'FontName','Times New Roman', 'FontSize',20);
legend('Motion Equation','FontName','Times New Roman','FontSize',20);
xlim([0 100]);
%ylim([-0.02 0.06]);
set(gca,'FontName','Times New Roman','FontSize',18);
box off

% Subplot 2
subplot(3,1,2);
plot(t_dist, thetaB_ss_deg, 'LineWidth',1.5); grid on;
xlabel('Time [s]', 'FontName','Times New Roman', 'FontSize',20);
ylabel('\theta [deg]', 'FontName','Times New Roman', 'FontSize',20);
legend('State-Space','FontName','Times New Roman','FontSize',20);
xlim([0 100]);
%ylim([-0.02 0.06]);
set(gca,'FontName','Times New Roman','FontSize',18);
box off

% Subplot 3
subplot(3,1,3);
plot(tB, pitch_qb_deg, 'LineWidth',1.5); grid on;
xlabel('Time [s]', 'FontName','Times New Roman', 'FontSize',20);
ylabel('\theta [deg]', 'FontName','Times New Roman', 'FontSize',20);
legend('QBlade','FontName','Times New Roman','FontSize',20);
xlim([0 100]);
%ylim([-0.02 0.06]);
set(gca,'FontName','Times New Roman','FontSize',18);
box off


%% --------- FFT comparison (EOM vs State-space vs QBlade) ----------------
% Use the same helper from Section 6
[Ffft, A_eom] = simple_fft_single_sided(tB, thetaB_deg - mean(thetaB_deg));
[~,    A_ss ] = simple_fft_single_sided(t_dist, thetaB_ss_deg - mean(thetaB_ss_deg));
[~,    A_qb ] = simple_fft_single_sided(tB, pitch_qb_deg - mean(pitch_qb_deg));

% Align frequency vector length if needed (use the shorter F axis)
FminLen = min([numel(Ffft), numel(A_ss), numel(A_qb)]);
Fplot   = Ffft(1:FminLen);
Ae_plot = A_eom(1:FminLen);
As_plot = A_ss(1:FminLen);
Aq_plot = A_qb(1:FminLen);


% Peak frequencies from FFT
[Ap_eom, idxE] = max(Ae_plot);   fp_eom = Fplot(idxE);
[Ap_ss,  idxS] = max(As_plot);   fp_ss  = Fplot(idxS);
[Ap_qb,  idxQ] = max(Aq_plot);   fp_qb2 = Fplot(idxQ);% (name distinct from Section 6)

%% --------- Comparative table (3 columns) --------------------------------
% Basic stats
mean_eom = mean(thetaB_deg);   std_eom = std(thetaB_deg);   rms_eom = sqrt(mean(thetaB_deg.^2));   rng_eom = range(thetaB_deg);
mean_ss  = mean(thetaB_ss_deg);std_ss  = std(thetaB_ss_deg);rms_ss  = sqrt(mean(thetaB_ss_deg.^2));rng_ss  = range(thetaB_ss_deg);
mean_qb2 = mean(pitch_qb_deg); std_qb2 = std(pitch_qb_deg); rms_qb2 = sqrt(mean(pitch_qb_deg.^2)); rng_qb2 = range(pitch_qb_deg);

% Damping (logarithmic decrement) for each series (may return NaN if no clear peaks)
zeta_eom = logdec_damping(tB,        thetaB_deg);
zeta_ss  = logdec_damping(t_dist,    thetaB_ss_deg);
zeta_qb2 = logdec_damping(tB,        pitch_qb_deg);

Metric = { ...
  'Std [deg]'; 'f_{peak} (FFT) [Hz]'; 'Peak amplitude (FFT) [deg]'};

EOM        = [ std_eom; fp_eom; Ap_eom];
StateSpace = [ std_ss;  fp_ss;  Ap_ss];
QBlade3    = [ std_qb2; fp_qb2; Ap_qb];

tblSS = table(Metric, EOM, StateSpace, QBlade3);
disp('================== COMPARISON (EOM vs State-space vs QBlade) ==================');
disp(tblSS);

%% ========================= SECTION 8 - LQR CO-DESIGN: OPTIMIZE PLATFORM MASS ONLY =====
params = struct();
params.mr = mr; params.mt = mt; params.g = g;
params.l1 = l1; params.l2 = l2; params.l3 = l3; params.l4 = l4; params.d = d;
params.C_h = C_h; params.K_m = K_m; params.B_theta = B_theta;
params.a = a; params.b = b; params.n = n; params.A_inf = A_inf;

params.mp_nom = mp;
params.mp_minmax = [0.8*mp, 0.86*mp];

params.Qw  = diag([1, 1e-2, 1e-6*ones(1,params.n)]);
params.Ract= 1e-10*eye(2);   % <-- two control inputs

w_theta  = 1; 
w_thetad = 1e-2; 
w_u      = 1e-8;

Fmax = 790000;   % per-channel saturation

w1_series = arrayfun(w1_fun, t_dist);
w2_series = arrayfun(w2_fun, t_dist);



x0_mp = params.mp_nom;
opts_fms = optimset('Display','iter','TolX',1e-3,'TolFun',1e-3,'MaxFunEvals',150);
cost_fun_mp = @(x) cost_mp_only(x, params, w1_series, w2_series, t_dist, Fmax, w_theta, w_thetad, w_u);
x_opt = fminsearch(cost_fun_mp, x0_mp, opts_fms);
mp_opt = min(max(x_opt(1), params.mp_minmax(1)), params.mp_minmax(2));

% --- Open loop (nominal) ---
Pnom = build_ss_for_mp(params.mp_nom, params);
sysOL = ss(Pnom.A, Pnom.Bw, Pnom.C, 0);
y_ol  = rad2deg(lsim(sysOL, [w1_series w2_series], t_dist, zeros(size(Pnom.A,1),1)));

% --- Closed loop (optimized mp + two actuators) ---
Popt = build_ss_for_mp(mp_opt, params);
Kopt = lqr(Popt.A, Popt.Bu, Popt.Q, Popt.R);   % 2 x n
Acl  = Popt.A - Popt.Bu*Kopt;
sysCL= ss(Acl, Popt.Bw, Popt.C, 0);
y_cl = rad2deg(lsim(sysCL, [w1_series w2_series], t_dist, zeros(size(Popt.A,1),1)));

% control effort per channel
[~, ~, xhist_opt] = lsim(ss(Popt.A, Popt.Bw, eye(size(Popt.A)), 0), ...
                         [w1_series w2_series], t_dist, zeros(size(Popt.A,1),1));
u_opt = -(Kopt * xhist_opt.').';          % Nx2
u_opt_sat = max(-Fmax, min(Fmax, u_opt)); % per-channel saturation

% --- Figure font settings ---
set(0,'DefaultAxesFontName','Times New Roman');
set(0,'DefaultAxesFontSize',18);
set(0,'DefaultTextFontName','Times New Roman');
set(0,'DefaultTextFontSize',18);

figure;
subplot(3,1,1);
plot(t_dist, y_ol, 'LineWidth',1.2); grid on;
xlabel('Time [s]'); ylabel('\theta [deg]');
title(sprintf('Open-loop - m_p=%.2e kg', params.mp_nom));
box off

subplot(3,1,2);
plot(t_dist, y_cl, 'LineWidth',1.5); grid on;
xlabel('Time [s]'); ylabel('\theta [deg]');
title(sprintf('Closed-loop LQR Co-Design - m_p=%.2e kg', mp_opt));
box off


subplot(3,1,3);
plot(t_dist, u_opt_sat(:,1), 'LineWidth',1.2); hold on;
%plot(t_dist, u_opt_sat(:,2), 'LineWidth',1.2); grid on;
xlabel('Time [s]'); ylabel('u_i [MN]');
legend('u_1','u_2','Location','best');
title('Active mooring forces');
box off

% %
[F9, A_ol] = simple_fft_single_sided(t_dist, y_ol - mean(y_ol));
[~,  A_cl] = simple_fft_single_sided(t_dist, y_cl - mean(y_cl));
[~,  A_qb] = simple_fft_single_sided(t_dist, pitch_qb_deg - mean(pitch_qb_deg));
Lmin = min([numel(F9), numel(A_ol), numel(A_cl), numel(A_qb)]);

% --- metrics ---
mean_ol = mean(y_ol); std_ol = std(y_ol); rms_ol = sqrt(mean(y_ol.^2)); rng_ol = range(y_ol);
mean_cl = mean(y_cl); std_cl = std(y_cl); rms_cl = sqrt(mean(y_cl.^2)); rng_cl = range(y_cl);
[Ap_ol, iO] = max(A_ol(1:Lmin)); fp_ol = F9(iO);
[Ap_cl, iC] = max(A_cl(1:Lmin)); fp_cl = F9(iC);

Metric = { ...
  'mp_{nom} [kg]'; 'mp_{opt} [kg]'; ...
  'LQR K row1 (first 2 gains)'; 'LQR K row2 (first 2 gains)'; ...
  'Mean \theta [deg] (OL)'; 'Std \theta [deg] (OL)'; 'RMS \theta [deg] (OL)'; 'Range \theta [deg] (OL)'; ...
  'Mean \theta [deg] (CL)'; 'Std \theta [deg] (CL)'; 'RMS \theta [deg] (CL)'; 'Range \theta [deg] (CL)'; ...
  'f_{peak} OL [Hz]'; 'f_{peak} CL [Hz]' };

Info = { ...
  params.mp_nom; mp_opt; ...
  sprintf('[%.3e  %.3e  ...]', Kopt(1,1), Kopt(1,2)); ...
  sprintf('[%.3e  %.3e  ...]', Kopt(2,1), Kopt(2,2)); ...
  mean_ol; std_ol; rms_ol; rng_ol; ...
  mean_cl; std_cl; rms_cl; rng_cl; ...
  fp_ol; fp_cl };

T_co_mp = table(Metric, Info);
disp('================== CO-DESIGN (State-space + LQR) - MASS ONLY, TWO ACTUATORS ==================');
disp(T_co_mp);

%% ========================= SECTION 9 - NOMINAL LQR (NO CO-DESIGN) ==================
% Assumptions: uses params and build_ss_for_mp() already defined; two actuators (u1,u2)

% --- nominal plant using nominal mp ---
Pnom = build_ss_for_mp(params.mp_nom, params);

% --- LQR for two actuators (uses weights already defined in params) ---
K10  = lqr(Pnom.A, Pnom.Bu, params.Qw, params.Ract);   % size: 2 x (2+n)
Acl10 = Pnom.A - Pnom.Bu*K10;

% --- simulate open-loop and closed-loop responses under the same disturbances ---
sysOL10 = ss(Pnom.A, Pnom.Bw, Pnom.C, 0);
y_ol10  = rad2deg(lsim(sysOL10, [w1_series w2_series], t_dist, zeros(size(Pnom.A,1),1)));

sysCL10 = ss(Acl10, Pnom.Bw, Pnom.C, 0);
y_cl10  = rad2deg(lsim(sysCL10, [w1_series w2_series], t_dist, zeros(size(Pnom.A,1),1)));

% --- control effort per channel (u1,u2) no CL ---
[~, ~, xhist10] = lsim(ss(Pnom.A, Pnom.Bw, eye(size(Pnom.A)), 0), ...
                       [w1_series w2_series], t_dist, zeros(size(Pnom.A,1),1));
u10      = -(K10 * xhist10.').';            % Nx2
u10_sat  = max(-Fmax, min(Fmax, u10));      % per-channel saturation

% --- figure font settings (Times New Roman 18) ---
set(0,'DefaultAxesFontName','Times New Roman');
set(0,'DefaultAxesFontSize',18);
set(0,'DefaultTextFontName','Times New Roman');
set(0,'DefaultTextFontSize',18);

% --- figures: open-loop vs closed-loop + control effort ---
figure;
subplot(3,1,1);
plot(t_dist, y_ol10, 'LineWidth',1.2); grid on;
xlabel('Time [s]'); ylabel('\theta [deg]');
title('Open-loop');
box off

subplot(3,1,2);
plot(t_dist, y_cl10, 'LineWidth',1.5); grid on;
xlabel('Time [s]'); ylabel('\theta [deg]');
title('Closed-loop');
box off

subplot(3,1,3);
plot(t_dist, u10_sat(:,1), 'LineWidth',1.2);  grid on;
xlabel('Time [s]'); ylabel('u_i [MN]');
%legend('u_1','u_2','Location','best');
title('Active mooring forces');
box off

% --- FFT: open vs closed ---
[F10, A_ol10] = simple_fft_single_sided(t_dist, y_ol10 - mean(y_ol10));
[~,   A_cl10] = simple_fft_single_sided(t_dist, y_cl10 - mean(y_cl10));
Lmin10 = min([numel(F10), numel(A_ol10), numel(A_cl10)]);

% --- summary metrics ---
mean_ol10 = mean(y_ol10); std_ol10 = std(y_ol10); rms_ol10 = sqrt(mean(y_ol10.^2)); rng_ol10 = range(y_ol10);
mean_cl10 = mean(y_cl10); std_cl10 = std(y_cl10); rms_cl10 = sqrt(mean(y_cl10.^2)); rng_cl10 = range(y_cl10);
[Ap_ol10, iO10] = max(A_ol10(1:Lmin10)); fp_ol10 = F10(iO10);
[Ap_cl10, iC10] = max(A_cl10(1:Lmin10)); fp_cl10 = F10(iC10);

Metric10 = { ...
  'mp_{nom} [kg]'; ...
  'LQR K row1 (first 2 gains)'; 'LQR K row2 (first 2 gains)'; ...
  'Mean \theta [deg] (OL)'; 'Std \theta [deg] (OL)'; 'RMS \theta [deg] (OL)'; 'Range \theta [deg] (OL)'; ...
  'Mean \theta [deg] (CL)'; 'Std \theta [deg] (CL)'; 'RMS \theta [deg] (CL)'; 'Range \theta [deg] (CL)'; ...
  'f_{peak} OL [Hz]'; 'f_{peak} CL [Hz]' };

Info10 = { ...
  params.mp_nom; ...
  sprintf('[%.3e  %.3e  ...]', K10(1,1), K10(1,2)); ...
  sprintf('[%.3e  %.3e  ...]', K10(2,1), K10(2,2)); ...
  mean_ol10; std_ol10; rms_ol10; rng_ol10; ...
  mean_cl10; std_cl10; rms_cl10; rng_cl10; ...
  fp_ol10; fp_cl10 };

T_lqr_nom = table(Metric10, Info10);
disp('================== SECTION 9 - LQR (no co-design), TWO ACTUATORS ==================');
disp(T_lqr_nom);

%% ========================= SECTION 10 - LOCAL FUNCTIONS =========================
% Local functions are collected at the end of the script so the main workflow
% remains ordered and MATLAB can execute the script without interleaving local
% function definitions with script statements.

function dx = eom_article_plus(t,x,Fr,Ft,Fp,l1,l2,l3,l4,d, Jstar,Ctot,Btot,a,b, w1,w2,u1,u2)
    % States: x = [theta; thetad; z1..zn]
    theta  = x(1); thetad = x(2);
    n = length(a); z = x(3:2+n);

    % Internal LHS terms: stiffness + damping + radiation
    M_stiff = Ctot * theta;
    M_damp  = Btot * thetad;
    M_rad   = sum(z);                        % radiation memory

    % Gravity term - change the factor below to 2 if a 2x contribution is required
    M_grav = 1*(Fr*l1 + Ft*l2 - Fp*l4) * sin(theta);

    % External RHS terms: wind/wave + pull-pull actuation
    U1 = u1(t,theta); U2 = u2(t,theta);
    M_ext  =  (w1(t)) * l1 * cos(theta) ...
            + (w2(t)) * l3 * cos(theta) ...
            - d * (U1 + U2) * cos(theta);

    thetadd = ( M_grav + M_ext - M_stiff - M_damp - M_rad ) / Jstar;

    % Radiation memory: z_i
    zdot = -b.*z + a.*thetad;

    dx = [thetad; thetadd; zdot];
end

function [A55,B55,omega] = read_wamit_1_pitch(fname)
    fid = fopen(fname,'r');
    assert(fid>0, 'Could not open %s', fname);

    A55 = []; B55 = []; omega = [];
    while true
        ln = fgetl(fid);
        if ~ischar(ln), break; end
        ln = strtrim(ln);
        if isempty(ln), continue; end
        if ln(1)=='#' || ln(1)=='!' || startsWith(lower(ln),'freq') || startsWith(lower(ln),'omega')
            continue; % skip headers/comments
        end
        ln = regexprep(ln,'[dD]','E'); % Fortran D->E
        nums = sscanf(ln,'%f');
        if numel(nums) < 5, continue; end
        om   = nums(1);
        ii   = round(nums(2));
        jj   = round(nums(3));
        Aij  = nums(end-1);
        Bij  = nums(end);
        if ii==5 && jj==5
            omega(end+1,1) = om;   %#ok<AGROW>
            A55(end+1,1)   = Aij;  %#ok<AGROW>
            B55(end+1,1)   = Bij;  %#ok<AGROW>
        end
    end
    fclose(fid);
    if isempty(omega)
        error('No valid (i=j=5) rows found in %s.', fname);
    end
    [omega,ord] = sort(omega);
    A55 = A55(ord); B55 = B55(ord);
    [uOm,~,ic] = unique(omega);
    if numel(uOm) < numel(omega)
        A55 = accumarray(ic, A55, [], @mean);
        B55 = accumarray(ic, B55, [], @mean);
        omega = uOm;
    end
end

function Kt = build_kernel_from_B(omega,B, t)
    omega = omega(:); B = B(:); t = t(:);
    if numel(B) > 2
        B(1) = B(2); B(end) = B(end-1); % edge smoothing
    end
    Kt = zeros(size(t));
    for k=1:numel(t)
        Kt(k) = (2/pi)*trapz(omega, B.*cos(omega*t(k)));
    end
end

function [a,b] = fit_prony_exp(Kt,t, nExp)
    t  = t(:); Kt = Kt(:);
    T  = t(end); b0 = logspace(log10(1/max(T,1)), log10(20/T), nExp).';
    a0 = ones(nExp,1)*(max(Kt)/max(nExp,1));
    x0 = [a0; b0];
    Phi = @(bvec) exp(-t * bvec.');       % [Nt x nExp]
    res = @(x) Kt - Phi(x(nExp+1:end)) * x(1:nExp);
    f   = @(x) sum(res(x).^2);
    opts= optimset('Display','off','MaxFunEvals',5e5,'MaxIter',5e4);
    x   = fminsearch(f,x0,opts);
    a   = x(1:nExp);
    b   = abs(x(nExp+1:end));             % positivity

end

function [t, y] = read_signal_txt(fname)
    % Try readmatrix; fallback to textscan
    try
        data = readmatrix(fname);
    catch
        fid = fopen(fname,'r');
        assert(fid>0, 'Could not open %s', fname);
        C = textscan(fid,'%f%f','CommentStyle',{'#','!'},'CollectOutput',true);
        fclose(fid);
        data = C{1};
    end
    if isempty(data) || size(data,2) < 2
        error('File %s must have at least two columns: time and signal.', fname);
    end
    t = data(:,1); y = data(:,2);
    valid = isfinite(t) & isfinite(y);
    t = t(valid); y = y(valid);
    [t,ord] = sort(t); y = y(ord);
    if numel(unique(t)) < numel(t)
        [ut,~,ic] = unique(t);
        y = accumarray(ic, y, [], @mean);
        t = ut;
    end
end

function [fp, omega_p] = peak_frequency_from_timeseries(t, x)
    t = t(:); x = x(:);
    dt = median(diff(t));
    x = x - mean(x);
    N = length(x);
    Nfft = 2^nextpow2(N);
    w = hann(N); xw = x.*w;
    X = fft(xw, Nfft);
    f = (0:Nfft-1)'/(Nfft*dt);
    pos = f>0;
    [~,idx] = max(abs(X(pos)));
    fpos = f(pos);
    fp = fpos(idx);                 % [Hz]
    omega_p = 2*pi*fp;              % [rad/s]
end

function k = solve_dispersion(omega, h, g)
    if omega<=0
        k = 0; return;
    end
    k_i = max((omega^2)/g, 1e-9); % initial guess
    for it=1:100
        th = tanh(k_i*h);
        f   = omega^2 - g*k_i*th;
        dfk = -g*(th + k_i*h*(sech(k_i*h).^2));
        k_new = k_i - f/dfk;
        if ~isfinite(k_new), break; end
        if abs(k_new-k_i) < 1e-12, k_i = k_new; break; end
        k_i = max(k_new, 1e-12);
    end
    k = k_i;
end

function [F, A] = simple_fft_single_sided(t, x)
% Single-sided FFT amplitude (simple scaling).
    t = t(:); x = x(:);
    dt = median(diff(t)); Fs = 1/dt;
    N  = length(x);
    Y  = fft(x);
    A2 = abs(Y)/N;                 % two-sided amplitude
    A  = A2(1:floor(N/2)+1);       % single-sided
    A(2:end-1) = 2*A(2:end-1);     % single-sided adjustment
    F  = Fs*(0:floor(N/2))'/N;     % frequency axis
end

function zeta = logdec_damping(t, y)
% ζ via logarithmic decrement using the first two positive peaks.
% Returns NaN if not enough peaks (honest diagnostic).
    t = t(:); y = y(:);
    [pks, ~] = findpeaks(y, t, 'MinPeakProminence', max(1e-6,0.02*range(y)));
    if numel(pks) < 2
        zeta = NaN; return;
    end
    delta = log(pks(1)/pks(2));
    zeta  = delta / sqrt((2*pi)^2 + delta^2);
end

function plant = build_ss_for_mp(mp_var, P)
    mp_v = min(max(mp_var, P.mp_minmax(1)), P.mp_minmax(2));
    l2_v = P.l2;

    Fr_v = P.mr*P.g;   Ft_v = P.mt*P.g;   Fp_v = mp_v*P.g;

    Delta_v = (P.d^2 + 3*P.l4^2)*mp_v + 6*P.l1^2*P.mr + 4*l2_v^2*P.mt;
    Jstar_v = Delta_v/3 + P.A_inf;

    Ggrav_v = (Fr_v*P.l1 + Ft_v*l2_v - Fp_v*P.l4);
    Ctot_v  = P.C_h + P.K_m;
    Btot_v  = P.B_theta;

    A_v = zeros(2+P.n);
    A_v(1,2) = 1;
    A_v(2,1) = (Ggrav_v - Ctot_v)/Jstar_v;
    A_v(2,2) = -Btot_v/Jstar_v;
    A_v(2,3:end) = -(1/Jstar_v)*ones(1,P.n);
    A_v(3:end,2) = P.a(:);
    A_v(3:end,3:end) = -diag(P.b);

    Bw_v = zeros(2+P.n,2);
    Bw_v(2,1) = P.l1/Jstar_v;
    Bw_v(2,2) = P.l3/Jstar_v;

    % <<< TWO ACTIVE FORCES: u1 and u2 >>>
    Bu_v = zeros(2+P.n,2);
    Bu_v(2,1) = -P.d/Jstar_v;   % u1 generates torque -d*u1
    Bu_v(2,2) =  P.d/Jstar_v;   % u2 generates torque +d*u2

    C_v = [1, zeros(1,1+P.n)];

    plant.A=A_v; plant.Bw=Bw_v; plant.Bu=Bu_v; plant.C=C_v;
    plant.Q=P.Qw; plant.R=P.Ract; plant.J=Jstar_v;
end

function Jcost = cost_mp_only(x, P, w1s, w2s, tvec, Fmax_, w_th, w_dth, w_u_)
    mp_try = x(1);
    plant = build_ss_for_mp(mp_try, P);
    try
        K = lqr(plant.A, plant.Bu, plant.Q, plant.R);  % K: 2 x nstates
    catch
        Jcost = 1e12; return;
    end
    Acl = plant.A - plant.Bu*K;
    sysCL = ss(Acl, plant.Bw, plant.C, 0);
    y  = lsim(sysCL, [w1s w2s], tvec, zeros(size(plant.A,1),1));
    y  = rad2deg(y);
    dt = median(diff(tvec));
    dth = gradient(y, dt);

    sysX = ss(plant.A, plant.Bw, eye(size(plant.A)), 0);
    [~, ~, xhist] = lsim(sysX, [w1s w2s], tvec, zeros(size(plant.A,1),1));
    u = -(K * xhist.').';                 % Nx2
    u = max(-Fmax_, min(Fmax_, u));       % per-channel saturation

    Jperf = trapz(tvec, w_th*(y.^2) + w_dth*(dth.^2) + w_u_*sum(u.^2,2)); % sum across channels
    Jpen = 1e-6*( max(0, mp_try-P.mp_minmax(2))^2 + max(0, P.mp_minmax(1)-mp_try)^2 );
    Jcost = Jperf + Jpen;
end
