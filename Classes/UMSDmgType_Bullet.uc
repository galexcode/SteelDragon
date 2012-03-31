class UMSDmgType_Bullet extends UTDamageType;

static function SpawnHitEffect(Pawn P, float Damage, vector Momentum, name BoneName, vector HitLocation)
{
	local UMSPawn umsp;
	local name HeadBone;
	local UTEmit_HitEffect HitEffect;
	local vector EffectLocation;
	local TraceHitInfo MyHitInfo;

	umsp = UMSPawn(P);
	 EffectLocation = HitLocation;
	if ( BoneName == '' )
	{
			MyHitInfo.HitComponent = P.Mesh;
			P.CheckHitInfo( MyHitInfo, P.Mesh, Momentum, EffectLocation );
			BoneName = MyHitInfo.BoneName;
	}
	if (umsp != None && umsp.Mesh != None)
	{
		HeadBone = umsp.HeadBone;
	}
	if(BoneName != HeadBone)
	{
		return;
	}
	HitEffect = P.Spawn(umsp.default.BloodEmitterClass,,, EffectLocation, rotator(-Momentum));
	if (HitEffect != None)
	{
		//umsp.ClientMessage("Bone Name="$BoneName);
		//umsp.ClientMessage("Head Bone="$HeadBone);
		HitEffect.AttachTo(P, HeadBone);
	}
}


DefaultProperties
{
	//bOverrideHitEffectColor=true
	//HitEffectColor=(A=1,R=1,G=0,B=0)
	bCausesBloodSplatterDecals=True 
  bCausesBlood=True
	KDamageImpulse=200.000000
  VehicleDamageScaling=0.600000
  VehicleMomentumScaling=0.750000
}
