package util;

class DisplayUtil
{
  public static inline function localToGlobal(d:DisplayObject, p:Point):Void
  {
    d.worldTransform.apply(p, p);
  }
  public static inline function globalToLocal(d:DisplayObject, p:Point):Void
  {
    d.worldTransform.applyInverse(p, p);
  }
  public static inline function distance(p0:Point, p1:Point):Float
  {
    return Math.sqrt((p1.x-p0.x)*(p1.x-p0.x) + (p1.y-p0.y)*(p1.y-p0.y));
  }

  private static var TEMP = new Point(0,0);
  public static function sqr(x:Float) return x * x;
  public static function dist2(v:Point, w:Point) { return sqr(v.x - w.x) + sqr(v.y - w.y); }
  public static function distToSegmentSquared(p:Point, v:Point, w:Point)
  {
    var l2 = dist2(v, w);
    if (l2 == 0) return dist2(p, v);
    var t = ((p.x - v.x) * (w.x - v.x) + (p.y - v.y) * (w.y - v.y)) / l2;
    t = Math.max(0, Math.min(1, t));
    TEMP.set(v.x + t * (w.x - v.x), v.y + t * (w.y - v.y));
    return dist2(p, TEMP);
  }
  public static function distToSegment(p: Point, v: Point, w: Point) {
    return Math.sqrt(distToSegmentSquared(p, v, w));
  }

}
