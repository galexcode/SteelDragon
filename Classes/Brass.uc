   //Copyright Unreal-Level.ru\\
  //    - - - PROOF - - -      \\
 //           Pistol            \\
//          NewWeapons           \\

class Brass extends Actor;

var	MeshComponent		ShellMeshComp;

var() float				StayTime;

var() ParticleSystem	BrassEffectTemplate;
var() float				BrassEffectOffset;
var const LightEnvironmentComponent LightEnvironment;

struct BrassImpactSound
{
	var name MaterialType;
	var SoundCue Sound;
};
var() array<BrassImpactSound> BrassImpactSounds;
var   float				NextHitSoundTime;

var Vector				AngularVelocity1;


simulated function StartBrass(optional float SwitchToBackgroundDelay, optional bool bBrassEffect=true, optional bool bNoEffectCollide)
{
	if (ShellMeshComp.BodyInstance == None || !ShellMeshComp.BodyInstance.IsValidBodyInstance())
	{
		Destroy();
		return;
	}

	if (bNoEffectCollide)
		ShellMeshComp.SetRBCollidesWithChannel( RBCC_EffectPhysics, FALSE );

	ShellMeshComp.WakeRigidBody();

	ShellMeshComp.SetRBLinearVelocity( Velocity, false );
	ShellMeshComp.SetRBAngularVelocity( AngularVelocity1, false );

	if (SwitchToBackgroundDelay > 0)
	{
		SetTimer(SwitchToBackgroundDelay, false, 'DPGSwitch');
		ShellMeshComp.SetDepthPriorityGroup(SDPG_Foreground);
	}

	if (BrassEffectTemplate != None && bBrassEffect)
		WorldInfo.MyEmitterPool.SpawnEmitter(BrassEffectTemplate, Location+Vector(Rotation)*BrassEffectOffset, Rotation, self);
}

simulated event PostBeginPlay()
{
	ShellMeshComp.SetRBCollidesWithChannel( RBCC_Default, TRUE );

	if (WorldInfo.bDropDetail || Worldinfo.TimeSeconds - LastRenderTime > 0.05 || WorldInfo.GetDetailMode() < DM_High)
		ShellMeshComp.SetRBCollidesWithChannel( RBCC_EffectPhysics, FALSE );
	else
		ShellMeshComp.SetRBCollidesWithChannel( RBCC_EffectPhysics, TRUE );

	ShellMeshComp.SetRBCollidesWithChannel( RBCC_Pawn, FALSE );
	ShellMeshComp.SetRBCollidesWithChannel( RBCC_Untitled3, FALSE );
	ShellMeshComp.SetRBCollidesWithChannel( RBCC_GameplayPhysics, FALSE );

	SetTimer(StayTime, false);

	NextHitSoundTime = WorldInfo.TimeSeconds + 0.15;
}

simulated function DPGSwitch()
{
	ShellMeshComp.SetDepthPriorityGroup(SDPG_World);
}


simulated function Timer()
{
	if (WorldInfo.bDropDetail || (Worldinfo.TimeSeconds - LastRenderTime > 0.1) || !PlayerCanSeeMe())
		Destroy();
	else
		SetTimer(2.0, false);
}

simulated event RigidBodyCollision( PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent, const out CollisionImpactData RigidCollisionData, int ContactIndex )
{
	if (WorldInfo.TimeSeconds >= NextHitSoundTime && VSizeSq(Velocity) > 2500)
	{
		NextHitSoundTime = WorldInfo.TimeSeconds + 5.0;

		PlayImpactSound(RigidCollisionData.ContactInfos[0].PhysMaterial[0]);
	}
}

simulated function PlayImpactSound (PhysicalMaterial HitMaterial)
{
	local int i;
	local UTPhysicalMaterialProperty PhysicalProperty;

	if (HitMaterial != None)
	{
		PhysicalProperty = UTPhysicalMaterialProperty(HitMaterial.GetPhysicalMaterialProperty(class'UTPhysicalMaterialProperty'));
		if (PhysicalProperty != None && PhysicalProperty.MaterialType != 'None')
		{
			i = BrassImpactSounds.Find('MaterialType', PhysicalProperty.MaterialType);
			if (i == -1)
				i = 0;
		}
	}
	if (BrassImpactSounds[i].Sound != None)
		PlaySound(BrassImpactSounds[i].Sound, true);
}

defaultproperties
{
   Begin Object Class=StaticMeshComponent Name=ShellStaticMeshComp
	  StaticMesh=StaticMesh'WP_BW_All.StaticMesh.S_WP_BW_ShellCasing_Pistol'//StaticMesh'WP_BW_All.StaticMesh.S_WP_BW_ShellCasing_Rifle'
	  CullDistance=1000.000000
      CachedCullDistance=1000.000000
      RBChannel=RBCC_EffectPhysics
      bNotifyRigidBodyCollision=True
      Scale=0.07500
      ScriptRigidBodyCollisionThreshold=50.000000
      Name="ShellStaticMeshComp"
   End Object
	Begin Object Class=DynamicLightEnvironmentComponent Name=ShellLightEnvironmentComp 
      AmbientShadowColor=(R=0.300000,G=0.300000,B=0.300000,A=1.000000)
      AmbientGlow=(R=0.100000,G=0.100000,B=0.100000,A=1.000000)
      bCastShadows=True
      Name="ShellLightEnvironmentComp"
   End Object
   StayTime=5.000000
   BrassEffectOffset=6.000000
   BrassImpactSounds(0)=(MaterialType="Dirt",Sound=SoundCue'WP_BW_All.Sounds.A_WP_BW_Cartridge_ConcreteCue')
   BrassImpactSounds(1)=(MaterialType="Gravel",Sound=SoundCue'WP_BW_All.Sounds.A_WP_BW_Cartridge_ConcreteCue')
   BrassImpactSounds(2)=(MaterialType="Sand",Sound=SoundCue'WP_BW_All.Sounds.A_WP_BW_Cartridge_ConcreteCue')
   BrassImpactSounds(3)=(MaterialType="Dirt_Wet",Sound=SoundCue'WP_BW_All.Sounds.A_WP_BW_Cartridge_ConcreteCue')
   BrassImpactSounds(4)=(MaterialType="Energy",Sound=SoundCue'WP_BW_All.Sounds.A_WP_BW_Cartridge_ConcreteCue')
   BrassImpactSounds(5)=(MaterialType="WorldBoundary",Sound=SoundCue'WP_BW_All.Sounds.A_WP_BW_Cartridge_ConcreteCue')
   BrassImpactSounds(6)=(MaterialType="Flesh",Sound=SoundCue'WP_BW_All.Sounds.A_WP_BW_Cartridge_ConcreteCue')
   BrassImpactSounds(7)=(MaterialType="Flesh_Human",Sound=SoundCue'WP_BW_All.Sounds.A_WP_BW_Cartridge_ConcreteCue')
   BrassImpactSounds(8)=(MaterialType="Kraal",Sound=SoundCue'WP_BW_All.Sounds.A_WP_BW_Cartridge_ConcreteCue')
   BrassImpactSounds(9)=(MaterialType="Necris",Sound=SoundCue'WP_BW_All.Sounds.A_WP_BW_Cartridge_ConcreteCue')
   BrassImpactSounds(10)=(MaterialType="Robot",Sound=SoundCue'WP_BW_All.Sounds.A_WP_BW_Cartridge_MetalCue')
   BrassImpactSounds(11)=(MaterialType="Foliage",Sound=SoundCue'WP_BW_All.Sounds.A_WP_BW_Cartridge_WoodCue')
   BrassImpactSounds(12)=(MaterialType="Glass",Sound=SoundCue'WP_BW_All.Sounds.A_WP_BW_Cartridge_ConcreteCue')
   BrassImpactSounds(13)=(MaterialType="Liquid",Sound=SoundCue'WP_BW_All.Sounds.A_WP_BW_Cartridge_ConcreteCue')
   BrassImpactSounds(14)=(MaterialType="Water",Sound=SoundCue'WP_BW_All.Sounds.A_WP_BW_Cartridge_ConcreteCue')
   BrassImpactSounds(15)=(MaterialType="ShallowWater",Sound=SoundCue'WP_BW_All.Sounds.A_WP_BW_Cartridge_ConcreteCue')
   BrassImpactSounds(16)=(MaterialType="Lava",Sound=SoundCue'WP_BW_All.Sounds.A_WP_BW_Cartridge_ConcreteCue')
   BrassImpactSounds(17)=(MaterialType="Slime",Sound=SoundCue'WP_BW_All.Sounds.A_WP_BW_Cartridge_ConcreteCue')
   BrassImpactSounds(18)=(MaterialType="Metal",Sound=SoundCue'WP_BW_All.Sounds.A_WP_BW_Cartridge_MetalCue')
   BrassImpactSounds(19)=(MaterialType="Snow",Sound=SoundCue'WP_BW_All.Sounds.A_WP_BW_Cartridge_ConcreteCue')
   BrassImpactSounds(20)=(MaterialType="Wood",Sound=SoundCue'WP_BW_All.Sounds.A_WP_BW_Cartridge_WoodCue')
   BrassImpactSounds(21)=(MaterialType="NecrisVehicle",Sound=SoundCue'WP_BW_All.Sounds.A_WP_BW_Cartridge_MetalCue')
   Physics=PHYS_RigidBody
   TickGroup=TG_PostAsyncWork
   bDestroyedByInterpActor=True
   bGameRelevant=True
   bNoEncroachCheck=True
   ShellMeshComp=ShellStaticMeshComp
   Components(1)=ShellStaticMeshComp
   Components(0)=ShellLightEnvironmentComp
   CollisionComponent=ShellStaticMeshComp
}
