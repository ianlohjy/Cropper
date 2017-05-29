import java.util.UUID;
import java.io.File;

_CropIdentityFactory CropIdentityFactory = new _CropIdentityFactory();
class _CropIdentityFactory
{
    public CropIdentity build_from_folder(File identity_folder)
    {
        String folder_uuid = identity_folder.getName();

        // Check for image info
        File base_info_file = new File(identity_folder.getAbsolutePath()+"/"+folder_uuid+"_baseinfo.json");
        println("Image info path: "+base_info_file);
        if (base_info_file.exists()) {
            println("Image info file found successfully");
        } else {
            println("ERROR: No image info file exists for "+folder_uuid);
            return null;
        }
        
        JSONObject base_info_json = loadJSONObject(base_info_file.getAbsolutePath());
        String original_image_file_name = base_info_json.getString("original_image_file_name");
        String image_id = base_info_json.getString("image_id"); // this should be the same as our folder name

        // Check for imagebase image
        File base_image_file = new File(identity_folder.getAbsolutePath()+"/"+original_image_file_name);
        println("Base image path: "+base_image_file);
        if (base_image_file.exists()) {
            println("Base image file found successfully");
        } else {
            println("ERROR: No base image file exists for "+folder_uuid);
            return null;
        }

        File crops_folder = new File(identity_folder.getAbsolutePath()+"/"+"Crops");
        println("Crop gathering from folder "+crops_folder.getAbsolutePath());
        ArrayList<Crop> crops = new ArrayList<Crop>();
        if (crops_folder.exists()) {
            File[] crop_files = crops_folder.listFiles();
            File crop_file;
            for (int i = 0; i<crop_files.length; i++) {
                crop_file = crop_files[i];
                println("Running processing over crop file: "+crop_file.getAbsolutePath());
                println("File name: "+crop_file.getName());
                if (Utils.getExtension(crop_file).equals(OUTPUT_IMAGE_EXTENSION)) {
                    println("Found Crop file image: "+crop_file.getAbsolutePath());
                    // subtract 9 from the path to get rid of "_crop.png"
                    String companion_file_name = crop_file.getAbsolutePath().replace("crop","cropinfo").replace(OUTPUT_IMAGE_EXTENSION, "json");
                    File crop_info_file = new File(companion_file_name);
                    println("Searching for companion file: "+crop_info_file);
                    if (crop_info_file.exists()) {
                        println("Found compnanion file - adding crop");
                        crops.add(new Crop(loadJSONObject(crop_info_file.getAbsolutePath())));
                    } else {
                        println("ERROR: No companion file found for image "+crop_file.getName());
                    }
                } else {
                    println("Not an image file, continuing...");
                }
            }
        } else {
            println("No crop folder existed for image "+image_id);
        }
        return new CropIdentity(base_image_file, image_id, crops);
    }
}

class CropIdentity
{
    String original_image_file_name = "";

    String image_id;
    
    File original_file;

    ArrayList<Crop> crops;

    // Used for making new ones. Will duplicate the original file.
    public CropIdentity(File original_file)
    {
        this.original_file = original_file;
        this.original_image_file_name = original_file.getName();
        this.image_id = original_image_file_name;//.replaceAll("\\.", "_");//UUID.randomUUID().toString();
        println("Image id: "+image_id);
        this.crops = new ArrayList<Crop>();
        File directory = new File(OUTPUT_DIRECTORY+"/"+image_id+"/");
        directory.mkdirs();
        try{
            Utils.copyFile(original_file, new File(directory.getAbsolutePath()+"/"+original_image_file_name));
        } catch (IOException e){
            println("Failed to copy file!"+e);
        }
        save_to_output_directory();
    }

    // Used for loading. Assumes the original file has already been duplicated.
    public CropIdentity(File original_file, String image_id, ArrayList<Crop> crops)
    {
        this.original_file = original_file;
        this.original_image_file_name = original_file.getName();
        this.original_image_file_name = original_image_file_name;
        this.image_id = image_id;
        this.crops = crops;
    }

    void save_to_output_directory()
    {
        JSONObject base_json = new JSONObject();
        base_json.setString("original_image_file_name", original_image_file_name);
        base_json.setString("image_id", image_id);
        saveJSONObject(base_json, OUTPUT_DIRECTORY+"/"+image_id+"/"+image_id+"_baseinfo.json");
        JSONObject crop_json; 
        
        File crops_directory = new File(OUTPUT_DIRECTORY+"/"+image_id+"/"+"Crops/");
        if(crops_directory.exists()){
            println("Cleaning crops directory "+crops_directory.getAbsolutePath());
            File[] old_crops = crops_directory.listFiles();
            
            for(int i = 0; i<old_crops.length; i++){
                boolean deletion_success = old_crops[i].delete();
                println((deletion_success? "Successfully deleted" : "ERROR: Failed to delete") + " old file "+old_crops[i].getAbsolutePath());
            }
        }
        
        
        for (Crop crop : crops) {
            crop_json = crop.to_JSON();
            saveJSONObject(crop_json, OUTPUT_DIRECTORY+"/"+image_id+"/"+"Crops/"+image_id+"_cropinfo_"+crop.crop_index+".json");
            crop.crop_image.regenerate_image(loadImage(original_file.getAbsolutePath()));
            crop.crop_image.image.save(OUTPUT_DIRECTORY+"/"+image_id+"/"+"Crops/"+image_id+"_crop_"+crop.crop_index+"."+OUTPUT_IMAGE_EXTENSION);
        }
    }

    String base_image_path()
    {
        return OUTPUT_DIRECTORY+"/"+image_id+"/"+original_image_file_name;
    }
}