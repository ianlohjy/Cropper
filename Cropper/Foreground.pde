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