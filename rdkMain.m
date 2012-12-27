varpick = 'load';

switch varpick
    case 'new'

        sys = ObjSet.SysCheck;
        exp = ObjSet.ExpSet(sys);
        pres = ObjSet.PresSet(sys);
        obj = ObjSet(sys,exp,pres);
        obj.batchDot;

    case 'load'

        [f,p] = uigetfile;
        load([p f],'mat');
        
    otherwise
        
        error('RDK: Invalid option.')
        
end

% Initialization
addpath(obj.exp.path); % Add path
KbName('UnifyKeyNames'); % Unify keys
ListenChar(2);
HideCursor;

% Output Setup
out = cell([size(obj.out,1) size(obj.out,2)+3]); % obj.out with 3 columns for L/R response, RT, and Acc
out(1:size(obj.out,1),1:size(obj.out,2)) = obj.out;
LRkey = cellfun(@(y)(~isempty(y)),obj.out(:,4:5)); % If isn't empty (aka coherent), then matrix index will contain '1'

% Display sequence
obj.sys.display.w = obj.pres.open(obj.sys.display.screenNumber,obj.sys.display.black,obj.sys.display.stereo); % Open Window

% for i = 1:600
%     obj.pres.draw_fun(dot{1,1}(:,:,i,1),obj.sys.display.w);
%     obj.pres.selectstereo_fun(obj.sys.display.w,1);
%     obj.pres.draw_fun(dot{1,1}(:,:,i,2),obj.sys.display.w);
%     pause(.03);
%     obj.pres.flip_fun(obj.sys.display.w);
% end

for block_i = 1:obj.exp.block % For each block
    for trial_i = 1:obj.exp.trial_n % For each trial
        start(obj.t); % Start timer
        keyFlag = 1; % Key flag to prevent multiple press entries
        while strcmp(obj.t.Running,'on') % While the timer is running
            if keyFlag 
                [keyIsDown,secs,keyCode] = KbCheck;
                if keyIsDown
                    
                    if KbName('Escape') % If escape
                        error('Erroring out of timer.');
%                         stop(obj.t);
                    end
                    
                    if KbName('LeftArrow') % If left arrow press
                        
                        resp = 'L';
                        respchk = 1;
                        stop(obj.t);
                        keyFlag = 0;
                        
                    elseif KbName('RightArrow') % If right arrow press
                        
                        resp = 'R';
                        respchk = 2;
                        stop(obj.t);
                        keyFlag = 0;
                        
                    end
                    
                    nextcell = find(cellfun(@isempty,out(:,size(obj.out,2)+1)),1); % Next empty cell
                    out{nextcell,size(obj.out,2)+1} = resp; % Log response
                    out{nextcell,size(obj.out,2)+2} = obj.t.UserData - secs; % Log RT
                    out{nextcell,size(obj.out,2)+3} = LRkey(nextcell,respchk); % Log LRkey entry
                    
                end
            end
        end
        obj.pres.trial_count = trial_i; % Adding to presentation trial_count
    end
    obj.pres.block_count = block_i; % Adding to presentation block_count
end

% Clean-up
cell2csv([obj.exp.path filesep 'out.csv'],out); % Write output
ListenChar(0);
ShowCursor;