package drone;

class LandingPad extends Sprite
{
  public var has_landed = false;
  public var opts:PadOpts;

  public function new(opts:PadOpts=null)
  {
    super();

    if (opts==null) opts = { };
    if (!Reflect.hasField(opts, "is_landable")) opts.is_landable = false;
    if (!Reflect.hasField(opts, "left_light")) opts.left_light = true;
    if (!Reflect.hasField(opts, "right_light")) opts.right_light = true;
    this.opts = opts;

    if (Reflect.hasField(opts, "x")) this.x = opts.x;
    if (Reflect.hasField(opts, "y")) this.y = opts.y;

    AtlasMgr.load_atlas('drones', function(sheet) {
      this.texture = this.opts.is_landable ? sheet.textures.atlas_landing_pad : sheet.textures.atlas_barrier;
      this.pivot.x = this.texture.width/2;
      this.pivot.y = this.texture.height;

      if (this.opts.left_light) {
        var left = new WarnLight(sheet);
        left.scale.set(-0.75, 0.75);
        left.y = 5;
        addChild(left);
      }
      if (this.opts.right_light) {
        var right = new WarnLight(sheet);
        right.scale.set(0.75, 0.75);
        right.x = this.texture.width;
        right.y = 5;
        addChild(right);
      }
    });

  }
}

typedef PadOpts = {
  ?is_landable: Bool,
  ?is_package_src: Bool,
  ?on_package_delivered: Void->Void,
  ?left_light: Bool,
  ?right_light: Bool,
  ?x: Float,
  ?y: Float
}
