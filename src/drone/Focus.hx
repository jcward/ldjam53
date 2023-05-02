package drone;

import global.pixi.interaction.InteractionEvent;

class Focus extends Sprite
{
  var drones_sheet:Spritesheet;
  public var graphics:Graphics;

  public function new()
  {
    super();

    graphics = new Graphics();
    AtlasMgr.load_atlas('drones', function(sheet) {
      drones_sheet = sheet;
      var s = new Sprite(sheet.textures.atlas_focus);
      addChild(s);
      addChild(graphics);
    });
  }

  var timer:IndicatorBar;
  var drawing_data:DrawingType = { idx:0, pts:[], t0:0 };
  var MAX_DIST = 100;
  public function start_drawing(parent:Sprite, x:Float, y:Float)
  {
    parent.addChild(this);
    reset_drawing_data();
    this.interactive = true;
    this.graphics.clear();

    this.graphics.beginFill(0xffffff, 1.0);
    for (r in 0...60) {
      var rad = r/30*Math.PI;
      this.graphics.drawCircle(100+MAX_DIST*Math.cos(rad), 100+MAX_DIST*Math.sin(rad), 1.5);
    }
    this.graphics.endFill();

    this.interactiveChildren = true;
    timer = new IndicatorBar(Const.WIDTH / 2, 20, Const.ORANGE);
    timer.x = Const.WIDTH / 2;
    timer.y = Const.PIXI_HEIGHT - 30;
    addChild(timer);
    timer.setup_timer(1000, ()->{});
    this.addListener("mousemove", handle_focus_draw);
  }

  public function end_drawing(pod:Pod)
  {
    if (this.parent!=null) this.parent.removeChild(this);
    if (timer != null) { timer.parent.removeChild(timer); timer = null; }
    this.removeListener("mousemove", handle_focus_draw);
    if (drawing_data.pts.length > 0) {
      drawing_data.idx = 0;
      var origin = drawing_data.pts[0].pt.clone();
      for (dpt in drawing_data.pts) {
        dpt.pt.x -= origin.x;
        dpt.pt.y -= origin.y;
      }
      if (drawing_data.pts.length > 0) {
        pod.apply_drawing(drawing_data);
      }
      reset_drawing_data();
    }
  }

  function reset_drawing_data() {
    drawing_data = { idx:0, pts:[], t0:Timer.stamp() };
  }

  function handle_focus_draw(e:InteractionEvent)
  {
    var pt = e.data.getLocalPosition(this);
    drawing_data.pts.push({ pt:pt, t: Timer.stamp() - drawing_data.t0 });
    this.graphics.beginFill(Const.ORANGE, 1.0);
    this.graphics.drawCircle(pt.x, pt.y, 5);
    this.graphics.endFill();
  }

}
