      SUBROUTINE WNDIRDIG(IDOTS,JDOTS, C2DIR,IDDGD,NSSS,IQUAD,LSRNHEMI)
C$$$  SUBPROGRAM DOCUMENTATION BLOCK
C                .      .    .                                       .
C SUBPROGRAM:    WNDIRDIG     PLOTTING WIND-DIRECTION DIGIT
C   PRGMMR: KRISHNA KUMAR      ORG: W/NP12   DATE: 1999-07-01
C
C ABSTRACT:
C     ...TO PLOT WIND DIRECTION DIGIT NEAR END OF WIND STAFF;
C     ...BY LOCATING POSITION OF LITTLE WIND DIR DIGIT NR 
C        END OF WND STAFF, AND PLOTTING THE 2ND DIGIT OF NDD AT 
C        THAT POSITION.
C        (THIS IS A VERSION OF WNDIRT() WITH ADDITIONAL CALL SEQUENCE
C        ARGUMENTS.)
C
C PROGRAM HISTORY LOG:
C   96-10-28  SHIMOMURA
C 1999-07-01  KRISHNA KUMAR CONVERTED THIS CODE FROM CRAY TO IBM RS/6000.
C
C USAGE:    CALL WNDIRDIG(IDOTS,JDOTS,NDIR,IDDGD,NSSS,IQUAD,LSRNHEMI)
C   INPUT ARGUMENT LIST:
C     ...GIVEN
C     (1), (2) IDOTS,JDOTS -- LOCATION OF STN IN DOTS (NEAREST
C                                       HUNDREDTH OF AN INCH)
C     (3) C2DIR  -- CHARACTER*2 TRUE WIND DIR IN TENS OF DEGREES
C                                     ('01' THRU '36', OR '99' IF CALM)
C     (4) IDDGD -- GRID ORIENTED WIND DIR (I2) IN TENS OF DEGREES
C     (5) NSSS  -- WIND SPEED IN KTS (I3) (=0 IF.LT.5KTS)
C     (6) IQUAD -- ORIENTATION OF THE DIGIT
C                  =0;  FOR THE MAJORITY OF OUR NORTH AMERICAN PLOTS
C                  =1;  FOR SIDEWAYS, AS IN THE MERCATOR
C                  =2;  FOR UPSIDE-DOWN
C                  =3;  FOR SIDEWAYS, BUT UPSIDE-DOWN FROM 
C                                     THE MERCATOR PERSPECTIVE
C     (7) LSRNHEMI -- LOGICAL SWITCH
C                  = .T.; FOR SOUTHERN HEMISPHERE MODE OF BARBS
C                  = .F.; FOR NORTHERN HEMISPHERE MODE OF BARBS
C
C   OUTPUT FILES:  (DELETE IF NO OUTPUT FILES IN SUBPROGRAM)
C     FT55F001 - LABEL ARRAY WHERE PUTLAB PUTS THE CHARACTER
C     FT06F001 - INCLUDE IF ANY PRINTOUT
C
C REMARKS: LIST CAVEATS, OTHER HELPFUL HINTS OR INFORMATION
C     THE 3RD ARG: CHARACTER*2 C2DIR
C     MUST BE A CHARACTER STRING OF LENGTH AT LEAST 2-CHARACTERS
C     CONTAINING THE 2-DIGIT WIND DIRECTION
C     TO THE TENS OF DEGREES (IN ASCII)
C
C ATTRIBUTES:
C   LANGUAGE: F90
C   MACHINE:  IBM
C
C$$$
C
C
C USAGE:    CALL WNDIRDIG(IDOTS,JDOTS,C2DIR,IDDGD,NSSS,IQUAD,LSRNHEMI)
      INTEGER        IDOTS,JDOTS
      CHARACTER*(*)  C2DIR
      INTEGER        IDDGD
      INTEGER        NSSS
      INTEGER        IQUAD
      LOGICAL        LSRNHEMI
C
C
      REAL    CONVTR
      DATA    CONVTR  	/0.174533/
C     ...CONVERTS TENS OF DEGREES TO RADIANS

      REAL    HYPKA
      DATA    HYPKA  	/31.0/

      REAL    HYPKB
      DATA    HYPKB	/37.0/

      REAL    ADXLL
      REAL    ADYLL
      REAL    ADXLLCON(4)
      DATA    ADXLLCON  	/-3.5, -4.5, -3.5, -4.5 /
      REAL    ADYLLCON(4)
      DATA    ADYLLCON  	/-4.5, -3.5, -4.5, -3.5 /
C     ...WHICH ARE INCREMENTS FORM CENTER OF FIGURE TO LL CORNER
C
C     ... FINE ADJUSTMENTS TO POSITION OF DIGIT ...
      INTEGER  KSCORNIJ(2,36)
      DATA     KSCORNIJ      / 0,0,  0,0,  0,0,  0,0,  0,0,  0,-1,
     7                         0,0,  0,-1, 0,-1, 0,-1, 0,-1, 0,-1,
     3                         0,-2, 0,-1, 0,-1, 0,-1, 0,0,  0,0,
     9                         0,0,  0,0,  0,-1, 0,-1, 0,-1, 0,-1,
     5                         0,-1, 0,-2, 0,-2, 0,-2, 0,-2, 0,-2,
     1                        -1,-1, 0,0, -1,0, -1,0, -1,0, -1,0 /
                             
      INTEGER  KNCORNIJ(2,36)
      DATA     KNCORNIJ      / 0,0,  0,0,  0,0,  0,0,  0,-1, 0,-1,
     7                         0,-1, 0,-1, 0,-1, 0,-1, 0,-1, 0,0,
     3                         0,0,  0,0, -1,0, -1,0, -1,0,  0,0,
     9                         0,0,  0,0,  0,0,  0,0,  0,0,  0,-1,
     5                         0,-1, 0,-1, 0,-1, 0,-1, 0,-1, 0,-1, 
     1                         0,-2, 0,0,  0,0,  0,0,  0,0,  0,0 /
      INTEGER  ILLDIG,JLLDIG
      INTEGER  IDDA
      REAL     DDA
      REAL     DIRAD
      REAL     DELX,DELY

      INTEGER      IROT_PRI(2)
      INTEGER      IROTA
      EQUIVALENCE (IROT_PRI(1),IROTA)
      INTEGER      IPRIOR
      EQUIVALENCE (IROT_PRI(2),IPRIOR)        

C
C
      SAVE
C
      IF(NSSS .LE. 0) THEN
        GO TO 800
      ENDIF

      IF(NSSS .GE. 48) THEN
        HYPOT=HYPKB
      ELSE
        HYPOT=HYPKA
      ENDIF

C     (3) C2DIR  -- C*2 TRUE WIND DIR (A2) IN TENS OF DEGREES
C                                   ('01' THRU '36', OR '99' IF CALM)
      LENDIR = LEN(C2DIR)
      IF(LENDIR .LT. 2) THEN
        WRITE(6,123)
  123   FORMAT(1H ,'WNDIRDIG:ERROR IN GIVEN LEN OF ARG3: C2DIR;',
     1        /1H ,7X,'CALLER MUST DEFINE AS CHARACTER STRING ',
     2                ' OF LEN AT LEAST *2')
        GO TO 999
      ENDIF
C     ... OTHERWISE, C2DIR IS A CHARACTER STRING WITH LEN .GE. 2;
      IF(C2DIR .EQ. '99') THEN
        GO TO 800		!... CALM WIND; DO NOTHING EXIT
      ENDIF

      IDDA = 45 - IDDGD
      IF(IDDA .GE. 36) THEN
        IDDA = IDDA - 36
      ENDIF

      IF(IQUAD .EQ. 0) THEN
C       ... ORIENTATION DEFAULT -- UPRIGHT...
        HEIGHT = 19.0
        ANGLE = 0.0
        ADXLL = ADXLLCON(1)
        ADYKK = ADYLLCON(1)
        IROTA = 0
        IPRIOR = 1
      ELSE IF(IQUAD .EQ. 1) THEN
C       ... ORIENTATION SIDEWAYS, LIKE ON MERCATOR ...
        HEIGHT = 24.0
        ANGLE = 90.0
        ADXLL = ADXLLCON(2)
        ADYKK = ADYLLCON(2)
        IROTA = 0
        IPRIOR = 1
      ELSE IF(IQUAD .EQ. 2) THEN
C       ... ORIENTATION UPSIDE-DOWN
        HEIGHT = 19.0
        ANGLE = 180.0
        ADXLL = ADXLLCON(3)
        ADYKK = ADYLLCON(3)
        IROTA = 2
        IPRIOR = 1
      ELSE IF(IQUAD .EQ. 3) THEN
C       ... ORIENTATION UPSIDE-DOWN FROM MERCATOR PERSPECTIVE ...
        HEIGHT = 19.0
        ANGLE = 270.0
        ADXLL = ADXLLCON(4)
        ADYKK = ADYLLCON(4)
        IROTA = 3
        IPRIOR = 1
      ELSE
C       ... ORIENTATION DEFAULT -- UPRIGHT...
        HEIGHT = 19.0
        ANGLE = 0.0
        ADXLL = ADXLLCON(1)
        ADYKK = ADYLLCON(1)
        IROTA = 0
        IPRIOR = 1
      ENDIF
      
C     ... TEST FOR IDDGD W/I RANGE BEFORE USING IT AS SUBSCRIPT ...
      JDDGRID = IDDGD
      IF(JDDGRID .GT. 36) THEN
        DO WHILE (JDDGRID .GT. 36)
          JDDGRID = JDDGRID - 36
        ENDDO
      ENDIF
C     ... WHEN IT FALLS THRU TO HERE, JDDGRID .LE. 36,
      IF(JDDGRID .LE. 0) THEN
        DO WHILE (JDDGRID .LE. 0)
          JDDGRID = JDDGRID + 36
        ENDDO
      ENDIF
C     ... WHEN IT FALLS THRU TO HERE, JDDGRID .GT. 0, SO WITHIN RANGE

      DDA   = IDDA 
      IF(LSRNHEMI) THEN
        DDA = DDA - 1.5
        ICORN = KSCORNIJ(1,JDDGRID)
        JCORN = KSCORNIJ(2,JDDGRID)
      ELSE
        DDA = DDA + 1.5
        ICORN = KNCORNIJ(1,JDDGRID)
        JCORN = KNCORNIJ(2,JDDGRID)
      ENDIF
C     ...PLOTTED DIGIT FIFTEEN  DEGREES AWAY FROM STAFF
      DIRAD = DDA*CONVTR
      DELX  = HYPOT*COS(DIRAD)
      DELY  = HYPOT*SIN(DIRAD)
      ILLDIG = NINT(FLOAT(IDOTS) + DELX + ADXLL)
      ILLDIG = ILLDIG + ICORN
      IF(ILLDIG .LE. 0) THEN
        GO TO 810
      ENDIF

      JLLDIG = NINT(FLOAT(JDOTS) + DELY + ADYLL)
      JLLDIG = JLLDIG + JCORN
      IF(JLLDIG .LE. 0) THEN
        GO TO 810
      ENDIF
C     ...THAT FINISHES POSITIONING OF DIGIT
      IPRIOR=1
      IF(C2DIR(2:2) .GE. '0' .AND. C2DIR(2:2) .LE. '9') THEN

        CALL PUTLAB(ILLDIG,JLLDIG,HEIGHT,C2DIR(2:2),ANGLE,1,IROT_PRI,0)

      ELSE
        WRITE(6,335)C2DIR(1:2)
  335   FORMAT(1H ,'WNDIRDIG:UNABLE TO PLOT WND-DIR DIGIT BECAUSE ',
     1             'GIVEN ILLEGAL C2DIR-VALUE="',A2,'"')
        GO TO 999
       
      ENDIF

      RETURN
C     ...WHICH IS NORMAL EXIT
C
  800 CONTINUE
C     ...COMES TO 800 FOR CALM WIND. NOTHING PLOTTED.
      RETURN

  810 CONTINUE
C     ...COMES TO 810 FOR NEG VALUED I OR J, SO OFF GRID-EXIT
      PRINT 811
  811 FORMAT(1H ,'WNDIRDIG: NEGATIVE-VALUED I/J SO POINT OFF-GRID')
      RETURN

  999 CONTINUE
      RETURN
      END
