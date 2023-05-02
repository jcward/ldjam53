package drone;

import util.DialogBox;

class Level4 extends AbsLevel
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
      util.DialogBox.modal('Level 4 - Tight Squeeze', 'Things can get pretty tight in the big city. Think you\'re a flying ace, kid?', after_dialog);
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
    // Foreground buildings
    var num_blds = 1;
    var pad = (Const.WIDTH - num_blds*drones_sheet.textures.atlas_building_b.width)/(num_blds+1);
    var col_rects = [];
    for (i in 0...2) {
      var b = new Sprite(drones_sheet.textures.atlas_building_b);
      world_cont.addChild(b);
      b.y = Const.PIXI_HEIGHT - b.height - 0;
      b.x = -110 + i*715;
      col_rects.push(new Rectangle(b.x, b.y, b.width, b.height));
    }
    Collisions.set_col_rects(col_rects);

    // Starting pad
    add_pad(new LandingPad({ x:pod.x, y:Const.PIXI_HEIGHT, is_landable: true }));
    pads[0].has_landed = true; // no points for the initial pad
    add_pad(new LandingPad({ x:pod.x*0.8, y: Const.PIXI_HEIGHT - 150, is_landable: true }));
    add_pad(new LandingPad({ x:pod.x*1.2, y: Const.PIXI_HEIGHT - 150, is_landable: true }));
    add_pad(new LandingPad({ x:pod.x*0.25, y: Const.PIXI_HEIGHT - 300, is_landable: true }));
    add_pad(new LandingPad({ x:pod.x*1.75, y: Const.PIXI_HEIGHT - 300, is_landable: true }));
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
        util.DialogBox.modal('Level 4 Success - The End ... ?', 'You\'ve reached the end of this LDJAM prototype. I ran out of time! But I have so many more ideas to implement - check back for more levels in the post-JAM edition!', function() {
          pod.keys_enabled = true;
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
      util.DialogBox.modal('Level4 Failed', '${ phrases.sample() } Alright, try again!', function() {
        this.parent.removeChild(this);
        Const.app.stage.addChild(new Level4());
      });
    }, 2000);
  }
}
