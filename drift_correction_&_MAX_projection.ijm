Dialog.create("Correct drift + MAX project");
Dialog.addString("Source folder:", "");
Dialog.addString("Ext:", "czi");
Dialog.show();
dir = Dialog.getString();
ext = Dialog.getString();
list = getFileList(dir);

for (i=0; i<list.length; i++) {
    showProgress(i+1, list.length);
    x = dir + list[i];
    if (endsWith(x, "." + ext)){
        run("Bio-Formats Windowless Importer", "open=[x]");
        title = getTitle();
        getDimensions(width, height, channels, slices, frames);
        c = channels;
        z = slices;
// "correct 3D drift" plugin works with time series, not stacks, they are exchanged in the image properties
        run("Properties...", "channels=c slices=1 frames=z");
        run("Correct 3D drift", "channel=1 only=0 lowest=1 highest=1");
        run("Z Project...", "projection=[Max Intensity]");
        run("Enhance Contrast", "saturated=0.01");
        saveAs("Tiff",dir+title+"-corrDrift_MAX");
        run("Close All");
    }
}
