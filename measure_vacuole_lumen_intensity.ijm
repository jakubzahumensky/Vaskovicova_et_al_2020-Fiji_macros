// Lines starting with "//" are comment lines
// macro processes the original fluorescence channel to obtain masks of vacuoles and vacuole lumen
// masks are then applied to the original non-processed fl. channel for intensity analysis

// set lower circularity (c) and area (S) limit; select slice (s) and fl. channel (F) to measure intensity
   c = 0.5;
   S = 1;
   s = 9;
   F = 1;
   title = getTitle();
   path = getDirectory("image");
   run("Clear Results");

// only works with fluorescent channel and duplicates it for different processing operations
   run("Duplicate...", "duplicate channels=F slices=s");
   title2 = getTitle();
   run("Duplicate...", " ");
   title3 = getTitle();

// preprocessing for thresholding to compensate for different acquisition parameters 
// normalization of vacuoles of different intensity, contrast stretch, background subtraction, thresholding to mean gray value
   run("Despeckle");
   run("Enhance Local Contrast (CLAHE)", "blocksize=127 histogram=256 maximum=3 mask=*None*");
   run("Subtract Background...", "rolling=75 disable");
   run("Set Measurements...", "mean redirect=None decimal=0");
   run("Measure");
   M=getResult("Mean",0);
   setThreshold(M, 65535);

// mask of whole vacuoles is made and processed to best fit the vacuole outlines; the resulting masks are added to the ROI manager
   run("Set Measurements...", "area mean standard min centroid shape integrated redirect=None decimal=5");
   run("Analyze Particles...", "size=1.00-Infinity circularity=c-1.00 show=Masks display exclude clear include add");
   run("Invert");
   run("Close-");
   run("Fill Holes");
   run("Despeckle");
   run("Erode");
   run("Analyze Particles...", "size=1.00-Infinity circularity=c-1.00 show=Masks display exclude clear include add");
   selectWindow("Mask of "+title3);
   saveAs("TIFF",path+title3+"-outer_bound");

// vacuole mask is used to create vac_lumen mask; the resulting masks are added to the ROI manager
   selectWindow(title3+"-outer_bound.tif");
   run("Erode");
   run("Erode");
   run("Erode");
   run("Erode");
   run("Erode");
   run("Analyze Particles...", "size=0.00-Infinity circularity=0-1.00 show=Outlines display exclude include add");
   selectWindow(title3+"-outer_bound.tif");
   saveAs("TIFF",path+title3+"-inner_bound");
   selectWindow(title2);
   run("Clear Results");
 // measuring of objects using both creating masks from ROIs stored in ROI manager
   roiManager("Measure");

// background measurement from original fluorecence channel
   selectWindow(title2);
   run("gem");
   run("Invert LUT");
   saveAs("TIFF",path+title2+"-slice_"+s);
   setTool("wand");
 // wand parameters need to be adjusted manually, these settings do not translate to the work space for unknown reasons
   doWand(1, 1, 50.0, "4-connected");
   waitForUser("Measure 5 areas for background");
   selectWindow("Results");
   saveAs("Results", path+title+"vac_lumen+membrane-results.csv");

// all images are closed and those needed for manual curation of results are opened again
   run("Close All");
 // original image including brightfield channel is loaded, vacuoles are displayed in red - helps eliminate data petraining to dead cells
   open(path+title);
 // sets slice s of fluoresence channel (weird logic of Fiji counting slices)
   x=2*s-1;
   setSlice(x);
   Stack.setChannel(1);
	run("Red");
   run("Enhance Contrast", "saturated=0.1");
	Stack.setChannel(2);
	run("Grays");
   run("Enhance Contrast", "saturated=0.01");
   Stack.setDisplayMode("composite");
   setTool("multipoint");
 // creates overlay of vacuolar membrane over the vacuole to verify correct segmentation of vacuoles; fragmented and non-standard vacuoles are discarded
   open(path+title3+"-outer_bound.tif");
   run("Grays");
   run("Enhance Contrast", "saturated=0.01");
   open(path+title3+"-inner_bound.tif");
   imageCalculator("Difference create", title3+"-outer_bound.tif",title3+"-inner_bound.tif");
   saveAs("TIFF",path+title3+"-membrane");
   run("Green");
   open(path+title2+"-slice_"+s+".tif");
   run("Enhance Contrast", "saturated=0.01");
   run("8-bit");
   run("Merge Channels...", "c1=[" + title2 + "-slice_"+s+".tif] c2=[" + title3 + "-membrane.tif] create");
   saveAs("TIFF",path+title3+"-composite");
   selectWindow(title3+"-outer_bound.tif");
   run("Invert LUT");

   run("Tile");

// following background subtraction, data are used to calculate mean vac_lumen intensity and ratio of total vac_lumen/whole_vacuole intensity
