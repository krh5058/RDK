function params = rdk( varargin )
% rdk -- Random Dot Kinematogram display program
%
% rdk( [,param_fn] [,verbose])
%   param_fn : string indicating filename for saved parameter struct stored
%   in "params" folder
%       -Ex: rdk('rdk_new.mat')
%   Include 'verbose' if you require extended output:
%       -Ex: rdk('verbose')
%       -Ex: rdk('rdk_new.mat','verbose')

%----   History
% 120727    krh reorganized frontend.  Removed control.debug
% 0812xx    rog modified from DotDem_rog to make more modular
% 081213    rog modified to use high-level data structure
% 081230    rog modified documentation. Built facility to allow default
%           params.

% control.debug = 1;
% control.verbose = 1;
%param_fn = 'rdk_defaults.mat';

%----   Input check
error(nargchk(0,2,nargin)); % 0 to 2 inputs only

PsychJavaTrouble;
rand('state',sum(clock*100));
randn('state',sum(clock*100));

% Directory of this script
file_str = mfilename('fullpath');
[file_dir,~,~] = fileparts(file_str);
file_dir = fileparts(file_dir);

if nargin >= 1
    mov_in = cellfun(@(y)(~isempty(y)),regexp(varargin,'[Mm]ovie'));
    if mov_in % Movie can only be run alone
        control.movie = 1;
        control.verbose = 0;
        param_in = 0;
        intext = ' No input file specified. ';
    else
        verb_in = cellfun(@(y)(~isempty(y)),regexp(varargin,'[Vv]erbose'));    
        if ~verb_in % Check for verbose
            param_in = 1; % Consider varargin{1} to be param_fn
            control.verbose = 0;
        else
            control.verbose = 1;
            fprintf('[%s]: Verbose on. \n', mfilename);
            if any(~verb_in) % Check for anything but verbose
                param_in = find(~verb_in);
            else
                intext = ' No input file specified. ';
                param_in = 0; % No parameter input
            end
        end
    end
else % No input
    param_in = 0; % No parameter input
    control.verbose = 0; % No verbose
    intext = ' No input file specified. ';
end % End if: nargin >= 1

%---- Search param file
if param_in 
    param_fn = varargin{param_in};
    if ispc % OS check
        [~,param_find] = system(['dir /b/s "' file_dir filesep 'params' filesep param_fn '"']);
        if strcmp(param_find(1:end-1),'File Not Found')
            fprintf('[%s]: Parameter file %s not found in params folder. \n', mfilename, param_fn );
            if ~strcmp(input('Generate new parameter file (y/n)?','s'),'y')
                fprintf('[%s]: Aborting. \n', mfilename);
                return;
            else
                intext = ' ';
            end
        end
    elseif ismac
        [~,param_find] = system(['find ' file_dir filesep 'params -name ' varargin{1}]);
        if isempty(param_find)
            fprintf('[%s]: Parameter file %s not found in params folder. \n', mfilename, param_fn );
            if ~strcmp(input('Generate new parameter file (y/n)?','s'),'y')
                fprintf('[%s]: Aborting. \n', mfilename);
                return;
            else
                intext = ' ';
            end
        end
    end
    % Load parameters
    try
        load(param_find(1:end-1));
        fprintf('[%s]: Parameter file %s loaded. \n', mfilename, param_fn );
    catch loadException
    end
end

if ~exist('params','var') % Check if params file exists
    param_fn = ['rdk_' datestr(now,30) '.mat']; % New parameter string
    fprintf('[%s]:%sGenerating new parameter file: %s. \n', mfilename, intext, param_fn);
    
    %----   Get user parameters and compute dependent parameters
    params = rdkGetSetParams_beta( param_fn, control );
    
    % Save param file
    if control.verbose
        fprintf('[%s]: Saving parameter file as %s.', mfilename, param_fn );
    end
    save( [file_dir filesep 'params' filesep param_fn], 'params' );
    
end

% Subj ID
subj_prompt={'Subject ID:'};
subj_name='Enter Subject ID';
subj_numlines=1;
subj_defaultanswer={'1'};
subj_options.Resize='on';
s_name = inputdlg(subj_prompt,subj_name,subj_numlines,subj_defaultanswer,subj_options);
subjID_double = str2double(regexp(s_name{1},'\d','match'));
if length(num2str(subjID_double,'%d')) > 4
    error('Invalid subject ID.  ID must be less than or equal to 4 digits long.');
else
    params.exp.subjID = num2str([zeros(1,4 - length(subjID_double)) subjID_double],'%d'); % Zero-pad if not already.
end

params.exp.datadir = [file_dir filesep 'data' filesep];

%----   Generate stimuli
params.exp = rdkGenerateStimuli( params );

%----   Show stimuli
if ispc
    ShowHideWinTaskbarMex(0)
end

if params.exp.dual
    w = Screen('OpenWindow', params.display.screenNumber, 0,[], 32, params.display.doublebuffer+1,4);
else
    w = Screen('OpenWindow', params.display.screenNumber, 0,[], 32, params.display.doublebuffer+1);
end

Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
HideCursor;
Priority( MaxPriority(w) );

if isfield(control,'movie')
    params.control.moviePtr = Screen('CreateMovie', w, ['"' file_dir filesep 'movie' filesep param_fn(1:end-3) 'mov"'], params.display.width_pix_full, params.display.height_pix,params.display.fps);
end

params = rdkShowStimuli( params, w );

if isfield(control,'movie')
    Screen('FinalizeMovie', params.control.moviePtr);
%     Screen('CloseMovie', params.control.moviePtr);
end

ShowCursor;
Priority( 0 );
Screen('CloseAll');

if ispc
    ShowHideWinTaskbarMex(1)
end

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%