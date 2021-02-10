function plot_pose_3d( M, varargin )
% (c) Johannes Schneider, 2015

% parse parameters
if numel(varargin) == 1, params = varargin{1};
else params = parseparams(varargin{:}); end

t = M( 1:3, 4 );
R = M( 1:3, 1:3 )';

if isempty(params.color)
  quiver3( t(1), t(2), t(3), R(1,1), R(1,2), R(1,3), params.length, 'Color','red', 'LineWidth', params.width );
  quiver3( t(1), t(2), t(3), R(2,1), R(2,2), R(2,3), params.length, 'Color','green', 'LineWidth', params.width );
  quiver3( t(1), t(2), t(3), R(3,1), R(3,2), R(3,3), params.length, 'Color','blue', 'LineWidth', params.width );
else
  quiver3( t(1), t(2), t(3), R(1,1), R(1,2), R(1,3), params.length, 'Color',params.color, 'LineWidth', params.width );
  quiver3( t(1), t(2), t(3), R(2,1), R(2,2), R(2,3), params.length, 'Color',params.color, 'LineWidth', params.width );
  quiver3( t(1), t(2), t(3), R(3,1), R(3,2), R(3,3), params.length, 'Color',params.color, 'LineWidth', params.width );
end

if ~isempty(params.id)
  text( t(1), t(2)+params.length/4, t(3), [' ',num2str(params.id)] )
end
  
return;


% input parameter parser
function params = parseparams( varargin )

% default parameters
params.length = 1;
params.width  = 2;
params.color = '';
params.id = '';

% modifications via optional parameters
for i = 1 : 2 : numel(varargin) - 1
  if ismember(varargin{i}, fieldnames(params))
    params.(varargin{i}) = varargin{i + 1};
  else
    error('Unknown parameter ''%s''.', varargin{i});
  end
end