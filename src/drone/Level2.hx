package drone;

import util.DialogBox;

class Level2 extends AbsLevel
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
      after_dialog();
    } else {
      util.DialogBox.modal('Level 2 - Barriers', 'You\'re going to have to fly in some tight spaces, kid. Land on all the pads, but don\'t hit the barriers.', after_dialog);
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
    // Starting pad
    add_pad(new LandingPad({ x:pod.x, y:Const.PIXI_HEIGHT, is_landable: true }));
    pads[0].has_landed = true; // no points for the initial pad
    add_pad(new LandingPad({ x:pod.x*0.75, y: Const.PIXI_HEIGHT - 150, is_landable: false }));
    add_pad(new LandingPad({ x:pod.x*1.0, y: Const.PIXI_HEIGHT - 150, is_landable: false }));
    add_pad(new LandingPad({ x:pod.x*1.25, y: Const.PIXI_HEIGHT - 150, is_landable: false }));
    add_pad(new LandingPad({ x:pod.x, y: Const.PIXI_HEIGHT - 300, is_landable: true }));
  }

  function after_dialog()
  {
    start_level_time_ixn();
  }

  var t0 = haxe.Timer.stamp();

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
        util.DialogBox.modal('Level 2 Success', 'Fancy flying! Ok, let\'s get down to business and ship some packages.', function() {
          this.parent.removeChild(this);
          Const.app.stage.addChild(new Level3());
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
                     "Not the worst I've ever seen.",
                     "I said gentle, kid. Yeesh. "];
      util.DialogBox.modal('Level 2 Failed', '${ phrases.sample() } Alright, try again!', function() {
        this.parent.removeChild(this);
        Const.app.stage.addChild(new Level2());
      });
    }, 2000);
  }
}
