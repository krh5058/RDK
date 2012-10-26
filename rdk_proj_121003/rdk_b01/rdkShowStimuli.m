function params = rdkShowStimuli( params, w )
% rdkShowStimuli -- shows RDK show stimulus array
% params = rdkShowStimuli( params, w )

%----   Calls
%   rdkComputeGradient
%   rdkBoundsCheck
%   rdkGenerateDots
%
%---    Called by
%   rdk

%----   Features to add/fix:
%   081214  Facility to pregenerate dot coords before trial then show movie
%   081214  Fix compute_dotpatch routine so that frame-dependent changes in
%           dot region can be computed.
%   081214  Fix rdkComputeGradient so that frame- or time-dependent changes in
%           motion gradient are allowed.
%   081214  Better user input handling (which keypress, choice recording, etc.)
%   081214  Changing fixation color or shape for retinotopic imaging
%   081214  Hooks for external device signaling.
%   081214  For runtime modes, breaks between blocks, instruction screens.
%   081214  Dot replotting in linear_const mode results in artefact.  Should
%           appear on opposite side of annulus/region.  With annulus/circle,
%           this can be achieved by keeping r fixed and rotating theta (t)
%           by pi radians.  When region is square/rect, the signs of both x
%           and y coordinates should be changed.
%   081214  Best to open and close window at the start of each block or
%           once each experiment?

%----   History
% 081213    rog modified from earlier version of non-structured code.
% 080122    rog added verbose control to experimenter feedback.

%--------------------------------------------------------------------------

exp = params.exp;
display = params.display;
% control = params.control;

%---    Prepare to use toolbox OpenGL routines
AssertOpenGL;

%----   Initialize Psychtoolbox mex functions so calls are fast

KbCheck; GetSecs; WaitSecs(0.001); GetMouse();

% for b = 1:exp.nblocks
  
b = 1; % Temp index
count = 1;
keyIsDown = 0; % Reset keyIsDown
if ispc
    escMap = 27;
elseif ismac
    escMap = 41;
end

% Output prep
fid = fopen([params.exp.datadir datestr(date,'yymmdd') '_' exp.subjID '.csv'],'a');
fprintf(fid,'%s,%s,%s,%s,%s,%s\n','Subject','Trial','LeftPattern','RightPattern','Response','RT');

while count <= exp.ntrials
    
    % before block stuff...
    if params.control.verbose
        disp(sprintf('[%s]: Starting block %d of %d.', mfilename, b, exp.nblocks ) );
    end
    
    try
        %----    Skip synch tests if debugging
        if params.control.verbose
            disp(sprintf('[%s]: Screen debug off.', mfilename) );
            Screen('Preference','SkipSyncTests', 0);
        else
            %             disp(sprintf('[%s]: Screen debug on.', mfilename) );
            %             Screen('Preference','SkipSyncTests', 1);
            Screen('Preference','SkipSyncTests', 0);
        end

        for t = 1:exp.block(b).ntrials

            trial = exp.block(b).trial(t);
            if params.control.verbose
                disp(sprintf('[%s]: Trial %d of %d.', mfilename, t, exp.block(b).ntrials ) );
            end
            
            %----    Open screen
            if params.control.verbose
                disp(sprintf('[%s]: Opening participant screen.', mfilename ));
            end
            
%             if params.exp.dual
%                 w = Screen('OpenWindow', params.display.screenNumber, 0,[], 32, params.display.doublebuffer+1,4);
%             else
%                 w = Screen('OpenWindow', params.display.screenNumber, 0,[], 32, params.display.doublebuffer+1);
%             end      

%             Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
%             
%             HideCursor;
%             Priority( MaxPriority(w) );

            dotstim = trial.dotstim;

            %----   Animation loop
            buttons = 0;
            loop_start = GetSecs;
            vbl = Screen( 'Flip', w );
            
            % For 4-phase motion correction
            time_mod_period_fr = dotstim(1).motion(1).time_mod_period_fr; % *** Assuming dotstim val is redundant
            old_switchFlag = 0; % Initialize
            
            % Condition coherence
            dotstim(1).motion(1).coh = exp.pres(count,1,:);
            dotstim(1).motion(2).coh = exp.pres(count,2,:);
            
            disp(['Left: ' num2str(exp.pres(count,1,1)) '/' num2str(exp.pres(count,1,2))]);
            disp(['Right: ' num2str(exp.pres(count,2,1)) '/' num2str(exp.pres(count,2,2))]);
            
            for fr = 1:trial(t).duration_fr
%                 if params.control.debug
%                     disp(sprintf('[%s]: Frame %d of %d.', mfilename, fr, trial(t).duration_fr) );
%                 end
                
                if (fr>1)
                    for stereo = 0:exp.dual
                        Screen('SelectStereoDrawBuffer', w, stereo);
                        Screen('FillOval', w, trial.fix(stereo+1).color, trial.fix(stereo+1).coord );	% draw fixation dot (flip erases it)
                        for s=1:trial.ndotstim
                            Screen('DrawDots', w, dotstim(s).dots(stereo+1).xymatrix, dotstim(s).dots(stereo+1).pix, dotstim(s).dots(stereo+1).colors, display.center, dotstim(s).dots(stereo+1).shape );  % change 1 to 0 to draw square dots
                        end             
                    end
                    Screen('DrawingFinished', w); % Tell PTB that no further drawing commands will follow before Screen('Flip')
                end;
                

                [ mx, my, buttons ] = GetMouse( params.display.screenNumber );
                [ keyIsDown, secs, keyCode ] = KbCheck;
                
                if find( buttons ) % break out of loop
                    press_rt = GetSecs - loop_start;
                    disp(find(buttons));
                    disp(press_rt);
                    pause(.3)
                    fprintf(fid,'%s,%d,%s,%s,%d,%6.4f\n',exp.subjID,count,[exp.block.trial.dotstim.motion(1).mode{1} '-' num2str(exp.pres(count,1,1)) '-' num2str(exp.pres(count,1,2))],[exp.block.trial.dotstim.motion(1).mode{1} '-' num2str(exp.pres(count,2,1)) '-' num2str(exp.pres(count,2,2))],find(buttons),press_rt);
                    break;
                elseif keyIsDown
                    if ispc
                        if find(keyCode)==escMap % If Escape
                            disp('User Cancelled.');
                            return;
                        end
                    end
                end; % if
                
                if strcmp('4-phase',dotstim(1).motion(1).time_mod_mode)
                    % Moved from rdkComputeGradient.m, needed to be outside
                    % Add conditional test here to switch sign of motion.mdir
                    % if forward motion cycle occurred last time
                    fr_dur_phase = mod( fr, time_mod_period_fr*2 ) + 1;
                    switchFlag = fr_dur_phase > floor( time_mod_period_fr );
                    if old_switchFlag ~= switchFlag
                        dotstim(1).motion(1).mdir = -1*dotstim(1).motion(1).mdir; % *** Assuming dotstim will only have 1
                        dotstim(1).motion(2).mdir = -1*dotstim(1).motion(2).mdir; % *** Assuming dotstim will only have 1
                        old_switchFlag = switchFlag;
                    end
                end
                        
                %----   Compute motion
                for s=1:trial.ndotstim % Redundant after changes (using exp.ntrial)
                    for d=1:exp.dual+1
                        [ dotstim(s).motion(d).dxdy, dotstim(s).motion(d).drdt ] = rdkComputeGradient( fr, dotstim(s).dots(d), dotstim(s).motion(d) );
                        
                        dotstim(s).dots(d).xy = dotstim(s).dots(d).xy + dotstim(s).motion(d).dxdy;
                        dotstim(s).dots(d).rt = dotstim(s).dots(d).rt + dotstim(s).motion(d).drdt;
                        
                        %----   Determine parameters for dot dotpatch
                        dotstim(s).region(d) = rdkComputeRegion( fr, dotstim(s).region(d) );
                        
                        %----   Determine whether dots are in bounds
                        dotstim(s).dots(d) = rdkBoundsCheck( dotstim(s).dots(d), dotstim(s).region(d) );
                        
                        %----   If some dots are out, regenerate dots and create 2xn dot
                        if dotstim(s).dots(d).nout
                            dotstim(s).dots(d) = rdkGenerateDots( dotstim(s).dots(d), dotstim(s).region(d) );
                        end
                        dotstim(s).dots(d).xymatrix = transpose( dotstim(s).dots(d).xy );
                    end % for s
                end
                
                if (params.display.doublebuffer==1)
                    vbl=Screen('Flip', w, vbl + ( display.waitframes -0.5 )*display.ifi);
                    if isfield(params.control,'movie')
                        Screen('AddFrameToMovie',w,Screen('Rect',w),'frontBuffer', params.control.moviePtr, []);
                    end
                end; % if
            end;
            
            if ~any(buttons) % If no response
                fprintf(fid,'%s,%d,%s,%s,%s,%s\n',exp.subjID,count,[exp.block.trial.dotstim.motion(1).mode{1} '-' num2str(exp.pres(count,1,1)) '-' num2str(exp.pres(count,1,2))],[exp.block.trial.dotstim.motion(1).mode{1} '-' num2str(exp.pres(count,2,1)) '-' num2str(exp.pres(count,2,2))],'NA','NA');
            end
            loop_secs = GetSecs - loop_start;
            press_rt  = loop_secs;
%             Priority(0);
%             ShowCursor
%             Screen('CloseAll');
        end
    catch
        rethrow( lasterror );
%         Priority(0);
%         ShowCursor;
%         Screen('CloseAll');
    end

    trial.frames_shown = fr;
    trial.press_rt = press_rt;
    trial.loop_secs = loop_secs;
    
    if params.control.verbose
        disp(sprintf( '[%s]: %d frames of %d in %2.2f s shown.', mfilename, fr,  trial.frames_shown, trial.loop_secs ) );
    end
    
    count = count + 1;
    pause(.1)
    
end % block loop

return;