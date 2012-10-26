function ph = rdkPlotTrialRegion( trial )

plotcolors = {'b', 'r'};

for s = 1:trial.ndotstim
    switch trial.dotstim(s).region.shape
        case {'annulus', 'wedge', 'circle'}
            th = linspace(trial.dotstim(s).region.tminmax(1), trial.dotstim(s).region.tminmax(2), 100);
            rmin = trial.dotstim(s).region.rminmax_pix(1)*ones( size( th ) );
            rmax = trial.dotstim(s).region.rminmax_pix(2)*ones( size( th ) );
            ph = polar( th, rmax, plotcolors{s} );
            hold on
            ph = polar( th, rmin, plotcolors{s} );       
        case {'rectangle'}
        otherwise
    end % switch trial...
end % for s
hold off
axis square

return