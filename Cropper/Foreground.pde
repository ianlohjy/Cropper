// Foreground UI, including the cursor.

class Foreground implements ModeDelegate
{
  
  Foreground()
  {
    mode.delegates.add(this);
  }
  
  void draw()
  {
    switch(mode.current_mode)
    {
      case SELECTION_MODE:
      break;
      case EDITING_MODE:
      pushStyle();
      noStroke();
      fill(0, 70);
      rect(0, 0, width, height);
      popStyle();
      for(Crop crop : crop_handler.crops){
          crop.crop_image.drawImage();
      }
      draw_grid(50, 50);
      break;
      case CREATING_MODE:
      if(mode.selection_tool == MARQUEE){
          pushStyle();
          strokeWeight(1);
          stroke(0, 50);
          line(0, mouseY, width, mouseY);
          line(mouseX, 0, mouseX, height);
          popStyle();
      }
      break;
    }
    pushStyle();
    String mode_string = "";
    switch(mode.current_mode){
        case SELECTION_MODE:
        mode_string = "SELECTION MODE";
        break;
        case CREATING_MODE:
        mode_string = "CREATION MODE";
        break;
        case EDITING_MODE:
        mode_string = "EDIT MODE";
        break;
    }
    textAlign(CENTER);
    fill(0);
    text(mode_string, width*0.5+1, 21);
    fill(255);
    text(mode_string, width*0.5, 20);
    popStyle();
    if(Application.is_busy){
        pushStyle();
        fill(0, 80);
        noStroke();
        rect(0, 0, width, height);
        fill(255);
        textAlign(CENTER);
        textSize(36);
        text(Application.busy_message, width*0.5, height*0.5);
        popStyle();
    }
  }
  
  void mode_changed(int mode, int old_mode){
    switch(mode)
    {
      case SELECTION_MODE:
      change_cursor(ARROW);
      break;
      case CREATING_MODE:
      change_cursor(CROSS);
      break;
      case EDITING_MODE:
      for(Crop crop : crop_handler.crops){
          crop.crop_image.regenerate_image(background.background_image);
      }
      change_cursor(ARROW);
      break;
      case PANNING_MODE:
      change_cursor(HAND);
      break;
    }
  }
  
  void draw_grid(int grid_size_x, int grid_size_y){
    pushStyle();
    strokeWeight(1);
      stroke(0, 50);
      for(int i = 0; i < width/grid_size_x; i++)
      {
          line(i * grid_size_x, 0, i * grid_size_x, height);
      }
      for(int i = 0; i < height/grid_size_y; i++)
      {
          line(0, i * grid_size_y, width, i * grid_size_y);
      }
    popStyle();
  }
  
}