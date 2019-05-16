! ���܂�菀��
! 99/07/xx �ۍ␪�G
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
! 99/08/31 �ۍ␪�G rho_newsnow_inv �̏����l��^����悤�ɂ���B
!                   ��ŎQ�Ƃ���邱�Ƃ����邽�߁B�Q�Ƃ̂�����`�F�b�N�v�B
!
      SUBROUTINE SNOW_WFLUX_PRE (
     I   NMAX    , DELT_SNOW         , 
     I   NMAX_0  , NMAX_01 , NMAX_2  , NMAX_3  , NMAX_4  , 
     I   GLA_SNOW, WTR_SNOW, TMP_SNOW, 
     I   CVR_SNW , 
     I   HFLUX_CONV     , 
     I   H2O_BUCKET_INTO_SNOW        ,ENH_BUCKET_INTO_SNOW        ,
     I   ENG_SNOW_BUCKET , H2O_SNOW_BUCKET , 
     I   U_REF       , V_REF       , TMP_REF      , 
     I   RHO_SNOW_INV_IN   , 
     O   ENG_PRECIPI , H2O_PRECIPI , RHO_PRECIPI_INV  , 
     O   ENG_SNOW    , H2O_SNOW    , RHO_SNOW_INV , 
     O   IFLG_SLEV_CHANGE      )                      ! ���������邾��

!
! ����
!
!  �E �����ŁA�i�q���ϒl�Ƃ��Ĉ������Ƃɒ��ӁB
!     01 �ɂ��Ă� *CVR_SNW ���Ă���B
!     �~�J�E�~��͂�������Ă���Ƃ����B
!
!  �E �ᖳ����ɐႪ�~�������̂́A����̐؂蒼���Ɠ��l�Ɉ����B
!
      USE SIBPRM , ONLY :
     1   IDX   , 
     1   ISN  
!
      USE SIBCON , ONLY : 
     1    CAP_WTR_c ,                             ! ���̔�M
     1    CAP_GLA_c ,                             ! ���̔�M
     1    HL_W2G_c    ,                             ! �X -> ��
     1    TMP_FREZ_c                              ! �������x
!
#ifdef MONYOS
      USE SIB_MONIT, ONLY : MONIT_SIB, INA, ICS ,
     1                      IMONIT_LEVEL , IMONIT_ALL   
!
      USE COM_STEP_SIB0109 , ONLY : ICN_SIB0109_MONITOR 
#endif

!
      IMPLICIT NONE
!
! INPUT
!
      INTEGER,INTENT(IN)   :: NMAX
      INTEGER,INTENT(IN)   :: NMAX_0 (3)
      INTEGER,INTENT(IN)   :: NMAX_01(3)
      INTEGER,INTENT(IN)   :: NMAX_2 (3)
      INTEGER,INTENT(IN)   :: NMAX_3 (3)
      INTEGER,INTENT(IN)   :: NMAX_4 (3)
!
      REAL(8),INTENT(IN)   :: CVR_SNW  (IDX)
!
!  �o�P�c �i�ᖳ������ʂ����i�q���ρATMP_SNOW ���������Ă���j
! 
      REAL(8),INTENT(IN)   :: ENH_BUCKET_INTO_SNOW (IDX)! �J���G�l���M�[
      REAL(8),INTENT(IN)   :: H2O_BUCKET_INTO_SNOW (IDX)    ! �J�̗�
!
      REAL(8),INTENT(IN)   :: TMP_SNOW  (IDX,ISN+1)   ! ��̉��x
      REAL(8),INTENT(IN)   :: GLA_SNOW  (IDX,ISN)     ! ��̕X�̗�
      REAL(8),INTENT(IN)   :: WTR_SNOW  (IDX,ISN)     ! ��̐��̗�
!
      REAL(8),INTENT(IN)   :: HFLUX_CONV (IDX,ISN) 
!                                                !��w�̎󂯎��G�l���M�[
!
      REAL(8),INTENT(IN)   :: RHO_SNOW_INV_IN    (IDX,ISN)
      REAL(8),INTENT(IN)   :: DELT_SNOW  
!
      REAL(8),INTENT(IN)   :: ENG_SNOW_BUCKET(IDX)
      REAL(8),INTENT(IN)   :: H2O_SNOW_BUCKET(IDX)
!
      REAL(8),INTENT(IN)   :: U_REF    (IDX)
      REAL(8),INTENT(IN)   :: V_REF    (IDX)
      REAL(8),INTENT(IN)   :: TMP_REF  (IDX)
!
! OUTPUT
!
!   ��ϕ��p
      REAL(8),INTENT(OUT)  :: ENG_SNOW    (IDX,ISN)   ! ����̃G�l���M�[
      REAL(8),INTENT(OUT)  :: H2O_SNOW    (IDX,ISN)   ! ����̎���
      REAL(8),INTENT(OUT)  :: ENG_PRECIPI (IDX)       ! �~��̃G�l���M�[
      REAL(8),INTENT(OUT)  :: H2O_PRECIPI (IDX)       ! �~��̎���
!
      REAL(8),INTENT(OUT)  :: RHO_SNOW_INV   (IDX,ISN)
      REAL(8),INTENT(OUT)  :: RHO_PRECIPI_INV(IDX)
!
      INTEGER,INTENT(OUT)  :: IFLG_SLEV_CHANGE (IDX) ! ��w�̕ύX�t���O 
!
!
! WORK
!
      REAL(8)      :: ENX_SNOW1    ! ���w�� ENX 
      INTEGER      :: I
      INTEGER      :: K
      LOGICAL,SAVE :: LFIRST 
!
#ifdef MONYOS
      REAL(8),PARAMETER  :: ONE =  1.D0 
      CHARACTER(7)       :: CMARK
#endif
!
      DATA LFIRST / .TRUE. /
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'SNOW_WFLUX_PRE POCHAKA 01/08/17' 
        LFIRST = .FALSE.
      ENDIF
!
!  ������
!
      ENG_SNOW(:,:) = 0.D0
      H2O_SNOW(:,:) = 0.D0
      IFLG_SLEV_CHANGE (:) = 0        ! ���Z�b�g
!
! ======================
! >> �~��E�~���̌v�Z <<   
! ======================
!  �~��E�~��  ... ���͂͊i�q���ϒl�ł���B
!                  �o�͂�����ŗǂ�
!
      DO I=1,NMAX
        ENG_PRECIPI(I) =   ENH_BUCKET_INTO_SNOW (I) 
!
        H2O_PRECIPI(I) =   H2O_BUCKET_INTO_SNOW (I) 
!
        RHO_PRECIPI_INV(I) 
     1      = 1 / 
     1            ( 3.6 * SQRT(U_REF(I)**2 + V_REF(I)**2 )
     1              - 0.2 * ( TMP_REF(I) - TMP_FREZ_c ) 
     1              + 62 )
      ENDDO
!
!
! ==========================
! >> ��̖��x�ω��i���d�j <<       
! ==========================
!   check  ��̖��x�ϕ��i�j�������ł��Ă��܂��H
!
      CALL SNOW_RHO_INTG (
     I    NMAX  , NMAX_01 , NMAX_2  , NMAX_3  , NMAX_4  , 
     I    RHO_SNOW_INV_IN , 
     I    DELT_SNOW       ,
     I    WTR_SNOW        , GLA_SNOW      , TMP_SNOW   , 
     O    RHO_SNOW_INV    )
!
! ============================
! >> �e�w�̃G�l���M�[�̌v�Z <<   
! ============================
!
!  ���w
!
      DO I=NMAX_01(2),NMAX
        ENG_SNOW (I,1) =  
     1      CAP_GLA_c * ( TMP_SNOW(I,1) - TMP_FREZ_c ) * GLA_SNOW (I,1) 
     1        - HL_W2G_c  * GLA_SNOW (I,1) 
     1        + HFLUX_CONV(I,1) * DELT_SNOW
        H2O_SNOW (I,1) = GLA_SNOW(I,1)    + WTR_SNOW(I,1) 
      ENDDO
!
!   01 �͊i�q���ϒl�ɂ��� �i CVR_SNW �{ �j
!
      DO I=NMAX_01(2),NMAX_01(3)              
        ENG_SNOW (I,1) = ENG_SNOW (I,1) * CVR_SNW(I) 
        H2O_SNOW (I,1) = H2O_SNOW (I,1) * CVR_SNW(I) 
      ENDDO
!
!  ���w
!
      DO I=NMAX_2(2),NMAX
        ENG_SNOW (I,2) =  
     1      CAP_GLA_c * ( TMP_SNOW(I,2) - TMP_FREZ_c ) * GLA_SNOW (I,2) 
     1        - HL_W2G_c  * GLA_SNOW (I,2) 
     1        + HFLUX_CONV(I,2) * DELT_SNOW
        H2O_SNOW (I,2) = GLA_SNOW(I,2)    + WTR_SNOW(I,2) 
      ENDDO
!
!  ��O�w
!
      DO I=NMAX_3(2),NMAX
        ENG_SNOW (I,3) =  
     1      CAP_GLA_c * ( TMP_SNOW(I,3) - TMP_FREZ_c ) * GLA_SNOW (I,3) 
     1        - HL_W2G_c  * GLA_SNOW (I,3) 
     1        + HFLUX_CONV(I,3) * DELT_SNOW
        H2O_SNOW (I,3) = GLA_SNOW(I,3)    + WTR_SNOW(I,3) 
      ENDDO
!
!  ��l�w
!
      DO I=NMAX_4(2),NMAX
        ENG_SNOW (I,4) =  
     1      CAP_GLA_c * ( TMP_SNOW(I,4) - TMP_FREZ_c ) * GLA_SNOW (I,4) 
     1        - HL_W2G_c  * GLA_SNOW (I,4) 
     1        + HFLUX_CONV(I,4) * DELT_SNOW
        H2O_SNOW (I,4) = GLA_SNOW(I,4)    + WTR_SNOW(I,4) 
      ENDDO
!
!  ================
!  >> �N��̕␳ <<
!  ================
!  �V��w���M�ŗZ���Ă��Ă�����A���̃X�e�b�v�͋��� 
!
! ==============
! > �ڍ׃��j�^ <
! ==============
!
#ifdef MONYOS
      IF ( IMONIT_LEVEL .GE. IMONIT_ALL ) THEN
!
! ���o�P�c from canopy 
        CMARK  = 'WFLBWS' 
        CALL MONIT_SIB ( CMARK , H2O_BUCKET_INTO_SNOW, INA , ONE , ONE )
!
! ���o�P�c from canopy �ɔ����M
        CMARK  = 'IFLBWS' 
        CALL MONIT_SIB ( CMARK , ENH_BUCKET_INTO_SNOW, INA , ONE, ONE)
!
! ����o�P�c  
!
        CMARK  = 'WLWBGET' 
        CALL MONIT_SIB ( CMARK , H2O_SNOW_BUCKET, INA , ONE   , ONE )  !ver2
!
        CMARK  = 'HLWBGET' 
        CALL MONIT_SIB ( CMARK , ENG_SNOW_BUCKET, INA , ONE   , ONE )  !ver2
!
! �u�Ԓl
!      
        IF ( ICN_SIB0109_MONITOR.EQ.1 ) THEN
!
        DO K=1,ISN
!
! �G�l���M�[
!
          CMARK  = 'ENGWxY'                           ! �X�i�b�v
          WRITE ( CMARK(5:5) , '(I1)' ) K
          CALL MONIT_SIB ( CMARK , ENG_SNOW(1,K), ICS, DELT_SNOW, ONE )  
!
! H2O
!
          CMARK  = 'H2OWxY'                           ! �X�i�b�v
          WRITE ( CMARK(5:5) , '(I1)' ) K
          CALL MONIT_SIB ( CMARK , H2O_SNOW(1,K), ICS, DELT_SNOW, ONE )
!
        ENDDO  
        ENDIF
!
      ENDIF
#endif
!
! ==============================
! >> ����o�P�c���~��ɍ����� <<
! ==============================
!
      DO I = 1,NMAX
        H2O_PRECIPI(I) = H2O_PRECIPI(I) + H2O_SNOW_BUCKET(I) 
        ENG_PRECIPI(I) = ENG_PRECIPI(I) + ENG_SNOW_BUCKET(I) 
      ENDDO
!
!  ====================
!  >> 0 �w�Őᓙ���� <<
!  ====================
!  
      DO I=1,NMAX_0(3)
        IF (       H2O_BUCKET_INTO_SNOW(I) .GT. 0. 
     1        .OR. H2O_SNOW_BUCKET     (I) .GT. 0. ) THEN 
          IFLG_SLEV_CHANGE(I) = 1
        ENDIF
      ENDDO
!

      RETURN
      END
!============================================================
      SUBROUTINE MR_SNOW_WFLUX_PRE
!
! SNOW_WFLUX_PRE �ŏo�͂���f�o�b�O�p�ϐ��̓o�^���
!
      USE SIBPRM , ONLY :
     1   ISN 
!
#ifdef MONYOS
      USE SIB_MONIT, ONLY : 
     1                      IMONIT_LEVEL , IMONIT_ALL   
#endif
!
      IMPLICIT NONE
!
      CHARACTER( 7)  :: CMARK 
      CHARACTER(32)  :: CTITLE 
      CHARACTER(13)  :: CUNIT
!
      LOGICAL,SAVE ::  LFIRST 
!
      INTEGER :: K 
!
      DATA LFIRST /.TRUE./
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'MONIT_REGIST_SNOW_WFLUX_PRE 99/10 POCHAKA'
        LFIRST = .FALSE. 
      ENDIF
!
#ifdef MONYOS
      IF ( IMONIT_LEVEL .GE. IMONIT_ALL ) THEN
!
! �~��
!
      CMARK  = 'WFLBWS'
      CTITLE = 'BUCKET H2O INTO SNOW'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
! �~���ɔ����M
!
      CMARK  = 'IFLBWS'
      CTITLE = 'ENG WITH BUCKET H2O INTO SNOW'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
! ����o�P�c
!
      CMARK  = 'WLWBGET'
      CTITLE = 'H2O GET FROM LITTLE SNOW BUCKET '
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
! ����o�P�c
!
      CMARK  = 'HLWBGET'
      CTITLE = 'ENG WITH H2O IN LITTLE SNOW BUCKET '
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
! ���Ԃł� H2O snap
!
      CMARK  = 'H2OWxY'
      CTITLE = 'H2O SNOW x - BEFORE SNOW_WATER_CALC SNAP'
      CUNIT  = 'KG/M**2/S'
      DO K=1,ISN
        WRITE ( CMARK (5:5)   , '(I1)' ) K
        WRITE ( CTITLE(10:10) , '(I1)' ) K
        CALL monit_regist_sib_snap ( CMARK , CTITLE , CUNIT )
      ENDDO

! ���Ԃł� ENG snap
!
      CMARK  = 'ENGWxY'
      CTITLE = 'ENG SNOW x - BEFORE SNOW_WATER_CALC SNAP'
      CUNIT  = 'W/M**2'
      DO K=1,ISN
        WRITE ( CMARK (5:5)   , '(I1)' ) K
        WRITE ( CTITLE(10:10) , '(I1)' ) K
        CALL monit_regist_sib_snap ( CMARK , CTITLE , CUNIT )
      ENDDO
!
      ENDIF
#endif
!
      RETURN
      END