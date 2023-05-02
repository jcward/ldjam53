package drone;

class Mailbox extends Sprite
{
  public var has_landed = false;
  public var is_pkg_source = false;
  var drones_sheet:Spritesheet;

  public function new()
  {
    super();

    AtlasMgr.load_atlas('drones', function(sheet) {
      drones_sheet = sheet;
      this.texture = sheet.textures.atlas_fedup_mailbox;
      this.pivot.x = this.texture.width/2;
      this.pivot.y = this.texture.height/2;
    });
  }

  private var _is_open = false;
  public var is_open(get,set):Bool;
  public function set_is_open(v:Bool):Bool {
    _is_open = v;
    this.texture = _is_open ? drones_sheet.textures.atlas_fedup_mailbox_open : drones_sheet.textures.atlas_fedup_mailbox;
    return _is_open;
  }
  public function get_is_open():Bool return _is_open;

}
