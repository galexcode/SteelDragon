class UMSWeap_AK74 extends UMSWeapon;

/*
var int LastClipCount;
var int LastAmmoCount;
var int FlameClipCount;
var int FlameAmmoCount;
*/
var class<UTEmitter> FlameEmitterClass;

simulated function ProcessFireMode()
{
	//flamethrower
	if(CurrentFireModeNum==1) //auto
	{
		//WeaponFireTypes(0)=EWFT_InstantHit;
		InstantHitDamageTypes[0]=Class'UMSDmgType_Burning';
		ShotCost[0]=3;	
		/*
		LastClipCount = ClipCount;
		LastAmmoCount = AmmoCount;
		ClipCount = 300;
		AmmoCount = 3;
		*/
		FireInterval[0]=0.05;
		Spread[0]=0;
		InstantHitDamage[0]=20;
		RecoilAmount[0]=0;
		WeaponRange=400;
	}
	else
	{
		InstantHitDamageTypes[0]=default.InstantHitDamageTypes[0];
		ShotCost[0]=default.ShotCost[0];
		FireInterval[0]=default.FireInterval[0];
		Spread[0]=default.Spread[0];
		InstantHitDamage[0]=default.InstantHitDamage[0];
		RecoilAmount[0]=default.RecoilAmount[0];
		WeaponRange = default.WeaponRange;
	}
	super.ProcessFireMode();
}

simulated function ProcessInstantHit(byte FiringMode, ImpactInfo Impact, optional int NumHits)
{
	super.ProcessInstantHit(FiringMode,Impact,NumHits);
	if(CurrentFireModeNum==1)
	{
		if ( Impact.HitActor != None && Impact.HitActor.bWorldGeometry )
		{			
			Impact.HitActor.Spawn(FlameEmitterClass,,, Impact.HitLocation,rotator(-Impact.HitNormal));
		}
	}
}

defaultproperties
{
	//WeapAnimType=EWAT_Rife
  //WeaponCategory = EWP_Rife
	FlameEmitterClass=class'UMSEmit_GroundFlame'
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
	
    ClipCount=30 // װ����
    //RecoilAmount=160   //ǹ�ĺ�������С
	AmmoCount=90 // Я����
    MaxAmmoCount=360  //���Я����

    bPrimaryWeapon=True

    PlayerViewOffset=(X=20,Y=-3,Z=-1.5)                 //   ������ʼ����   ÿ����������ͬ��������

	//IronSightViewOffset=(X=-2.60,Y=-11,Z=2.30)  // �������Ҽ�������   ÿ����������ͬ��������
	bUseISSocket=true
	ISSocketName="ISSocket"
	//IronSightViewOffset=(X=0,Y=-15.9,Z=3.0)
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

    InventoryGroup=3                       //��������ͼ�����к�
    AttachmentClass=Class'UMSAttach_AK74'

    WeaponFireSnd(0)=SoundCue'WP_Ak74.Sounds.FireCue'  //���������
	//WeaponFireSnd(1)=SoundCue'WP_Ak74.Sounds.FireCue'  //���������
//  WeaponPutDownSnd=SoundCue''
//  WeaponEquipSnd=SoundCue''
//  FlashLightSwitchSnd=SoundCue''

		MuzzleFlashSocket = MussleFlashSocket
    MuzzleFlashPSCTemplate=ParticleSystem'WP_Ak74.Effects.MuzzleFlash'   //����Ļ���
    MuzzleFlashDuration=0.100000                                       //����Ļ���

    aimerror=600.000000

		WeaponFireTypes(0)=EWFT_InstantHit   //������ʽ
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
      SkeletalMesh=SkeletalMesh'WP_Ak74.Mesh.WP_SK_AK74_3P'          //WeaponPickupFactory���������������
    End Object

    PickupFactoryMesh=PickupMesh
}