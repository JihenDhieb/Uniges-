import 'dart:async';
import 'package:android_package_installer/android_package_installer.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

class InstallStatus {
  double? progress = 0.0;
  String? status = "";
  String? path = "";
}

class FileDownload {
  static Future<InstallStatus> downloadApk(String url, String name,
      Function(InstallStatus) onProgressCallback) async {
    InstallStatus i = InstallStatus();

    FileDownloader.downloadFile(
        url: url,
        name: name,
        onProgress: (fileName, progress) {
          i.progress = progress;
          i.status = DownloadStatus.DOWNLOADING.toString();
          onProgressCallback(i);
        },
        onDownloadCompleted: (path) {
          i.path = path;
          i.status = DownloadStatus.INSTALLING.toString();
          onProgressCallback(i);
          forceInstall(path);
        });

    return i;
  }
}

void forceInstall(String path) async {
  int? statusCode = await AndroidPackageInstaller.installApk(apkFilePath: path);

  PackageInstallerStatus installationStatus =
      PackageInstallerStatus.byCode(statusCode!);
  print(installationStatus.name);
}

enum DownloadStatus {
  DOWNLOADING,
  INSTALLING,
  ERROR,
}
