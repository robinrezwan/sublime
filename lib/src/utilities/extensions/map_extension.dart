import 'dart:core';

extension MapExtension<K, V> on Map<K, V> {
  K? keyOf(V value) {
    final List<K> keysList = keys.toList();
    final List<V> valuesList = values.toList();

    return valuesList.contains(value)
        ? keysList[valuesList.indexOf(value)]
        : null;
  }
}
