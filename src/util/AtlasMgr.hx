package util;

class AtlasMgr
{
  static var promises:DynamicAccess<Promise<Spritesheet>> = {};

  public static function load_atlas(name:String, callback:Spritesheet->Void)
  {
    if (promises[name] != null) {
      promises[name].then((s)->callback(s));
      return;
    }

    // URLs relative to the index.html
    var p = new Promise<Spritesheet>(function(resolve, reject) {
      Loader.shared.add('./images/atlases/${ name }.json').load(function(loader,res) {
        var sheet:Spritesheet = Reflect.field(res, './images/atlases/${ name }.json');
        resolve(sheet);
      });
    });
    promises[name] = p;
    p.then((s)->callback(s));
  }
}
