#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


Function BinWave(wav_wavetobin, var_Bin)
	WAVE wav_wavetobin
	INT var_Bin
	Variable var_numpoints = numpnts(wav_wavetobin)
	Variable i, j = 0
	String str_NewWaveName
	
	if (var_Bin == 1)
		Abort "Binning Value needs to	 be greater than one"	
	endif
	
	make/O/N=(var_numpoints/var_Bin) wav_binnedwave
	for(i=0;i<floor(var_numpoints/var_Bin);i+=1)	
		wav_binnedwave[i] = sum(wav_wavetobin, j, j+(var_Bin-1))	
		j += (var_Bin)			
	endfor						

	str_NewWaveName = NameOfWave(wav_wavetobin) + "_bin" + num2str(var_Bin)
	Rename wav_binnedwave, $str_NewWaveName
	Return 0
End