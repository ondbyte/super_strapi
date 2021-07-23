import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:inflection2/inflection2.dart';
import 'package:path/path.dart' as path;

import 'helpers.dart';
import 'super_strapi.dart';
import 'types.dart';

class Gen {
  final Directory strapiProjectDirectory;
  final File outPutFile;
  final bool isSchemaOnly;
  final List<File> defaultModels;
  final bool shouldGnerateWidgets;

  late final Directory apiDirectory;
  late final Directory componentDirectory;
  late final Directory extensionsDirectory;

  Gen(
    this.strapiProjectDirectory,
    this.outPutFile,
    this.isSchemaOnly,
    this.defaultModels,
    this.shouldGnerateWidgets,
  ) {
    apiDirectory = Directory(
      path.join(strapiProjectDirectory.path, "api"),
    );
    componentDirectory = Directory(
      path.join(strapiProjectDirectory.path, "components"),
    );
    extensionsDirectory = Directory(
      path.join(strapiProjectDirectory.path, "extensions"),
    );
  }

  String getCollectionNameFromRoutesFile(File file) {
    final n =
        path.basenameWithoutExtension(path.basenameWithoutExtension(file.path));
    return pluralize(n);
    final splitted = path.split(file.path);
    splitted.removeLast();
    splitted.removeLast();
    final configFile = File(
      path.joinAll(
        [...splitted, "config", "routes.json"],
      ),
    );
    if (configFile.existsSync()) {
      final data = configFile.readAsStringSync();
      final j = jsonDecode(data);
      final routes = j["routes"];
      if (routes is List && routes.isNotEmpty) {
        final name = path
            .basenameWithoutExtension(path.basenameWithoutExtension(file.path));
        final route = routes.firstWhere(
            (element) => (element["handler"].toString() == "$name.find" ||
                element["handler"].toString() == "$name.find"),
            orElse: () => null);
        if (route is Map) {
          final path = route["path"];
          if (route.containsKey("path")) {
            if (path is String) {
              return path.replaceFirst("/", "");
            } else {
              print("noo4");
            }
          } else {
            print("noo3");
          }
        } else {
          print(routes);
          print(name);
        }
      } else {
        print("noo");
      }
    }
    throw Exception("cannot get collection name for file: " + file.path);
  }

  Future generate() async {
    final apiFolderFiles =
        await readFilesWithExtension(apiDirectory, extn: ".settings.json")
            .toList();
    final extensionFolderFiles = await () async {
      final fs = await readFilesWithExtension(
        extensionsDirectory,
        extn: ".settings.json",
      ).toList();
      final files1 = fs.map((event) => path.basename(event.path));
      final files2 = defaultModels.map((e) => path.basename(e.path));
      final toAdd = [];
      files2.forEach((element) {
        if (!files1.contains(element)) {
          toAdd.add(element);
        }
      });
      toAdd.forEach((element) {
        fs.add(defaultModels.firstWhere((e) => e.path.endsWith(element)));
      });
      return fs;
    }();

    final componentsFolderFiles =
        await readFilesWithExtension(componentDirectory, extn: ".json")
            .toList();

    final apiJsons = await readAllFileToJson(apiFolderFiles);

    final _extnJsons = await readAllFileToJson(extensionFolderFiles);

    final extnJsons = () {
      final returnable = <File, Map<String, dynamic>>{};
      _extnJsons.forEach((key, value) {
        final name = path.basename(key.path);
        final defaultOne = defaultModels.firstWhere(
          (element) => element.path.endsWith(name),
        );
        returnable.addAll({defaultOne: value});
      });
      return returnable;
    }();

    final componentJsons = await readAllFileToJson(componentsFolderFiles);

    final l = Library((b) {
      b.directives.add((DirectiveBuilder()
            ..type = DirectiveType.import
            ..url = "package:simple_strapi/simple_strapi.dart")
          .build());
      b.directives.add((DirectiveBuilder()
            ..type = DirectiveType.import
            ..url = "dart:convert")
          .build());
      if (shouldGnerateWidgets) {
        b.directives.add((DirectiveBuilder()
              ..type = DirectiveType.import
              ..url = "package:flutter/widgets.dart")
            .build());
        b.body.add(Code(strapiBaseWidget));
        b.directives.add((DirectiveBuilder()
              ..type = DirectiveType.import
              ..url = "package:flutter/scheduler.dart")
            .build());
        b.body.add(Code(strapiBaseWidget));
      }
      apiJsons.forEach((key, value) {
        final collectionName = getCollectionNameFromRoutesFile(key);
        final classes = generateClass(
          key,
          value,
          false,
          collectionName,
        );
        b.body.addAll([
          ...classes,
        ]);
      });
      extnJsons.forEach((key, value) {
        final collectionName = getCollectionNameFromRoutesFile(key);
        final classes = generateClass(key, value, false, collectionName);
        b.body.addAll([
          ...classes,
        ]);
      });
      final completer = Completer<bool>();
      componentJsons.forEach((key, value) {
        final collectionName = getCollectionNameFromRoutesFile(key);
        final classes = generateClass(key, value, true, collectionName);
        b.body.addAll([
          ...classes,
        ]);
        if (key == componentJsons.keys.last) {
          completer.complete(true);
        }
      });
    });

    final e = DartEmitter();
    final f = DartFormatter();
    final dart = () {
      try {
        return f.format("${l.accept(e)}");
      } catch (_) {
        print("emitted dart code contains errors");
        return "${l.accept(e)}";
      }
    }();
    await outPutFile.writeAsString(dart);
  }

  Code generateCollectionClass(
      String className, String classVariableName, String? collectionName) {
    return Code(collectionClassString(
      className,
      classVariableName,
      collectionName,
      shouldGnerateWidgets,
      className.toLowerCase() == "user",
    ));
  }

  List<dynamic> generateClass(
    File file,
    Map<String, dynamic> j,
    bool isComponent,
    String? collectionName,
  ) {
    if (!j.containsKey("attributes")) {
      // print(j);
      // print(file);
      // print(isComponent);
      // print(collectionName);
      // throw Exception("attributes missing in the strapi model");
      return [];
    }
    final _name =
        path.basenameWithoutExtension(path.basenameWithoutExtension(file.path));

    final className = toClassName(_name);

    final collectionClassName = () {
      final ccn = toClassName(pluralize(className));
      if (ccn.toLowerCase() == className.toLowerCase()) {
        return ccn + "s";
      }
      return ccn;
    }();
    final camelClassName = toCamelClassName(className);
    final enumClasses = <Enum>[];
    final ifEnumerator = (String name, List<dynamic> enumerators) {
      enumClasses.add(Enum((b) {
        b
          ..name = name
          ..values.addAll(enumerators.map((e) => EnumValue((evb) {
                evb..name = e;
              })));
      }));
    };

    final fields = getFieldsFromStrapiAttributes(j["attributes"], ifEnumerator);

    final emptyFieldsField = Field(
      (b) => b
        ..name = "_emptyFields"
        ..type = Reference("_$className" "EmptyFields")
        ..assignment = Code(
          "_$className" "EmptyFields()",
        ),
    );

    final createdAtField = Field(
      (b) => {
        b
          ..name = "createdAt"
          ..type = Reference("DateTime?")
          ..modifier = FieldModifier.final$
      },
    );

    final updatedAtField = Field(
      (b) => {
        b
          ..name = "updatedAt"
          ..type = Reference("DateTime?")
          ..modifier = FieldModifier.final$
      },
    );

    final syncedField = Field(
      (b) => {
        b
          ..name = "_synced"
          ..type = Reference("bool")
          ..modifier = FieldModifier.final$
      },
    );

    final idField = Field(
      (b) => {
        b
          ..name = "id"
          ..type = Reference("String?")
          ..modifier = FieldModifier.final$
      },
    );

    final collectionNameField = Field(
      (b) => b
        ..name = "collectionName"
        ..static = true
        ..modifier = FieldModifier.final$
        ..assignment = Code("\"$collectionName\""),
    );

    final params = <Parameter>[];
    for (final field in fields) {
      params.add((ParameterBuilder()
            ..name = field.name
            ..toThis = true)
          .build());
    }

    final namedParams = <Parameter>[];
    for (final field in fields) {
      namedParams.add(
        (ParameterBuilder()
              ..name = field.name
              ..named = true
              ..toThis = true)
            .build(),
      );
    }

    final classBuilder = ClassBuilder();

    final constructorFromID = (ConstructorBuilder()
          ..name = "fromID"
          ..requiredParameters.add((ParameterBuilder()
                ..name = idField.name
                ..toThis = true)
              .build())
          ..initializers.addAll([
            Code("_synced = false"),
            ...fields.map((e) => Code("${e.name} = null")),
            Code("${createdAtField.name} = null"),
            Code("${updatedAtField.name} = null")
          ]))
        .build();

    final constructorDefault = (ConstructorBuilder()
          ..optionalParameters.addAll([
            ...namedParams,
          ]))
        .build();

    final constructorFresh = (ConstructorBuilder()
          ..name = "fresh"
          ..optionalParameters.addAll([
            ...namedParams,
          ])
          ..initializers.addAll([
            Code("_synced = false"),
            Code("${createdAtField.name} = null"),
            Code("${updatedAtField.name} = null"),
            Code("${idField.name} = null"),
          ]))
        .build();

    final constructor_synced = (ConstructorBuilder()
          ..name = "_synced"
          ..requiredParameters.addAll([
            ...fields.map((e) => (ParameterBuilder()
                  ..name = e.name
                  ..toThis = true)
                .build()),
            (ParameterBuilder()
                  ..name = createdAtField.name
                  ..toThis = true)
                .build(),
            (ParameterBuilder()
                  ..name = updatedAtField.name
                  ..toThis = true)
                .build(),
            (ParameterBuilder()
                  ..name = idField.name
                  ..toThis = true)
                .build(),
          ])
          ..initializers.addAll([
            Code("_synced = true"),
          ]))
        .build();

    final constructor_unsynced = (ConstructorBuilder()
          ..name = "_unsynced"
          ..requiredParameters.addAll([
            ...fields.map((e) => (ParameterBuilder()
                  ..name = e.name
                  ..toThis = true)
                .build()),
            if (!isComponent)
              (ParameterBuilder()
                    ..name = createdAtField.name
                    ..toThis = true)
                  .build(),
            if (!isComponent)
              (ParameterBuilder()
                    ..name = updatedAtField.name
                    ..toThis = true)
                  .build(),
            if (!isComponent)
              (ParameterBuilder()
                    ..name = idField.name
                    ..toThis = true)
                  .build(),
          ])
          ..initializers.addAll([
            if (!isComponent) Code("_synced = false"),
          ]))
        .build();

    final getSyncedMethod = (MethodBuilder()
          ..name = "synced"
          ..lambda = true
          ..type = MethodType.getter
          ..returns = Reference("bool")
          ..body = Code("_synced"))
        .build();

    final getFieldsMethod = (MethodBuilder()
          ..name = "fields"
          ..lambda = true
          ..static = true
          ..type = MethodType.getter
          ..returns = Reference("_${className}Fields")
          ..body = Code("_${className}Fields.i"))
        .build();

    final syncMethod = (MethodBuilder()
          ..name = "sync"
          ..returns = Reference("Future<$className>")
          ..modifier = MethodModifier.async
          ..body = CodeExpression(Code(
                  "if(!synced){return this;}\nfinal _id = this.id;\nif(_id is! String){return this;}\nfinal response = await $collectionClassName.findOne(_id);\nif(response is $className){ return response;} else { return this;}"))
              .code)
        .build();

    final copyWithMethod = (MethodBuilder()
          ..name = "copyWIth"
          ..returns = Reference("$className")
          ..optionalParameters.addAll(fields.map((field) => (ParameterBuilder()
                ..name = field.name
                ..named = true
                ..type = field.type)
              .build()))
          ..body = CodeExpression(Code("$className._unsynced")).call([
            ...fields
                .map((field) =>
                    CodeExpression(Code("${field.name}??this.${field.name}")))
                .toList(),
            CodeExpression(Code("this.${createdAtField.name}")),
            CodeExpression(Code("this.${updatedAtField.name}")),
            CodeExpression(Code("this.${idField.name}")),
          ]).code)
        .build();

    final setNullMethod = (MethodBuilder()
          ..name = "setNull"
          ..returns = Reference("$className")
          ..optionalParameters.addAll(fields.map((field) => (ParameterBuilder()
                ..name = field.name
                ..named = true
                ..type = Reference("bool")
                ..defaultTo = Code("false"))
              .build()))
          ..body = Block.of([
            CodeExpression(Code("return $className._unsynced")).call([
              ...fields
                  .map((field) => CodeExpression(
                      Code("${field.name}?null:this.${field.name}")))
                  .toList(),
              CodeExpression(Code("this.${createdAtField.name}")),
              CodeExpression(Code("this.${updatedAtField.name}")),
              CodeExpression(Code("this.${idField.name}")),
            ]).code,
            Code(
              fields
                  .map(
                      (field) => ".._emptyFields.${field.name} = ${field.name}")
                  .join(""),
            ),
            Code(";"),
          ]))
        .build();

    final accessFromMapExpression = (Field f, bool fromMap) {
      final type = f.type;
      if (type is CollectionListReference) {
        if (type.className == "dynamic") {
          return CodeExpression(
            fromMap
                ? Code("map[\"${f.name}\"]")
                : Code("\"${f.name}\":${f.name}"),
          );
        }
        return fromMap
            ? CodeExpression(
                Code(
                    "StrapiUtils.objFromListOfMap<${type.className}>(map[\"${f.name}\"],(e)=>${pluralize(type.className)}._fromIDorData(e))"),
              )
            : CodeExpression(
                Code(
                    "\"${f.name}\":${f.name}?.map((e)=>toServer?e.id:e._toMap(level:level+level)).toList()"),
              );
      }
      if (type is CollectionReference) {
        return CodeExpression(
          fromMap
              ? Code(
                  "StrapiUtils.objFromMap<${type.className}>(map[\"${f.name}\"],(e)=>${pluralize(type.className)}._fromIDorData(e))")
              : Code(
                  "\"${f.name}\":toServer?${f.name}?.id:${f.name}?._toMap(level:level+level)"),
        );
      }
      if (type is ComponentListReference) {
        return CodeExpression(
          fromMap
              ? Code(
                  "StrapiUtils.objFromListOfMap<${type.className}>(map[\"${f.name}\"],(e)=>${type.className}.fromMap(e))")
              : Code(
                  "\"${f.name}\":${f.name}?.map((e)=>e._toMap(level:level+level)).toList()",
                ),
        );
      }
      if (type is ComponentReference) {
        return CodeExpression(
          fromMap
              ? Code(
                  "StrapiUtils.objFromMap<${type.className}>(map[\"${f.name}\"],(e)=>${type.className}.fromMap(e))")
              : Code("\"${f.name}\":${f.name}?._toMap(level:level+level)"),
        );
      }
      if (type.symbol == "DateTime?") {
        return CodeExpression(
          fromMap
              ? Code("StrapiUtils.parseDateTime(map[\"${f.name}\"])")
              : Code("\"${f.name}\":${f.name}?.toIso8601String()"),
        );
      }
      if (type.symbol == "double?") {
        return CodeExpression(
          fromMap
              ? Code("StrapiUtils.parseDouble(map[\"${f.name}\"])")
              : Code("\"${f.name}\":${f.name}"),
        );
      }
      if (type.symbol == "int?") {
        return CodeExpression(
          fromMap
              ? Code("StrapiUtils.parseInt(map[\"${f.name}\"])")
              : Code("\"${f.name}\":${f.name}"),
        );
      }
      if (type.symbol == "bool?") {
        return CodeExpression(
          fromMap
              ? Code("StrapiUtils.parseBool(map[\"${f.name}\"])")
              : Code("\"${f.name}\":${f.name}"),
        );
      }
      if (type.symbol == "Map<String,dynamic>?") {
        return CodeExpression(
          fromMap
              ? Code("map[\"${f.name}\"]")
              : Code("\"${f.name}\":${f.name}"),
        );
      }
      if (type is EnumeratorReference) {
        return fromMap
            ? CodeExpression(Code(
                "StrapiUtils.toEnum<${type.enumName}>(${type.enumName}.values,map[\"${f.name}\"])"))
            : CodeExpression(
                Code("\"${f.name}\":StrapiUtils.enumToString(${f.name})"));
      }
      return fromMap
          ? CodeExpression(Code("map[\"${f.name}\"]"))
          : CodeExpression(Code("\"${f.name}\":${f.name}"));
    };

    final toMapMethod = Method((b) => b
      ..name = "toMap"
      ..returns = Reference("Map<String,dynamic>")
      ..lambda = true
      ..body = Code("_toMap(level:-1)"));

    final _getNullForType = (Field field) {
      final type = field.type.runtimeType;
      if (type == ComponentListReference || type == CollectionListReference) {
        return "[]";
      }
      return "null";
    };

    final toPrivateMapMethod = (MethodBuilder()
          ..name = "_toMap"
          ..returns = Reference("Map<String,dynamic>")
          ..optionalParameters.add(Parameter((b) => b
            ..name = "level"
            ..named = true
            ..type = Reference("int")
            ..defaultTo = Code("0")))
          ..body = Code(
            "final toServer = level==0;\nreturn {${[
              ...fields.map((field) => CodeExpression(Code(isComponent
                      ? "${accessFromMapExpression(field, false).code.toString()}"
                      : ("if(_emptyFields.${field.name})\"${field.name}\":${_getNullForType(field)} else if(!_emptyFields.${field.name}&&${field.name}!=null) ${accessFromMapExpression(field, false).code.toString()}")))
                  .code
                  .toString()),
              /* if (!isComponent)
                accessFromMapExpression(createdAtField, false).code.toString(),
              if (!isComponent)
                accessFromMapExpression(updatedAtField, false).code.toString(), */
              if (!isComponent)
                accessFromMapExpression(idField, false).code.toString(),
            ].fold<List<String>>([], (pv, e) {
              if (e is String && e.isNotEmpty) {
                return [...pv, e];
              }
              return pv;
            }).join(",")}};",
          ))
        .build();

    final fromSyncedMapMethod = (MethodBuilder()
          ..name = "fromSyncedMap"
          ..static = true
          ..returns = Reference(className)
          ..requiredParameters.add((ParameterBuilder()
                ..name = "map"
                ..type = Reference("Map<dynamic,dynamic>"))
              .build())
          ..body = CodeExpression(Code("$className._synced")).call([
            ...fields.map((field) => accessFromMapExpression(field, true)),
            if (!isComponent) accessFromMapExpression(createdAtField, true),
            if (!isComponent) accessFromMapExpression(updatedAtField, true),
            if (!isComponent) accessFromMapExpression(idField, true)
          ]).code)
        .build();

    final fromMapMethod = (MethodBuilder()
          ..name = "fromMap"
          ..static = true
          ..returns = Reference(className + "?")
          ..requiredParameters.add((ParameterBuilder()
                ..name = "map"
                ..type = Reference("Map<String,dynamic>"))
              .build())
          ..body = CodeExpression(Code("$className._unsynced")).call([
            ...fields.map((field) => accessFromMapExpression(field, true)),
            if (!isComponent) accessFromMapExpression(createdAtField, true),
            if (!isComponent) accessFromMapExpression(updatedAtField, true),
            if (!isComponent) accessFromMapExpression(idField, true)
          ]).code)
        .build();

    final toStringMethod = (MethodBuilder()
          ..name = "toString"
          ..returns = Reference("String")
          ..lambda = true
          ..annotations.addAll([CodeExpression(Code("override"))])
          ..body = Code(
              '''"${isComponent ? "[Strapi Component Type $className]: " : "[Strapi Collection Type $className]"}\\n"+_toMap().toString()'''))
        .build();

    classBuilder
      ..name = className
      ..fields.addAll([
        if (!isComponent) syncedField,
        ...fields,
        if (!isComponent) createdAtField,
        if (!isComponent) updatedAtField,
        if (!isComponent) idField,
        if (!isComponent) collectionNameField,
        if (!isComponent) emptyFieldsField,
      ])
      ..constructors.addAll([
        if (!isComponent) constructorFromID,
        if (!isComponent) constructorFresh,
        if (!isComponent) constructor_synced,
        constructor_unsynced,
        if (isComponent) constructorDefault,
      ])
      ..methods.addAll([
        if (!isComponent) getSyncedMethod,
        if (!isComponent) copyWithMethod,
        if (!isComponent) setNullMethod,
        if (!isComponent) fromSyncedMapMethod,
        fromMapMethod,
        toMapMethod,
        toPrivateMapMethod,
        if (!isComponent) syncMethod,
        getFieldsMethod,
        toStringMethod
      ]);

    return [
      ...enumClasses,
      classBuilder.build(),
      if (!isComponent)
        generateCollectionClass(className, camelClassName, collectionName),
      generateFieldsClass(
        className,
        camelClassName,
        collectionName,
        [
          ...fields,
          if (!isComponent) createdAtField,
          if (!isComponent) updatedAtField,
          if (!isComponent) idField,
        ],
        isComponent,
      ),
      generateEmptyFieldsClass(
        className,
        camelClassName,
        fields,
      ),
    ];
  }

  Class generateEmptyFieldsClass(
    String className,
    String camelClassName,
    List<Field> fields,
  ) {
    return Class(
      (b) => b
        ..name = "_$className" "EmptyFields"
        ..fields.addAll(
          fields.map(
            (e) => Field(
              (fb) => fb
                ..name = e.name
                ..type = Reference("bool")
                ..assignment = Code("false"),
            ),
          ),
        ),
    );
  }

  Class generateFieldsClass(
    String className,
    String camelClassName,
    collectionName,
    List<Field> fields,
    bool isComponent,
  ) {
    final b = ClassBuilder();
    b
      ..name = "_${className}Fields"
      ..fields.add(Field((fb) {
        fb
          ..name = "i"
          ..type = Reference("_${className}Fields")
          ..assignment = Code("_${className}Fields._i()")
          ..static = true
          ..modifier = FieldModifier.final$;
      }))
      ..constructors.add(Constructor((cb) {
        cb..name = "_i";
      }))
      ..methods.add(Method((b) {
        b
          ..name = "call"
          ..body = Code("return ${isComponent ? "\"{" : "["}${fields.map((e) {
            if (isComponent) {
              if ((e.type is ComponentReference ||
                  e.type is ComponentListReference)) {
                final cn = (e.type as dynamic).className;
                return "${e.name}\${_${toClassName(cn)}Fields.i()}";
              } else if ((e.type is CollectionListReference ||
                  e.type is CollectionReference)) {
                return "${e.name}{id}";
              }
            }
            return e.name;
          }).join(",")}${isComponent ? "}\"" : "]"};")
          ..returns = Reference(
            isComponent ? "String" : "List<StrapiField>",
          );
      }))
      ..fields.addAll(fields.map((e) {
        final ref = e.type;
        if (ref is CollectionListReference) {
          final fb = FieldBuilder();
          fb
            ..name = e.name
            ..modifier = FieldModifier.final$
            ..assignment = Code("StrapiCollectionField(\"${e.name}\")");
          return fb.build();
        } else if (ref is CollectionReference) {
          final fb = FieldBuilder();
          fb
            ..name = e.name
            ..modifier = FieldModifier.final$
            ..assignment = Code("StrapiModelField(\"${e.name}\")");
          return fb.build();
        } else if (ref is ComponentListReference || ref is ComponentReference) {
          final fb = FieldBuilder();
          fb
            ..name = e.name
            ..modifier = FieldModifier.final$
            ..assignment = Code("StrapiComponentField(\"${e.name}\")");
          return fb.build();
        } else {
          final fb = FieldBuilder();
          fb
            ..name = e.name
            ..modifier = FieldModifier.final$
            ..assignment = Code("StrapiLeafField(\"${e.name}\")");
          return fb.build();
        }
      }));
    return b.build();
  }

  Future<Map<File, Map<String, dynamic>>> readAllFileToJson(
      List<File> files) async {
    final returnable = <File, Map<String, dynamic>>{};
    for (final file in files) {
      returnable.addAll({file: await readToJson(file)});
    }
    return returnable;
  }

  Future<Map<String, dynamic>> readToJson(File file) async {
    try {
      final content = await file.readAsString();
      final j = json.decode(content);
      return j;
    } catch (e) {
      print("unable to read file to json ${file.path}");
    }
    return {};
  }
}
