package drone;

class Score extends Sprite
{
  public static var singleton = new Score();

  var text:Text;
  var score:Int = 0;

  public function new()
  {
    super();

    setup_text();
    reset();
  }

  function setup_text()
  {
    var style = new TextStyle({
      fontFamily: 'VT323',
      fontSize: 28,
      fontStyle: 'italic',
      fontWeight: 'bold',
      fill: ['#ffffff', '#5588cc'], // gradient
      dropShadow: true,
      dropShadowColor: '#000000',
      dropShadowBlur: 2,
      dropShadowAngle: Math.PI / 6,
      dropShadowDistance: 1
    });

    text = new Text("", style);
    addChild(text);
  }

  function redraw()
  {
    var t:String = '${ score }';
    while (t.length < 5) t = '0'+t;
    text.text = t;
  }

  public function increment(v:Int) {
    score += v;
    if (score < 0) score = 0;
    redraw();
  }

  function reset() {
    score = 0;
    redraw();
  }
}
