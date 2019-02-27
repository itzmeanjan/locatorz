import 'PlatformLevelLocationIssueHandler.dart';
import 'dart:async';

class CSVExporter {
  final String dirName;
  String fileName;
  final List<Map<String, String>> dataToExport;
  final PlatformLevelLocationIssueHandler platformLevelLocationIssueHandler;

  CSVExporter(this.dirName, this.fileName, this.dataToExport,
      this.platformLevelLocationIssueHandler);

  Future<bool> exportToCSV() async {
    return await platformLevelLocationIssueHandler.methodChannel.invokeMethod(
        "exportToCSV", <String, dynamic>{
      "dirName": dirName,
      "fileName": fileName,
      "data": dataToExport
    }).then((dynamic value) {
      return value == 1;
    });
  }

  Future<bool> requestStorageAccessPermission() async {
    return await platformLevelLocationIssueHandler.methodChannel
        .invokeMethod("requestStorageAccessPermission")
        .then((dynamic value) {
      return value == 1;
    });
  }
}
