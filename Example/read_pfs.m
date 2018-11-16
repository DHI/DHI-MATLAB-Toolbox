% Example of reading a pfs file, modifying a parameter and saving it again.

filename = 'data/plot_oresund.plc';

pfs = mzReadPFS(filename);

pfs.Sections.MIKE_ZERO_PLOT_COMPOSER{1}.Sections.ANIMATION_SETUP{1}.Keys.StartTime
pfs.Sections.MIKE_ZERO_PLOT_COMPOSER{1}.Sections.ANIMATION_SETUP{1}.Keys.StartTime{1} = '1980, 1, 1, 1, 0, 0';

mzWritePFS('test_plot.plc',pfs);