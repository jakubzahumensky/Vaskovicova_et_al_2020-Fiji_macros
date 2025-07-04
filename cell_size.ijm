// Lines starting with "//" are comment lines
   setBatchMode(true);
   Dialog.create("cell_size-batch");
          Dialog.addString("Source folder:", "");
          Dialog.addString("Ext:", "czi");
          Dialog.show();
          path = Dialog.getString();
          ext = Dialog.getString();
          list = getFileList(path);
   for (i=0; i<list.length; i++) {
	showProgress(i+1, list.length);
	x=path+list[i];
	if (endsWith(x, "."+ext)) {
		run("Clear Results");
		run("Bio-Formats Windowless Importer", "open=[x]");
		title = getTitle();
		run("Duplicate...", " ");
		run("Despeckle");
		run("Enhance Local Contrast (CLAHE)", "blocksize=127 histogram=256 maximum=3 mask=*None*");
		run("Subtract Background...", "rolling=75 light");
		run("Set Measurements...", "min redirect=None decimal=0");
		run("Measure");
		min=getResult("Min",0);
		max=getResult("Max",0);
		z=(min+max)/2;
		setThreshold(0, z);
		run("Convert to Mask");
		saveAs("TIFF",path+title+"-mask-OG");
		title2 = getTitle();
		run("Close-");
		run("Fill Holes");
		run("Despeckle");
	      // separate clusters
		run("Watershed");
	      // make mask fit the middle of black cell outline
		run("Erode");
		run("Erode");
		run("Erode");
	      // separate clusters
		run("Watershed");
		run("Set Measurements...", "area shape redirect=None decimal=5");
		run("Analyze Particles...", "size=3-Infinity circularity=0.75-1.00 display exclude clear include add");
		saveAs("Results", path+title+"-cell_sizes.csv");
		selectWindow(title2);
		saveAs("TIFF",path+title+"-mask-final");
		run("Close All");
				  }
			     }

// following this processing, results are manually curated:
// cells that are partially out of frame, out of focus and originated in erroneusly segmented clusters are discarded
