import java.nio.channels.FileChannel;
import java.io.FileInputStream;
import java.io.FileOutputStream;

void uprintln(String message)
{
  println(message);
}

// ARROW, CROSS, HAND, MOVE, TEXT, or WAIT
void change_cursor(int cursor_type)
{
  cursor(cursor_type);
}

// _Utils: This is a pseudo-static setup that I use since Processing statics don't work.
// Means usage syntax the same as regular statics: Utils.function().
// Helps with the new IDE autocomplete too.

// ps. If you want to do this with things like referencing this PApplet, or the sketch path,
// you'll need to construct this in setup().
_Utils Utils = new _Utils();
class _Utils
{
  
  // Modified from https://www.openprocessing.org/sketch/65627
  boolean point_is_within_polygon(PVector point, ArrayList<PVector> polygonVertices)
  {
    if(polygonVertices.size() < 2){
      return false;
    }
    float a = 0;
    for (int i =0; i<polygonVertices.size()-1; ++i) {
      PVector v1 = (PVector) polygonVertices.get(i);
      PVector v2 = (PVector) polygonVertices.get(i+1);
      a += vAtan2cent180(point, v1, v2);
    }
    PVector v1 = (PVector) polygonVertices.get(polygonVertices.size()-1);
    PVector v2 = (PVector) polygonVertices.get(0);
    a += vAtan2cent180(point, v1, v2);
  
    if (abs(abs(a) - TWO_PI) < 0.01) return true;
    else return false;
  }
  
  // used with the point_is_within_polygon function
  float vAtan2cent180(PVector cent, PVector v2, PVector v1)
 {
    PVector vA = v1.get();
    PVector vB = v2.get();
    vA.sub(cent);
    vB.sub(cent);
    vB.mult(-1);
    float ang = atan2(vB.x, vB.y) - atan2(vA.x, vA.y);
    if (ang < 0) ang = TWO_PI + ang;
    ang-=PI;
    return ang;
  }
  
  // Modulus safe for use with negatives.
  int safeMod(int value, int modulus){
    while(value < 0){
      value += modulus;
    }
    return value % modulus;
  }
  
  String getExtension(File file){
      String[] components = file.getName().split("\\.");
      return components[components.length-1];
  }
  
  public void copyFile(File sourceFile, File destFile) throws IOException {
      println("Copying "+sourceFile.getAbsolutePath()+" to "+destFile.getAbsolutePath());
    if(!destFile.exists()) {
        destFile.createNewFile();
    }

    FileChannel source = null;
    FileChannel destination = null;

    try {
        source = new FileInputStream(sourceFile).getChannel();
        destination = new FileOutputStream(destFile).getChannel();
        destination.transferFrom(source, 0, source.size());
    }
    finally {
        if(source != null) {
            source.close();
        }
        if(destination != null) {
            destination.close();
        }
    }
}
  
}