class UMSBot extends UTBot;

var class<UTFamilyInfo> CharacterClass;


function Initialize(float InSkill, const out CharacterInfo BotInfo)
{
	local UTPlayerReplicationInfo PRI;

	Skill = FClamp(InSkill, 0, 7);

	// copy AI personality
	if (BotInfo.AIData.FavoriteWeapon != "")
	{
		if (WorldInfo.IsConsoleBuild())
		{
			FavoriteWeapon = class<Weapon>(FindObject(BotInfo.AIData.FavoriteWeapon, class'Class'));
		}
		else
		{
			FavoriteWeapon = class<Weapon>(DynamicLoadObject(BotInfo.AIData.FavoriteWeapon, class'Class'));
		}
	}
	Aggressiveness = FClamp(BotInfo.AIData.Aggressiveness, 0, 1);
	BaseAggressiveness = Aggressiveness;
	Accuracy = FClamp(BotInfo.AIData.Accuracy, -5, 5);
	StrafingAbility = FClamp(BotInfo.AIData.StrafingAbility, -5, 5);
	CombatStyle = FClamp(BotInfo.AIData.CombatStyle, -1, 1);
	Jumpiness = FClamp(BotInfo.AIData.Jumpiness, -1, 1);
	Tactics = FClamp(BotInfo.AIData.Tactics, -5, 5);
	ReactionTime = FClamp(BotInfo.AIData.ReactionTime, -5, 5);

	// copy visual properties
 	PRI = UTPlayerReplicationInfo(PlayerReplicationInfo);
 	if (PRI != None)
 	{
		UTPawn(Pawn).SetCharacterClassFromInfo(CharacterClass);
		
	}

	ResetSkill();
}


defaultproperties
{
	CharacterClass=class'UMSFamilyInfo_PLA'
}