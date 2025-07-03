// Lines starting with "//" are comment lines
// measuring perpendicular projection of whole vacuoles to xy plane
// z-stack images need to be pre-processed before using this macro: drift correction and MAX intensity projection
// without z-stack preprocessing, the resulting sizes will be undervalued

// set lower circularity (c) and area (S) limit; select fluorescence channel (F)
   c=0.5;
   S=1;
   F=1;
   run("Clear Results");

   title = getTitle();
   path = getDirectory("image");

// duplicates fl. channel for mask creation
   run("Duplicate...", "duplicate channels=F");
   title2 = getTitle();

// pre-processing for thresholding to compensate for different acquisition parameters 
// normalization of vacuoles of different intensity, contrast stretch, background subtraction, thresholding to mean gray value
   run("Despeckle");
   run("Enhance Local Contrast (CLAHE)", "blocksize=127 histogram=256 maximum=3 mask=*None*");
   run("Subtract Background...", "rolling=75 disable");
   run("Set Measurements...", "mean redirect=None decimal=0");
   run("Measure");
   x=getResult("Mean",0);
   setThreshold(x, 65535);

// mask of whole vacuoles is made and processed to best fit the vacuole outlines; the resulting masks are added to the ROI manager and used to measure areas in original image (to include intensity information)
   run("Set Measurements...", "area mean standard shape integrated redirect=None decimal=5");
   run("Analyze Particles...", "size=S-Infinity circularity=c-1.00 show=Masks display exclude clear include add");
   run("Invert");
   run("Close-");
   run("Fill Holes");
   run("Despeckle");
   run("Erode");
   run("Analyze Particles...", "size=S-Infinity circularity=c-1.00 show=Outlines display exclude clear add");
   run("Clear Results");
   selectWindow(title);
   roiManager("Measure");

// saving results, outlines and masks
   saveAs("Results", path+title+"-vac_size+intensity.csv");
   selectWindow("Drawing of Mask of "+title2);
   saveAs("PNG",path+title+"-bounds");
   close();
   close(title2);
   close("Mask of "+title2);
 // composite brightfield+fl. channel image is created; vacuoles are displayed in red - helps eliminate data petraining to dead cells
   open(path+title);   
   selectWindow(title);
   run("Enhance Contrast", "saturated=1");
   Stack.setDisplayMode("composite");
   Stack.setChannel(2);
   run("Grays");
   Stack.setChannel(1);
   run("Red");

   run("Tile");

// selects wand tool to mark dead cells and fragmented vacuoles - deleted from results tables
   setTool("multipoint");
