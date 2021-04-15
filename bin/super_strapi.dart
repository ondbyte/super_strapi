import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

import 'package:path/path.dart';

import 'package:yaml/yaml.dart';

import 'gen.dart';
import 'json2yaml/json2yaml.dart';

void main(List<String> arguments) async {
  final argvParser = ArgParser();
  try {
    argvParser.addOption(
      "strapi-project-path",
      abbr: "i",
      help:
          "required, strapi project folder to generate the schema/dart classes",
    );
    argvParser.addOption(
      "output-folder",
      abbr: "o",
      help: "required, to output the generated super_strapi project folder",
    );
    argvParser.addFlag(
      "only-schema",
      abbr: "s",
      defaultsTo: false,
      help:
          "defaults to false, if set to true only schema is generated from strapi models otherwise dart classes is generated from strapi models",
    );
    argvParser.addFlag(
      "generate-widgets",
      abbr: "w",
      defaultsTo: true,
      help:
          "defaults to true, if set to true flutter updateListener widgets for all collection types will be generated",
    );

    final argvResults = argvParser.parse(arguments);

    final strapiProjectPath = argvResults["strapi-project-path"];
    final outPutPath = argvResults["output-folder"];
    if (outPutPath == null) {
      throw FormatException();
    }
    final isSchemaOnly = argvResults["only-schema"];

    final shouldGenerateWidgets = argvResults["generate-widgets"];

    if (strapiProjectPath != null && outPutPath != null) {
      final strapiProjectDirectory = Directory(strapiProjectPath);
      final outPutFile = await setupOutPutDirectory(
        Directory(outPutPath),
        shouldGenerateWidgets,
      );
      checkStrapiProjectRoot(strapiProjectDirectory);
      final defaultModels = await _getLatestDefaultModels(
        strapiProjectDirectory,
      );
      //print(defaultModels);

      final gen = Gen(
        strapiProjectDirectory,
        outPutFile,
        isSchemaOnly,
        defaultModels,
        shouldGenerateWidgets,
      );

      await gen.generate();
    } else {
      throw FormatException();
    }
  } on FormatException catch (e) {
    print("use fallowing arguments with super_strapi\n");

    print(argvParser.usage);
  }
}

final defaultModelsURL = [
  "https://raw.githubusercontent.com/strapi/strapi/master/packages/strapi-plugin-users-permissions/models/",
  "https://raw.githubusercontent.com/strapi/strapi/master/packages/strapi-plugin-upload/models/"
];

final defaultModelNames = <String>[
  "https://raw.githubusercontent.com/strapi/strapi/master/packages/strapi-plugin-users-permissions/models/Permission.settings.json",
  "https://raw.githubusercontent.com/strapi/strapi/master/packages/strapi-plugin-users-permissions/models/Role.settings.json",
  "https://raw.githubusercontent.com/strapi/strapi/master/packages/strapi-plugin-users-permissions/models/User.settings.json",
  "https://raw.githubusercontent.com/strapi/strapi/master/packages/strapi-plugin-upload/models/File.settings.json",
];

final tmpDirectory = join(Directory.systemTemp.path);

Future<List<File>> _getLatestDefaultModels(
  Directory strapiProjectDir,
) async {
  final fileList = <File>[];
  final modulesDirectory = Directory(
    join(strapiProjectDir.path, "node_modules"),
  );
  if (!(await modulesDirectory.exists())) {
    print(
        "${modulesDirectory.path} doesnt exists, make sure you are referring a strapi project as input, and make sure you ran 'npm install' in your strapi project");
    exit(0);
  }
  final all =
      await (await modulesDirectory.list()).fold<List<Directory>>([], (pv, e) {
    if (e is Directory) {
      final name = basename(e.path);
      if (name.startsWith("strapi-plugin-")) {
        return [...pv, e];
      }
    }
    return pv;
  });

  await Future.forEach<Directory>(all, (e) async {
    fileList.addAll(
        await readFilesWithExtension(e, extn: "settings.json").toList());
  });
  return fileList;
}

void checkStrapiProjectRoot(Directory directory) {
  if (!directory.existsSync()) {
    print("provided path doesnt exist ${directory.path}");
    exit(0);
  } else if (!File(directory.path + "/package.json").existsSync()) {
    print("provided project is not a node/strapi project ${directory.path}");
    exit(0);
  }
}

Future<File> setupOutPutDirectory(
    Directory directory, bool shouldGenerateWidgets) async {
  if (await _validatePubspec(directory, shouldGenerateWidgets)) {
    return File(
      join(
        directory.path,
        "super_strapi_generated",
        "lib",
        "super_strapi_generated.dart",
      ),
    );
  } else {
    exit(0);
  }
}

Future<bool> _validatePubspec(
    Directory directory, bool shouldGenerateWidgets) async {
  final pubspec =
      File(join(directory.path, "super_strapi_generated", "pubspec.yaml"));
  var projectExists = await pubspec.exists();
  if (!projectExists) {
    projectExists = await _makeProject(directory, shouldGenerateWidgets);
  }
  if (!projectExists) {
    print("problem creating a dart project");
    exit(0);
  }
  final yamlString = await pubspec.readAsString();
  final parsed = loadYaml(yamlString);
  var enabled = parsed?["super_strapi"]?["enabled"] ?? false;
  if (shouldGenerateWidgets) {
    final flutterProject = () {
      try {
        return (parsed?["dependencies"]["flutter"]["sdk"] == "flutter");
      } catch (e) {
        return false;
      }
    }();
    if (!flutterProject) {
      print(
        "existing project is dart project, if you want to generate widgets remove existing dart project first so the program can generate flutter project",
      );
      return false;
    }
  }
  if (!enabled) {
    print("unable to validate existing project");
  }
  return enabled;
}

Future<bool> _makeProject(
    Directory directory, bool shouldGenerateWidgets) async {
  print("generating a dart project @ ${directory.path}");
  final process = (shouldGenerateWidgets)
      ? Process.runSync(
          "flutter",
          [
            "create",
            "--no-pub",
            "--org",
            "xyz.yadunandan",
            "--project-name",
            "super_strapi_generated",
            "-t",
            "package",
            "./super_strapi_generated",
          ],
          workingDirectory: directory.path,
        )
      : Process.runSync(
          "dart",
          [
            "create",
            "-t",
            "package-simple",
            "super_strapi_generated",
          ],
          workingDirectory: directory.path,
        );

  final pubspecFile = File(join(
    directory.path,
    "super_strapi_generated",
    "pubspec.yaml",
  ));
  if (pubspecFile.existsSync()) {
    final yamlString = await pubspecFile.readAsString();
    final yaml = Map<String, dynamic>.fromEntries(
        (loadYaml(yamlString).entries.toList() as List).map((e) {
      return MapEntry(e.key as String, e.value);
    }));
    yaml["super_strapi"] = {"enabled": true};
    if (shouldGenerateWidgets) {
      yaml["dependencies"] = {
        "flutter": {"sdk": "flutter"},
        "simple_strapi": "any",
      };
    } else {
      yaml["dependencies"] = {
        "simple_strapi": "any",
      };
    }
    await pubspecFile.writeAsString(json2yaml(yaml));
    print("go to genereted project folder and run pub get/flutter pub get");
    return true;
  }
  print("no pubspec");
  return false;
}

Stream<File> readFilesWithExtension(Directory dir, {String extn = ""}) async* {
  final stream = dir.list(recursive: true);
  await for (final maybeFile in stream) {
    if (maybeFile is File) {
      if (maybeFile.path.endsWith(extn)) {
        yield maybeFile;
      }
    }
  }
}
