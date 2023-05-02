package drone;

import util.DialogBox;

class AbsLevel extends Sprite
{
  private static inline var INIT_LIFE = 10.0;

  var drones_sheet:Spritesheet;
  var world_cont:Sprite;
  var pod:Pod;
  var MAX_Y_SCROLL:Float;
  var particles:AirParticles;
  var pads:Array<LandingPad> = [];
  var clouds:Clouds;
  var life = INIT_LIFE;
  var lifebar:IndicatorBar;

  var y_parallax:Array<{ s:Sprite, factor:Float }> = [];

  public function new(focus_enabled = true)
  {
    super();

    if (focus_enabled) focus = new Focus();

    AtlasMgr.load_atlas('drones', on_sheet_loaded);
  }

  function on_sheet_loaded(drones:Spritesheet)
  {
    Const.app.ticker.add(untyped on_frame);

    this.drones_sheet = drones;

    // Layers
    setup_backdrop();

    world_cont = new Sprite();
    addChild(world_cont);

    setup_pod();
    setup_objects();
    world_cont.addChild(pod);

    setup_particles();

    addChild(Score.singleton);
    Score.singleton.x = Score.singleton.y = 5;

    var lw = 60;
    lifebar = new IndicatorBar(lw, 6, 0x33aa44);
    lifebar.set_pct(1.0);
    lifebar.x = 5 + lw/2;
    lifebar.y = 30;
    addChild(lifebar);

    after_setup();
  }

  var ixn_t0:Float; // Interaction time, for calculating time bonus
  function start_level_time_ixn()
  {
    ixn_t0 = Timer.stamp();
    pod.keys_enabled = true;
  }

  function score_bonuses(after_time_bonus:Void->Void)
  {
    var dt = Math.floor(10*(Timer.stamp() - ixn_t0))/10;
    var pts = Math.floor(1000 / Math.sqrt(dt));
    var dopts = { bkg_color: 0x225588, width: 300 };
    DialogBox.modal('Completed in ${ dt } seconds!', '${ pts } bonus points!', dopts, function() {
      Score.singleton.increment(pts);
      if (life == INIT_LIFE) {
        DialogBox.modal('NO DAMAGE!', '1500 bonus points!', dopts, function() {
          Score.singleton.increment(1500);
          after_time_bonus();
        });
      } else {
        after_time_bonus();
      }
    });
  }

  function after_setup()
  {
    throw 'override';
  }

  function setup_sky()
  {
    var sky = new Sprite(drones_sheet.textures.atlas_blue_sky_strip);
    addChild(sky);
    sky.scale.set(Const.WIDTH / sky.width, Const.PIXI_HEIGHT / sky.height);

    clouds = new Clouds();
    addChild(clouds);
  }

  function setup_backdrop() {
    setup_sky();
  }

  function setup_pod() {
    pod = new Pod();
  }

  function setup_objects() {
    throw 'override';
  }

  function setup_particles()
  {
    particles = new AirParticles(pod);
    addChild(particles);
  }

  var last_frame_t:Float = 0.0;
  var collected_dt:Float = 0.0;
  function on_frame(ignore_dt:Float)
  {
    if (last_frame_t==0) {
      last_frame_t = Timer.stamp();
      return;
    }
    var t = Timer.stamp();
    var dt_ms = (t - last_frame_t)*1000;
    last_frame_t = t;
    collected_dt += dt_ms;
    while (collected_dt >= 8) { // 8ms => 125fps
      on_sim_tick();
      collected_dt -= 8;
    }
  }

  function on_sim_tick()
  {
    if (Keys.singleton.mouse_is_down) {
      if (!is_focus) {
        // is_focus = true;
      }
      return; // stops time!
    } else {
      is_focus = false;
    }

    check_remove_tgt_pad();
    pod.on_sim_tick();
    if (clouds != null) clouds.on_tick(0.417); // TODO: remove dt?
    check_world_move();
    check_pads();
    check_bounds_death();
  }

  var pkg_tgt_pad:LandingPad;
  var num_delivered = 0;
  function check_remove_tgt_pad() {
    if (pkg_tgt_pad != null && pkg_tgt_pad.has_landed && !pod.landed) {
      pads.remove(pkg_tgt_pad);
      pkg_tgt_pad.parent.removeChild(pkg_tgt_pad);
      pkg_tgt_pad = null;
    }
  }

  var is_focus(get, set):Bool;
  var focus:Focus;
  var timer:IndicatorBar;
  function get_is_focus():Bool return focus != null && focus.parent != null;
  function set_is_focus(v:Bool):Bool {
    if (is_focus == v) return v;
    if (v) {
      focus.start_drawing(this, pod.x, pod.y);
    } else {
      focus.end_drawing(pod);
    }
    return v;
  }

  function add_pad(p:LandingPad) {
    pads.push(p);
    world_cont.addChild(p);
  }

  function check_pads()
  {
    if (pod.landed || is_dead()) return;

    Collisions.check_pads(pod, pads, damage, on_land);
  }

  function on_land(pad:LandingPad)
  {
  }

  function check_world_move()
  {
    var b4 = world_cont.y;
    var top_pad = (Const.PIXI_HEIGHT / 3) * 1+Math.sqrt(Math.abs(pod.velocity.y));
    if (pod.y < top_pad) {
      world_cont.y = Math.min(MAX_Y_SCROLL, top_pad - pod.y);
      //} else if (pod.y - world_cont.y > Const.PIXI_HEIGHT - 100) {
      //  world_cont.y = pod.y - (Const.PIXI_HEIGHT - 100);
    }
    var dy = world_cont.y - b4;

    // Move particles at 100%
    for (ff in @:privateAccess particles.ffs) {
      ff.s.y += dy;
    }

    // Move clouds at 50% (parallax)
    if (clouds != null) {
      for (cloud in @:privateAccess clouds.clouds) {
        cloud.y += dy*0.5;
      }
    }

    for (itm in y_parallax) {
      itm.s.y += dy*itm.factor;
    }
  }

  function check_bounds_death()
  {
    if (pod.landed || is_dead()) return;
    Collisions.check_bounds_death(pod, damage);
  }

  function is_dead() return life <= 0;

  function damage(amt:Float)
  {
    if (is_dead()) return;
    @:privateAccess pod.base.tint = 0xff4444;
    Timer.delay(function() {
      if (is_dead()) return;
      @:privateAccess pod.base.tint = 0xffffff;
    }, 100);
    life -= amt;
    if (is_dead()) {
      life = 0;
      die();
    }

    lifebar.set_pct(life / INIT_LIFE);
  }

  function die()
  {
    pod.keys_enabled = false;
    @:privateAccess pod.base.tint = 0x0;
    @:privateAccess pod.rear_fan.tint = 0x0;
    @:privateAccess pod.front_fan.tint = 0x0;
    // Extend with custom retry
  }
}
