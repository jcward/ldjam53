package drone;

class WarnLight extends AnimatedSprite
{
  public function new(sheet:Spritesheet)
  {

    var txts: Array<Texture> = [
      sheet.textures.atlas_warn_light1,
      sheet.textures.atlas_warn_light2,
      sheet.textures.atlas_warn_light3,
      sheet.textures.atlas_warn_light4,
      sheet.textures.atlas_warn_light5,
      sheet.textures.atlas_warn_light6,
      sheet.textures.atlas_warn_light7,
      sheet.textures.atlas_warn_light8,
    ];
    super(txts);
    this.loop = true;
    this.pivot.set(0, 20);
    this.animationSpeed = 0.15 + Math.random()*0.1;
    this.gotoAndPlay(Math.floor(txts.length*Math.random()));
  }
}
