class UMSPlayerController extends UTPlayerController;

var() bool bUseTrueView;
var bool bAdjustISMode;
var bool bMeleeMode;
var bool bMeleeAttack;
//var bool bMeleeEnd;
var name MeleeAttackAnim;
var class<UMSWeaponMelee> MeleeWeaponClass;
var UMSWeaponMelee MeleeWeapon;
var float MeleeInterval;
//var name MeleeWeaponSocket;
enum EAdjustISAxis
{
	IS_X,IS_Y,IS_Z
};
var float AdjustISDelta;
var EAdjustISAxis CurrentAdjustISAxis;
var class<UTFamilyInfo> CharacterClass;

simulated event PostBeginPlay()
{
  super.PostBeginPlay();
  MeleeWeapon = Spawn(MeleeWeaponClass,self);
	MeleeWeapon.Controller=self;
  SetupPlayerCharacter();
}

function SetupPlayerCharacter()
{
  //Set character to our custom character
  ServerSetCharacterClass(CharacterClass);
}

exec function whynotrecog()
{
	Print("I don't know");
}

exec function SwitchWeapon(byte T)
{
  if(bMeleeMode)
	 	return;
	else
		super.SwitchWeapon(T);	
}

//just test whether can leave blood
exec function LeaveBlood()
{
	Print("LeaveBlood");
	UMSPawn(Pawn).LeaveBloodDecalOnGround();
}

simulated exec function ToggleMelee()
{
	local UTPawn p;
	p = UTPawn(Pawn);
	if(!bMeleeMode)
	{
		MeleeWeapon.AttachTo(p);
		p.CurrentWeaponAttachment.DetachFrom(p.Mesh);
		bMeleeMode = true;
	}
	else
	{
		MeleeWeapon.DetachFrom(p.Mesh);
		p.CurrentWeaponAttachment.AttachTo(p);
		bMeleeMode = false;
	}
}

exec function TraceHit()
{
	if(bMeleeMode)
	{
		MeleeWeapon.TraceHit();
	}
}

simulated exec function MeleeAttack()
{
	if(bMeleeMode&&!bMeleeAttack)//&&bMeleeEnd
	{
		ServerMeleeAttack();
		/*
		bMeleeAttack = true;
		p.PlayVictoryAnimation();	//which will call DoPlayEmote then TopHalfAnimSlot.PlayCustomAnim
		bMeleeAttack = false;
		*/
	}
}

reliable server function ServerMeleeAttack()
{
  GotoState('MeleeAttacking');
}

/*  
simulated exec function EndMeleeAttack()
{
  ServerEndMeleeAttack();
}

reliable server function ServerEndMeleeAttack()
{
   //play attack end anim
}
*/

simulated state MeleeAttacking
{
	simulated function BeginState(Name PreviousStateName)
	{
		local UTPawn p;
		p = UTPawn(Pawn);
	 	bMeleeAttack=true;		
		p.TopHalfAnimSlot.PlayCustomAnim(MeleeAttackAnim,MeleeInterval);
		//TraceHit();
		GoToState(PreviousStateName);
  }

   simulated function EndState(Name NextStateName)
	{
		bMeleeAttack = false;
	}
}

simulated exec function ToggleDualMode()
{
	local UMSPawn p;
	local UMSWeapon w;
	p = UMSPawn(Pawn);
	if(!p.bUseSecondary)
	{
		//APHX: Get required weapon
		w = Spawn(class'UMSWeap_AK74');
		//w.bSecondary = true;
		p.EquipSecondary(w);
		if(p.SecondaryWeapon!=None)
			p.bUseSecondary = true;
	}
	else
	{
		p.UnEquipSecondary();
		p.bUseSecondary = false;
	}
}

simulated exec function ToggleIronSights()
{
	local UMSWeapon w;
	local UMSPawn p;
	p = UMSPawn(Pawn);
	w = UMSWeapon(p.Weapon);
	if(p.bUseSecondary)
	{
		//Print("Left Start Fire");
		//p.bFireSecondary = true;
		p.SecondaryWeapon.StartFire(0);
		p.SecondaryWeapon.ServerStartFire(0);
	}
	else
		w.ToggleIronSights();
}

simulated function Print(string text)
{
	ClientMessage(text);
} 

simulated exec function ToggleAdjustISMode()
{
	if(!bAdjustISMode)
	{
		bAdjustISMode = true;
		Print("Now enter IS Adjust Mode");
	}
	else
	{
		bAdjustISMode = false;
		Print("Now exit IS Adjust Mode");
	}
}

simulated exec function SetAdjustISDelta(float value)
{
	if(bAdjustISMode)
	{
		AdjustISDelta = value;
		Print("AdjustISDelta ="$AdjustISDelta);
	}
}

simulated exec function SetCurrentAdjustISAxis(string value)
{
	if(!bAdjustISMode)
	{
		return;
	}
	if(value=="")
		Print("No value. Please follow x, y or z");
	switch(value)
	{
		case "x":
			CurrentAdjustISAxis = IS_X;
			Print("CurrentAdjustISAxis = IS_X");
			break;
		case "y":
			CurrentAdjustISAxis = IS_Y;
			Print("CurrentAdjustISAxis = IS_Y");
			break;
		case "z":
			CurrentAdjustISAxis = IS_Z;
			Print("CurrentAdjustISAxis = IS_Z");
			break;
		defalut:
			Print("Invalid value");
			break;
	}
}

simulated exec function ShowWeaponFireMode()
{
	local UMSWeapon w;
	w = UMSWeapon(UTPawn(Pawn).Weapon);
	Print("Weapon Mode:"$w.CurrentFireMode);
	
}

simulated exec function AdjustIS(bool positive)
{
	local float currVal;
	local UMSWeapon w;
	if(!bAdjustISMode)
	{
		return;
	}
	w = UMSWeapon(UTPawn(Pawn).Weapon);
	switch(CurrentAdjustISAxis)
	{
		case IS_X:
			currVal = w.IronSightViewOffset.X;
			Print("old ironsight x: "$currVal);
			break;
		case IS_Y:
			currVal = w.IronSightViewOffset.Y;
			Print("old ironsight y: "$currVal);
			break;
		case IS_Z:
			currVal = w.IronSightViewOffset.Z;
			Print("old ironsight z: "$currVal);
			break;
	}
	if(positive)
	{
		currVal+=AdjustISDelta;
	}
	else
		currVal-=AdjustISDelta;
	switch(CurrentAdjustISAxis)
	{
		case IS_X:
			w.IronSightViewOffset.X=currVal;
			Print("new ironsight x: "$currVal);
			break;
		case IS_Y:
			w.IronSightViewOffset.Y=currVal;
			Print("new ironsight y: "$currVal);
			break;
		case IS_Z:
			w.IronSightViewOffset.Z=currVal;
			Print("new ironsight z: "$currVal);
			break;
		default:
			break;
	}
	if(w.bUsingIronSights)
	{
		w.ExitIronSights();
		w.EnterIronSights();
	}
	else
		w.EnterIronSights();
}

simulated exec function AdjustPlayerViewOffset(bool positive)
{
	local float currVal,currVal2;
	local UMSWeapon w;
	local UMSPawn p;
	if(!bAdjustISMode)
	{
		return;
	}
	p=UMSPawn(Pawn);
	w = UMSWeapon(p.Weapon);
	
	switch(CurrentAdjustISAxis)
	{
		case IS_X:
			currVal = w.PlayerViewOffset.X;
			currVal2 = p.EyeOffset.X;
			Print("old pvoffset x: "$currVal2);
			break;
		case IS_Y:
			currVal = w.PlayerViewOffset.Y;
			currVal2=p.EyeOffset.Y;
			Print("old pvoffset y: "$currVal2);
			break;
		case IS_Z:
			currVal = w.PlayerViewOffset.Z;
			currVal2=p.EyeOffset.Z;
			Print("old pvoffset z: "$currVal2);
			break;
	}
	if(positive)
	{
		currVal+=AdjustISDelta;
		currVal2+=AdjustISDelta;
	}
	else
	{
		currVal-=AdjustISDelta;
		currVal2-=AdjustISDelta;
	}
	switch(CurrentAdjustISAxis)
	{
		case IS_X:
			w.PlayerViewOffset.X=currVal;
			p.EyeOffset.X=currVal2;
			Print("new pvoffset x: "$currVal2);
			break;
		case IS_Y:
			p.EyeOffset.Y = currVal2;
			w.PlayerViewOffset.Y=currVal;
			Print("new pvoffset y: "$currVal2);
			break;
		case IS_Z:
			w.PlayerViewOffset.Z=currVal;
			p.EyeOffset.Z=currVal2;
			Print("new pvoffset z: "$currVal2);
			break;
		default:
			break;
	}
}

simulated exec function Reload()
{
	local UMSWeapon w;
	w = UMSWeapon(UTPawn(Pawn).Weapon);
	w.ReloadWeapon();
}

simulated exec function SwitchMode()
{
	local UMSWeapon w;
	w = UMSWeapon(UTPawn(Pawn).Weapon);
	w.SwitchFireMode();
}

DefaultProperties
{
	bUseTrueView=true
	AdjustISDelta=0.2;
	CurrentAdjustISAxis=IS_Y;
	CharacterClass=class'UMSFamilyInfo_PLA'
	//MeleeWeaponSocket='DualWeaponPoint'
	MeleeAttackAnim = "Taunt_FB_Victory"
	MeleeWeaponClass=class'UMSMelee_Sword'
	MeleeInterval=0.1
}

