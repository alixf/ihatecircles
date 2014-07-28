@:enum abstract Protocol(Int)
{
	var STC_ADDPLAYER 			= 0;
	var STC_UPDATEPLAYER 		= 1;
	var STC_REMOVEPLAYER 		= 2;
	var STC_ADDBULLET 			= 3;
	var STC_ADDENEMY			= 4;
	var STC_UPDATEENEMY			= 5;
	var STC_REMOVEMULTISCORE	= 6;
	var STC_STARTGAME			= 7;
	var STC_HITPLAYER			= 8;
	var STC_ADDLINE				= 9;
	
	var CTS_ADDPLAYER 			= 100;
	var CTS_UPDATEPLAYER 		= 101;
	var CTS_ADDBULLET 			= 102;
	var CTS_HITENEMY			= 103;
	var CTS_REMOVEBULLET		= 104;
	var CTS_STARTGAME			= 105;
	var CTS_HITPLAYER			= 106;
	var CTS_ADDLINE				= 107;
}