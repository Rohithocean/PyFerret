*
* transpose_xe.F
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
* 3/2017 ACM completing the set of TRANSPOSE functions
* 


      SUBROUTINE transpose_xe_init(id)

      IMPLICIT NONE
      INCLUDE 'EF_Util.cmn'

      INTEGER id, arg

      CALL ef_set_desc(id, 'transposes X and E axes of given variable')
      CALL ef_set_num_args(id, 1)
      CALL ef_set_axis_inheritance_6d(id,
     .                                ABSTRACT,        IMPLIED_BY_ARGS,        
     .                                IMPLIED_BY_ARGS, IMPLIED_BY_ARGS,
     .                                ABSTRACT,        IMPLIED_BY_ARGS)
      CALL ef_set_piecemeal_ok_6d(id, NO, NO, NO, NO, NO, NO)

      arg = 1
      CALL ef_set_arg_name(id, arg, 'VAR')
      CALL ef_set_arg_desc(id, arg, 'variable to transpose in X and E')
      CALL ef_set_axis_influence_6d(id, arg, NO, YES, YES, YES, NO, YES)

      RETURN 
      END


      SUBROUTINE transpose_xe_result_limits(id)

      IMPLICIT NONE
      INCLUDE 'EF_Util.cmn'

      INTEGER id

      INTEGER arg_lo_ss(6,EF_MAX_ARGS),
     .        arg_hi_ss(6,EF_MAX_ARGS),
     .        arg_incr (6,EF_MAX_ARGS)
      INTEGER lo_x, hi_x, lo_e, hi_e, nx, ne

*     Set the ABSTRACT X and E axes.

      CALL ef_get_arg_subscripts_6d(id, arg_lo_ss, arg_hi_ss, arg_incr)

      nx = arg_hi_ss(X_AXIS, ARG1) - arg_lo_ss(X_AXIS, ARG1) + 1
      nE = arg_hi_ss(E_AXIS, ARG1) - arg_lo_ss(E_AXIS, ARG1) + 1

*     The below has the effect of translating any sub-matrix so that
*     the indices will always begin at 1 as expected for an abstract axis.

      lo_x = 1
      hi_x = ne
      lo_E = 1
      hi_E = nx

      CALL ef_set_axis_limits(id, X_AXIS, lo_x, hi_x)
      CALL ef_set_axis_limits(id, E_AXIS, lo_e, hi_e)

      RETURN 

      END


*
* In this subroutine we compute the result
*
      SUBROUTINE transpose_xe_compute(id, arg_1, result)

      IMPLICIT NONE
      INCLUDE 'EF_Util.cmn'
      INCLUDE 'EF_mem_subsc.cmn'

      INTEGER id

      REAL arg_1(mem1lox:mem1hix, mem1loy:mem1hiy, mem1loz:mem1hiz, 
     .           mem1lot:mem1hit, mem1loe:mem1hie, mem1lof:mem1hif)

      REAL result(memreslox:memreshix, memresloy:memreshiy, 
     .            memresloz:memreshiz, memreslot:memreshit,
     .            memresloe:memreshie, memreslof:memreshif)

* After initialization, the 'res_' arrays contain indexing information 
* for the result axes.  The 'arg_' arrays will contain the indexing 
* information for each variable''s axes. 

      INTEGER res_lo_ss(6),
     .        res_hi_ss(6),
     .        res_incr (6)
      INTEGER arg_lo_ss(6,EF_MAX_ARGS),
     .        arg_hi_ss(6,EF_MAX_ARGS),
     .        arg_incr (6,EF_MAX_ARGS)

      REAL bad_flag(EF_MAX_ARGS), bad_flag_result

      INTEGER i, j, k, l, m, n
      INTEGER i1, j1, k1, l1, m1, n1
      CHARACTER*100 errtxt

      CALL ef_get_res_subscripts_6d(id, res_lo_ss, res_hi_ss, res_incr)
      CALL ef_get_arg_subscripts_6d(id, arg_lo_ss, arg_hi_ss, arg_incr)
      CALL ef_get_bad_flags(id, bad_flag, bad_flag_result)

* check to make sure both axis have points to transpose
      IF ( (arg_lo_ss(E_AXIS, ARG1) .EQ. ef_unspecified_int4) .OR. 
     .     (arg_hi_ss(E_AXIS, ARG1) .EQ. ef_unspecified_int4) ) THEN
         WRITE(errtxt,*) 'E axis cannot be a normal axis'
         GOTO 999
      ENDIF
      IF ( (arg_lo_ss(X_AXIS, ARG1) .EQ. ef_unspecified_int4) .OR. 
     .     (arg_hi_ss(X_AXIS, ARG1) .EQ. ef_unspecified_int4) ) THEN
         WRITE(errtxt,*) 'X axis cannot be a normal axis'
         GOTO 999
      ENDIF

      n1 = arg_lo_ss(F_AXIS, ARG1)
      DO 600 n = res_lo_ss(F_AXIS), res_hi_ss(F_AXIS)

      m1 = arg_lo_ss(E_AXIS, ARG1)
      DO 500 i = res_lo_ss(X_AXIS), res_hi_ss(X_AXIS)

      l1 = arg_lo_ss(T_AXIS, ARG1)
      DO 400 l = res_lo_ss(T_AXIS), res_hi_ss(T_AXIS)

      k1 = arg_lo_ss(Z_AXIS, ARG1)
      DO 300 k = res_lo_ss(Z_AXIS), res_hi_ss(Z_AXIS)

      j1 = arg_lo_ss(Y_AXIS, ARG1)
      DO 200 j = res_lo_ss(Y_AXIS), res_hi_ss(Y_AXIS) 

      i1 = arg_lo_ss(X_AXIS, ARG1)
      DO 100 m = res_lo_ss(E_AXIS), res_hi_ss(E_AXIS) 

         IF ( arg_1(i1,j1,k1,l1,m1,n1) .NE. bad_flag(ARG1) ) THEN
            result(i,j,k,l,m,n) = arg_1(i1,j1,k1,l1,m1,n1)
         ELSE
            result(i,j,k,l,m,n) = bad_flag_result
         ENDIF

         i1 = i1 + arg_incr(X_AXIS, ARG1)
 100  CONTINUE

         j1 = j1 + arg_incr(Y_AXIS, ARG1)
 200  CONTINUE

         k1 = k1 + arg_incr(Z_AXIS, ARG1)
 300  CONTINUE

         l1 = l1 + arg_incr(T_AXIS, ARG1)
 400  CONTINUE

         m1 = m1 + arg_incr(E_AXIS, ARG1)
 500  CONTINUE

         n1 = n1 + arg_incr(F_AXIS, ARG1)
 600  CONTINUE

      RETURN 

 999  CALL EF_BAIL_OUT(id, errtxt)

      RETURN 
      END
