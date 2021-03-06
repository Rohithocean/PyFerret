	CHARACTER*(*) FUNCTION FULL_VAR_TITLE( cx, do_units, tlen )

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
* create a title for a memory variable including:
* i)   the variable's title, 
* ii)  modifications to the title ( either mods given as a part of the name or
*      remarks about transformations performed on the variable )

* programmer - steve hankin
* NOAA/PMEL, Seattle, WA - Tropical Modeling and Analysis Program
* written for VAX computer under VMS operating system
*
* revision 0.0 - 5/12/87
* revision 0.1 - 8/29/87 - added parend around title mod
* revision 0.2 - 4/11/88 - added units
* V200:   1/3/89 - mr --> cx
* V500: *kob* 3/99 - up VAR_UNITS from 32 to 64 
*       *acm* 3/12 cleanup ifdefs and unnecessary include files


        IMPLICIT NONE
* calling argument declarations:
	LOGICAL	do_units
	INTEGER	cx, tlen

* internal variable declarations:
	CHARACTER*200	VAR_TITLE, VAR_TITLE_MOD, PAREN_SURROUND
	CHARACTER	VAR_UNITS*64
	INTEGER		TM_LENSTR1, maxlen, slen

	include 'ferret.parm'

* initialize
	maxlen	= LEN( FULL_VAR_TITLE )

* title
	FULL_VAR_TITLE = VAR_TITLE( cx )
	tlen	       = TM_LENSTR1( FULL_VAR_TITLE )

* units
	IF (do_units) THEN
	   FULL_VAR_TITLE = FULL_VAR_TITLE(:tlen) // ' ' //
     .		PAREN_SURROUND( VAR_UNITS(cx), slen )
	   tlen = MIN( maxlen, tlen+1+slen)
	ENDIF

* mods to title
	FULL_VAR_TITLE = FULL_VAR_TITLE(:tlen) //
     .		PAREN_SURROUND( VAR_TITLE_MOD(cx), slen )

* if it wont fit indicate that with a "*" at the end
	tlen = MIN( maxlen, tlen+slen )
	IF ( tlen .EQ. maxlen ) FULL_VAR_TITLE(maxlen:maxlen) = '*'

	RETURN
	END
