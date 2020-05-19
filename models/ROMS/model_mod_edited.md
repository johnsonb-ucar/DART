MODULE model\_mod (ROMS)
========================

[NAMELIST](#namelist) / [INTERFACES](#Interface) / [FILES](#FilesUsed) / [REFERENCES](#References) / [ERRORS](#Errors) / [PLANS](#FuturePlans) / [TERMS OF USE](#Legalese)

Overview
--------

This is the DART interface to the [Regional Ocean Modeling System](https://www.myroms.org) - **ROMS**. This document describes the
relationship between ROMS and DART and provides an overview of how to perform ensemble data assimilation with ROMS to provide ocean states that are consistent with the information provided by various ocean observations.

Running ROMS is complicated. It is **strongly** recommended that you become very familiar with running ROMS before you attempt a ROMS-DART assimilation experiment. Running ROMS-DART takes expertise in both areas.

We recommend working through the [DART tutorial](../../documentation/tutorial/index.html) to learn the concepts of ensemble data assimilation and the capabilities of DART.

The ROMS code is not distributed with DART, it can be obtained from the ROMS website <https://www.myroms.org>. There you will also find instructions on how to compile and run ROMS. DART can use the 'verification observations' from ROMS (basically the estimate of the observation at the location and time computed as the model advances) so it would be worthwhile to become familiar with that capability of ROMS. DART calls these 'precomputed forward operators'.

DART can also use observations from the [World Ocean Database](https://www.nodc.noaa.gov/OC5/indprod.html) (WOD). The conversion from the WOD formats to the DART observation sequence format is accomplished by the converters in the *observations/obs\_converters/WOD* directory. They are described by [WOD.html](../../observations/obs_converters/WOD/WOD.html). The DART forward operators require interpolation from the ROMS terrain-following and horizontally curvilinear orthogonal coordinates to the observation location. This capability is still under development.

**A note about file names:** During the course of an experiment, many files are created. To make them unique, the *ocean\_time* is converted from

> "seconds since 1900-01-01 00:00:00"

to the equivalent number of DAYS. An *integer* number of days. The intent is to tag the filename to reflect the valid time of the model state. This could be used as the DSTART for the next cycle, so it makes sense to me.

The confusion comes when applied to the observation files. The input observation files for the ROMS 4DVAR system typically have a DSTART that designates the start of the forecast cycle and the file must contain observation from DSTART to the end of the forecast. Makes sense. The model runs to the end of the forecast, harvesting the verification observations along the way.

So then DART converts all those verification observations and tags that
file ... with the same time tag as all the other output files ... which
reflects the *ocean\_time* (converted to days). The input observation
file to ROMS will have a different DSTART time in the filename than the
corresponding verification files. Ugh. You are free to come up with a
better plan. These are just examples, after all. Hopefully good
examples.

The procedure to perform an assimilation experiment is outlined in the
following steps:

1.  Compile ROMS (as per the ROMS instructions).
2.  Compile all the DART executables (in the normal fashion).
3.  Stage a directory with all the files required to advance an ensemble
    of ROMS models and DART.
4.  Modify the run-time controls in *ocean.in, s4dvar.in* and
    *input.nml*. Since ROMS has a *Bin/subsitute* command, it is used to
    replace temporary placeholders with actual values at various parts
    during the process.
5.  Advance all the instances of ROMS; each one will produce a restart
    file and a verification observation file.
6.  Convert all the verification observation files into a single DART
    observation sequence file with the
    [convert\_roms\_obs.f90](../../observations/obs_converters/ROMS/ROMS.html)
    program.
7.  Assimilate. (DART will read and update the ROMS files directly - no
    conversion is necessary.)
8.  Update the control files for ROMS in preparation for the next model
    advance.

The *shell_scripts* directory has several scripts that are intended to
provide examples. These scripts **WILL** need to be modified to work on
your system and are heavily internally commented. It will be necessary
to read through and understand the scripts. As mentioned before, the
ROMS *Bin/subsitute* command is used to replace temporary placeholders
with actual values at various parts during the process.

| Script      | Description |
| ----------- | ----------- |
| [ensemble.sh](shell_scripts/ensemble.sh) | was written by Hernan Arango to run an ensemble of ROMS models. It is an appropriate example of what is required from the ROMS perspective. It does no data assimilation. |
| [stage\_experiment.csh](shell_scripts/stage_experiment.csh) | prepares a directory for an assimilation experiment. The idea is basically that everything you need should be assembled by this script and that this should only be run ONCE per experiment. After everything is staged in the experiment directory, another script can be run to advance the model and perform the assimilation. *stage\_experiment.csh* will also modify some of the template scripts and copy working versions into the experiment directory. This script may be run interactively, i.e. from the UNIX command line. |
| [submit\_multiple\_cycles\_lsf.csh](shell_scripts/submit_multiple_cycles_lsf.csh) | is an executable script that submits a series of dependent jobs to an LSF queuing system. Each job runs *cycle.csh* in the experiment directory and only runs if the previous dependent job completes successfully. |
| [cycle.csh.template](shell_scripts/cycle.csh.template) | is a non-executable template that is modified by *stage\_experiment.csh* and results in an exectuable *cycle.csh* in the experiment directory. *cycle.csh* is designed to be run as a batch job and advances the ROMS model states one-by-one for the desired forecast length. The assimilation is performed and the control information for the next ROMS forecast is updated. Each model execution and *filter* use the same set of MPI tasks. |
| [submit\_multiple\_jobs\_slurm.csh](shell_scripts/submit_multiple_jobs_slurm.csh) | is an executable script that submits a series of dependent jobs to an LSF queuing system. It is possible to submit **many** jobs the queue, but the jobs run one-at-a-time. Every assimilation cycle is divided into two scripts to be able to efficiently set the resources for each phase. *advance\_ensemble.csh* is a job array that advances each ROMS instance in separate jobs. When the entire job array finishes - and only if they all finish correctly - will the next job start to run. *run\_filter.csh* performs the assimilation and prepares the experiment directory for another assimilation cycle. *submit\_multiple\_jobs\_slurm.csh* may be run from the command line in the experiment directory. Multiple assimilation cycles can be specified, so it is possible to put **many** jobs in the queue.  |
| [advance\_ensemble.csh.template](shell_scripts/advance_ensemble.csh.template) | is a non-executable template that is modified by *stage\_experiment.csh* and results in an exectuable *advance\_ensemble.csh* in the experiment directory. *advance\_ensemble.csh* is designed to submit an job array to the queueing system (PBS,SLURM, or LSF) to advance the ensemble members in separate jobs. |
| [run\_filter.csh.template](shell_scripts/run_filter.csh.template) | is a non-executable template that is modified by *stage\_experiment.csh* and results in an exectuable *run\_filter.csh* in the experiment directory. *run\_filter.csh* is very similar to *cycle.csh* but does not advance the ROMS model instances. |

The variables from ROMS that are copied into the DART state vector are controlled by the *input.nml* *model\_nml* namelist. See below for the documentation on the &model\_nml entries. The state vector should
include all variables needed to apply the forward observation operators as well as the prognostic variables important to restart ROMS.

The example *input.nml* *model\_nml* demonstrates how to construct the DART state vector. The following table explains in detail each entry for the *variables* namelist item:

| Column 1       | Column 2      | Column 3 | Column 4 | Column 5  |
| -------------- | ------------- | -------- | -------- | --------- |
| Variable name  | DART QUANTITY | minimum  | maximum  | update    |

| Value          | Description |
| -------------- | ----------- |
| Variable name  | This is the ROMS variable name as it appears in the ROMS netCDF file. |
| DART QUANTITY  |  This is the character string of the corresponding DART QUANTITY. The complete list of possible DART QUANTITY values is available in the [obs\_def\_mod](../../assimilation_code/modules/observations/DEFAULT_obs_kind_mod.html) that is built by [preprocess](../../assimilation_code/programs/preprocess/preprocess.html) |
| minimum        | If the variable is to be updated in the ROMS restart file, this specifies the minimum value. If set to 'NA', there is no minimum value. |
| maximum        |  If the variable is to be updated in the ROMS restart file, this specifies the maximum value. If set to 'NA', there is no maximum value. |
| update         |  The updated variable may or may not be written to the ROMS restart file.  *'UPDATE'*  means the variable in the restart file is updated. This is case-insensitive.  *'NO\_COPY\_BACK'*  (or anything else) means the variable in the restart file remains unchanged. |

# NAMELIST

This namelist is read from the file *input.nml*. Namelists start with an
ampersand '&' and terminate with a slash '/'. Character strings that
contain a '/' must be enclosed in quotes to prevent them from
prematurely terminating the namelist. The default namelist is presented
below, a more realistic namelist is presented at the end of this
section.

    &model_nml
       roms_filename               = 'roms_input.nc'
       assimilation_period_days    = 1
       assimilation_period_seconds = 0
       vert_localization_coord     = 3
       debug                       = 0
       variables                   = ''
      /




| Item                  | Type                  | Description           |
| --------------------- | --------------------- | --------------------- |
| roms\_filename        | character(len=256)    | This is the name of the file used to provide information about the ROMS variable dimensions,  etc. |
| assimilation_period_days, assimilation_period_seconds  | integer               | Combined, these  specify the width of the assimilation window. The current model time is used as the center time of  the assimilation window. All observations in the assimilation window are assimilated. **BEWARE:** if you put observations that occur before the beginning of the assimilation_period, DART will error out because it cannot move the model 'back in time' to process these observations. |
| variables             | character(:, 5)       | A 2D array of strings, 5 per ROMS variable to be added to the dart state vector. <ol><li>ROMS field name - must match netCDF variable name exactly</li><li>DART QUANTITY must match a valid DART QTY\_xxx exactly</li><li>minimum physical value - if none, use 'NA'</li><li>maximum physical value - if none, use 'NA'</li><li>case-insensitive string describing whether to copy the updated variable into the ROMS restart file ('UPDATE') or not (any other value). There is generally no point copying diagnostic variables into the restart file. Some diagnostic variables may be useful for computing forward operators, however.</li></ol>|
| vert_localization_coord | integer             | Vertical coordinate for vertical  localization. <ul style="list-style-type:none;"><li>1 = model level</li><li>2 = pressure (in pascals)</li><li>3 = height (in meters)</li><li>4 = scale height  (unitless)</li></ul>Currently, only 3 (height) is supported for ROMS. |

A more realistic ROMS namelist is presented here, along with one of the
more unusual settings that is generally necessary when running ROMS. The
*use\_precomputed\_FOs\_these\_obs\_types* variable needs to list the
observation types that are present in the ROMS verification observation
file.

    &model_nml
       roms_filename                = 'roms_input.nc'
       assimilation_period_days     = 1
       assimilation_period_seconds  = 0
       vert_localization_coord      = 3
       debug                        = 1
       variables = 'temp',   'QTY_TEMPERATURE',          'NA', 'NA', 'update',
                   'salt',   'QTY_SALINITY',            '0.0', 'NA', 'update',
                   'u',      'QTY_U_CURRENT_COMPONENT',  'NA', 'NA', 'update',
                   'v',      'QTY_V_CURRENT_COMPONENT',  'NA', 'NA', 'update',
                   'zeta',   'QTY_SEA_SURFACE_HEIGHT'    'NA', 'NA', 'update'
      /

    &obs_kind_nml
       evaluate_these_obs_types = ''
       assimilate_these_obs_types =          'SATELLITE_SSH',
                                             'SATELLITE_SSS',
                                             'XBT_TEMPERATURE',
                                             'CTD_TEMPERATURE',
                                             'CTD_SALINITY',
                                             'ARGO_TEMPERATURE',
                                             'ARGO_SALINITY',
                                             'GLIDER_TEMPERATURE',
                                             'GLIDER_SALINITY',
                                             'SATELLITE_BLENDED_SST',
                                             'SATELLITE_MICROWAVE_SST',
                                             'SATELLITE_INFRARED_SST'
       use_precomputed_FOs_these_obs_types = 'SATELLITE_SSH',
                                             'SATELLITE_SSS',
                                             'XBT_TEMPERATURE',
                                             'CTD_TEMPERATURE',
                                             'CTD_SALINITY',
                                             'ARGO_TEMPERATURE',
                                             'ARGO_SALINITY',
                                             'GLIDER_TEMPERATURE',
                                             'GLIDER_SALINITY',
                                             'SATELLITE_BLENDED_SST',
                                             'SATELLITE_MICROWAVE_SST',
                                             'SATELLITE_INFRARED_SST'
      /

# OTHER MODULES USED

    types_mod
    time_manager_mod
    threed_sphere/location_mod
    utilities_mod
    obs_kind_mod
    map_utils
    netcdf
    typesizes

    utilities/default_model_mod.f90

# FILES

These are the files used by the DART side of the experiment. Additional
files necessary to run ROMS are not listed here. Depending on the
setting in *input.nml* for *stages\_to\_write*, there may be more DART
diagnostic files output. The inflation files are listed here because
they may be required for an assimilation.

-   input.nml
-   varinfo.dat
-   ocean.in
-   restart\_files.txt
-   precomputed\_files.txt (optionally)
-   input\_priorinf\_\[mean,sd\].nc (optionally)
-   output\_priorinf\_\[mean,sd\].nc (optionally)
-   input\_postinf\_\[mean,sd\].nc (optionally)
-   output\_postinf\_\[mean,sd\].nc (optionally)

# REFERENCES

[Regional Ocean Modeling System](https://www.myroms.org)

# ERROR CODES AND CONDITIONS

| Routine         | Message        | Comment                     |
| --------------- | -------------- | --------------------------- |
| static_init_model parse_variable_input | 'model_nml:model "variables" not fully specified' | There must be 5 items specified for each variable intended to be part of the DART vector. The *variables* definition in *input.nml* does not have 5 items per variable. |
| static_init_model parse_variable_input | 'there is no quantity <...> in obs_kind_mod.f90' | An unsupported (or misspelled) DART quantity is specified in the *variables* definition in *input.nml*. |
| get_location_from_ijk | 'Routine not finished.' | This routine has not been rigorously tested. |

# KNOWN BUGS

None.

# FUTURE PLANS

Fully support interpolation in addition to relying on the verification
observations.

# TERMS OF USE

DART software - Copyright UCAR. This open source software is provided by
UCAR, "as is", without charge, subject to all terms of use at
<http://www.image.ucar.edu/DAReS/DART/DART_download>

  ------------------ -----------------------------
  Contact:           Tim Hoar, Nancy Collins
  Revision:          \$Revision\$
  Source:            \$URL\$
  Change Date:       \$Date\$
  Change history:    try "svn log" or "svn diff"
  ------------------ -----------------------------
