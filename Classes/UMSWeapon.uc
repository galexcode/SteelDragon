//Based on FFWeapon, modified by aphx

class UMSWeapon extends UTWeapon config (UMSWeapon)
        /*native
	nativereplication
	dependson(UTPlayerController)
	config(UTWeapon)   */
	abstract;

/*************************************************************************
 *************************************************************************/

var int ClipCount;
var(Reload) float ReloadInterval;       
var(Reload) float EmptyReloadInterval; 
var(Run) float RunStartInterval;
var(Run) float RunEndInterval;

var bool bSecondary;
var bool bIsSpreading;
var bool bReloadable;          
var bool bIsReloading;        
var bool bReloadReleased;
var bool bIsFlashlightOn;     
var bool bHasIronSights;      
var bool bUsingIronSights;    
var bool bPrimaryWeapon;
var bool bWeaponPuttingDown;
var bool bExitISAfterShots;
var bool bIsSwitchingMode;
//var bool bChangeISLoc;
var() bool bUseCameraSocket;

var() name CameraSocketName;

var class<UTDamageType> HeadShotDamageType;
var float HeadShotDamageMult;

//IronSight
var(IronSights) bool bUseISSocket;
var(IronSights) vector	IronSightViewOffset;
var(IronSights) float IronSightBobDamping;
var(IronSights) float IronSightGroundSpeedFactor;
var(IronSights) float IronSightStartInterval;
var(IronSights) float IronSightEndInterval;
var(IronSights) name ISSocketName;
var(IronSights) bool bISHidePawn;
var bool bPlayingISStart;
//EWeaponHand ISWeaponHand;
//var vector ISSocketLoc;
/*
var float fChangeAimTime;
var float TimeToChangeAim;
*/
//var bool bDrawISWeapon;

//Switch Fire Mode
var(SwitchMode) float SwitchModeInterval;
var int CurrentFireModeNum; 
var int MaxFireModeNum; 
var int ShotsFired;
var array<name> FireModeNames;

//Recoil
var(Recoil) Array<int> RecoilAmount;
var(Recoil) Array<float> IronsightRecoilFactor;
var(Recoil) Array<float> StayRecoilFactor;
var(Recoil) Array<float> SpreadPerFire, FireSpreadCheckTime;

var(Spread) Array<float> MaxSpread;
var(Run) float SpreadPerRun, RunSpreadCheckTime;

//Animations
var(Animations) name WeaponSwitchModeAnim;
var(Animations) name WeaponISStartAnim;
var(Animations) name WeaponISIdleAnim;
var(Animations) name WeaponISEndAnim;


var(Animations) name	WeaponReloadAnim;
var(Animations) name	WeaponReloadEmptyAnim;

var(Animations) name	WeaponRunStartAnim;
var(Animations) name	WeaponRunIdleAnim;
var(Animations) name	WeaponRunEndAnim;

var(Animations) name    WeaponFlashLightAnim;


//Reload Camera Anims
var CameraAnim ReloadCameraAnim;
var CameraAnim ReloadEmptyCameraAnim;

//Sounds
var SoundCue ReloadSound;
var SoundCue ReloadEmptySound;
var SoundCue FlashLightSwitchSnd;

//Brass
var(Brass) class<Brass>		    BrassClass;
var(Brass) name					EjectorSocket;
var(Brass) Vector				BrassStartOffset;
var(Brass) Vector				BrassVelocity;
var(Brass) bool					bEjectBrassOnFire;
var(Brass) float					BrassForegroundTime;
var(Brass)  bool		            bEjectBrass;

//Spread Reduce
var(Spread) float CrouchReducedSpread;
var(Spread) float StayReducedSpread;
var(Spread) float ISReducedSpread;

//Crosshair
var float IronsightCrosshairScalingFactor;
var float SpreadCrosshairScalingFactor;
var float MaxSpreadCrosshairScaling;
var float MaxCrosshairScaling;


simulated function ProcessInstantHit(byte FiringMode, ImpactInfo Impact, optional int NumHits)
{
	local int HeadDamage;
	if( (Role == Role_Authority) && !bUsingAimingHelp )
	{
		HeadDamage = InstantHitDamage[FiringMode]* HeadShotDamageMult;
		if ( (UMSPawn(Impact.HitActor) != None && UMSPawn(Impact.HitActor).TakeHeadShot(Impact, HeadShotDamageType, HeadDamage, Instigator.Controller)) ||
			(UTVehicle(Impact.HitActor) != None) )
		{
			SetFlashLocation(Impact.HitLocation);
			return;
		}
	}
	super.ProcessInstantHit( FiringMode, Impact, NumHits);
}

simulated function TimeWeaponEquipping()
{
	// The weapon is equipped, attach it to the mesh.
	if(bSecondary)
	{
		AttachSecondaryWeaponTo(Instigator.Mesh);
	}
	else
		AttachWeaponTo( Instigator.Mesh );

	// Play the animation
	PlayWeaponEquip();

	SetTimer( GetEquipTime() , false, 'WeaponEquipped');
}

//aphx: only work in TFPS
simulated function AttachSecondaryWeaponTo( SkeletalMeshComponent MeshCpnt, optional Name SocketName )
{
	local UMSPawn UTP;

	UTP = UMSPawn(Instigator);
	// Attach 1st Person Muzzle Flashes, etc,
	if ( Instigator.IsFirstPerson() )
	{
		AttachComponent(Mesh);
		EnsureWeaponOverlayComponentLast();
		SetHidden(True);
		bPendingShow = TRUE;
		Mesh.SetLightEnvironment(UTP.LightEnvironment);
		if (GetHand() == HAND_Hidden)
		{
			UTP.ArmsMesh[0].SetHidden(true);
			UTP.ArmsMesh[1].SetHidden(true);
		}
	}
	else
	{
		SetHidden(True);
		if (UTP != None)
		{
			Mesh.SetLightEnvironment(UTP.LightEnvironment);
			UTP.ArmsMesh[0].SetHidden(true);
			UTP.ArmsMesh[1].SetHidden(true);
		}
	}

	SetWeaponOverlayFlags(UTP);

	// Spawn the 3rd Person Attachment
	if (Role == ROLE_Authority && UTP != None)
	{
		UTP.SecondaryWeaponAttachmentClass = class<UMSWeaponAttachment>(AttachmentClass);
		if (WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_Standalone || (WorldInfo.NetMode == NM_Client && Instigator.IsLocallyControlled()))
		{
			UTP.SecondaryWeaponAttachmentChanged();
		}
	}

	SetSkin(UTPawn(Instigator).ReplicatedBodyMaterial);
}

simulated function StartFire(byte FireModeNum)
{
	local UMSPlayerController PC;
	local UMSPawn p;
	p = UMSPawn(Instigator);
	PC = UMSPlayerController(p.Controller);
	if(bSecondary)
	{
		p.bFireSecondary = true;
		PC.Print("Start Secondary Fire: "$p.bFireSecondary);
	}
	else
	{
		p.bFireSecondary = false;
	}
	super.StartFire(FireModeNum);
}

simulated function PlayWeaponAnimation( Name Sequence, float fDesiredDuration, optional bool bLoop, optional SkeletalMeshComponent SkelMesh)
{
	local SkeletalMeshComponent skelMeshCp;
	local UMSPlayerController PC;
	PC = UMSPlayerController(Instigator.Controller);
	if(PC.bUseTrueView)
	{
		if(bSecondary)
		 	skelMeshCp = UMSPawn(Instigator).SecondaryWeaponAttachment.Mesh;
		else
			skelMeshCp = UMSPawn(Instigator).CurrentWeaponAttachment.Mesh;
		`Log(skelMeshCp);
	}	
	else
		skelMeshCp = SkelMesh;
	super.PlayWeaponAnimation(Sequence, fDesiredDuration, bLoop, skelMeshCp);
}

simulated function Rotator GetAdjustedAim (Vector StartFireLoc)
{
	local SkeletalMeshComponent skelMeshCp;
	local vector sLoc;
	local rotator sRot;
	if(bUsingIronSights)
	{
		skelMeshCp = UMSPawn(Instigator).CurrentWeaponAttachment.Mesh;
		skelMeshCp.GetSocketWorldLocationAndRotation(MuzzleFlashSocket,sLoc,sRot);
		return sRot;
	}
	else
		//APHX: Dual mode uses the same aim as usual
		return super.GetAdjustedAim(StartFireLoc);
}

simulated function AttachMuzzleFlash()
{
	local SkeletalMeshComponent SKMesh;
	if(UMSPlayerController(Instigator.Controller).bUseTrueView)
	{
		bMuzzleFlashAttached = true;
		if(bSecondary)
		{
			SKMesh = UMSPawn(Instigator).SecondaryWeaponAttachment.Mesh;
		}
		else
			SKMesh = UMSPawn(Instigator).CurrentWeaponAttachment.Mesh;
		if (  SKMesh != none )
		{
			if ( (MuzzleFlashPSCTemplate != none) || (MuzzleFlashAltPSCTemplate != none) )
			{
				MuzzleFlashPSC = new(Outer) class'UTParticleSystemComponent';
				MuzzleFlashPSC.bAutoActivate = false;
				MuzzleFlashPSC.SetDepthPriorityGroup(SDPG_Foreground);
				MuzzleFlashPSC.SetFOV(UDKSkeletalMeshComponent(SKMesh).FOV);
				SKMesh.AttachComponentToSocket(MuzzleFlashPSC, MuzzleFlashSocket);
			}
		}
	}
	else
	{
		super.AttachMuzzleFlash();
	}
	// Attach the Muzzle Flash
	
}

/*************************************************************************
 * Set Brass *    ÉèÖÃµ¯¿Ç 
 *************************************************************************/
simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
{
	/*
	if ( FireModeNum < WeaponFireAnim.Length && WeaponFireAnim[FireModeNum] != '' )
		PlayWeaponAnimation( WeaponFireAnim[FireModeNum], GetFireInterval(FireModeNum) );
	if ( FireModeNum < ArmFireAnim.Length && ArmFireAnim[FireModeNum] != '' && ArmsAnimSet != none)
		PlayArmAnimatiown( ArmFireAnim[FireModeNum], GetFireInterval(FireModeNum) );

	CauseMuzzleFlash();
	*/

	ShakeView();

	if (bEjectBrassOnFire)
		EjectBrass();
}


simulated function EjectBrass()
{
	local Brass	Shell;
	local vector	X, Y, Z, StartLoc;
	local Rotator	StartRot;
	local UMSPlayerController PC;
	local SkeletalMeshComponent skelMeshCp;

	PC = UMSPlayerController(Instigator.Controller);
	if (!bEjectBrass || !Instigator.IsFirstPerson())
		return;
	if (Worldinfo.TimeSeconds - LastRenderTime > 0.15 || WorldInfo.GetDetailMode() == DM_Low)
		return;


	if (BrassClass != None)
	{
		
		if(PC.bUseTrueView)
		{
			if(bSecondary)
		 		skelMeshCp = UMSPawn(Instigator).SecondaryWeaponAttachment.Mesh;
			else
				skelMeshCp = UMSPawn(Instigator).CurrentWeaponAttachment.Mesh;
		}	
		else
		{
			skelMeshCp = SkeletalMeshComponent(Mesh);
		}
		//SkeletalMeshComponent(Mesh).GetSocketWorldLocationAndRotation(EjectorSocket, StartLoc, StartRot);
		skelMeshCp.GetSocketWorldLocationAndRotation(EjectorSocket, StartLoc, StartRot);

		GetAxes(StartRot, X, Y, Z);
		Shell = Spawn(BrassClass,,, StartLoc + X * BrassStartOffset.X + Y * BrassStartOffset.Y + Z * BrassStartOffset.Z, StartRot);
		if (Shell != None)
		{
			Shell.Velocity = Instigator.Velocity + X * BrassVelocity.X + Y * BrassVelocity.Y + Z * BrassVelocity.Z;
			Shell.AngularVelocity1 = VRand() * 125;
			Shell.StartBrass(BrassForegroundTime);
		}
	}

}

/*************************************************************************
 * LOCAL FUNCTIONS Section
 *************************************************************************/


replication
{
    if (bNetOwner)
        ClipCount;
        
    if (bNetOwner && bNetDirty)
       bReloadReleased;
}

simulated function bool HasAmmo( byte FireModeNum, optional int Amount )
{
    return true;
}

simulated function bool HasAnyAmmo()
{
    if (bReloadable)
        return ( ( AmmoCount > 0 ) || (ClipCount > 0) );
    else
        return (AmmoCount > 0);
}

simulated function WeaponEmpty()
{       /*      udkÓÐÐ©°æ±¾»á±¨´í
	if (bDebugWeapon)
	{
		LogInternal("---"@self$"."$GetStateName()$".WeaponEmpty()"@IsFiring()@Instigator@Instigator.IsLocallyControlled());
		ScriptTrace();
	}*/
	if ( IsFiring() )
	{
        GotoState('Active');
	}
}

simulated function bool CanThrow()
{
	if (!IsInState('WeaponEquipping'))
           return bCanThrow;
}

simulated function SwitchFireMode()
{
	if(bIsSwitchingMode==false&&bIsReloading==false&&bWeaponPuttingDown==false)
	{
		`Log("Go to Switch Mode");
		PlayWeaponAnimation(WeaponSwitchModeAnim,SwitchModeInterval);
		GoToState('WeaponSwitchMode');
	}
}

simulated function GetISSocketInfo(out vector sloc, out rotator srot, optional bool bUseTrueView=false)
{
	//local UMSPLayerController PC;
	local SkeletalMeshComponent skelMeshCp;
	//PC = UMSPLayerController(Instigator.Controller);
	//PC.ClientMessage("Now we get IS info");
	if(bUseTrueView)
	{
		skelMeshCp = UMSPawn(Instigator).CurrentWeaponAttachment.Mesh;
	}	
	else
		skelMeshCp = SkeletalMeshComponent(Mesh);
	skelMeshCp.GetSocketWorldLocationAndRotation(ISSocketName,sloc,srot);
	//PC.Print("slocX="$sloc.x);
}

simulated exec function ToggleIronSights()
{
	if (GetZoomedState()==ZST_NotZoomed && bHasIronSights && PlayerViewOffset.Y >= default.PlayerViewOffset.Y)
    {
		EnterIronSights();
            //OnAnimEnd();
    }
	else if(bUsingIronSights)
	{
		ExitIronSights();
	}
}

simulated exec function ExitIronSights()
{   
    local UTPlayerController PC;
	PC = UTPlayerController(Instigator.Controller);
	UMSPawn(Instigator).SetMeshVisibility(true);
	PlayWeaponAnimation(WeaponISEndAnim,IronSightEndInterval);
	//PC.DesiredFOV =default.FOV;                                     //³õÊ¼×´Ì¬µÄ½¹¾à£¨fov£©(²»Í¬µÄ°æ±¾ÓÎÏ·ÖÐÐ§¹û»á²»Í¬£¬×ÔÐÐÉèÖÃ£©
    EndZoom(PC);
	PlayerViewOffset.Y = default.PlayerViewOffset.Y;
    PlayerViewOffset.Z = default.PlayerViewOffset.Z;
    PlayerViewOffset.X = default.PlayerViewOffset.X;

    bUsingIronSights = False;
    WeaponIdleAnims[0] = 'WeaponIdle';
                                                              //³õÊ¼×´Ì¬µÄ³ÖÇ¹¶¯»­
	//PC.WeaponHand = PC.default.WeaponHand;														  
    BobDamping = default.BobDamping;
	//fChangeAimTime = 0;

    UTPawn(Owner).GroundSpeed = UTPawn(Owner).default.GroundSpeed;
}

simulated exec function EnterIronSights()
{
	local UTPlayerController PC;   
	PC = UTPlayerController(Instigator.Controller);
	PlayWeaponAnimation(WeaponISStartAnim,IronSightStartInterval);
    ZoomedFireModeNum = CurrentFireMode;
	StartZoom(PC);
	WeaponIdleAnims[0] = WeaponISIdleAnim; 
	bUsingIronSights = True;
	//PC.ClientMessage("bUsingIronSights="$bUsingIronSights);
	//PC.ClientMessage("bUseISSocket="$bUseISSocket);
	if(bISHidePawn)
	{
		UMSPawn(Instigator).SetMeshVisibility(false);
	}
	if(!bUseISSocket)
	{
		//PC.ClientMessage("Use PVOffset");
		PlayerViewOffset.Y = IronSightViewOffset.Y;
		PlayerViewOffset.Z = IronSightViewOffset.Z;
		PlayerViewOffset.X = IronSightViewOffset.X;
	}
	//PC.WeaponHand = ISWeaponHand;
	BobDamping = IronSightBobDamping;                             //Ç¹µÄ°Ú¶¯£¬ÖµÔ½´ó°Ú¶¯Ô½Ð¡
	UTPawn(Owner).GroundSpeed *= IronSightGroundSpeedFactor;          //Ãé×¼Ê±ÅÜ¶¯µÄËÙ¶È
}

simulated function WeaponRunning()             //Ã»ÓÐ¸ãÃ÷°×
{
    local UTPlayerController PC;
    local UTPawn UTP;

    UTP = UTPawn(Owner);
    PC = UTPlayerController(Instigator.Controller);
    if (PC.bRun != 0 && WeaponIdleAnims[0] == 'WeaponIdle' && !UTP.bIsCrouched &&
        RunStartInterval != 0 && bWeaponPuttingDown == False)
    {
        WeaponIdleAnims[0] = 'WeaponRunIdle';
        if (!bIsReloading)
        {
            PlayWeaponAnimation( WeaponRunStartAnim, RunStartInterval );
        }
    }

    if (PC.bRun == 0 && WeaponIdleAnims[0] == 'WeaponRunIdle' && !UTP.bIsCrouched ||
        UTP.bIsCrouched && WeaponIdleAnims[0] == 'WeaponRunIdle')
    {
        WeaponIdleAnims[0] = 'WeaponIdle';
        if (!bIsReloading)
        {
            PlayWeaponAnimation( WeaponRunEndAnim, RunEndInterval );
        }
    }
}

/*********************************************************************************************
 * Recoil
 *********************************************************************************************/

simulated function Recoil(byte FireModeNum)                           //ÉèÖÃºó×øÁ¦
{
    local rotator viewRotation;
    local vector X,Y,Z;
	local int currRecoilAmount;
	
	currRecoilAmount = RecoilAmount[FireModeNum];

    GetAxes(Instigator.Rotation,X,Y,Z);
    viewRotation = Instigator.GetViewRotation();

    if (bUsingIronsights)
        currRecoilAmount = currRecoilAmount * IronsightRecoilFactor[FireModeNum];

    if (UTPawn(Owner).Velocity.X + UTPawn(Owner).Velocity.Y  == 0)
        currRecoilAmount = currRecoilAmount * StayRecoilFactor[FireModeNum];

    viewRotation.Pitch += currRecoilAmount;
    UTPlayerController(Instigator.Controller).SetRotation(ViewRotation);
	//RecoilAmount = default.RecoilAmount;
	
	//Spread with recoil
	if(IsTimerActive('AcculateRecoilSpread'))
	{
		Spread[FireModeNum] += SpreadPerFire[FireModeNum];
		if(Spread[FireModeNum] > MaxSpread[FireModeNum])
		{
			ClearTimer('AcculateRecoilSpread');
			Spread[FireModeNum] = default.Spread[FireModeNum];
			bIsSpreading=false;
		}
		else{
			bIsSpreading=true;}  //if sth. goes wrong
	}
	else
	{
		Spread[FireModeNum] = default.Spread[FireModeNum];
		SetTimer(FireSpreadCheckTime[FireModeNum],false,'AcculateRecoilSpread');
		bIsSpreading=true;
		//pc.ClientMessage("Spread Begins");
	}
}

simulated function ProcessFireMode()
{
	//local UMSPlayerController pc;
	//pc = UMSPlayerController(Instigator.Controller);	
	ShotsFired++;  //warning: maybe casue memory leak
	if(ShotsFired>3)
	{
		ShotsFired= 0;
	}
	Switch(CurrentFireModeNum)
	{
		Case 1:
			//PC.Print("FireMode: Auto");
			Break;
		Case 0:
			//PC.Print("FireMode: Burst");
			if(ShotsFired ==3)
			{
				StopFire(0);
				ServerStopFire(0);
			}
			Break;
		Case 2:
			//PC.Print("FireMode: Semi");
			StopFire(0);
			ServerStopFire(0);
			Break;
	}
}

simulated function FireAmmunition()
{
	//local UMSPlayerController pc;
	//pc = UMSPlayerController(Instigator.Controller);
  if (ClipCount > 0)
      Recoil(CurrentFireMode);
			
	ProcessFireMode();
  super.FireAmmunition();
}
 
/*********************************************************************************************
 * Reloading
 *********************************************************************************************/

simulated function bool CanReload()
{
    if( IsFiring() || bIsSwitchingMode||
    bIsReloading || ClipCount >= Default.ClipCount ||
    AmmoCount == 0 || bWeaponPuttingDown == True  )
    {
        return false;
    }

    if (bReloadable)
    {
        return true;
    }
}

simulated exec function ReloadWeapon()
{
    if( CanReload() )
    {
        ServerReloadWeapon();
        //GotoState( 'Reloading' );
    }
}

reliable server function ServerReloadWeapon()
{
	if(bUsingIronSights)
	{
		ExitIronSights();
	}
    GotoState('Reloading');
}

simulated exec function EndReloadWeapon()
{
      ServerEndReloadWeapon();
}

reliable server function ServerEndReloadWeapon()
{
   if (!bReloadReleased)
      bReloadReleased = True;
}

function ConsumeAmmo( byte FireModeNum )
{
    if (ClipCount < default.ClipCount && bReloadable && bIsReloading)
    {
        ShotCost[FireModeNum] = default.ClipCount - ClipCount;
        AddAmmo(-ShotCost[FireModeNum]);
        ShotCost[FireModeNum] = 0;
    }

    if (!bReloadable)
        AddAmmo(-ShotCost[FireModeNum]);

    if (ClipCount > 0 && bReloadable && !bIsReloading)
    {
        ClipCount--;
    }
   if(ClipCount==0&&AmmoCount>0)          //ÉèÖÃ×Ô¶¯»»µ¯¼Ð
    {
      ExitIronSights();
            //bExitISAfterShots = false;
      ServerReloadWeapon();
      GotoState('Reloading');

    }
}

simulated function PutDownWeapon()
{
    if (bIsReloading || bUsingIronSights||bIsSwitchingMode)
	{
        return;
    }
    else
    {
        GotoState('WeaponPuttingDown');
    }
}

simulated function bool ShouldRefire()
{
    if(ClipCount == 0 || UTPawn(Owner).bIsWalking == False)
	{
	    WeaponPlaySound( FlashLightSwitchSnd, 1.0 );
        return false;
    }

	return StillFiring( CurrentFireMode );
} 

/*************************************************************************
 * WeaponFiring
 *************************************************************************/
simulated state WeaponFiring
{
	simulated function EndState(Name NextStateName)
	{
        if (UTPawn(Owner) != none)
        {
            UTPawn(Owner).Groundspeed *= 1;    //0.8
            Spread[CurrentFireMode] = default.Spread[CurrentFireMode];
        }

        super.EndState(NextStateName);
	}

	simulated function BeginState(Name PrevStateName)
	{
	    if (UTPawn(Owner) != none)
        {
            UTPawn(Owner).Groundspeed /= 1;     //0.8

            if (UTPawn(Owner).bIsCrouched)
                Spread[CurrentFireMode] -= CrouchReducedSpread;

            if (UTPawn(Owner).Velocity.X + UTPawn(Owner).Velocity.Y  == 0)
                Spread[CurrentFireMode] -= StayReducedSpread;

            if (bUsingIronSights)
               Spread[CurrentFireMode] -= ISReducedSpread;
        }
		Super.BeginState(PrevStateName);
	}

	simulated function BeginFire( Byte FireModeNum )
	{
		if ( CheckZoom(FireModeNum) )
		{
			return;
		}

		Global.BeginFire(FireModeNum);

		if( !HasAnyAmmo() )
		{
			WeaponEmpty();
			return;
		}
	}

    simulated function EndFire( Byte FireModeNum )
    {
        if (FireModeNum == 1 && bUsingIronSights)
        {
            bExitISAfterShots = true;
        }

        Super.EndFire(FireModeNum);
    }
}

/*************************************************************************
 * WeaponEquipping
 *************************************************************************/
simulated state WeaponEquipping
{
	simulated function BeginState(Name PreviousStateName)
	{
	  if (bIsFlashLightOn)
	   {
             SetTimer(2.0, false);
           }

        super.BeginState(PreviousStateName);
        }
}

/*************************************************************************
 * WeaponPuttingDown
 *************************************************************************/
simulated state WeaponPuttingDown
{
     simulated event BeginState(Name PreviousStateName)
     {
        bWeaponPuttingDown = True;
        SetTimer(2.0, false);
        super.BeginState(PreviousStateName);
     }

    simulated event EndState(Name NextStateName)
	{
	   bWeaponPuttingDown = False;
	   super.EndState(NextStateName);
    }
}


/*********************************************************************************************
 * Switching Fire Mode
 *********************************************************************************************/
simulated state WeaponSwitchMode
{
   simulated event BeginState(Name PreviousStateName)
   {
			local UMSPlayerController PC;
      PC = UMSPlayerController(Instigator.Controller);
			bIsSwitchingMode = True;
			PC.ClientMessage("Start Switching");
			if(bIsSwitchingMode&&bUsingIronSights)
			{
				ExitIronSights();
			}
			PlayWeaponAnimation(WeaponSwitchModeAnim,SwitchModeInterval);
			CurrentFireModeNum=CurrentFireModeNum++;
			if(CurrentFireModeNum>MaxFireModeNum)
			{
				CurrentFireModeNum=0;
			}
			PC.Print("Fire Mode: "$FireModeNames[CurrentFireModeNum]);
			GoToState(PreviousStateName);
		 //super.BeginState(PreviousStateName);
     }

    simulated event EndState(Name NextStateName)
	{
	   bIsSwitchingMode = False;
	   //super.EndState(NextStateName);
    }

}
 
/*************************************************************************
 * Active
 *************************************************************************/
simulated state Active
{
    simulated function BeginState(Name PreviousStateName)
    {
        if (bExitISAfterShots)
        {
            ExitIronSights();
           // OnAnimEnd();
            bExitISAfterShots = false;
        }
        Super.BeginState(PreviousStateName);
    }

    simulated function BeginFire( Byte FireModeNum )
	{
		if (ClipCount == 0)
		{
          return;
		}
		if (ClipCount > 0)
		{
		Super.BeginFire(FireModeNum);
		}	
		
      
        if ((bReloadable && ClipCount == 0)
             || UTPawn(Owner).bIsWalking == False ||
            (!bReloadable && AmmoCount == 0))
	    {
            if (FireModeNum == 0 && UTPawn(Owner).bIsWalking == True && !bIsReloading)
            {
                WeaponPlaySound( FlashLightSwitchSnd, 1.0 );
            }
            return;
        }
        else
  		{
            Super.BeginFire( FireModeNum );
	    }
    }

    simulated function bool ShouldLagRot()
	{
		if (!bUsingIronsights)
		{
            return true;
        }
	    return false;
        }

    simulated function EndFire( Byte FireModeNum )
    {
       

        Super.EndFire(FireModeNum);
    }
}


/*************************************************************************
 * Reloading
 *************************************************************************/
simulated state Reloading
{
	simulated function BeginReload()
	{
	   local UTPlayerController PC;
	   local int AmmoLeft;
        
        PC = UTPlayerController(Instigator.Controller);
		//PC.ClientMessage("Start Reloading");
        
        if ( Pawn(Owner) == None )
            return;

        bIsReloading = true;
        bHasIronSights = false;
		

        AmmoLeft = AmmoCount;
        ConsumeAmmo(CurrentFireMode);

        if (ClipCount > 0 || EmptyReloadInterval == 0)
        {
            WeaponPlaySound( ReloadSound, 1.0 );
            PlayWeaponAnimation( WeaponReloadAnim, ReloadInterval );
            PC.PlayCameraAnim( ReloadCameraAnim );
        }
        
        if (ClipCount == 0 && EmptyReloadInterval > 0)
        {
            ReloadInterval = EmptyReloadInterval;
            WeaponPlaySound( ReloadEmptySound, 1.0 );
            PlayWeaponAnimation( WeaponReloadEmptyAnim, ReloadInterval );
            PC.PlayCameraAnim( ReloadEmptyCameraAnim );
        }

        if(AmmoCount < default.ClipCount - ClipCount)
        {
            ClipCount = ClipCount + AmmoLeft;
        }
        if(AmmoCount >= default.ClipCount - ClipCount)
        {
            ClipCount = Default.ClipCount;
        }
    }

    simulated function EndReload()
	{
		bIsReloading = false;
		bHasIronSights = default.bHasIronsights;
                ReloadInterval = default.ReloadInterval;
                GotoState( 'Active' );
	}

Begin:
	BeginReload();
	Sleep( ReloadInterval );
	EndReload();
}



/*************************************************************************
 * Ammo HUD *  µ¯Ò©µÄHUD
 *************************************************************************/

simulated function ActiveRenderOverlays( HUD H )      //ÏÔÊ¾×Óµ¯ÊýºÍÐ¯µ¯Á¿
{
	local float X, Y;
   X = (H.Canvas.SizeX/2);
   Y = (H.Canvas.SizeY * 0.825);
   H.Canvas.SetDrawColor(71, 233, 63, 255);
   H.Canvas.Font = class'UTHUD'.static.GetFontSizeIndex(1);
   H.Canvas.SetPos(X, Y);
   H.Canvas.DrawText("Ammo:"$ClipCount@"ReserveAmmo:"@AmmoCount@" ");
	Super.ActiveRenderOverlays(H);

   if(bUsingIronSights == True)    //ÉèÖÃÃé×¼Í¼±êÔÚ²»Í¬Ãé×¼×´Ì¬Ê±µÄÏÔÊ¾,ÔÚ×ÔÐÐÉèÖÃÎäÆ÷Î»ÖÃÊ±£¬×îºÃÆÁ±Îµô
   {
		CrosshairScaling-=IronsightCrosshairScalingFactor ;
		if(CrosshairScaling<=0.4)
		{
			CrosshairImage=Texture2D'UI_HUD.HUD.UTCrossHairs';
			CrosshairScaling=0;
		}
    }
    else
    {
      CrosshairImage=Texture2D'UI_HUD.HUD.UTCrossHairs' ;
      CrosshairScaling=0.8 ;
    }
	
	if(bIsSpreading)
	{
		CrosshairImage=Texture2D'UI_HUD.HUD.UTCrossHairs';
		CrosshairScaling += SpreadCrosshairScalingFactor;
		if(CrosshairScaling>MaxCrosshairScaling)
		{
			CrosshairScaling = MaxCrosshairScaling;
		}
	}

   if (bIsReloading)
   {
      H.Canvas.DrawText("Reloading...");
      CrosshairImage=Texture2D'UI_HUD.HUD.UTCrossHairs';
      CrosshairScaling=0;
   }
}

/*************************************************************************
 * DEFAULTPROPERTIES Section
 *************************************************************************/

defaultproperties
{
    bEjectBrass=True
    EjectorSocket="Ejector"            //ÍËµ¯¿ÇµÄ²å²ÛÃû³Æ
    bReloadable=True
    bHasIronSights=True
		
	MuzzleFlashSocket = "MuzzleFlashSocket"
	
	HeadShotDamageType=class'UMSDmgType_Headshot'
	HeadShotDamageMult=2.0
	
	MaxFireModeNum = 2;
	FireModeNames(0)="Burst"
	FireModeNames(1)="Auto"
	FireModeNames(2)="Semi"
	
	CrouchReducedSpread=0.02
	StayReducedSpread=0.02
	ISReducedSpread=0.04
    
    CrosshairImage=Texture2D'UI_HUD.HUD.UTCrossHairs'
	CrossHairCoordinates=(U=128,V=0,UL=64,VL=64)  //(U=192,V=64,UL=64,VL=64)
	IconCoordinates=(U=600,V=341,UL=111,VL=58)
	CrosshairScaling=0.8
	IronsightCrosshairScalingFactor=0.20
	SpreadCrosshairScalingFactor=0.1
	MaxCrosshairScaling=1.2
	
	bPendingShow = false

	WeaponSwitchModeAnim = "WeaponReload"  //Switch Fire Mode Anim
    WeaponReloadAnim="WeaponReload" // ÉèÖÃ»»µ¯¼ÐµÄ¶¯»­Ãû
    WeaponReloadEmptyAnim="WeaponReloadAndCock" // ÉèÖÃ»»µ¯¼ÐÀ­Ë¨µÄ¶¯»­Ãû
    WeaponRunStartAnim="WeaponRunStart" // àíèìàöèÿ íà÷àëà ñïðèíòà
    WeaponRunIdleAnim="WeaponRunIdle" // àíèìàöèÿ ñïðèíòà(îæèäàíèå)
    WeaponRunEndAnim="WeaponRunEnd" // àíèìàöèÿ îêîí÷àíèÿ ñïðèíòà
	WeaponISIdleAnim="WeaponIronSight_Idle" //Ironsight Idle Anim
	WeaponISStartAnim="WeaponReload"
	WeaponISEndAnim="WeaponPutDown"
	
	IronSightBobDamping=0.9
    BobDamping=0.450000
	
	IronSightGroundSpeedFactor=0.55

    Begin Object Name=FirstPersonMesh
    End Object

    Mesh=FirstPersonMesh
    bDropOnDeath=True
    RespawnTime=1.000000             //ÎäÆ÷ÖØÉú¼ä¸ô
    PickupFactoryMesh=PickupMesh
}
