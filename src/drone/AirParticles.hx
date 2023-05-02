package drone;

class AirParticles extends Sprite
{
  var drones_sheet:Spritesheet;

  var pod:Pod;
  var ffs:Array<{ s:Sprite,
    dt:Float,
    radius:Float,
    speed:Float,
    dx:Float,
    dy:Float,
    vel: Point,
    ss:Float
  }>;

  public function new(pod:Pod)
  {
    super();
    this.pod = pod;

    AtlasMgr.load_atlas("drones", function(s) {
      drones_sheet = s;
      setup_leafs();
    });
  }

  var leaf_conts:Array<Sprite> = [];
  function setup_leafs()
  {
    var c_cont = new Sprite();
    this.addChild(c_cont);
    // TODO - pub_sub.publish(SHOW_WEATHER(c_cont));

    // Interpolated - some constant, somewhat dependant on screen size
    var size_scale = 1.0; // + 0.5*Math.max(WW, Const.PIXI_HEIGHT)/1500;
    var amt = 400;

    var now = Timer.stamp();
    ffs = [];
    for (i in 0...amt) {
      var txts: Array<Texture> = [ drones_sheet.textures.atlas_leaf1, drones_sheet.textures.atlas_leaf2, drones_sheet.textures.atlas_leaf3, drones_sheet.textures.atlas_leaf4, drones_sheet.textures.atlas_leaf5 ];
      var sprite = new AnimatedSprite(txts);
      sprite.loop = true;
      var speed_scale = 0.5 + Math.random()*0.2; // little ones move slower
      sprite.scale.x = sprite.scale.y = speed_scale * size_scale;
      sprite.animationSpeed = 0.1 + Math.random()*0.15;
      sprite.gotoAndPlay(Math.floor(txts.length*Math.random()));
      c_cont.addChild(sprite);
      sprite.x = Const.WIDTH*(0 + Math.random()*1.0);
      sprite.y = Const.PIXI_HEIGHT*(0 + Math.random()*1.0);
      sprite.alpha = 0.4 + 0.4*Math.random();
      ffs.push({ s:sprite,
                 dt:Math.random()*20,
                 radius:(0.5+Math.random()*1.2)*size_scale, // chaos
                 speed: 0.1+Math.random()*0.1,
                 dx:(Math.random()*1 + 5) / 9,
                 dy:(Math.random()*1 + 1) / 9,
                 vel: new Point(0,0),
                 ss:speed_scale
                 });
    }
    var p0 = new Point(0,0);
    var p0_b = new Point(0,0);
    var p1 = new Point(0,0);
    var p1_b = new Point(0,0);
    var pff = new Point(0,0);
    function do_anim(params:Dynamic) {
      if (Keys.singleton.mouse_is_down) return; // stops time!
      if (this.parent == null) {
        Const.app.ticker.remove(untyped do_anim);
        return;
      }

      // Check for pod engine effects
      if (pod != null) {
        p0_b.x = p0.x = @:privateAccess pod.rear_fan.x;
        p0.y = @:privateAccess pod.rear_fan.y;
        p0_b.y = p0.y + 50;
        pod.localToGlobal(p0);
        pod.localToGlobal(p0_b);
        this.globalToLocal(p0);
        p1_b.x = p1.x = @:privateAccess pod.front_fan.x;
        p1.y = @:privateAccess pod.front_fan.y;
        p1_b.y = p1.y + 50;
        pod.localToGlobal(p1);
        pod.localToGlobal(p1_b);
        this.globalToLocal(p1);
        var fan_size = p0.distance(p1) / 3;
        var thrust = 0.5 + (@:privateAccess pod.thrust) * 5;
        for (ff in ffs) {
          pff.x = ff.s.x;
          pff.y = ff.s.y;
          var fan_dist = pff.distToSegment(p0, p0_b);
          if (fan_dist < fan_size) {
            var spd = 1; // fan_dist / fan_size;
            ff.vel.y = thrust * 1 * spd * Math.cos(@:privateAccess pod.fan_r);
            ff.vel.x = thrust * -1 * spd * Math.sin(@:privateAccess pod.fan_r);
          } else {
            fan_dist = pff.distToSegment(p1, p1_b);
            if (fan_dist < fan_size) {
              var spd = 1; //fan_dist / fan_size;
              ff.vel.y = thrust * 1 * spd * Math.cos(@:privateAccess pod.fan_r);
              ff.vel.x = thrust * -1 * spd * Math.sin(@:privateAccess pod.fan_r);
            }
          }
        }
      }

      var now = haxe.Timer.stamp();
      for (ff in ffs) {
        ff.s.scale.x = ff.s.scale.y = ff.ss * size_scale;
        ff.s.x += ff.dx*ff.s.scale.x/6 + Math.cos((now+ff.dt)*ff.speed)*ff.radius/12 + ff.vel.x;
        ff.s.y += ff.dy*ff.s.scale.x/6 + Math.sin(3*(now+ff.dt)*ff.speed)*ff.radius/12 + ff.vel.y;
        if (ff.s.x > Const.WIDTH) ff.s.x -= Const.WIDTH;
        if (ff.s.x < 0) ff.s.x += Const.WIDTH;
        if (ff.s.y < 0) ff.s.y += Const.PIXI_HEIGHT;
        if (ff.s.y > Const.PIXI_HEIGHT) {
          ff.s.y -= Const.PIXI_HEIGHT;
          ff.vel.y = ff.vel.y = 0; // wrap-around, lose fan effect
        }
        ff.vel.y *= 0.99;
        ff.vel.x *= 0.99;
      }
    }
    Const.app.ticker.add(untyped do_anim);
    leaf_conts.push(c_cont);
	}

}

