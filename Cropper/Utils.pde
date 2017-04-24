public static boolean isPointLeftOfLine(PVector a, PVector b, float x_input, float y_input)
{
  try
  {
    return ((b.x - a.x)*(y_input - a.y) - (b.y - a.y)*(x_input - a.x)) > 0;
  }
  catch(Exception e)
  {
    return false;
  }  
}

void uprintln(String message)
{
  println(message);
}

void change_cursor(int cursor_type)
{
  cursor(cursor_type);
}