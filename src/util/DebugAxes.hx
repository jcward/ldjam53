package util;

class DebugAxes extends Graphics
{
  public function new()
  {
    super();

    this.lineStyle(1, 0xff0000);
    this.moveTo(0,0);
    this.lineTo(10,0);
    this.lineStyle(1, 0xaa0000);
    this.moveTo(-10,0);
    this.lineTo(0,0);

    this.lineStyle(1, 0x00ff00);
    this.moveTo(0,0);
    this.lineTo(0,10);
    this.lineStyle(1, 0x00aa00);
    this.moveTo(0,-10);
    this.lineTo(0,0);
  }
}
