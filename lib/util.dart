import 'dart:math';

extension InvertMap<K, V> on Map<K, V> {
  Map<V, K> get inverted {
    return map((k, v) => MapEntry<V, K>(v, k));
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

extension IntSum on Iterable<int> {
  int get sum => fold(0, (sum, n) => sum + n);
}

class Pair<A, B> {
  A first;
  B second;

  Pair(this.first, this.second);

  @override
  bool operator ==(dynamic other) {
    if (other is! Pair<A, B>) {
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

class Vector2 extends Pair<int, int> {
  Vector2(int x, int y) : super(x, y);

  int get x => first;
  set x(int v) => first = v;
  int get y => second;
  set y(int v) => second = v;
}

class _RangeIterator extends Iterator<int> {
  Range r;
  int i;

  _RangeIterator(this.r) : i = r.start - r.step;

  @override
  int get current => i;

  @override
  bool moveNext() {
    i += r.step;
    return i.between(min(r.start, r.end), max(r.start, r.end));
  }
}

class Range extends Iterable<int> {
  int start, end, step;
  @override
  Iterator<int> get iterator => _RangeIterator(this);

  Range(this.start, this.end, [this.step = 1]);
}
