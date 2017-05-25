

_Application Application = new _Application();

class _Application
{
    // original_file_name as key
    HashMap<String, CropIdentity> identities = new HashMap<String, CropIdentity>();
    
    CropIdentity current_identity = null;
    
    public _Application(){
        
    }
    
    void add_new_identities(ArrayList<File> image_files)
    {
        for(File file : image_files){
            if(identities.containsKey(file.getName())){
                // ignore
                println("Ignored an added entity - already exists in HashMap: "+file.getName());
            } else {
                println("Added new (fresh) entity to HashMap: "+file.getName());
                identities.put(file.getName(), new CropIdentity(file));
            }
        }
    }
    
    void add_existing_identities(ArrayList<CropIdentity> new_identities)
    {
        for(CropIdentity identity : new_identities){
            if(identities.containsKey(identity.original_image_file_name)){
                // ignore
                println("Ignored an added entity - already exists in HashMap: "+identity.original_image_file_name);
            } else {
                println("Added new (loaded) entity to HashMap: "+identity.original_image_file_name);
                identities.put(identity.original_image_file_name, identity);
            }
        }
    }
    
    void display_identity_at_index(int index)
    {
        CropIdentity[] identities_array = identities.values().toArray(new CropIdentity[0]);
        if(identities_array.length == 0 || index >= identities_array.length){
            println("Requested display at an invalid index: "+index+", identities.length: "+identities_array.length);
            return;
        }
        CropIdentity identity = identities_array[index];
        println("Displaying identity: "+identity.original_image_file_name);
        crop_handler.set_crops(identity.crops);
        background.set_background_image(loadImage(identity.base_image_path()));
    }
    
    void save_crops_for_current_identity()
    {
        // TODO
    }
    
    
}


void load_identities(File folder){
    if (folder == null){
        println("User cancelled folder selection input");
    } else if (folder.isFile()){
        println("Cannot proceed. Please select a folder.");
    }else {
        println("Loading from folder "+folder.getAbsolutePath());
        ArrayList<CropIdentity> identities_loaded = new ArrayList<CropIdentity>();
        File[] folder_contents = folder.listFiles();
        File thisFolder;
        for(int i = 0; i<folder_contents.length; i++){
            thisFolder = folder_contents[i];
            if(thisFolder.isFile()){
                println("Ignored file: "+thisFolder.getName());
                continue;
            } else {
                println("Found folder contents ("+i+"): "+thisFolder.getName());
                CropIdentity new_crop_identity = CropIdentityFactory.build_from_folder(thisFolder);
                if(new_crop_identity != null){
                    identities_loaded.add(new_crop_identity);
                } else {
                    println("Identity loading for "+thisFolder.getName()+" failed due - something went wrong during folder loading :(");
                }
            }
        }
        println("Done! "+identities_loaded.size()+" identities loaded.");
        Application.add_existing_identities(identities_loaded);
        
    }
}



// File Drag & Drop Handling
void dropEvent(DropEvent drop_event)
{
    if (drop_event.isFile())
    {
        // Contains information of the dropped content
        File dropped_content = drop_event.file();

        // For storing found files
        File[] found_files = new File[0];
        ArrayList<File> compatible_files = new ArrayList<File>();

        // Check if the drop was a folder or file
        if (dropped_content.isDirectory())
        {
            found_files = dropped_content.listFiles();
        } else if (dropped_content.isFile())
        {
            found_files = new File[1];
            found_files[0] = dropped_content.getAbsoluteFile();
        } else {
            return;
        } // If no file dropped

        // Check for compatible file formats
        uprintln("\n### CHECKING FOR COMPATIBLE FILES ###");

        for (File file : found_files)
        {
            String file_path = file.getAbsolutePath();
            String file_format = (file_path.substring(file_path.lastIndexOf('.'), file_path.length())).toUpperCase();
            // Added JPEG in here - if only for testing.
            if (file_format.equals(".PNG") || file_format.equals(".JPG"))
            {
                compatible_files.add(file);
                uprintln("  > " + compatible_files.get(compatible_files.size()-1));
            }
        }
        if (compatible_files.size()==0)
        {
            uprintln("    NONE FOUND!");
        } else
        {
            uprintln("    FOUND " + compatible_files.size() + " FILE(S)");
        }
        
        println("Done! Trying to add "+compatible_files.size()+" new files.");
        Application.add_new_identities(compatible_files);

        // Load in the first of the dropped images
        //background.load_image_paths(compatible_files);
        //if (compatible_files.size() > 0)
        //{
        //    background.load_background(0);
        //}
        //uprintln("### DONE ###");
    }
}