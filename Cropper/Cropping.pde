

class CropHandler
{
  ArrayList<Crop> crops = new ArrayList<Crop>();
  /* There can only be one active crop at a time. 
     If there is an active crop, CropHandler will create any new crops, 
     but instead let the active crop do its thing.
  */
  Crop active_crop = null; 

  CropHandler()
  {
  }

  void draw()
  {
    for(Crop crop: crops)
    {
      crop.draw();
    }
  }

  boolean new_crop()
  {
    if(active_crop == null)
    {
      uprintln("### Creating new crop ###");
      // Todo: deselect & close all other crops
      Crop new_crop = new Crop(this);
      crops.add(new_crop);
      
      active_crop = new_crop; 
      active_crop.open();  
      return true;
    } 
    else
    {
      //println("A crop is currently active!");
      return false;
    }
  }

  void key_events(KeyEvent e)
  {
    if (e.getAction() == 1)
    {
      switch(e.getKeyCode())
      {
      case 10: // RIGHT ENTER
        break;
      }
    }
  }

  void mouse_events(MouseEvent e)
  {
    // Mouse Pressed
    if (e.getAction() == 1)
    {
      switch(e.getButton())
      {
        // Left Mouse Button
      case 37:
        new_crop();
        break;

      default:
        break;
      }
    }

    for (Crop crop : crops)
    {
      crop.mouse_events(e);
    }
  }

  // Crop
  class Crop
  {
    final static int NONE = 0; // Nothing/ Deselected
    final static int OPEN = 1; // Being actively created at the moment
    final static int SELECTED = 2; // Selected/ Editing

    int mode = NONE;

    boolean selected = false;
    ArrayList<PVector> points;

    CropHandler crop_handler;

    Crop(CropHandler crop_handler)
    {
      this.crop_handler = crop_handler;
      points = new ArrayList<PVector>();
    }
    
    // Modes
    boolean is_open()
    {
      if(mode == OPEN)
      {  return true;
      }
      else
      {  return false;
      } 
    }
    
    void open()
    {
      uprintln("\n### SHAPE OPENED ###");
      mode = OPEN;
    }

    void close()
    {
      mode = NONE;
      if(crop_handler.active_crop == this)
      { /* If this crop is closed (made not active), 
           and if the crop handler has this crop as active,
           remove it as the active crop
        */
        crop_handler.active_crop = null;
      }
    }

    void set_mode(int mode)
    {
      this.mode = mode;
    }

    void mouse_events(MouseEvent e)
    {
      // Mouse Pressed
      if (e.getAction() == 1)
      {
        switch(e.getButton())
        {
          // Left Mouse Button
          case 37:
          if(is_open())
          {
            add_point(e.getX(), e.getY(), -1);
          }  
          break;
          
          case 39:
          if(is_open())
          {
            close();
            uprintln("### SHAPE CLOSED ###");
          }
          break;
    
          default:
          break;
        }
      }
    }

    void draw()
    {
      if(points != null)
      { 
        pushStyle();
        fill(255,0,255,50);
        stroke(0);
        strokeWeight(1);
        
        // Draw PShape with vertices
        beginShape();
        for(PVector point: points)
        {
          // Converting coordinates so that they match the background transform
          PVector wts_coords = background.world_to_screen(point.x,point.y); 
          //ellipse(point.x, point.y, 10, 10);
          vertex(wts_coords.x, wts_coords.y);
        }
        endShape(CLOSE);
        
        /*
        // Draw connecting lines
        
        for(int p=0; p<points.size(); p++)
        {
          int next_index = (p==points.size()-1) ? 0 : p+1;
          // Converting coordinates so that they match the background transform
          PVector wts_coord1 = background.world_to_screen(points.get(p).x,points.get(p).y); 
          PVector wts_coord2 = background.world_to_screen(points.get(next_index).x,points.get(next_index).y); 
          
          line(wts_coord1.x,wts_coord1.y,wts_coord2.x,wts_coord2.y);
        }*/ 
        
        fill(0);
        noStroke();
        // strokeWeight(1);
        
        // Draw points
        for(PVector point: points)
        {
          // Converting coordinates so that they match the background transform
          PVector wts_coords = background.world_to_screen(point.x,point.y); 
          //ellipse(point.x, point.y, 10, 10);
          ellipse(wts_coords.x, wts_coords.y, 10, 10);
          
          //rectMode(CENTER);
          //rect(wts_coords.x, wts_coords.y, 10, 10);
        }
        
        // Show crop index number at first point
        PVector wts_coords = background.world_to_screen(points.get(0).x,points.get(0).y); 
        int index = crop_handler.crops.indexOf(this);
        float index_width = textWidth(Integer.toString(index)) + 5;
        
        fill(0);
        rectMode(CENTER);
        rect(wts_coords.x, wts_coords.y -25, index_width, 20, 20, 20, 20, 20);
        fill(255);
        textAlign(CENTER,CENTER);
        text(index, wts_coords.x, wts_coords.y -27);
        
        popStyle();
      }
    }

    void add_point(float x, float y, int position)
    {
      PVector stw_coord = background.screen_to_world(x,y);
      
      if (points == null)
      {
        points = new ArrayList<PVector>();
      }
      
      if(position < 0 || position > points.size()-1)
      { // If the position is not in range, just add a point at the end
        points.add(new PVector(stw_coord.x, stw_coord.y));
        uprintln("    Adding Point " + (points.size()-1) + "/" + (points.size()-1));
      }
      else
      {
        points.add(position, new PVector(stw_coord.x, stw_coord.y));
        uprintln("    Adding Point " + position + "/" +  (points.size()-1));
      }
    }

    void within_bounds(float x, float y)
    {
      // Will use isPointLeftOfLine() in Utils tab
      // For each each line segment, check if the point is on its left or right side
      // If all lines are the same side, then it point is inside the shape
      // Otherwise, if a check gives you an opposite orientation, break the loop and return false.
    }
  }
}