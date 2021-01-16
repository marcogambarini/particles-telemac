!                    **********************
                     SUBROUTINE USER_FLOT3D
!                    **********************
!
     &(XFLOT,YFLOT,ZFLOT,NFLOT,NFLOT_MAX,X,Y,Z,IKLE,NELEM,NELMAX,NPOIN,
     & NPLAN,TAGFLO,SHPFLO,SHZFLO,ELTFLO,ETAFLO,MESH3D,LT,NIT,AT)
!
!***********************************************************************
! TELEMAC3D
!***********************************************************************
!
!brief    This subroutine is called at every time step, and the user can
!+        add or remove particles as in the example given
!
!history  J-M HERVOUET (EDF R&D, LNHE)
!+        26/02/2013
!+        V6P3
!+    First version.
!
!history  Y. AUDOUIN (LNHE)
!+        22/10/18
!+        V8P1
!+   Creation from FLOT3D
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!| AT             |-->| TIME
!| ELTFLO         |<->| NUMBERS OF ELEMENTS WHERE ARE THE FLOATS
!| ETAFLO         |<->| LEVELS WHERE ARE THE FLOATS
!| LT             |-->| CURRENT TIME STEP
!| MESH3D         |<->| 3D MESH STRUCTURE
!| NFLOT          |-->| NUMBER OF FLOATS
!| NFLOT_MAX      |-->| MAXIMUM NUMBER OF FLOATS
!| NIT            |-->| NUMBER OF TIME STEPS
!| NPLAN          |-->| NUMBER OF PLANES
!| NPOIN          |-->| NUMBER OF POINTS IN THE MESH
!| SHPFLO         |<->| BARYCENTRIC COORDINATES OF FLOATS IN THEIR
!|                |   | ELEMENTS.
!| SHZFLO         |<->| BARYCENTRIC COORDINATES OF FLOATS IN THEIR LEVEL
!| X              |-->| ABSCISSAE OF POINTS IN THE MESH
!| Y              |-->| ORDINATES OF POINTS IN THE MESH
!| Z              |-->| ELEVATIONS OF POINTS IN THE MESH
!| XFLOT          |<->| ABSCISSAE OF FLOATING BODIES
!| YFLOT          |<->| ORDINATES OF FLOATING BODIES
!| ZFLOT          |<->| ELEVATIONS OF FLOATING BODIES
!| LAB            |   | PARTICLE LABEL
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF
      USE STREAMLINE, ONLY : ADD_PARTICLE,DEL_PARTICLE
      USE INTERFACE_TELEMAC3D, EX_USER_FLOT3D => USER_FLOT3D
      USE DECLARATIONS_TELEMAC3D, ONLY: T3D_FILES, T3DFO1
!
      IMPLICIT NONE
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN)             :: NPOIN,NIT,NFLOT_MAX,LT,NPLAN
      INTEGER, INTENT(IN)             :: NELEM,NELMAX
      INTEGER, INTENT(IN)             :: IKLE(NELMAX,*)
      INTEGER, INTENT(INOUT)          :: NFLOT
      INTEGER, INTENT(INOUT)          :: TAGFLO(NFLOT_MAX)
      INTEGER, INTENT(INOUT)          :: ELTFLO(NFLOT_MAX)
      INTEGER, INTENT(INOUT)          :: ETAFLO(NFLOT_MAX)
      DOUBLE PRECISION, INTENT(IN)    :: X(NPOIN),Y(NPOIN),Z(NPOIN),AT
      DOUBLE PRECISION, INTENT(INOUT) :: XFLOT(NFLOT_MAX)
      DOUBLE PRECISION, INTENT(INOUT) :: YFLOT(NFLOT_MAX)
      DOUBLE PRECISION, INTENT(INOUT) :: ZFLOT(NFLOT_MAX)
      DOUBLE PRECISION, INTENT(INOUT) :: SHPFLO(3,NFLOT_MAX)
      DOUBLE PRECISION, INTENT(INOUT) :: SHZFLO(NFLOT_MAX)
      TYPE(BIEF_MESH) , INTENT(INOUT) :: MESH3D
      INTEGER :: N, I
      
      INTEGER, ALLOCATABLE, DIMENSION(:) :: LAB
      INTEGER, ALLOCATABLE, DIMENSION(:) :: RELEASE_STEP
      DOUBLE PRECISION, ALLOCATABLE, DIMENSION(:) :: XNEWPART
      DOUBLE PRECISION, ALLOCATABLE, DIMENSION(:) :: YNEWPART
      DOUBLE PRECISION, ALLOCATABLE, DIMENSION(:) :: ZNEWPART

      INTEGER                         :: UL
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
! REMEMBER LOCAL DATA AT NEXT CALL
      SAVE
!
!-----------------------------------------------------------------------
!

!AT THE FIRST TIME STEP, READ DATA FROM THE FILE
! (WHY DOESNT IT WORK AT STEP ZERO?)
      IF(LT.EQ.1) THEN

      PRINT*, "READING FROM DROGUES FILE"        
        
      UL = T3D_FILES(T3DFO1)%LU
! FIRST LINE: TOTAL NUMBER OF PARTICLES FOR ALLOCATION
      READ(UL,*) N
        
      PRINT*, "TOTAL NUMBER OF DROGUES", N
! SECOND LINE (HEADER): IGNORE
      READ(UL,*)

      ALLOCATE(LAB(N))
      ALLOCATE(RELEASE_STEP(N))
      ALLOCATE(XNEWPART(N))
      ALLOCATE(YNEWPART(N))
      ALLOCATE(ZNEWPART(N))
        
      DO I=1,N
        READ(UL,*) LAB(I), RELEASE_STEP(I), XNEWPART(I),
     &             YNEWPART(I), ZNEWPART(I)
      ENDDO


      ENDIF

!AT EACH TIME STEP, CHECK IF PARTICLES SHOULD BE ADDED
      DO I=1,N
        IF (LT.EQ.RELEASE_STEP(I)) THEN
          PRINT*, "ADDING PARTICLE ", LAB(I)
          CALL ADD_PARTICLE(XNEWPART(I),YNEWPART(I),ZNEWPART(I),
     &           LAB(I),NFLOT,
     &           NFLOT_MAX,XFLOT,YFLOT,ZFLOT,TAGFLO,
     &           SHPFLO,SHZFLO,ELTFLO,ETAFLO,MESH3D,NPLAN,
     &           0.D0,0.D0,0.D0,0.D0,0,0)
        ENDIF
      ENDDO



!
!-----------------------------------------------------------------------
!
      RETURN
      END
