class UMSWeap_M4 extends UMSWeapon;

/********************************
********************************/

simulated event SetPosition(UDKPawn Holder)
{
	//local vector sloc;
	super.SetPosition(Holder);
	SetBase(Holder,,Holder.ArmsMesh[0],UMSPawn(Holder).ArmWeaponPoint);
	//Holder.ArmsMesh[0].GetSocketWorldLocationAndRotation(UMSPawn(Holder).ArmWeaponPoint,sloc);
	//SetLocation(sloc);	
}

defaultproperties
{
	//WeaponCategory=EWP_Rife
	//WeapAnimType=EWAT_Rife
	bUseCameraSocket=true
	CameraSocketName = "Eye"
  bEjectBrassOnFire=True  //�Ƿ��˵���(True - ����������, false - �� ����������)
	BrassClass=Class'Brass' // Ӧ�õ�Class
	BrassStartOffset=(X=0,Y=0,Z=0) // ���ó���ƫ��
        BrassVelocity=(X=40,Y=90,Z=70)    //�����ٶ� 


	ReloadInterval=2.290000 // ����� ������������ �������� �����������
    EmptyReloadInterval=3.200000 // ����� ������������ �������� ����������� � �������������� �������
    RunStartInterval=0.200000 // ����� ������������ �������� ������ �������
    RunEndInterval=0.200000 // ����� ������������ �������� ��������� �������
	SwitchModeInterval=0.5
	IronSightStartInterval = 0.8 // equals to zomm rate
	IronSightEndInterval = 0.8
	
	WeaponReloadEmptyAnim="WeaponReloadEmpty"
	WeaponISIdleAnim="WeaponFire"
	
    ClipCount=30 // װ����
    //RecoilAmount=160   //ǹ�ĺ�������С
	AmmoCount=90 // Я����
  MaxAmmoCount=360  //���Я����
	
	

  bPrimaryWeapon=True

  PlayerViewOffset=(X=25,Y=1,Z=-1.5)                 //   ������ʼ����   ÿ����������ͬ��������

	//IronSightViewOffset=(X=-2.60,Y=-11,Z=2.30)  // �������Ҽ�������   ÿ����������ͬ��������
	bUseISSocket=true
	ISSocketName="ISSocket"
	IronSightViewOffset=(X=0,Y=0,Z=0)
	//bZoomedFireMode(0)=
	//bZoomedFireMode(1)=true
	ZoomedTargetFOV=40.0
	ZoomedRate=90.0
	ZoomFadeTime=0.2
	
	RecoilAmount(0)=160
	IronsightRecoilFactor(0)=0.75
	StayRecoilFactor(0)=0.75
	SpreadPerFire(0)=0.02
	FireSpreadCheckTime(0)=1
	MaxSpread(0) = 0.18
	
	
	RecoilAmount(1)=140
	IronsightRecoilFactor(1)=0.75
	StayRecoilFactor(1)=0.75
	SpreadPerFire(1)=0.02
	FireSpreadCheckTime(1)=1
	MaxSpread(1) = 0.18
	
		

    ReloadCameraAnim=CameraAnim'WP_Ak74.CameraAnims.C_WP_AK74_ReloadMotion'   //���ӵ�ʱ���ŵ�CameraAnims
    ReloadEmptyCameraAnim=CameraAnim'WP_Ak74.CameraAnims.C_WP_AK74_ReloadEmptyMotion'   //ͬ��
//  ReloadSound=SoundCue''
//  ReloadEmptySound=SoundCue''
//  FireCameraAnim(0)=CameraAnim''

    InventoryGroup=2                       //��������ͼ�����к�
    AttachmentClass=Class'UMSAttach_M4'

    WeaponFireSnd(0)=SoundCue'WP_Ak74.Sounds.FireCue'  //���������
		WeaponFireSnd(1)=SoundCue'WP_Ak74.Sounds.FireCue'  //���������
//  WeaponPutDownSnd=SoundCue''
//  WeaponEquipSnd=SoundCue''
//  FlashLightSwitchSnd=SoundCue''

    MuzzleFlashPSCTemplate=ParticleSystem'WP_Ak74.Effects.MuzzleFlash'   //����Ļ���
    MuzzleFlashDuration=0.100000                                       //����Ļ���

    aimerror=600.000000

	WeaponFireTypes(0)=EWFT_InstantHit   //���������ʽ
    WeaponFireTypes(1)=EWFT_InstantHit             //�Ҽ�������ʽ
    FireInterval(0)=0.150000            //������
	ShotCost(0)=1                    //����ʱ�õ��ӵ���
    Spread(0)=0.04000                   //�ӵ�ɢ����С
    InstantHitDamage(0)=30.000000       //��Ѫ
    InstantHitMomentum(0)=1000.000000   //�ӵ�������С
    InstantHitDamageTypes(0)=Class'UMSDmgType_Bullet'
	RotChgSpeed=3.0
	ReturnChgSpeed=3.0
    EquipTime=0.7        
    PutDownTime=0.5
    bInstantHit=True

	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object


    Begin Object Name=PickupMesh 
      SkeletalMesh=SkeletalMesh'MyPackage.WP_M4.WP_AR_M4_HR'          //WeaponPickupFactory���������������
    End Object

    PickupFactoryMesh=PickupMesh
}