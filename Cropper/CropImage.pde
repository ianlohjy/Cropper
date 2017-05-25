

class CropImage
{
    Crop crop;
    
    PImage image;
    
    PVector image_position = new PVector();
    PVector image_size = new PVector();
    float image_rotation = 0;
    private PVector image_rotation_pivot_default = new PVector(0.5, 0.5); 
    PVector image_rotation_pivot_offset = new PVector(); // offset from normalized default position at 0.5, 0.5
    
    public CropImage(Crop crop){
        this.crop = crop;
    }
    
    public void drawSkeleton(){
        PVector wts_coord = background.world_to_screen(image_position);
        float wts_scale = background.world_to_screen(1);
        pushStyle();
        stroke(0, 255, 0);
        strokeWeight(1);
        noFill();
        rect(wts_coord.x, wts_coord.y, image_size.x*wts_scale, image_size.y*wts_scale);
        popStyle();
    }
    
    public void drawImage()
    {
        PVector wts_coord = background.world_to_screen(image_position.x, image_position.y);
        float wts_scale = background.world_to_screen(1);
        image(image, wts_coord.x, wts_coord.y, image.width*wts_scale, image.height*wts_scale);
    }
    
    public void regenerate_image(PImage base_image)
    {
        PGraphics mask_graphics = createGraphics(ceil(image_size.x), ceil(image_size.y));
        mask_graphics.beginDraw();
        mask_graphics.background(0);
        mask_graphics.endDraw();
        
        mask_graphics.beginDraw();
        mask_graphics.noStroke();
        mask_graphics.fill(255);
        mask_graphics.beginShape();
        for (PVector point : crop.points)
        { 
            mask_graphics.vertex(point.x - image_position.x, point.y - image_position.y);
        }
        mask_graphics.endShape(CLOSE);
        mask_graphics.endDraw();
        
        PGraphics export_graphics = createGraphics(ceil(image_size.x), ceil(image_size.y));
        export_graphics.beginDraw();
        export_graphics.clear();
        export_graphics.endDraw();
        
        export_graphics.beginDraw();
        export_graphics.image(base_image, -image_position.x, -image_position.y);
        export_graphics.endDraw();
        
        export_graphics.mask(mask_graphics.get());
        
        image = export_graphics.get();
    }
    
    public void update(){
        float smallest_x = Float.MAX_VALUE;
        float largest_x = Float.MIN_VALUE;
        float smallest_y = Float.MAX_VALUE;
        float largest_y = Float.MIN_VALUE;
        
        for(PVector point : crop.points){
            if(point.x < smallest_x){
                smallest_x = point.x;
            }
            if(point.x > largest_x){
                largest_x = point.x;
            }
            if(point.y < smallest_y){
                smallest_y = point.y;
            }
            if(point.y > largest_y){
                largest_y = point.y;
            }
        }
        
        image_position.x = smallest_x;
        image_position.y = smallest_y;
        image_size.x = largest_x - smallest_x;
        image_size.y = largest_y - smallest_y;
    }
    
    PVector get_rotation_pivot()
    {
        return PVector.add(image_rotation_pivot_default, image_rotation_pivot_offset);
    }


}