extension InvertMap<K,V> on Map<K,V> {
  Map<V,K> get inverted {
    return map((k, v) => MapEntry<V,K>(v, k));
  }
}

extension Between on num {
  bool between(num min, num max) {
    return this >= min && this <= max;
  }
}

extension Flatten<T> on Iterable<Iterable<T>> {
  List<T> get flatten => fold<List<T>>([], (xs, x) => xs..addAll(x));
}

class Pair<A,B> {
  A first;
  B second;

  Pair(this.first, this.second);

  @override
  bool operator ==(dynamic other) {
    if (other is! Pair<A,B>) {
      return false;
    }

    if (first != other.first || second != other.second) {
      return false;
    }

    return true;
  }

  @override
  int get hashCode => first.hashCode * second.hashCode;
}

class Vector2 extends Pair<int,int> {
  Vector2(int x, int y) : super(x, y);

  int get x => first;
  set x(int v) => first = v;
  int get y => second;
  set y(int v) => second = v;
}
