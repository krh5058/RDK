function region = rdkComputeRegion( fr, region )
% rdkComputeRegion -- computes current region parameters for RDK
%
% region = rdkComputeRegion( fr, dotstim  )

%----   Called by
%   rdkShowStimuli

%----   Features/bugs
%   081214  exp_ring mode works reasonably well, but ring disappears at edge
%           There is a problem with the rot_wedge mode in updating dot
%           positions so that dot density remains constant and stray dots
%           are not plotted.  Otherwise, very cool!

%----   History
%   081214  rog wrote.


% region = dotstim.region;

switch region.space_mod_mode
    case 'exp_ring'
        % compute current phase
        cycle_phase = ( ( mod(fr, region.space_mod_period_fr )+1)/region.space_mod_period_fr )*2*pi;

        % leading edge is at 0 phase + ring width
        rmaxx = region.rminmax_static_pix(1) + cycle_phase * region.ring_width_pix;

        rminn = rmaxx - region.space_duty_cycle * region.ring_width_pix;
        region.rminmax_pix = [ rminn rmaxx ];
    case 'rot_wedge'
        % leading edge is at 0 phase + wedge width
        tmaxx = ((mod(fr, region.space_mod_period_fr)+1)/region.space_mod_period_fr)*2*pi;
        tminn = tmaxx - region.space_duty_cycle * 2*pi;
        region.tminmax = [ tminn tmaxx ];
    case 'none'
        return;
    otherwise
        error('region_mode misspecified.\n');
end

return
