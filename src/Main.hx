package;

class Main
{
  public static function main() new Main();

  public function new()
  {
    haxe.Timer.delay(clear_loading, 50);
  }

  function clear_loading()
  {
    var loading:Element = document.body.querySelector(".loading");
    loading.classList.add('hide');
    Timer.delay(function() {
      loading.remove();
      setup_app();
    }, 450);
  }

  var game_cont:Element;
  function resize_game_cont(e=null) {
    var pad = 15;
    var FULL_HEIGHT = Const.PIXI_HEIGHT + Const.TYPE_HEIGHT;
    var sx = (window.innerWidth-2*pad) / Const.WIDTH;
    var sy = (window.innerHeight-2*pad) / (FULL_HEIGHT);
    var scale = Math.min(sx, sy);
    var dx = sy < sx ? (window.innerWidth-2*pad - Const.WIDTH*sy) / 2 : 0;

    game_cont.style.width = '${ Const.WIDTH }px';
    game_cont.style.height = '${ FULL_HEIGHT }px';
    game_cont.style.transform = 'scale(${ scale })';
    game_cont.style.top = '${ pad }px';
    game_cont.style.left = '${ pad + dx }px';
    game_cont.style.marginBottom = '${ 2*pad + FULL_HEIGHT*(scale - 1) }px';
  }

  function setup_app()
  {
    // Prevent right-click
    document.body.oncontextmenu = function(e) { e.preventDefault(); }

    // Game container scaling
    game_cont = document.body.querySelector('.game-container');
    window.addEventListener('resize', resize_game_cont);
    resize_game_cont();

    game_cont.classList.remove('no-gc');
    window.scrollTo(0, 0);

    var app = Const.app = new Application({
      backgroundColor: 0x000000,
      width: Const.WIDTH,
      height: Const.PIXI_HEIGHT
    });

    var cont = document.body.querySelector('.pixi-container');
    cont.appendChild(app.view);
    cont.style.width = '${ Const.WIDTH }px';
    cont.style.height = '${ Const.PIXI_HEIGHT }px';
    app.view.className = 'pixi-app';

    start_game();
  }

  function start_game()
  {
    new drone.DroneGame();
  }

  function test_graphics()
  {
    var g = new Graphics();
    g.lineStyle(3, 0xff0000);
    g.drawCircle(Const.WIDTH/2, Const.PIXI_HEIGHT/2, Const.PIXI_HEIGHT/2);
    Const.app.stage.addChild(g);
  }
}
