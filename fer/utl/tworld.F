	DOUBLE PRECISION FUNCTION TWORLD( subsc, grid, idim, where_in_box )

*
*
*  This software was developed by the Thermal Modeling and Analysis
*  Project(TMAP) of the National Oceanographic and Atmospheric
*  Administration's (NOAA) Pacific Marine Environmental Lab(PMEL),
*  hereafter referred to as NOAA/PMEL/TMAP.
*
*  Access and use of this software shall impose the following
*  obligations and understandings on the user. The user is granted the
*  right, without any fee or cost, to use, copy, modify, alter, enhance
*  and distribute this software, and any derivative works thereof, and
*  its supporting documentation for any purpose whatsoever, provided
*  that this entire notice appears in all copies of the software,
*  derivative works and supporting documentation.  Further, the user
*  agrees to credit NOAA/PMEL/TMAP in any publications that result from
*  the use of this software or in any product that includes this
*  software. The names TMAP, NOAA and/or PMEL, however, may not be used
*  in any advertising or publicity to endorse or promote any products
*  or commercial entity unless specific written permission is obtained
*  from NOAA/PMEL/TMAP. The user also understands that NOAA/PMEL/TMAP
*  is not obligated to provide the user with any support, consulting,
*  training or assistance of any kind with regard to the use, operation
*  and performance of this software nor to provide the user with any
*  updates, revisions, new versions or "bug fixes".
*
*  THIS SOFTWARE IS PROVIDED BY NOAA/PMEL/TMAP "AS IS" AND ANY EXPRESS
*  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
*  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
*  ARE DISCLAIMED. IN NO EVENT SHALL NOAA/PMEL/TMAP BE LIABLE FOR ANY SPECIAL,
*  INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER
*  RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF
*  CONTRACT, NEGLIGENCE OR OTHER TORTUOUS ACTION, ARISING OUT OF OR IN
*  CONNECTION WITH THE ACCESS, USE OR PERFORMANCE OF THIS SOFTWARE. 
*
*
* convert a subscript value on a grid into a "world" coordinate
* if the axis is a valid time axis then convert the time step value into
* seconds from jan-1-0000:00:00 so that all time axes are on an absolute scale

* programmer - steve hankin
* NOAA/PMEL, Seattle, WA - Tropical Modeling and Analysis Program
* written for VAX computer under VMS operating system
*
* revision 0.0 - 7/26/88
* revision 0.1 -12/30/88 - added where_in_box
* V230:  7/20/92 - check for valid time axis T0
* V530: *acm* 12/00 alternative calendar types; cal_id
*       *acm* 3/12 cleanup ifdefs and unnecessary include files
*       *acm* 3/12 6D Ferret: Add E and F dimensions 
*                  A time axis may be a T axis or F axis, so idim is 
*                  now an arg to TSTEP_TO_SECS

        IMPLICIT NONE
	include 'tmap_dims.parm'
	include 'xtm_grid.cmn_text'
	external xgt_grid_data
	include 'ferret.parm'

* calling argument declarations:
	INTEGER	subsc, grid, idim, where_in_box, 
     .          TM_GET_CALENDAR_ID, cal_id

* internal variable declarations:
        LOGICAL TM_DATE_OK
        INTEGER line
	REAL*8	TM_WORLD, TSTEP_TO_SECS, ww

* standard conversion into world coordinates
	ww = TM_WORLD( subsc, grid, idim, where_in_box )
	TWORLD = ww

* special treatment of calendar time axis
	IF ( idim .EQ. t_dim .OR. idim .EQ. f_dim ) THEN
           line = grid_line( idim, grid )
           cal_id = TM_GET_CALENDAR_ID ( line_cal_name(line) )
           IF ( TM_DATE_OK( line_t0(line), cal_id )  )
     .     TWORLD = TSTEP_TO_SECS( grid, idim, ww )
	ENDIF
	RETURN
	END
