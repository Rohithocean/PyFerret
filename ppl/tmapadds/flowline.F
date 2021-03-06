        SUBROUTINE flowline (u, v, flag, nxs, nys, px, py, xf, yf)


C**
C**    @(#)flowline.F	    9/19/00
C**
C**
C***********************************************************************
C**
C**                 PLOT+ Scientific Graphics System
C**
C***********************************************************************
C**
C**
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
*  ACM  implementing algorighm from grads -- gxstrm.c
*       draw flowlines 

C  From GrADS code, gxstrm.c
C  and based on vecfld.F

C void gxstrm (float *u, float *v, float *c, int is, int js,
C   float uund, float vund, float cund, int flag, float *shdlvs,
C   int *shdcls, int shdcnt, int den) 


*  v4 2-oct-01 remove VMS includes
*  ACM 12/01  remove ref to jscl; not used.
*  ACM 12/01  remove GET_MEMORY call.  This is now done, with other 
*             PPLUS memory allocation, in disp_set_up.F on the call 
*             from xeq_vector.  Also clean up the declarations.
* ACM  9/9/02 Make px and py declarations px(*); for regular grids these
*             are dummy arrays.
*       *acm* 3/12 6D Ferret (common uses nferdims in tmap_dims.parm)
* V687 *acm* 3/14 tickets 2151 and 2147: allow missing coordinate data in 3-arg 
*                 and 4-arg plot commands. (not implemented in flowline plots)


        IMPLICIT NONE
	include		'parampl5_dat.decl'
	include		'PARAMPL5.DAT'

	include 'tmap_dims.parm'
	include 'ferret.parm'
	include 'errmsg.parm'
	include 'vector_inc.decl'
	include 'VECTOR.INC'
        INCLUDE 'xcurvilinear.cmn'


*******************************************************************************


C  Calling argument declarations

      REAL xf, yf, px(*),py(*)
      REAL U(NXS,NYS),V(NXS,NYS), FLAG(*)
      INTEGER nxs, nys

C  Local declarations

      INTEGER siz, i, iscl, jscl, status


C   Size of the flag grid, allocated in disp_set_up.F

      i = MAX(NXS,NYS)
      iscl = 200/i
      iscl = iscl + density - 5
      IF (iscl .LT.  1) iscl = 1
      IF (iscl .GT. 10) iscl =10

      siz = i*i*iscl*iscl + i*iscl   ! see ii1index in flowline_sub

      CALL flowline_sub (u, v, flag, siz, density, nxs, nys, 
     .                   px, py, xf, yf)

      IF (curv_missing) THEN
 5100	 CALL ERRMSG(ferr_not_implemented, status,
     .     'Missing curvilienar coordinate data in VECTOR/FLOW command', 
     .     *5000)
      ENDIF
 5000 RETURN

      END
