!
! ISLSCP�֘A���W���[��
!
!   ����
!     �EJOB ���s�͐����X�^�[�g
!     �E�Z�g�E���g�v�Z�͈ꎞ�ԂɈ�x�͍s�Ȃ��B
!
!  -----------------------------------------------------------
!   
      MODULE ISLSCP
!
      USE PRM , ONLY :                    ! ���f��
     1    IDIM  , 
     1    JDIM  , 
     1    JLPHY , 
     1    IJPHY , 
     1    IRAD  ,
     1    JRAD  ,
     1    JPHY2 
!
      USE COM_RUNCONF_SIB0109 , ONLY :            ! �W���u���萔
     1    JCN_SIB_ISLSCP_CYCLE1987 , 
!    1    JCN_SIB_MONIT_DETAIL     , 
     1    JCN_IWL_SKIP 
!
      USE ISLSCP_FILE_UNIT , ONLY :       ! �t�@�C�����u�ԍ�
     1    IFILE_MWND  , 
     1    IFILE_TEMP  , 
     1    IFILE_PRSS  , 
     1    IFILE_QREF  , 
     1    IFILE_TPRC  , 
     1    IFILE_CPRC  , 
     1    IFILE_LWDN  , 
     1    IFILE_SWDN  , 
     1    IFILE_CLD

	USE TS, ONLY:
     1     TIME_STEP, RSEC_CLEAN

!
#ifdef MONYOS
      use sib_monit, only : imonit_level , imonit_select 
#endif
!
      IMPLICIT NONE   
!
!
! SAVE �ϐ�
!
      REAL(4),SAVE   :: U_PRE    (IDIM,JDIM)         
      REAL(4),SAVE   :: PS_PRE   (IDIM,JDIM)
      REAL(4),SAVE   :: TMP_PRE  (IDIM,JDIM)
      REAL(4),SAVE   :: Q_PRE    (IDIM,JDIM)
!
      REAL(4),SAVE   :: U_NEXT   (IDIM,JDIM)
      REAL(4),SAVE   :: PS_NEXT  (IDIM,JDIM)
      REAL(4),SAVE   :: TMP_NEXT (IDIM,JDIM)
      REAL(4),SAVE   :: Q_NEXT   (IDIM,JDIM)
!
      REAL(4),SAVE   :: RLWD_PRE (IDIM,JDIM)
      REAL(4),SAVE   :: RLWD_NEXT(IDIM,JDIM)
!
      REAL(4),SAVE   :: RSWD_SUM (IDIM,JDIM)
      REAL(4),SAVE   :: PTOT_SUM (IDIM,JDIM)
      REAL(4),SAVE   :: PCNV_SUM (IDIM,JDIM)
!
      REAL(4),SAVE   :: CLD_PRE  (IDIM,JDIM)
      REAL(4),SAVE   :: CLD_NEXT (IDIM,JDIM)
!
      REAL(8),SAVE   :: SR_FLUX_WORK(IDIM,JDIM)
!
      LOGICAL,SAVE   :: LFIRST
!
      INTEGER,SAVE :: 
     1     JCN_ISLSCP_GRADS   = 0      ! ISLSCP ���͂� GrADS �`���Ȃ� 1 
                                       ! ���� 360x180 �̂݃T�|�[�g
                                       ! ���i�q��T�����A���ܓx�o�x�B
!
      DATA LFIRST / .TRUE. / 
!
      CONTAINS 
!
! =====================================================================
!
      SUBROUTINE ISLSCP_INI (
     I   ID_NOW     , DELT_ATM    , 
     I   RSEC       , 
     I   IMASK      , 
     I   GLON       , GLAT        ) 
!
      USE CALENDAR , ONLY : 
     1     CALENDAR_RUN_GETKT ,
     1     CALENDAR_RUN_GETID

!
! ISLSCP �̏�������
!   �O�̓ǂݍ��ݒi�K�œǂ�ł����ׂ��f�[�^��ǂݍ���
!   ����B���� ID_NOW �͐���
! 
!
      IMPLICIT NONE
!
! INPUT
!
      INTEGER,INTENT(IN) :: ID_NOW    (5)         ! �{�X�e�b�v�̎���
      INTEGER,INTENT(IN) :: IMASK     (IDIM,JDIM)
      REAL(8),INTENT(IN) :: RSEC 
      REAL(8),INTENT(IN) :: DELT_ATM
!
      REAL(8),INTENT(IN) :: GLON (IDIM,JDIM)     ! �o�x�i�P�ʁA�x�j
      REAL(8),INTENT(IN) :: GLAT (IDIM,JDIM)     ! �ܓx�i�P�ʁA�x�j
!
! WORK
!
      INTEGER :: ID_PRE     (5)        ! �O�X�e�b�v�̎���
      INTEGER :: ID_PRE_00Z (5) 
      INTEGER :: ID_NEXT_00Z(5)  
      INTEGER :: ID_PRE_03Z (5) 
      INTEGER :: ID_NEXT_03Z(5)  
      INTEGER :: ID_PRE_CLD (5) 
      INTEGER :: ID_NEXT_CLD(5) 
      INTEGER :: ID_WORK_1  (5) 
      INTEGER :: ID_WORK_2  (5) 
      REAL(8) :: RSEC_OLD 
      REAL(8) :: RDAY_OLD 
      REAL(8) :: RDAY_TOT
      INTEGER :: KT_LAG 
!
! ==============
! >> �������� <<
! ==============
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'ISLSCP_INI 00/06/12 POCHAKA '
        LFIRST = .FALSE. 
      ELSE
        WRITE(6,*) 'ISLSCP_INI ERROR : NOT FIRST TIME'
        stop 999
      ENDIF
!
!  �`�F�b�N
!
      IF (       JCN_ISLSCP_GRADS.NE.0 
     1     .AND. (IDIM.NE.360 .OR. JDIM.NE.180) ) THEN
        write(6,*) 'islscp_ini error jcn_islscp_grads -> 360x180'
        stop 999
      ENDIF
!
!     SEC_6HR_00Z  = MOD ( ID_NOW(4)   , 6 ) * 3600.D0 + DELT_ATM / 2 
!     SEC_6HR_LWDN = MOD ( ID_NOW(4)+3 , 6 ) * 3600.D0 + 1800.D0 
!
! ==================================
! >> �t�@�C������f�[�^�̓ǂݍ��� <<
! ==================================
!
      KT_LAG = -1 
      CALL CALENDAR_RUN_GETID ( ID_NOW , ID_PRE ,  KT_LAG )
!
!  �ǂݍ��ݓ����̐ݒ�
!
      write(6,*) 'idpre' ,id_pre 
      CALL ISLSCP_GETID_XX  ( ID_PRE , 0 , ID_PRE_00Z , ID_NEXT_00Z ) 
      CALL ISLSCP_GETID_XX  ( ID_PRE , 3 , ID_PRE_03Z , ID_NEXT_03Z )  
      CALL ISLSCP_GETID_CLD ( ID_PRE ,     ID_PRE_CLD , ID_NEXT_CLD )  
!
!  00 + 6xn �f�[�^�̓ǂݍ���
!
      write(6,*) 'ISLSCP_INI PREDATA  ' , ID_PRE_00Z
      CALL ISLSCP_RDFL (IFILE_MWND,'MWND',ID_PRE_00Z ,IMASK,U_PRE   )
      CALL ISLSCP_RDFL (IFILE_PRSS,'PRSS',ID_PRE_00Z ,IMASK,PS_PRE  )
      CALL ISLSCP_RDFL (IFILE_TEMP,'TEMP',ID_PRE_00Z ,IMASK,TMP_PRE )
      CALL ISLSCP_RDFL (IFILE_QREF,'QREF',ID_PRE_00Z ,IMASK,Q_PRE   )
!
      CALL ISLSCP_RDFL (IFILE_TPRC,'TPRC',ID_PRE_00Z ,IMASK,PTOT_SUM )     
      CALL ISLSCP_RDFL (IFILE_CPRC,'CPRC',ID_PRE_00Z ,IMASK,PCNV_SUM )     
      CALL ISLSCP_RDFL (IFILE_SWDN,'SWDN',ID_PRE_00Z ,IMASK,RSWD_SUM )     
!
      write(6,*) 'ISLSCP_INI NEXTDATA ' , ID_NEXT_00Z
      CALL ISLSCP_RDFL (IFILE_MWND,'MWND',ID_NEXT_00Z,IMASK,U_NEXT  )
      CALL ISLSCP_RDFL (IFILE_PRSS,'PRSS',ID_NEXT_00Z,IMASK,PS_NEXT )
      CALL ISLSCP_RDFL (IFILE_TEMP,'TEMP',ID_NEXT_00Z,IMASK,TMP_NEXT)
      CALL ISLSCP_RDFL (IFILE_QREF,'QREF',ID_NEXT_00Z,IMASK,Q_NEXT  )
!
!  6HR PRE �f�[�^�̓ǂݍ��� �i���g�j
!     �Ⴆ�΍��� 01Z (���邢�� 21Z-03Z �̂����̂ǂ���)�ł���Ƃ���B
!     ID_PRE_03Z �A_NEXT_03Z �ɂ͒l�Ƃ��� 21Z �� 03Z �������Ă���B
!
!     ���g�́A00Z �̃f�[�^�́iISLSCP �ɊԈႢ���Ȃ���΁j 00Z-06Z�i����03Z�j��
!     �f�[�^�Ȃ̂ŁA18Z�i����21Z�j �� 00Z �i����03Z�j�̃f�[�^��ǂ߂΂悢�B
!
!     ���ۂɂ� ISLSCP �f�[�^�ɂ͊ԈႢ�������āA
!         00Z �̃f�[�^ = 18Z-00Z�i����21Z�j �̃f�[�^
!     �Ȃ̂ŁA00Z�i����21Z�j �� 06Z �i����03Z�j�̃f�[�^��ǂޕK�v������B
!
!     �܂� ID_PRE_03Z , _NEXT_03Z �� +3 ���Ԃ����f�[�^��ǂޕK�v������B
!     ���� +3 ���Ԃ̑���� ISLSCP_RDFL ���s�Ȃ��B
!       
      write(6,*) 'ISLSCP_INI  LWDN PRE  DATA  ' , ID_PRE_03Z
      CALL ISLSCP_RDFL ( IFILE_LWDN,'LWDN',ID_PRE_03Z ,IMASK,RLWD_PRE ) 
      write(6,*) 'ISLSCP_INI  LWDN NEXT DATA  ' , ID_NEXT_03Z
      CALL ISLSCP_RDFL ( IFILE_LWDN,'LWDN',ID_NEXT_03Z,IMASK,RLWD_NEXT) 
!
!  �_�ʃf�[�^�̓ǂݍ���
!
      write(6,*) 'ISLSCP_INI CLD  PRE  DATA  ' , ID_PRE_CLD
      CALL ISLSCP_RDFL (IFILE_CLD ,'CLD ',ID_PRE_CLD , IMASK,CLD_PRE )       
      write(6,*) 'ISLSCP_INI CLD  NEXT DATA  ' , ID_NEXT_CLD
      CALL ISLSCP_RDFL (IFILE_CLD ,'CLD ',ID_NEXT_CLD,IMASK,CLD_NEXT )       
!
! ============================
! >> �Z�g�d�݃e�[�u���̍쐬 <<
! ============================
!  ���B�����X�^�[�g��O��Ƃ��Ă���̂�
!      �Z�g�E���g�� 1 ���Ԓl�́AISLSCP_INI �ł͗p�ӂ���K�v�Ȃ��B
!
!   ��O�� (00+6xn)Z �ł� RDAY , RSEC �̌v�Z
!
!    RDAY_OLD �̌v�Z ( = ID_PRE �ɂ����� RDAY )
!
      KT_LAG = 0 
      CALL CALENDAR_RUN_GETID ( ID_PRE , ID_WORK_1 , KT_LAG )
      ID_WORK_1(2) = 1 
      ID_WORK_1(3) = 1 
      ID_WORK_1(4) = 0 
      KT_LAG = 0 
      CALL CALENDAR_RUN_GETID ( ID_WORK_1 , ID_WORK_2 , KT_LAG )
      ID_WORK_2(1) = ID_WORK_1(1) + 1 
      CALL CALENDAR_RUN_GETKT ( ID_WORK_1 , ID_WORK_2 , 3 , KT_LAG )
      RDAY_TOT = KT_LAG * 1.D0
!
      CALL CALENDAR_RUN_GETKT ( ID_WORK_1 , ID_PRE    , 3 , KT_LAG )
      RDAY_OLD = KT_LAG * 1.D0 / RDAY_TOT
#ifdef DEBUG
      write(6,*) 'ISLSCP_INI RDAY_OLD =' , RDAY_OLD , RDAY_TOT , 
     1           KT_LAG,
     1           RDAY_OLD*365
#endif
!
!   RSEC_OLD �̌v�Z
!
      KT_LAG   = MOD ( ID_PRE(4) , 6 ) 
      RSEC_OLD = RSEC 
!
      IF ( RSEC*24 .LT. 5.99 ) THEN 
         RSEC_OLD = RSEC_OLD + 1.D0 
      ENDIF
!
      RSEC_OLD = RSEC_OLD - ( KT_LAG + 1 ) / 24.D0 
#ifdef DEBUG
      write(6,*) 'ISLSCP_INI RSEC_OLD =' , RSEC_OLD , RSEC 
#endif
      CALL RSEC_CLEAN ( RSEC_OLD ) 
#ifdef DEBUG
      write(6,*) 'ISLSCP_INI RSEC_OLD =' , RSEC_OLD , RSEC ,
     1           RSEC_OLD*86400. , 86400-RSEC_OLD*86400.
#endif
!
!   �Z�g�̌v�Z
!
      CALL ISLSCP_SWDN_6HR ( 
     I    RDAY_OLD  , RSEC_OLD , DELT_ATM , 
     I    GLON      , GLAT     , IMASK    , 
     M    RSWD_SUM  , 
     O    SR_FLUX_WORK         )
!
      RETURN
      END SUBROUTINE ISLSCP_INI
! =====================================================================
      SUBROUTINE ISLSCP_MAIN ( 
     I   ID_NOW     , ID_PRE     , DELT_ATM   ,
     I   RDAY       , RSEC        , 
     I   IMASK      , 
     I   GLON       , GLAT       , 
     O   U_PHY      , V_PHY       , 
     O   PD_PHY     , PS_PHY      , PF_PHY      , 
     O   TMP_PHY    , Q_PHY       , 
     O   ZMEAN_PHY  , ZTEMP_PHY   , 
     O   PPLI_PHY   , PPCI_PHY    ,
     O   RVISB , RVISD , RNIRB , RNIRD , DLWB  ) 
!
      USE COM_STEP_SIB0109 , ONLY :
     1    ICN_SIB0109_SW
!
      USE CALENDAR , ONLY : 
     1     CALENDAR_RUN_GETKT ,
     1     CALENDAR_RUN_GETID ,
     1     CALENDAR_RUN_GETSBD

!
      IMPLICIT NONE
!
! INPUT
!
      INTEGER,INTENT(IN) :: ID_NOW    (5)         ! �{�X�e�b�v�̎���
      INTEGER,INTENT(IN) :: ID_PRE    (5)         ! �{�X�e�b�v�̎���
      REAL(8),INTENT(IN) :: RSEC 
      REAL(8),INTENT(IN) :: RDAY 
      REAL(8),INTENT(IN) :: DELT_ATM
!
      REAL(8),INTENT(IN) :: GLON (IDIM,JDIM)     ! �o�x�i�P�ʁA�x�j
      REAL(8),INTENT(IN) :: GLAT (IDIM,JDIM)     ! �ܓx�i�P�ʁA�x�j
      INTEGER,INTENT(IN) :: IMASK(IDIM,JDIM)     
!
! OUTPUT 
!
      REAL(8),INTENT(OUT)  :: U_PHY     (IDIM,JDIM)  ! U
      REAL(8),INTENT(OUT)  :: V_PHY     (IDIM,JDIM)  ! V 
      REAL(8),INTENT(OUT)  :: PD_PHY    (IDIM,JDIM)  ! (PS-PH)*2  
      REAL(8),INTENT(OUT)  :: PS_PHY    (IDIM,JDIM)  ! �n�[�t���x�� = Ps HPa
      REAL(8),INTENT(OUT)  :: PF_PHY    (IDIM,JDIM)  ! �t�����x�� HPa 
      REAL(8),INTENT(OUT)  :: TMP_PHY   (IDIM,JDIM)  ! ���x 
      REAL(8),INTENT(OUT)  :: Q_PHY     (IDIM,JDIM)  ! �䎼 kg/kg
      REAL(8),INTENT(INOUT):: ZMEAN_PHY (IDIM,JDIM)  ! �ꎞ��?���ϓV���p
      REAL(8),INTENT(OUT)  :: ZTEMP_PHY (IDIM,JDIM)  ! �e�X�e�b�v�V���p
      REAL(8),INTENT(OUT)  :: PPLI_PHY  (IDIM,JDIM)  ! ��K�͋Ì����~��
      REAL(8),INTENT(OUT)  :: PPCI_PHY  (IDIM,JDIM)  ! �ω_���~��
!
      REAL(8),INTENT(INOUT)::  RVISB ( IRAD*JRAD )   ! ���ˌv�Z�������B
      REAL(8),INTENT(INOUT)::  RVISD ( IRAD*JRAD )   ! ���ˌv�Z�����U��
      REAL(8),INTENT(INOUT)::  RNIRB ( IRAD*JRAD )   ! ���ˌv�Z���ߐԒ��B
      REAL(8),INTENT(INOUT)::  RNIRD ( IRAD*JRAD )   ! ���ˌv�Z���ߐԎU��
      REAL(8),INTENT(INOUT)::  DLWB  ( IRAD*JRAD )   ! ���ˌv�Z�����g
!      
! WORK
!
      INTEGER :: ID_PRE_00Z (5) 
      INTEGER :: ID_NEXT_00Z(5)  
      INTEGER :: ID_PRE_03Z (5) 
      INTEGER :: ID_NEXT_03Z(5)  
      INTEGER :: ID_PRE_CLD (5) 
      INTEGER :: ID_NEXT_CLD(5)  
      INTEGER :: ID_WORK    (5)  
      INTEGER :: KT_LAG
      INTEGER :: IDUMMY_1
      INTEGER :: IDUMMY_2
      INTEGER :: IDUMMY_3
      INTEGER :: IDUMMY_4
      REAL(8),SAVE :: CLD   (IDIM,JDIM)
!     REAL(8) :: CLD   (IDIM,JDIM)
      REAL(8) :: RSHRT (IDIM,JDIM)
!
#ifdef MONYOS
      INTEGER           :: JL
      INTEGER           :: IJ_POINT
      INTEGER           :: J_POINT
      CHARACTER( 7)     :: CMARK 
      REAL(8),PARAMETER :: ONE = 1.D0
#endif
!
      REAL(8) :: WGT_00Z_NEXT 
      REAL(8) :: WGT_LWDN_NEXT 
      REAL(8) :: WGT_MON_NEXT 
!
      REAL(8),SAVE   :: SEC_6HR_00Z 
      REAL(8),SAVE   :: SEC_6HR_LWDN
!
      REAL(8) :: SEC_6HR_TOT
      INTEGER :: NSTEPS_RAD
!
      LOGICAL :: L_6HR_00Z      ! �t���O�B(00+6xn)Z �� true
      LOGICAL :: L_6HR_03Z      ! �t���O�B(03+6xn)Z �� true
      LOGICAL :: L_MON          ! �t���O�B15���ɂȂ肽�Ă̂Ƃ��� true
!
      REAL(8),SAVE :: ZERO = 0.D0 
!
! ==============
! >> �`�F�b�N <<
! ==============
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'ISLSCP_MAIN ERROR : CALL ISLSCP_INI BEFORE'
        STOP 999
      ENDIF
!
! ====================
! >> �t���O�𗧂Ă� <<
! ====================
!
      L_6HR_00Z = .FALSE. 
      L_6HR_03Z = .FALSE. 
      L_MON     = .FALSE. 
!
!   0,6,12,18 ���ɂȂ���
!
      IF ( ID_NOW(4).NE.ID_PRE(4) .AND. MOD(ID_NOW(4),6).EQ.0 ) THEN
        L_6HR_00Z = .TRUE. 
      ENDIF
!
!   3,9,15,21 ���ɂȂ���
!
      IF ( ID_NOW(4).NE.ID_PRE(4) .AND. MOD(ID_NOW(4),6).EQ.3 ) THEN
        L_6HR_03Z = .TRUE. 
      ENDIF
!
!   15 ���� 0 ���ɂȂ���
!
      IF ( ID_NOW(4).NE.ID_PRE(4) .AND. 
     1     ID_NOW(3).EQ.15 .AND. ID_NOW(4).EQ.0 ) THEN
        L_MON = .TRUE. 
      ENDIF
!
! =================
! >> (00 + 6xn)Z <<
! =================
!
      IF ( L_6HR_00Z ) THEN 
!
!  SAVE �f�[�^�̍X�V
!
        U_PRE    (:,:) = U_NEXT    (:,:)
        PS_PRE   (:,:) = PS_NEXT   (:,:)
        TMP_PRE  (:,:) = TMP_NEXT  (:,:)
        Q_PRE    (:,:) = Q_NEXT    (:,:)
!
        CALL ISLSCP_GETID_XX  ( ID_NOW , 0 , ID_PRE_00Z , ID_NEXT_00Z ) 
!
        CALL ISLSCP_RDFL (IFILE_MWND,'MWND',ID_NEXT_00Z,IMASK,U_NEXT   )
        CALL ISLSCP_RDFL (IFILE_PRSS,'PRSS',ID_NEXT_00Z,IMASK,PS_NEXT  )
        CALL ISLSCP_RDFL (IFILE_TEMP,'TEMP',ID_NEXT_00Z,IMASK,TMP_NEXT )
        CALL ISLSCP_RDFL (IFILE_QREF,'QREF',ID_NEXT_00Z,IMASK,Q_NEXT   )
        CALL ISLSCP_RDFL (IFILE_TPRC,'TPRC',ID_PRE_00Z ,IMASK,PTOT_SUM )     
        CALL ISLSCP_RDFL (IFILE_CPRC,'CPRC',ID_PRE_00Z ,IMASK,PCNV_SUM )     
        CALL ISLSCP_RDFL (IFILE_SWDN,'SWDN',ID_PRE_00Z ,IMASK,RSWD_SUM )     
!
      ENDIF
!
! =================
! >> (03 + 6xn)Z <<
! =================
!   ���ӁB
!    -1) �� 03Z �ł���Ƃ���B
!     0) ���g�ł́A06Z �ƃ��x���̒����Ă���f�[�^�� 00Z-06Z �̕��ςł���B
!        03Z �` 09Z �̊Ԃ� 06Z �� 12Z �̃��x��������f�[�^����}����B
!        ���Ȃ킿�A03Z �ł� 12Z �ƃ��x���������Ă���f�[�^��ǂݍ���
!        ����� RLWD_NEXT �Ƃ���B
!     1) �Ƃ������ƂŁA�܂� �A
!        06Z �ƃ��x���̒����Ă���f�[�^�� RLWD_PRE �ɂ���
!     2) ISLSCP_GETID_XX �� ID_NOW �̋ߕӂ� 03Z,09Z,15Z,21Z �̓������擾�B
!        ID_NOW �� 03Z �ł���̂ŁAID_NEXT_03Z �� 09Z �ɂȂ�B
!     3) ISLSCP_RDFL �� 'LWDN' �ɂ��Ă� +3 ���Ԃ��āA12Z �ɂȂ�B   
!
      IF ( L_6HR_03Z ) THEN
        RLWD_PRE    (:,:) = RLWD_NEXT    (:,:)
        CALL ISLSCP_GETID_XX  ( ID_NOW , 3 , ID_PRE_03Z , ID_NEXT_03Z ) 
        CALL ISLSCP_RDFL (IFILE_LWDN,'LWDN',ID_NEXT_03Z,IMASK,RLWD_NEXT)
      ENDIF
!
! ============
! >> 15,00Z <<
! ============
!
      IF ( L_MON ) THEN
        CLD_PRE    (:,:) = CLD_NEXT    (:,:)
!
        CALL ISLSCP_GETID_CLD ( ID_NOW , ID_PRE_CLD , ID_NEXT_CLD ) 
        CALL ISLSCP_RDFL(IFILE_CLD ,'CLD ',ID_NEXT_CLD, IMASK,CLD_NEXT )       
      ENDIF
!
! ====================
! >> �o�ߎ��Ԃ̐��` <<
! ====================
!   �W���u��ڑ����Ă����ʂ��ς��Ȃ��悤�ɂ���B
!   hour ���J��オ������ 3600 �̔{���ɂ���B
!
! �ώZ
      SEC_6HR_00Z = SEC_6HR_00Z + DELT_ATM 
! �l�𐮂���
      IF ( ID_NOW(4).NE.ID_PRE(4) ) THEN        
        SEC_6HR_00Z = MOD ( ID_NOW(4)   , 6 ) * 3600.D0 + DELT_ATM / 2 
      ENDIF
!
!  ���g���˗p���� 
!
      SEC_6HR_LWDN = MOD ( ID_NOW(4)+3 , 6 ) * 3600.D0 + 1800.D0 
!
! ==========
! >> ���} <<
! ==========
!
!  ------------------
!  > ���}�d�݂̌v�Z <
!  ------------------
!
      SEC_6HR_TOT = 6 * 3600.D0 
      WGT_00Z_NEXT  = SEC_6HR_00Z  / SEC_6HR_TOT 
      WGT_LWDN_NEXT = SEC_6HR_LWDN / SEC_6HR_TOT 
!
!  �`�F�b�N
!
#ifdef DEBUG
      IF ( WGT_00Z_NEXT.LE.0.D0  .OR. WGT_00Z_NEXT.GE.1.D0 ) THEN
        WRITE(6,*) 'ISLSCP_MAIN ERROR WGT_00Z_NEXT = ' , WGT_00Z_NEXT
        STOP 999
      ENDIF
      IF ( WGT_LWDN_NEXT.LE.0.D0 .OR. WGT_LWDN_NEXT.GE.1.D0 ) THEN
        WRITE(6,*) 'ISLSCP_MAIN ERROR WGT_LWDN_NEXT = ' , WGT_LWDN_NEXT
        STOP 999
      ENDIF
#endif
!
!  ==================
!  >> �f�[�^�̉��H <<
!  ==================
!
!  ------------
!  > ���ԓ��} <
!  ------------
!
!   �P���� 00Z �n�����ʂ݂̂̐��`���} 
!     ���˂���݁i�Z�g�A���g�A�_�ʁj�͈ꎞ�ԂɈ�x�̂ݍs�Ȃ�
!
      CALL ISLSCP_INTERP ( U_PRE   , U_NEXT   , WGT_00Z_NEXT , U_PHY   )
      CALL ISLSCP_INTERP ( PS_PRE  , PS_NEXT  , WGT_00Z_NEXT , PS_PHY  )
      CALL ISLSCP_INTERP ( TMP_PRE , TMP_NEXT , WGT_00Z_NEXT , TMP_PHY )
      CALL ISLSCP_INTERP ( Q_PRE   , Q_NEXT   , WGT_00Z_NEXT , Q_PHY   )
!
! ======================
! >> �Z�g�f�[�^�̍쐬 <<                              99/11/17 �쐬��������
! ======================
!
!  ----------------------
!  > 6 ���ԂɈ�x�̏��� <
!  ----------------------
!
      IF ( L_6HR_00Z ) THEN
!
        CALL ISLSCP_SWDN_6HR (
     I      RDAY      , RSEC     , DELT_ATM , 
     I      GLON      , GLAT     , IMASK    , 
     M      RSWD_SUM  , 
     O      SR_FLUX_WORK         )
!
      ENDIF
!
!  --------------------------
!  > ���ˌv�Z�X�e�b�v�̏��� <
!  --------------------------
!     ���̒Z�g���ˌv�Z�܂ł̕��ς̓V���p�E�Z�g���� 4 �������v�Z����B
!
#     ifdef DEBUG
      write(6,*) 'islscp before islscp_swdn_1hr' , ICN_SIB0109_SW
#     endif
!
      IF ( ICN_SIB0109_SW .EQ. 1 ) THEN
!
        CALL ISLSCP_SWDN_1HR (
     I    RDAY , RSEC , DELT_ATM  , 
     I    SR_FLUX_WORK,
     I    GLON , GLAT , 
     O    NSTEPS_RAD  , 
     O    RSHRT       ,  ZMEAN_PHY   )
!
        KT_LAG = 0
        CALL CALENDAR_RUN_GETID ( ID_NOW , ID_WORK , KT_LAG ) 
        CALL CALENDAR_RUN_GETSBD  (
     I    ID_WORK  , 
     O    IDUMMY_1 , IDUMMY_2 , IDUMMY_3 , IDUMMY_4 , WGT_MON_NEXT ) 
!   
        CALL ISLSCP_INTERP( CLD_PRE , CLD_NEXT , WGT_MON_NEXT , CLD  )
!
!   �_�� CLD      : 0-100 �� 0-1 �ɂ��� 
        CLD (:,:) = CLD(:,:) / 100.D0  
!
        CALL ISLSCP_SWDN_1HR_DEVIDE (
     O     RVISB , RVISD , RNIRB , RNIRD , 
     I     RSHRT , CLD   , ZMEAN_PHY   )
!
        CALL ISLSCP_INTERP( RLWD_PRE, RLWD_NEXT, WGT_LWDN_NEXT , DLWB  )
!
      ENDIF
!
!  --------------------
!  > ���X�e�b�v�̏��� <
!  --------------------
!    ���X�e�b�v�̓V���p�̌v�Z
!
      CALL ISLSCP_SUNANG ( 
     I    RDAY     , RSEC    , 
     I    GLON     , GLAT    , 
     O    ZTEMP_PHY    )
!
!  ==================
!  >> ���̑��̉��H <<
!  ==================
!
!   ZTEMP �␳ �i���̒l�������j
      ZTEMP_PHY(:,:) = MAX ( ZTEMP_PHY(:,:) , ZERO ) 
!
!   ��k����      : �[���ɂ���
      V_PHY(:,:) = 0.D0
!
!   �n�\�ʋC�� PS : �P�ʂ� HPa �ɂ��� 
      PS_PHY(:,:) = PS_PHY(:,:) / 100.D0  
!
!   �~���� �i�P�ʂ� mm/6h ���� mm/step �ɂ���j
!
      PPCI_PHY(:,:) =  PCNV_SUM(:,:)           
     1                    / (3600*6) * DELT_ATM 
      PPLI_PHY(:,:) = ( PTOT_SUM(:,:) - PCNV_SUM(:,:) )  
     1                    / (3600*6) * DELT_ATM   
!
!   --------
!   > �ݒ� <
!   --------
!     ��C�ŉ��w�w�� �� 10HPa �� 
!
      PD_PHY(:,:) = 10.D0
      PF_PHY(:,:) = PS_PHY(:,:) - 5.D0 
!
! ================
! >> �ڍ׃��j�^ <<   
! ================
!
#ifdef MONYOS
!     IF ( JCN_SIB_MONIT_DETAIL .EQ. 1 ) THEN
      IF ( IMONIT_LEVEL .GE. IMONIT_SELECT ) THEN
        DO JL=1,JLPHY
          IJ_POINT = (JL-1)*IJPHY + 1              ! �|�C���^�B
          J_POINT  = (JL-1)*JPHY2 + 1 
!
          IF ( ICN_SIB0109_SW .EQ. 1 ) THEN
!
! �S�Z�g
            CMARK = 'FSR' 
            CALL MONIT_ADD_2 ( CMARK , RSHRT (1,J_POINT) , 
     1                         JL, DELT_ATM*NSTEPS_RAD , ONE )     
!
! ���g
            CMARK = 'FLR' 
            CALL MONIT_ADD_2 ( CMARK , DLWB  (IJ_POINT) , 
     1                         JL, DELT_ATM*NSTEPS_RAD , ONE )
!
          ENDIF
!
! �_��
          
	  CMARK = 'FCLD'
	  CALL MONIT_ADD_2(CMARK, CLD(1,J_POINT), JL, DELT_ATM, ONE)
!
! ���x
          CMARK = 'FTMP' 
          CALL MONIT_ADD_2 ( CMARK , TMP_PHY(1,J_POINT) , 
     1                       JL , DELT_ATM , ONE )
!
! �䎼
          CMARK = 'FQ' 
          CALL MONIT_ADD_2 ( CMARK , Q_PHY(1,J_POINT) , 
     1                       JL , DELT_ATM , ONE )
!
! �n�\�ʋC��
          CMARK = 'FPS' 
          CALL MONIT_ADD_2 ( CMARK , PS_PHY(1,J_POINT) , 
     1                       JL , DELT_ATM , ONE )
!
! �ω_���~��
          CMARK = 'FPC' 
          CALL MONIT_ADD_2 ( CMARK , PPCI_PHY(1,J_POINT) , 
     1                       JL , ONE , ONE )
!
! ��K�͋Ì����~��
          CMARK = 'FPL' 
          CALL MONIT_ADD_2 ( CMARK , PPLI_PHY(1,J_POINT) , 
     1                       JL , ONE , ONE )
!
! ����
          CMARK = 'FU' 
          CALL MONIT_ADD_2 ( CMARK , U_PHY(1,J_POINT) , 
     1                       JL , DELT_ATM , ONE )

        ENDDO
      ENDIF
#endif
!
! ==============
! >> �������� <<
! ==============
!
      IF ( LFIRST ) THEN
        LFIRST = .FALSE. 
      ENDIF
!
      RETURN
      END SUBROUTINE ISLSCP_MAIN
!
!======================================================
      SUBROUTINE MONIT_REGIST_ISLSCP_MAIN
!
! ISLSCP_MAIN �ŏo�͂���ϐ����X�g
!
      use sib_monit, only : imonit_level , imonit_select 
!
      IMPLICIT NONE
!
      CHARACTER( 7)  :: CMARK 
      CHARACTER(32)  :: CTITLE 
      CHARACTER(13)  :: CUNIT
!
      LOGICAL,SAVE ::  LFIRST 
      DATA LFIRST /.TRUE./
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'MONIT_REGIST_ISLSCP_MAIN 99/11 POCHAKA'
        LFIRST = .FALSE. 
      ENDIF
!
      IF ( IMONIT_LEVEL .GE. IMONIT_SELECT ) THEN
      CMARK  = 'FSR'
      CTITLE = 'SHORT RADIATION (ATMOSPHERIC FORCING)'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'FLR'
      CTITLE = 'LONG RADIATION (ATMOSPHERIC FORCING)'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'FTMP'
      CTITLE = 'TEMPERATURE (ATMOSPHERIC FORCING)'
      CUNIT  = 'K'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'FQ'
      CTITLE = 'HUMIDITY (ATMOSPHERIC FORCING)'
      CUNIT  = ''
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'FPS'
      CTITLE = 'SURFACE PRESSURE (ATMOSPHERIC FORCING)'
      CUNIT  = 'HPa'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'FPC'
      CTITLE = 'CONVECTIVE PRECIPITATION (ATMOSPHERIC FORCING)'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'FPL'
      CTITLE = 'LARGE SCALE PRECIPITATION (ATMOSPHERIC FORCING)'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'FCLD'
      CTITLE = 'CLOUD AMOUNT (ATMOSPHERIC FORCING)'
      CUNIT  = ''
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'FU'
      CTITLE = 'WIND VELOCITY (ATMOSPHERIC FORCING)'
      CUNIT  = 'M/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      ENDIF
!
      end  subroutine monit_regist_islscp_main
!
      END MODULE ISLSCP
