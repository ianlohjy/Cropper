
// This is intended as a singleton-esque class to store what the program is doing.

// Having a crop or crop vertex highlighted
final static int SELECTION_MODE = 0;
// 
final static int EDITING_MODE= 1;
final int CREATING_MODE = 2;

class Mode
{

    int current_mode = SELECTION_MODE;

    // The delegates will receive callbacks when the mode changes.
    // ModeDelegate interface declared below.
    ArrayList<ModeDelegate> delegates = new ArrayList<ModeDelegate>();

    void key_events(KeyEvent e) {
        switch(e.getKey())
        {
            
        case 'v': // v akin to Photoshop's selection tool
            switch_mode(SELECTION_MODE);
            break;
        case 'n': // n for "new"
            switch_mode(CREATING_MODE);
            break;
        case 'e': // e for "edit" - this will probably not be used.
            switch_mode(EDITING_MODE);
            break;
        }
        switch(e.getKeyCode())
        {
        case ESC:
            switch_mode(SELECTION_MODE);
            break;
        }
    }

    void switch_mode(int mode)
    {
        int old_mode = current_mode;
        current_mode = mode;
        for (ModeDelegate d : delegates) {
            d.mode_changed(current_mode, old_mode);
        }
    }
}

interface ModeDelegate {
    void mode_changed(int mode, int old_mode);
}