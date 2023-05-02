package drone;

import util.DialogBox;

class Level1 extends AbsLevel
{
  static var skip_intro = false;

  public function new()
  {
    MAX_Y_SCROLL = 100;
    if (window.location.search.indexOf("skip")>=0) skip_intro = true;

    super(false);
  }

  override function after_setup()
  {
    if (skip_intro) {
      after_dialog2();
    } else {
      util.DialogBox.modal('Level 1 - First Day On The Job', 'Hey kid, you awake? You might still be feeling the effects of the NeuroPilot(TM) implants. Anyway, welcome to FedUp - absolutely, positively, yadda yadda drone delivery.', after_dialog1);
      cleanup_blink = setup_blink();
    }
  }

  override function setup_pod()
  {
    super.setup_pod();
    pod.x = Const.WIDTH/2;
    pod.y = Const.PIXI_HEIGHT - 45;
  }

  override function setup_objects()
  {
    add_pad(new LandingPad({ x:pod.x, y:Const.PIXI_HEIGHT, is_landable: true }));
    pads[0].has_landed = true; // no points for the initial pad
    add_pad(new LandingPad({ x:pod.x/2, y: Const.PIXI_HEIGHT - 100, is_landable: true }));
    add_pad(new LandingPad({ x:pod.x*1.5, y: Const.PIXI_HEIGHT - 200, is_landable: true }));
  }

  function setup_blink()
  {
    var blink_top = new Sprite(drones_sheet.textures.atlas_blink);
    var blink_bottom = new Sprite(drones_sheet.textures.atlas_blink);
    blink_top.scale.set(Const.WIDTH / blink_top.width, Const.WIDTH / blink_top.width);
    blink_bottom.scale.set(blink_top.scale.x, -blink_top.scale.y);
    blink_bottom.y = blink_bottom.height;
    addChild(blink_top);
    addChild(blink_bottom);
    var t0 = haxe.Timer.stamp();
    var ii = window.setInterval(function() {
      blink_top.y--;
      blink_bottom.y++;
    }, 30);
    return function() {
      window.clearInterval(ii);
      removeChild(blink_top);
      removeChild(blink_bottom);
    };
  }

  var cleanup_blink:Void->Void;
  function after_dialog1() {
    util.DialogBox.modal('Level 1 - First Day On The Job', 'Your FedUp 5000 is a state of the art delivery drone. Handles like a beauty... but a little delicate. Land gently, and only on the landing pads. Touch down on each pad, then back to the lower pad, got it?', after_dialog2);
  }

  function after_dialog2()
  {
    if (cleanup_blink != null) cleanup_blink();
    start_level_time_ixn();
    keys_hint = new Sprite(drones_sheet.textures.atlas_keys_hint);
    keys_hint.pivot.set(keys_hint.width/2, keys_hint.height/2);
    keys_hint.x = Const.WIDTH/2;
    keys_hint.y = keys_hint.height*2;
    addChild(keys_hint);
  }

  var keys_hint:Sprite;
  var t0 = haxe.Timer.stamp();

  override function on_tick(dt:Float)
  {
    super.on_tick(dt);

    if (keys_hint != null) {
      keys_hint.alpha = 0.5+0.5*Math.sin((haxe.Timer.stamp() - t0)*2);
      if (Keys.singleton.num_keys_down > 0) {
        keys_hint.parent.removeChild(keys_hint);
        keys_hint = null;
      }
    }
  }

  override function on_land(pad:LandingPad)
  {
    var success = pad == pads[0];
    for (lp in pads) {
      if (lp.opts.is_landable && !lp.has_landed) success = false;
    }
    if (success) {
      pod.keys_enabled = false;
      score_bonuses(function() {
        skip_intro = true;
        util.DialogBox.modal('Level 1 Success', 'You\'ve got potential, kid! But that\'s not all there is to it...', function() {
          this.parent.removeChild(this);
          Const.app.stage.addChild(new Level2());
        });
      });
    }
  }

  override function die()
  {
    super.die();

    Timer.delay(function() {
      skip_intro = true;
      var phrases = ["Watch it, kid, these things are expensive!",
                     "Hey, first-day jitters? I get it.",
                     "Not the worst I've ever seen. But not great either.",
                     "I said gentle, kid. Yeesh."];
      util.DialogBox.modal('Level 1 Failed', '${ phrases.sample() } Alright, try again!', function() {
        this.parent.removeChild(this);
        Const.app.stage.addChild(new Level1());
      });
    }, 2000);
  }
}
