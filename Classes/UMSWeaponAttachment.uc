class UMSWeaponAttachment extends UTWeaponAttachment;

//var bool bFlashSecondary;
//var const WeapAnimType DUAL_ANIM = EWAT_DualPistols;

/*
simulated function PlayImpactEffects(vector HitLocation)
{
	if(Pawn(HitActor) != none)
  {
    WorldInfo.MyEmitterPool.SpawnEmitter(BloodTemplate, HitLocation, rotator(-HitNormal),);
    PlaySound(SoundCue'A_Character_BodyImpacts.BodyImpacts.A_Character_BodyImpact_Bullet_Cue',true,,, HitLocation);
  }
	super.PlayImpactEffects(HitLocation);
}
*/

simulated function SecondaryAttachTo(UTPawn OwnerPawn)
{
	SetWeaponOverlayFlags(OwnerPawn);

	if (OwnerPawn.Mesh != None)
	{
		// Attach Weapon mesh to player skelmesh
		if ( Mesh != None )
		{
			OwnerMesh = OwnerPawn.Mesh;
			AttachmentSocket = OwnerPawn.WeaponSocket2;

			// Weapon Mesh Shadow
			Mesh.SetShadowParent(OwnerPawn.Mesh);
			Mesh.SetLightEnvironment(OwnerPawn.LightEnvironment);

			if (OwnerPawn.ReplicatedBodyMaterial != None)
			{
				SetSkin(OwnerPawn.ReplicatedBodyMaterial);
			}

			OwnerPawn.Mesh.AttachComponentToSocket(Mesh, OwnerPawn.WeaponSocket2);
		}

		if (OverlayMesh != none)
		{
			OwnerPawn.Mesh.AttachComponentToSocket(OverlayMesh, OwnerPawn.WeaponSocket2);
		}
	}

	if (MuzzleFlashSocket != '')
	{
		if (MuzzleFlashPSCTemplate != None || MuzzleFlashAltPSCTemplate != None)
		{
			MuzzleFlashPSC = new(self) class'UTParticleSystemComponent';
			MuzzleFlashPSC.bAutoActivate = false;
			MuzzleFlashPSC.SetOwnerNoSee(true);
			Mesh.AttachComponentToSocket(MuzzleFlashPSC, MuzzleFlashSocket);
		}
	}

	OwnerPawn.SetWeapAnimType(WeapAnimType);

	GotoState('CurrentlyAttached');
}

simulated function ThirdPersonFireEffects(vector HitLocation)
{
	local UMSPawn P;

	Super.ThirdPersonFireEffects(HitLocation);

	//SpawnTracer(GetEffectLocation(), HitLocation);

	P = UMSPawn(Instigator);
	if (P != None && P.bUseSecondary)
	{
		// override recoil and play only on hand that's firing
		P.GunRecoilNode.bPlayRecoil = false;
		if (P.bFireSecondary)
		{
			P.LeftRecoilNode.bPlayRecoil = true;
		}
		else
		{
			P.RightRecoilNode.bPlayRecoil = true;
		}

		//bFlashSecondary = !bFlashSecondary;
	}
}

/*
simulated function AttachTo(OwnerPawn)
{
	if(bSecondary&&UMSPawn(OwnerPawn).bUseSecondary)
	{
		 SecondaryAttachTo(OwnerPawn);
	}
	else
		super.AttachTo(OwnerPawn);
}
*/

DefaultProperties
{
  
}


