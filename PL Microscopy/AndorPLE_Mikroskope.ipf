#pragma TextEncoding = "Windows-1252"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Static strConstant str_PreferedPath = "C:Users:flo12af:Florian Oberndorfer:Promotion:Daten:PLEM Mikroskop:"

Menu "AKH"
	Submenu "PL Mikroskop"
	"Load File", LoadAndorAsc()
	End
End


//Structure for reading out all important data
Structure AndorData
	//File data
	String str_DataFolder
	String str_FileName
	
	//Camera data
	String str_time
	String str_version
	Variable var_temperature_C
	String str_Model
	String str_Datatype
	String str_AquisitionMode
	String str_TriggerMode
	Variable var_ExposureTime_s
	String str_ReadOutMode
	
	//What follows depends on ReadOutMode
	Variable var_HorBinning
	Variable var_VerBinning
	String str_ClockWiseRotation
	String str_AntiClockWiseRotation
	String str_HorFlipping
	String str_VerFlipping
	Variable var_VerticalShiftSpeed_us
	Variable var_PixelReadoutRate_MHz
	String str_BaselineClamp
	String str_ClockAmplitude
	String str_OutputAmpflifier
	Variable str_SerialNumber
	String str_PreAmplifierGain
	String str_SpuriousNoiseFilterMode
	String str_PhotonCounted
	String str_DataAveragingFilterMode
	
	//Spectrograph data
	String str_SRSerialNumber
	Variable var_Wavelength_nm
	Variable var_GratingGrooveDensity_1_mm
	Variable GratingBlaze
	String OutputFlipperPort
	Variable InputSideSlitWidth_um
		
EndStructure


//Function to load all data and save it in the Structure
Static Function ReadMainData(data,RefNumber)
	STRUCT AndorData &data
	Variable RefNumber
	String str_temperature_C, str_ExposureTime
	Variable var_temp
	
	Open/R RefNumber
	FReadLine RefNumber, data.str_time
	FReadLine RefNumber, data.str_version
	FReadLine RefNumber, str_temperature_C
	sscanf str_temperature_C, "Temperature (C):%f", var_temp
	data.var_temperature_C = var_temp
	FReadLine RefNumber, data.str_Model
	FReadLine RefNumber, data.str_Datatype
	FReadLine RefNumber, data.str_AquisitionMode
	FReadLine RefNumber, data.str_TriggerMode
	FReadLine RefNumber, str_ExposureTime
	sscanf str_ExposureTime, "Exposure Time (secs):%f", var_temp
	data.var_ExposureTime_s = var_temp	 
End



//Function to load all Files
Function FileLoader()
End

//Simple Function to read data and save file
Function LoadAndorAsc_old(str_file)
	String str_file 
	String str_fileheader
	Variable num_strings,i, AndorRefNumber
	
	Open/R AndorRefNumber
	FReadLine/T=(num2char(13)+num2char(10)+num2char(13)+num2char(10)) AndorRefNumber, str_fileheader
	LoadWave/A/N=LoadedWave/J/K=1/M/Q/L={0,35,0,0,0}/U={0,1,0,0} str_file
	WAVE wave_to_note = $"LoadedWave0"
	

End


Function LoadAndorAsc([str_file])
	String str_file
	String str_greplist
	Variable var_strings,i
	
	if(ParamIsDefault(str_File))
		str_file=PopUpChooseAndorFile(strPrompt="Choose Absorption File")
	endif
	
	Make/O/T/FREE wave_greplist
	GREP/E=".*:.*" str_file as wave_greplist
	var_strings = numpnts(wave_greplist)
		
	LoadWave/A/N=LoadedWave/J/K=1/M/Q/L={0,35,0,0,0}/U={0,1,0,0} str_file
	WAVE LoadedWave = LoadedWave0
	str_file = ParseFilePath(3, str_file, ":", 0, 0)
	str_file = CleanupName(str_file,1)
	Rename $NameofWave(LoadedWave), $str_file
	
	for(i=0;i<var_strings;i+=1)	// Initialize variables;continue test
		Note LoadedWave , wave_greplist[i]	// Condition;update loop variables
	endfor						// Execute body code until continue test is FALSE
	
End


Static Function/S PopUpChooseAndorFile([strPrompt])
	String strPrompt
	strPrompt = selectstring(paramIsDefault(strPrompt), strPrompt, "choose file")
	
	Variable refNum
	String outputPath
	String fileFilters = "Delimited Text Files (*.csv,*.txt,*.ibw):.csv,.txt,.ibw;"

	//Browse to Absorption-Folder
	String strPath = str_PreferedPath
	//String strPath = "C:Users:mak24gg:Documents:RAW:Absorption:"
	NewPath/O/Q path, strPath
	PathInfo/S path
	
	Open/D/F=fileFilters/R/M=strPrompt refNum
	outputPath = S_fileName
	return outputPath
End 