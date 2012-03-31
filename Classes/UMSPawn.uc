class UMSPawn extends UTPawn;

var() name EyeSocket;
var() name ArmWeaponPoint;
var() vector EyeOffset;
var bool bUseSecondary;
var bool bFireSecondary;
var bool bSecondaryPuttingDown;
var	repnotify	class<UMSWeaponAttachment>	SecondaryWeaponAttachmentClass;
var				UMSWeaponAttachment			SecondaryWeaponAttachment;
var UMSWeapon SecondaryWeapon;
var repnotify class<UMSWeapon> SecondaryWeaponClass;
var class<UTEmit_BloodSpray> BloodEmitterClass;

replication
{	
	if ( bNetDirty )
		SecondaryWeaponClass, SecondaryWeaponAttachmentClass;
}

DefaultProperties
{
	EyeSocket=Eye
	//BloodSplatterDecalMaterial=MaterialInstanceTimeVarying'CH_Gibs.Decals.BloodSplatter'
	BloodEmitterClass=class'UMSEmit_BloodSpray' //this is the blood emmitter class we created earlier
	//BloodEffects[0]=(Template=ParticleSystem'MyPackage.Effects.P_FX_Bloodhit_Corrupt_Far',MinDistance=750.0)
	//BloodEffects[1]=(Template=ParticleSystem'MyPackage.Effects.P_FX_Bloodhit_Corrupt_Mid',MinDistance=350.0)
	//BloodEffects[2]=(Template=ParticleSystem'MyPackage.Effects.P_FX_Bloodhit_Corrupt_Near',MinDistance=0.0)
}

/*
simulated function PlayTakeHitEffects()
{
	local class<UMSDmgType_Rife95> UMSDamage;
	local vector BloodMomentum;
	local UTEmit_HitEffect HitEffect;
	local ParticleSystem BloodTemplate;

	if (EffectIsRelevant(Location, false))
	{
		UMSDamage = class<UMSDmgType_Rife95>(LastTakeHitInfo.DamageType);
		if ( UMSDamage != None )
		{
			if (UMSDamage.default.bCausesBloodSplatterDecals && !IsZero(LastTakeHitInfo.Momentum) && !class'UTGame'.Static.UseLowGore(WorldInfo))
			{
				LeaveABloodSplatterDecal(LastTakeHitInfo.HitLocation, LastTakeHitInfo.Momentum);
			}		
		  if ( UMSDamage.default.bCausesBlood && !class'UTGame'.Static.UseLowGore(WorldInfo) )
			{
					BloodTemplate = class'UTEmitter'.static.GetTemplateForDistance(default.BloodEffects, LastTakeHitInfo.HitLocation, WorldInfo);This is referencing the blood effects in the default properties
					if (BloodTemplate != None)
					{
						BloodMomentum = Normal(-1.0 * LastTakeHitInfo.Momentum) + (0.5 * VRand());
						HitEffect = Spawn(default.BloodEmitterClass, self,, LastTakeHitInfo.HitLocation, rotator(BloodMomentum));
						HitEffect.SetTemplate(BloodTemplate, true);
						HitEffect.AttachTo(self, LastTakeHitInfo.HitBone);
					}
				}

				if ( !Mesh.bNotUpdatingKinematicDueToDistance )
				{
					// physics based takehit animations
					if (UMSDamage != None)
					{
						//@todo: apply impulse when in full ragdoll too (that also needs to happen on the server)
						if ( !class'Engine'.static.IsSplitScreen() && Health > 0 && DrivenVehicle == None && Physics != PHYS_RigidBody &&
							VSize(LastTakeHitInfo.Momentum) > SYTDamage.default.PhysicsTakeHitMomentumThreshold )
						{
							if (Mesh.PhysicsAssetInstance != None)
							{
								// just add an impulse to the asset that's already there
								Mesh.AddImpulse(LastTakeHitInfo.Momentum, LastTakeHitInfo.HitLocation);
								// if we were already playing a take hit effect, restart it
								if (bBlendOutTakeHitPhysics)
								{
									Mesh.PhysicsWeight = 0.5;
								}
							}
							else if (Mesh.PhysicsAsset != None)
							{
								Mesh.PhysicsWeight = 0.5;
								Mesh.PhysicsAssetInstance.SetNamedBodiesFixed(true, TakeHitPhysicsFixedBones, Mesh, true);
								Mesh.AddImpulse(LastTakeHitInfo.Momentum, LastTakeHitInfo.HitLocation);
								bBlendOutTakeHitPhysics = true;
							}
						}
						UMSDamage.static.SpawnHitEffect(self, LastTakeHitInfo.Damage, LastTakeHitInfo.Momentum, LastTakeHitInfo.HitBone, LastTakeHitInfo.HitLocation);
				}
			}
		}
	}
}
*/

simulated function EquipSecondary(UMSWeapon otherWeapon)
{
	otherWeapon.bSecondary = true;
	SecondaryWeaponAttachmentClass = class<UMSWeaponAttachment>(otherWeapon.AttachmentClass);
	SecondaryWeapon = otherWeapon;
	SecondaryWeapon.bSecondary = true;
	SecondaryWeaponAttachmentChanged();
	SetWeapAnimType(EWAT_DualPistols);
	//otherWeapon.GoToState('');
}

simulated function UnEquipSecondary()
{
	SecondaryWeapon.bSecondary = false;
	SecondaryWeaponAttachmentClass = none;
	SecondaryWeaponAttachment = none;
	SecondaryWeapon = none;
	SecondaryWeaponAttachmentChanged();
	//SetWeapAnimType(EWAT_DualPistols);
}

simulated function SetSkin(Material NewMaterial)
{
	super.SetSkin(NewMaterial);
	if(bUseSecondary)
	{
		if (SecondaryWeaponAttachment != None)
		{
			SecondaryWeaponAttachment.SetSkin(NewMaterial);
		}
	}
}

simulated function SetSecondaryWeaponAttachmentVisibility(bool bAttachmentVisible)
{
	bWeaponAttachmentVisible = bAttachmentVisible;
	if (SecondaryWeaponAttachment != None )
	{
		SecondaryWeaponAttachment.ChangeVisibility(bAttachmentVisible);
	}
}

simulated event Vector GetWeaponStartTraceLocation(optional Weapon CurrentWeapon)
{
	if(bFireSecondary)
	{
		if (SecondaryWeaponAttachment != None)
			return SecondaryWeaponAttachment.GetEffectLocation();
	}
	if (CurrentWeaponAttachment != None)
		return CurrentWeaponAttachment.GetEffectLocation();

	// If we have no controller, we simply traces from pawn eyes location
	return GetPawnViewLocation();
}

simulated event Destroyed()
{
	local PlayerController PC;
	local Actor A;

	Super.Destroyed();

	foreach BasedActors(class'Actor', A)
	{
		A.PawnBaseDied();
	}

	// remove from local HUD's post-rendered list
	ForEach LocalPlayerControllers(class'PlayerController', PC)
	{
		if ( PC.MyHUD != None )
		{
			PC.MyHUD.RemovePostRenderedActor(self);
		}
	}

	if (CurrentWeaponAttachment != None)
	{
		CurrentWeaponAttachment.DetachFrom(Mesh);
		CurrentWeaponAttachment.Destroy();
	}
	if (SecondaryWeaponAttachment != None)
	{
		SecondaryWeaponAttachment.DetachFrom(Mesh);
		SecondaryWeaponAttachment.Destroy();
	}
}

simulated function ApplyWeaponOverlayFlags(byte NewFlags)
{
	super.ApplyWeaponOverlayFlags(NewFlags);
	if(bUseSecondary)
	{
		if ( SecondaryWeaponAttachment != none )
		{
			SecondaryWeaponAttachment.SetWeaponOverlayFlags(self);
		}
	}
}

simulated function FiringModeUpdated(Weapon InWeapon, byte InFiringMode, bool bViaReplication)
{
	super.FiringModeUpdated(InWeapon, InFiringMode, bViaReplication);
	if(SecondaryWeaponAttachment != none)
	{
		SecondaryWeaponAttachment.FireModeUpdated(InFiringMode, bViaReplication);
	}
}

simulated function SetPuttingDownSecondaryWeapon(bool bNowPuttingDownWeapon)
{
	if (bSecondaryPuttingDown != bNowPuttingDownWeapon || Role < ROLE_Authority)
	{
		bSecondaryPuttingDown = bNowPuttingDownWeapon;
		if (SecondaryWeaponAttachment != None)
		{
			SecondaryWeaponAttachment.SetPuttingDownWeapon(bSecondaryPuttingDown);
		}
	}
}

//APHX: modify when allow one put down but another still hold 
simulated function SetPuttingDownWeapon(bool bNowPuttingDownWeapon)
{
	SetPuttingDownSecondaryWeapon(bNowPuttingDownWeapon);
	super.SetPuttingDownWeapon(bNowPuttingDownWeapon);
}

simulated function bool GetSecondaryPuttingDownWeapon()
{
	return bSecondaryPuttingDown;
}


simulated function SecondaryWeaponAttachmentChanged()
{
	if ((SecondaryWeaponAttachment == None || SecondaryWeaponAttachment.Class != SecondaryWeaponAttachmentClass) && Mesh.SkeletalMesh != None)
	{
		// Detach/Destroy the current attachment if we have one
		if (SecondaryWeaponAttachment!=None)
		{
			SecondaryWeaponAttachment.DetachFrom(Mesh);
			SecondaryWeaponAttachment.Destroy();
		}

		// Create the new Attachment.
		if (SecondaryWeaponAttachmentClass!=None)
		{
			SecondaryWeaponAttachment = Spawn(SecondaryWeaponAttachmentClass,self);
			SecondaryWeaponAttachment.Instigator = self;
		}
		else
			SecondaryWeaponAttachment = none;

		// If all is good, attach it to the Pawn's Mesh.
		if (SecondaryWeaponAttachment != None)
		{
			SecondaryWeaponAttachment.SecondaryAttachTo(self);
			SecondaryWeaponAttachment.SetSkin(ReplicatedBodyMaterial);
			SecondaryWeaponAttachment.ChangeVisibility(bWeaponAttachmentVisible);
		}
	}
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'bSecondaryPuttingDown')
	{
		SetPuttingDownSecondaryWeapon(bSecondaryPuttingDown);
	}
	else if(VarName == 'SecondaryWeaponAttachmentClass')
	{
		SecondaryWeaponAttachmentChanged();
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

simulated function SecondaryWeaponFired(Weapon InWeapon, bool bViaReplication, optional vector HitLocation)
{
	if (SecondaryWeaponAttachment != None)
	{
		if ( !IsFirstPerson() )
		{
			SecondaryWeaponAttachment.ThirdPersonFireEffects(HitLocation);
		}
		else
		{
			SecondaryWeaponAttachment.FirstPersonFireEffects(Weapon, HitLocation);
	                if ( class'Engine'.static.IsSplitScreen() && CurrentWeaponAttachment.EffectIsRelevant(CurrentWeaponAttachment.Location,false,CurrentWeaponAttachment.MaxFireEffectDistance) )
	                {
		                // third person muzzle flash
		                SecondaryWeaponAttachment.CauseMuzzleFlash();
	                }
		}

		if ( HitLocation != Vect(0,0,0) && (WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_Standalone || bViaReplication) )
		{
			SecondaryWeaponAttachment.PlayImpactEffects(HitLocation);
		}
	}
}

simulated function SecondaryWeaponStoppedFiring(Weapon InWeapon, bool bViaReplication)
{
	if (SecondaryWeaponAttachment != None)
	{
		// always call function for both viewpoints, as during the delay between calling EndFire() on the weapon
		// and it actually stopping, we might have switched viewpoints (e.g. this commonly happens when entering a vehicle)
		SecondaryWeaponAttachment.StopThirdPersonFireEffects();
		SecondaryWeaponAttachment.StopFirstPersonFireEffects(Weapon);
	}
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	//UTWeapon(Weapon).AttachWeaponTo(ArmsMesh[0],ArmWeaponPoint);
	//ArmsMesh[0].AttachComponentToSocket(UMSWeapon(Weapon).Mesh,ArmWeaponPoint);
}

simulated event vector GetPawnViewLocation()
{
	local vector sLoc,ViewLoc;
	local rotator ViewRot;
	local UMSWeapon w;
	local UMSPlayerController PC;
	w = UMSWeapon(Weapon);
	PC =  UMSPlayerController(Controller);
	if(PC.bUseTrueView)
	{
		SetWeaponVisibility(false);
		if(w.bISHidePawn)
			SetMeshVisibility(false);
		else
			SetMeshVisibility(true);
		if(w.bUsingIronSights)
		{				
			if(w.bUseISSocket)
			{
				w.GetISSocketInfo(sLoc,ViewRot,PC.bUseTrueView);
				ViewLoc = sLoc+w.IronSightViewOffset;
				//PC.Print("ViewLocX="$ViewLoc.X);
			}
			else // not use IS Socket but use true view
			{
				Mesh.GetSocketWorldLocationAndRotation(EyeSocket, sLoc);
				ViewLoc = sLoc+ EyeOffset+w.IronSightViewOffset;
			}
		}	
		else
		{		
			//PC.ClientMessage("bUseTrueView");
			Mesh.GetSocketWorldLocationAndRotation(EyeSocket, sLoc);	
			ViewLoc = sLoc + EyeOffset;	
		}
	}
	else 
	{
		//PC.ClientMessage("No Socket in GetPawnViewLocation, bUseISSocket");
		SetWeaponVisibility(true);
		SetMeshVisibility(false);
		if(w.bUseCameraSocket)
		{
			ArmsMesh[0].GetSocketWorldLocationAndRotation(w.CameraSocketName,ViewLoc);
		}
		else
		{
			ViewLoc=super.GetPawnViewLocation();
		}		
		//PC.Print("ArmMesh[0]="$ArmsMesh[0].Name);
	}
	return ViewLoc;
}


simulated event GetActorEyesViewPoint( out vector out_Location, out Rotator out_Rotation )
{
	out_Location = GetPawnViewLocation();
	out_Rotation = GetViewRotation();
}


simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	local bool bCameraCalc;
    
    // if we are the local player, make sure our head is normal size.
    // This will make it visible again in third person views and give us the correct bone positions later.
    // NOTE: A better way to do this is to make sure the head is a separate mesh/component and stop it being rendered to the owner.
    if (WorldInfo.NetMode != NM_DedicatedServer && IsHumanControlled() && IsLocallyControlled() && (HeadScale != 1.0f))
    {
        SetHeadScale(1.0f);

        // since we've just un-shrunk the head, force the skeleton to update, just in case
        Mesh.ForceSkelUpdate();
    }
    
    // Call the proper CalcCamera function and remember the result
    bCameraCalc = Super.CalcCamera(fDeltaTime, out_CamLoc, out_CamRot, out_FOV);
		GetActorEyesViewPoint(out_CamLoc, out_CamRot);

    // now that we've run the proper calcs, shrink the head again,
    // but only if we're the local player and in a first person view
    if (WorldInfo.NetMode != NM_DedicatedServer && IsHumanControlled() && IsLocallyControlled() && IsFirstPerson() && !bFixedView)
    {
        //SetHeadScale(0.0f);

        // force the skeleton to update, just in case
        Mesh.ForceSkelUpdate();
    }

    // send the result back to UTPlayerController::GetPlayerViewPoint()...
    return bCameraCalc;
}