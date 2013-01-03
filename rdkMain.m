varpick = 'oldload';

warning('off','MATLAB:TIMER:RATEPRECISION');

switch varpick
    case 'prepare'
        
        prepare_n = input('Enter number of iterations:\n');
        
        for i = 1:prepare_n
            
            fprintf('RDK: Preparing iteration %i.\n', prepare_n); % Report
            
            % Property values
            sys = ObjSet.SysCheck;
            exp = ObjSet.ExpSet(sys);
            pres = ObjSet.PresSet(sys);
            
            % Object definition
            obj = ObjSet(sys,exp,pres);
            obj.batchDot;
            clear obj
            
        end
    
    case 'newrun'
        
        % Property values
        sys = ObjSet.SysCheck;
        exp = ObjSet.ExpSet(sys);
        pres = ObjSet.PresSet(sys);
        
        % Object definition
        obj = ObjSet(sys,exp,pres);
        obj.batchDot;
        
    case 'oldload'
        
        % Old property values
        [f,p] = uigetfile;
        fprintf('RDK: Loading object (%s).  One moment.\n', [p f]); % Report
        old_instance = load([p f]);
        old_strval = fieldnames(old_instance);
%         
%         % Screen set-up
%         obj.sys.display.w = obj.pres.open(eval([oldstrval{1} '.sys.display.screenNumber']),eval([old_strval{1} '.sys.display.black']),eval([old_strval{1} '.sys.display.stereo'])); % Open Window
%         
        % Object definition
        obj = ObjSet(eval(['old_instance.' old_strval{1} '.sys']),eval(['old_instance.' old_strval{1} '.exp']),eval(['old_instance.' old_strval{1} '.pres']));
        obj.dotStore = old_instance.(old_strval{1}).dotStore;
        obj.out = old_instance.(old_strval{1}).out;
        
    otherwise
        
        error('RDK: Invalid option.')
      
end

% Initialization
PsychJavaTrouble();
addpath(obj.exp.path); % Add path
KbName('UnifyKeyNames'); % Unify keys
obj.start_key = KbName('Space'); % Define start_fcn keys in obj properties
esckey = KbName('Escape');
lkey = KbName('LeftArrow');
rkey = KbName('RightArrow');
obj.timer_key = [esckey lkey rkey]; % Define timer_fcn keys in obj properties
% ListenChar(2);
HideCursor;

% Output Setup
out = cell([size(obj.out,1) size(obj.out,2)+3]); % obj.out with 3 columns for L/R response, RT, and Acc
out(1:size(obj.out,1),1:size(obj.out,2)) = obj.out;
LRkey = cellfun(@(y2)(~isempty(y2)),cellfun(@(y)(find(y)),obj.out(:,4:5),'UniformOutput',false)); % If isn't empty (aka coherent), then matrix index will contain '1'

% Screen and timer set-up
obj.sys.display.w = obj.pres.open(obj.sys.display.screenNumber,obj.sys.display.black,obj.sys.display.stereo); % Open Window
obj.tGen;

% Display sequence
esc_flag = 0;

for block_i = 1:obj.exp.block % For each block
    for trial_i = 1:obj.exp.trial_n % For each trial
        start(obj.t); % Start timer
        keyFlag = 1; % Key flag to prevent multiple press entries
        while strcmp(obj.t.Running,'on') % While the timer is running
            if keyFlag 
                [keyIsDown,secs,keyCode] = KbCheck;
                if keyIsDown
                    
                    if find(keyCode) == esckey % If escape
                        disp('esc')
                        esc_flag = 1;
                        stop(obj.t);
                        fprintf('RDK: Aborting display sequence. \n');
                        Screen('CloseAll');
                    end
                    
                    if find(keyCode) == lkey % If left arrow press
                        disp('l')
                        resp = 'L';
                        respchk = 1;
                        stop(obj.t);
                        keyFlag = 0;
                    elseif find(keyCode) == rkey % If right arrow press
                        disp('r')
                        resp = 'R';
                        respchk = 2;
                        stop(obj.t);
                        keyFlag = 0;
                    end
                    
                    nextcell = find(cellfun(@isempty,out(:,size(obj.out,2)+1)),1); % Next empty cell
                    out{nextcell,size(obj.out,2)+1} = resp; % Log response
                    out{nextcell,size(obj.out,2)+2} = secs - obj.t.UserData; % Log RT
                    out{nextcell,size(obj.out,2)+3} = LRkey(nextcell,respchk); % Log LRkey entry
                    
                end
            end
        end
        if esc_flag
            break;
        else
            obj.pres.trial_count = trial_i; % Adding to presentation trial_count
        end
    end
    if esc_flag
        break;
    else
        obj.pres.block_count = block_i; % Adding to presentation block_count
    end
end

% Clean-up
fprintf('RDK: Writing data output (%s). \n', [obj.exp.objpath filesep 'out.csv']);
cell2csv([obj.exp.objpath filesep 'out.csv'],out); % Write output
ListenChar(0);
ShowCursor;