% mitgcm binary output --> netCDF
close all
clear all

% set source dir
sdir = './'

% read in file name
input.fin  = [sdir,'SSH'];
input.fout = {'SSH'};
input.vname= {'SSH'};
input.longname = {'Sea Surface Height'};
input.unit     = {'m'};
input.modelsrc = 'MITgcm Regional Southern Ocean';

% model time step
input.dT   = 900;
input.YR0  = 0;

% model coordinate
input.x = [sdir,'XC'];
input.y = [sdir,'YC'];
input.zc = [sdir,'RC'];
input.zf = [sdir,'RF'];

% call rdmds_nc function;
rdmds_nc(input);

% read in file name
input.fin  = [sdir,'Phyto'];
input.fout = {'diatom' 'lgeuk' 'synecho' 'prochlo' 'n2fix' 'cocco'};
input.vname= {'diatom' 'lgeuk' 'synecho' 'prochlo' 'n2fix' 'cocco'};
input.longname = {'diatom' 'large eukeryotes' 'synechococcus' 'prochlococcus' 'nitrogen fixer' 'coccolithphorid'};
input.unit     = {'mmolP/m3' 'mmolP/m3' 'mmolP/m3' 'mmolP/m3' 'mmolP/m3' 'mmolP/m3'};
rdmds_nc(input);

% read in file name
input.fin  = [sdir,'NutGas'];
input.fout = {'po4' 'no3' 'dfe' 'sio2' 'dic' 'alk' 'o2'};
input.vname = input.fout;
input.longname = input.fout;
input.unit     = {'mmol/m3' 'mmol/m3' 'mmol/m3' 'mmol/m3' 'mmol/m3' 'mmol/m3' 'mmol/m3'};
rdmds_nc(input);

% read in file name
input.fin  = [sdir,'CChem'];
input.fout = {'co2flux' 'pco2' 'ph'};
input.vname = input.fout;
input.longname = input.fout;
input.unit     = {'mmolC/m2/sec' 'atm' 'ND'};
rdmds_nc(input);

% read in file name
input.fin  = [sdir,'Prod'];
input.fout = {'pp' 'par'};
input.vname = input.fout;
input.longname = {'Primary Production' 'PAR'};
input.unit     = {'mmolP/m3/sec' 'uEin/m^2/s'};
rdmds_nc(input);

% read in file name
input.fin  = [sdir,'U'];
input.fout = {'U'};
input.vname= {'U'};
input.longname = {'Zonal velocity'};
input.unit     = {'m per sec'};

% call rdmds_nc function;
rdmds_nc(input);

% read in file name
input.fin  = [sdir,'V'];
input.fout = {'V'};
input.vname= {'V'};
input.longname = {'Meridional velocity'};
input.unit     = {'m per sec'};

% call rdmds_nc function;
rdmds_nc(input);

% read in file name
input.fin  = [sdir,'W'];
input.fout = {'W'};
input.vname= {'W'};
input.longname = {'Vertical velocity'};
input.unit     = {'m per sec'};

% call rdmds_nc function;
rdmds_nc(input);

% read in file name
input.fin  = [sdir,'T'];
input.fout = {'T'};
input.vname= {'T'};
input.longname = {'potential temperature'};
input.unit     = {'degree C'};

% call rdmds_nc function;
rdmds_nc(input);

% read in file name
input.fin  = [sdir,'S'];
input.fout = {'S'};
input.vname= {'S'};
input.longname = {'salinity'};
input.unit     = {'psu'};

% call rdmds_nc function;
rdmds_nc(input);

% read in file name
input.fin  = [sdir,'MLD'];
input.fout = {'MLD'};
input.vname= {'MLD'};
input.longname = {'mixed layer depth'};
input.unit     = {'m'};

% call rdmds_nc function;
rdmds_nc(input);

% read in file name
input.fin  = [sdir,'VORT'];
input.fout = {'VORT'};
input.vname= {'VORT'};
input.longname = {'vertical component of 3D vorticity'};
input.unit     = {'m'};

% call rdmds_nc function;
rdmds_nc(input);


