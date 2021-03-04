Bitwise Considerations
======================

By bitwise we mean bit for bit identical results in the output obs_sequence file and the restarts (netcdf-to-netcdf or
DART format-to-dart format) when comparing one version of the code to another. For testing the code to be bitwise with
Lanai there are several things to change/set in Manhattan and your mkmf:

#. assim_tools_mod.f90:
   ``lanai_bitwise = .true.`` This is hard coded to false because it is very slow to be bitwise with Lanai.
   ``lanai_bitwise = .true.`` causes the vertical conversion of observations to be done in get_close_obs inside the
   sequential obs do loop. See :doc:`./vertical_conversion` for details about this change.
#. filter_nml:
   ``output_forward_op_errors = .true.`` This will cause the forward operator code to calculate all forward operators,
   even if some ensemble members fail.
#. mkmf:
   ifort fp-model precise
   In general use the debugging FLAGS in the mkmfs provided with DART.
#. sampling_error_correction:
   Use the sampling_error_correction_table.Lanai.nc from the assimilation_code/programs/system_simulation/work
   directory. These values are identical to the Lanai release.
#. posterior inflation:
   Try to avoid testing cases which use posterior inflation. The posterior inflation has additional code in the
   Manhattan version compared to Lanai. If you need to test a case that has posterior, copy
   assim_tools/assim_tools_mod.f90 from the 'classic' release to your Lanai build, and run your test against that
   version.

Important
~~~~~~~~~

The *CAM* and *bgrid_solo* model_mods have been altered so the state is in a different order inside filter. Thus DART
format restarts will **not** be bitwise with Lanai DART format restarts, but netcdf files will be (after running
dart_to_cam).
