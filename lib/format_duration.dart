String formatDuration(Duration d) {
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  final millis = (d.inMilliseconds % 1000).toString().padLeft(3, '0');
  return "$minutes:$seconds.$millis";
}
