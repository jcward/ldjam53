package drone;

import util.DebugAxes;

class Pod extends Sprite
{
  var drones_sheet:Spritesheet;

  var base:Sprite;
  var rear_fan:Sprite;
  var front_fan:Sprite;
  var pkg:Sprite;

  public var velocity:Point = new Point(0,0);

  public function new()
  {
    super();

    AtlasMgr.load_atlas('drones', function(sheet) {
      drones_sheet = sheet;
      base = new Sprite(drones_sheet.textures.atlas_pod_base);
      addChild(base);

      rear_fan = new Sprite(drones_sheet.textures.atlas_pod_fan);
      addChild(rear_fan);
      rear_fan.rotation = Math.PI/10;
      rear_fan.pivot.set(rear_fan.width/2, rear_fan.height/2);
      rear_fan.x = base.texture.width/2 - base.texture.width*0.28;
      rear_fan.y = base.texture.height*0.33;

      front_fan = new Sprite(drones_sheet.textures.atlas_pod_fan);
      addChild(front_fan);
      front_fan.rotation = Math.PI/10;
      front_fan.pivot.set(front_fan.width/2, front_fan.height/2);
      front_fan.x = base.texture.width/2 + base.texture.width*0.28;
      front_fan.y = base.texture.height*0.33;

      pkg = new Sprite(drones_sheet.textures.atlas_package_sm);
      addChild(pkg);
      pkg.x = base.texture.width*0.42;
      pkg.y = base.texture.height*0.51;
      pkg.visible = false;

      this.pivot.set(base.texture.width/2, base.texture.height*0.33);
    });
  }

  public var has_package(get,set):Bool;
  public function set_has_package(v:Bool):Bool return (pkg.visible = v);
  public function get_has_package():Bool return pkg.visible;

  public var keys_enabled = false;
  var fan_r:Float = 0;
  var thrust:Float = 0;
  public function on_sim_tick() {
    if (!landed) {
      velocity.y += Const.gravity*(0.417);
      if (velocity.y > 4) velocity.y = 4; // terminal velocity
    }
    if (keys_enabled && Keys.up()) {
      landed = false;
      thrust = 0.8*thrust + 0.2*Const.gravity*2*(0.417);
    } else {
      thrust = 0.8*thrust;
    }
    velocity.y -= thrust;
    var dx = 0.0;
    if (keys_enabled) {
      if (Keys.right()) dx = 2*(0.417);
      if (Keys.left()) dx -= 2*(0.417);
    }
    fan_r = 0.9*fan_r + 0.1*dx;
    rear_fan.rotation = front_fan.rotation = fan_r / 2;
    this.rotation = 0.95*this.rotation + 0.05*(2*fan_r * thrust);
    velocity.x += thrust*(fan_r/2);
    y += velocity.y;
    velocity.x *= 0.99;
    x += velocity.x;

    do_drone();
  }

  public var landed = true;
  public function land(y:Float)
  {
    this.y = y;
    this.landed = true;
    velocity.set(0,0);
    thrust = 0;
    this.rotation = 0;
  }

  var current_drawing:{ drawing:DrawingType, p0:Point, t0:Float, drone:Sprite };
  public function apply_drawing(drawing:DrawingType)
  {
    var p0 = new Point(this.x, this.y);
    init_mini_drone();
    current_drawing = {
      drawing: drawing,
      t0: Timer.stamp(),
      p0: p0,
      drone: mini_drone
    }
  }

  public function init_mini_drone()
  {
    if (mini_drone==null) {
      mini_drone = new Sprite(drones_sheet.textures.atlas_mini_drone);
      mini_drone.pivot.set(mini_drone.texture.width/2, mini_drone.texture.height/2);
      mini_drone.x = this.x; mini_drone.y = this.y;
      parent.addChild(mini_drone);
    }
  }

  var mini_drone:Sprite;
  var tgt:Point = new Point();
  function do_drone()
  {
    if (mini_drone == null) return;
    tgt.x = this.x; tgt.y = this.y;
    if (current_drawing != null) {
      var dt = Timer.stamp() - current_drawing.t0;
      while (true) {
        var pt = current_drawing.drawing.pts[current_drawing.drawing.idx];
        if (pt.t > dt) break;
        current_drawing.drawing.idx++;
        if (current_drawing.drawing.idx >= current_drawing.drawing.pts.length) {
          current_drawing = null;
          return;
        }
      }
      tgt.copyFrom(current_drawing.drawing.pts[current_drawing.drawing.idx].pt);
      tgt.x += current_drawing.p0.x;
      tgt.y += current_drawing.p0.y;
    }
    mini_drone.x = 0.6*mini_drone.x + 0.4*tgt.x;
    mini_drone.y = 0.6*mini_drone.y + 0.4*tgt.y;
  }
}
