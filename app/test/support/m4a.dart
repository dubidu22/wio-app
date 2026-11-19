import 'dart:convert';
import 'dart:typed_data';

/// One MP4 box: 32-bit size, four-letter type, payload.
Uint8List box(String type, List<int> payload) {
  final out = BytesBuilder();
  final header = ByteData(8)..setUint32(0, payload.length + 8);
  out.add(header.buffer.asUint8List(0, 4));
  out.add(latin1.encode(type));
  out.add(payload);
  return out.toBytes();
}

Uint8List _concat(List<List<int>> parts) {
  final out = BytesBuilder();
  for (final p in parts) {
    out.add(p);
  }
  return out.toBytes();
}

/// A full box (version 0) with creation and change time set to [time],
/// then [rest].
Uint8List timedBox(String type, int time, List<int> rest) {
  final head = ByteData(12)
    ..setUint32(0, 0)
    ..setUint32(4, time)
    ..setUint32(8, time);
  return box(type, _concat(<List<int>>[head.buffer.asUint8List(), rest]));
}

/// The bytes of "mdat" in [sampleM4a], audio frames that must survive.
final Uint8List sampleAudio = Uint8List.fromList(
  List<int>.generate(256, (i) => (i * 7) & 0xff),
);

/// Recording time in [sampleM4a] (seconds since 1904, as MP4 counts).
const int sampleTime = 0xE3C1A2B4;

/// A small M4A laid out as Android's MPEG4Writer writes it: ftyp, mdat,
/// then moov with times, a `meta` box with the Android version and a
/// `udta` box with a location.
Uint8List sampleM4a() => _concat(<List<int>>[
  box('ftyp', ascii.encode('M4A \x00\x00\x00\x00isomM4A ')),
  box('mdat', sampleAudio),
  box(
    'moov',
    _concat(<List<int>>[
      timedBox('mvhd', sampleTime, List<int>.filled(88, 1)),
      box(
        'trak',
        _concat(<List<int>>[
          timedBox('tkhd', sampleTime, List<int>.filled(68, 2)),
          box(
            'mdia',
            _concat(<List<int>>[
              timedBox('mdhd', sampleTime, List<int>.filled(8, 3)),
              box(
                'hdlr',
                ascii.encode(
                  '\x00\x00\x00\x00\x00\x00\x00\x00soun'
                  'SoundHandle\x00',
                ),
              ),
            ]),
          ),
          box('udta', box('\xa9xyz', ascii.encode('+52.5200+013.4050/'))),
        ]),
      ),
      box('meta', ascii.encode('keys com.android.version 14')),
      box('udta', box('\xa9xyz', ascii.encode('+48.1351+011.5820/'))),
    ]),
  ),
]);

/// Whether [needle] occurs in [bytes].
bool containsBytes(Uint8List bytes, List<int> needle) {
  outer:
  for (var i = 0; i + needle.length <= bytes.length; i++) {
    for (var j = 0; j < needle.length; j++) {
      if (bytes[i + j] != needle[j]) continue outer;
    }
    return true;
  }
  return false;
}
