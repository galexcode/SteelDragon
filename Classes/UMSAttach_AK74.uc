class UMSAttach_AK74 extends UMSWeaponAttachment;

DefaultProperties
{
  // Weapon SkeletalMesh
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_Ak74.Mesh.WP_SK_AK74_3P'//非第一人称的武器
		Translation=(Y=0,Z=-2)
		Rotation=(pitch=0,Yaw=0)
		Scale=1.1
	End Object
	
	MuzzleFlashSocket = MussleFlashSocket
  MuzzleFlashPSCTemplate=ParticleSystem'WP_Ak74.Effects.MuzzleFlash'   //开火的火焰
  MuzzleFlashDuration=0.100000
	
//以下是弹着点的效果 
DefaultImpactEffect=(DecalMaterials=(MaterialInstanceConstant'WP_Pistol.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=24.000000,DecalHeight=24.000000,ParticleTemplate=ParticleSystem'WP_Pistol.Effects.P_WP_Pistol_MuzzleFlash_Impact',Sound=SoundCue'WP_Pistol.Sounds_Bullet.WP_BulletImpact_Concrete')
	
	ImpactEffects(0)=(MaterialType="Dirt",DecalMaterials=(MaterialInstanceConstant'WP_Pistol.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'WP_Pistol.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(1)=(MaterialType="Gravel",DecalMaterials=(MaterialInstanceConstant'WP_Pistol.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'WP_Pistol.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(2)=(MaterialType="Sand",DecalMaterials=(MaterialInstanceConstant'WP_Pistol.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'WP_Pistol.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(3)=(MaterialType="Dirt_Wet",DecalMaterials=(MaterialInstanceConstant'WP_Pistol.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'WP_Pistol.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(4)=(MaterialType="Energy",DecalMaterials=(MaterialInstanceConstant'WP_Pistol.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'WP_Pistol.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(5)=(MaterialType="WorldBoundary",DecalMaterials=(MaterialInstanceConstant'WP_Pistol.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'WP_Pistol.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(6)=(MaterialType="Flesh",DecalMaterials=(MaterialInstanceConstant'WP_Pistol.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'WP_Pistol.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(7)=(MaterialType="Flesh_Human",DecalMaterials=(MaterialInstanceConstant'WP_Pistol.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'WP_Pistol.Effects.P_WP_Pistol_MuzzleFlash_Impact')
	ImpactEffects(8)=(MaterialType="Lava",DecalMaterials=(MaterialInstanceConstant'WP_Pistol.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'WP_Pistol.Effects.P_WP_Pistol_MuzzleFlash_Impact')
	ImpactEffects(9)=(MaterialType="NecrisVehicle",DecalMaterials=(MaterialInstanceConstant'WP_Pistol.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'WP_Pistol.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(10)=(MaterialType="Robot",DecalMaterials=(MaterialInstanceConstant'WP_Pistol.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'WP_Pistol.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(11)=(MaterialType="Foliage",DecalMaterials=(MaterialInstanceConstant'WP_Pistol.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'WP_Pistol.Effects.P_WP_Pistol_MuzzleFlash_Impact',Sound=SoundCue'WP_Pistol.Sounds_Bullet.WP_BulletImpact_Concrete')
    ImpactEffects(12)=(MaterialType="Glass",DecalMaterials=(MaterialInstanceConstant'WP_Pistol.Bullet.MI_Bullet_Wood'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'WP_Pistol.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(13)=(MaterialType="Liquid",DecalMaterials=(MaterialInstanceConstant'WP_Pistol.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'WP_Pistol.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(14)=(MaterialType="Water",DecalMaterials=(MaterialInstanceConstant'WP_Pistol.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'Envy_Effects.Particles.P_WP_Water_Splash_Small')
    ImpactEffects(15)=(MaterialType="ShallowWater",DecalMaterials=(MaterialInstanceConstant'WP_Pistol.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'Envy_Effects.Particles.P_WP_Water_Splash_Small')
    ImpactEffects(17)=(MaterialType="Slime",DecalMaterials=(MaterialInstanceConstant'WP_Pistol.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'WP_Pistol.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(18)=(MaterialType="Metal",DecalMaterials=(MaterialInstanceConstant'WP_Pistol.Bullet.MI_Bullet_Metal'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'WP_Pistol.Effects.P_WP_Pistol_MuzzleFlash_Impact',Sound=SoundCue'WP_Pistol.Sounds_Bullet.WP_BulletImpact_Metal')
    ImpactEffects(19)=(MaterialType="Snow",DecalMaterials=(MaterialInstanceConstant'WP_Pistol.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'WP_Pistol.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(20)=(MaterialType="Wood",DecalMaterials=(MaterialInstanceConstant'WP_Pistol.Bullet.MI_Bullet_Wood'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'WP_Pistol.Effects.P_WP_Pistol_MuzzleFlash_Impact',Sound=SoundCue'WP_Pistol.Sounds_Bullet.WP_BulletImpact_Wood')
}
