package util;

class Keys
{
  public static var singleton = new Keys();

  public static function up():Bool return singleton.is_pressed[KeyEvent.DOM_VK_UP] || singleton.is_pressed[KeyEvent.DOM_VK_W];
  public static function down():Bool return singleton.is_pressed[KeyEvent.DOM_VK_DOWN] || singleton.is_pressed[KeyEvent.DOM_VK_S];
  public static function left():Bool return singleton.is_pressed[KeyEvent.DOM_VK_LEFT] || singleton.is_pressed[KeyEvent.DOM_VK_A];
  public static function right():Bool return singleton.is_pressed[KeyEvent.DOM_VK_RIGHT] || singleton.is_pressed[KeyEvent.DOM_VK_D];

  private function new()
  {
    window.addEventListener('keydown', handle_keydown);
    window.addEventListener('keyup', handle_keyup);
    window.addEventListener('mousedown', handle_mousedown);
    window.addEventListener('mouseup', handle_mouseup);
  }

  public var is_pressed(default, never):Dynamic = {};
  public var num_keys_down = 0;

  function handle_keydown(e:KeyboardEvent)
  {
    if (!is_pressed[e.keyCode]) num_keys_down++;
    is_pressed[e.keyCode] = true;
  }
  function handle_keyup(e:KeyboardEvent)
  {
    if (is_pressed[e.keyCode]) num_keys_down--;
    is_pressed[e.keyCode] = false;
    e.stopImmediatePropagation();
    e.preventDefault();
    return false;
  }

  public var mouse_is_down(default, null):Bool = false;
  function handle_mousedown(e:MouseEvent) if (e.which==1) mouse_is_down = true;
  function handle_mouseup(e:MouseEvent) if (e.which==1) mouse_is_down = false;
}
