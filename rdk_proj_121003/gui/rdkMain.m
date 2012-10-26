function rdkMain( varargin )
% rdk -- Random Dot Kinematogram display program
%
% rdk( [param_fn] )

%----   History
%   0812xx  rog modified from DotDem_rog to make more modular

%---    Extract data from command line
if nargin < 1
    struct_fn = [];
else
    struct_fn = varargin{1};
    disp( sprintf( '[%s]: Struct filename: %s.', mfilename, struct_fn ) );
end

%----   Get user parameters and compute dependent parameters
params = setRDKparams;

disp( sprintf('[%s]: Generating initial dot patterns.', mfilename ) );
params.dots = generateRDKdots( params.dots, params.bounds );

%----   Compute motion motion matrix
disp( sprintf('[%s]: Generating initial motion gradient.', mfilename ) );
params.motion = compute_motion_gradient( params );

if params.control.save_struct
    save_dots_struct( params, struct_fn );
end

%----   Show stimuli
params = showRDKstimuli( params );

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%