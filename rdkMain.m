varpick = 'newrun';

warning('off','MATLAB:TIMER:RATEPRECISION');
% Error displays
err_disp = {'Test date is not of appropriate length (YYYYMMDD).', ...
    'Test time is not of appropriate length (HHMM).', ...
    'Test date is not numeric.', ...
    'Test time is not numeric.'};


switch varpick
    case 'prepare'
        
        prepare_n = input('RDK: Enter number of iterations:\n');
        fprintf('RDK: Test time and date is required to label each dot set.\n');
        
        % Error displays
        err_disp = {'Test date is not of appropriate length (YYYYMMDD).', ...
            'Test time is not of appropriate length (HHMM).', ...
            'Test date is not numeric.', ...
            'Test time is not numeric.'};
        
        for i = 1:prepare_n
            % User input
            testdate = input('RDK: Enter testing date (YYYYMMDD):','s');
            testtime = input('RDK: Enter testing date (HHMM):','s');
            % String checks
            prep_kick = 0;
            err_h = zeros([1 4]);
            if length(testdate)~=8
                err_h(1) = 1;
                prep_kick = 1;
            end
            if length(testtime)~=4
                err_h(2) = 1;
                prep_kick = 1;
            end
            if isnan(str2double(testdate))
                err_h(3) = 1;
                prep_kick = 1;
            end
            if isnan(str2double(testtime))
                err_h(4) = 1;
                prep_kick = 1;
            end
            
            if prep_kick
                for err_i = 1:length(err_h)
                    if err_h(err_i)
                        fprintf('RDK: %s\n',err_disp{err_i});
                    end
                end
                error('RDK: Rerun script with appropriate time and date entries.');
            else
                subjstr = [testdate '_' testtime];
            end
            
            fprintf('RDK: Preparing iteration %i.\n', prepare_n); % Report
            % Property values
            sys = ObjSet.SysCheck;
            exp = ObjSet.ExpSet(sys,subjstr);
            pres = ObjSet.PresSet(sys);
            
            % Object definition
            obj = ObjSet(sys,exp,pres);
            obj.batchDot;
            clear obj
            
        end
        return; % Exit script
    
    case 'newrun'
        % User input
        testdate = input('RDK: Enter testing date (YYYYMMDD):','s');
        testtime = input('RDK: Enter testing date (HHMM):','s');
        % String checks
        kick = 0;
        err_h = zeros([1 4]);
        if length(testdate)~=8
            err_h(1) = 1;
            kick = 1;
        end
        if length(testtime)~=4
            err_h(2) = 1;
            kick = 1;
        end
        if isnan(str2double(testdate))
            err_h(3) = 1;
            kick = 1;
        end
        if isnan(str2double(testtime))
            err_h(4) = 1;
            kick = 1;
        end
        
        if kick
            for err_i = 1:length(err_h)
                if err_h(err_i)
                    fprintf('RDK: %s\n',err_disp{err_i});
                end
            end
            error('RDK: Rerun script with appropriate time and date entries.');
        else
            subjstr = [testdate '_' testtime];
        end
        
        % Property values
        sys = ObjSet.SysCheck;
        exp = ObjSet.ExpSet(sys,subjstr);
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
spkey = KbName('Space'); 
esckey = KbName('Escape');
lkey = KbName('LeftArrow');
rkey = KbName('RightArrow');
obj.start_key = [spkey esckey]; % Define start_fcn keys in obj properties
obj.timer_key = [lkey rkey esckey]; % Define timer_fcn keys in obj properties
% ListenChar(2);
HideCursor;

% Output Setup
out = cell([size(obj.out,1) size(obj.out,2)+3]); % obj.out with 3 columns for L/R response, RT, and Acc
out(1:size(obj.out,1),1:size(obj.out,2)) = obj.out;
LRkey = cellfun(@(y2)(~isempty(y2)),cellfun(@(y)(find(y)),obj.out(:,4:5),'UniformOutput',false)); % If isn't empty (aka coherent), then matrix index will contain '1'

% Starting window set-up
Screen('Preference','SkipSyncTests',2);
obj.sys.display.temp_w = obj.pres.open(obj.sys.display.screenNumber,obj.sys.display.black,0); % Open Window
RestrictKeysForKbCheck(spkey);
obj.begin_fcn; % Display starting text

% Screen and timer set-up
Screen('Preference','SkipSyncTests',0);
obj.sys.display.w = obj.pres.open(obj.sys.display.screenNumber,obj.sys.display.black,obj.sys.display.stereo); % Open Window
obj.tGen;

% Display sequence
obj.pres.esc_flag = 0;

for block_i = 1:obj.exp.block % For each block
    obj.pres.block_count = block_i; % Changing presentation block_count
    for trial_i = 1:obj.exp.trial_n % For each trial
        obj.pres.trial_count = trial_i; % Changing presentation trial_count
        keyFlag = 1; % Key flag to prevent multiple press entries
        resp = ' '; % Reset response
        respchk = []; % Reset response accuracy check index
        keyCode = []; % Reset keyCode
        start(obj.t); % Start timer
        while strcmp(obj.t.Running,'on') % While the timer is running
            if keyFlag
                [keyIsDown,secs,keyCode] = KbCheck;
                if keyIsDown
                    stop(obj.t)
                    keyFlag = 0;
                    if find(keyCode) == esckey % If escape
                        obj.pres.esc_flag = 1;
                        fprintf('RDK: Aborting display sequence. \n');
                        Screen('CloseAll');
                    end
                end
            end
        end
        if obj.pres.esc_flag
            break;
        end
        if find(keyCode) == lkey % If left arrow press
            resp = 'L';
            respchk = 1;
        elseif find(keyCode) == rkey % If right arrow press
            resp = 'R';
            respchk = 2;
        end
        % Logging output
        nextcell = find(cellfun(@isempty,out(:,size(obj.out,2)+1)),1); % Next empty cell
        out{nextcell,size(obj.out,2)+1} = resp; % Log response
        if regexp(resp,'\s')
            out{nextcell,size(obj.out,2)+2} = 0; % No RT if no response
        else
            out{nextcell,size(obj.out,2)+2} = secs - obj.t.UserData; % Log RT
        end
        if isempty(respchk)
            out{nextcell,size(obj.out,2)+3} = 0; % Miss if respchk is empty (no response)
        else
            out{nextcell,size(obj.out,2)+3} = LRkey(nextcell,respchk); % Log LRkey entry
        end
    end
    if obj.pres.esc_flag
        break;
    end
end

% Output
fprintf('RDK: Writing data output (%s). \n\n\n', [obj.exp.objpath filesep 'out.csv']);
out_h = {'Block','Trial','PatternType','LeftCoh','RightCoh','Response','RT','Acc'};
cell2csv([obj.exp.objpath filesep 'out.csv'],[out_h; out]); % Write output

% Clean-up
Screen('CloseAll');
ListenChar(0);
ShowCursor;