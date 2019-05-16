! �Ⴊ����ꍇ�̑�C���̗A�������̕ύX�i�L���m�s�[��ԁj
! 99/06/0x ���
! 99/07/13 �ۍ␪�G  �����ύX�B 
! 99/07/27 �ۍ␪�G  XLAI �ǉ�
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
!
      SUBROUTINE CANOPY_MOD_AIR_SNW (
     I  NSTR             , NEND        , 
     I  DEP_SNOW         , NTYP         , MON         , 
     I  FAC_AG_INV_ms    , FAC_AC_BAR_INV_ms         , 
     I  XLAI_VEG_ms      , 
     I  D_ZERO_ms        , Z0_ms            , 
     I  CVR_VEG_ms       , CVR_VEG_INV_ms , 
     I  WTR_SNOW         , GLA_SNOW       , 
     O  Z0_msx           , 
     O  FAC_AG_INV_msx   , FAC_AC_BAR_INV_msx ,
     O  CVR_VEG_msx      , CVR_VEG_INV_msx    , 
     O  XLAI_VEG_msx     , D_ZERO_msx         , 
     O  HUM_SNSK         , FR_WBH_SNW         
     1    ) 
!
! ����Ă��邱��
!   ��̐[���́A�L���m�s�[�̍����ɑ΂���䂪�傫���ق�
!     �L���m�s�[��Ԃ́A�Ⴊ�����Ƃ��ɑ΂��銄�� FAC �͏������Ȃ�A
!     ZERO_CS ����̐[�� DEP_SNOW �ɋ߂��A
!     �e�x�����������A
!     �ϐ�\�ʂƃL���m�s�[��ԊԂ̒�R���������i�������Z���Ȃ�̂Łj�A
!     �L���m�s�[�ƃL���m�s�[��ԊԂ̒�R�萔���傫��
!           �i���Ƃ�ł���t�����Ȃ��Ȃ�̂ŁB
!             �����ŗt�̕��z�͈�l�Ɖ��肵���B�j
!   �Ȃ�B
!
!   ������... 
!     �E�Ⴊ�����L���m�s�[���� Z2 �� 0.95 �{���z����Ƃ��́A�֋X��A��
!       �̍����� Z2*0.95 �����Ȃ��Ƃ���B 
!       ����� Sellers ��(1986) �̂Ƃ��Ă�����@�ł���B
!       �L���m�s�[���������ƁA�����ꂽ�ӏ��̈������O��������K�v������B
!       ������������Ȃ�����ł��낤�B
!
!     �E�t�@�N�^�̕]�����@�͊�{�I�ɂ��������ł���B
!       �Ⴊ���邱�Ƃɂ����ʂ�K���ɁA�������ꍇ�iFAC=1�j�ƘA���I�ɂ�
!       ��悤�ɂ���Ă���B
!
!  �v�`�F�b�N
!    DEP_SNOW ���������ƕϐ� SDEP ���Ƃ��Ă����Ȃ��Ă悢��?  
!
      USE SIBPRM , ONLY : 
     1  IDX   , 
     1  ISN   , 
     1  ICG
!
      USE SIBVEG , ONLY : 
     1           Z2_mo              ,     ! �L���m�s�[��[���� (ITYP,IMON)
     1           Z1_mo                    ! �L���m�s�[���[���� (ITYP,IMON)
!
      USE SIBCON , ONLY :
     1            CVR_VEG_INV_MAX_c    
!
!     use com_debug , only : ipoint_new 
     
!
      IMPLICIT NONE
!
! INPUT 
!
      INTEGER,INTENT(IN)   :: NSTR 
      INTEGER,INTENT(IN)   :: NEND
      INTEGER,INTENT(IN)   :: MON
      INTEGER,INTENT(IN)   :: NTYP   (IDX)         ! �A���^�C�v
!
      REAL(8),INTENT(IN)   :: DEP_SNOW(IDX,ISN+1)! �ϐ�[( m ) 
!
      REAL(8),INTENT(IN)   :: FAC_AG_INV_ms (IDX)! ��ʂƃL���ԋ�͒�R����
!                                                ! �Ɋւ���萔 �� RDC 
      REAL(8),INTENT(IN)   :: FAC_AC_BAR_INV_ms (IDX) 
!                                                ! �ϐ��̃L���ƃL����ԊԂ�
!                                                ! ��R�Ɋ֌W����萔 �� RBC
!
      REAL(8),INTENT(IN)   :: XLAI_VEG_ms    (IDX,ICG)
!
      REAL(8),INTENT(IN)   :: CVR_VEG_ms     (IDX,ICG)
      REAL(8),INTENT(IN)   :: CVR_VEG_INV_ms (IDX,ICG)
!
      REAL(8),INTENT(IN)   :: WTR_SNOW       (IDX)
      REAL(8),INTENT(IN)   :: GLA_SNOW       (IDX)
!
! OUTPUT
!
      REAL(8),INTENT(OUT)  :: FAC_AG_INV_msx (IDX)! ��ʂƃL���ԋ�͒�R����
!                                                ! �Ɋւ���萔 �� RDC 
      REAL(8),INTENT(OUT)  :: FAC_AC_BAR_INV_msx (IDX) 
!                                                ! �ϐ��̃L���ƃL����ԊԂ�
!                                                ! ��R�Ɋ֌W����萔 �� RBC
!
      REAL(8),INTENT(OUT)  :: XLAI_VEG_msx (IDX,ICG)
      REAL(8),INTENT(OUT)  :: HUM_SNSK     (IDX)
      REAL(8),INTENT(OUT)  :: FR_WBH_SNW   (IDX)
!
      REAL(8),INTENT(OUT)  :: CVR_VEG_msx    (IDX,ICG)
      REAL(8),INTENT(OUT)  :: CVR_VEG_INV_msx(IDX,ICG)
!

!
! INOUT
!
      REAL(8),INTENT(IN)   :: D_ZERO_ms  (IDX)    ! ��ʏ�̗�ʕψ� (m)
      REAL(8),INTENT(INOUT):: D_ZERO_msx (IDX)    ! ��ʏ�̗�ʕψ� (m)
      REAL(8),INTENT(IN)   :: Z0_ms      (IDX)    ! ��ʏ�̑e�x��   (m)
      REAL(8),INTENT(OUT)  :: Z0_msx     (IDX)    ! ��ʏ�̑e�x��   (m)
!
! WORK 
!
      INTEGER   :: I
      REAL(8)   :: XZ
      REAL(8)   :: SDEP
      REAL(8)   :: FAC
      REAL(8),PARAMETER :: ZERO = 0.D0  
      REAL(8)   :: H2O_SNOW
! 
      REAL(8),PARAMETER :: H2O_MIN = 1.D-10 
!
      LOGICAl,SAVE :: LFIRST 
!
      DATA LFIRST /.TRUE. /
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'CANOPY_MOD_AIR_SNOW 99/07 POCHAKA'
        LFIRST = .FALSE. 
      ENDIF
!
      DO 100 I = NSTR, NEND
#ifdef CORRECT
        XZ     = Z2_mo ( NTYP(I) , MON ) - Z1_mo ( NTYP(I) , MON ) 
        SDEP   = MIN ( DEP_SNOW(I,5)- Z1_mo ( NTYP(I) , MON )
     1                 , XZ * 0.95D0 )  
#else
        XZ     = Z2_mo  ( NTYP(I) , MON )
        SDEP   = MIN ( DEP_SNOW(I,5)  , XZ * 0.95D0 )  
#endif
        SDEP   = MAX ( SDEP , ZERO )  
        FAC    = 1.0D0 - SDEP / XZ                ! �Ⴀ�� 0.05 - �ᖳ�� 1
!
        D_ZERO_msx (I)        = SDEP   + FAC * D_ZERO_ms(I)
        Z0_msx     (I)        = Z0_ms (I)  * FAC
!
!#ifdef CORRECT
        FAC_AG_INV_msx (I)    = FAC_AG_INV_ms (I)    / FAC
        FAC_AC_BAR_INV_msx(I) = FAC_AC_BAR_INV_ms(I) * FAC 
!#else
!        FAC_AG_INV_msx (I)    = FAC_AG_INV_ms (I)    * FAC
!        FAC_AC_BAR_INV_msx(I) = FAC_AC_BAR_INV_ms(I) / FAC 
!#endif
!
!  -----------------------------------------------
!
        XZ     = Z2_mo ( NTYP(I) , MON ) - Z1_mo ( NTYP(I) , MON ) 
        SDEP   = MIN ( DEP_SNOW(I,5)- Z1_mo ( NTYP(I) , MON )
     1                 , XZ * 0.95D0 )  
        SDEP   = MAX ( SDEP , ZERO )  
        FAC    = 1.D0 - SDEP /  XZ 
!
!
        XLAI_VEG_msx (I,1)    = XLAI_VEG_ms (I,1) * FAC
        XLAI_VEG_msx (I,2)    = 0. 
!
!  -----------------------------------------------
!
        HUM_SNSK      (I)     = 1.  
!
        CVR_VEG_msx (I,1)      = CVR_VEG_ms (I,1)
        CVR_VEG_msx (I,2)      = 0. 
        CVR_VEG_INV_msx (I,1)  = CVR_VEG_INV_ms (I,1)
        CVR_VEG_INV_msx (I,2)  = CVR_VEG_INV_MAX_c   
!
        H2O_SNOW      = MAX ( WTR_SNOW(I)+GLA_SNOW(I) , H2O_MIN )
        FR_WBH_SNW(I) = WTR_SNOW(I) / H2O_SNOW  
  100 CONTINUE
!
      RETURN
!
      END
