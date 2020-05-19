[]{#TOP}

MODULE model\_mod (ROMS)
========================

+-----------------------------------+-----------------------------------+
| ![DART project                    | Jump to [DART Documentation Main  |
| logo](../../documentation/images/ | Index](../../documentation/index. |
| Dartboard7.png){height="70"}      | html)\                            |
|                                   | version information for this      |
|                                   | file:\                            |
|                                   | \$Id\$                            |
+-----------------------------------+-----------------------------------+

[NAMELIST](#Namelist) / [INTERFACES](#Interface) / [FILES](#FilesUsed) /
[REFERENCES](#References) / [ERRORS](#Errors) / [PLANS](#FuturePlans) /
[TERMS OF USE](#Legalese)

Overview
--------

This is the DART interface to the [Regional Ocean Modeling
System](https://www.myroms.org) - **ROMS**. This document describes the
relationship between ROMS and DART and provides an overview of how to
perform ensemble data assimilation with ROMS to provide ocean states
that are consistent with the information provided by various ocean
observations.\
\
Running ROMS is complicated. It is **strongly** recommended that you
become very familiar with running ROMS before you attempt a ROMS-DART
assimilation experiment. Running DART is complicated. It is **strongly**
recommended that you become very familiar with running DART before you
attempt a ROMS-DART assimilation experiment. Running ROMS-DART takes
expertise in both areas.\
\
We recommend working through the [DART
tutorial](../../documentation/tutorial/index.html) to learn the concepts
of ensemble data assimilation and the capabilities of DART.\
\
The ROMS code is not distributed with DART, it can be obtained from the
ROMS website <https://www.myroms.org>. There you will also find
instructions on how to compile and run ROMS. DART can use the
'verification observations' from ROMS (basically the estimate of the
observation at the location and time computed as the model advances) so
it would be worthwhile to become familiar with that capability of ROMS.
DART calls these 'precomputed forward operators'.\
\
DART can also use observations from the [World Ocean
Database](https://www.nodc.noaa.gov/OC5/indprod.html) - WOD. The
conversion from the WOD formats to the DART observation sequence format
is accomplished by the converters in the
*observations/obs\_converters/WOD* directory. They are described by
[WOD.html](../../observations/obs_converters/WOD/WOD.html). The DART
forward operators require interpolation from the ROMS terrain-following
and horizontally curvilinear orthogonal coordinates to the observation
location. *As of revision 12153*, this capability is still under
development.

**A note about file names:** During the course of an experiment, many
files are created. To make them unique, the *ocean\_time* is converted
from

> "seconds since 1900-01-01 00:00:00"

to the equivalent number of DAYS. An *integer* number of days. The
intent is to tag the filename to reflect the valid time of the model
state. This could be used as the DSTART for the next cycle, so it makes
sense to me.\
\
The confusion comes when applied to the observation files. The input
observation files for the ROMS 4DVAR system typically have a DSTART that
designates the start of the forecast cycle and the file must contain
observation from DSTART to the end of the forecast. Makes sense. The
model runs to the end of the forecast, harvesting the verification
observations along the way.\
\
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

The *shell\_scripts* directory has several scripts that are intended to
provide examples. These scripts **WILL** need to be modified to work on
your system and are heavily internally commented. It will be necessary
to read through and understand the scripts. As mentioned before, the
ROMS *Bin/subsitute* command is used to replace temporary placeholders
with actual values at various parts during the process.

  Script                                                                              Description
  ----------------------------------------------------------------------------------- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  [ensemble.sh](shell_scripts/ensemble.sh)                                            Was written by Hernan Arango to run an ensemble of ROMS models. It is an appropriate example of what is required from the ROMS perspective. It does no data assimilation.
  [stage\_experiment.csh](shell_scripts/stage_experiment.csh)                         prepares a directory for an assimilation experiment. The idea is basically that everything you need should be assembled by this script and that this should only be run ONCE per experiment. After everything is staged in the experiment directory, another script can be run to advance the model and perform the assimilation. *stage\_experiment.csh* will also modify some of the template scripts and copy working versions into the experiment directory. This script may be run interactively, i.e. from the UNIX command line.
  [submit\_multiple\_cycles\_lsf.csh](shell_scripts/submit_multiple_cycles_lsf.csh)   is an executable script that submits a series of dependent jobs to an LSF queuing system. Each job runs *cycle.csh* in the experiment directory and only runs if the previous dependent job completes successfully.
  [cycle.csh.template](shell_scripts/cycle.csh.template)                              is a non-executable template that is modified by *stage\_experiment.csh* and results in an exectuable *cycle.csh* in the experiment directory. *cycle.csh* is designed to be run as a batch job and advances the ROMS model states one-by-one for the desired forecast length. The assimilation is performed and the control information for the next ROMS forecast is updated. Each model execution and *filter* use the same set of MPI tasks.
  [submit\_multiple\_jobs\_slurm.csh](shell_scripts/submit_multiple_jobs_slurm.csh)   is an executable script that submits a series of dependent jobs to an LSF queuing system. It is possible to submit **many** jobs the queue, but the jobs run one-at-a-time. Every assimilation cycle is divided into two scripts to be able to efficiently set the resources for each phase. *advance\_ensemble.csh* is a job array that advances each ROMS instance in separate jobs. When the entire job array finishes - and only if they all finish correctly - will the next job start to run. *run\_filter.csh* performs the assimilation and prepares the experiment directory for another assimilation cycle. *submit\_multiple\_jobs\_slurm.csh* may be run from the command line in the experiment directory. Multiple assimilation cycles can be specified, so it is possible to put **many** jobs in the queue.
  [advance\_ensemble.csh.template](shell_scripts/advance_ensemble.csh.template)       is a non-executable template that is modified by *stage\_experiment.csh* and results in an exectuable *advance\_ensemble.csh* in the experiment directory. *advance\_ensemble.csh* is designed to submit an job array to the queueing system (PBS,SLURM, or LSF) to advance the ensemble members in separate jobs.
  [run\_filter.csh.template](shell_scripts/run_filter.csh.template)                   is a non-executable template that is modified by *stage\_experiment.csh* and results in an exectuable *run\_filter.csh* in the experiment directory. *run\_filter.csh* is very similar to *cycle.csh* but does not advance the ROMS model instances.

The variables from ROMS that are copied into the DART state vector are
controlled by the *input.nml* *model\_nml* namelist. See below for the
documentation on the &model\_nml entries. The state vector should
include all variables needed to apply the forward observation operators
as well as the prognostic variables important to restart ROMS.\
\
The example *input.nml* *model\_nml* demonstrates how to construct the
DART state vector. The following table explains in detail each entry for
the *variables* namelist item:

<div>

  Column 1        Column 2        Column 3   Column 4   Column 5
  --------------- --------------- ---------- ---------- ----------
  Variable name   DART QUANTITY   minimum    maximum    update

\
\
  ----------------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Variable name     This is the ROMS variable name as it appears in the ROMS netCDF file.

  DART QUANTITY     This is the character string of the corresponding DART QUANTITY. The complete list of possible DART QUANTITY values is available in the [obs\_def\_mod](../../assimilation_code/modules/observations/DEFAULT_obs_kind_mod.html) that is built by [preprocess](../../assimilation_code/programs/preprocess/preprocess.html)

  minimum           If the variable is to be updated in the ROMS restart file, this specifies the minimum value. If set to 'NA', there is no minimum value.

  maximum           If the variable is to be updated in the ROMS restart file, this specifies the maximum value. If set to 'NA', there is no maximum value.

  update            The updated variable may or may not be written to the ROMS restart file.\
                    *'UPDATE'*  means the variable in the restart file is updated. This is case-insensitive.\
                    *'NO\_COPY\_BACK'*  (or anything else) means the variable in the restart file remains unchanged.\
  ----------------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

</div>

[]{#Namelist}

<div class="top">

\[[top](#)\]

</div>

------------------------------------------------------------------------

NAMELIST
--------

This namelist is read from the file *input.nml*. Namelists start with an
ampersand '&' and terminate with a slash '/'. Character strings that
contain a '/' must be enclosed in quotes to prevent them from
prematurely terminating the namelist. The default namelist is presented
below, a more realistic namelist is presented at the end of this
section.

<div class="namelist">

    &model_nml
       roms_filename               = 'roms_input.nc'
       assimilation_period_days    = 1
       assimilation_period_seconds = 0
       vert_localization_coord     = 3
       debug                       = 0
       variables                   = ''
      /

</div>

<div>

+-----------------------+-----------------------+-----------------------+
| Item                  | Type                  | Description           |
+=======================+=======================+=======================+
| roms\_filename        | character(len=256)    | This is the name of   |
|                       |                       | the file used to      |
|                       |                       | provide information   |
|                       |                       | about the ROMS        |
|                       |                       | variable dimensions,  |
|                       |                       | etc.                  |
+-----------------------+-----------------------+-----------------------+
| assimilation\_period\ | integer               | Combined, these       |
| _days,\               |                       | specify the width of  |
| assimilation\_period\ |                       | the assimilation      |
| _seconds              |                       | window. The current   |
|                       |                       | model time is used as |
|                       |                       | the center time of    |
|                       |                       | the assimilation      |
|                       |                       | window. All           |
|                       |                       | observations in the   |
|                       |                       | assimilation window   |
|                       |                       | are assimilated.      |
|                       |                       | BEWARE: if you put    |
|                       |                       | observations that     |
|                       |                       | occur before the      |
|                       |                       | beginning of the      |
|                       |                       | assimilation\_period, |
|                       |                       | DART will error out   |
|                       |                       | because it cannot     |
|                       |                       | move the model 'back  |
|                       |                       | in time' to process   |
|                       |                       | these observations.   |
+-----------------------+-----------------------+-----------------------+
| variables             | character(:, 5)       | A 2D array of         |
|                       |                       | strings, 5 per ROMS   |
|                       |                       | variable to be added  |
|                       |                       | to the dart state     |
|                       |                       | vector.               |
|                       |                       | 1.  ROMS field name - |
|                       |                       |     must match netCDF |
|                       |                       |     variable name     |
|                       |                       |     exactly           |
|                       |                       | 2.  DART QUANTITY -   |
|                       |                       |     must match a      |
|                       |                       |     valid DART        |
|                       |                       |     QTY\_xxx exactly  |
|                       |                       | 3.  minimum physical  |
|                       |                       |     value - if none,  |
|                       |                       |     use 'NA'          |
|                       |                       | 4.  maximum physical  |
|                       |                       |     value - if none,  |
|                       |                       |     use 'NA'          |
|                       |                       | 5.  case-insensitive  |
|                       |                       |     string describing |
|                       |                       |     whether to copy   |
|                       |                       |     the updated       |
|                       |                       |     variable into the |
|                       |                       |     ROMS restart file |
|                       |                       |     ('UPDATE') or not |
|                       |                       |     (any other        |
|                       |                       |     value). There is  |
|                       |                       |     generally no      |
|                       |                       |     point copying     |
|                       |                       |     diagnostic        |
|                       |                       |     variables into    |
|                       |                       |     the restart file. |
|                       |                       |     Some diagnostic   |
|                       |                       |     variables may be  |
|                       |                       |     useful for        |
|                       |                       |     computing forward |
|                       |                       |     operators,        |
|                       |                       |     however.          |
+-----------------------+-----------------------+-----------------------+
| vert\_localization\_c | integer               | Vertical coordinate   |
| oord                  |                       | for vertical          |
|                       |                       | localization.         |
|                       |                       | -   1 = model level   |
|                       |                       | -   2 = pressure (in  |
|                       |                       |     pascals)          |
|                       |                       | -   3 = height (in    |
|                       |                       |     meters)           |
|                       |                       | -   4 = scale height  |
|                       |                       |     (unitless)        |
|                       |                       |                       |
|                       |                       | Currently, only 3     |
|                       |                       | (height) is supported |
|                       |                       | for ROMS.             |
+-----------------------+-----------------------+-----------------------+

</div>

\
\

A more realistic ROMS namelist is presented here, along with one of the
more unusual settings that is generally necessary when running ROMS. The
*use\_precomputed\_FOs\_these\_obs\_types* variable needs to list the
observation types that are present in the ROMS verification observation
file.

<div class="namelist">

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

</div>

[]{#Interface}

<div class="top">

\[[top](#)\]

</div>

------------------------------------------------------------------------

OTHER MODULES USED
------------------

    types_mod
    time_manager_mod
    threed_sphere/location_mod
    utilities_mod
    obs_kind_mod
    map_utils
    netcdf
    typesizes

    utilities/default_model_mod.f90

------------------------------------------------------------------------

PUBLIC INTERFACES
-----------------

The 18 required public interfaces are standardized for all DART
compliant models. These interfaces allow DART to advance the model, get
the model state and metadata describing this state, find state variables
that are close to a given location, and do spatial interpolation for a
variety of variables required in observational operators. Some of the
interfaces are common to multiple models and exist in their own modules.
Only the interfaces unique to ROMS are described here.

*use model\_mod, only :*

[get\_model\_size](#get_model_size)

 

[get\_state\_meta\_data](#get_state_meta_data)

 

[model\_interpolate](#model_interpolate)

 

[shortest\_time\_between\_assimilations](#shortest_time_between_assimilations)

 

[static\_init\_model](#static_init_model)

 

[end\_model](#end_model)

 

[nc\_write\_model\_atts](#nc_write_model_atts)

 

[write\_model\_time](#write_model_time)

 

[read\_model\_time](#read_model_time)

These routines are not required, but are useful:

 

[get\_time\_information](#get_time_information)

 

[get\_location\_from\_ijk](#get_location_from_ijk)

These required interfaces are described in their own module
documentation:

*use default\_model\_mod, only :*

[nc\_write\_model\_vars](../utilities/default_model_mod.html#nc_write_model_vars)

 

[pert\_model\_copies](../utilities/default_model_mod.html#pert_model_copies)

 

[adv\_1step](../utilities/default_model_mod.html#adv_1step)

 

[init\_time](../utilities/default_model_mod.html#init_time)

 

[init\_conditions](../utilities/default_model_mod.html#init_conditions)

 

*use location\_model\_mod, only :*

[get\_close\_obs](../../assimilation_code/location/threed_sphere/location_mod.html#get_close_obs)

 

[get\_close\_state](../../assimilation_code/location/threed_sphere/location_mod.html#get_close_obs)

 

[convert\_vertical\_obs](../../assimilation_code/location/threed_sphere/location_mod.html#convert_vertical_obs)

 

[convert\_vertical\_state](../../assimilation_code/location/threed_sphere/location_mod.html#convert_vertical_state)

The last 4 interfaces are only required for low-order models where
advancing the model can be done by a call to a subroutine. The ROMS
model only advances by executing the program ROMS.exe. Thus the last 4
interfaces only appear as stubs in the ROMS module.\
\
The interface pert\_model\_copies is presently not provided for ROMS.
The initial ensemble has to be generated off-line. If coherent
structures are not required, the filter can generate an ensemble with
uncorrelated random Gaussian noise of 0.002. This is of course not
appropriate for a model like ROMS which has variables expressed in a
wide range of scales. It is thus recommended to generate the initial
ensemble off-line, perhaps with the tools provided in
models/ROMS/PERTURB/3DVAR-COVAR.

A note about documentation style. Optional arguments are enclosed in
brackets *\[like this\]*.

[]{#get_model_size}\

<div class="routine">

*model\_size = get\_model\_size( )*
    integer :: get_model_size

</div>

<div class="indent1">

Returns the length of the model state vector as an integer. This
includes all nested domains.

  --------------- ---------------------------------------
  *model\_size*   The length of the model state vector.
  --------------- ---------------------------------------

</div>

\
[]{#get_state_meta_data}\

<div class="routine">

*call get\_state\_meta\_data (index\_in, location *\[, var\_type\]*)*
    integer,             intent(in)  :: index_in
    type(location_type), intent(out) :: location
    integer, optional,   intent(out) :: var_type

</div>

<div class="indent1">

Returns metadata about a given element in the DART vector, specifically
the location and the quantity.

  ---------------- ------------------------------------------------------------------------------------------------------------------------------------
  *index\_in   *   Index of state vector element about which information is requested.
  *location*       the location of the indexed state variable.
  *var\_type*      Returns the DART QUANTITY (QTY\_TEMPERATURE, QTY\_U\_WIND\_COMPONENT, etc.) of the indexed state variable as an optional argument.
  ---------------- ------------------------------------------------------------------------------------------------------------------------------------

</div>

\
[]{#model_interpolate}\

<div class="routine">

*call model\_interpolate(state\_handle, ens\_size, location, obs\_type,
expected\_obs, istatus)*
    type(ensemble_type), intent(in)  :: state_handle
    integer,             intent(in)  :: ens_size
    type(location_type), intent(in)  :: location
    integer,             intent(in)  :: obs_type
    real(r8),            intent(out) :: expected_obs(:)
    integer,             intent(out) :: istatus(:)

</div>

<div class="indent1">

Given a handle to a model state, a physical location, and a desired
QUANTITY; *model\_interpolate* returns the array of expected observation
values and a status for each. At present, the ROMS *model\_interpolate*
is under development as the forward operators for ROMS are precomputed.

  ----------------- ---------------------------------------------------------------------------------------------------------------------
  *state\_handle*   A model state vector.
  *ens\_size*       The size of the ensemble.
  *location   *     Physical location of interest.
  *obs\_type*       Integer describing the QUANTITY of interest.
  *expected\_obs*   The array of interpolated values from the model. The length of the array corresponds to the ensemble size.
  *istatus*         The array of integer flags indicating the status of the interpolation. Each ensemble member returns its own status.
  ----------------- ---------------------------------------------------------------------------------------------------------------------

</div>

\
[]{#shortest_time_between_assimilations}\

<div class="routine">

*var = shortest\_time\_between\_assimilations()*
    type(time_type) :: shortest_time_between_assimilations

</div>

<div class="indent1">

Returns the time step (forecast length) of the model; the smallest
increment in time that the model is capable of advancing the state in a
given implementation.

  ---------- ------------------------------
  *var   *   Smallest time step of model.
  ---------- ------------------------------

</div>

\
[]{#static_init_model}\

<div class="routine">

*call static\_init\_model()*

</div>

<div class="indent1">

Used for runtime initialization of the model. This is the first call
made to the model by any DART compliant assimilation routine. It reads
the model namelist parameters, set the calendar type (the GREGORIAN
calendar is used with the ROMS model), and determine the dart vector
length. This routine requires that a *roms\_input.nc* is present in the
working directory to retrieve model information (grid dimensions and
spacing, variable sizes, etc).

</div>

\
[]{#end_model}\

<div class="routine">

*call end\_model( )*

</div>

<div class="indent1">

Called when use of a model is completed to clean up storage, etc. A stub
is provided for the ROMS model.

</div>

\
[]{#nc_write_model_atts}\

<div class="routine">

*ierr = nc\_write\_model\_atts(ncid)*
    integer             :: nc_write_model_atts
    integer, intent(in) :: ncid

</div>

<div class="indent1">

Function to write model-specific attributes to a netCDF file, usually
the DART diagnostic files. This function writes the model metadata to a
NetCDF file opened to a file identified by ncid.

  ----------- -----------------------------------------------------------
  *ncid   *   Integer file descriptor to previously-opened netCDF file.
  *ierr*      Returns a 0 for successful completion.
  ----------- -----------------------------------------------------------

</div>

\
[]{#write_model_time}\

<div class="routine">

*call write\_model\_time(ncid, model\_time *\[, adv\_to\_time\]*)*
    integer,         intent(in)           :: ncid
    type(time_type), intent(in)           :: model_time
    type(time_type), intent(in), optional :: adv_to_time

</div>

<div class="indent1">

Routine to write the current model time to the requested netCDF file.
This is used for all the DART diagnostic output.

  ----------------- -------------------------------------------------
  *ncid   *         Integer file descriptor to an open netCDF file.
  *model\_time*     The current time of the model state.
  *adv\_to\_time*   The desired time for the next assimilation.
  ----------------- -------------------------------------------------

</div>

\
[]{#read_model_time}\

<div class="routine">

*var = read\_model\_time(filename)*
    character(len=*),intent(in)  filename
    type(time_type)              var

</div>

<div class="indent1">

Routine to read the model time from a netCDF file that has not been
opened. The file is opened, the time is read, and the file is closed.

  ----------- -----------------------------------------------------------------------------------------------------
  *ncid   *   the name of the netCDF file.
  *var*       The current time associated with the file. Specifically, this is the last 'ocean\_time' (normally).
  ----------- -----------------------------------------------------------------------------------------------------

</div>

[]{#get_time_information}\

<div class="routine">

*call get\_time\_information(filename, ncid, var\_name, dim\_name &
*\[,myvarid, calendar, last\_time\_index, last\_time, origin\_time,
all\_times\]*)*
    character(len=*),            intent(in)  :: filename
    integer,                     intent(in)  :: ncid
    character(len=*),            intent(in)  :: var_name
    character(len=*),            intent(in)  :: dim_name
    integer,           optional, intent(out) :: myvarid
    character(len=32), optional, intent(out) :: calendar
    integer,           optional, intent(out) :: last_time_index
    type(time_type),   optional, intent(out) :: last_time
    type(time_type),   optional, intent(out) :: origin_time
    type(time_type),   optional, intent(out) :: all_times(:)

</div>

<div class="indent1">

Routine to determine the variable describing the time in a ROMS netCDF
file.

  --------------------- -----------------------------------------------------------------------------------------------------------------
  *filename   *         The name of the netCDF file. This is used for error messages only.
  *ncid*                The netCDF file ID - the file must be open.
  *var\_name*           The name of the variable containing the current model time. This is usually 'ocean\_time'.
  *dim\_name*           The dimension specifying the length of the time variable. TJH: This should not be needed and should be removed.
  *myvarid*             The netCDF variable ID of *var\_name*.
  *calendar*            The type of calendar being used by *filename*.
  *last\_time\_index*   The index of the last time *var\_name*. The last time is declared to be the current model time.
  *last\_time*          The current model time.
  *origin\_time*        The time defined in the 'units' attributes of *var\_name*.
  *all\_times*          The entire array of times in *var\_name*.
  --------------------- -----------------------------------------------------------------------------------------------------------------

</div>

[]{#get_location_from_ijk}\

<div class="routine">

*var = get\_location\_from\_ijk(filoc, fjloc, fkloc, quantity,
location*)
    real(r8),            intent(in)  :: filoc
    real(r8),            intent(in)  :: fjloc
    real(r8),            intent(in)  :: fkloc
    integer,             intent(in)  :: quantity
    type(location_type), intent(out) :: last_time

</div>

<div class="indent1">

Returns the lat,lon,depth given a fractional i,j,k and a specified
quantity as well as a status.\
\
Each grid cell is oriented in a counter clockwise direction for
interpolating locations. First we interpolate in latitude and longitude,
then interpolate in height. The height/depth of each grid cell can very
on each interpolation, so care is taken when we interpolate in the
horizontal. Using the 4 different heights and lat\_frac, lon\_frac,
hgt\_frac we can do a simple trilinear interpolation to find the
location given fractional indicies.\
\
var = 10 - bad incoming dart\_kind\
var = 11 - fkloc out of range\
var = 12 - filoc or fjloc out of range for u grid\
var = 13 - filoc or fjloc out of range for v grid\
var = 14 - filoc or fjloc out of range for rho grid\
var = 99 - initalized istatus, this should not happen

  ---------------- ------------------------------------
  *filoc*          Fractional x index.
  *fjloc*          Fractional y index.
  *fkloc*          Fractional vertical index.
  *quantity*       The DART quantity of interest.
  *location    *   The latitude, longitude and depth.
  ---------------- ------------------------------------

</div>

[]{#FilesUsed}

<div class="top">

\[[top](#)\]

</div>

------------------------------------------------------------------------

FILES
-----

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

[]{#References}

<div class="top">

\[[top](#)\]

</div>

------------------------------------------------------------------------

REFERENCES
----------

[Regional Ocean Modeling System](https://www.myroms.org)

[]{#Errors}

<div class="top">

\[[top](#)\]

</div>

------------------------------------------------------------------------

ERROR CODES and CONDITIONS
--------------------------

<div class="errors">

Routine
Message
Comment
static\_init\_model\
parse\_variable\_input\
'model\_nml:model "variables" not fully specified'
There must be 5 items specified for each variable intended to be part of
the DART vector. The *variables* definition in *input.nml* does not have
5 items per variable.
static\_init\_model\
parse\_variable\_input\
'there is no quantity &lt;...&gt; in obs\_kind\_mod.f90'
An unsupported (or misspelled) DART quantity is specified in the
*variables* definition in *input.nml*.
get\_location\_from\_ijk
'Routine not finished.'
This routine has not been rigorously tested.

</div>

KNOWN BUGS
----------

none

[]{#FuturePlans}

<div class="top">

\[[top](#)\]

</div>

------------------------------------------------------------------------

FUTURE PLANS
------------

Fully support interpolation in addition to relying on the verification
observations.

[]{#Legalese}

<div class="top">

\[[top](#)\]

</div>

------------------------------------------------------------------------

Terms of Use
------------

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


