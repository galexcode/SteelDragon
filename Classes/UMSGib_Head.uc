
/**
 * Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
 */
class UMSGib_Head extends UTGib_Robot;

var bool bBleed;
var float BleedTime;
var float BleedMinDist;
var vector LastLocation;

event HitWall (Vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	local MaterialInstanceTimeVarying MITV_Decal;
	super.HitWall(HitNormal, Wall, WallComp);
	//we can use timer for blood trails
	if(IsTimerActive('Bleed'))
	{
		if(vsize(Location-LastLocation)>BleedMinDist)			
		MITV_Decal = new(Outer) class'MaterialInstanceTimeVarying';
		MITV_Decal.SetParent( class'UMSFamilyInfo_PLA'.default.BloodSplatterDecalMaterial );
		if(Wall!=none&&Wall.bWorldGeometry)
		{
			WorldInfo.MyDecalManager.SpawnDecal(MITV_Decal, Location, rotator(-HitNormal), 100, 100, 50, false);
			MITV_Decal.SetScalarStartTime( class'UTGib'.default.DecalDissolveParamName, class'UTGib'.default.DecalWaitTimeBeforeDissolve );		
			LastLocation = Location;
		}
	}
	else
	{
		SetTimer(BleedTime,false,'Bleed');
	}
}

defaultproperties
{
	GibMeshesData[0]=(TheStaticMesh=StaticMesh'CH_Gibs.Mesh.S_CH_Gib_Corrupt_Part14',TheSkelMesh=None,ThePhysAsset=None,DrawScale=2.0)
	BleedTime = 1.2
	BleedMinDist = 30
	HitSound=SoundCue'A_Character_BodyImpacts.BodyImpacts.A_Character_RobotImpact_HeadshotRoll_Cue'
}
