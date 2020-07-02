#pragma TextEncoding = "Windows-1252"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Loads all .bmp files in selected folder
Function LoadMicroscopyImages()
	String filelist = "", file, directory
	Variable numfiles = 0, i
	
	directory = PopUpChooseDirectory()
	fileList = PathActionGetFileList(directory, ".bmp")
	numfiles = ItemsInList(filelist)
	
	for(i=0; i<numFiles; i+=1)
		file = StringFromList(i, fileList)
		file = directory + file
		ImageLoad/T=bmp/Q file
	endfor
End



//Scales all Image files to the corresponding um values.
// Lichtmikroskop: 
// 10x 0.200282 um/Pixel
// 50x 0.0478432 um/Pixel
// 100x 0.0248139 um/Pixel
Function ScaleImagesTransMicroscope(magnification [,scaling])
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

//Function to generate PSF of an airy Disc in the focal plane, scaled with um.
Function MakeAiryPSF(npix,cx,cy,ND,lambda)
    Variable npix,cx,cy,ND,lambda
   
    Make/O/D/N=(npix,npix) airyWave
    Variable rs=2*pi*ND/lambda
    airyWave=(2*BesselJ(1,(rs*sqrt((x-cx)^2+(y-cy)^2)))/(rs*sqrt((x-cx)^2+(y-cy)^2)))^2
    SetScale/P x, 0, 0.001, airyWave
    SetScale/P y, 0, 0.001, airyWave
End