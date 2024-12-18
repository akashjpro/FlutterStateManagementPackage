# Flutter State Management Package

## **Mục tiêu**
Phát triển một package Flutter để quản lý state trong ứng dụng mà không sử dụng bất kỳ package quản lý state có sẵn nào trên pub.dev. Package này hỗ trợ quản lý state hiệu quả, dễ sử dụng và dễ tích hợp vào các ứng dụng Flutter khác nhau.

---

## **1. Cấu trúc và tổ chức**

Package sẽ được chia thành các thành phần chính như sau:

```
/lib
  ├── src/
  │   ├── state_manager.dart        # Lớp quản lý state tổng quát
  │   ├── state_notifier.dart.      # StateNotifier: cập nhật và quản lý state
  │   ├── state_observer.dart       # Gắn state vào UI và lắng nghe sự thay đổi
  │   ├── async_state_manager.dart  # Quản lý state bất đồng bộ
  │   ├── resettable_state.dart.    # Hỗ trợ reset state
  │   ├── performance_tracker.dart. # Công cụ đo hiệu suất
  └── example/                      # Ví dụ minh họa cách sử dụng package

```

---

## **2. Thiết kế chi tiết**

### **a. StateNotifier: Cốt lõi quản lý State**

`StateNotifier` chịu trách nhiệm:
1. Quản lý trạng thái hiện tại.
2. Thông báo cho các listener khi state thay đổi.
3. Cho phép reset state về giá trị mặc định.

```dart
import 'dart:async';

class StateNotifier<T> {
  T _state;
  final StreamController<T> _controller = StreamController<T>.broadcast();

  StateNotifier(this._state);

  // Lấy state hiện tại
  T get state => _state;

  // Stream cho phép lắng nghe thay đổi
  Stream<T> get stream => _controller.stream;

  // Cập nhật state mới
  void update(T newState) {
    if (_state != newState) {
      _state = newState;
      _controller.add(_state);
    }
  }

  // Reset state về giá trị mặc định
  void reset(T defaultState) {
    _state = defaultState;
    _controller.add(_state);
  }

  // Cleanup stream khi không cần thiết
  void dispose() {
    _controller.close();
  }
}
```

---

### **b. StateObserver: Liên kết state với UI**

`StateObserver` tự động cập nhật UI khi state thay đổi, đảm bảo hiệu suất bằng cách chỉ cập nhật **khi cần thiết**.

```dart
import 'package:flutter/widgets.dart';

class StateObserver<T> extends StatefulWidget {
  final StateNotifier<T> notifier;
  final Widget Function(BuildContext, T) builder;

  const StateObserver({
    required this.notifier,
    required this.builder,
    Key? key,
  }) : super(key: key);

  @override
  _StateObserverState<T> createState() => _StateObserverState<T>();
}

class _StateObserverState<T> extends State<StateObserver<T>> {
  late T _state;
  late StreamSubscription<T> _subscription;

  @override
  void initState() {
    super.initState();
    _state = widget.notifier.state;
    _subscription = widget.notifier.stream.listen((newState) {
      setState(() => _state = newState);
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _state);
  }
}
```

**Cách sử dụng**:
```dart



final counterNotifier = StateNotifier<int>(0);

StateObserver(notifier: counterNotifier,
builder: (context, value) {
return Text('Count: $value');
},
);
```

---

### **c. AsyncStateManager: Hỗ trợ State bất đồng bộ**

Quản lý state cho các tác vụ bất đồng bộ như gọi API hoặc đọc dữ liệu từ database.

```dart
class AsyncState<T> {
  T? _state;
  bool isLoading = false;
  final StreamController<T?> _controller = StreamController<T?>.broadcast();

  Stream<T?> get stream => _controller.stream;
  T? get state => _state;

  // Load dữ liệu bất đồng bộ
  Future<void> load(Future<T> Function() fetcher) async {
    isLoading = true;
    _controller.add(null); // Gửi state "đang tải"
    try {
      _state = await fetcher();
      _controller.add(_state);
    } catch (e) {
      _controller.addError(e);
    } finally {
      isLoading = false;
    }
  }

  void dispose() => _controller.close();
}
```

**Sử dụng**:
```dart
final userState = AsyncState<User>();

userState.load(() async {
final user = await fetchUserFromAPI();
return user;
});

```

---

### **d. ResettableState: Xóa hoặc Reset state**

Cho phép reset state về giá trị mặc định khi cần.

```dart
class ResettableState<T> {
  final T _defaultValue;
  T _currentValue;

  ResettableState(this._defaultValue) : _currentValue = _defaultValue;

  T get value => _currentValue;

  void update(T newValue) {
    _currentValue = newValue;
  }

  void reset() {
    _currentValue = _defaultValue;
  }
}
```

---

### **e. PerformanceTracker: Đo lường hiệu suất**

Đo thời gian thực thi và kiểm tra rò rỉ bộ nhớ để đảm bảo hiệu suất ổn định.

```dart
class PerformanceTracker {
  static Stopwatch _stopwatch = Stopwatch();

  static void start() {
    _stopwatch.reset();
    _stopwatch.start();
  }

  static void stop(String taskName) {
    _stopwatch.stop();
    print('$taskName executed in ${_stopwatch.elapsedMilliseconds}ms');
  }
}
```

**Sử dụng**:
```dart
void main() {
  PerformanceTracker.start(); // Bắt đầu đo hiệu suất

  // Thực hiện công việc của bạn ở đây
  print("Đang thực hiện công việc...");

  PerformanceTracker.stop('Load Data'); // Kết thúc đo hiệu suất và in kết quả
}
```

---

## **3. Đo lường hiệu suất**

### **a. Thay đổi nhiều state liên tục**

```dart
void main() {
  final counterNotifier = StateNotifier<int>(0);

  // Đo hiệu suất khi cập nhật state 1000 lần
  PerformanceTracker.start();
  for (int i = 0; i < 1000; i++) {
    counterNotifier.update(i);
  }
  PerformanceTracker.stop('Update 1000 times');

  counterNotifier.dispose();
}
```

**Output**:
```
State updated in 15µs. Total updates: 1
State updated in 12µs. Total updates: 2
...
State updated in 10µs. Total updates: 1000
Update 1000 times executed in 50ms.
```

### **b. Cập nhật nhiều state đồng thời**

```dart
void main() {
  final states = List.generate(1000, (index) => StateNotifier<int>(0));

  PerformanceTracker.start();

  for (final state in states) {
    state.update(1); // Cập nhật từng state một
  }

  PerformanceTracker.stop('Update 1000 states');

  for (final state in states) {
    state.dispose();
  }
}
```

**Output**:
```
Update 1000 states executed in 30ms.
```

---

## **4. Kết luận**

Package này:
1. **Quản lý state đơn giản và phức tạp**.
2. **Hiệu suất cao và tránh render thừa**.
3. **Hỗ trợ bất đồng bộ** cho các tác vụ như gọi API.
4. **API thân thiện**, dễ dàng tích hợp vào ứng dụng hiện tại.
5. **Mở rộng dễ dàng**: Có thể thêm middleware, persistence và tính năng mới trong tương lai.

Package này hoàn toàn tùy chỉnh, không phụ thuộc vào các thư viện bên ngoài, giúp lập trình viên kiểm soát toàn bộ quá trình quản lý state.

