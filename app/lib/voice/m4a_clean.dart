import 'dart:typed_data';

/// Boxes that carry nothing but metadata: Android's MPEG4Writer puts the
/// Android version into `moov/meta`, and a location would go into `udta`.
const Set<String> _metadataBoxes = <String>{'udta', 'meta'};

/// Boxes whose children are walked.
const Set<String> _containers = <String>{
  'moov',
  'trak',
  'mdia',
  'minf',
  'stbl',
  'edts',
};

/// Boxes with a creation and a change time after version and flags.
const Set<String> _timed = <String>{'mvhd', 'tkhd', 'mdhd'};

/// Cleans a voice note's M4A in place (D-285): every `udta` and `meta` box
/// becomes a `free` box of the same size filled with zeros, so no offset in
/// the file changes, and the creation and change times of `mvhd`, `tkhd`
/// and `mdhd` are set to zero. Throws a [FormatException] when [bytes] is
/// not an MP4 file with `ftyp`, `moov` and `mdat`.
void cleanM4a(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  final top = _boxes(data, 0, bytes.length);
  final types = top.map((b) => b.type).toSet();
  for (final needed in <String>['ftyp', 'moov', 'mdat']) {
    if (!types.contains(needed)) {
      throw FormatException('not an M4A file: no $needed box');
    }
  }
  if (top.first.type != 'ftyp') {
    throw const FormatException('not an M4A file: ftyp is not first');
  }
  _clean(bytes, data, top);
}

void _clean(Uint8List bytes, ByteData data, List<_Box> boxes) {
  for (final box in boxes) {
    if (_metadataBoxes.contains(box.type)) {
      // "free" keeps the size; the payload is zeroed.
      bytes.setRange(box.start + 4, box.start + 8, 'free'.codeUnits);
      bytes.fillRange(box.payload, box.end, 0);
    } else if (_timed.contains(box.type)) {
      _zeroTimes(data, box);
    } else if (_containers.contains(box.type)) {
      _clean(bytes, data, _boxes(data, box.payload, box.end));
    }
  }
}

void _zeroTimes(ByteData data, _Box box) {
  if (box.end - box.payload < 4) {
    throw FormatException('${box.type} too short');
  }
  final version = data.getUint8(box.payload);
  final width = version == 1 ? 8 : 4;
  final first = box.payload + 4;
  if (first + 2 * width > box.end) {
    throw FormatException('${box.type} too short');
  }
  for (var i = first; i < first + 2 * width; i++) {
    data.setUint8(i, 0);
  }
}

class _Box {
  const _Box(this.type, this.start, this.payload, this.end);

  final String type;
  final int start;
  final int payload;
  final int end;
}

List<_Box> _boxes(ByteData data, int from, int to) {
  final boxes = <_Box>[];
  var at = from;
  while (at < to) {
    if (to - at < 8) throw const FormatException('box header cut off');
    var size = data.getUint32(at);
    final type = String.fromCharCodes(
      Uint8List.sublistView(data, at + 4, at + 8),
    );
    var payload = at + 8;
    if (size == 1) {
      if (to - at < 16) throw const FormatException('box header cut off');
      final big = data.getUint64(at + 8);
      if (big > to - at) throw FormatException('$type box too long');
      size = big;
      payload = at + 16;
    } else if (size == 0) {
      size = to - at;
    }
    if (size < payload - at || at + size > to) {
      throw FormatException('$type box has a bad size');
    }
    boxes.add(_Box(type, at, payload, at + size));
    at += size;
  }
  return boxes;
}
