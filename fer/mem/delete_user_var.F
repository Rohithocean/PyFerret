	SUBROUTINE DELETE_USER_VAR ( uvar, iset )

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
* delete a user-defined variable 
* First locate each of its children and delete them

* programmer - steve hankin
* NOAA/PMEL, Seattle, WA - Tropical Modeling and Analysis Program

* V450 7/97 - guts of routine moved to DELETE_USER_VAR_SUB
* V510 *sh* 1/00 - bug fixes to support nested GC variables
*        2/12 *kms* Add E and F dimensions (use nferdims in tmap_dims.parm)
* V698  2/16 *acm* For ticket 2352: variables defined with LET/D are
*                  added to that dataset in the attribute structure. Extra
*                  argument to DELETE_USER_VAR
* V699 6/16 *sh* quick exit if already deleted

        IMPLICIT NONE
        include 'tmap_dims.parm'
	include 'ferret.parm'
	include 'xvariables.cmn'

* calling argument declarations:
	INTEGER	uvar, iset

* internal variable declarations:
	INTEGER	i, uv, uvar_ancestor, num_indices, 
     .          result_array(max_uvar), dset

* fall-back check to forgive sloppy bookkeeping elsewhere
* as of 6/16 uvar grids are stored in LIST structures and a double deletion
* can corrupt them
	IF (uvar_num_items(uvar) .EQ. uvar_deleted) RETURN

* delete child vars
*	DO 200 uv = 1, max_uvar
*	   IF ( uvar_num_items( uv ) .EQ. uvar_deleted ) GOTO 200
        CALL deleted_list_get_undel(uvar_num_items_head, 
     .                          result_array(1),
     .                          max_uvar, num_indices )
         DO 200 i =1, num_indices
           uv = result_array(i)
* ... delete if this variable is a child of uvar 
*	uvar_name_code for child vars is "(Cnnn,Vmmm)" -- the "mmm" is the ancestor
	   IF (uvar_name_code(uv)(1:2) .NE. '(C' ) GOTO 200
	   READ (uvar_name_code(uv)(8:10),'(I3)',ERR=200) uvar_ancestor
	   dset = pdset_uvars
	   IF (uvar_ancestor.EQ.uvar) CALL DELETE_USER_VAR_SUB(uv, dset)
 200	CONTINUE

* now delete the variable itself
	dset = iset
	IF (dset.EQ.unspecified_int4 .OR. 
     .      dset.EQ.pdset_irrelevant) dset = pdset_uvars
        CALL DELETE_USER_VAR_SUB(uvar, dset)
	      
	RETURN
	END
