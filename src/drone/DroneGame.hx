package drone;

class DroneGame
{
  var app:Application;

  public function new()
  {
    this.app = Const.app;

    if (window.location.search.indexOf("level=4")>=0) {
      app.stage.addChild(new Level4());
    } else if (window.location.search.indexOf("level=3")>=0) {
      app.stage.addChild(new Level3());
    } else if (window.location.search.indexOf("level=2")>=0) {
      app.stage.addChild(new Level2());
    } else {
      app.stage.addChild(new Level1());
    }
  }
}
