import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class VideoProcessor {
  static final VideoProcessor _instance = VideoProcessor._internal();
  factory VideoProcessor() => _instance;
  VideoProcessor._internal();

  Future<String?> trimVideo(
    String inputPath,
    double startTime,
    double endTime,
  ) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String outputPath = '${tempDir.path}/${const Uuid().v4()}.mp4';

      final String command = '-i "$inputPath" -ss $startTime -t ${endTime - startTime} -c:v copy -c:a copy "$outputPath"';
      
      final session = await FFmpegKit.execute(command);
      final ReturnCode? returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return outputPath;
      } else {
        return null;
      }
    } catch (e) {
      print('Error trimming video: $e');
      return null;
    }
  }

  Future<String?> mergeVideos(List<String> videoPaths) async {
    try {
      // Create a text file with the list of videos to concatenate
      final Directory tempDir = await getTemporaryDirectory();
      final String listPath = '${tempDir.path}/videos.txt';
      final String outputPath = '${tempDir.path}/${const Uuid().v4()}.mp4';

      final File listFile = File(listPath);
      String fileContent = '';
      for (String path in videoPaths) {
        fileContent += "file '$path'\n";
      }
      await listFile.writeAsString(fileContent);

      final String command = '-f concat -safe 0 -i "$listPath" -c copy "$outputPath"';
      
      final session = await FFmpegKit.execute(command);
      final ReturnCode? returnCode = await session.getReturnCode();

      await listFile.delete();

      if (ReturnCode.isSuccess(returnCode)) {
        return outputPath;
      } else {
        return null;
      }
    } catch (e) {
      print('Error merging videos: $e');
      return null;
    }
  }

  Future<String?> applyFilter(String inputPath, String filterType) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String outputPath = '${tempDir.path}/${const Uuid().v4()}.mp4';

      String filterCommand = '';
      switch (filterType) {
        case 'grayscale':
          filterCommand = '-vf colorspace=bt709:iall=bt601-6-625:fast=1';
          break;
        case 'sepia':
          filterCommand = '-vf colorbalance=rs=.393:gs=.769:bs=.189:rm=.349:gm=.686:bm=.168:rh=.272:gh=.534:bh=.131';
          break;
        case 'vintage':
          filterCommand = '-vf curves=vintage';
          break;
        case 'bright':
          filterCommand = '-vf eq=brightness=0.2';
          break;
        default:
          filterCommand = '';
      }

      final String command = '-i "$inputPath" $filterCommand "$outputPath"';
      
      final session = await FFmpegKit.execute(command);
      final ReturnCode? returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return outputPath;
      } else {
        return null;
      }
    } catch (e) {
      print('Error applying filter: $e');
      return null;
    }
  }

  Future<String?> addAudioTrack(
    String videoPath,
    String audioPath,
    double volume,
  ) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String outputPath = '${tempDir.path}/${const Uuid().v4()}.mp4';

      final String command = '-i "$videoPath" -i "$audioPath" -filter_complex "[1:a]volume=$volume[a1];[0:a][a1]amix=inputs=2:duration=first[a]" -map 0:v -map "[a]" "$outputPath"';
      
      final session = await FFmpegKit.execute(command);
      final ReturnCode? returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return outputPath;
      } else {
        return null;
      }
    } catch (e) {
      print('Error adding audio: $e');
      return null;
    }
  }

  Future<String?> addSubtitles(
    String videoPath,
    String subtitlesText,
    double startTime,
  ) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String outputPath = '${tempDir.path}/${const Uuid().v4()}.mp4';
      final String srtPath = '${tempDir.path}/subtitles.srt';

      // Create a simple SRT file
      final File srtFile = File(srtPath);
      await srtFile.writeAsString('''
1
00:00:${startTime.toStringAsFixed(3)} --> 00:00:${(startTime + 3).toStringAsFixed(3)}
$subtitlesText
''');

      final String command = '-i "$videoPath" -vf subtitles="$srtPath" "$outputPath"';
      
      final session = await FFmpegKit.execute(command);
      final ReturnCode? returnCode = await session.getReturnCode();

      await srtFile.delete();

      if (ReturnCode.isSuccess(returnCode)) {
        return outputPath;
      } else {
        return null;
      }
    } catch (e) {
      print('Error adding subtitles: $e');
      return null;
    }
  }
}