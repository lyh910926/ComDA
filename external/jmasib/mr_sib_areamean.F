      SUBROUTINE MR_SIB_AREAMEAN
!
      USE SIBPRM , ONLY : IDP
!
      USE SIB_MONIT , ONLY : 
     1     IMONIT_LEVEL        , 
     1     IMONIT_MEAN_MRI     ,
     1     IMONIT_FLUX_MRI     ,
     1     IMONIT_SNAP_NPD     ,
     1     IMONIT_FLUX_COMMON
!
      IMPLICIT NONE
!
      CHARACTER( 7)  :: CMARK 
      CHARACTER(32)  :: CTITLE 
      CHARACTER(13)  :: CUNIT
      INTEGER        :: K
!
! �Ⴀ�薳�����ϓ��̓��ʏo�͒l�̂����ŁA���E�C���ʂ̃��j�^�͂����œo�^
!
! ===============================
! >> ���� : �i�q���σt���b�N�X <<
! ===============================
!

      IF ( IMONIT_LEVEL .GE. IMONIT_FLUX_COMMON ) THEN
!
!  ���M  -(HSNNF+HSNCF+HSNGF+HSNWF)
        CMARK  = 'FLSH'
        CTITLE = 'Sensible heat flux'
        CUNIT  = 'W/m**2'
        CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
!  ���M  
!    �L���m�s�[�̗t�̏���/���؁E���I/�����A
!    �����̗t��      ����/���؁E���I/�����A
!    ���n�E��\�ʂ�  ����/���؁E���I/�����A
!    �L���m�s�[�̗t�̏��U
!    �����̗t��      ���U
!       - ( WEVNF+WEVSF+WEVGF+WEVBNLD+WEVBNLU+WEVBSWD+WEVBSWU ) * 2507000
!       - ( GSLNF+GSLSF+GSLGF+GSLBNLD+GSLBNLU+GSLBSWD+GSLBSWU ) * 2834500
!       - ( WTRBNLF+WTRBSLF+WTRBGLF) * 2507000 
!
!    ���L 3 �v�f ( ���؁E�Ւf�����E���U ) �������Ə����ł���B
!       - (                   WEVBNLD+WEVBNLU+WEVBSWD+WEVBSWU ) * 2507000
!
        CMARK  = 'FLLH'
        CTITLE = 'Latent heat flux'
        CUNIT  = 'W/m**2'
        CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
!   �����U���t���b�N�X
        CMARK  = 'EVSPS'        !  �o�^�͊C�Ƌ���
        CTITLE = 'Evapo-transpiration and Sublimation'
        CUNIT  = 'kg/m**2/s'
        CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
!  �^���ʃt���b�N�X ( canopy_get_gmuv )
!     CMARK='UMOM' = MFLUG + MFLUW    �o�^�͊C�Ƌ���
!     CMARK='VMOM' = MFLVG + MFLVW    �o�^�͊C�Ƌ���
!
        CMARK  = 'UMOM'
        CTITLE = 'Momentum flux (U)'
        CUNIT  = 'N/m**2/s'
        CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
        CMARK  = 'VMOM'
        CTITLE = 'Momentum flux (U)'
        CUNIT  = 'N/m**2/s'
        CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      ENDIF
!
! ==========================
! >> MRI : �i�q���ϕ����� <<
! ==========================
!
      IF ( IMONIT_LEVEL .GE. IMONIT_MEAN_MRI ) THEN
!
!   �e�x�� ( �I�t���C���̂� ... �C�m��ł��o������ )
        CMARK  = 'Z0'
        CTITLE = 'Roughness Length'
        CUNIT  = 'm'
        CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
!   ��������  ( �Ƃ肠�����g���� ) 
        CMARK  = 'BETA'
        CTITLE = 'Evaporation Efficiency'
        CUNIT  = '0-1'
        CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      ENDIF
!
      IF ( IMONIT_LEVEL .GE. IMONIT_FLUX_MRI ) THEN
!
!   �|�e���V����������  ( �Ƃ肠�����g���� ) 
        CMARK  = 'EPOT'
        CTITLE = 'Potential Evaporation'
        CUNIT  = 'W/m**2'
        CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      ENDIF
!
! �{���E�X�i�b�v�V���b�g
!      
      IF ( IMONIT_LEVEL .GE. IMONIT_SNAP_NPD ) THEN 
!
!   �e�x�� ( �I�t���C���̂� ... �C�m��ł��o������ )
!
        CMARK  = 'Z0'
        CTITLE = 'Roughness Length'
        CUNIT  = 'm'
        CALL monit_regist_sib_snap ( CMARK , CTITLE , CUNIT )
!
      ENDIF
!
! �L�����ˉ��x
!
!!      IF ( IMONIT_LEVEL .GE. IMONIT_MEAN_MRI ) THEN
!!        CMARK  = 'TGEF'
!!        CTITLE = 'TEMPERATURE LONG RAD FROM SIB TOP'
!!        CUNIT  = 'K'
!!        CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!!      ENDIF
!
      RETURN
      END