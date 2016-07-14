#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 1.11
// Program to open files, save them as tab delimidated, then close them out of memory.

// Example:
//  osc("C:Documents and Settings:computation:Desktop:AFM_6-2-16:", "SKPM_", 21, basepaths ="C:Documents and Settings:computation:Desktop:testfolder:",  startsuffix = 0000)



//startsuffix is an optional parameter and if given must be given as "startsuffix=0000"
// see->    DisplayHelpTopic "ParamIsDefault"
// basepatho = base path to open  
// basenameo = base name to open
// suffend = last number in the batch to process
// basepaths = base path to save
// basenames = base name to save
// startsuffix = base number to begin iterating from, useful if your first few images are actually graphs

Menu "Save Files to .txt"
	Submenu "Batch Export Folder"
		"Default", osc()
		"Custom Labeling", osc()
	end
	"Test" , test()
	"Test open file dialog", OpenParam()
end

Function AutoOpen()  // combines ui requests with OpenSaveClose command
end









	
Function OpenParam()
	Variable refNum
	String basepatho
	
	// Ask user for folder .ibw files are in
	String message = "Select folder containing *.ibw fildes to be exported"
	NewPath /M  = message /O basepatho
	if (V_Flag)
		return -1		//user canceled
	endif
	//print basepatho
	
	//first = replacestring(basepatho, first, " ")
	
	// request open parameters
	Variable suffend = 0017, saves = 1
	String basenameo = "SKPM_"
	Prompt basenameo, "Enter the base name of the files (enclose in quotes, CASE matters): " 
	Prompt suffend, "What suffix number do you want the export to END with?"
	Prompt saves, "Use default save parameters? (e.g. save folder, save name, inital file exported) ", popup "Yes;No"
	
	DoPrompt "Information Required for File Open", basenameo, suffend, saves
	if (V_Flag)
		return -1		//user canceled
	endif
	
	// do they want default save parameters?
	if (saves !=1)
		message = "What folder would you like the exported *.txt files to be saved in?"
		NewPath /M  = message /O basepaths
		print "\r Good job, you haven't specified what to do if the user doesn't want default save params \r use the base command 'osc()', type help() for more.\r"
	endif
	
	//run appropriate scripts to open identified files\
	print basepatho
	print basenameo
	print suffend
	osc(basepatho, basenameo, suffend)

end





function test()
	Variable refNum
	String basepatho
	
	// Ask user for folder .ibw files are in
	String message = "Select folder containing *.ibw fildes to be exported"
	NewPath /M  = message /O/Q basepatho
	if (V_Flag)
		return -1		//user canceled
	endif
	//print basepatho
end


Function osc(basepatho, basenameo, suffend, [basepaths, basenames, startsuffix]) 		// basepatho = base path to open  // basepaths = base path to save
	string basepatho, basenameo, basepaths, basenames
	variable startsuffix, suffend
	variable suffix
	
	// check for the startsuffix, if it isn't present, default to 0000
	if (ParamIsDefault(startsuffix))
		startsuffix =0000
	endif
	// check for the basenames, if it isn't present, default to the same as basenameo
	if (ParamIsDefault(basenames))
		basenames =basenameo
		//NewPath/C/O stuff "C:Documents and Settings:computation:Desktop:130826:output:"
	endif
	// check for the basepaths, if it isn't present, default to the same as basepatho
	if(ParamIsDefault(basepaths))
		basepaths = basepatho + "output:"
	endif
	suffix = startsuffix

	// Set the symbolic file path for the open operation
	NewPath/O opensezme basepatho
	// Set the symbolic file path for the save operation
	NewPath/C/O savesezme basepaths
	
	do
	// form the filename
	// note that num2string() drops preceeding 0s.  So we must add them back to stay with igor's naming scheme
		if (suffix<10)
			string zeros = num2istr(0) + num2istr(0) + num2istr(0)
		elseif (suffix<100 && suffix>=10)
			zeros = num2istr(0) + num2istr(0)
		elseif (suffix<1000 && suffix>=100)
			zeros =  num2istr(0)
		elseif (suffix<10000 && suffix>=1000)
			// do not add zeros
		elseif (suffix>=10000)
			print "I'm sorry, we don't know what to do with this number suffix. See command osc()."
			abort
		endif
		
		string nameo = basenameo + zeros +num2istr(suffix)
		
		// open the wave
		LoadWave /P=opensezme nameo
		
		
		// Part 2  Save the wave as tab seperated
		// create the name to save the wave under
		string names = basenames + zeros + num2str(suffix) + ".txt"  			// this is the name of the file
		string namesfp = basepaths + names				// this is the names full path
		// Save/J SKPM_0000 as "SKPM_0000.txt"
		Save/O/J $nameo as namesfp  // '$' operator converts the string to a file reference
		
		// Part 3 Close out the wave
		killwaves $nameo
		suffix +=1
		
		while(suffix<=suffend)
	end
	
print "\r dun dun ..Doneee. \r"
	
end



//Function help()
	//print "Example: osc(basepatho, basenameo, suffend, [basepaths, basenames, startsuffix]) \r"
	//print  "basepatho = base path to open  \r basenameo = base name to open \r suffend = last number in the batch to process\r basepaths = base path to save \r basenames = base name to save \r startsuffix = base number to begin iterating from, useful if your first few images are actually graphs"
	//print "Note that to use optional parameters you must explicitly define them in the function call using 'ParamName =Value' syntax"
	//print "Note that in path specification, you should use ':' instead of '/' to specify subdirectories.\r"
	//DisplayHelpTopic "ParamIsDefault"
	//DisplayHelpTopic "Using Optional Parameters"
//end


Function/S DoOpenFileDialog()
	Variable refNum
	String message = "Select first that will be exported"
	String outputPath
	String fileFilters = "Igor binary files (*.ibw):.ibw;"
	fileFilters += "All Files:.*;"
	Open /D /R /F=fileFilters /M=message refNum
	outputPath = S_fileName
	return outputPath // Will be empty if user canceled
End

