package util;

class DialogBox
{
  public static function modal(header:String, message:String, ?opts:{ bkg_color:Int, width: Int }, callback:Void->Void)
  {
    var modal = new Sprite();
    var bkg = new Graphics();

    var width = opts==null ? Const.WIDTH*0.8 : opts.width;
    var pad = 15;
    bkg.beginFill(opts==null ? 0x111111 : opts.bkg_color, 0.90);
    bkg.lineStyle(2, 0x0, 1.0);
    modal.addChild(bkg);

    var header_style = new TextStyle({
      fontFamily: 'VT323',
      fontSize: 28,
      fill: ['#ffffff', '#5588cc'], // gradient
      dropShadow: true,
      dropShadowColor: '#000000',
      dropShadowBlur: 3,
      dropShadowAngle: Math.PI / 6,
      dropShadowDistance: 3,
      wordWrap: true,
      wordWrapWidth: width - 2*pad,
      align:"center"
    });

    var header_text = new Text(header, header_style);
    header_text.x = (width - header_text.width)/2;
    header_text.y = pad;
    modal.addChild(header_text);

    var message_style = new TextStyle({
      fontFamily: 'VT323',
      fontSize: 22,
      fill: ['#33aa44'],
      dropShadow: true,
      dropShadowColor: '#000000',
      dropShadowBlur: 2,
      dropShadowAngle: Math.PI / 6,
      dropShadowDistance: 2,
      wordWrap: true,
      wordWrapWidth: width - 2*pad,
      align:"left",
      lineHeight: 23.5
    });

    var message_text = new Text(message, message_style);
    message_text.x = pad;
    message_text.y = header_text.y  + header_text.height + pad;
    modal.addChild(message_text);

    var height = header_text.height + message_text.height + pad*3;
    bkg.drawRoundedRect(0, 0, width, height, 10);

    Const.app.stage.addChild(modal);
    modal.x = (Const.WIDTH - width)/2;
    modal.y = (Const.PIXI_HEIGHT - height)/2;

    message_text.text = '';
    var letters = message.split("");
    var funcs = [];
    function push_func(set_msg:String) {
      funcs.push(()->{ message_text.text = set_msg; });
    }
    var msg = "";
    for (l in letters) {
      msg += l;
      push_func(msg);
    }
    function pop() {
      if (funcs.length > 0) {
        funcs.shift()();
        haxe.Timer.delay(pop, (Keys.singleton.num_keys_down>0 || Keys.singleton.mouse_is_down) ? 20 : 70);
      } else {
        haxe.Timer.delay(function() {
          modal.parent.removeChild(modal);
          callback();
        }, 1500);
      }
    }
    pop();
  }

  private static var lbl:Sprite;
  public static function label(d:DisplayObject, dx:Float, dy:Float, msg:String, bcolor:Int, tcolor:String)
  {
    var label_style = new TextStyle({
      fontFamily: 'VT323',
      fontSize: 18,
      fill: tcolor,
      align:"left"
    });

    var p = new Point(dx, dy);
    d.localToGlobal(p);

    if (lbl !=null && lbl.parent!=null) lbl.parent.removeChild(lbl);
    lbl = new Sprite();

    Const.app.stage.addChild(lbl);
    lbl.x = p.x;
    lbl.y = p.y;

    var txt = new Text(msg, label_style);
    var bkg = new Graphics();
    bkg.beginFill(bcolor, 1.0);
    bkg.drawRoundedRect(0,0,txt.width,txt.height,2);
    lbl.addChild(bkg);
    lbl.addChild(txt);

    Timer.delay(function() {
      if (lbl !=null && lbl.parent!=null) lbl.parent.removeChild(lbl);
      lbl = null;
    }, 2500);
  }

}
