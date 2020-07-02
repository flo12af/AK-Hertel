#pragma rtGlobals=1	// Use modern global access method.
#include <Median XY Smoothing Dialog>
#include <Multi-peak fitting 2.0>


// ImageTransform indexWave

Function/WAVE SigmaClip(wavImage, [varTolerance])
	WAVE wavImage
	Variable varTolerance
	Variable varMedian, varSDeviation, varUpperEnd
	String strNewName
	
	if(paramisDefault(varTolerance))
		varTolerance = 5
	endif
	
	varMedian = Median(wavImage)
	varSDeviation = sqrt(Variance(wavImage))
	strNewName = NameOfWave(wavImage) + "_SClipped"	
	varUpperEnd = varMedian + varTolerance*varSDeviation
	
	
	Duplicate/O wavImage, wavDupImage	
	MatrixOP/O wavDupImage = setNaNs(wavDupImage,greater(wavDupImage,varUpperEnd))
	MatrixFilter NaNZapMedian wavDupImage
	
	Return wavDupImage
End


Function/WAVE SigmaClipShort(wavImage, [varTolerance])
	WAVE wavImage
	Variable varTolerance
	Variable varMedian, varSDeviation, varUpperEnd
	String strNewName
	
	if(paramisDefault(varTolerance))
		varTolerance = 5
	endif
	
	varUpperEnd = varMedian + varTolerance*varSDeviation
	
	MatrixOP/O wavImage = setNaNs(wavImage,greater(wavImage,varUpperEnd))
	MatrixFilter NaNZapMedian wavDupImage
	
End


Function AutoDetermineThreshold(wavImage, [varCutoff])
	WAVE wavImage
	Variable varCutoff
	Variable varBinNumber, varCutoffBin, varThreshold
	
	if(paramisdefault(varCutoff)==1)
		varCutoff = 0.45
	endif
	
	Histogram/B=3/DEST=wavImage_hist wavImage 
	varBinNumber = numpnts(wavImage_hist)
	varCutoffbin = round(varBinNumber*varCutoff)
	varThreshold = pnt2x(wavImage_hist,varCutoffbin)
	
	MatrixOP/O wavDupImageThreshold = greater(wavImage, varThreshold)
	MatrixFilter/B=0 point wavDupImageThreshold
	MatrixOP/O wavDupImageThreshold = greater(wavDupImageThreshold,6)
	
	Return varThreshold
End

Function/WAVE ListEdgePositions(wavImage, varThreshold, varRange)	
	WAVE wavImage	
	Variable varThreshold
	Int varRange
	Variable varValuePosition = 0
	Variable varNumPoints = numpnts(wavImage), varXDim, varYDim
	Variable i = 0

	Make/O/N=(200000,3) wavIndexPoints
	MatrixOP/O wavDupImageThreshold = greater(wavImage, varThreshold)
	MatrixFilter/B=0 point wavDupImageThreshold
	MatrixOP/O wavDupImageThreshold = greater(wavDupImageThreshold,5)
	
	varXDim = Dimsize(wavDupImageThreshold,0)-1
	varYDim = Dimsize(wavDupImageThreshold,1)-1	
	wavDupImageThreshold[0,varRange][*]=0
	wavDupImageThreshold[varXDim-varRange,varXDim][*]=0
	wavDupImageThreshold[*][0,varRange]=0
	wavDupImageThreshold[*][varYDim-varRange,varYDim]=0
	
	do
		FindValue/S=(varValuePosition)/V=1 wavDupImageThreshold	
		wavIndexPoints[i][0] = V_Value
		wavIndexPoints[i][1] = V_row
		wavIndexPoints[i][2] = V_col
		VarValuePosition = V_Value + 1
		i+=1		
	while (V_Value != -1)	

	Redimension/N=(i-1,3) wavIndexPoints 
	Return wavIndexPoints
End



Function RemoveSpikes(wavImage, [varThreshold, varTolerance, varRange])
	WAVE wavImage
	Variable varTolerance, varRange, varThreshold
	Variable i, varRowRangeLow, varRowRangeHigh, varColRangeLow, varColRangeHigh
	WAVE wavEdgeEnvironmentClean
	
	if(paramisdefault(varThreshold)==1)
		varThreshold = AutoDetermineThreshold(wavImage)
	endif
	
	if(paramisdefault(varTolerance)==1)
		varTolerance = 1
	endif
	
	if(paramisdefault(varRange)==1)
		varRange = 1
	endif
	
	WAVE wavIndexPoints = ListEdgePositions(wavImage, varThreshold, varRange)
	Variable Timer = StartMSTimer

	
	Variable varPointNumber = DimSize(wavIndexPoints,0)
	Duplicate/O wavImage, wavSpikeRemoval
	
	for(i=0;i<varPointNumber;i+=1)	// Initialize variables;continue test
		varRowRangeLow = wavIndexPoints[i][1] - varRange
		varRowRangeHigh = wavIndexPoints[i][1] + varRange
		varColRangeLow = wavIndexPoints[i][2]- varRange
		varColRangeHigh = wavIndexPoints[i][2] + varRange
		
		MatrixOP/O/FREE wavEdgeEnvironment = subRange(wavImage, varRowRangeLow, varRowRangeHigh, varColRangeLow, varColRangeHigh)// Condition;update loop variables
		WAVE wavEdgeEnvironmentClean = SigmaClip(wavEdgeEnvironment, varTolerance = 1)
		MatrixOP/O wavSpikeRemoval = insertMat(wavEdgeEnvironmentClean , wavSpikeRemoval, varRowRangeLow, varColRangeLow)
	endfor						// Execute body code until continue test is FALSE
	Print StopMSTimer(Timer)
End