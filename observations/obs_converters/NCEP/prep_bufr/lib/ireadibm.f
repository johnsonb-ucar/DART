      FUNCTION IREADIBM(LUNIT,SUBSET,IDATE)

C$$$  SUBPROGRAM DOCUMENTATION BLOCK
C
C SUBPROGRAM:    IREADIBM
C   PRGMMR: WOOLLEN          ORG: NP20       DATE: 1999-11-18
C
C ABSTRACT: THIS FUNCTION CALLS BUFR ARCHIVE LIBRARY SUBROUTINE READIBM
C   AND PASSES BACK ITS RETURN CODE.  SEE READIBM FOR MORE DETAILS. IT
C   IS CONSIDERED OBSOLETE AND MAY BE REMOVED FROM THE BUFR ARCHIVE
C   LIBRARY IN A FUTURE VERSION.  USERS SHOULD MIGRATE TO THE DIRECT
C   USE OF IREADMG WHICH CALLS BUFR ARCHIVE LIBRARY SUBROUTINE READMG.
C
C PROGRAM HISTORY LOG:
C 1999-11-18  J. WOOLLEN -- ORIGINAL AUTHOR (ENTRY POINT IN IREADMG)
C 2002-05-14  J. WOOLLEN -- CHANGED FROM AN ENTRY POINT TO INCREASE
C                           PORTABILITY TO OTHER PLATFORMS
C 2003-11-04  S. BENDER  -- ADDED REMARKS/BUFRLIB ROUTINE
C                           INTERDEPENDENCIES
C 2003-11-04  D. KEYSER  -- UNIFIED/PORTABLE FOR WRF; ADDED
C                           DOCUMENTATION (INCLUDING HISTORY)
C DART $Id$
C
C USAGE:    IREADIBM  (LUNIT, SUBSET, IDATE)
C   INPUT ARGUMENT LIST:
C     LUNIT    - INTEGER: FORTRAN LOGICAL UNIT NUMBER FOR BUFR FILE
C
C   OUTPUT ARGUMENT LIST:
C     SUBSET   - CHARACTER*8: TABLE A MNEMONIC FOR TYPE OF BUFR MESSAGE
C                BEING READ
C     IDATE    - INTEGER: DATE-TIME STORED WITHIN SECTION 1 OF BUFR
C                MESSAGE BEING READ, IN FORMAT OF EITHER YYMMDDHH OR
C                YYYYMMDDHH, DEPENDING ON DATELEN() VALUE
C     IREADIBM - INTEGER: RETURN CODE:
C                       0 = normal return
C                      -1 = there are no more BUFR messages in LUNIT
C
C REMARKS:
C    THIS ROUTINE CALLS:        READIBM
C    THIS ROUTINE IS CALLED BY: None
C                               Normally called only by application
C                               programs.
C
C ATTRIBUTES:
C   LANGUAGE: FORTRAN 77
C   MACHINE:  PORTABLE TO ALL PLATFORMS
C
C$$$

      CHARACTER*8 SUBSET
      CALL READIBM(LUNIT,SUBSET,IDATE,IRET)
      IREADIBM = IRET
      RETURN
      END
