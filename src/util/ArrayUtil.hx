package util;

class ArrayUtil
{
  // Return a randomly selected element from the array
  public static function sample<T>(arr:Array<T>):T {
    if (arr==null || arr.length==0) return null;
    return arr[Math.floor(Math.random()*arr.length)];
  }
}
