!
      SUBROUTINE SNOW_HFLUX_EXPLICIT (
     I  NMAX      , NMAX_01   , NMAX_1    ,
     I  NMAX_2    , NMAX_3    , NMAX_4    , 
     I  DELT_SNOW , CVR_SNW   ,   
     I  SRAD_BUCKET_SNOW_TO_SNSL     ,  
     I  HDIFF_FLUX_H     , 
     M  HFLUX_CONV    , 
     O  ENG_BUCKET_SNOW_TO_SNSL )

!  ��ł̉��x�̎������Ă�B
!
!        S1    1
!        S2    2
!        S3    3
!        S4    4
! 
!   ����
!     �E�ォ��̃t���b�N�X�͗^�����Ă���B      
!
      USE SIBPRM , ONLY : 
     1    IDX    , 
     1    ISN      
!
      USE SIBCON , ONLY :
     1    HL_WTR_c , 
     1    HL_W2G_c  
!
#ifdef MONYOS
      USE SIB_MONIT, ONLY : ICS , MONIT_SIB ,
     1                      IMONIT_LEVEL , IMONIT_ALL  , 
     1                      IMONIT_FLUX_COMMON 
#endif
!
      IMPLICIT NONE 
!
! INPUT 
!
      INTEGER,INTENT(IN)    :: NMAX
      INTEGER,INTENT(IN)    :: NMAX_01(3)
!     INTEGER,INTENT(IN)    :: NMAX_02(3)
      INTEGER,INTENT(IN)    :: NMAX_1 (3)
      INTEGER,INTENT(IN)    :: NMAX_2 (3)
      INTEGER,INTENT(IN)    :: NMAX_3 (3)
      INTEGER,INTENT(IN)    :: NMAX_4 (3)
!
      REAL(8),INTENT(IN)   :: CVR_SNW      (IDX)
!
!     REAL(8),INTENT(IN)    :: TMP_SNOW    (IDX,ISN)
!     REAL(8),INTENT(IN)    :: TMP_SNSL    (IDX)
      REAL(8),INTENT(IN)    :: HDIFF_FLUX_H   (IDX,0:ISN) 
!
      REAL(8),INTENT(IN)    :: DELT_SNOW
!
!     REAL(8),INTENT(IN)    :: SRAD_FLUX_CNV (IDX,ISN)  ! 
      REAL(8),INTENT(IN)    :: SRAD_BUCKET_SNOW_TO_SNSL(IDX) 
!
!
! OUTPUT 
!
      REAL(8),INTENT(INOUT) :: HFLUX_CONV(IDX,ISN) 
      REAL(8),INTENT(OUT)   :: ENG_BUCKET_SNOW_TO_SNSL(IDX) 
!
! WORK
      REAL(8)               :: ENG_BUC_SNOW_TO_SNSL(IDX) 
      INTEGER               :: I
!
#ifdef MONYOS
      REAL(8),PARAMETER  :: ONE = 1.D0 
!     REAL(8)            :: WORK(IDX) 
      CHARACTER(7)       :: CMARK
#endif
!
      LOGICAL,SAVE :: LFIRST 
      DATA LFIRST / .TRUE. /
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'SNOW_HFLUX_EXPLICIT POCHAKA 00/07/29' 
        LFIRST = .FALSE.
      ENDIF
!
!  �e�w�̔M�̂��܂� HFLUX_CONV 
!    �Z�g���ɁA�M�`������������

!  ����w
!
      DO I=NMAX_01(2),NMAX
        HFLUX_CONV(I,1) = 
     1          HDIFF_FLUX_H(I,0)                
     1        + HFLUX_CONV(I,1)             ! �Z�g��
     1        - HDIFF_FLUX_H  (I,1) 
      ENDDO
!
!  ����w
!
      DO I=NMAX_2(2),NMAX
        HFLUX_CONV(I,2) = 
     1      + HFLUX_CONV(I,2) 
     1      + HDIFF_FLUX_H  (I,1)
     1      - HDIFF_FLUX_H  (I,2)
      ENDDO
!
!  ���O�w
!
      DO I=NMAX_3(2),NMAX
        HFLUX_CONV(I,3) = 
     1      + HFLUX_CONV(I,3) 
     1      + HDIFF_FLUX_H  (I,2)
     1      - HDIFF_FLUX_H  (I,3)
      ENDDO 
!
!  ���l�w
!
      DO I=NMAX_4(2),NMAX
        HFLUX_CONV(I,4) = 
     1      + HFLUX_CONV(I,4) 
     1      + HDIFF_FLUX_H  (I,3)
     1      - HDIFF_FLUX_H  (I,4)
      ENDDO
!
!  ========================
!  > �n�ʂւ̔M�t���b�N�X <  �i���������j
!  ========================
!
!  --------------------
!  > �M�g�U�t���b�N�X <
!  --------------------
!
      DO I=NMAX_01(2),NMAX_1(3)
        ENG_BUC_SNOW_TO_SNSL(I) =  HDIFF_FLUX_H(I,1) 
      ENDDO
!
      DO I=NMAX_2(2),NMAX_2(3)
        ENG_BUC_SNOW_TO_SNSL(I) =  HDIFF_FLUX_H(I,2) 
      ENDDO
!
      DO I=NMAX_3(2),NMAX_3(3)
        ENG_BUC_SNOW_TO_SNSL(I) =  HDIFF_FLUX_H(I,3) 
      ENDDO
!
      DO I=NMAX_4(2),NMAX_4(3)
        ENG_BUC_SNOW_TO_SNSL(I) =  HDIFF_FLUX_H(I,4) 
      ENDDO
!
!  --------------------------------
!  > �Ⴀ��E��Ȃ�������ł̕␳ <
!  --------------------------------
!     �����܂ł̌v�Z�ł� ENG_BUC_SNOW_TO_SNSL �͐Ⴀ��悾��
!     �ł̕��ϗʂł������B
!     �����Ŋi�q���ςɂ���B
!     ����炪���̂܂ܓy��ւ̓��͂ɂȂ�B
!
      DO 3000 I=NMAX_01(2),NMAX
        ENG_BUCKET_SNOW_TO_SNSL(I) = 
     1         + ENG_BUC_SNOW_TO_SNSL(I) 
     1               * CVR_SNW(I) * DELT_SNOW
     1         + SRAD_BUCKET_SNOW_TO_SNSL(I)    
 3000 CONTINUE  
!
!  --------------
!  > �ڍ׃��j�^ <
!  --------------
!
#ifdef MONYOS
      IF ( IMONIT_LEVEL .GE. IMONIT_FLUX_COMMON ) THEN
!
        CMARK  = 'HFLW12F' 
        CALL MONIT_SIB ( CMARK , HDIFF_FLUX_H(1,1), ICS, 
     1                   DELT_SNOW, ONE)  
!
        CMARK  = 'HFLW23F' 
        CALL MONIT_SIB ( CMARK , HDIFF_FLUX_H(1,2), ICS, 
     1                   DELT_SNOW, ONE)  
!
        CMARK  = 'HFLW34F' 
        CALL MONIT_SIB ( CMARK , HDIFF_FLUX_H(1,3), ICS, 
     1                   DELT_SNOW, ONE)  
!
        CMARK  = 'HFLW4LF' 
        CALL MONIT_SIB ( CMARK , HDIFF_FLUX_H(1,4), ICS, 
     1                   DELT_SNOW, ONE)  
!
      ENDIF
!
      IF ( IMONIT_LEVEL .GE. IMONIT_ALL ) THEN
!  �Ⴀ��y��ւ̔M
        CMARK  = 'HFLBWL' 
        CALL MONIT_SIB ( CMARK , ENG_BUC_SNOW_TO_SNSL,ICS,DELT_SNOW,ONE)  
      ENDIF
#endif
!
      RETURN
      END