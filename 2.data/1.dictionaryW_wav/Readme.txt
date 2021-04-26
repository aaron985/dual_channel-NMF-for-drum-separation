DictionaryW filename look like this:
	1.drums (BassDrum, TomDrums):
		Text_Text_Text(##_##).wav
	The positions correspond to:
		{Brand name}_{Product name}_{shell material}(diameter_width).wav
		
	2.drums (SnareDrum):
		Text_Text_Text(##_##)_Text.wav
	The positions correspond to:
		{Brand name}_{Product name}_{shell material}(diameter_width)_{hit position}.wav
		
	3.cymbals (Hihat, RideCymbals):
		Text_Text_Text(##)_Text.wav
	The positions correspond to:
		{Brand name}_{Product name}_{Product characteristic}(diameter)_{hit position}.wav
		
	4.cymbals (CrashCymbals):
		Text_Text_Text(##).wav
	The positions correspond to:
		{Brand name}_{Product name}_{Product characteristic}(diameter).wav
	
	5. cumbals (Stack Cymbals):
		Text_Text_Text(##_##).wav
	The positions correspond to:
		{Brand name}_{Product name}_{Product characteristic}(first diameter_secend diameter).wav

###############################################
The score informed data is from ENST Drums dataset.