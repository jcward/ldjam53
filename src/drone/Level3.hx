package drone;

import global.PIXI;
import global.pixi.interaction.InteractionEvent;
import util.DialogBox;

class Level3 extends AbsLevel
{
  static var skip_intro = false;

  public function new()
  {
    MAX_Y_SCROLL = Const.PIXI_HEIGHT;
    if (window.location.search.indexOf("skip")>=0) skip_intro = true;

    super();
  }

  override function after_setup()
  {
    if (skip_intro) {
      after_dialog();
    } else {
      do_dialog();
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
    var street = new Sprite(drones_sheet.textures.atlas_street);

    // Background / darkened buildings
    for (i in 0...4) {
      var b = new Sprite(drones_sheet.textures.atlas_building_b_bkg);
      world_cont.addChild(b);
      b.scale.set(0.9, 0.9);
      b.y = Const.PIXI_HEIGHT - b.height - street.texture.height*0.5;
      b.x = 110 + i*b.width;
      y_parallax.push({ s:b, factor:-0.2 });
    }

    world_cont.addChild(street);
    street.y = Const.PIXI_HEIGHT - street.texture.height;
    street.scale.x = Const.WIDTH / street.texture.width;

    // Foreground buildings
    var num_blds = 1;
    var pad = (Const.WIDTH - num_blds*drones_sheet.textures.atlas_building_b.width)/(num_blds+1);
    var col_rects = [];
    for (i in 0...num_blds) {
      var b = new Sprite(drones_sheet.textures.atlas_building_b);
      world_cont.addChild(b);
      b.y = Const.PIXI_HEIGHT - b.height - street.texture.height;
      b.x = pad + i*(b.width+pad) + 200;
      col_rects.push(new Rectangle(b.x, b.y, b.width, b.height));
    }
    Collisions.set_col_rects(col_rects);

    var truck = new Sprite(drones_sheet.textures.atlas_fedup_truck);
    world_cont.addChild(truck);
    truck.y = Const.PIXI_HEIGHT - truck.texture.height;

    add_pad(new LandingPad({ x:pod.x, y:Const.PIXI_HEIGHT, is_landable: true }));
    pads[0].has_landed = true; // no points for the initial pad
    var truck_pad = new LandingPad({ x:truck.texture.width - 35, y:Const.PIXI_HEIGHT - truck.texture.height, is_landable: true, is_package_src: true });
    add_pad(truck_pad);
  }

  override function on_land(pad:LandingPad)
  {
    if (pad.opts.is_package_src && !pod.has_package) {
      if (num_delivered >= 3) {
        DialogBox.label(pod, 0, 44, 'ALL DONE!', 0x22cc22, "#000000");
      } else {
        pod.has_package = true;
        pkg_tgt_pad = new LandingPad({ is_landable: true, x:520, y:-30 });
        add_pad(pkg_tgt_pad);
      }
    }

    if (pad==pkg_tgt_pad && pod.has_package) {
      pod.has_package = false;
      Score.singleton.increment(100);
      num_delivered++;
    }

    var success = (pad==pads[0] && num_delivered>=3);
    if (success) {
      pod.keys_enabled = false;
      score_bonuses(function() {
        skip_intro = true;
        util.DialogBox.modal('Level 3 Success', 'Good job, kid! Maybe it\'s time to give you a real assignment!', function() {
          this.parent.removeChild(this);
          Const.app.stage.addChild(new Level4());
        });
      });
    }

  }

  var mailboxes:Array<Mailbox> = [];
  function add_mailbox(x:Float, y:Float) {
    var m = new Mailbox();
    mailboxes.push(m);
    m.x = x;
    m.y = y;
    world_cont.addChild(m);
  }

  function do_dialog() {
    util.DialogBox.modal('Level 3 - Ship It Real Good', 'Pick up three packages from the truck, and deliver them to the mailbox on the top of the building. Remember, time is money! Chop chop!', after_dialog);
  }

  function after_dialog()
  {
    start_level_time_ixn();
  }

  var keys_hint:Sprite;
  var t0 = haxe.Timer.stamp();

  override function die()
  {
    super.die();

    Timer.delay(function() {
      skip_intro = true;
      util.DialogBox.modal('Level 3 Failed', 'Neither rain, nor snow, nor sleet, nor FAIL. None shall stop the drone-borne mail! Try again!', function() {
        this.parent.removeChild(this);
        Const.app.stage.addChild(new Level3());
      });
    }, 2000);
  }
}

// Old Dialog:
//   util.DialogBox.modal('Level 3 - Ship It Real Good', 'Pick up the package from the truck and deliver it to the mailbox. But your FedUp 5000 is a heavy transport, it doesn\'t deal with the little mailbox lids. For that, you\'re going to have to use a FedOpener XS.', do_dialog2);
//   util.DialogBox.modal('Level 3 - Ship It Real Good', 'The FedOpener XS is neuro-controlled. State of the art! Fly near the mailbox, then use your mouse to draw a flight plan for the XS. Once open, drop the package in the box.', after_dialog);
