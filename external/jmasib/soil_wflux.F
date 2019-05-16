! �y�뒆�̐��t���b�N�X�̕]��
! 99/07/06 �ۍ␪�G 
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
! 99/09/22 �ۍ␪�G XFR_WTR �̉��������B
!                   �������� XFR_WTR(I,1)**(-BEE_co(J))�ł܂����̂ŁB
! 99/09/23 �ۍ␪�G dep_h_inv(i,3) �̎���ς���
! 99/09/24 �ۍ␪�G �������̑Ίp�����ɖ�肠��BFACT_WGT_h2o ����
! 99/09/24 �ۍ␪�G �g�U�W���̗^������ύX�B�iJCN_COEF_WFLUX_SOIL=0 �̎��B�j
!
      SUBROUTINE SOIL_WFLUX (
     I   NSTR             , NEND             , 
     I   INSFLAG          , 
     I   FR_WTR_SOIL      , 
     I   FR_GLA_SOIL      , 
     I   FACT_WGT_H2O      , 
     I   DELT_SOIL        , 
     I   NTYP             , 
     I   TMP_SOIL         , 
     O   WFLUX_H          , WTR_INC ) 
! /*
! �C���[�W
!   TMP_FREZ �����ቷ�Ȃ�� �y + ��C + �X
!                             �����������Z�����Ă��邱�Ƃ͂���
!   TMP_FREZ �Ȃ��           �y + ��C + ��
!   TMP_FREZ ���������Ȃ�� �y + ��C + �X + ��
!
! ���_�B
!   �E�|�e���V�����̉��������A�����W���̉��������A...  XK, POT_SOIL
!     �܂��������ɂ͏d�̓|�e���V�������ł̃t���b�N�X���Ȃ��������B
!     1 ��ϐ������āA0 or 1 �ɂ���?
!
! �v�`�F�b�N
!  �E��[��������ė��鐅�́A�~�� - ���n�����ł���̂ŁA�K���������ł͂Ȃ��B
!    ����ɑ΂���΍�͂��Ă��Ă���̂��H
!    �Ƃ��ɁA���L���鐅���������̉t���̏�����v�����ꂽ�ꍇ�̑[�u�́H
!
! ���ӁB�g�U�W���̗^�����ɂ��āB99/09/24
!
! ���� 1 : �������Ɖ� �` �z�I�ɉ����ꍇ
!
!   �󌄒��𐅂���߂銄�� FR_WTR = w �Ƃ���B
!   ���̎��ʂ� FACT_WGT_H2O * w �ł���B������ FACT_WGT_H2O=RHO_WTR_C*POR 
!
!   �������́A
!      ���̎��ʂ̎��ԕω��� = ���ʃt���b�N�X����
!   �̌`�ł���B�܂�
!      d (FACT_WGT_H2O*w)/dt = �ォ��̐��t���b�N�X - ���ւ̐��t���b�N�X
!   �ł���B
!   �z�ɕ]������鐅�t���b�N�X WFLUX_H_exp �́A
!      WFLUX_H_exp = XK_H * ( POT_SOIL - POT_SOIL ) / DEP_H * RHO_WTR_c -- *E
!   �Ƃ����`�ł���B
!
!   �����ׂ���������
!      d (FACT_WGT_H2O*w)/dt =   WFLUX_H_exp_�� - WFLUX_H_exp_��
!   �ł���B���̃T�u���[�`���ł� *E �ŕ\�����e�t���b�N�X���v�Z���āA
!   ��ʂ̃T�u���[�`���ɕԂ��B
!
! ���� 2 : �������Ɖ� �` �A�I�ɉ����ꍇ
!
!   �A�I�ɉ����ꍇ�́A�t���b�N�X�Ƃ��ĕ␳�� WFLUX_H_cor �������B
!
!   ���t���b�N�X�̕␳�ʂ́APOT_SOIL �� w �̊֌W
!      POT_SOIL = POT_SAT_SOIL * w'**(-B)  
!      w'       = w/(1-�󌄒��̕X�̊���)
!   ���Ȃ킿
!      POT_SOIL = POT_SAT_SOIL  * (1-�X�̊���)**B * w**(-B) 
!   �𔽉f���āA�ȉ��̂悤�ɂȂ�B������ ��w = dw/dt * DELT 
!   WFLUX_H_cor_��
!   = XK_H / DEP_H * POT_SAT_SOIL * (1-�X�̊���)**B * (-B) * w**(-B-1)  
!          * (��w_��̑w - ��w_���Y�w)  * RHO_WTR_C 
!   = XK_H / DEP_H * POT_SAT_SOIL                   * (-B) * w'**(-B)/w 
!          * (��w_��̑w - ��w_���Y�w)  * RHO_WTR_C 
!   = XK_H / DEP_H * POT_SOIL                       * (-B)           /w * d
!          * (��w_��̑w - ��w_���Y�w)  * RHO_WTR_C 
!   = XK_H / DEP_H * POT_SOIL * (-B)/w * (��w_��̑w - ��w_���Y�w) * RHO_WTR_C 
!   �ɂȂ�B
!
!   ��������
!      d (FACT_WGT_H2O*w)/dt =   WFLUX_H_exp_�� - WFLUX_H_exp_��
!                              + WFLUX_H_cor_�� - WFLUX_H_cor_�� 
!   ���Ȃ킿
!      FACT_WGT_H2O * dw/dt  
!          = (   WFLUX_H_exp_�� - WFLUX_H_exp_��
!              + WFLUX_H_cor_�� - WFLUX_H_cor_�� ) 
!   �ł���B
!
!   �����ł͊ȒP�̂��߂ɓ��Y�w�̕␳���݂̂��L�����Ƃɂ��悤�B
!       WFLUX_H_cor_�� 
!         = - XK_H / DEP_H * POT_SOIL * (-B) /w * dw/dt * DELT * RHO_WTR_C  
!   ������
!       XC_H  = XK_H / DEP_H 
!       XC    = POT_SOIL / (-B) / w * DELT * RHO_WTR_C 
!       DF_xx = XC_H * XC        
!   �Ə����ƁA
!       WFLUX_H_cor_�� = - XC_H * XC * dw/dt 
!                      = - DF_xx     * dw/dt 
!   �ł���B
!
!   ��������
!      ( FACT_WGT_H2O + DF_xx ) dw/dt = �z�I�t���b�N�X����
!   �ł���A�A�I�␳���͂��̉� AA ��p����
!       WFLUX_H_cor_�� = - DF_xx     * AA 
!   �̂悤�ɏ������Ƃ��ł���B
!
! ���� 2 �` �� 3 �w�Ƃ��̉��̂��Ƃ�
!   3 �w�ڂƂ��̉��Ƃ̃t���b�N�X�ɂ��Ă̊�{�I�ȍl�����́A
!     �E���ɂ͔�����B�����I�t
!       3 �w�ڂ̊g�U�W���i�O�}�����Ƃ������Ɓj�A
!       2 �w�ځE3 �w�ڊԂ̃|�e���V�������i�O�}�����Ƃ������Ɓj�A
!       �n�ʂ̌X�����ʂ̐ρB
!     �E��ɗ��邩�ǂ����͍l��������B�f�t�H���g�ł͖����B
!       ����ꍇ�̓����I�t�Ɠ����]�����@�B
!
! */       
!
!
      USE SIBPRM , ONLY : 
     1   IDX   ,
     1   ITYP  , 
     1   IDP  
!
      USE SIBCON , ONLY :
     1   DELT_FAC_SOIL_c  , 
!    1   JCN_COEF_WFLUX_SOIL_c  ,
     1   TMP_FREZ_c        ,
     1   RHO_WTR_C        
     1   , JCN_RUNOFF_GRAV_c            ! default=1 2004/08/10 Hosaka 
     1   , COEF_SOIL_WFLUX_MIN_c        ! default=0 
     1   , POT_SOIL_MIN_c              
!
      USE SIBVEG , ONLY : 
     1           SINX_co                 , ! �y��w�̌X��  (ITYP)
     1           POR_SOIL_co            ,  ! �󌄗�   (ITYP)  
     1           BEE_co                 ,  ! �y�됅���ˑ����W�� (ITYP)
     1           DEP_SOIL_co             , ! �y��w�̐[��    (ITYP,IDP)
     1           POT_SAT_SOIL_co        ,  ! �O�a���̓y��|�e���V���� (ITYP)
     1           WCOEF_SAT_SOIL_co         ! �O�a�����W��    (ITYP)
!
      USE COM_RUNCONF_SIB0109 , ONLY :
     1   JCN_RRUNOFF_B        ,
     1   JCN_SOIL_WATER_EXPLICIT       ! implicit -> 0 , explicit -> 1 
!
#ifdef MONYOS
      USE SIB_MONIT, ONLY : MONIT_SIB, ICN,ICS,
     1                      IMONIT_LEVEL, IMONIT_ALL , 
     1                       IMONIT_FLUX_COMMON
#endif
!
      IMPLICIT NONE
!
! INPUT
!
      INTEGER,INTENT(IN)    :: NSTR
      INTEGER,INTENT(IN)    :: NEND
      INTEGER,INTENT(IN)    :: INSFLAG         ! �ᖳ�� 0, �ቺ 1 
!
!  �萔
!
      INTEGER,INTENT(IN)    :: NTYP      (IDX)
!
      REAL(8),INTENT(IN)    :: DELT_SOIL       ! ���ԍ�
!
      REAL(8),INTENT(IN)    :: FR_WTR_SOIL (IDX,IDP)  ! 
      REAL(8),INTENT(IN)    :: FR_GLA_SOIL (IDX,IDP)
!
      REAL(8),INTENT(IN)    :: TMP_SOIL    (IDX,IDP)   ! 
!
!
      REAL(8),INTENT(IN)    :: FACT_WGT_H2O  (IDX,IDP)    ! �󌄗�x���̔�d
!
! OUTPUT
!
      REAL(8),INTENT(OUT)   :: WFLUX_H(IDX,IDP) ! ���t���b�N�X
      REAL(8),INTENT(OUT)   :: WTR_INC(IDX,IDP) ! ������
!
! SAVE 
!
      REAL(8),SAVE    :: DEP_H_INV (ITYP,IDP)     ! 1/�w���ό���
!
! WORK
!
      REAL(8)   :: XPOT_SOIL(IDX,IDP)       ! �y��|�e���V����
      REAL(8)   :: XFR_WTR  (IDX,IDP) ! W �󌄒��ŉt���̐�߂�̐ϔ�
!     REAL(8)   :: XPOROS   (IDX,IDP) ! �󌄗� �i1- �y - �X�j
      REAL(8)   :: XK    (IDX,IDP)    ! �����W�� �i�t���j
      REAL(8)   :: XK_H  (IDX,IDP)    ! �����W�� �i�n�[�t�j
      REAL(8)   :: EPSILON(IDX)       ! q_{3+1/2} �L���t���O     
      REAL(8)   :: WFLUX_H_EXP (IDX,IDP)
      REAL(8)   :: WFLUX_H_COR (IDX,IDP)
!
      REAL(8)   :: AA    (IDX,3,4)    ! �������̌W��
      REAL(8)   :: A11I
      REAL(8)   :: A22I
      REAL(8)   :: A33I
      REAL(8)   :: XC_H    (IDX,IDP)  ! �������̌W���p��ƕϐ�
      REAL(8)   :: XC      (IDX,IDP)  ! �������̌W���p��ƕϐ�
      REAL(8)   :: DF12_DW1(IDX)    ! �������̌W���p��ƕϐ�
      REAL(8)   :: DF12_DW2(IDX)    ! �������̌W���p��ƕϐ�
      REAL(8)   :: DF23_DW2(IDX)    ! �������̌W���p��ƕϐ�
      REAL(8)   :: DF23_DW3(IDX)    ! �������̌W���p��ƕϐ�
      REAL(8)   :: DF34_DW2(IDX)    ! �������̌W���p��ƕϐ�
      REAL(8)   :: DF34_DW3(IDX)    ! �������̌W���p��ƕϐ�
!
      REAL(8)   :: DELS    (IDX)     
      REAL(8)   :: WMAX 
      REAL(8)   :: WMIN
      REAL(8)   :: PSMAX 
      REAL(8)   :: PSMIN
      REAL(8)   :: BOT 
!
      REAL(8)   :: PHASE_SOIL(IDX,IDP) ! ��x�ȏ� 1 �A�ȉ� 0 
!                                      ! ��x�ȉ��ł̓|�e���V�����͕ς��Ȃ�
!
      REAL(8)   :: WP3_1 
      REAL(8)   :: WP3_2 
      REAL(8)   :: WP3_3 
      REAL(8)   :: WM1_1  
      REAL(8)   :: WM1_2  
      REAL(8)   :: WM1_3  
!
      REAL(8)   :: AVK          (IDX,IDP)  
      REAL(8)   :: DIV   
      REAL(8)   :: AVKMIN 
      REAL(8)   :: AVKMAX 
      REAL(8)   :: SAT 
!
      REAL(8)   :: DELT_SL
!
      REAL(8)   :: XFR_GLA
      REAL(8)   :: XFACT        (IDX,IDP)
      REAL(8)   :: XFACT_INV    (IDX,IDP)
      REAL(8)   :: XFACT_WGT_H2O(IDX,IDP)
!     
      INTEGER   :: I
      INTEGER   :: J
      INTEGER   :: K
!
      REAL(8),PARAMETER :: DIV_MIN = 1.D-7    ! �̂Ɠ����l
      REAL(8),PARAMETER :: ZERO   = 0.D0
      REAL(8),PARAMETER :: ONE = 1.D0 
      REAL(8),PARAMETER :: XFR_WTR_MIN = 1.D-2 ! �e��W���]���Ɏg���O�a�x����
      REAL(8),PARAMETER :: XFR_GLA_MAX = 0.9999D0
!
#ifdef MONYOS
      CHARACTER(7)      :: CMARK 
#endif
!
      LOGICAL,SAVE :: LFIRST
!
      DATA LFIRST / .TRUE. /
!
!
! ==================================
! >> ��x�v�Z����΂����萔�̐ݒ� << 
! ==================================
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'SOIL_WFLUX 99/08 POCHAKA'
        LFIRST = .FALSE. 
!
!       ���ӁBdep_h_inv(I,3) �̗^�����ɂ��āB  99/09/24 
!             3,4 �w�ڊԂ̐��t���b�N�X��]������ۂɁA
!             4 �w�ڂ� 3 �w�ڂƓ����������ƍl���A
!             3,4, �w�ڂ̊e�X�̒����ł̒l�̍�����]������A�Ƃ�������B
!
        DO 100 J = 1,ITYP
          DEP_H_INV(J,1) = 2. / ( DEP_SOIL_co(J,1)+ DEP_SOIL_co(J,2) ) 
          DEP_H_INV(J,2) = 2. / ( DEP_SOIL_co(J,2)+ DEP_SOIL_co(J,3) ) 
          DEP_H_INV(J,3) = 1. / DEP_SOIL_co(J,3)   
 100    CONTINUE   
!
      ENDIF
!
      DELT_SL      = DELT_SOIL * DELT_FAC_SOIL_c    ! �Ӗ���?  000731
!
!     write(6,*) 'soil_wflux KKK delt_fac ' , 
!    1           DELT_FAC_SOIL_1 , DELT_FAC_SOIL_2 , delt_soil
!
! =======================================
! >> �|�e���V�����ω��t���O PHASE_SOIL << 
! =======================================
!  ��x�ȉ��ł͐����|�e���V�����͕ω����Ȃ�
!
      PHASE_SOIL(:,:) = ONE 
! 
      DO K=1,IDP
      DO I=NSTR,NEND
        IF ( TMP_SOIL(I,K) .LT. TMP_FREZ_c ) THEN
          PHASE_SOIL(I,K) = 0.
        ENDIF
      ENDDO
      ENDDO
!
! ======================
! >> �����W�����̌v�Z << 
! ======================
!
      DO 1000 K=1,IDP
      DO 1000 I=NSTR,NEND
        J = NTYP(I)
!
! �X�̑��݂ɂ��O�a�x���ɂ�����W���̐ݒ�
!       XFACT     = (1-XFR_GLA1) 
!       XFACT_INV = 1/(1-XFR_GLA1) 
!       XFACT     * XFR_W = FR_W 
!
        XFR_GLA  = MIN ( FR_GLA_SOIL (I,K) , XFR_GLA_MAX )  ! max �� 0.9999
        XFACT    (I,K) = 1 - XFR_GLA                        ! min �� 0.0001
        XFACT_INV(I,K) = 1./XFACT(I,K)                      ! max �� 10000 
!
! �O�a�x XFR_WTR  �i �󌄒��Ő��̐�߂�̐ϔ� �j
!
        XFR_WTR  (I,K) = FR_WTR_SOIL (I,K) * XFACT_INV(I,K)
!
#ifdef SIB_DEBUG 
        if ( xfr_wtr(I,K)-1 .GT. 1.D-7 ) THEN
          write(6,*) 'soil_wflux error xfr_wtr' , i , K ,xfr_wtr(I,K),
     1               XFR_GLA , XFACT(I,K) ,  FR_WTR_SOIL (I,K) , 
     1               XFACT_INV(I,K) , 
     1               FR_WTR_SOIL (I,K) + FR_GLA_SOIL (I,K) 
          stop 999
        endif
#endif
!
        XFR_WTR  (I,K) = MAX ( XFR_WTR  (I,K) , XFR_WTR_MIN )  ! min �� 0.01 
!
! �󌄗� XPOROS �i �󌄂̊����B1 - �y - �X )
!       XPOROS (I,K) = POR_SOIL_co(J) * (1.-FR_GLA_SOIL(I,K)) 
!
! �y�됅�|�e���V���� XPOT_SOIL
!   ���_... ���������B���������ꍇ�͗L���l�ɁB
!             �܂��������Ȃ��ꍇ�A�d�̓|�e���V�����������Ȃ��悤�ɂ������B
!
        XPOT_SOIL(I,K) = POT_SAT_SOIL_co(J)*XFR_WTR(I,K)**(-BEE_co(J))    
        XPOT_SOIL(I,K) = MAX ( XPOT_SOIL(I,K) , POT_SOIL_MIN_c ) 
!
        XFACT_WGT_H2O(I,K) = FACT_WGT_H2O(I,K) * XFACT(I,K) 
!
! �����W�� XK 
!    ���_... ���������B���������ꍇ�� 0 �ɂ���B
!
        XK(I,K) = WCOEF_SAT_SOIL_co(J) 
     1                * XFR_WTR(I,K)**(2.*BEE_co(J)+3.)    
 1000 CONTINUE  
!
! ========================
! >> �������̌W���̐ݒ� <<
! ========================
!
!     IF ( JCN_COEF_WFLUX_SOIL_c .EQ. 0 ) THEN   ! MILLY AND EAGLESON (1982)?
      DO 4000 I=NSTR,NEND 
        J = NTYP(I)
        WP3_1     = XFR_WTR (I,1)**(2*BEE_co(J)+3.) 
        WP3_2     = XFR_WTR (I,2)**(2*BEE_co(J)+3.) 
        WP3_3     = XFR_WTR (I,3)**(2*BEE_co(J)+3.) 
!
        WM1_1     = XFR_WTR (I,1)**(-BEE_co(J)) 
        WM1_2     = XFR_WTR (I,2)**(-BEE_co(J)) 
        WM1_3     = XFR_WTR (I,3)**(-BEE_co(J)) 
!
!   ����̕]�� �i �A�I�␳���W�� DELS = d��/dw > 0 ) 
!
        WMAX      = MAX ( XFR_WTR (I,1), XFR_WTR (I,2), XFR_WTR (I,3) )
        WMIN      = MIN ( XFR_WTR (I,1), XFR_WTR (I,2), XFR_WTR (I,3) )
        PSMAX     = MAX ( WM1_1        , WM1_2        , WM1_3         )
        PSMIN     = MIN ( WM1_1        , WM1_2        , WM1_3         )
        BOT       = MAX ( 1.D-7 , WMAX - WMIN ) 
        DELS(I)   = - ( PSMAX - PSMIN ) / BOT * POT_SAT_SOIL_co(J)   
!                   ^^^^^^^^^^^^^^^^^^^^^^^^^   ^^^^^^^^^^^^^^^^^^
!                      ��                          ��
!
!   ���w�Ƒ��w
!
        AVK(I,1)  = WP3_1 * WM1_1 - WP3_2 * WM1_2
        DIV       = WM1_1 - WM1_2
!
        AVKMIN    = MIN ( WP3_1, WP3_2 )                                
        AVKMAX    = MAX ( WP3_1, WP3_2 )  
! 
        IF ( ABS(DIV).GT.DIV_MIN ) THEN   ! ���ʒʂ�
          AVK(I,1) = - AVK(I,1) * BEE_co(J) / ( (BEE_co(J)+3) * DIV )  
        ENDIF
!
        AVK(I,1)  = MIN ( AVK(I,1) , AVKMAX )
        AVK(I,1)  = MAX ( AVK(I,1) , AVKMIN )
        SAT       = WCOEF_SAT_SOIL_co(J) 
     1               * ( 1 - MAX(FR_GLA_SOIL(I,1),FR_GLA_SOIL(I,2)) )
        XK_H(I,1) = MAX ( SAT * AVK(I,1) , COEF_SOIL_WFLUX_MIN_c ) 
!
!   ���w�Ƒ�O�w
!
        AVK(I,2)  = WP3_2 * WM1_2 - WP3_3 * WM1_3 
        DIV       = WM1_2 - WM1_3
        AVKMIN    = MIN( WP3_2, WP3_3 )                                
        AVKMAX    = MAX( WP3_2, WP3_3 )  
!
        IF ( ABS(DIV).GT.DIV_MIN ) THEN
          AVK(I,2)= - AVK(I,2) * BEE_co(J) / ( (BEE_co(J)+3) * DIV )  
        ENDIF
!
        AVK(I,2)  = MIN ( AVK(I,2) , AVKMAX )
        AVK(I,2)  = MAX ( AVK(I,2) , AVKMIN )
        SAT       = WCOEF_SAT_SOIL_co(J) 
     1             * ( 1 - MAX(FR_GLA_SOIL(I,2),FR_GLA_SOIL(I,3)) )
        XK_H(I,2) = MAX ( SAT * AVK(I,2) , COEF_SOIL_WFLUX_MIN_c ) 
!
!   ��O�w�Ƃ��̉�
!
        AVK (I,3) = XK  (I,3)       ! ������ K
        XK_H(I,3) = XK  (I,3)       ! *SAT ���Ȃ��Ă����̂���?? �����͂�?
 4000 CONTINUE
!
!     ELSE
!       DO 4100 I=NSTR,NEND
!         J = NTYP(I) 
!         XK_H(I,1) 
!    1       = ( DEP_SOIL_co(J,1) + DEP_SOIL_co(J,2) ) 
!    1         * XK(I,1) * XK(I,2)
!    1        / ( DEP_SOIL_co(J,1)* XK(I,2)+DEP_SOIL_co(J,2)* XK(I,1) )
!         XK_H(I,2) 
!    1       = ( DEP_SOIL_co(J,2) + DEP_SOIL_co(J,3) ) 
!    1         * XK(I,2) * XK(I,3)
!    1        / ( DEP_SOIL_co(J,2)* XK(I,3)+DEP_SOIL_co(J,3)* XK(I,2) )     
!         XK_H(I,3) = XK  (I,3) 
!4100   CONTINUE  
!     ENDIF
!
!     �w�Ԃ̗�   XC_H = XK_H / DEP_H 
!     �w�̗�     XC   = XPOT_SOIL * (- BEE_co(J) ) / w * m dt * RHO_WTR_C 
!
      DO 4200 I=NSTR,NEND
        J = NTYP(I) 
!
!  XC_H �̌v�Z
!     ���x x ( AVK x K_s ) / ����          > 0 
!
        XC_H  (I,1) = RHO_WTR_C * XK_H(I,1) * DEP_H_INV(J,1) 
        XC_H  (I,2) = RHO_WTR_C * XK_H(I,2) * DEP_H_INV(J,2)
        XC_H  (I,3) = RHO_WTR_C * XK_H(I,3) * DEP_H_INV(J,3) 
     1                                      * SINX_co(J) 
!
        WFLUX_H_EXP(I,1) 
     1     = - XC_H(I,1) 
     1        * ( XPOT_SOIL(I,2) - XPOT_SOIL(I,1) ) 
!            + RHO_WTR_C * AVK(I,1)                 ! �d�̓|�e���V����
!
        WFLUX_H_EXP(I,2) 
     1     = - XC_H(I,2) 
     1        * ( XPOT_SOIL(I,3) - XPOT_SOIL(I,2) )  
!            + RHO_WTR_C * AVK(I,2)                 ! �d�̓|�e���V����
!
        WFLUX_H_EXP(I,3) 
     1     = - XC_H(I,3) 
     1        * ( XPOT_SOIL(I,3) - XPOT_SOIL(I,2) )  
!    1        + RHO_WTR_C * AVK(I,3) * sinx_co(j) 
!
!  �A�I�␳���֌W
!     d��/dw 
!     �Ƃ肠�����͊e�w�Ƃ����Ȃ��l DELS �ɂ��Ă݂�
!
        XC    (I,1) = DELS (I) 
        XC    (I,2) = DELS (I) 
        XC    (I,3) = DELS (I) 
!
!
 4200 CONTINUE  
!
      IF ( JCN_RUNOFF_GRAV_c .GE. 1 ) THEN 
        DO I=NSTR,NEND
          WFLUX_H_EXP(I,3) = WFLUX_H_EXP(I,3) 
     1        + RHO_WTR_C * AVK(I,3) * sinx_co(j) 
                                                     ! �d�̓|�e���V����
        ENDDO
      ENDIF
!
      IF ( JCN_RUNOFF_GRAV_c .GE. 2 ) THEN 
        DO I=NSTR,NEND
          WFLUX_H_EXP(I,1) = WFLUX_H_EXP(I,1) 
!    1         + RHO_WTR_C * AVK(I,1)               
     1         + RHO_WTR_C * XK_H(I,1)               
          WFLUX_H_EXP(I,2) = WFLUX_H_EXP(I,2) 
!    1         + RHO_WTR_C * AVK(I,2)               
     1         + RHO_WTR_C * XK_H(I,2)               
        ENDDO
      ENDIF
!
! �� 3 �w�ڂւ̉�����̗���
!     JCN_RRUNOFF_B = 0 �i��ւ̋t���֎~�j�ŁAWFLUX_H �����i������j�̏ꍇ
!
      DO 4300 I=NSTR,NEND 
        EPSILON(I) = 1.
 4300 CONTINUE  
!
      IF ( JCN_RRUNOFF_B .EQ. 0 ) THEN
        DO 4310 I=NSTR,NEND 
          IF ( WFLUX_H_EXP(I,3) .LT. 0. ) THEN
            EPSILON(I) = 0. 
            WFLUX_H_EXP(I,3) = 0. 
          ENDIF
 4310   CONTINUE  
      ENDIF
!
!  ================================================
!  >> �t���b�N�X�̉����� �` �C���v���V�b�g�̏ꍇ <<
!  ================================================
!
      IF ( JCN_SOIL_WATER_EXPLICIT.EQ.0 ) THEN
!
! ------------------------
! > �C���v���V�b�g��^�� < 
! ------------------------
!
!   ��
!      DF12_DW1 ... W1 ���������Ƃ��� 1->2 �ւ̃t���b�N�X�̑���
!        XC_H(I,1)       = 1 �w�� 2 �w�Ƃ̊Ԃ̒萔
!        XC  (I,1)       = W1 ���������Ƃ��� 1 �w�ڂ̃|�e���V��������
!        PHASE_SOIL(I,1) = W1 ���������Ƃ��ă|�e���V�����������邩?
!      
      DO I=NSTR,NEND
        DF12_DW1(I) =   XC_H (I,1) * XC (I,1) 
!    1                             * PHASE_SOIL(I,1) 
        DF12_DW2(I) = - XC_H (I,1) * XC (I,2) 
!    1                             * PHASE_SOIL(I,2)         
        DF23_DW2(I) =   XC_H (I,2) * XC (I,2) 
!    1                             * PHASE_SOIL(I,2)         
        DF23_DW3(I) = - XC_H (I,2) * XC (I,3) 
!    1                             * PHASE_SOIL(I,3)         
        DF34_DW2(I) =   XC_H (I,3) * XC (I,2) 
!    1                                        * PHASE_SOIL(I,2) 
!    1                                        * EPSILON(I)
        DF34_DW3(I) = - XC_H (I,3) * XC (I,3) 
!    1                                        * PHASE_SOIL(I,3)         
!    1                                        * EPSILON(I) 
      ENDDO
!
!  ------------------
!  > �����������Ă� <
!  ------------------
!
      DO 5000 I=NSTR,NEND
        AA(I,1,1) 
     1     =   XFACT_WGT_H2O (I,1)  / DELT_SL 
     1       + DF12_DW1 (I)
        AA(I,1,2) 
     1     =   DF12_DW2 (I)
        AA(I,1,3) =   0. 
        AA(I,1,4) 
     1     =                - WFLUX_H_EXP(I,1) 
!
        AA(I,2,1) 
     1     = - DF12_DW1 (I)
        AA(I,2,2) 
     1     =   XFACT_WGT_H2O (I,2) / DELT_SL  
     1       - DF12_DW2 (I) + DF23_DW2(I)  
        AA(I,2,3) 
     1     =                + DF23_DW3(I)  
        AA(I,2,4) 
     1     =   WFLUX_H_EXP(I,1) - WFLUX_H_EXP(I,2) 
!
        AA(I,3,1) =   0. 
        AA(I,3,2) 
     1     = - DF23_DW2(I) 
!    1       + DF34_DW2(I)               ! ���[�r���A�I�␳
        AA(I,3,3) 
     1     =   XFACT_WGT_H2O (I,3) / DELT_SL 
     1       - DF23_DW3(I) 
!    1       + DF34_DW3(I)               ! ���[�r���A�I�␳
        AA(I,3,4) 
     1     =   WFLUX_H_EXP(I,2) - WFLUX_H_EXP(I,3) 
 5000 CONTINUE  
!
! ----------------
! > ������������ <
! ----------------
!
      DO 6000 I=NSTR,NEND
        A33I = 1./AA(I,3,3) 
        AA(I,3,2) = AA(I,3,2) * A33I
        AA(I,3,4) = AA(I,3,4) * A33I
!       AA(I,3,3) = 1. 
!
        AA(I,2,2) = AA(I,2,2) - AA(I,3,2) * AA(I,2,3)     
        AA(I,2,4) = AA(I,2,4) - AA(I,3,4) * AA(I,2,3)     
!       AA(I,2,3) = 0. 
!
        A22I = 1./AA(I,2,2)
        AA(I,2,1) = AA(I,2,1) * A22I 
        AA(I,2,4) = AA(I,2,4) * A22I 
!       AA(I,2,2) = 1.      
!
        AA(I,1,1) = AA(I,1,1) - AA(I,2,1) * AA(I,1,2)     
        AA(I,1,4) = AA(I,1,4) - AA(I,2,4) * AA(I,1,2)     
!       AA(I,1,2) = 0. 
!
        A11I = 1./AA(I,1,1)
        AA(I,1,4) = AA(I,1,4) * A11I                      ! dW1/dt * ��t
!       AA(I,1,1) = 1. 
!
        AA(I,2,4) = AA(I,2,4) - AA(I,1,4) * AA(I,2,1)     ! dW2/dt * ��t
!       AA(I,2,1) = 0. 
!
        AA(I,3,4) = AA(I,3,4) - AA(I,2,4) * AA(I,3,2)     ! dW3/dt * ��t
!       AA(I,3,2) = 0. 
 6000 CONTINUE
!
! ---------------------- 
! > ���t���b�N�X�̌��� <
! ---------------------- 
!
      DO 7000 I=NSTR,NEND
!
! �t���b�N�X WFLUX_H �̌v�Z ... ��������
!
        WFLUX_H_COR(I,1) 
     1     = 
     1       + (   DF12_DW1(I) * AA(I,1,4) 
     1           + DF12_DW2(I) * AA(I,2,4) ) 
!!   1         * DELT_SL
!
        WFLUX_H_COR(I,2) 
     1     = 
     1       + (   DF23_DW2(I) * AA(I,2,4) 
     1           + DF23_DW3(I) * AA(I,3,4) ) 
!!   1         * DELT_SL
!
        WFLUX_H_COR(I,3) 
     1     = 0
!    1       + (   DF34_DW2(I) * AA(I,2,4) 
!    1           + DF34_DW3(I) * AA(I,3,4) ) 
!              * DELT_SL
!
        WFLUX_H(I,1) = WFLUX_H_EXP(I,1) + WFLUX_H_COR(I,1) 
!
        WFLUX_H(I,2) = WFLUX_H_EXP(I,2) + WFLUX_H_COR(I,2) 
!
        WFLUX_H(I,3) = WFLUX_H_EXP(I,3) + WFLUX_H_COR(I,3) 
!
 7000 CONTINUE  
!
!  ==================================================
!  >> �t���b�N�X�̉����� �` �G�N�X�v���V�b�g�̏ꍇ <<
!  ==================================================
!
      ELSE 
        DO I=NSTR,NEND
          WFLUX_H(I,1) = WFLUX_H_EXP(I,1) 
          WFLUX_H(I,2) = WFLUX_H_EXP(I,2) 
          WFLUX_H(I,3) = WFLUX_H_EXP(I,3) 
        ENDDO
      ENDIF
!
!  ==========================
!  >> ��O�w�̉�����̗��� <<
!  ==========================
!     �]�����ʂ� WFLUX_H(I,3) < 0 �A�܂艺����̗�����v������ꍇ�ɁA
!     ����ɂ������邩�ǂ����B
!
      IF ( JCN_RRUNOFF_B .EQ. 0 ) THEN
        DO 8000 I=NSTR,NEND
          WFLUX_H(I,3) = MAX ( WFLUX_H(I,3) , ZERO )
 8000   CONTINUE 
      ENDIF 
!
!  �������鐅�ʌv�Z
!
      DO I=NSTR,NEND 
        WTR_INC(I,1) = (              - WFLUX_H(I,1) ) 
     1                 * DELT_SL 
        WTR_INC(I,2) = ( WFLUX_H(I,1) - WFLUX_H(I,2) ) 
     1                 * DELT_SL
        WTR_INC(I,3) = ( WFLUX_H(I,2) - WFLUX_H(I,3) )
     1                 * DELT_SL
      ENDDO
!
!  ============================
!  >> �t���b�N�X�ʂ̃`�F�b�N <<
!  ============================
!    ���t���b�N�X�v�Z�ŁA���ۂɂ���ȏ�̂��̂𗬂��Ă���ꍇ�͕␳
!
!
! ================
! >> �ڍ׃��j�^ <<
! ================
!
! �n�������I�t�A����сA01 �ȊO�̐��t���b�N�X�ɔ����M�� soil_flux_conv �ŁB
!
#ifdef MONYOS
      IF ( IMONIT_LEVEL .GE. IMONIT_ALL ) THEN
!
!
! ���t���b�N�X 1 -> 2 
!
        IF ( INSFLAG .EQ.0 ) THEN
          CMARK  = 'WFLN12'
          CALL MONIT_SIB ( CMARK , WFLUX_H_EXP(1,1), 
     1                     ICN, DELT_SOIL,ONE)  
        ELSE
          CMARK  = 'WFLS12'
          CALL MONIT_SIB ( CMARK , WFLUX_H_EXP(1,1), 
     1                     ICS, DELT_SOIL,ONE)  
        ENDIF
!
! ���t���b�N�X 2 -> 3 
!
        IF ( INSFLAG .EQ.0 ) THEN
          CMARK  = 'WFLN23'
          CALL MONIT_SIB ( CMARK , WFLUX_H_EXP(1,2), 
     1                     ICN   , DELT_SOIL,ONE)  
        ELSE
          CMARK  = 'WFLS23'
          CALL MONIT_SIB ( CMARK , WFLUX_H_EXP(1,2), 
     1                     ICS   , DELT_SOIL,ONE)  
        ENDIF
!
! ���t���b�N�X 2 -> 3 
!
        IF ( INSFLAG .EQ.0 ) THEN
          CMARK  = 'WFLN34'
          CALL MONIT_SIB ( CMARK , WFLUX_H_EXP(1,3), 
     1                     ICN   , DELT_SOIL,ONE)  
        ELSE
          CMARK  = 'WFLS34'
          CALL MONIT_SIB ( CMARK , WFLUX_H_EXP(1,3), 
     1                     ICS   , DELT_SOIL,ONE)  
        ENDIF
!
! ���t���b�N�X 1 -> 2 
!
        IF ( INSFLAG .EQ.0 ) THEN
          CMARK  = 'WFLN12C'
          CALL MONIT_SIB ( CMARK , WFLUX_H_COR(1,1), 
     1                     ICN, DELT_SOIL,ONE)  
        ELSE
          CMARK  = 'WFLS12C'
          CALL MONIT_SIB ( CMARK , WFLUX_H_COR(1,1), 
     1                     ICS, DELT_SOIL,ONE)  
        ENDIF
!
! ���t���b�N�X 2 -> 3 
!
        IF ( INSFLAG .EQ.0 ) THEN
          CMARK  = 'WFLN23C'
          CALL MONIT_SIB ( CMARK , WFLUX_H_COR(1,2), 
     1                     ICN   , DELT_SOIL,ONE)  
        ELSE
          CMARK  = 'WFLS23C'
          CALL MONIT_SIB ( CMARK , WFLUX_H_COR(1,2), 
     1                     ICS   , DELT_SOIL,ONE)  
        ENDIF
!
!
! COEF XK
!
        CMARK  = 'XK1'
        IF ( INSFLAG .EQ.0 ) THEN
          CALL MONIT_SIB ( CMARK , XK(1,1),ICN, DELT_SOIL,ONE)  
        ELSE 
          CALL MONIT_SIB ( CMARK , XK(1,1),ICS, DELT_SOIL,ONE)  
        ENDIF
!
        CMARK  = 'XK2'
        IF ( INSFLAG .EQ.0 ) THEN
          CALL MONIT_SIB ( CMARK , XK(1,2),ICN, DELT_SOIL,ONE)  
        ELSE 
          CALL MONIT_SIB ( CMARK , XK(1,2),ICS, DELT_SOIL,ONE)  
        ENDIF
!
        CMARK  = 'XK3'
        IF ( INSFLAG .EQ.0 ) THEN
          CALL MONIT_SIB ( CMARK , XK(1,3),ICN, DELT_SOIL,ONE)  
        ELSE 
          CALL MONIT_SIB ( CMARK , XK(1,3),ICS, DELT_SOIL,ONE)  
        ENDIF
!
! COEF XK_H 
!
        CMARK  = 'XKH1'
        IF ( INSFLAG .EQ.0 ) THEN
          CALL MONIT_SIB ( CMARK , XK_H(1,1),ICN, DELT_SOIL,ONE)  
        ELSE 
          CALL MONIT_SIB ( CMARK , XK_H(1,1),ICS, DELT_SOIL,ONE)  
        ENDIF
!
        CMARK  = 'XKH2'
        IF ( INSFLAG .EQ.0 ) THEN
          CALL MONIT_SIB ( CMARK , XK_H(1,2),ICN, DELT_SOIL,ONE)  
        ELSE 
          CALL MONIT_SIB ( CMARK , XK_H(1,2),ICS, DELT_SOIL,ONE)  
        ENDIF
!
        CMARK  = 'XKH3'
        IF ( INSFLAG .EQ.0 ) THEN
          CALL MONIT_SIB ( CMARK , XK_H(1,3),ICN, DELT_SOIL,ONE)  
        ELSE 
          CALL MONIT_SIB ( CMARK , XK_H(1,3),ICS, DELT_SOIL,ONE)  
        ENDIF
!
        CMARK  = 'AVK1'
        IF ( INSFLAG .EQ.0 ) THEN
          CALL MONIT_SIB ( CMARK , AVK(1,1),ICN, DELT_SOIL,ONE)  
        ELSE 
          CALL MONIT_SIB ( CMARK , AVK(1,1),ICS, DELT_SOIL,ONE)  
        ENDIF
!
        CMARK  = 'AVK2'
        IF ( INSFLAG .EQ.0 ) THEN
          CALL MONIT_SIB ( CMARK , AVK(1,2),ICN, DELT_SOIL,ONE)  
        ELSE 
          CALL MONIT_SIB ( CMARK , AVK(1,2),ICS, DELT_SOIL,ONE)  
        ENDIF
!
        CMARK  = 'AVK3'
        IF ( INSFLAG .EQ.0 ) THEN
          CALL MONIT_SIB ( CMARK , AVK(1,3),ICN, DELT_SOIL,ONE)  
        ELSE 
          CALL MONIT_SIB ( CMARK , AVK(1,3),ICS, DELT_SOIL,ONE)  
        ENDIF
!
        CMARK  = 'POTL1'
        IF ( INSFLAG .EQ.0 ) THEN
          CALL MONIT_SIB ( CMARK , XPOT_SOIL(1,1),ICN, DELT_SOIL,ONE)  
        ELSE 
          CALL MONIT_SIB ( CMARK , XPOT_SOIL(1,1),ICS, DELT_SOIL,ONE)  
        ENDIF
        CMARK  = 'POTL2'
        IF ( INSFLAG .EQ.0 ) THEN
          CALL MONIT_SIB ( CMARK , XPOT_SOIL(1,2),ICN, DELT_SOIL,ONE)  
        ELSE 
          CALL MONIT_SIB ( CMARK , XPOT_SOIL(1,2),ICS, DELT_SOIL,ONE)  
        ENDIF
        CMARK  = 'POTL3'
        IF ( INSFLAG .EQ.0 ) THEN
          CALL MONIT_SIB ( CMARK , XPOT_SOIL(1,3),ICN, DELT_SOIL,ONE)  
        ELSE 
          CALL MONIT_SIB ( CMARK , XPOT_SOIL(1,3),ICS, DELT_SOIL,ONE)  
        ENDIF
!
!
      ENDIF
!
      IF ( IMONIT_LEVEL .GE. IMONIT_FLUX_COMMON ) THEN
!
!
! ���t���b�N�X 1 -> 2 
!
        IF ( INSFLAG .EQ.0 ) THEN
          CMARK  = 'WFLN12F'
          CALL MONIT_SIB ( CMARK , WFLUX_H    (1,1), 
     1                     ICN, DELT_SOIL,ONE)  
        ELSE
          CMARK  = 'WFLS12F'
          CALL MONIT_SIB ( CMARK , WFLUX_H    (1,1), 
     1                     ICS  , DELT_SOIL,ONE)  
        ENDIF
!
! ���t���b�N�X 2 -> 3 
!
        IF ( INSFLAG .EQ.0 ) THEN
          CMARK  = 'WFLN23F'
          CALL MONIT_SIB ( CMARK , WFLUX_H    (1,2), 
     1                     ICN   , DELT_SOIL,ONE)  
        ELSE
          CMARK  = 'WFLS23F'
          CALL MONIT_SIB ( CMARK , WFLUX_H    (1,2), 
     1                     ICS   , DELT_SOIL,ONE)  
        ENDIF


!
      ENDIF
#endif 
!
      RETURN
      END
!===============================================================
      SUBROUTINE MR_SOIL_WFLUX
!
! soil_wflux �ŏo�͂���f�o�b�O�p�ϐ��̓o�^���
!
#ifdef MONYOS
      USE SIB_MONIT, ONLY : 
     1         IMONIT_LEVEL, IMONIT_ALL, IMONIT_FLUX_COMMON
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
!
      DATA LFIRST /.TRUE./
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'MONIT_REGIST_SOIL_WFLUX 99/09 POCHAKA'
        LFIRST = .FALSE. 
      ENDIF
!
!-------------------------------------------------------------
!
#ifdef MONYOS
      IF ( IMONIT_LEVEL .GE. IMONIT_ALL ) THEN
!
!
!  1->2 �̐��t���b�N�X   �i�M�͕ʓr�j
!
      CMARK  = 'WFLN12'
      CTITLE = 'H2O FLUX SOIL 1 TO 2 NOS explicit'
      CUNIT  = 'kg/m**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'WFLS12'
      CTITLE = 'H2O FLUX SOIL 1 TO 2 SNW explicit'
      CUNIT  = 'kg/m**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
!  2->3 �̐��t���b�N�X   �i�M�͕ʓr�j
!
      CMARK  = 'WFLN23'
      CTITLE = 'H2O FLUX SOIL 2 TO 3 NOS explicit'
      CUNIT  = 'kg/m**2/s'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'WFLS23'
      CTITLE = 'H2O FLUX SOIL 2 TO 3 SNW explicit'
      CUNIT  = 'kg/m**2/s'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'WFLN34'
      CTITLE = 'H2O FLUX SOIL 2 TO 3 NOS explicit'
      CUNIT  = 'kg/m**2/s'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'WFLS34'
      CTITLE = 'H2O FLUX SOIL 2 TO 3 SNW explicit'  
      CUNIT  = 'kg/m**2/s'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'WFLN12C'
      CTITLE = 'H2O FLUX SOIL 1 TO 2 NOS explicit'
      CUNIT  = 'kg/m**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'WFLS12C'
      CTITLE = 'H2O FLUX SOIL 1 TO 2 SNW explicit'
      CUNIT  = 'kg/m**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
!  2->3 �̐��t���b�N�X   �i�M�͕ʓr�j
!
      CMARK  = 'WFLN23C'
      CTITLE = 'H2O FLUX SOIL 2 TO 3 NOS explicit'
      CUNIT  = 'kg/m**2/s'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'WFLS23C' 
      CTITLE = 'H2O FLUX SOIL 2 TO 3 SNW explicit'
      CUNIT  = 'kg/m**2/s'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
!
      CMARK  = 'XK1'
      CTITLE = 'H2O FLUX COEF 1-2'
      CUNIT  = '-'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
      CMARK  = 'XK2'
      CTITLE = 'H2O FLUX COEF 2-3'
      CUNIT  = '-'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
      CMARK  = 'XK3'
      CTITLE = 'H2O FLUX COEF 3-4'
      CUNIT  = '-'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'XKH1'
      CTITLE = 'H2O FLUX COEF 1-2'
      CUNIT  = '-'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
      CMARK  = 'XKH2'
      CTITLE = 'H2O FLUX COEF 2-3'
      CUNIT  = '-'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
      CMARK  = 'XKH3'
      CTITLE = 'H2O FLUX COEF 3-4'
      CUNIT  = '-'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'AVK1'
      CTITLE = 'H2O FLUX COEF 1-2'
      CUNIT  = '-'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
      CMARK  = 'AVK2'
      CTITLE = 'H2O FLUX COEF 2-3'
      CUNIT  = '-'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
      CMARK  = 'AVK3'
      CTITLE = 'H2O FLUX COEF 3-4'
      CUNIT  = '-'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'POTL1'
      CTITLE = 'potential L1'
      CUNIT  = '-'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'POTL2'
      CTITLE = 'potential L2'
      CUNIT  = '-'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'POTL3'
      CTITLE = 'potential L3'
      CUNIT  = '-'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )

!
      ENDIF
!
      IF ( IMONIT_LEVEL .GE. IMONIT_FLUX_COMMON ) THEN
!
      CMARK  = 'WFLN12F'
      CTITLE = 'H2O FLUX SOIL 1 TO 2 NOS after CORRECT'
      CUNIT  = 'kg/m**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'WFLS12F'
      CTITLE = 'H2O FLUX SOIL 1 TO 2 SNW after CORRECT'
      CUNIT  = 'kg/m**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'WFLN23F'
      CTITLE = 'H2O FLUX SOIL 2 TO 3 NOS after CORRECT'
      CUNIT  = 'kg/m**2/s'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'WFLS23F'
      CTITLE = 'H2O FLUX SOIL 2 TO 3 SNW after CORRECT'
      CUNIT  = 'kg/m**2/s'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      ENDIF
#endif
!
      RETURN
      END












