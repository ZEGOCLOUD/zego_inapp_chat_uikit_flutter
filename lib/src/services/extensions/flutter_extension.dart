import 'package:flutter/foundation.dart';

class ListNotifier<T> extends ValueNotifier<List<T>> {
  ListNotifier(List<T> value) : super(value);

  int get length => value.length;
  bool get isEmpty => value.isEmpty;
  bool get isNotEmpty => value.isNotEmpty;

  void add(T item, {bool notify = true}) {
    value.add(item);
    if (notify) notifyListeners();
  }

  bool remove(Object? item, {bool notify = true}) {
    final changed = value.remove(item);
    if (changed && notify) notifyListeners();
    return changed;
  }

  void addAll(Iterable<T> iterable,
      {bool Function(T element)? add, bool notify = true}) {
    if (add != null) {
      for (final element in iterable) {
        if (add(element)) {
          value.add(element);
        }
      }
    } else {
      value.addAll(iterable);
    }
    if (notify) notifyListeners();
  }

  void removeDuplicates<K>(K Function(T e) getKey, {bool notify = false}) {
    var tempMap = <K, T>{};

    for (var item in value) {
      tempMap[getKey(item)] = item;
    }

    value.replaceRange(0, value.length, tempMap.values);
    if (notify) notifyListeners();
  }

  void clear({bool notify = true}) {
    value.clear();
    if (notify) notifyListeners();
  }

  void insert(int index, T element, {bool notify = true}) {
    value.insert(index, element);
    if (notify) notifyListeners();
  }

  void insertAll(int index, Iterable<T> iterable, {bool notify = true}) {
    value.insertAll(index, iterable);
    if (notify) notifyListeners();
  }

  void removeWhere(bool Function(T element) test, {bool notify = true}) {
    value.removeWhere(test);
    if (notify) notifyListeners();
  }

  T operator [](int index) {
    return value[index];
  }

  void operator []=(int index, T element) {
    if (value[index] != element) {
      value[index] = element;
      notifyListeners();
    }
  }

  bool moveItemTo(int targetIndex, bool Function(T) test,
      {bool notify = true}) {
    final index = value.indexWhere(test);
    bool valueChanged = false;
    if ((index != -1) && (index != targetIndex)) {
      valueChanged = true;
      final member = value.removeAt(index);
      value.insert(targetIndex, member);
    }
    if (notify && valueChanged) notifyListeners();
    return valueChanged;
  }

  void sort(int Function(T a, T b) compare, {bool notify = true}) {
    value.sort(compare);
    if (notify) notifyListeners();
  }

  void triggerNotify() => notifyListeners();
}

class MapNotifier<K, V> extends ValueNotifier<Map<K, V>> {
  MapNotifier(Map<K, V> value) : super(value);

  int get length => value.length;
  bool get isEmpty => value.isEmpty;
  bool get isNotEmpty => value.isNotEmpty;

  void addValue(K key, V newValue, {bool notify = true}) {
    value[key] = newValue;
    if (notify) notifyListeners();
  }

  void removeValue(K key, {bool notify = true}) {
    value.remove(key);
    if (notify) notifyListeners();
  }

  void removeWhere(bool Function(K key, V value) test, {bool notify = true}) {
    value.removeWhere(test);
    if (notify) notifyListeners();
  }

  void clear({bool notify = true}) {
    value.clear();
    if (notify) notifyListeners();
  }

  void addAll(Map<K, V> other, {bool notify = true}) {
    value.addAll(other);
    if (notify) notifyListeners();
  }

  V? operator [](K key) {
    return value[key];
  }

  void operator []=(K key, V value) {
    if (this.value[key] != value) {
      this.value[key] = value;
      notifyListeners();
    }
  }

  void triggerNotifierfy() => notifyListeners();
}
