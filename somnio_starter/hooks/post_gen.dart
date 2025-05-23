import 'dart:io';
import 'package:mason/mason.dart';

void run(HookContext context) async {
  final directory = Directory.current.path;
  final vars = context.vars;
  final projectName = vars['project_name'];
  final projectDirectory = "$directory/$projectName";
  final uiPackageDirectory = "$projectDirectory/packages/${projectName}_ui";
  final galleryDirectory = "$uiPackageDirectory/gallery";

  var progress = context.logger.progress('Getting packages');

  final directories = [projectDirectory, uiPackageDirectory, galleryDirectory];

  for (final dir in directories) {
    await Process.run(
      'flutter',
      ['pub', 'get'],
      runInShell: true,
      workingDirectory: dir,
    );
  }

  progress.complete();

  progress = context.logger.progress(
    'Creating auto generated assets using build_runner',
  );

  await Process.run(
    'flutter',
    ['pub', 'run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    runInShell: true,
    workingDirectory: uiPackageDirectory,
  );

  progress.complete();

  progress = context.logger.progress('Running dart fix');

  for (final dir in directories.reversed) {
    await Process.run(
      'dart',
      ['fix', '--apply'],
      runInShell: true,
      workingDirectory: dir,
    );
  }

  progress.complete();
}
