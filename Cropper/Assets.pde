// This is the first time I've done this.
// Just want to put all the external assets somewhere tiny.

// pseudo-static. Described in Modes.pde.
_Assets Assets = new _Assets();
class _Assets{
    
    PImage rotation_image;
    
    // We can't put this in the constructor because the sketch hasn't loaded
    // when that's called
    void load_assets()
    {
        rotation_image = loadImage(dataPath("rotate_icon.png"));
    }
}