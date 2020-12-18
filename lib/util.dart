extension InvertMap<K,V> on Map<K,V> {
  Map<V,K> get inverted {
    return map((k, v) => MapEntry<V,K>(v, k));
  }
}
