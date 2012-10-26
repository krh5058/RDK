function dots = rdkBoundsCheck( dots, region )
% rdkBoundsCheck -- finds dots out of bounds
%
% dotstim = rdkBoundsCheck( dotstim )

%----   Calls

%----   Called by
% rdkShowStimuli

%----   Feature adds/bugs
% 1. Additional region.shape modes

%----   History
% 081213 rog wrote.

%----   Bounds check depends on boundary shape (mode)
% dots = dotstim.dots;
% region = dotstim.region;

switch region.shape
    case {'circle', 'annulus'}
        r = dots.rt(:,1);
        dout = find( ( r > region.rminmax_pix(:,2) ) |...
                     ( r < region.rminmax_pix(:,1) ) );    
    case 'wedge'
        r = dots.rt(:,1); t = dots.rt(:,2);
        dout = find( ( r > region.rminmax_pix(:,2) ) |...
                     ( r < region.rminmax_pix(:,1) ) |...
                     ( t > region.tminmax(:,2) ) |...
                     ( t < region.tminmax(:,1) ) );    
    case 'rect'
        h = dots.xy(:,1);
        v = dots.xy(:,2);
        
        % if out of bounds regenerate in bounds        
        dout = find( ( h > region.hminmax_pix(2) ) |...
            ( h < region.hminmax_pix(1) ) |...
            ( v > region.vminmax_pix(2) ) |...
            ( v < region.vminmax_pix(1) )...
            );
    otherwise
        error('bounds_mode specified improperly');
end % switch

%----   If dots out > fraction to kill, don't kill
fout = length( dout )/dots.ndots; % out in space
if fout >= dots.f_kill
    dots.out_index = dout;
else
    dkill = find( rand(dots.ndots,1) < dots.f_kill );
    dots.out_index = unique( union( dout, dkill ) );
end

dots.nout = length( dots.out_index );
% dotstim.dots = dots;

return
