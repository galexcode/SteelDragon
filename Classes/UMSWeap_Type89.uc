class UMSWeap_Type89 extends UMSWeapon;

/********************************
********************************/

defaultproperties
{
      bEjectBrassOnFire=True  // «ЈсЌЋµѓњ«(True - показывать, false - не показывать)
	BrassClass=Class'Brass' // ”¶”√µƒClass
	BrassStartOffset=(X=0,Y=0,Z=0) // …и÷√≥ц…ъ∆Ђ“∆
        BrassVelocity=(X=40,Y=90,Z=70)    //µѓ≥цЋўґ» 


	ReloadInterval=2.290000 // врем€ проигрывани€ анимации перезар€дки
    EmptyReloadInterval=3.200000 // врем€ проигрывани€ анимации перезар€дки и передергивани€ затвора
    RunStartInterval=0.200000 // врем€ проигрывани€ анимации начала спринта
    RunEndInterval=0.200000 // врем€ проигрывани€ анимации окончани€ спринта
	SwitchModeInterval=0.5
	IronSightStartInterval = 0.8 // equals to zomm rate
	IronSightEndInterval = 0.8
	
    ClipCount=30 // „∞µѓЅњ
    //RecoilAmount=160   //«єµƒЇу„шЅ¶іу–°
	AmmoCount=90 // –ѓµѓЅњ
    MaxAmmoCount=360  //„оіу–ѓµѓЅњ
	
	

    bPrimaryWeapon=True

    PlayerViewOffset=(X=20,Y=-3,Z=-1.5)                 //   ќд∆ч≥х Љ„ш±к   √њЄцќд∆чґЉ≤їЌђ„‘––…и÷√

	//IronSightViewOffset=(X=-2.60,Y=-11,Z=2.30)  // ќд∆ч∞і”“Љьµƒ„ш±к   √њЄцќд∆чґЉ≤їЌђ„‘––…и÷√
	bUseISSocket=false
	ISSocketName="ISSocket"
	IronSightViewOffset=(X=5.5,Y=-4.5,Z=-3)
	ISWeaponHand=HAND_Centered
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
	
	WeaponReloadAnim="reload"
	WeaponReloadEmptyAnim="reload"
	WeaponISIdleAnim="Idle"

    ReloadCameraAnim=CameraAnim'WP_Ak74.CameraAnims.C_WP_AK74_ReloadMotion'   //її„”µѓ ±≤•Ј≈µƒCameraAnims
    ReloadEmptyCameraAnim=CameraAnim'WP_Ak74.CameraAnims.C_WP_AK74_ReloadEmptyMotion'   //Ќђ…ѕ
//  ReloadSound=SoundCue''
//  ReloadEmptySound=SoundCue''
//  FireCameraAnim(0)=CameraAnim''

    InventoryGroup=3                       //±Њќд∆чµƒЌЉ±к–тЅ–Ї≈
    AttachmentClass=Class'UMSAttach_Type89'

    WeaponFireSnd(0)=SoundCue'WP_Ak74.Sounds.FireCue'  //њ™їрµƒ…щ“ф
	//WeaponFireSnd(1)=SoundCue'WP_Ak74.Sounds.FireCue'  //њ™їрµƒ…щ“ф
//  WeaponPutDownSnd=SoundCue''
//  WeaponEquipSnd=SoundCue''
//  FlashLightSwitchSnd=SoundCue''

    MuzzleFlashPSCTemplate=ParticleSystem'WP_Ak74.Effects.MuzzleFlash'   //њ™їрµƒїр—ж
    MuzzleFlashDuration=0.100000                                       //њ™їрµƒїр—ж

    aimerror=600.000000

	WeaponFireTypes(0)=EWFT_InstantHit   //„уЉьє•їчЈљ љ
    WeaponFireTypes(1)=EWFT_None             //”“Љьє•їчЈљ љ
    FireInterval(0)=0.150000            //њ™їрЉдЄф
	ShotCost(0)=1                    //њ™їр ±”√µƒ„”µѓ э
    Spread(0)=0.04000                   //„”µѓ…Ґ≤Љіу–°
    InstantHitDamage(0)=30.000000       //µф—™
    InstantHitMomentum(0)=1000.000000   //„”µѓ≥еЅ¶іу–°
    InstantHitDamageTypes(0)=Class'UMSDmgType_Type89'
	RotChgSpeed=3.0
	ReturnChgSpeed=3.0
    EquipTime=0.7        
    PutDownTime=0.5
    bInstantHit=True

	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'MyPackage.WP_89.MS_Type89_VD'      //µЏ“ї»Ћ≥∆µƒќд∆ч
        AnimSets(0)=AnimSet'MyPackage.WP_89.Type89_anim'                //ќд∆чµƒґѓї≠animset
		Animations=MeshSequenceA
		PhysicsAsset=None
		Scale=1
		FOV=45.0                                              //ќд∆чµƒљєЊа
		bForceUpdateAttachmentsInTick=true

	End Object

    Mesh=FirstPersonMesh



    Begin Object Name=PickupMesh 
      SkeletalMesh=SkeletalMesh'MyPackage.WP_89.MS_Type89_VD'          //WeaponPickupFactoryќд∆ч≥ц…ъµгµƒќд∆ч
    End Object

    PickupFactoryMesh=PickupMesh
}