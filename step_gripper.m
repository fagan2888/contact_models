function [st, x] = step_gripper(params, st, u)
% st = [x, y, z, q0, q1, q2, q3, y_g1, y_g2, z_g ...]

% System parameters
h = params.h;
mu = params.mu;
m = params.m; % sphere mass
r = params.r; % sphere amss
m_g = params.m_g; % gripper finger mass
step_fun = params.step_fun;

M = diag(m*[1 1 1 (2/5)*r^2 (2/5)*r^2 (2/5)*r^2]);

% Extract pose and velocity
q = st(1:10);
v = st(11:19);

% Gravitational, external, and other forces
w = v(4:6);
I = M(4:6,4:6);
Fext = [0; 0; -9.81*m; -cross(w, I*w); u];

% Contact gap distances
psi = [r - q(10)
       q(10)
       q(8) - q(2) - r
       q(2) - q(9) - r
       q(3) - r];

% Jacobian for contacts
J = [ zeros(1,8)             -1   % gripper lift height   (normal)
      zeros(1,8)              1   % gripper lower height  (normal)
      0 -1  0  0  0  0  1  0  0   % finger1-disk          (normal)
      0  1  0  0  0  0  0 -1  0   % finger2-disk          (normal)
      0  0  1  0  0  0  0  0  0   % disk-floor            (normal)
      zeros(1,6)        1  1  0   % gripper lift height  (tangent)
      zeros(1,6)       -1 -1  0   % gripper lower height (tangent)
      0  0  1  r  0  0  0  0 -1   % finger1-disk         (tangent)
      0  0 -1  r  0  0  0  0  1   % finger2-disk         (tangent)
      0  1  0  r  0  0  0  0  0   % disk-floor           (tangent)
      zeros(1,8)              0   % gripper lift height    (other)
      zeros(1,8)              0   % gripper lower height   (other)
     -1  0  0  0  0 -r  0  0  0   % finger1-disk           (other)
     -1  0  0  0  r  0  0  0  0   % finger2-disk           (other)
     -1  0  0  0  0  r  0  0  0]; % disk-floor             (other)
J(:,4:6) = J(:,4:6)*R;


% Step without contact impulses
v_next = (v + M\Fext*h);
q_next(q:7) = int_body(q(1:7), v_next(1:6), h);
q_next(8:10) = q(8:10) + h*v_next(7:9);

psi2 = [r - q_next(10)
       q_next(10)
       q_next(8) - q_next(2) - r
       q_next(2) - q_next(9) - r
       q_next(3) - r];

% Identify active contacts
c_active = psi2 < 0.01;
J = J([c_active; c_active; c_active],:);
psi = psi(c_active);
mu = mu(c_active);

x = NaN(3*size(c_active,1),1);
if any(c_active)
    % Solve contact dynamics
    [v_next, x_active]  = step_fun(v, Fext, M, J, mu, psi, h);
    q_next = q;
    q_next(q:7) = int_body(q(1:7), v_next(1:6), h);
    q_next(8:10) = q(8:10) + h*v_next(7:9);
    x([c_active; c_active; c_active]) = x_active;
end

st = [q_next; v_next];
end