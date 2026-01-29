function sos = design_cheby2_bandpass_sos(...
    sample_rate, ...
    center_frequency, ...
    bandwidth, ...
    filter_order)

    % DESIGN_CHEBY2_BANDPASS_SOS   Chebyshev Type II bandpass IIR in SOS form
    %
    % Inputs:
    %   sample_rate       Fs in Hz
    %   center_frequency  f0 in Hz (geometric preferred)
    %   bandwidth         -3 dB bandwidth in Hz
    %   filter_order      even recommended (total bandpass order)
    %
    % Output: Nx6 SOS matrix [b0 b1 b2  a0 a1 a2] with a0 = 1

    % if mod(filter_order, 2) ~= 0
    %     filter_order = filter_order - mod(filter_order, 2);
    %     warning('filter_order must be even → forced to %d', filter_order);
    % end
    % 
    % if bandwidth <= 0 || center_frequency <= bandwidth/2 || ...
    %    center_frequency + bandwidth/2 >= sample_rate/2
    %     error('Invalid frequency specs (Nyquist violation or negative bw)');
    % end
    % 
    % % ──────────────────────────────────────────────
    % % 1. Digital → analog prewarped frequencies
    % % ──────────────────────────────────────────────
    % tan_half_fs = 2 * sample_rate;   % bilinear constant = 2/Ts
    % 
    % omega_d_center = 2 * pi * center_frequency / sample_rate;
    % omega_d_lower  = 2 * pi * (center_frequency - bandwidth/2) / sample_rate;
    % omega_d_upper  = 2 * pi * (center_frequency + bandwidth/2) / sample_rate;
    % 
    % Omega_0 = tan_half_fs * tan(omega_d_center / 2);   % analog center freq
    % Omega_l = tan_half_fs * tan(omega_d_lower  / 2);
    % Omega_u = tan_half_fs * tan(omega_d_upper  / 2);
    % 
    % % Better bandwidth measure in analog domain
    % B_omega = Omega_u - Omega_l;
    % 
    % % Quality factor for transformation
    % Q_bp = Omega_0 / B_omega;

% ──────────────────────────────────────────────
% 1. Normalize to fs = 1  →  much better numerical behaviour at high Fs
% ──────────────────────────────────────────────
f0_norm = center_frequency / sample_rate;
bw_norm = bandwidth         / sample_rate;

if bw_norm > 0.499 || f0_norm < bw_norm/2 || f0_norm > 1 - bw_norm/2
    error('Invalid normalized frequencies (must be inside (0, 0.5))');
end

w0      = 2 * pi * f0_norm;
w_lower = 2 * pi * (f0_norm - bw_norm/2);
w_upper = 2 * pi * (f0_norm + bw_norm/2);

% Pre-warped analog frequencies (Ω = tan(ω/2) when fs is normalized to 1)
Omega_0     = tan(w0     / 2);
Omega_lower = tan(w_lower / 2);
Omega_upper = tan(w_upper / 2);

% Analog bandwidth (geometric center is better for narrow bands, but arithmetic ok here)
B_analog = Omega_upper - Omega_lower;     % ← this is the correct name

% Quality factor
Q = Omega_0 / B_analog;

% ──────────────────────────────────────────────
% 2. Chebyshev Type II lowpass prototype (Ωc = 1 rad/s)
% ──────────────────────────────────────────────
Rs_db = 40;
n_lp = filter_order / 2;

epsilon = 1 / sqrt(10^(0.1*Rs_db) - 1);
alpha   = (1/n_lp) * asinh(1/epsilon);

poles_lp = zeros(1, 2*n_lp);
for k = 1:n_lp
    theta = (2*k - 1)*pi / (2*n_lp);
    sigma = -sinh(alpha) * sin(theta);
    wd    =  cosh(alpha) * cos(theta);
    poles_lp(2*k-1) = sigma + 1i*wd;
    poles_lp(2*k)   = sigma - 1i*wd;
end

% Zeros on imaginary axis
zeros_lp = zeros(1, 2*n_lp);
for k = 1:n_lp
    theta_z = (2*k - 1)*pi / (2*n_lp);
    z_im    = 1 / sin(theta_z);
    zeros_lp(2*k-1) =  1i * z_im;
    zeros_lp(2*k)   = -1i * z_im;
end

% Common scaling for type-II prototype to have |H(j1)| ≈ 10^(-Rs/20)
scale = 1 / cosh(alpha);
zeros_lp = zeros_lp * scale;

% ──────────────────────────────────────────────
% 3. Analog lowpass → bandpass transformation
%    For lowpass pole/zero p:   s → (s² + Ω₀²)/(B s)
% ──────────────────────────────────────────────
s_poles = [];
s_zeros = [];

for p = poles_lp
    % Quadratic: s² + (p*B) s + Ω₀² = 0    (note sign convention)
    a = 1;
    b = p * B_analog;           % ← fixed: use B_analog
    c = Omega_0^2;
    disc = b^2 - 4*a*c;
    if disc < 0, disc = complex(disc); end
    sqrt_disc = sqrt(disc);
    r1 = (-b + sqrt_disc)/(2*a);
    r2 = (-b - sqrt_disc)/(2*a);
    s_poles = [s_poles r1 r2];
end

for z = zeros_lp
    if abs(real(z)) > 1e-9 || abs(imag(z)) < 1e-9
        continue;
    end
    a = 1;
    b = z * B_analog;           % ← fixed
    c = Omega_0^2;
    disc = b^2 - 4*a*c;
    if disc < 0, disc = complex(disc); end
    sqrt_disc = sqrt(disc);
    r1 = (-b + sqrt_disc)/(2*a);
    r2 = (-b - sqrt_disc)/(2*a);
    s_zeros = [s_zeros r1 r2];
end

% ──────────────────────────────────────────────
% 4. Bilinear transform  (analog s → digital z)
%    With normalized fs=1 → K = 1 (prewarping constant = 2/T with T=1)
% ──────────────────────────────────────────────
K = 1;

z_poles = (K + s_poles) ./ (K - s_poles);
z_zeros = (K + s_zeros) ./ (K - s_zeros);

% Remove clearly unstable poles (numerical garbage)
% stable_idx = abs(z_poles) < 0.999;
% z_poles = z_poles(stable_idx);

% ──────────────────────────────────────────────
% 5. Build SOS with conjugate pairing
% ──────────────────────────────────────────────
% Reuse or copy the sort_complex_conjugate_pairs helper from earlier
[z_poles_paired, ~] = sort_complex_conjugate_pairs(z_poles);
[z_zeros_paired, ~] = sort_complex_conjugate_pairs(z_zeros);

n_sections = length(z_poles_paired)/2;
sos = zeros(n_sections, 6);

z_ptr = 1;
for sec = 1:n_sections
    p1 = z_poles_paired(2*sec-1);
    p2 = z_poles_paired(2*sec);

    a0 = 1;
    a1 = -(real(p1 + p2));   % force real coeffs
    a2 =  real(p1 * p2);

    if z_ptr + 1 <= length(z_zeros_paired)
        z1 = z_zeros_paired(z_ptr);
        z2 = z_zeros_paired(z_ptr+1);
        z_ptr = z_ptr + 2;
    else
        z1 = 0; z2 = 0;   % all-pole fallback
    end

    b0 = 1;
    b1 = -(real(z1 + z2));
    b2 =  real(z1 * z2);

    sos(sec,:) = [b0 b1 b2  a0 a1 a2];
end

% Basic gain correction at center frequency
w_test = 2*pi * f0_norm;
z_test = exp(1i * w_test);
H = 1;
for i = 1:size(sos,1)
    b = sos(i,1:3); a = sos(i,4:6);
    H = H * polyval(b, z_test) / polyval(a, z_test);
end
gain = 1 / abs(H);
sos(:,1:3) = sos(:,1:3) * gain;

end


function [sorted, idx] = sort_complex_conjugate_pairs(v)
    % Helper: sort complex vector so conjugates are next to each other
    tol = 1e-10;
    v = v(:).';
    n = length(v);
    used = false(1,n);
    sorted = zeros(1,n);
    idx = 1:n;

    k = 1;
    for i = 1:n
        if used(i), continue; end
        p = v(i);
        sorted(k) = p;
        used(i) = true;
        k = k + 1;

        % find conjugate
        [~, j] = min(abs(v - conj(p)));
        if j ~= i && abs(v(j) - conj(p)) < tol && ~used(j)
            sorted(k) = v(j);
            used(j) = true;
            k = k + 1;
        end
    end
    sorted = sorted(1:k-1);
    idx = idx(used);
end