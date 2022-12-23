import 'package:flutter/foundation.dart';

// class ListNotifier<T> extends ChangeNotifier implements ValueListenable<List<T>> {
class ListNotifier<T> extends ValueNotifier<List<T>> {
  ListNotifier(List<T> value) : super(value);

  int get length => value.length;
  bool get isEmpty => value.isEmpty;
  bool get isNotEmpty => value.isNotEmpty;

  void add(T item) {
    value.add(item);
    notifyListeners();
  }

  bool remove(Object? item) {
    final changed = value.remove(item);
    if (changed) notifyListeners();
    return changed;
  }

  void addAll(Iterable<T> iterable) {
    value.addAll(iterable);
    notifyListeners();
  }

  void clear() {
    value.clear();
    notifyListeners();
  }

  void insert(int index, T element) {
    value.insert(index, element);
    notifyListeners();
  }

  void insertAll(int index, Iterable<T> iterable) {
    value.insertAll(index, iterable);
    notifyListeners();
  }

  void removeWhere(bool Function(T element) param0) {
    value.removeWhere(param0);
    notifyListeners();
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
}
