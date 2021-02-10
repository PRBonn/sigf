function f = helperfunctions
% status 2016-06-28

%% Operatoren
f.skew = @(x) [0, -x(3), x(2); x(3), 0, -x(1); -x(2), x(1), 0];
f.deskew = @(x) [-x(2,3); x(1,3); -x(1,2)];
f.vec = @(x) x(:);
f.uvec = @(d,n) (1:d == n)';

%% WF Operatoren
f.pi_ = @(A) [f.skew(A(1:3)), zeros(3,1); A(4)*eye(3), -A(1:3)];


%% Rotationen
% Rotationsmatrix
f.rot = @(phi, a) circshift( ...
    blkdiag([cos(phi), -sin(phi); sin(phi), cos(phi)], 1), a * [1 1]);
f.rot_2d = @(phi) [cos(phi), -sin(phi); sin(phi), cos(phi)];
f.ab2R = @(a, b) R_from_a_b( a, b );
f.rotM = @(phi, a) [f.rot(phi, a), zeros(3,1); 0 0 0 1];
% kleine Rotationen
f.Rdr = @(dr) (eye(3) + f.skew(dr)) / (eye(3) - f.skew(dr));
f.Rdr_2d = @(dr)([1 -dr; dr 1]/[1 dr; -dr 1]);
f.Sdr = @(dR) (eye(3) + dR) \ (eye(3) - dR);
% Rotationswinkel (Rx*Ry*Rz)
f.R2w = @(R) [atan2(R(3,2),R(3,3)); atan2(-R(3,1),sqrt(R(3,2)^2+R(3,3)^2)); atan2(R(2,1),R(1,1))];
% Rotationsvektor (Achse+Winkel)
f.R2r = @(R) rotationvectorFromR( R );
f.r2R = @(r) cos(norm(r))*eye(3) + (1-cos(norm(r)))*(r*r')./(r'*r) + sin(norm(r))*f.skew(r./norm(r));
% Quaternionen
f.q2R = @(q) 1/(q(1)^2+q(2)^2+q(3)^2+q(4)^2)* ...
[q(1)^2 + q(2)^2 - q(3)^2 - q(4)^2, 2*(q(2)*q(3)- q(1)*q(4)), 2*(q(2)*q(4)+ q(1)*q(3));
2*(q(3)*q(2)+ q(1)*q(4)), q(1)^2 - q(2)^2 + q(3)^2 - q(4)^2, 2*(q(3)*q(4)- q(1)*q(2));
2*(q(4)*q(2) - q(1)*q(3)), 2*(q(4)*q(3)+ q(1)*q(2)), q(1)^2-q(2)^2-q(3)^2+q(4)^2];
f.q2R_ros = @(q) f.q2R( [q(4);q(1);q(2);q(3)] );
f.R2q = @(R) R2q_(R);
f.mult_q = @(p, r) [p, [-p(2 : 4)'; p(1) * eye(3) + f.skew(p(2 : 4))]] * r;
f.Mq = @(q) [q(1), -q(2:4)'; q(2:4), q(1)*eye(3)+f.skew(q(2:4))];
f.Mq_ = @(q) [q(1), -q(2:4)'; q(2:4), q(1)*eye(3)-f.skew(q(2:4))];
f.qinv = @(q) [q(1); -q(2:4)] ./ (q'*q);

%% Homogene Koordinaten
f.normE = @(x) x ./ x(end * ones(1, end), :);
f.normS = @(x) x ./ sqrt(ones(size(x, 1)) * x.^2);
f.hom2euc = @(x) x(1 : end - 1, :) ./ x(end * ones(1, end - 1), :);
f.euc2hom = @(x) [x; ones(1, size(x, 2))];
f.posHom = @(x) x ./ sign(x(end * ones(1, end), :));

%% Homogene Matrizen
f.M = @(R,t) [R, t; 0 0 0 1];

%% Jakobi-Matrizen
f.JnormS = @(x) (eye(size(x, 1)) - x * x' / (x' * x)) / norm(x);
f.JnormE = @(x) ( 1/x(end)^2 * ...
    [ x(end)*eye(length(x)-1), -x(1:length(x)-1); zeros(1,length(x)) ] );
  
%% Numerical Jacobian
f.jacobian_num = @(fctn,v,h) jacobian_num_(fctn,v,h);

%% helpfull functions
f.round_in_bounds = @(x,bounds) round( max( min( x, bounds(2) ), bounds(1) ) );
f.getCols = @(x,a,b) x(:,a:b);
f.getRows = @(x,a,b) x(a:b,:);

%% geometry
f.angle_two_vectors = @(x,y) acos( x'*y / (norm(x)*norm(y)) ); 

%% image geometry
f.fip2ray = @(x,h,c) f.normS( [((x-h)/c).*(sin(norm((x-h)/c))/norm((x-h)/c)); cos(norm((x-h)/c))] ); % not tested yet
f.ray2fip = @(x,h,c) (c*atan2(norm(x(1:2)),x(3))/norm(x(1:2))).*x(1:2) + h; % not tested yet
f.pip2ray = @(x,h,c) f.normS( [((x-h)/c); 1] ); % not tested yet
f.ray2pip = @(x,h,c) (c/x(3)).*x(1:2) + h; % not tested yet
% f.eip2ray = @(x,h,c) f.normS( ... );
% f.sip2ray = @(x,h,c) f.normS( ... );



%% numerical jacobian
function J = jacobian_num_( fctn, v, h )
% INPUT:   fctn   function handle
%          v      values for constants
%          h      step size for each parameter
% OUTPUT:  J      jacobian

dim = length( h );
J = zeros( 1, dim );
for i = 1 : dim
  h_i = zeros( dim, 1 );
  h_i(i) = h(i);
  J(i) = (fctn(v,h_i)-fctn(v,-h_i))/(2*h(i));
end

return



%% quaternion from rotation matrix
function q = R2q_( R )

[theta, r] = angleAndAxisFromR( R );
q = [ cos( theta / 2 ); sin( theta / 2 ) .* r ];

return


%% rotationvector from rotation matrix
function r = rotationvectorFromR( R )

[theta, r] = angleAndAxisFromR( R );
r = theta * r;

return


%% rotation angle and axis from rotation matrix
function [theta, r] = angleAndAxisFromR( R )

% precalculations
tr = trace( R );
a = - [ R(2,3)-R(3,2); R(3,1)-R(1,3); R(1,2)-R(2,1) ];

% rotation angle
theta = atan2( norm(a), tr-1 );

% check three cases because of singularities
if abs( theta ) < eps 
    % i) null rotation
    r = [1; 0; 0];
    theta = 0;
elseif abs( theta - pi ) < eps
    % ii) rotation angle smaller than 180 degrees
    theta = pi;
    D = ( R + eye(3) );
    % choose columns with smalles amount
    [m, i] = max( diag(D) );
    ru = D( :, i );
    r = ru/norm(ru);
else
    % iii) if rotation angle within (0,180) degrees
    r = a / norm(a);
end

return


%% rotation matrix from one, two or three vector pairs such that b=R*a
function R = R_from_a_b( a, b )
% INPUT:   a   3d vector(s)
%          b   rotated 3d vector(s)
% OUTPUT:  R   3x3 rotation matrix

% number of vector pairs
nbr_pairs = size( a, 2 );

% determine rotation matrix
switch nbr_pairs
  case 1
    R = eye(3) + 2.*b*a' -1/(1+a'*b) * (a+b) * (a+b)';
  case 2
    a = [ a, cross(a(:,1),a(:,2)) ];
    b = [ b, cross(b(:,1),b(:,2)) ];
    R = b / a;
    [U, S, V] = svd( R );
    R = U * V';
  case 3
    R = b / a;
    [U, S, V] = svd( R );
    R = U * V';
end

return