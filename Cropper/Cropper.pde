import controlP5.*;
import drop.*;

/*
TO DO:
 - Exporting to JSON
 - Importing from JSON
 - Exporting masked images from crops
 
 */

// UI
ControlP5 cp; // Instantiate CP5 (gui)
SDrop drop;
Background background;
Foreground foreground;
Mode mode;

// CROPPING
CropHandler crop_handler;

void settings()
{
    size(1000, 500);
}

void setup()
{
    surface.setResizable(true);
    surface.setSize(1000, 500);
    Assets.load_assets();
    mode = new Mode();
    background = new Background();
    foreground = new Foreground();
    drop = new SDrop(this);
    crop_handler = new CropHandler();
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