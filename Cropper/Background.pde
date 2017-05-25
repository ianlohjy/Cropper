// Handles everything in the background
// (Images, file navigation, drag/drop)

class Background
{

    int cur_image_position;
    ArrayList<String> image_files;

    // Background Image Parameter
    PImage background_image;
    PImage background_image_low;
    PVector bg_transform = new PVector(0, 0, 1); // Represents x,y offset and scale amount
    boolean low_res = false;

    // Navigation Parameters
    float nudge_min = 1; // Nudge is treated the same way as it is done in Illustrator
    float nudge_max = 10;
    float nudge_amt = nudge_min;

    float zoom_min = 0.01; // Nudge is treated the same way as it is done in Illustrator
    float zoom_max = 0.1;
    float zoom_amt = zoom_min;

    float zoom_min_limit = 0.01;
    float zoom_max_limit = 10;

    boolean panning = false;
    PVector pan_init_position;
    PVector pan_init_bg_transform;

    Background()
    {
        //image_files = new ArrayList<String>();
        //image_files.add("C:\\Users\\Ian\\Desktop\\CN Photos\\Done\\Studio Session _ 04-04-1427 _ Kaikohe\\Studio Session _ 04-04-1427 _ Kaikohe-290 copy.png");
        //load_background(0);
    }

    void draw()
    {
        // Background colour
        pushStyle();
        noStroke();
        fill(230);
        rect(0, 0, width, height);
        popStyle();
        // Intro message
        pushStyle();
        noStroke();
        fill(0);
        textAlign(CENTER, CENTER);
        textSize(15);
        text("DRAG & DROP AN IMAGE OR FOLDER TO BEGIN", width/2-100, height/2-200, 200, 200);
        textAlign(CENTER, TOP);
        textSize(12);
        text("Arrow Keys - Nudge Image\nLeft/Right Mouse - Create/ Finish Shape\nMouse Wheel - Zoom & Pan\nF - Frame Image\n[ ] - Prev/Next Image\n\nHold Shift to increase nudge & zoom amount", 
            width/2-125, height/2-50, 250, 200);
        popStyle();

        // Background_image
        pushStyle();
        pushMatrix();
        translate(bg_transform.x, bg_transform.y);
        scale(bg_transform.z);

        // Draw Center Point
        pushStyle();
        noFill();
        stroke(0);
        strokeWeight(1);
        ellipse(0, 0, 30, 30);
        line(0, -50, 0, 50);
        line(-50, 0, 50, 0);
        popStyle();

        if (background_image != null)
        {
            image(background_image, 0, 0);
        }

        /*
    pushStyle();
         noFill();
         stroke(0);
         strokeWeight(1);
         for(int l=0; l<100; l++)
         {
         line(l*10,0,l*10,1000);
         }
         popStyle();
         */
        popMatrix();
        popStyle();

        /*
    fill(255,0,0);
         PVector converted_coords = screen_to_world(mouseX, mouseY);
         text(mouseX+ " " + mouseY, mouseX, mouseY-50);
         text(bg_transform.x + " " + bg_transform.y + " " + bg_transform.z, mouseX, mouseY-35);
         text(converted_coords.x + " " + converted_coords.y, mouseX, mouseY-20);
         */

        // Show image information
        pushStyle();
        noStroke();
        String image_info = "NO IMAGE LOADED";
        if (image_files != null)
        {
            try
            {
                image_info = "Image #" + (cur_image_position+1) + "/" + (image_files.size()) + " | Path: " + image_files.get(cur_image_position);
            }
            catch(Exception e)
            {
            }
        }
        float image_info_width = textWidth(image_info)+10;

        fill(0);
        rect(0, height-15, image_info_width, 15);
        fill(255);
        textSize(12);
        textAlign(LEFT, TOP);

        text(image_info, 5, height-15); 
        popStyle();
    }

    // Navigation
    PVector screen_to_world(float x, float y)
    {
        // Converts window position into world space coordinates
        return new PVector((x-bg_transform.x)/bg_transform.z, (y-bg_transform.y)/bg_transform.z);
    }

    PVector screen_to_world(PVector vector)
    {
        // Convenience overload method
        return screen_to_world(vector.x, vector.y);
    }

    float screen_to_world(float scale)
    {
        // Convenience overload method
        return scale/bg_transform.z;
    }

    PVector world_to_screen(float x, float y)
    {
        // Converts world space coordinates into screen space position
        return new PVector((x*bg_transform.z)+bg_transform.x, (y*bg_transform.z)+bg_transform.y);
    }
    
    float world_to_screen(float scale)
    {
        // Converts world space coordinates into screen space position
        return scale*bg_transform.z;
    }

    PVector world_to_screen(PVector vector)
    {
        // Convenience overload method
        return world_to_screen(vector.x, vector.y);
    }

    void frame_background()
    { // Fits background to window
        // Find out which side is larger
        if (background_image !=null)
        {
            float screen_ratio = (float)width/height;
            float background_ratio = (float)background_image.width/background_image.height;

            if (background_ratio > screen_ratio) // Fit to width
            {
                bg_transform.z = ((float)width/background_image.width);
                move_to(0, 0); // Reset the translation to 0, this lets us easily use world_to_screen() to find the image dimensions 
                PVector image_screen_size = world_to_screen(0, background_image.height); // Find the height of the screen
                move_to(0, (height-image_screen_size.y)/2);
            } else // Fit to height 
            {
                bg_transform.z = ((float)height/background_image.height);
                move_to(0, 0); // Reset the translation to 0, this lets us easily use world_to_screen() to find the image dimensions 
                PVector image_screen_size = world_to_screen(background_image.width, 0);
                move_to((width-image_screen_size.x)/2, 0);
            }
        }
    }
    void move(float x, float y)
    {
        bg_transform.x += x;
        bg_transform.y += y;
    }

    void move_to(float x, float y)
    {
        bg_transform.x = x;
        bg_transform.y = y;
    }

    void zoom(float amt)
    {
        // When zooming, we want to make sure that we are zooming in the direction of the mouse
        PVector starting_mouse_position = screen_to_world(mouseX, mouseY);

        bg_transform.z += amt;

        if (bg_transform.z > zoom_max_limit)
        {
            bg_transform.z = zoom_max_limit;
        } else if (bg_transform.z < zoom_min_limit)
        {
            bg_transform.z = zoom_min_limit;
        }

        // Apply zoom correction
        PVector new_zoomed_position = world_to_screen(starting_mouse_position.x, starting_mouse_position.y);
        new_zoomed_position.sub(mouseX, mouseY);
        move(-new_zoomed_position.x, -new_zoomed_position.y);
    }

    void pan_start()
    {
        pan_init_position = new PVector(mouseX, mouseY);
        pan_init_bg_transform = bg_transform.copy();
        panning = true;
        change_cursor(HAND);
    }

    void pan_move()
    {
        float x_offset = mouseX-pan_init_position.x;
        float y_offset = mouseY-pan_init_position.y;
        move_to(pan_init_bg_transform.x+x_offset, pan_init_bg_transform.y+y_offset);
    }

    void pan_stop()
    {
        panning = false;
        change_cursor(ARROW);
    }

    // Mouse Events
    void mouse_events(MouseEvent e)
    {
        // Mouse Pressed
        if (e.getAction() == 1)
        {
            // Middle Mouse
            if (e.getButton() == 3)
            {
                pan_start();
            }
        }

        // Mouse Released
        if (e.getAction() == 2)
        {
            // Middle Mouse
            if (e.getButton() == 3)
            {
                pan_stop();
            }
        }

        // Mouse Dragged
        if (e.getAction() == 4)
        {
            // Middle Mouse
            if (e.getButton() == 3)
            {
                pan_move();
            }
        }

        // Mouse Wheel
        if (e.getAction() == 8)
        {
            // Middle Mouse
            if (e.getCount() == 1)
            {
                zoom(-zoom_amt);
            } else if (e.getCount() == -1)
            {
                zoom(zoom_amt);
            }
        }

        // Mouse Moved
        if (e.getAction() == 5)
        {
        }
    }

    // Key Events
    void key_events(KeyEvent e)
    {
        // Key Pressed
        if (e.getAction() == 1)
        {
            switch(e.getKeyCode())
            {
            case 40: // DOWN
                move(0, nudge_amt);
                break;

            case 39: // RIGHT
                move(nudge_amt, 0);
                break;

            case 38: // UP
                move(0, -nudge_amt);
                break;

            case 37: // LEFT
                move(-nudge_amt, 0);
                break;

            case 16: // SHIFT
                nudge_amt = nudge_max;
                zoom_amt = zoom_max;
                break;

            case 70: // F
                frame_background();
                break;

            case 91: // [
                prev_background();
                break;

            case 93: // ]
                next_background();
                break;

            default:
                break;
            }
        }

        // Key Released
        if (e.getAction() == 2) 
        {
            switch(e.getKeyCode())
            {
            case 16: // SHIFT
                nudge_amt = nudge_min;
                zoom_amt = zoom_min;
                break;

            default:
                break;
            }
        }
    }

    void next_background()
    {
        load_background(cur_image_position+1);
    }

    void prev_background()
    {  
        load_background(cur_image_position-1);
    }

    // Utilities
    void load_background(int position)
    {
        if (image_files.size() > 0)
        {   
            // Loop the index if position is out of bounds
            if (position > image_files.size()-1)
            {
                position = 0;
            } else if (position < 0)
            {
                position = image_files.size()-1;
            }
            background_image = loadImage(image_files.get(position));
            cur_image_position = position;
            frame_background();
        }
        //background_image_low = loadImage(image_files.get(position));
        //background_image.resize(500,0);
    }

    void load_image_paths(ArrayList<String> images)
    {
        image_files = images;
    }
} 
// END OF BACKGROUND CLASS


// File Drag & Drop Handling
void dropEvent(DropEvent drop_event)
{
    if (drop_event.isFile())
    {
        // Contains information of the dropped content
        File dropped_content = drop_event.file();

        // For storing found files
        File[] found_files = new File[0];
        ArrayList<String> compatible_files = new ArrayList<String>();

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
                compatible_files.add(file_path);
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

        // Load in the first of the dropped images
        background.load_image_paths(compatible_files);
        if (compatible_files.size() > 0)
        {
            background.load_background(0);
        }
        uprintln("### DONE ###");
    }
}