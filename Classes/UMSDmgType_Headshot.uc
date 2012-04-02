class UMSDmgType_Headshot extends UTDamageType
	abstract;
var bool bHeadDrop;

static function SpawnHitEffect(Pawn P, float Damage, vector Momentum, name BoneName, vector HitLocation)
{
	local UTPawn UTP;
	local name HeadBone;
	local UTEmit_HitEffect HitEffect;

	UTP = UTPawn(P);
	if (UTP != None && UTP.Mesh != None)
	{
		HeadBone = UTP.HeadBone;
	}
	HitEffect = P.Spawn(class'UMSEmit_BloodSpray',,, HitLocation, rotator(-Momentum));
	if (HitEffect != None)
	{
		HitEffect.AttachTo(P, HeadBone);
	}
}

static function int IncrementKills(UTPlayerReplicationInfo KillerPRI)
{
	if ( PlayerController(KillerPRI.Owner) != None )
	{
		PlayerController(KillerPRI.Owner).ReceiveLocalizedMessage( class'UTWeaponKillRewardMessage', 0 );
	}
	return super.IncrementKills(KillerPRI);
}

defaultproperties
{
	bHeadDrop = true;
	bSeversHead=true
	//bNeverGibs=true
	//bIgnoreDriverDamageMult=true
	DeathAnim=Death_Headshot
	CustomTauntIndex=3
	bCausesBloodSplatterDecals=true
	DeathString = "You were headshot"
	KDamageImpulse = 400
}