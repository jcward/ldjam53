package drone;

import util.DialogBox;

class Collisions
{
  private static inline var DAMAGE_MULT = 2.5;
  private static var last_damage_t = 0.;

  // Throttle collision damage to every 0.5 sec max
  private static function limit_damage(v:Float, on_damage:Float->Void) {
    var t = Timer.stamp();
    if (t - last_damage_t > 0.5) {
      last_damage_t = t;
      on_damage(v);
      Score.singleton.increment(-5);
    }
  }

  public static function crash_v_to_damage(vel:Float):Float
  {
    if (vel < 0.25) vel = 0.25;
    return Math.abs(vel)*DAMAGE_MULT;
  }

  public static function check_pads(pod:Pod, pads:Array<LandingPad>, on_damage:Float->Void, on_land:LandingPad->Void)
  {
    for (lp in pads) {
      var dx = Math.abs(pod.x - lp.x);
      var on_pad = dx < lp.texture.width/4;
      var hit_pad = dx < (@:privateAccess pod.base).width*0.55;

      var at_landing_level = pod.y > lp.y - 44 && pod.y < lp.y - 20;
      var at_wing_level = pod.y > lp.y - 18 && pod.y < lp.y;

      // Descending on the pad
      if (at_landing_level && on_pad) {
        if (pod.velocity.y > 2.5 || !lp.opts.is_landable) {
          pod.y = lp.y - 44;
          pod.velocity.set(pod.velocity.x*0.7,-pod.velocity.y*0.6);
          DialogBox.label(pod, 0, 44, 'TOO FAST!', 0xee0000, "#000000");
          limit_damage(crash_v_to_damage(pod.velocity.y), on_damage);
        } else {
          // Successful landing!
          if (!lp.has_landed) { // Score only on the first landing
            lp.has_landed = true;
            if (pod.velocity.y < 1) {
              DialogBox.label(pod, 0, 44, 'EXCELLENT!', 0x22cc22, "#000000");
              Score.singleton.increment(50);
            } else {
              DialogBox.label(pod, 0, 44, 'NICE!', 0x55cc99, "#000000");
              Score.singleton.increment(30);
            }
          }
          pod.land(lp.y - 44);
          on_land(lp);
        }
      } else if (at_wing_level && hit_pad && !on_pad) {
        // Hit from above
        pod.velocity.set(pod.velocity.x*0.7,-Math.abs(pod.velocity.y*0.7));
        DialogBox.label(pod, 0, 44, 'OUCH!', 0xee0000, "#000000");
        limit_damage(crash_v_to_damage(pod.velocity.y), on_damage);
      }
      if (hit_pad && pod.y < lp.y + 10 && pod.y > lp.y) {
        // Hit pad from underneath
        pod.velocity.set(pod.velocity.x*0.7,Math.abs(pod.velocity.y*0.5));
        limit_damage(crash_v_to_damage(pod.velocity.y), on_damage);
      }
    }

    for (bnd in [new Rectangle(pod.x - 30, pod.y - 30, 60, 55), /* pod core */
                 new Rectangle(pod.x - 80, pod.y - 20, 160, 25)]) { /* pod core */
    var tmp_r:Rectangle = new Rectangle();
    for (r in col_rects) {
      tmp_r.copyFrom(r);
      var is_overlap = rect_overlap(bnd, r);
      if (is_overlap) {
        var direction:Point = null;
        tmp_r.x += 10;
        if (!rect_overlap(bnd, tmp_r)) {
          direction = new Point(-0.8, pod.velocity.y); // we hit it on the left, need to bounce left
        }
        tmp_r.x -= 20;
        if (direction==null && !rect_overlap(bnd, tmp_r)) {
          direction = new Point(0.8, pod.velocity.y); // we hit it on the right, need to bounce right
        }
        tmp_r.x += 10;
        tmp_r.y += 10;
        if (direction==null && !rect_overlap(bnd, tmp_r)) {
          direction = new Point(pod.velocity.x, -0.8); // we hit it on the top, need to bounce up
        }
        tmp_r.y -= 20;
        if (direction==null && !rect_overlap(bnd, tmp_r)) {
          direction = new Point(pod.velocity.x, 0.8); // we hit it on the bottom, need to bounce down
        }
        pod.velocity.set(direction.x,direction.y);
        limit_damage(crash_v_to_damage(Math.max(pod.velocity.y, pod.velocity.x)), on_damage);
        break;
      }
    }
    }
  }

  public static function check_bounds_death(pod:Pod, on_damage:Float->Void)
  {
    if (pod.y > Const.PIXI_HEIGHT - 35) {
      pod.y = Const.PIXI_HEIGHT - 35;
      pod.velocity.set(pod.velocity.x*0.7,-pod.velocity.y*0.6);
      limit_damage(crash_v_to_damage(pod.velocity.y), on_damage);
    }
  }

  private static var col_rects:Array<Rectangle> = [];
  public static function set_col_rects(rects:Array<Rectangle>)
  {
    col_rects = rects;
  }

  public static function rect_overlap(rectA:Rectangle, rectB:Rectangle):Bool
  {
    if (rectA.width <= 0 || rectA.height <= 0 || rectB.width <= 0 || rectB.height <= 0) return false;

    var aLeftOfB = (rectA.x + rectA.width) < rectB.x;
    var aRightOfB = rectA.x > (rectB.x + rectB.width);
    var aAboveB = rectA.y > (rectB.y + rectB.height);
    var aBelowB = (rectA.y + rectA.height) < rectB.y;

    return !( aLeftOfB || aRightOfB || aAboveB || aBelowB );
  }

}
