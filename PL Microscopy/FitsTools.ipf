#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include <FITS Loader>

Menu "AKH"
	Submenu "Fits File Loader"
	"Load Directory", FITSLoadDirectory()
	End
End



//test path
Static strConstant str_PreferedPath = "D:Dokumente:HomeOfficeDaten:SharpCap:SharpCap Captures"

Function FITSLoadDirectory()
	String fileList = "", file, directory, fullpath, fullpath_cs, filename, str_buffer
	Variable numFiles = 0, i, j, r, cs
	WAVE wav_filename
	DFREF current_folder = GetDataFolderDFR() //get original data folder
	
	//Get file list
	directory = PopUpChooseDirectory()
	fileList = PathActionGetFileList(directory, ".fits")
	numFiles = ItemsInList(fileList)
	for(i=0; i<numFiles; i+=1)
		file = StringFromList(i, fileList)
		fullpath = directory + file
		filename = RemoveEnding(file, ".fits") 
		fullpath_cs = RemoveEnding(fullpath, ".fits") + ".CameraSettings.txt"
		
		//Open and load fits file
		Open/R r as fullpath
		LoadOneFITS(r,filename,0,0,0,0,0,10000000,10000000)
		Close r
		
		//Clean up Folders
		SetDataFolder $filename
		SetDataFolder Primary
		WAVE wav_filename = data
		Duplicate wav_filename, current_folder:$filename 
		KillWaves wav_filename	
		SetDataFolder current_folder
		KillDataFolder $filename 
		
		//Write Camera Settings into the Wave Note
		Open/R cs as fullpath_cs
		for(j=0;j<34;j+=1)	// Initialize variables;continue test
			FReadLine	cs, str_buffer		// Condition;update loop variables
			Note $filename, TrimString(str_buffer)
		endfor						// Execute body code until continue test is FALSE
		Close cs
		
	endfor
	Close/A
End


//Adds all Information from the header into the wavenotes. No longer used
Static Function/WAVE NoteFitsFile(filename)	
	String filename
	
	WAVE wave_fits_data = data
	SVAR str_camera = INSTRUME
	SVAR str_date_obs = 'DATE-OBS'
	NVAR var_y_pixel_size = YPIXSZ
	NVAR var_y_binning = YBINNING
	NVAR var_x_pixel_size = YPIXSZ
	NVAR var_x_binning = XBINNING
	NVAR var_int_time = EXPTIME
	NVAR var_temp = 'CCD-TEMP'
	NVAR var_Bitpix = BITPIX
	Note wave_fits_data, "Camera used: " + str_camera
	Note wave_fits_data, "Image taken at: " + str_date_obs
	Note wave_fits_data, "Y axis pixel size: " + num2str(var_y_pixel_size)
	Note wave_fits_data, "Y binning: " + num2str(var_y_binning)
	Note wave_fits_data, "X axis pixel size: " + num2str(var_x_pixel_size)
	Note wave_fits_data, "X binning: " + num2str(var_x_binning)
	Note wave_fits_data, "Integration time: " + num2str(var_int_time)
	Note wave_fits_data, "Temperature: " + num2str(var_temp)
	Note wave_fits_data, "Bit per pixel: " + num2str(var_Bitpix)	
	Duplicate wave_fits_data, $filename 
	KillWaves wave_fits_data	
	KillVariables/A
	KillSTrings/A
	Return $filename
End



Static Function/S PopUpChooseDirectory()
	//Go to Base Path
	String strPath = str_PreferedPath
	NewPath/O/Q path, strPath
	PathInfo/S path
	//Open Dialog Box for choosing path
	NewPath/M="choose Folder"/O/Q path
	PathInfo path
	strPath = S_path
	GetFileFolderInfo/Q/Z=1 strPath

	if (V_isFolder)
		return strPath
	else
		return ""
	endif
End

//Draws a 50 um scale bar, based on x/y scaling; Image needs to be scaled beforehand
Function DrawScaleBar()
	SetDrawEnv xcoord= top,ycoord= left,textrgb=(65535,65535,65535), linefgc= (65535,65535,65535),linethick= 5.00
	DrawLine 20,40,70,40
	SetDrawEnv xcoord= top,ycoord= left,textrgb=(65535,65535,65535)
	DrawText 30,35,"50 µm"
End

Function SubtractDark()


End

//Scales all Image files to the corresponding um values.
// Lichtmikroskop: 
// 10x 0.200282 um/Pixel
// 50x 0.0478432 um/Pixel
// 100x 0.0248139 um/Pixel
Static Function ScaleImages(magnification [,scaling])
	Variable magnification, scaling
	
	if (ParamIsDefault(scaling))
		switch(magnification)
			case 10:
				scaling = 0.200282
				break
			case 50:
				scaling = 0.0478432
				break
			case 100: 
				scaling = 0.0248139
				break
			default:
				Abort "Specified magnification not available or missing"
			endswitch 
	endif	
		
	String str_wavelist
	Variable i, numitems
	WAVE wave_to_scale
	str_wavelist = wavelist("*",";","")
	numitems = itemsinlist(str_wavelist)

	for(i=0; i<numitems; i+=1)
		WAVE wave_to_scale = $StringFromList(i, str_wavelist, ";")
		SetScale/P x, 0, scaling, wave_to_scale
		SetScale/P y, 0, scaling, wave_to_scale
	endfor
End

