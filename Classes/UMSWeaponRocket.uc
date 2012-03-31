class UMSWeaponRocket extends UMSWeapon;

var class<UTProjectile> GrenadeClass;

simulated function ProcessFireMode()
{
	Switch(CurrentFireModeNum)
	{
		Case 0:
			//PC.Print("FireMode: Rocket");
			WeaponProjectiles[0]=default.WeaponProjectiles[0];
			StopFire(0);
			ServerStopFire(0);
			Break;
		Case 1:
			//PC.Print("FireMode: Grenade");
			WeaponProjectiles[0]=GrenadeClass;
			StopFire(0);
			ServerStopFire(0);
			break;		
	}
}

defaultproperties
{
	InventoryGroup=5
	
	FireInterval(0)=+1.0
	
	AttachmentClass=class'UTGameContent.UTAttachment_RocketLauncher'
	
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'WP_RocketLauncher.Mesh.SK_WP_RocketLauncher_3P'
	End Object
		
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponProjectiles(0)=class'UTProj_Rocket'
	GrenadeClass = class'UTProj_Grenade'
	MaxFireModeNum = 1
	FireModeNames(0)="Rocket"
	FireModeNames(1)="Grenade"
	
	WeaponFireSnd[0]=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Fire_Cue'
	
	MuzzleFlashSocket=MuzzleFlashSocketA
	MuzzleFlashPSCTemplate=WP_RocketLauncher.Effects.P_WP_RockerLauncher_Muzzle_Flash
	MuzzleFlashDuration=0.33
	MuzzleFlashLightClass=class'UTGame.UTRocketMuzzleFlashLight'
	
	ShotCost(0)=1 
	ClipCount=1 
	AmmoCount=9 // 携弹量
  MaxAmmoCount=36  //最大携弹量
	
	RecoilAmount(0)=160
	StayRecoilFactor(0)=0.75
	
	ReloadCameraAnim=CameraAnim'WP_Ak74.CameraAnims.C_WP_AK74_ReloadMotion'   //换子弹时播放的CameraAnims
  ReloadEmptyCameraAnim=CameraAnim'WP_Ak74.CameraAnims.C_WP_AK74_ReloadEmptyMotion'   //同上
	
	MaxDesireability=0.78
	AIRating=+0.78
	CurrentRating=+0.78
	
	EquipTime=+0.6
	JumpDamping=0.75
	
	IconCoordinates=(U=131,V=379,UL=129,VL=50)
	CrossHairCoordinates=(U=128,V=64,UL=64,VL=64)
	WeaponPutDownSnd=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Lower_Cue'
	
	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveformShooting1
		Samples(0)=(LeftAmplitude=90,RightAmplitude=50,LeftFunction=WF_LinearDecreasing,RightFunction=WF_LinearDecreasing,Duration=0.200)
	End Object
	WeaponFireWaveForm=ForceFeedbackWaveformShooting1
}
