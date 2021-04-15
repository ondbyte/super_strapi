import 'package:code_builder/code_builder.dart';
import 'package:inflection2/inflection2.dart';

import 'helpers.dart';

Reference? getDartTypeFromStrapiType({
  String name = "",
  String strapiType = "",
  String component = "",
  String collection = "",
  String model = "",
  bool componentRepeatable = false,
}) {
  switch (strapiType) {
    case "date":
    case "datetime":
    case "time":
      {
        return Reference(
          "DateTime?",
        );
      }
    case "decimal":
    case "float":
      {
        return Reference("double?");
      }
    case "integer":
    case "biginteger":
      {
        return Reference("int?");
      }
    case "string":
    case "richtext":
    case "text":
      {
        return Reference("String?");
      }
    case "boolean":
      {
        return Reference("bool?");
      }
    case "email":
      {
        return Reference("String?");
      }
    case "json":
      {
        return Reference("Map<String,dynamic>?");
      }
    case "enumeration":
      {
        final enumName = toClassName(name);
        return EnumeratorReference(
          "$enumName?",
          enumName,
        );
      }
    case "component":
      {
        if (component.isEmpty) {
          throw Exception("component cannot be empty while referencing a type");
        }
        final className = toClassName(component);
        if (componentRepeatable) {
          return ComponentListReference("List<$className>?", className);
        } else {
          return ComponentReference("$className?", className);
        }
        return null;
      }
    case "":
      {
        if (model.isNotEmpty) {
          final className = toClassName(model);
          return CollectionReference(className + "?", className);
        } else if (collection.isNotEmpty) {
          final className = toClassName(collection);
          return CollectionListReference("List<$className>?", className);
        } else {
          throw Exception("model and collection both cannot be empty");
        }
        return null;
      }
    default:
      {
        return null;
      }
  }
}

class CollectionListReference extends Reference {
  final className;
  CollectionListReference(
    String symbol,
    this.className,
  ) : super(symbol);
}

class EnumeratorReference extends Reference {
  final String enumName;
  EnumeratorReference(String symbol, this.enumName) : super(symbol);
}

class CollectionReference extends Reference {
  final className;
  CollectionReference(
    String symbol,
    this.className,
  ) : super(symbol);
}

class ComponentListReference extends Reference {
  final className;
  ComponentListReference(
    String symbol,
    this.className,
  ) : super(symbol);
}

class ComponentReference extends Reference {
  final className;
  ComponentReference(
    String symbol,
    this.className,
  ) : super(symbol);
}

List<Field> getFieldsFromStrapiAttributes(Map<String, dynamic> attributes,
    Function(String, List<dynamic>) ifEnumerator) {
  final returnable = <Field>[];
  attributes.forEach(
    (name, value) {
      final type = getDartTypeFromStrapiType(
        name: name,
        strapiType: value["type"] ?? "",
        component: (value["component"] != null)
            ? (value["component"] ?? "").split(".").last
            : "",
        model: value["model"] ?? "",
        collection: value["collection"] ?? "",
        componentRepeatable: value["repeatable"],
      );
      if (type is Reference) {
        final enums = value["enum"];
        if (enums != null) {
          ifEnumerator(type.symbol.replaceAll("?", ""), enums);
        }
        if (type is Reference) {
          returnable.add(
            Field(
              (b) => b
                ..name = name
                ..type = type
                ..modifier = FieldModifier.final$,
            ),
          );
        }
      }
    },
  );
  //print(returnable.map((e) => e.type.runtimeType.toString()).join("\n"));
  return returnable;
}

extension FieldExt on Field {
  Code accessFromMap() {
    switch (type.symbol) {
      case "DateTime?":
        {
          return Code("DateTime.tryParse2(map[\"$name\"])");
        }
      case "double?":
        {
          return Code("double.tryParse2(map[\"$name\"])");
        }
      case "int?":
        {
          return Code("int.tryParse2(map[\"$name\"])");
        }
      case "String?":
        {
          return Code("map[\"$name\"]");
        }
      case "Map<String,dynamic>?":
        {
          return Code("map[\"$name\"]");
        }
      default:
        {
          {
            if (type.symbol.endsWith("Component")) {
              return Code("${type.symbol}.fromMap(map[\"$name\"])");
            }
            if (type.symbol.startsWith("List<")) {
              final sym =
                  type.symbol.replaceAll("List<", "").replaceAll(">", "");
              return Code("$sym" "Collection.fromIDs(map[\"$name\"])");
            }
          }
          return Code("");
        }
    }
  }
}

final collectionClassString =
    // ignore: top_level_function_literal_block
    (String className, String classVariableName, String? collectionName,
        bool buildWidgets, bool isUserCollection) {
  final collectionClassName = () {
    final ccn = toClassName(pluralize(className));
    if (ccn.toLowerCase() == className.toLowerCase()) {
      return ccn + "s";
    }
    return ccn;
  }();
  if (collectionName == null || collectionName.isEmpty) {
    collectionName = pluralize(className);
  }
  var returnable = '''
class <CollectionClassName> {
  static const collectionName = "<collectionName>";

  static List<className?> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => className.fromID(id)).toList();
  }

  static Future<className?> findOne(String id) async {
    try{
      final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return className.fromSyncedMap(mapResponse);
    }
    }catch (e,s){
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<List<className>> findMultiple({int limit = 16}) async {
    try{
      final list =
        await StrapiCollection.findMultiple(collection: collectionName,limit:limit,);
    if (list.isNotEmpty) {
      return list.map((map) => className.fromSyncedMap(map)).toList();
    }
    }catch (e,s){
      sPrint(e);
      sPrint(s);
    }
    return [];
  }

  static Future<className?> create(className classVariableName) async {
    try{
      final map = await StrapiCollection.create(
      collection: collectionName,
      data: classVariableName._toMap(level:0),
    );
    if (map.isNotEmpty) {
      return className.fromSyncedMap(map);
    }
    }catch (e,s){
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<className?> update(className classVariableName) async {
    try{
      final id = classVariableName.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: classVariableName._toMap(level:0),
      );
      if (map.isNotEmpty) {
        return className.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
      }
      catch (e,s){
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<int> count() async {
    try{
      return await StrapiCollection.count(collectionName);
    }catch (e,s){
      sPrint(e);
      sPrint(s);
    }
      return 0;
  }

  static Future<className?> delete(className classVariableName) async {
    try{
      final id = classVariableName.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return className.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
    }catch (e,s){
      sPrint(e);
      sPrint(s);
    }
  }  
  

  static className? _fromIDorData(idOrData) {
    if (idOrData is String) {
      return className.fromID(idOrData);
    }
    if (idOrData is Map) {
      return className.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<className>> executeQuery(StrapiCollectionQuery query,{int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(collectionName:collectionName,);
    try{
      final response = await Strapi.i.graphRequest(queryString,maxTimeOutInMillis:maxTimeOutInMillis);
      if(response.body.isNotEmpty){
        final object = response.body.first;
        if(object is Map&&object.containsKey("data")){
          final data = object["data"];
          if(data is Map&&data.containsKey(query.collectionName)){
            final myList = data[query.collectionName];
            if(myList is List){
              final list = <className>[];
              myList.forEach((e){
                final o = _fromIDorData(e);
                if(o is className){
                  list.add(o);
                }
              });
              return list;
            } else if(myList is Map&&myList.containsKey("id")){
              final o = _fromIDorData(myList);
              if(o is className){
                return [o];
              }
            }
          }
        }
      }
    }catch (e,s){
      sPrint(e);
      sPrint(s);
    }
    return [];
  }

  

  <userMe>

  <widgetBuilder>
}''';
  var userMeString = "";
  if (isUserCollection) {
    userMeString = '''
    static className? _me;
  static Future<className?> me({asFindOne:false}) async {
    final _id = _me?.id;
    if(asFindOne&&(_me is className && _id is String)){
      return findOne(_id);
    }
    try{
      if(Strapi.i.strapiToken.isEmpty){
      throw StrapiException(msg:"cannot get users/me endpoint without token, please authenticate first");
    }
    final response = await StrapiCollection.customEndpoint(
      collection:"users",
      endPoint: "me"
    );
    if (response is List && response.isNotEmpty) {
      _me = className.fromSyncedMap(response.first);
    }
    if(_me is className && asFindOne){
      return me(asFindOne:asFindOne);
    }
    return _me;
    } catch (e,s){
      sPrint(e);
      sPrint(s);
    }
  }''';
  }
  returnable = returnable.replaceFirst("<userMe>", userMeString);
  var widgetBuilderSTring = "";
  if (buildWidgets) {
    // ignore: prefer_double_quotes
    widgetBuilderSTring = '''
  static Widget listenerWidget({
    required className strapiObject,
    bool sync = false,
    required Widget Function(
      BuildContext,
      className,
    )
        builder,
  }) {
    return _StrapiListenerWidget<className>(
      strapiObject: strapiObject,
      generator: className.fromMap,
      builder: builder,
      sync:sync,
    );
  }''';
  }
  returnable = returnable.replaceAll("<widgetBuilder>", widgetBuilderSTring);

  returnable = returnable
      .replaceAll("className", className)
      .replaceAll("classVariableName", classVariableName)
      .replaceAll("<CollectionClassName>", collectionClassName)
      .replaceAll("<collectionName>", collectionName);
  return returnable;
};

final strapiBaseWidget = '''

class _StrapiListenerWidget<T> extends StatefulWidget {
  final bool sync;
  final T strapiObject;
  final T? Function(Map<String, dynamic>) generator;
  final Widget Function(BuildContext, T) builder;
  _StrapiListenerWidget({
    Key? key,
    required this.strapiObject,
    required this.generator,
    required this.builder,
    required this.sync,
  }) : super(key: key);

  @override
  _StrapiListenerWidgetState<T> createState() => _StrapiListenerWidgetState();
}

class _StrapiListenerWidgetState<T> extends State<_StrapiListenerWidget<T>> {
  late T _strapiObject;
  late final StrapiObjectListener? _listener;
  @override
  void initState() {
    super.initState();
    _strapiObject = widget.strapiObject;

    final id = (widget.strapiObject as dynamic).id;
    if (id is String) {
      _listener = StrapiObjectListener(
        id: id,
        listener: (map) {
          final updated = widget.generator(map);
          if (updated is T) {
            setState(() {
              _strapiObject = updated;
            });
          }
        },
      );
      if (widget.sync) {
        (_strapiObject as dynamic).sync();
      }
    } else {
      _listener = null;
    }
  }

  @override
  void dispose() {
    _listener?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _strapiObject,
    );
  }
}
''';
