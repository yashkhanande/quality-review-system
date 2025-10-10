import 'dart:typed_data';

class PasteSubscription {
  Future<void> cancel() async {}
}

PasteSubscription addPasteListener(void Function(Uint8List bytes) onImage) {
  // No-op on non-web platforms
  return PasteSubscription();
}
