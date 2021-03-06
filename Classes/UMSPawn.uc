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
var bool bHasHat;
var class<UTGib> HatGibClass;
var float HatGibImpulseRate;
var int HatDropDamage;
//var vector StoredHitLoc;
var vector StoredHitDir;
var float StoredHitImpulse;
var vector StoredHitNormal;
enum EHeadshotAction
{
	EHA_HeadDrop,
	EHA_HeadRocket,
	EHA_Spin,
	EHA_HeadBlow,
	EHA_None,
};

var EHeadshotAction CurrentHeadshotAction;

//var bool bDropHelmet;

replication
{	
	if ( bNetDirty )
		SecondaryWeaponClass, SecondaryWeaponAttachmentClass;
}

DefaultProperties
{
	EyeSocket=Eye
	BloodEmitterClass=class'UMSEmit_BloodSpray' //this is the blood emmitter class we created earlier
	bHasHat = true;
	HatGibClass = class'UMSGib_Helmet';
	HatGibImpulseRate = 300;
	HatDropDamage = 20;
	CurrentHeadshotAction = EHA_HeadDrop
}

//APHX: need head drop instead of head flying
/** spawn a special gib for this pawn's head and sets it as the ViewTarget for any players that were viewing this pawn */
simulated function SpawnHeadGib(class<UTDamageType> UTDamageType, vector HitLocation)
{
	local UTGib Gib;
	local UTPlayerController PC;
	local class<UDKEmitCameraEffect> CameraEffect;
	local vector ViewLocation;
	local rotator ViewRotation;
	local PlayerReplicationInfo OldRealViewTarget;
	local class<UTFamilyInfo> FamilyInfo;

	if ( class'UTGame'.Static.UseLowGore(WorldInfo) )
	{
		bHeadGibbed = true;
		return;
	}

	if (!bHeadGibbed)
	{
		FamilyInfo = CurrCharClassInfo;
		//spawn head gib
		switch(CurrentHeadshotAction)
		{
			case EHA_HeadDrop: 
				HeadGibDrop(HitLocation,StoredHitDir,200,false,Gib);		
				if(Gib!=none)
				{
					SetHeadScale(0.f);
					WorldInfo.MyEmitterPool.SpawnEmitter(FamilyInfo.default.HeadShotEffect, HitLocation, rotator(-StoredHitNormal), Gib);		
				}
				break;
			case EHA_HeadRocket:
				if ( HitLocation == Location )
				{
					HitLocation = Location + vector(Rotation);
				}						
				Gib = SpawnGib(CurrCharClassInfo.default.HeadGib.GibClass, FamilyInfo.default.HeadGib.BoneName, UTDamageType, HitLocation, true);
				if (Gib != None)
				{			
					Gib.SetRotation(Rotation);
					Gib.SetTexturesToBeResident( Gib.LifeSpan );	
					SetHeadScale(0.f);
					WorldInfo.MyEmitterPool.SpawnEmitter(FamilyInfo.default.HeadShotEffect, Gib.Location, rotator(vect(0,0,1)), Gib);						
				}
				break;
			case EHA_None:
				bHeadGibbed = true;
				return;
		}
		if(Gib!=none)
		{			
					
			foreach LocalPlayerControllers(class'UTPlayerController', PC)
			{
				if (PC.ViewTarget == self)
				{
					// save RealViewTarget for spectating so that this transition doesn't affect it
					OldRealViewTarget = PC.RealViewTarget;
					if (UTDamageType.default.bHeadGibCamera && (PC.UsingFirstPersonCamera() || !PC.IsInState('BaseSpectating')))
					{
						PC.SetViewTarget(Gib);

						CameraEffect = UTDamageType.static.GetDeathCameraEffectVictim(self);
						if (CameraEffect != None)
						{
							PC.ClientSpawnCameraEffect(CameraEffect);
						}
					}
					else
					{
						PC.GetPlayerViewPoint(ViewLocation, ViewRotation);
						PC.SetViewTarget(PC);
						PC.SetLocation(ViewLocation);
						PC.SetRotation(ViewRotation);
					}
					PC.RealViewTarget = OldRealViewTarget;
				}
			}
			bHeadGibbed = true;
		}
	}
}

function HeadGibDrop(vector sLoc,vector sDir, float speed, bool bSpinGib, optional out UTGib oGib)
{
	local UTGib Gib;
	local Rotator sRot;
	sRot = Rotator(sDir);
	Gib = Spawn(CurrCharClassInfo.default.HeadGib.GibClass, self,, sLoc, sRot);
	if ( Gib != None )
	{
		// add initial impulse
		//GetAxes(sRot, X, Y, Z);

		if (Gib.bUseUnrealPhysics)
		{
			Gib.Velocity = sDir*speed;
			Gib.SetPhysics(PHYS_Falling);
			Gib.RotationRate.Yaw = Rand(100000);
			Gib.RotationRate.Pitch = Rand(100000);
			Gib.RotationRate.Roll = Rand(100000);
		}
		else
		{
			Gib.Velocity = sDir*HatGibImpulseRate;
			Gib.GibMeshComp.WakeRigidBody();
			Gib.GibMeshComp.SetRBLinearVelocity(Gib.Velocity, false);
			if ( bSpinGib )
			{
				Gib.GibMeshComp.SetRBAngularVelocity(VRand() * 50, false);
			}
		}
		Gib.LifeSpan = Gib.LifeSpan + (2.0 * FRand());
		oGib = Gib;
	}
}

function bool IsHitHead(const out ImpactInfo Impact)
{
	local vector HeadLocation;
	local float Distance;

	if (HeadBone == '')
	{
		return False;
	}

	Mesh.ForceSkelUpdate();
	HeadLocation = Mesh.GetBoneLocation(HeadBone) + vect(0,0,1) * HeadHeight;

	// Find distance from head location to bullet vector
	Distance = PointDistToLine(HeadLocation, Impact.RayDir, Impact.HitLocation);

	return ( Distance < (HeadRadius * HeadScale) );
}

function SpawnHatGib(vector sLoc, vector sDir, bool bSpinGib )
{
	local UTGib Gib;
	local Rotator sRot;
	sRot = Rotator(sDir);
	Gib = Spawn(HatGibClass, self,, sLoc, sRot);

	if ( Gib != None )
	{
		// add initial impulse
		//GetAxes(sRot, X, Y, Z);

		if (Gib.bUseUnrealPhysics)
		{
			Gib.Velocity = sDir*HatGibImpulseRate;
			Gib.SetPhysics(PHYS_Falling);
			Gib.RotationRate.Yaw = Rand(100000);
			Gib.RotationRate.Pitch = Rand(100000);
			Gib.RotationRate.Roll = Rand(100000);
		}
		else
		{
			Gib.Velocity = sDir*HatGibImpulseRate;
			Gib.GibMeshComp.WakeRigidBody();
			Gib.GibMeshComp.SetRBLinearVelocity(Gib.Velocity, false);
			if ( bSpinGib )
			{
				Gib.GibMeshComp.SetRBAngularVelocity(VRand() * 50, false);
			}
		}
		Gib.LifeSpan = Gib.LifeSpan + (2.0 * FRand());
	}
}

function bool TakeHeadShot(const out ImpactInfo Impact, class<UTDamageType> HeadShotDamageType, int HeadDamage, controller InstigatingController)
{
	if(IsHitHead(Impact))
	{
		if (bHasHat&&HeadDamage>HatDropDamage&&HeadDamage<Health)
		{
			bHasHat = false;
			SpawnHatGib(Impact.HitLocation,Impact.RayDir,true);		
			UMSPlayerController(InstigatingController).Print("Hat Dropped");
		}
		StoredHitDir = Impact.RayDir;
		StoredHitNormal = Impact.HitNormal;
		//StoredHitImpulse = 400;
		TakeDamage(HeadDamage, InstigatingController, Impact.HitLocation, Impact.RayDir, HeadShotDamageType, Impact.HitInfo);		
		//UMSPlayerController(InstigatingController).Print("HeadShot");
		return true;
	}
	return false;
}

function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	//local UMSPlayerController umpc;
	//umpc = UMSPlayerController(Killer);
	if (Super.Died(Killer, DamageType, HitLocation))
	{
		//todo: let damageType handle the blodd decals
		LeaveBloodDecalOnGround(); 
		if(DamageType==class'UMSDmgType_Headshot')
		{
			UMSPlayerController(Killer).Print("HeadShot");
		}
		return true;
	}
	return false;
}

simulated function LeaveBloodDecalOnGround()
{
	//todo: use socket for decal location
	local MaterialInstanceTimeVarying MITV_Decal;
	
	local vector hitNorm;
	local vector hitLoc;
	local vector TraceDest;
	local vector TraceStart;
	local vector TraceExtent;
	local TraceHitInfo HitInfo;
	local actor TraceActor;
	
	TraceStart = Location;
	TraceDest =TraceStart + ( vect(0,0,-1) * 101 );
	TraceActor = Trace( hitLoc, hitNorm, TraceDest, TraceStart, false, TraceExtent, HitInfo, TRACEFLAG_PhysicsVolumes );
	MITV_Decal = new(Outer) class'MaterialInstanceTimeVarying';
	MITV_Decal.SetParent( GetFamilyInfo().default.BloodSplatterDecalMaterial );
	if(TraceActor!=none&&TraceActor.bWorldGeometry)
	{
		//PC.Print("Start Decal");
		WorldInfo.MyDecalManager.SpawnDecal(MITV_Decal, hitLoc, rotator(-hitNorm), 100, 100, 50, false);
		MITV_Decal.SetScalarStartTime( class'UTGib'.default.DecalDissolveParamName, class'UTGib'.default.DecalWaitTimeBeforeDissolve );		
	}
	
}

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