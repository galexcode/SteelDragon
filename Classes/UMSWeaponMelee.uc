class UMSWeaponMelee extends Actor abstract dependson(UTPawn);

var SkeletalMeshComponent Mesh;
var class<DamageType> MeleeDamageType;
var name AttachmentSocket;	//Socket on pawn. I'm lazy and won't create a pawn class 
var name AttackAnim;
var name StartTraceSocket, EndTraceSocket;
var EWeapAnimType WeapAnimType;
var Controller Controller;

simulated function AttachTo(UTPawn OwnerPawn)
{
	AttachComponent(Mesh);
	if (OwnerPawn.Mesh != None)
	{
		// Attach Weapon mesh to player skelmesh
		if ( Mesh != None )
		{
			Mesh.SetShadowParent(OwnerPawn.Mesh);
			Mesh.SetLightEnvironment(OwnerPawn.LightEnvironment);
		}
		//Mesh right?
		OwnerPawn.Mesh.AttachComponentToSocket(Mesh, AttachmentSocket);
		OwnerPawn.SetWeapAnimType(WeapAnimType);
	}
}

simulated function DetachFrom( SkeletalMeshComponent MeshCpnt )
{
	DetachComponent( Mesh );
	// Weapon Mesh Shadow
	if ( Mesh != None )
	{
		Mesh.SetShadowParent(None);
		Mesh.SetLightEnvironment(None);
	}
	if ( MeshCpnt != None )
	{
		// detach weapon mesh from player skelmesh
		if ( Mesh != None )
		{
			MeshCpnt.DetachComponent( mesh );
		}
	}
	SetBase(none);
	Mesh.SetLightEnvironment(None);
}


simulated event Tick(float DeltaTime)
{
	if(UMSPlayerController(Controller).bMeleeMode)
	{
		TraceHit();
	}
	super.Tick(DeltaTime);
}

simulated event EncroachedBy (Actor Other)
{
	if(Other!=Controller.Pawn)
	{
		UTPlayerController(Controller).ClientMessage("EncroachedBy");
		UTPlayerController(Controller).ClientMessage("Other:"$Other.class);
	}
}

simulated event bool EncroachingOn (Actor Other)
{
	if(Other!=Controller.Pawn)
	{
		UTPlayerController(Controller).ClientMessage("EncroachedOn");
		UTPlayerController(Controller).ClientMessage("Other:"$Other.class);
		return true;
	}
	else
		return false;
}

simulated event Bump(Actor Other, PrimitiveComponent OtherComp, Vector HitNormal)
{
	if(Other!=Controller.Pawn)
	{
		UTPlayerController(Controller).ClientMessage("Hit via Bump");
		UTPlayerController(Controller).ClientMessage("Hit:"$Other.class);
	}	
}

simulated event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	UTPlayerController(Controller).ClientMessage("Hit via Touch");
	UTPlayerController(Controller).ClientMessage("Hit:"$Other.class);
}

simulated function TraceHit()
{
	local vector			StartTrace, EndTrace;
	local vector            HitLocation, HitNormal;
	local Rotator           Temp;

	local actor             HitActor;

	// EndSocket StartSocket
	Mesh.GetSocketWorldLocationAndRotation(StartTraceSocket, StartTrace, Temp);
	Mesh.GetSocketWorldLocationAndRotation(EndTraceSocket, EndTrace, Temp);

//`endif
	HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
	if(HitActor!=none&&HitActor!=Controller.Pawn)
	{
		UTPlayerController(Controller).ClientMessage("Hit via Trace");
		UTPlayerController(Controller).ClientMessage("Hit Location:"$HitLocation);
		UTPlayerController(Controller).ClientMessage("Hit Actor:"$HitActor.class);
	}
	
}

defaultproperties
{
	AttachmentSocket = "DualWeaponPoint"
	StartTraceSocket = "StartControl"
	EndTraceSocket="EndControl"
	WeapAnimType = EWAT_Default
	Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent0
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=FALSE
		CastShadow=true
		bCastDynamicShadow=true
		bPerBoneMotionBlur=true
		
		BlockRigidBody=true
		BlockZeroExtent=true
		CollideActors=true
	End Object
	Mesh=SkeletalMeshComponent0
	bCollideActors=true
	CollisionType=COLLIDE_BlockAll
	
}
