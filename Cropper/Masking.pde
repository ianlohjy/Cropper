

class MaskHandler
{
    MaskHandler()
    {
        
    }
    
    PImage get_image_for_crop(Crop crop, PImage base_image)
    {
        PGraphics mask_graphics = createGraphics(base_image.width, base_image.height);
        mask_graphics.beginDraw();
        mask_graphics.background(0);
        mask_graphics.endDraw();
        
        mask_graphics.beginDraw();
        mask_graphics.noStroke();
        mask_graphics.fill(255);
        mask_graphics.beginShape();
        for (PVector point : crop.points)
        { 
            mask_graphics.vertex(point.x, point.y);
        }
        mask_graphics.endShape(CLOSE);
        mask_graphics.endDraw();
        
        PGraphics export_graphics = createGraphics(base_image.width, base_image.height);
        export_graphics.beginDraw();
        export_graphics.clear();
        export_graphics.endDraw();
        
        export_graphics.beginDraw();
        export_graphics.image(base_image, 0, 0);
        export_graphics.endDraw();
        
        export_graphics.mask(mask_graphics.get());
        
        return export_graphics.get();
    }
    
    void draw()
    {
        
    }
    
    void mouse_events(MouseEvent e)
    {
    }
} 