package drone;

class IndicatorBar extends Graphics
{
  var pct(default,set) = 1.0;
  var opts:{ width:Float, height:Float, color:Int };

  public function new(width:Float, height:Float, color:Int)
  {
    opts = { width: width, height: height, color: color };

    super();
    redraw();
  }

  public function setup_timer(dt:Int, callback:Void->Void)
  {
    var t0 = haxe.Timer.stamp();
    function on_frame() {
      pct = 1000*(haxe.Timer.stamp() - t0) / dt;
      if (pct>=1.0) {
        callback();
      } else {
        haxe.Timer.delay(on_frame, 33);
      }
    }
    haxe.Timer.delay(on_frame, 33);
  }

  public function set_pct(val:Float):Float
  {
    if (val > 1.0) val = 1.0;
    if (val < 0) val = 0;
    this.pct = val;
    redraw();
    return val;
  }

  function redraw()
  {
    this.clear();
    this.beginFill(0x0, 0.7);
    var ww = opts.width;
    var hh = opts.height;
    this.drawRoundedRect(-ww/2, -hh/2, ww, hh, 5);
    this.endFill();
    this.beginFill(opts.color, 1.0);
    ww = (ww - 1)*pct;
    hh -= 2;
    this.drawRoundedRect(-ww/2, -hh/2, ww, hh, 5);
    this.endFill();
  }
}
