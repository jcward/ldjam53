package drone;

class Clouds extends Sprite
{
  var drones_sheet:Spritesheet;
  var clouds:Array<{ dx:Float, s:Sprite, y:Float, yr0:Float, yrr:Float, yt:Float, ya:Float }> = [];
  public function new()
  {
    super();

    AtlasMgr.load_atlas('drones', function(sheet) {
      drones_sheet = sheet;
      var textures:DynamicAccess<Texture> = sheet.textures;

      for (i in 0...3) {
        var spr = new Sprite();
        spr.texture = textures['atlas_cloud${ i+1 }'];
        spr.x = (i*Const.WIDTH/3) * (0.9 + Math.random()*0.2);
        clouds.push({
          s:spr,
          dx:0.04,
          y:Math.random()*100,
          yr0: Math.random()*Math.PI*2,
          yrr: Math.random()*0.004 + 0.004,
          yt: 0,
          ya: 8+Math.random()*12
        });
        addChild(spr);
      }
    });
  }

  public function on_tick(dt:Float) {
    for (cloud in clouds) {
      cloud.s.x += cloud.dx*dt;
      if (cloud.s.x > Const.WIDTH) cloud.s.x -= (Const.WIDTH + cloud.s.texture.width*1.2);
      cloud.yt += cloud.yrr * dt;
      cloud.s.y = cloud.y + Math.sin(cloud.yr0 + cloud.yt)*cloud.ya;
    }
  }
}
