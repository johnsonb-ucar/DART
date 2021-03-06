      FUNCTION INVCON(NC,LUN,INV1,INV2)

C$$$  SUBPROGRAM DOCUMENTATION BLOCK
C
C SUBPROGRAM:    INVCON (docblock incomplete)
C   PRGMMR: WOOLLEN          ORG: NP20       DATE: 1994-01-06
C
C ABSTRACT: THIS FUNCTION ....
C
C PROGRAM HISTORY LOG:
C 1994-01-06  J. WOOLLEN -- ORIGINAL AUTHOR
C 1998-07-08  J. WOOLLEN -- IMPROVED MACHINE PORTABILITY
C 1999-11-18  J. WOOLLEN -- THE NUMBER OF BUFR FILES WHICH CAN BE
C                           OPENED AT ONE TIME INCREASED FROM 10 TO 32
C                           (NECESSARY IN ORDER TO PROCESS MULTIPLE
C                           BUFR FILES UNDER THE MPI)
C 2003-11-04  S. BENDER  -- ADDED REMARKS/BUFRLIB ROUTINE
C                           INTERDEPENDENCIES
C 2003-11-04  D. KEYSER  -- MAXJL (MAXIMUM NUMBER OF JUMP/LINK ENTRIES)
C                           INCREASED FROM 15000 TO 16000 (WAS IN
C                           VERIFICATION VERSION); UNIFIED/PORTABLE FOR
C                           WRF; ADDED DOCUMENTATION (INCLUDING
C                           HISTORY) (INCOMPLETE);  OUTPUTS MORE
C                           COMPLETE DIAGNOSTIC INFO WHEN UNUSUAL
C                           THINGS HAPPEN
C DART $Id$
C
C USAGE:    INVCON (NC, LUN, INV1, INV2)
C   INPUT ARGUMENT LIST:
C     NC       - INTEGER: ....
C     LUN      - INTEGER: I/O STREAM INDEX INTO INTERNAL MEMORY ARRAYS
C     INV1     - INTEGER: ....
C     INV2     - INTEGER: ....
C
C   OUTPUT ARGUMENT LIST:
C     INVCON   - INTEGER: ....
C
C   OUTPUT FILES:
C     UNIT 06  - STANDARD OUTPUT PRINT
C
C REMARKS:
C    THIS ROUTINE CALLS:        None
C    THIS ROUTINE IS CALLED BY: CONWIN
C                               Normally not called by any application
C                               programs.
C
C ATTRIBUTES:
C   LANGUAGE: FORTRAN 77
C   MACHINE:  PORTABLE TO ALL PLATFORMS
C
C$$$

      INCLUDE 'bufrlib.prm'

      COMMON /USRINT/ NVAL(NFILES),INV(MAXJL,NFILES),VAL(MAXJL,NFILES)
      COMMON /USRSTR/ NNOD,NCON,NODS(20),NODC(10),IVLS(10),KONS(10)
      COMMON /QUIET / IPRT

      REAL*8 VAL

C----------------------------------------------------------------------
C----------------------------------------------------------------------

C  CHECK THE INVENTORY INTERVAL
C  ----------------------------

      IF(INV1.LE.0 .OR. INV1.GT.NVAL(LUN)) GOTO 99
      IF(INV2.LE.0 .OR. INV2.GT.NVAL(LUN)) GOTO 99

C  FIND AN OCCURANCE OF NODE IN THE WINDOW MEETING THIS CONDITION
C  --------------------------------------------------------------

      DO INVCON=INV1,INV2
      IF(INV(INVCON,LUN).EQ.NODC(NC)) THEN
         IF(KONS(NC).EQ.1 .AND. VAL(INVCON,LUN).EQ.IVLS(NC)) GOTO 100
         IF(KONS(NC).EQ.2 .AND. VAL(INVCON,LUN).NE.IVLS(NC)) GOTO 100
         IF(KONS(NC).EQ.3 .AND. VAL(INVCON,LUN).LT.IVLS(NC)) GOTO 100
         IF(KONS(NC).EQ.4 .AND. VAL(INVCON,LUN).GT.IVLS(NC)) GOTO 100
      ENDIF
      ENDDO

99    INVCON = 0
      IF(IPRT.GE.2) THEN
      PRINT*
      PRINT*,'+++++++++++++++++BUFR ARCHIVE LIBRARY++++++++++++++++++++'
         PRINT*, 'BUFRLIB: INVCON - INVCON RETURNING WITH VALUE OF 0'
      PRINT*,'+++++++++++++++++BUFR ARCHIVE LIBRARY++++++++++++++++++++'
      PRINT*
      ENDIF

C  EXIT
C  ----

100   RETURN
      END
