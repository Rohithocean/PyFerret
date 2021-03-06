	SUBROUTINE PURGE_ALL_UVARS

*
*
*  This software was developed by the Thermal Modeling and Analysis
*  Project(TMAP) of the National Oceanographic and Atmospheric
*  Administration''s (NOAA) Pacific Marine Environmental Lab(PMEL),
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
* eliminate all stored user variables from memory

* programmer - steve hankin
* NOAA/PMEL, Seattle, WA - Tropical Modeling and Analysis Program

* V200:  6/29/89
* Unix/RISC port - 11/91 - bug fix: re-initialization of uvars was not complete
*                          for redetermination of grid

* V420 - use new routine DEALLO_UVAR_GRIDS to both deallocate dynamic
*	 grids associated with a uvar and clean out any memory-cached 
*	 results that may depend on this grid
*        2/12 *kms* Add E and F dimensions (use nferdims in tmap_dims.parm)
* v690 *sh* also purge any file vars that depend upon uvars as aux vars 
* V745 *acm*  3/19 Issue 1916. For issue 1916: Pull out guts into a 
*        subroutine that can also be called in cancel mem
 

        IMPLICIT NONE
        include 'tmap_dims.parm'
	include 'ferret.parm'
	include 'errmsg.parm'
	include 'xvariables.cmn'

* internal variable declarations:
	INTEGER	uvar, i, j, num_indices

*	DO 500 uvar = 1, max_uvar                      
*	   IF ( uvar_num_items( uvar ) .EQ. uvar_deleted ) GOTO 500  
        CALL deleted_list_get_undel(uvar_num_items_head, 
     .                          deleted_list_result(1),
     .                          max_uvar, num_indices )
        DO 500 j = 1, num_indices
           uvar = deleted_list_result(j)

* eliminate all memory resident instances of this variable
* and restore initial defaults

	   CALL PURGE_ALL_UVARS_SUB (uvar)

 500	CONTINUE

	CALL PURGE_AUX_VAR_DEPENDENTS

	RETURN
	END
