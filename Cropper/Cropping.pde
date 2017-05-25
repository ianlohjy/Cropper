
class CropHandler implements ModeDelegate
{
    ArrayList<Crop> crops = new ArrayList<Crop>();
    /* There can only be one active crop at a time. 
     If there is an active crop, CropHandler will create any new crops, 
     but instead let the active crop do its thing.
     */
    Crop active_crop = null;

    CropHandler()
    {
        mode.delegates.add(this);
    }

    void draw()
    {
        for (Crop crop : crops)
        {
            crop.draw();
        }
    }
    
    void set_crops(ArrayList<Crop> crops){
        deselect();
        this.crops = crops;
        println("CropHandler set crops, size: "+crops.size());
    }

    /* Begin ModeDelegate interface functions*/

    // Handling what happens when the mode changes.
    void mode_changed(int mode, int old_mode) {
        if (mode != CREATING_MODE)
        {
            // If we have an active crop that's open, close that up - we're not creating any more.
            if (active_crop != null)
            {
                if (active_crop.state == active_crop.OPEN)
                {
                    active_crop.close();
                }
            }
        }
        if(mode != SELECTION_MODE){
            deselect();
        }
    }

    /* End ModeDelegate interface functions */

    void new_crop(PVector position)
    {
        uprintln("### Creating new crop ###");
        // Todo: deselect & close all other crops
        Crop new_crop = new Crop(position);
        this.crops.add(new_crop);
        println("Added a new crop! New size: "+this.crops.size());

        active_crop = new_crop;
        //active_crop.open();
    }

    void selectCrop(Crop c)
    {
        deselect();
        //if (active_crop != null && active_crop != c)
        //{
        //  active_crop.deselect();
        //}
        active_crop = c;
        c.select();
    }

    void deselect()
    {
        for (Crop c : crops) {
            c.deselect();
        }
        active_crop = null;
    }

    void delete_active_crop()
    {
        if (active_crop != null)
        {
            delete_crop(active_crop);
        }
    }

    void delete_crop(Crop c)
    {
        uprintln("## DELETING CROP ##");
        if (crops.contains(c))
        {
            crops.remove(c);
            if (c == active_crop) {
                deselect();
            }
        } else
        {
            throw new IllegalArgumentException("ERROR: Tried to delete a crop that wasn't stored in our crops list.");
        }
    }

    void key_events(KeyEvent e)
    {
        println("key code: "+e.getKeyCode()+", action: "+e.getAction());
        if (e.getAction() == 1)
        {
            switch(e.getKeyCode())
            {
            case 8: // backspace
                switch(mode.current_mode)
                {
                case SELECTION_MODE:
                    delete_active_crop();
                    break;
                }
                break;
            case 10: // RIGHT ENTER
                uprintln("Right enter pressed (TODO)");
                break;
            }
        }
        Crop c;
        for (int i = crops.size()-1; i >= 0; i--) {
            c = (Crop) crops.get(i);
            c.key_events(e);
        }
    }

    void mouse_events(MouseEvent e)
    { 
        boolean can_continue_propagating = true;
        // We check if any of the crops should absorb the mouse click 
        for (Crop crop : crops)
        {
            if (!crop.mouse_events(e))
            {
                can_continue_propagating = false;
                break;
            }
        }
        if (!can_continue_propagating)
        {
            return;
        }

        PVector mouse_vector = background.screen_to_world(mouseX, mouseY);

        // Mouse Pressed
        if (e.getAction() == 1)
        {
            switch(e.getButton())
            {
                // Left Mouse Button
            case 37:
                switch(mode.current_mode)
                {
                case SELECTION_MODE:
                    boolean crop_was_selected = false;
                    for (Crop crop : crops)
                    {
                        if (Utils.point_is_within_polygon(mouse_vector, crop.points)) {
                            selectCrop(crop);
                            crop_was_selected = true;
                            break;
                        }
                    }
                    if (!crop_was_selected) {
                        deselect();
                        mode.switch_mode(SELECTION_MODE);
                    }
                    break;
                case EDITING_MODE:
                    if (active_crop != null)
                    {
                        if (!Utils.point_is_within_polygon(mouse_vector, active_crop.points))
                        {
                            deselect();
                            mode.switch_mode(SELECTION_MODE);
                        }
                    }
                    break;
                case CREATING_MODE:
                    if (active_crop == null)
                    {
                        new_crop(mouse_vector);
                    }
                    break;
                }
                break;

            default:
                break;
            }
        }
    }
}

// Crop
class Crop
{
    final static int NONE = 0; // Nothing/ Deselected
    final static int OPEN = 1; // Being actively created at the moment
    final static int SELECTED = 2; // Selected/ Editing

    int state = NONE;

    ArrayList<PVector> points;

    float vertex_size = 10;

    PVector selected_point;
    PVector selection_offset = new PVector();
    
    CropImage crop_image;

    Crop(PVector firstPoint)
    {
        points = new ArrayList<PVector>();
        crop_image = new CropImage(this);
        open();
        add_point(firstPoint, -1);
    }
    
    Crop(JSONObject json){
        points = new ArrayList<PVector>();
        crop_image = new CropImage(this);
        open();
        JSONArray points_array = json.getJSONArray("points");
        JSONObject point_object;
        for(int i = 0; i<points_array.size(); i++){
            point_object = points_array.getJSONObject(i);
            float x = point_object.getFloat("x");
            float y = point_object.getFloat("y");
            add_point(new PVector(x, y), -1);
        }
        crop_image.image_rotation = json.getFloat("image_rotation");
        crop_image.image_rotation_pivot_offset = new PVector(json.getFloat("image_rotation_pivot_offset_x"), json.getFloat("image_rotation_pivot_offset_y"));
        close();
    }
    
    JSONObject to_JSON(){
        JSONObject json = new JSONObject();
        JSONArray points_array = new JSONArray();
        for(PVector point : points){
            JSONObject point_object = new JSONObject();
            point_object.setFloat("x", point.x);
            point_object.setFloat("y", point.y);
        }
        json.setJSONArray("points", points_array);
        json.setFloat("image_rotation", crop_image.image_rotation);
        json.setFloat("image_rotation_pivot_offset_x", crop_image.image_rotation_pivot_offset.x);
        json.setFloat("image_rotation_pivot_offset_y", crop_image.image_rotation_pivot_offset.y);
        return json;
    }
    
    // Modes
    boolean is_open()
    {
        if (state == OPEN)
        {  
            return true;
        } else
        {  
            return false;
        }
    }

    void open()
    {
        uprintln("\n### SHAPE OPENED ###");
        state = OPEN;
    }

    void close()
    {
        uprintln("\n## SHAPE CLOSED ##");
        state = NONE;
        selected_point = null;
    }

    void select()
    {
        uprintln("\n## SHAPE SELECTED ##");
        state = SELECTED;
    }

    void deselect()
    {
        uprintln("\n## SHAPE DESELECTED ##");
        state = NONE;
        selected_point = null;
    }

    void set_state(int state)
    {
        this.state = state;
    }

    void key_events(KeyEvent e)
    {
        if (e.getAction() == 1)
        {
            switch(e.getKeyCode())
            {
            case 8: // backspace
                if (selected_point != null)
                {
                    delete_selected_point();
                }
                break;
            }
        }
    }

    // Returns true if the mouse press should be allowed to propagate
    boolean mouse_events(MouseEvent e)
    {
        PVector mouse_vector = background.screen_to_world(mouseX, mouseY);
        PVector event_vector = background.screen_to_world(e.getX(), e.getY());
        // Mouse Pressed
        if (e.getAction() == 1)
        {
            switch(e.getButton())
            {
                // Left Mouse Button
            case 37:
                switch(mode.current_mode)
                {
                case SELECTION_MODE:
                    PVector hit_vertex = crop_vertex_at_location(mouse_vector);
                    if (hit_vertex != null)
                    {
                        crop_handler.deselect();
                        selection_offset = PVector.sub(mouse_vector, hit_vertex);
                        selected_point = hit_vertex;
                        return false;
                    } else
                    {
                        return true;
                    }

                case CREATING_MODE:
                    if (is_open())
                    {
                        add_point(event_vector, -1);
                        return false;
                    }
                    break;
                }
            break;
            // Right mouse button
            case 39:
                if (is_open())
                {
                    close();
                    uprintln("### SHAPE CLOSED ###");
                    return false;
                }
                break;
            }
        }
        return true;
    }

    void draw()
    {
        if (points != null)
        {
            pushStyle();
            PVector mouse_vector = background.screen_to_world(mouseX, mouseY);
            // If we've selected a point and we're dragging, move the point to the mouse. 
            if(selected_point != null && Input.mouse_down){
                selected_point.x = mouse_vector.x - selection_offset.x;
                selected_point.y = mouse_vector.y - selection_offset.y;
                crop_image.update();
            }
            boolean mouse_is_inside = Utils.point_is_within_polygon(mouse_vector, points);
            strokeWeight(mouse_is_inside? 4 : 1);
            switch(state)
            {
            case NONE:
                fill(255, 0, 255, 10);
                stroke(0);
                break;
            case OPEN:
                fill(255, 0, 255, 50);
                stroke(164, 255, 62, 50);
                break;
            case SELECTED:
                fill(255, 0, 255, 50);
                stroke(255);
                break;
            }

            // Draw PShape with vertices
            beginShape();
            for (PVector point : points)
            {
                // Converting coordinates so that they match the background transform
                PVector wts_coords = background.world_to_screen(point.x, point.y); 
                //ellipse(point.x, point.y, 10, 10);
                vertex(wts_coords.x, wts_coords.y);
            }
            endShape(CLOSE);
            
            crop_image.drawSkeleton();

            pushStyle();
            fill(0);
            // Draw points
            for (PVector point : points)
            {
                if (point == selected_point)
                {
                    strokeWeight(4);
                    stroke(point == selected_point? 255 : color(0, 0));
                } else 
                {
                    strokeWeight(2);
                    stroke(vertex_is_hit(point, mouse_vector)? 255 : 0);
                }
                // Converting coordinates so that they match the background transform
                PVector wts_coords = background.world_to_screen(point.x, point.y); 

                ellipse(wts_coords.x, wts_coords.y, vertex_size, vertex_size);
            }
            popStyle();

            // Show crop index number at first point
            PVector wts_coords = background.world_to_screen(points.get(0).x, points.get(0).y);
            
            int index = crop_handler.crops.indexOf(this);
            float index_width = textWidth(Integer.toString(index)) + 5;

            fill(0);
            noStroke();
            rectMode(CENTER);
            rect(wts_coords.x, wts_coords.y -25, index_width, 20, 20, 20, 20, 20);
            fill(255);
            textAlign(CENTER, CENTER);
            text(index, wts_coords.x, wts_coords.y -27);
            
            // Show editing gizmos if we're selected (but aren't open - that looks weird)
            if(crop_handler.active_crop == this && state != OPEN)
            {
                int icon_size = 40;
                PVector centre = background.world_to_screen(centre_point());
                image(Assets.rotation_image, centre.x-icon_size*0.5, centre.y-icon_size*0.5, icon_size, icon_size);
            }

            popStyle();
        }
    }

    void add_point(PVector stw_coord, int position)
    {
        if (points == null)
        {
            points = new ArrayList<PVector>();
        }

        PVector new_point = new PVector(stw_coord.x, stw_coord.y);

        if (position < 0 || position > points.size()-1)
        { // If the position is not in range, just add a point at the end
            points.add(new_point);
            position = points.size()-1;
        } else {
            points.add(position, new_point);
        }

        selected_point = new_point;
        crop_image.update();
        uprintln("    Adding Point " + position + "/" + (points.size()-1));
    }

    void delete_selected_point()
    {
        if (selected_point != null)
        {
            uprintln("## DELETING VERTEX ##");
            if (points.size() <= 1)
            {
                crop_handler.delete_crop(this);
            } else
            {
                int new_selection_index = Utils.safeMod(points.indexOf(selected_point) - 1, points.size()-1);
                points.remove(selected_point);
                selected_point = (PVector) points.get(new_selection_index);
                crop_image.update();
            }
        }
    }

    PVector crop_vertex_at_location(PVector location)
    {
        for (PVector p : points) {
            if (vertex_is_hit(p, location))
            {
                return p;
            }
        }
        return null;
    }
    
    boolean vertex_is_hit(PVector vertex, PVector location)
    {
            return dist(vertex.x, vertex.y, location.x, location.y) < background.screen_to_world(vertex_size);
    }
    
    PVector centre_point()
    {
        PVector sum = new PVector();
        for(PVector p : points){
            sum.add(p);
        }
        sum.div(points.size());
        return sum;
    }
}