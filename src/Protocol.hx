@:enum abstract Protocol(Int)
{
	var STC_ADDSELFPLAYER 	= 0;
	var STC_ADDOTHERPLAYER 	= 1;
	var STC_UPDATEPLAYER 	= 2;
	var STC_REMOVEPLAYER 	= 3;
	var STC_ADDBULLET 		= 4;
	var STC_ADDENEMY		= 5;
	var STC_UPDATEENEMY		= 6;
	var STC_REMOVEENEMY		= 7;
	
	var CTS_ADDPLAYER 		= 100;
	var CTS_UPDATEPLAYER 	= 101;
	var CTS_ADDBULLET 		= 102;
	var CTS_HITENEMY		= 103;
}