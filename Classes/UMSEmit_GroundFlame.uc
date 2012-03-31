/**
 * Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
 */

class UMSEmit_GroundFlame extends UTEmitter;

simulated function AttachTo(Pawn P, name NewBoneName)
{
	//don't have to attach to anything
}

defaultproperties
{
	Begin Object Name=ParticleSystemComponent0
		bOwnerNoSee=true
		Template=ParticleSystem'MyPackage.Effects.P_Vehicle_Damage_1_Cicada'
	End Object
	ParticleSystemComponent=ParticleSystemComponent0

}
