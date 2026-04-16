String formatLiveCount(int count) {
  if (count < 1000) return count.toString();
  final source = count.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < source.length; index++) {
    if (index > 0 && (source.length - index) % 3 == 0) buffer.write(',');
    buffer.write(source[index]);
  }
  return buffer.toString();
}
