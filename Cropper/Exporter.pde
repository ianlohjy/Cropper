

public class Exporter{
    
    boolean exporting = false;
    
    CropIdentity last_exported_identity = null;
    
    public Exporter(PApplet sketch){
        sketch.registerMethod("draw", this);
    }
    
    public void draw(){
        if(exporting){
            Application.save_images_for_current_identity();
            // wait
            
            Application.next_identity();
            if(last_exported_identity == Application.current_identity){
                exporting = false;
                println("Completed saving images!");
            }
            last_exported_identity = Application.current_identity;
        }
    }
    
    public void begin(){
        println("Beginning all-export of images");
        exporting = true;
    }
    
}