import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;

class PasteSubscription {
  final StreamSubscription<html.Event> _sub;
  PasteSubscription._(this._sub);
  Future<void> cancel() => _sub.cancel();
}

PasteSubscription addPasteListener(void Function(Uint8List bytes) onImage) {
  final sub = html.document.onPaste.listen((event) async {
    try {
      final items = (event as dynamic).clipboardData?.items;
      if (items == null) return;
      for (final it in items) {
        if (it.kind == 'file' && (it.type as String).startsWith('image/')) {
          final blob = it.getAsFile();
          if (blob != null) {
            final reader = html.FileReader();
            reader.readAsArrayBuffer(blob);
            await reader.onLoad.first;
            final bytes = reader.result as List<int>;
            onImage(Uint8List.fromList(bytes));
          }
        }
      }
    } catch (e) {
      // ignore
    }
  });
  return PasteSubscription._(sub);
}
