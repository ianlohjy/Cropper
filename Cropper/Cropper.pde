import controlP5.*;
import drop.*;

boolean AUTOSAVE = true;
String[] OUTPUT_IMAGE_EXTENSIONS = {"png", "jpg"};

File OUTPUT_DIRECTORY;

// UI
ControlP5 cp5;
SDrop drop;
Background background;
Foreground foreground;
Mode mode;

// CROPPING
CropHandler crop_handler;

Exporter exporter;

ArrayList<CropIdentity> existing_crops;

boolean displaying_identities_to_process = false;

void settings()
{
    size(1100, 800);
}

void setup()
{
    surface.setResizable(true);
    surface.setSize(1200, 800);
    println("Beginning, loading existing identities...");
    Assets.load_assets();
    mode = new Mode();
    background = new Background();
    foreground = new Foreground();
    drop = new SDrop(this);
    crop_handler = new CropHandler();
    
    cp5 = new ControlP5(this);
    cp5.addButton("choose_output_directory")
    .setPosition(20, 20)
    .setSize(150, 20);
    cp5.addLabel("output_directory_label")
    .setPosition(20, 50);
    cp5.addLabel("identities_being_processed")
    .setPosition(20, 70)
    .setValueLabel("All identities processed.");
    
    exporter = new Exporter(this);
    
    set_output_directory(new File(sketchPath()+"/Output/"));
}

void draw()
{
    background(0);
    background.draw();
    crop_handler.draw();
    foreground.draw();

    noStroke();
    fill(0);
    rect(0, 0, 50, 15);
    fill(255);
    textSize(12);
    textAlign(LEFT, TOP);
    text("FPS " + int(frameRate), 0, 0);
    if(Application.remaining_new_identities_to_process > 0){
        displaying_identities_to_process = true;
        cp5.getController("identities_being_processed").setValueLabel("Processing identity "+Application.remaining_new_identities_to_process+" / "+Application.total_new_identities_to_process);
    } else if (displaying_identities_to_process) {
        displaying_identities_to_process = false;
        cp5.getController("identities_being_processed").setValueLabel("All identities processed.");
    }
}

// CONTROLP5 CAlLBACKS //

void choose_output_directory(){
    selectFolder("Select output directory", "set_output_directory");
}

void set_output_directory(File file){
    if( file != null ){
        println("Set output directory to "+file.getAbsolutePath());
        Application.reset_application();
        OUTPUT_DIRECTORY = new File(file.getAbsolutePath()+"/");
        load_identities(OUTPUT_DIRECTORY);
        cp5.getController("output_directory_label").setValueLabel(OUTPUT_DIRECTORY.getAbsolutePath());
        Application.display_identity_at_index(0);
    }
}

// EVENTS //
void pass_mouse_event(MouseEvent e)
{
    crop_handler.mouse_events(e);
    background.mouse_events(e);
}

void pass_key_events(KeyEvent e)
{  
    mode.key_events(e);
    background.key_events(e);
    crop_handler.key_events(e);
}

// Keys
void keyPressed(KeyEvent e)
{ 
    pass_key_events(e);
    
    if(key == CODED){
        switch(keyCode){
            case LEFT:
            Application.previous_identity();
            break;
            case RIGHT:
            Application.next_identity();
            break;
        }
    }
    
    switch(key){
        case 'o':
        // load_identities defined in Identification.pde
        selectFolder("Load specific crop set...", "open_identity", OUTPUT_DIRECTORY);
        break;
        case '0':
        Application.display_identity_at_index(0);
        break;
        case 's':
        Application.save_info_for_current_identity();
        // There are useful but a little dangerous to keep bound to keys!
        //case 'a':
        //exporter.begin();
        //break;
        //case 'd':
        //Application.delete_all_crop_images();
        //break;
    }
}

void keyReleased(KeyEvent e)
{
    pass_key_events(e);
}

// Mouse
void mouseMoved(MouseEvent e)
{
    pass_mouse_event(e);
}

void mouseDragged(MouseEvent e)
{
    pass_mouse_event(e);
}

void mousePressed(MouseEvent e)
{
    Input.mouse_down = true;
    pass_mouse_event(e);
}

void mouseReleased(MouseEvent e)
{
    Input.mouse_down = false;
    pass_mouse_event(e);
}

void mouseWheel(MouseEvent e)
{
    pass_mouse_event(e);
    //println(e.getCount());
    //println(e.getAction());
}