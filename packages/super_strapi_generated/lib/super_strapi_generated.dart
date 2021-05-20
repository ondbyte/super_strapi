import 'package:simple_strapi/simple_strapi.dart';
import 'dart:convert';
import 'package:flutter/widgets.dart';

class _StrapiListenerWidget<T> extends StatefulWidget {
  final bool sync;
  final T strapiObject;
  final T? Function(Map<String, dynamic>) generator;
  final Widget Function(BuildContext, T, bool) builder;
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
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _strapiObject = widget.strapiObject;

    _postInit();
  }

  void _postInit() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final id = (_strapiObject as dynamic).id;
      if (id is String) {
        _listener = StrapiObjectListener(
          id: id,
          initailData: (_strapiObject as dynamic).toMap(),
          listener: (map, loading) {
            final updated = widget.generator(map);
            if (updated is T) {
              setState(() {
                _strapiObject = updated;
                _loading = loading;
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
    });
  }

  @override
  void dispose() {
    _listener?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _strapiObject, _loading);
  }
}

class City {
  City.fromID(this.id)
      : _synced = false,
        name = null,
        enabled = null,
        country = null,
        localities = null,
        createdAt = null,
        updatedAt = null;

  City.fresh({this.name, this.enabled, this.country, this.localities})
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  City._synced(this.name, this.enabled, this.country, this.localities,
      this.createdAt, this.updatedAt, this.id)
      : _synced = true;

  City._unsynced(this.name, this.enabled, this.country, this.localities,
      this.createdAt, this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final String? name;

  final bool? enabled;

  final Country? country;

  final List<Locality>? localities;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  static final collectionName = "cities";

  _CityEmptyFields _emptyFields = _CityEmptyFields();

  bool get synced => _synced;
  City copyWIth(
          {String? name,
          bool? enabled,
          Country? country,
          List<Locality>? localities}) =>
      City._unsynced(
          name ?? this.name,
          enabled ?? this.enabled,
          country ?? this.country,
          localities ?? this.localities,
          this.createdAt,
          this.updatedAt,
          this.id);
  City setNull(
      {bool name = false,
      bool enabled = false,
      bool country = false,
      bool localities = false}) {
    return City._unsynced(
        name ? null : this.name,
        enabled ? null : this.enabled,
        country ? null : this.country,
        localities ? null : this.localities,
        this.createdAt,
        this.updatedAt,
        this.id)
      .._emptyFields.name = name
      .._emptyFields.enabled = enabled
      .._emptyFields.country = country
      .._emptyFields.localities = localities;
  }

  static City fromSyncedMap(Map<dynamic, dynamic> map) => City._synced(
      map["name"],
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.objFromMap<Country>(
          map["country"], (e) => Countries._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Locality>(
          map["localities"], (e) => Localities._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  static City? fromMap(Map<String, dynamic> map) => City._unsynced(
      map["name"],
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.objFromMap<Country>(
          map["country"], (e) => Countries._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Locality>(
          map["localities"], (e) => Localities._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  Map<String, dynamic> toMap() => _toMap(level: -1);
  Map<String, dynamic> _toMap({int level = 0}) {
    final toServer = level == 0;
    return {
      if (_emptyFields.name)
        "name": null
      else if (!_emptyFields.name && name != null)
        "name": name,
      if (_emptyFields.enabled)
        "enabled": null
      else if (!_emptyFields.enabled && enabled != null)
        "enabled": enabled,
      if (_emptyFields.country)
        "country": null
      else if (!_emptyFields.country && country != null)
        "country":
            toServer ? country?.id : country?._toMap(level: level + level),
      if (_emptyFields.localities)
        "localities": []
      else if (!_emptyFields.localities && localities != null)
        "localities": localities
            ?.map((e) => toServer ? e.id : e._toMap(level: level + level))
            .toList(),
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "id": id
    };
  }

  Future<City> sync() async {
    if (!synced) {
      return this;
    }
    final _id = this.id;
    if (_id is! String) {
      return this;
    }
    final response = await Cities.findOne(_id);
    if (response is City) {
      return response;
    } else {
      return this;
    }
  }

  static _CityFields get fields => _CityFields.i;
  @override
  String toString() => "[Strapi Collection Type City]\n" + _toMap().toString();
}

class Cities {
  static const collectionName = "cities";

  static List<City?> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => City.fromID(id)).toList();
  }

  static Future<City?> findOne(
    String id,
  ) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return City.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<City>> findMultiple({int limit = 16}) async {
    final list = await StrapiCollection.findMultiple(
      collection: collectionName,
      limit: limit,
    );
    if (list.isNotEmpty) {
      return list.map((map) => City.fromSyncedMap(map)).toList();
    }
    return [];
  }

  static Future<City?> create(City city) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: city._toMap(level: 0),
    );
    if (map.isNotEmpty) {
      return City.fromSyncedMap(map);
    }
  }

  static Future<City?> update(City city) async {
    final id = city.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: city._toMap(level: 0),
      );
      if (map.isNotEmpty) {
        return City.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<City?> delete(City city) async {
    final id = city.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return City.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }

  static City? _fromIDorData(idOrData) {
    if (idOrData is String) {
      return City.fromID(idOrData);
    }
    if (idOrData is Map) {
      if ((idOrData.containsKey("createdAt") ||
              idOrData.containsKey("updatedAt")) &&
          (idOrData["createdAt"] == null || idOrData["updatedAt"] == null)) {
        final id = idOrData["id"];
        return City.fromID(id);
      }
      return City.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<City>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    final response = await Strapi.i
        .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
    if (response.body.isNotEmpty) {
      final object = response.body.first;
      if (object is Map && object.containsKey("data")) {
        final data = object["data"];
        if (data is Map && data.containsKey(query.collectionName)) {
          final myList = data[query.collectionName];
          if (myList is List) {
            final list = <City>[];
            myList.forEach((e) {
              final o = _fromIDorData(e);
              if (o is City) {
                list.add(o);
              }
            });
            return list;
          } else if (myList is Map && myList.containsKey("id")) {
            final o = _fromIDorData(myList);
            if (o is City) {
              return [o];
            }
          }
        }
      }
    }
    return [];
  }

  static Widget listenerWidget({
    Key? key,
    required City strapiObject,
    bool sync = false,
    required Widget Function(
      BuildContext,
      City,
      bool,
    )
        builder,
  }) {
    return _StrapiListenerWidget<City>(
      key: key,
      strapiObject: strapiObject,
      generator: City.fromMap,
      builder: builder,
      sync: sync,
    );
  }
}

class _CityFields {
  _CityFields._i();

  static final _CityFields i = _CityFields._i();

  final name = StrapiLeafField("name");

  final enabled = StrapiLeafField("enabled");

  final country = StrapiModelField("country");

  final localities = StrapiCollectionField("localities");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [name, enabled, country, localities, createdAt, updatedAt, id];
  }
}

class _CityEmptyFields {
  bool name = false;

  bool enabled = false;

  bool country = false;

  bool localities = false;
}

class Employee {
  Employee.fromID(this.id)
      : _synced = false,
        name = null,
        image = null,
        enabled = null,
        user = null,
        bookings = null,
        holidays = null,
        business = null,
        starRating = null,
        createdAt = null,
        updatedAt = null;

  Employee.fresh(
      {this.name,
      this.image,
      this.enabled,
      this.user,
      this.bookings,
      this.holidays,
      this.business,
      this.starRating})
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  Employee._synced(
      this.name,
      this.image,
      this.enabled,
      this.user,
      this.bookings,
      this.holidays,
      this.business,
      this.starRating,
      this.createdAt,
      this.updatedAt,
      this.id)
      : _synced = true;

  Employee._unsynced(
      this.name,
      this.image,
      this.enabled,
      this.user,
      this.bookings,
      this.holidays,
      this.business,
      this.starRating,
      this.createdAt,
      this.updatedAt,
      this.id)
      : _synced = false;

  final bool _synced;

  final String? name;

  final List<StrapiFile>? image;

  final bool? enabled;

  final User? user;

  final List<Booking>? bookings;

  final List<Holiday>? holidays;

  final Business? business;

  final double? starRating;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  static final collectionName = "employees";

  _EmployeeEmptyFields _emptyFields = _EmployeeEmptyFields();

  bool get synced => _synced;
  Employee copyWIth(
          {String? name,
          List<StrapiFile>? image,
          bool? enabled,
          User? user,
          List<Booking>? bookings,
          List<Holiday>? holidays,
          Business? business,
          double? starRating}) =>
      Employee._unsynced(
          name ?? this.name,
          image ?? this.image,
          enabled ?? this.enabled,
          user ?? this.user,
          bookings ?? this.bookings,
          holidays ?? this.holidays,
          business ?? this.business,
          starRating ?? this.starRating,
          this.createdAt,
          this.updatedAt,
          this.id);
  Employee setNull(
      {bool name = false,
      bool image = false,
      bool enabled = false,
      bool user = false,
      bool bookings = false,
      bool holidays = false,
      bool business = false,
      bool starRating = false}) {
    return Employee._unsynced(
        name ? null : this.name,
        image ? null : this.image,
        enabled ? null : this.enabled,
        user ? null : this.user,
        bookings ? null : this.bookings,
        holidays ? null : this.holidays,
        business ? null : this.business,
        starRating ? null : this.starRating,
        this.createdAt,
        this.updatedAt,
        this.id)
      .._emptyFields.name = name
      .._emptyFields.image = image
      .._emptyFields.enabled = enabled
      .._emptyFields.user = user
      .._emptyFields.bookings = bookings
      .._emptyFields.holidays = holidays
      .._emptyFields.business = business
      .._emptyFields.starRating = starRating;
  }

  static Employee fromSyncedMap(Map<dynamic, dynamic> map) => Employee._synced(
      map["name"],
      StrapiUtils.objFromListOfMap<StrapiFile>(
          map["image"], (e) => StrapiFiles._fromIDorData(e)),
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.objFromMap<User>(map["user"], (e) => Users._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Booking>(
          map["bookings"], (e) => Bookings._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Holiday>(
          map["holidays"], (e) => Holiday.fromMap(e)),
      StrapiUtils.objFromMap<Business>(
          map["business"], (e) => Businesses._fromIDorData(e)),
      StrapiUtils.parseDouble(map["starRating"]),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  static Employee? fromMap(Map<String, dynamic> map) => Employee._unsynced(
      map["name"],
      StrapiUtils.objFromListOfMap<StrapiFile>(
          map["image"], (e) => StrapiFiles._fromIDorData(e)),
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.objFromMap<User>(map["user"], (e) => Users._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Booking>(
          map["bookings"], (e) => Bookings._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Holiday>(
          map["holidays"], (e) => Holiday.fromMap(e)),
      StrapiUtils.objFromMap<Business>(
          map["business"], (e) => Businesses._fromIDorData(e)),
      StrapiUtils.parseDouble(map["starRating"]),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  Map<String, dynamic> toMap() => _toMap(level: -1);
  Map<String, dynamic> _toMap({int level = 0}) {
    final toServer = level == 0;
    return {
      if (_emptyFields.name)
        "name": null
      else if (!_emptyFields.name && name != null)
        "name": name,
      if (_emptyFields.image)
        "image": []
      else if (!_emptyFields.image && image != null)
        "image": image
            ?.map((e) => toServer ? e.id : e._toMap(level: level + level))
            .toList(),
      if (_emptyFields.enabled)
        "enabled": null
      else if (!_emptyFields.enabled && enabled != null)
        "enabled": enabled,
      if (_emptyFields.user)
        "user": null
      else if (!_emptyFields.user && user != null)
        "user": toServer ? user?.id : user?._toMap(level: level + level),
      if (_emptyFields.bookings)
        "bookings": []
      else if (!_emptyFields.bookings && bookings != null)
        "bookings": bookings
            ?.map((e) => toServer ? e.id : e._toMap(level: level + level))
            .toList(),
      if (_emptyFields.holidays)
        "holidays": []
      else if (!_emptyFields.holidays && holidays != null)
        "holidays":
            holidays?.map((e) => e._toMap(level: level + level)).toList(),
      if (_emptyFields.business)
        "business": null
      else if (!_emptyFields.business && business != null)
        "business":
            toServer ? business?.id : business?._toMap(level: level + level),
      if (_emptyFields.starRating)
        "starRating": null
      else if (!_emptyFields.starRating && starRating != null)
        "starRating": starRating,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "id": id
    };
  }

  Future<Employee> sync() async {
    if (!synced) {
      return this;
    }
    final _id = this.id;
    if (_id is! String) {
      return this;
    }
    final response = await Employees.findOne(_id);
    if (response is Employee) {
      return response;
    } else {
      return this;
    }
  }

  static _EmployeeFields get fields => _EmployeeFields.i;
  @override
  String toString() =>
      "[Strapi Collection Type Employee]\n" + _toMap().toString();
}

class Employees {
  static const collectionName = "employees";

  static List<Employee?> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => Employee.fromID(id)).toList();
  }

  static Future<Employee?> findOne(
    String id,
  ) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return Employee.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<Employee>> findMultiple({int limit = 16}) async {
    final list = await StrapiCollection.findMultiple(
      collection: collectionName,
      limit: limit,
    );
    if (list.isNotEmpty) {
      return list.map((map) => Employee.fromSyncedMap(map)).toList();
    }
    return [];
  }

  static Future<Employee?> create(Employee employee) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: employee._toMap(level: 0),
    );
    if (map.isNotEmpty) {
      return Employee.fromSyncedMap(map);
    }
  }

  static Future<Employee?> update(Employee employee) async {
    final id = employee.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: employee._toMap(level: 0),
      );
      if (map.isNotEmpty) {
        return Employee.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<Employee?> delete(Employee employee) async {
    final id = employee.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return Employee.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }

  static Employee? _fromIDorData(idOrData) {
    if (idOrData is String) {
      return Employee.fromID(idOrData);
    }
    if (idOrData is Map) {
      if ((idOrData.containsKey("createdAt") ||
              idOrData.containsKey("updatedAt")) &&
          (idOrData["createdAt"] == null || idOrData["updatedAt"] == null)) {
        final id = idOrData["id"];
        return Employee.fromID(id);
      }
      return Employee.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<Employee>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    final response = await Strapi.i
        .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
    if (response.body.isNotEmpty) {
      final object = response.body.first;
      if (object is Map && object.containsKey("data")) {
        final data = object["data"];
        if (data is Map && data.containsKey(query.collectionName)) {
          final myList = data[query.collectionName];
          if (myList is List) {
            final list = <Employee>[];
            myList.forEach((e) {
              final o = _fromIDorData(e);
              if (o is Employee) {
                list.add(o);
              }
            });
            return list;
          } else if (myList is Map && myList.containsKey("id")) {
            final o = _fromIDorData(myList);
            if (o is Employee) {
              return [o];
            }
          }
        }
      }
    }
    return [];
  }

  static Widget listenerWidget({
    Key? key,
    required Employee strapiObject,
    bool sync = false,
    required Widget Function(
      BuildContext,
      Employee,
      bool,
    )
        builder,
  }) {
    return _StrapiListenerWidget<Employee>(
      key: key,
      strapiObject: strapiObject,
      generator: Employee.fromMap,
      builder: builder,
      sync: sync,
    );
  }
}

class _EmployeeFields {
  _EmployeeFields._i();

  static final _EmployeeFields i = _EmployeeFields._i();

  final name = StrapiLeafField("name");

  final image = StrapiCollectionField("image");

  final enabled = StrapiLeafField("enabled");

  final user = StrapiModelField("user");

  final bookings = StrapiCollectionField("bookings");

  final holidays = StrapiComponentField("holidays");

  final business = StrapiModelField("business");

  final starRating = StrapiLeafField("starRating");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [
      name,
      image,
      enabled,
      user,
      bookings,
      holidays,
      business,
      starRating,
      createdAt,
      updatedAt,
      id
    ];
  }
}

class _EmployeeEmptyFields {
  bool name = false;

  bool image = false;

  bool enabled = false;

  bool user = false;

  bool bookings = false;

  bool holidays = false;

  bool business = false;

  bool starRating = false;
}

enum BookingType { normal, package }
enum BookingStatus {
  cancelledByUser,
  cancelledByStaff,
  cancelledByReceptionist,
  cancelledByManager,
  cancelledByOwner,
  walkin,
  pendingApproval,
  accepted,
  ongoing,
  finished,
  noShow,
  halfWayThrough
}

class Booking {
  Booking.fromID(this.id)
      : _synced = false,
        business = null,
        bookedOn = null,
        bookingStartTime = null,
        bookingEndTime = null,
        bookingType = null,
        packages = null,
        products = null,
        employee = null,
        review = null,
        bookingStatus = null,
        bookedByUser = null,
        createdAt = null,
        updatedAt = null;

  Booking.fresh(
      {this.business,
      this.bookedOn,
      this.bookingStartTime,
      this.bookingEndTime,
      this.bookingType,
      this.packages,
      this.products,
      this.employee,
      this.review,
      this.bookingStatus,
      this.bookedByUser})
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  Booking._synced(
      this.business,
      this.bookedOn,
      this.bookingStartTime,
      this.bookingEndTime,
      this.bookingType,
      this.packages,
      this.products,
      this.employee,
      this.review,
      this.bookingStatus,
      this.bookedByUser,
      this.createdAt,
      this.updatedAt,
      this.id)
      : _synced = true;

  Booking._unsynced(
      this.business,
      this.bookedOn,
      this.bookingStartTime,
      this.bookingEndTime,
      this.bookingType,
      this.packages,
      this.products,
      this.employee,
      this.review,
      this.bookingStatus,
      this.bookedByUser,
      this.createdAt,
      this.updatedAt,
      this.id)
      : _synced = false;

  final bool _synced;

  final Business? business;

  final DateTime? bookedOn;

  final DateTime? bookingStartTime;

  final DateTime? bookingEndTime;

  final BookingType? bookingType;

  final List<Package>? packages;

  final List<Product>? products;

  final Employee? employee;

  final Review? review;

  final BookingStatus? bookingStatus;

  final User? bookedByUser;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  static final collectionName = "bookings";

  _BookingEmptyFields _emptyFields = _BookingEmptyFields();

  bool get synced => _synced;
  Booking copyWIth(
          {Business? business,
          DateTime? bookedOn,
          DateTime? bookingStartTime,
          DateTime? bookingEndTime,
          BookingType? bookingType,
          List<Package>? packages,
          List<Product>? products,
          Employee? employee,
          Review? review,
          BookingStatus? bookingStatus,
          User? bookedByUser}) =>
      Booking._unsynced(
          business ?? this.business,
          bookedOn ?? this.bookedOn,
          bookingStartTime ?? this.bookingStartTime,
          bookingEndTime ?? this.bookingEndTime,
          bookingType ?? this.bookingType,
          packages ?? this.packages,
          products ?? this.products,
          employee ?? this.employee,
          review ?? this.review,
          bookingStatus ?? this.bookingStatus,
          bookedByUser ?? this.bookedByUser,
          this.createdAt,
          this.updatedAt,
          this.id);
  Booking setNull(
      {bool business = false,
      bool bookedOn = false,
      bool bookingStartTime = false,
      bool bookingEndTime = false,
      bool bookingType = false,
      bool packages = false,
      bool products = false,
      bool employee = false,
      bool review = false,
      bool bookingStatus = false,
      bool bookedByUser = false}) {
    return Booking._unsynced(
        business ? null : this.business,
        bookedOn ? null : this.bookedOn,
        bookingStartTime ? null : this.bookingStartTime,
        bookingEndTime ? null : this.bookingEndTime,
        bookingType ? null : this.bookingType,
        packages ? null : this.packages,
        products ? null : this.products,
        employee ? null : this.employee,
        review ? null : this.review,
        bookingStatus ? null : this.bookingStatus,
        bookedByUser ? null : this.bookedByUser,
        this.createdAt,
        this.updatedAt,
        this.id)
      .._emptyFields.business = business
      .._emptyFields.bookedOn = bookedOn
      .._emptyFields.bookingStartTime = bookingStartTime
      .._emptyFields.bookingEndTime = bookingEndTime
      .._emptyFields.bookingType = bookingType
      .._emptyFields.packages = packages
      .._emptyFields.products = products
      .._emptyFields.employee = employee
      .._emptyFields.review = review
      .._emptyFields.bookingStatus = bookingStatus
      .._emptyFields.bookedByUser = bookedByUser;
  }

  static Booking fromSyncedMap(Map<dynamic, dynamic> map) => Booking._synced(
      StrapiUtils.objFromMap<Business>(
          map["business"], (e) => Businesses._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["bookedOn"]),
      StrapiUtils.parseDateTime(map["bookingStartTime"]),
      StrapiUtils.parseDateTime(map["bookingEndTime"]),
      StrapiUtils.toEnum<BookingType>(BookingType.values, map["bookingType"]),
      StrapiUtils.objFromListOfMap<Package>(
          map["packages"], (e) => Package.fromMap(e)),
      StrapiUtils.objFromListOfMap<Product>(
          map["products"], (e) => Product.fromMap(e)),
      StrapiUtils.objFromMap<Employee>(
          map["employee"], (e) => Employees._fromIDorData(e)),
      StrapiUtils.objFromMap<Review>(
          map["review"], (e) => Reviews._fromIDorData(e)),
      StrapiUtils.toEnum<BookingStatus>(
          BookingStatus.values, map["bookingStatus"]),
      StrapiUtils.objFromMap<User>(
          map["bookedByUser"], (e) => Users._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  static Booking? fromMap(Map<String, dynamic> map) => Booking._unsynced(
      StrapiUtils.objFromMap<Business>(
          map["business"], (e) => Businesses._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["bookedOn"]),
      StrapiUtils.parseDateTime(map["bookingStartTime"]),
      StrapiUtils.parseDateTime(map["bookingEndTime"]),
      StrapiUtils.toEnum<BookingType>(BookingType.values, map["bookingType"]),
      StrapiUtils.objFromListOfMap<Package>(
          map["packages"], (e) => Package.fromMap(e)),
      StrapiUtils.objFromListOfMap<Product>(
          map["products"], (e) => Product.fromMap(e)),
      StrapiUtils.objFromMap<Employee>(
          map["employee"], (e) => Employees._fromIDorData(e)),
      StrapiUtils.objFromMap<Review>(
          map["review"], (e) => Reviews._fromIDorData(e)),
      StrapiUtils.toEnum<BookingStatus>(
          BookingStatus.values, map["bookingStatus"]),
      StrapiUtils.objFromMap<User>(
          map["bookedByUser"], (e) => Users._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  Map<String, dynamic> toMap() => _toMap(level: -1);
  Map<String, dynamic> _toMap({int level = 0}) {
    final toServer = level == 0;
    return {
      if (_emptyFields.business)
        "business": null
      else if (!_emptyFields.business && business != null)
        "business":
            toServer ? business?.id : business?._toMap(level: level + level),
      if (_emptyFields.bookedOn)
        "bookedOn": null
      else if (!_emptyFields.bookedOn && bookedOn != null)
        "bookedOn": bookedOn?.toIso8601String(),
      if (_emptyFields.bookingStartTime)
        "bookingStartTime": null
      else if (!_emptyFields.bookingStartTime && bookingStartTime != null)
        "bookingStartTime": bookingStartTime?.toIso8601String(),
      if (_emptyFields.bookingEndTime)
        "bookingEndTime": null
      else if (!_emptyFields.bookingEndTime && bookingEndTime != null)
        "bookingEndTime": bookingEndTime?.toIso8601String(),
      if (_emptyFields.bookingType)
        "bookingType": null
      else if (!_emptyFields.bookingType && bookingType != null)
        "bookingType": StrapiUtils.enumToString(bookingType),
      if (_emptyFields.packages)
        "packages": []
      else if (!_emptyFields.packages && packages != null)
        "packages":
            packages?.map((e) => e._toMap(level: level + level)).toList(),
      if (_emptyFields.products)
        "products": []
      else if (!_emptyFields.products && products != null)
        "products":
            products?.map((e) => e._toMap(level: level + level)).toList(),
      if (_emptyFields.employee)
        "employee": null
      else if (!_emptyFields.employee && employee != null)
        "employee":
            toServer ? employee?.id : employee?._toMap(level: level + level),
      if (_emptyFields.review)
        "review": null
      else if (!_emptyFields.review && review != null)
        "review": toServer ? review?.id : review?._toMap(level: level + level),
      if (_emptyFields.bookingStatus)
        "bookingStatus": null
      else if (!_emptyFields.bookingStatus && bookingStatus != null)
        "bookingStatus": StrapiUtils.enumToString(bookingStatus),
      if (_emptyFields.bookedByUser)
        "bookedByUser": null
      else if (!_emptyFields.bookedByUser && bookedByUser != null)
        "bookedByUser": toServer
            ? bookedByUser?.id
            : bookedByUser?._toMap(level: level + level),
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "id": id
    };
  }

  Future<Booking> sync() async {
    if (!synced) {
      return this;
    }
    final _id = this.id;
    if (_id is! String) {
      return this;
    }
    final response = await Bookings.findOne(_id);
    if (response is Booking) {
      return response;
    } else {
      return this;
    }
  }

  static _BookingFields get fields => _BookingFields.i;
  @override
  String toString() =>
      "[Strapi Collection Type Booking]\n" + _toMap().toString();
}

class Bookings {
  static const collectionName = "bookings";

  static List<Booking?> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => Booking.fromID(id)).toList();
  }

  static Future<Booking?> findOne(
    String id,
  ) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return Booking.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<Booking>> findMultiple({int limit = 16}) async {
    final list = await StrapiCollection.findMultiple(
      collection: collectionName,
      limit: limit,
    );
    if (list.isNotEmpty) {
      return list.map((map) => Booking.fromSyncedMap(map)).toList();
    }
    return [];
  }

  static Future<Booking?> create(Booking booking) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: booking._toMap(level: 0),
    );
    if (map.isNotEmpty) {
      return Booking.fromSyncedMap(map);
    }
  }

  static Future<Booking?> update(Booking booking) async {
    final id = booking.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: booking._toMap(level: 0),
      );
      if (map.isNotEmpty) {
        return Booking.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<Booking?> delete(Booking booking) async {
    final id = booking.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return Booking.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }

  static Booking? _fromIDorData(idOrData) {
    if (idOrData is String) {
      return Booking.fromID(idOrData);
    }
    if (idOrData is Map) {
      if ((idOrData.containsKey("createdAt") ||
              idOrData.containsKey("updatedAt")) &&
          (idOrData["createdAt"] == null || idOrData["updatedAt"] == null)) {
        final id = idOrData["id"];
        return Booking.fromID(id);
      }
      return Booking.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<Booking>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    final response = await Strapi.i
        .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
    if (response.body.isNotEmpty) {
      final object = response.body.first;
      if (object is Map && object.containsKey("data")) {
        final data = object["data"];
        if (data is Map && data.containsKey(query.collectionName)) {
          final myList = data[query.collectionName];
          if (myList is List) {
            final list = <Booking>[];
            myList.forEach((e) {
              final o = _fromIDorData(e);
              if (o is Booking) {
                list.add(o);
              }
            });
            return list;
          } else if (myList is Map && myList.containsKey("id")) {
            final o = _fromIDorData(myList);
            if (o is Booking) {
              return [o];
            }
          }
        }
      }
    }
    return [];
  }

  static Widget listenerWidget({
    Key? key,
    required Booking strapiObject,
    bool sync = false,
    required Widget Function(
      BuildContext,
      Booking,
      bool,
    )
        builder,
  }) {
    return _StrapiListenerWidget<Booking>(
      key: key,
      strapiObject: strapiObject,
      generator: Booking.fromMap,
      builder: builder,
      sync: sync,
    );
  }
}

class _BookingFields {
  _BookingFields._i();

  static final _BookingFields i = _BookingFields._i();

  final business = StrapiModelField("business");

  final bookedOn = StrapiLeafField("bookedOn");

  final bookingStartTime = StrapiLeafField("bookingStartTime");

  final bookingEndTime = StrapiLeafField("bookingEndTime");

  final bookingType = StrapiLeafField("bookingType");

  final packages = StrapiComponentField("packages");

  final products = StrapiComponentField("products");

  final employee = StrapiModelField("employee");

  final review = StrapiModelField("review");

  final bookingStatus = StrapiLeafField("bookingStatus");

  final bookedByUser = StrapiModelField("bookedByUser");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [
      business,
      bookedOn,
      bookingStartTime,
      bookingEndTime,
      bookingType,
      packages,
      products,
      employee,
      review,
      bookingStatus,
      bookedByUser,
      createdAt,
      updatedAt,
      id
    ];
  }
}

class _BookingEmptyFields {
  bool business = false;

  bool bookedOn = false;

  bool bookingStartTime = false;

  bool bookingEndTime = false;

  bool bookingType = false;

  bool packages = false;

  bool products = false;

  bool employee = false;

  bool review = false;

  bool bookingStatus = false;

  bool bookedByUser = false;
}

class Locality {
  Locality.fromID(this.id)
      : _synced = false,
        name = null,
        enabled = null,
        city = null,
        coordinates = null,
        createdAt = null,
        updatedAt = null;

  Locality.fresh({this.name, this.enabled, this.city, this.coordinates})
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  Locality._synced(this.name, this.enabled, this.city, this.coordinates,
      this.createdAt, this.updatedAt, this.id)
      : _synced = true;

  Locality._unsynced(this.name, this.enabled, this.city, this.coordinates,
      this.createdAt, this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final String? name;

  final bool? enabled;

  final City? city;

  final Coordinates? coordinates;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  static final collectionName = "localities";

  _LocalityEmptyFields _emptyFields = _LocalityEmptyFields();

  bool get synced => _synced;
  Locality copyWIth(
          {String? name,
          bool? enabled,
          City? city,
          Coordinates? coordinates}) =>
      Locality._unsynced(
          name ?? this.name,
          enabled ?? this.enabled,
          city ?? this.city,
          coordinates ?? this.coordinates,
          this.createdAt,
          this.updatedAt,
          this.id);
  Locality setNull(
      {bool name = false,
      bool enabled = false,
      bool city = false,
      bool coordinates = false}) {
    return Locality._unsynced(
        name ? null : this.name,
        enabled ? null : this.enabled,
        city ? null : this.city,
        coordinates ? null : this.coordinates,
        this.createdAt,
        this.updatedAt,
        this.id)
      .._emptyFields.name = name
      .._emptyFields.enabled = enabled
      .._emptyFields.city = city
      .._emptyFields.coordinates = coordinates;
  }

  static Locality fromSyncedMap(Map<dynamic, dynamic> map) => Locality._synced(
      map["name"],
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.objFromMap<City>(map["city"], (e) => Cities._fromIDorData(e)),
      StrapiUtils.objFromMap<Coordinates>(
          map["coordinates"], (e) => Coordinates.fromMap(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  static Locality? fromMap(Map<String, dynamic> map) => Locality._unsynced(
      map["name"],
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.objFromMap<City>(map["city"], (e) => Cities._fromIDorData(e)),
      StrapiUtils.objFromMap<Coordinates>(
          map["coordinates"], (e) => Coordinates.fromMap(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  Map<String, dynamic> toMap() => _toMap(level: -1);
  Map<String, dynamic> _toMap({int level = 0}) {
    final toServer = level == 0;
    return {
      if (_emptyFields.name)
        "name": null
      else if (!_emptyFields.name && name != null)
        "name": name,
      if (_emptyFields.enabled)
        "enabled": null
      else if (!_emptyFields.enabled && enabled != null)
        "enabled": enabled,
      if (_emptyFields.city)
        "city": null
      else if (!_emptyFields.city && city != null)
        "city": toServer ? city?.id : city?._toMap(level: level + level),
      if (_emptyFields.coordinates)
        "coordinates": null
      else if (!_emptyFields.coordinates && coordinates != null)
        "coordinates": coordinates?._toMap(level: level + level),
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "id": id
    };
  }

  Future<Locality> sync() async {
    if (!synced) {
      return this;
    }
    final _id = this.id;
    if (_id is! String) {
      return this;
    }
    final response = await Localities.findOne(_id);
    if (response is Locality) {
      return response;
    } else {
      return this;
    }
  }

  static _LocalityFields get fields => _LocalityFields.i;
  @override
  String toString() =>
      "[Strapi Collection Type Locality]\n" + _toMap().toString();
}

class Localities {
  static const collectionName = "localities";

  static List<Locality?> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => Locality.fromID(id)).toList();
  }

  static Future<Locality?> findOne(
    String id,
  ) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return Locality.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<Locality>> findMultiple({int limit = 16}) async {
    final list = await StrapiCollection.findMultiple(
      collection: collectionName,
      limit: limit,
    );
    if (list.isNotEmpty) {
      return list.map((map) => Locality.fromSyncedMap(map)).toList();
    }
    return [];
  }

  static Future<Locality?> create(Locality locality) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: locality._toMap(level: 0),
    );
    if (map.isNotEmpty) {
      return Locality.fromSyncedMap(map);
    }
  }

  static Future<Locality?> update(Locality locality) async {
    final id = locality.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: locality._toMap(level: 0),
      );
      if (map.isNotEmpty) {
        return Locality.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<Locality?> delete(Locality locality) async {
    final id = locality.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return Locality.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }

  static Locality? _fromIDorData(idOrData) {
    if (idOrData is String) {
      return Locality.fromID(idOrData);
    }
    if (idOrData is Map) {
      if ((idOrData.containsKey("createdAt") ||
              idOrData.containsKey("updatedAt")) &&
          (idOrData["createdAt"] == null || idOrData["updatedAt"] == null)) {
        final id = idOrData["id"];
        return Locality.fromID(id);
      }
      return Locality.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<Locality>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    final response = await Strapi.i
        .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
    if (response.body.isNotEmpty) {
      final object = response.body.first;
      if (object is Map && object.containsKey("data")) {
        final data = object["data"];
        if (data is Map && data.containsKey(query.collectionName)) {
          final myList = data[query.collectionName];
          if (myList is List) {
            final list = <Locality>[];
            myList.forEach((e) {
              final o = _fromIDorData(e);
              if (o is Locality) {
                list.add(o);
              }
            });
            return list;
          } else if (myList is Map && myList.containsKey("id")) {
            final o = _fromIDorData(myList);
            if (o is Locality) {
              return [o];
            }
          }
        }
      }
    }
    return [];
  }

  static Widget listenerWidget({
    Key? key,
    required Locality strapiObject,
    bool sync = false,
    required Widget Function(
      BuildContext,
      Locality,
      bool,
    )
        builder,
  }) {
    return _StrapiListenerWidget<Locality>(
      key: key,
      strapiObject: strapiObject,
      generator: Locality.fromMap,
      builder: builder,
      sync: sync,
    );
  }
}

class _LocalityFields {
  _LocalityFields._i();

  static final _LocalityFields i = _LocalityFields._i();

  final name = StrapiLeafField("name");

  final enabled = StrapiLeafField("enabled");

  final city = StrapiModelField("city");

  final coordinates = StrapiComponentField("coordinates");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [name, enabled, city, coordinates, createdAt, updatedAt, id];
  }
}

class _LocalityEmptyFields {
  bool name = false;

  bool enabled = false;

  bool city = false;

  bool coordinates = false;
}

class PushNotification {
  PushNotification.fromID(this.id)
      : _synced = false,
        data = null,
        pushed_on = null,
        user = null,
        createdAt = null,
        updatedAt = null;

  PushNotification.fresh({this.data, this.pushed_on, this.user})
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  PushNotification._synced(this.data, this.pushed_on, this.user, this.createdAt,
      this.updatedAt, this.id)
      : _synced = true;

  PushNotification._unsynced(this.data, this.pushed_on, this.user,
      this.createdAt, this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final String? data;

  final DateTime? pushed_on;

  final User? user;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  static final collectionName = "push-notifications";

  _PushNotificationEmptyFields _emptyFields = _PushNotificationEmptyFields();

  bool get synced => _synced;
  PushNotification copyWIth({String? data, DateTime? pushed_on, User? user}) =>
      PushNotification._unsynced(data ?? this.data, pushed_on ?? this.pushed_on,
          user ?? this.user, this.createdAt, this.updatedAt, this.id);
  PushNotification setNull(
      {bool data = false, bool pushed_on = false, bool user = false}) {
    return PushNotification._unsynced(
        data ? null : this.data,
        pushed_on ? null : this.pushed_on,
        user ? null : this.user,
        this.createdAt,
        this.updatedAt,
        this.id)
      .._emptyFields.data = data
      .._emptyFields.pushed_on = pushed_on
      .._emptyFields.user = user;
  }

  static PushNotification fromSyncedMap(Map<dynamic, dynamic> map) =>
      PushNotification._synced(
          map["data"],
          StrapiUtils.parseDateTime(map["pushed_on"]),
          StrapiUtils.objFromMap<User>(
              map["user"], (e) => Users._fromIDorData(e)),
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["id"]);
  static PushNotification? fromMap(Map<String, dynamic> map) =>
      PushNotification._unsynced(
          map["data"],
          StrapiUtils.parseDateTime(map["pushed_on"]),
          StrapiUtils.objFromMap<User>(
              map["user"], (e) => Users._fromIDorData(e)),
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["id"]);
  Map<String, dynamic> toMap() => _toMap(level: -1);
  Map<String, dynamic> _toMap({int level = 0}) {
    final toServer = level == 0;
    return {
      if (_emptyFields.data)
        "data": null
      else if (!_emptyFields.data && data != null)
        "data": data,
      if (_emptyFields.pushed_on)
        "pushed_on": null
      else if (!_emptyFields.pushed_on && pushed_on != null)
        "pushed_on": pushed_on?.toIso8601String(),
      if (_emptyFields.user)
        "user": null
      else if (!_emptyFields.user && user != null)
        "user": toServer ? user?.id : user?._toMap(level: level + level),
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "id": id
    };
  }

  Future<PushNotification> sync() async {
    if (!synced) {
      return this;
    }
    final _id = this.id;
    if (_id is! String) {
      return this;
    }
    final response = await PushNotifications.findOne(_id);
    if (response is PushNotification) {
      return response;
    } else {
      return this;
    }
  }

  static _PushNotificationFields get fields => _PushNotificationFields.i;
  @override
  String toString() =>
      "[Strapi Collection Type PushNotification]\n" + _toMap().toString();
}

class PushNotifications {
  static const collectionName = "push-notifications";

  static List<PushNotification?> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => PushNotification.fromID(id)).toList();
  }

  static Future<PushNotification?> findOne(
    String id,
  ) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return PushNotification.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<PushNotification>> findMultiple({int limit = 16}) async {
    final list = await StrapiCollection.findMultiple(
      collection: collectionName,
      limit: limit,
    );
    if (list.isNotEmpty) {
      return list.map((map) => PushNotification.fromSyncedMap(map)).toList();
    }
    return [];
  }

  static Future<PushNotification?> create(
      PushNotification pushNotification) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: pushNotification._toMap(level: 0),
    );
    if (map.isNotEmpty) {
      return PushNotification.fromSyncedMap(map);
    }
  }

  static Future<PushNotification?> update(
      PushNotification pushNotification) async {
    final id = pushNotification.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: pushNotification._toMap(level: 0),
      );
      if (map.isNotEmpty) {
        return PushNotification.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<PushNotification?> delete(
      PushNotification pushNotification) async {
    final id = pushNotification.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return PushNotification.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }

  static PushNotification? _fromIDorData(idOrData) {
    if (idOrData is String) {
      return PushNotification.fromID(idOrData);
    }
    if (idOrData is Map) {
      if ((idOrData.containsKey("createdAt") ||
              idOrData.containsKey("updatedAt")) &&
          (idOrData["createdAt"] == null || idOrData["updatedAt"] == null)) {
        final id = idOrData["id"];
        return PushNotification.fromID(id);
      }
      return PushNotification.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<PushNotification>> executeQuery(
      StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    final response = await Strapi.i
        .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
    if (response.body.isNotEmpty) {
      final object = response.body.first;
      if (object is Map && object.containsKey("data")) {
        final data = object["data"];
        if (data is Map && data.containsKey(query.collectionName)) {
          final myList = data[query.collectionName];
          if (myList is List) {
            final list = <PushNotification>[];
            myList.forEach((e) {
              final o = _fromIDorData(e);
              if (o is PushNotification) {
                list.add(o);
              }
            });
            return list;
          } else if (myList is Map && myList.containsKey("id")) {
            final o = _fromIDorData(myList);
            if (o is PushNotification) {
              return [o];
            }
          }
        }
      }
    }
    return [];
  }

  static Widget listenerWidget({
    Key? key,
    required PushNotification strapiObject,
    bool sync = false,
    required Widget Function(
      BuildContext,
      PushNotification,
      bool,
    )
        builder,
  }) {
    return _StrapiListenerWidget<PushNotification>(
      key: key,
      strapiObject: strapiObject,
      generator: PushNotification.fromMap,
      builder: builder,
      sync: sync,
    );
  }
}

class _PushNotificationFields {
  _PushNotificationFields._i();

  static final _PushNotificationFields i = _PushNotificationFields._i();

  final data = StrapiLeafField("data");

  final pushed_on = StrapiLeafField("pushed_on");

  final user = StrapiModelField("user");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [data, pushed_on, user, createdAt, updatedAt, id];
  }
}

class _PushNotificationEmptyFields {
  bool data = false;

  bool pushed_on = false;

  bool user = false;
}

class Country {
  Country.fromID(this.id)
      : _synced = false,
        name = null,
        iso2Code = null,
        englishCurrencySymbol = null,
        flagUrl = null,
        enabled = null,
        localCurrencySymbol = null,
        localName = null,
        cities = null,
        createdAt = null,
        updatedAt = null;

  Country.fresh(
      {this.name,
      this.iso2Code,
      this.englishCurrencySymbol,
      this.flagUrl,
      this.enabled,
      this.localCurrencySymbol,
      this.localName,
      this.cities})
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  Country._synced(
      this.name,
      this.iso2Code,
      this.englishCurrencySymbol,
      this.flagUrl,
      this.enabled,
      this.localCurrencySymbol,
      this.localName,
      this.cities,
      this.createdAt,
      this.updatedAt,
      this.id)
      : _synced = true;

  Country._unsynced(
      this.name,
      this.iso2Code,
      this.englishCurrencySymbol,
      this.flagUrl,
      this.enabled,
      this.localCurrencySymbol,
      this.localName,
      this.cities,
      this.createdAt,
      this.updatedAt,
      this.id)
      : _synced = false;

  final bool _synced;

  final String? name;

  final String? iso2Code;

  final String? englishCurrencySymbol;

  final String? flagUrl;

  final bool? enabled;

  final String? localCurrencySymbol;

  final String? localName;

  final List<City>? cities;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  static final collectionName = "countries";

  _CountryEmptyFields _emptyFields = _CountryEmptyFields();

  bool get synced => _synced;
  Country copyWIth(
          {String? name,
          String? iso2Code,
          String? englishCurrencySymbol,
          String? flagUrl,
          bool? enabled,
          String? localCurrencySymbol,
          String? localName,
          List<City>? cities}) =>
      Country._unsynced(
          name ?? this.name,
          iso2Code ?? this.iso2Code,
          englishCurrencySymbol ?? this.englishCurrencySymbol,
          flagUrl ?? this.flagUrl,
          enabled ?? this.enabled,
          localCurrencySymbol ?? this.localCurrencySymbol,
          localName ?? this.localName,
          cities ?? this.cities,
          this.createdAt,
          this.updatedAt,
          this.id);
  Country setNull(
      {bool name = false,
      bool iso2Code = false,
      bool englishCurrencySymbol = false,
      bool flagUrl = false,
      bool enabled = false,
      bool localCurrencySymbol = false,
      bool localName = false,
      bool cities = false}) {
    return Country._unsynced(
        name ? null : this.name,
        iso2Code ? null : this.iso2Code,
        englishCurrencySymbol ? null : this.englishCurrencySymbol,
        flagUrl ? null : this.flagUrl,
        enabled ? null : this.enabled,
        localCurrencySymbol ? null : this.localCurrencySymbol,
        localName ? null : this.localName,
        cities ? null : this.cities,
        this.createdAt,
        this.updatedAt,
        this.id)
      .._emptyFields.name = name
      .._emptyFields.iso2Code = iso2Code
      .._emptyFields.englishCurrencySymbol = englishCurrencySymbol
      .._emptyFields.flagUrl = flagUrl
      .._emptyFields.enabled = enabled
      .._emptyFields.localCurrencySymbol = localCurrencySymbol
      .._emptyFields.localName = localName
      .._emptyFields.cities = cities;
  }

  static Country fromSyncedMap(Map<dynamic, dynamic> map) => Country._synced(
      map["name"],
      map["iso2Code"],
      map["englishCurrencySymbol"],
      map["flagUrl"],
      StrapiUtils.parseBool(map["enabled"]),
      map["localCurrencySymbol"],
      map["localName"],
      StrapiUtils.objFromListOfMap<City>(
          map["cities"], (e) => Cities._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  static Country? fromMap(Map<String, dynamic> map) => Country._unsynced(
      map["name"],
      map["iso2Code"],
      map["englishCurrencySymbol"],
      map["flagUrl"],
      StrapiUtils.parseBool(map["enabled"]),
      map["localCurrencySymbol"],
      map["localName"],
      StrapiUtils.objFromListOfMap<City>(
          map["cities"], (e) => Cities._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  Map<String, dynamic> toMap() => _toMap(level: -1);
  Map<String, dynamic> _toMap({int level = 0}) {
    final toServer = level == 0;
    return {
      if (_emptyFields.name)
        "name": null
      else if (!_emptyFields.name && name != null)
        "name": name,
      if (_emptyFields.iso2Code)
        "iso2Code": null
      else if (!_emptyFields.iso2Code && iso2Code != null)
        "iso2Code": iso2Code,
      if (_emptyFields.englishCurrencySymbol)
        "englishCurrencySymbol": null
      else if (!_emptyFields.englishCurrencySymbol &&
          englishCurrencySymbol != null)
        "englishCurrencySymbol": englishCurrencySymbol,
      if (_emptyFields.flagUrl)
        "flagUrl": null
      else if (!_emptyFields.flagUrl && flagUrl != null)
        "flagUrl": flagUrl,
      if (_emptyFields.enabled)
        "enabled": null
      else if (!_emptyFields.enabled && enabled != null)
        "enabled": enabled,
      if (_emptyFields.localCurrencySymbol)
        "localCurrencySymbol": null
      else if (!_emptyFields.localCurrencySymbol && localCurrencySymbol != null)
        "localCurrencySymbol": localCurrencySymbol,
      if (_emptyFields.localName)
        "localName": null
      else if (!_emptyFields.localName && localName != null)
        "localName": localName,
      if (_emptyFields.cities)
        "cities": []
      else if (!_emptyFields.cities && cities != null)
        "cities": cities
            ?.map((e) => toServer ? e.id : e._toMap(level: level + level))
            .toList(),
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "id": id
    };
  }

  Future<Country> sync() async {
    if (!synced) {
      return this;
    }
    final _id = this.id;
    if (_id is! String) {
      return this;
    }
    final response = await Countries.findOne(_id);
    if (response is Country) {
      return response;
    } else {
      return this;
    }
  }

  static _CountryFields get fields => _CountryFields.i;
  @override
  String toString() =>
      "[Strapi Collection Type Country]\n" + _toMap().toString();
}

class Countries {
  static const collectionName = "countries";

  static List<Country?> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => Country.fromID(id)).toList();
  }

  static Future<Country?> findOne(
    String id,
  ) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return Country.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<Country>> findMultiple({int limit = 16}) async {
    final list = await StrapiCollection.findMultiple(
      collection: collectionName,
      limit: limit,
    );
    if (list.isNotEmpty) {
      return list.map((map) => Country.fromSyncedMap(map)).toList();
    }
    return [];
  }

  static Future<Country?> create(Country country) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: country._toMap(level: 0),
    );
    if (map.isNotEmpty) {
      return Country.fromSyncedMap(map);
    }
  }

  static Future<Country?> update(Country country) async {
    final id = country.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: country._toMap(level: 0),
      );
      if (map.isNotEmpty) {
        return Country.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<Country?> delete(Country country) async {
    final id = country.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return Country.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }

  static Country? _fromIDorData(idOrData) {
    if (idOrData is String) {
      return Country.fromID(idOrData);
    }
    if (idOrData is Map) {
      if ((idOrData.containsKey("createdAt") ||
              idOrData.containsKey("updatedAt")) &&
          (idOrData["createdAt"] == null || idOrData["updatedAt"] == null)) {
        final id = idOrData["id"];
        return Country.fromID(id);
      }
      return Country.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<Country>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    final response = await Strapi.i
        .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
    if (response.body.isNotEmpty) {
      final object = response.body.first;
      if (object is Map && object.containsKey("data")) {
        final data = object["data"];
        if (data is Map && data.containsKey(query.collectionName)) {
          final myList = data[query.collectionName];
          if (myList is List) {
            final list = <Country>[];
            myList.forEach((e) {
              final o = _fromIDorData(e);
              if (o is Country) {
                list.add(o);
              }
            });
            return list;
          } else if (myList is Map && myList.containsKey("id")) {
            final o = _fromIDorData(myList);
            if (o is Country) {
              return [o];
            }
          }
        }
      }
    }
    return [];
  }

  static Widget listenerWidget({
    Key? key,
    required Country strapiObject,
    bool sync = false,
    required Widget Function(
      BuildContext,
      Country,
      bool,
    )
        builder,
  }) {
    return _StrapiListenerWidget<Country>(
      key: key,
      strapiObject: strapiObject,
      generator: Country.fromMap,
      builder: builder,
      sync: sync,
    );
  }
}

class _CountryFields {
  _CountryFields._i();

  static final _CountryFields i = _CountryFields._i();

  final name = StrapiLeafField("name");

  final iso2Code = StrapiLeafField("iso2Code");

  final englishCurrencySymbol = StrapiLeafField("englishCurrencySymbol");

  final flagUrl = StrapiLeafField("flagUrl");

  final enabled = StrapiLeafField("enabled");

  final localCurrencySymbol = StrapiLeafField("localCurrencySymbol");

  final localName = StrapiLeafField("localName");

  final cities = StrapiCollectionField("cities");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [
      name,
      iso2Code,
      englishCurrencySymbol,
      flagUrl,
      enabled,
      localCurrencySymbol,
      localName,
      cities,
      createdAt,
      updatedAt,
      id
    ];
  }
}

class _CountryEmptyFields {
  bool name = false;

  bool iso2Code = false;

  bool englishCurrencySymbol = false;

  bool flagUrl = false;

  bool enabled = false;

  bool localCurrencySymbol = false;

  bool localName = false;

  bool cities = false;
}

class Business {
  Business.fromID(this.id)
      : _synced = false,
        name = null,
        address = null,
        enabled = null,
        partner = null,
        packages = null,
        businessFeatures = null,
        business_category = null,
        starRating = null,
        contactNumber = null,
        email = null,
        about = null,
        catalogue = null,
        dayTiming = null,
        holidays = null,
        employees = null,
        createdAt = null,
        updatedAt = null;

  Business.fresh(
      {this.name,
      this.address,
      this.enabled,
      this.partner,
      this.packages,
      this.businessFeatures,
      this.business_category,
      this.starRating,
      this.contactNumber,
      this.email,
      this.about,
      this.catalogue,
      this.dayTiming,
      this.holidays,
      this.employees})
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  Business._synced(
      this.name,
      this.address,
      this.enabled,
      this.partner,
      this.packages,
      this.businessFeatures,
      this.business_category,
      this.starRating,
      this.contactNumber,
      this.email,
      this.about,
      this.catalogue,
      this.dayTiming,
      this.holidays,
      this.employees,
      this.createdAt,
      this.updatedAt,
      this.id)
      : _synced = true;

  Business._unsynced(
      this.name,
      this.address,
      this.enabled,
      this.partner,
      this.packages,
      this.businessFeatures,
      this.business_category,
      this.starRating,
      this.contactNumber,
      this.email,
      this.about,
      this.catalogue,
      this.dayTiming,
      this.holidays,
      this.employees,
      this.createdAt,
      this.updatedAt,
      this.id)
      : _synced = false;

  final bool _synced;

  final String? name;

  final Address? address;

  final bool? enabled;

  final Partner? partner;

  final List<Package>? packages;

  final List<BusinessFeature>? businessFeatures;

  final BusinessCategory? business_category;

  final double? starRating;

  final String? contactNumber;

  final String? email;

  final String? about;

  final List<ProductCategory>? catalogue;

  final List<DayTiming>? dayTiming;

  final List<Holiday>? holidays;

  final List<Employee>? employees;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  static final collectionName = "businesses";

  _BusinessEmptyFields _emptyFields = _BusinessEmptyFields();

  bool get synced => _synced;
  Business copyWIth(
          {String? name,
          Address? address,
          bool? enabled,
          Partner? partner,
          List<Package>? packages,
          List<BusinessFeature>? businessFeatures,
          BusinessCategory? business_category,
          double? starRating,
          String? contactNumber,
          String? email,
          String? about,
          List<ProductCategory>? catalogue,
          List<DayTiming>? dayTiming,
          List<Holiday>? holidays,
          List<Employee>? employees}) =>
      Business._unsynced(
          name ?? this.name,
          address ?? this.address,
          enabled ?? this.enabled,
          partner ?? this.partner,
          packages ?? this.packages,
          businessFeatures ?? this.businessFeatures,
          business_category ?? this.business_category,
          starRating ?? this.starRating,
          contactNumber ?? this.contactNumber,
          email ?? this.email,
          about ?? this.about,
          catalogue ?? this.catalogue,
          dayTiming ?? this.dayTiming,
          holidays ?? this.holidays,
          employees ?? this.employees,
          this.createdAt,
          this.updatedAt,
          this.id);
  Business setNull(
      {bool name = false,
      bool address = false,
      bool enabled = false,
      bool partner = false,
      bool packages = false,
      bool businessFeatures = false,
      bool business_category = false,
      bool starRating = false,
      bool contactNumber = false,
      bool email = false,
      bool about = false,
      bool catalogue = false,
      bool dayTiming = false,
      bool holidays = false,
      bool employees = false}) {
    return Business._unsynced(
        name ? null : this.name,
        address ? null : this.address,
        enabled ? null : this.enabled,
        partner ? null : this.partner,
        packages ? null : this.packages,
        businessFeatures ? null : this.businessFeatures,
        business_category ? null : this.business_category,
        starRating ? null : this.starRating,
        contactNumber ? null : this.contactNumber,
        email ? null : this.email,
        about ? null : this.about,
        catalogue ? null : this.catalogue,
        dayTiming ? null : this.dayTiming,
        holidays ? null : this.holidays,
        employees ? null : this.employees,
        this.createdAt,
        this.updatedAt,
        this.id)
      .._emptyFields.name = name
      .._emptyFields.address = address
      .._emptyFields.enabled = enabled
      .._emptyFields.partner = partner
      .._emptyFields.packages = packages
      .._emptyFields.businessFeatures = businessFeatures
      .._emptyFields.business_category = business_category
      .._emptyFields.starRating = starRating
      .._emptyFields.contactNumber = contactNumber
      .._emptyFields.email = email
      .._emptyFields.about = about
      .._emptyFields.catalogue = catalogue
      .._emptyFields.dayTiming = dayTiming
      .._emptyFields.holidays = holidays
      .._emptyFields.employees = employees;
  }

  static Business fromSyncedMap(Map<dynamic, dynamic> map) => Business._synced(
      map["name"],
      StrapiUtils.objFromMap<Address>(
          map["address"], (e) => Address.fromMap(e)),
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.objFromMap<Partner>(
          map["partner"], (e) => Partners._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Package>(
          map["packages"], (e) => Package.fromMap(e)),
      StrapiUtils.objFromListOfMap<BusinessFeature>(
          map["businessFeatures"], (e) => BusinessFeatures._fromIDorData(e)),
      StrapiUtils.objFromMap<BusinessCategory>(
          map["business_category"], (e) => BusinessCategories._fromIDorData(e)),
      StrapiUtils.parseDouble(map["starRating"]),
      map["contactNumber"],
      map["email"],
      map["about"],
      StrapiUtils.objFromListOfMap<ProductCategory>(
          map["catalogue"], (e) => ProductCategory.fromMap(e)),
      StrapiUtils.objFromListOfMap<DayTiming>(
          map["dayTiming"], (e) => DayTiming.fromMap(e)),
      StrapiUtils.objFromListOfMap<Holiday>(
          map["holidays"], (e) => Holiday.fromMap(e)),
      StrapiUtils.objFromListOfMap<Employee>(
          map["employees"], (e) => Employees._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  static Business? fromMap(Map<String, dynamic> map) => Business._unsynced(
      map["name"],
      StrapiUtils.objFromMap<Address>(
          map["address"], (e) => Address.fromMap(e)),
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.objFromMap<Partner>(
          map["partner"], (e) => Partners._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Package>(
          map["packages"], (e) => Package.fromMap(e)),
      StrapiUtils.objFromListOfMap<BusinessFeature>(
          map["businessFeatures"], (e) => BusinessFeatures._fromIDorData(e)),
      StrapiUtils.objFromMap<BusinessCategory>(
          map["business_category"], (e) => BusinessCategories._fromIDorData(e)),
      StrapiUtils.parseDouble(map["starRating"]),
      map["contactNumber"],
      map["email"],
      map["about"],
      StrapiUtils.objFromListOfMap<ProductCategory>(
          map["catalogue"], (e) => ProductCategory.fromMap(e)),
      StrapiUtils.objFromListOfMap<DayTiming>(
          map["dayTiming"], (e) => DayTiming.fromMap(e)),
      StrapiUtils.objFromListOfMap<Holiday>(
          map["holidays"], (e) => Holiday.fromMap(e)),
      StrapiUtils.objFromListOfMap<Employee>(
          map["employees"], (e) => Employees._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  Map<String, dynamic> toMap() => _toMap(level: -1);
  Map<String, dynamic> _toMap({int level = 0}) {
    final toServer = level == 0;
    return {
      if (_emptyFields.name)
        "name": null
      else if (!_emptyFields.name && name != null)
        "name": name,
      if (_emptyFields.address)
        "address": null
      else if (!_emptyFields.address && address != null)
        "address": address?._toMap(level: level + level),
      if (_emptyFields.enabled)
        "enabled": null
      else if (!_emptyFields.enabled && enabled != null)
        "enabled": enabled,
      if (_emptyFields.partner)
        "partner": null
      else if (!_emptyFields.partner && partner != null)
        "partner":
            toServer ? partner?.id : partner?._toMap(level: level + level),
      if (_emptyFields.packages)
        "packages": []
      else if (!_emptyFields.packages && packages != null)
        "packages":
            packages?.map((e) => e._toMap(level: level + level)).toList(),
      if (_emptyFields.businessFeatures)
        "businessFeatures": []
      else if (!_emptyFields.businessFeatures && businessFeatures != null)
        "businessFeatures": businessFeatures
            ?.map((e) => toServer ? e.id : e._toMap(level: level + level))
            .toList(),
      if (_emptyFields.business_category)
        "business_category": null
      else if (!_emptyFields.business_category && business_category != null)
        "business_category": toServer
            ? business_category?.id
            : business_category?._toMap(level: level + level),
      if (_emptyFields.starRating)
        "starRating": null
      else if (!_emptyFields.starRating && starRating != null)
        "starRating": starRating,
      if (_emptyFields.contactNumber)
        "contactNumber": null
      else if (!_emptyFields.contactNumber && contactNumber != null)
        "contactNumber": contactNumber,
      if (_emptyFields.email)
        "email": null
      else if (!_emptyFields.email && email != null)
        "email": email,
      if (_emptyFields.about)
        "about": null
      else if (!_emptyFields.about && about != null)
        "about": about,
      if (_emptyFields.catalogue)
        "catalogue": []
      else if (!_emptyFields.catalogue && catalogue != null)
        "catalogue":
            catalogue?.map((e) => e._toMap(level: level + level)).toList(),
      if (_emptyFields.dayTiming)
        "dayTiming": []
      else if (!_emptyFields.dayTiming && dayTiming != null)
        "dayTiming":
            dayTiming?.map((e) => e._toMap(level: level + level)).toList(),
      if (_emptyFields.holidays)
        "holidays": []
      else if (!_emptyFields.holidays && holidays != null)
        "holidays":
            holidays?.map((e) => e._toMap(level: level + level)).toList(),
      if (_emptyFields.employees)
        "employees": []
      else if (!_emptyFields.employees && employees != null)
        "employees": employees
            ?.map((e) => toServer ? e.id : e._toMap(level: level + level))
            .toList(),
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "id": id
    };
  }

  Future<Business> sync() async {
    if (!synced) {
      return this;
    }
    final _id = this.id;
    if (_id is! String) {
      return this;
    }
    final response = await Businesses.findOne(_id);
    if (response is Business) {
      return response;
    } else {
      return this;
    }
  }

  static _BusinessFields get fields => _BusinessFields.i;
  @override
  String toString() =>
      "[Strapi Collection Type Business]\n" + _toMap().toString();
}

class Businesses {
  static const collectionName = "businesses";

  static List<Business?> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => Business.fromID(id)).toList();
  }

  static Future<Business?> findOne(
    String id,
  ) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return Business.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<Business>> findMultiple({int limit = 16}) async {
    final list = await StrapiCollection.findMultiple(
      collection: collectionName,
      limit: limit,
    );
    if (list.isNotEmpty) {
      return list.map((map) => Business.fromSyncedMap(map)).toList();
    }
    return [];
  }

  static Future<Business?> create(Business business) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: business._toMap(level: 0),
    );
    if (map.isNotEmpty) {
      return Business.fromSyncedMap(map);
    }
  }

  static Future<Business?> update(Business business) async {
    final id = business.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: business._toMap(level: 0),
      );
      if (map.isNotEmpty) {
        return Business.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<Business?> delete(Business business) async {
    final id = business.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return Business.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }

  static Business? _fromIDorData(idOrData) {
    if (idOrData is String) {
      return Business.fromID(idOrData);
    }
    if (idOrData is Map) {
      if ((idOrData.containsKey("createdAt") ||
              idOrData.containsKey("updatedAt")) &&
          (idOrData["createdAt"] == null || idOrData["updatedAt"] == null)) {
        final id = idOrData["id"];
        return Business.fromID(id);
      }
      return Business.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<Business>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    final response = await Strapi.i
        .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
    if (response.body.isNotEmpty) {
      final object = response.body.first;
      if (object is Map && object.containsKey("data")) {
        final data = object["data"];
        if (data is Map && data.containsKey(query.collectionName)) {
          final myList = data[query.collectionName];
          if (myList is List) {
            final list = <Business>[];
            myList.forEach((e) {
              final o = _fromIDorData(e);
              if (o is Business) {
                list.add(o);
              }
            });
            return list;
          } else if (myList is Map && myList.containsKey("id")) {
            final o = _fromIDorData(myList);
            if (o is Business) {
              return [o];
            }
          }
        }
      }
    }
    return [];
  }

  static Widget listenerWidget({
    Key? key,
    required Business strapiObject,
    bool sync = false,
    required Widget Function(
      BuildContext,
      Business,
      bool,
    )
        builder,
  }) {
    return _StrapiListenerWidget<Business>(
      key: key,
      strapiObject: strapiObject,
      generator: Business.fromMap,
      builder: builder,
      sync: sync,
    );
  }
}

class _BusinessFields {
  _BusinessFields._i();

  static final _BusinessFields i = _BusinessFields._i();

  final name = StrapiLeafField("name");

  final address = StrapiComponentField("address");

  final enabled = StrapiLeafField("enabled");

  final partner = StrapiModelField("partner");

  final packages = StrapiComponentField("packages");

  final businessFeatures = StrapiCollectionField("businessFeatures");

  final business_category = StrapiModelField("business_category");

  final starRating = StrapiLeafField("starRating");

  final contactNumber = StrapiLeafField("contactNumber");

  final email = StrapiLeafField("email");

  final about = StrapiLeafField("about");

  final catalogue = StrapiComponentField("catalogue");

  final dayTiming = StrapiComponentField("dayTiming");

  final holidays = StrapiComponentField("holidays");

  final employees = StrapiCollectionField("employees");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [
      name,
      address,
      enabled,
      partner,
      packages,
      businessFeatures,
      business_category,
      starRating,
      contactNumber,
      email,
      about,
      catalogue,
      dayTiming,
      holidays,
      employees,
      createdAt,
      updatedAt,
      id
    ];
  }
}

class _BusinessEmptyFields {
  bool name = false;

  bool address = false;

  bool enabled = false;

  bool partner = false;

  bool packages = false;

  bool businessFeatures = false;

  bool business_category = false;

  bool starRating = false;

  bool contactNumber = false;

  bool email = false;

  bool about = false;

  bool catalogue = false;

  bool dayTiming = false;

  bool holidays = false;

  bool employees = false;
}

class BusinessCategory {
  BusinessCategory.fromID(this.id)
      : _synced = false,
        name = null,
        businesses = null,
        image = null,
        createdAt = null,
        updatedAt = null;

  BusinessCategory.fresh({this.name, this.businesses, this.image})
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  BusinessCategory._synced(this.name, this.businesses, this.image,
      this.createdAt, this.updatedAt, this.id)
      : _synced = true;

  BusinessCategory._unsynced(this.name, this.businesses, this.image,
      this.createdAt, this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final String? name;

  final List<Business>? businesses;

  final StrapiFile? image;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  static final collectionName = "business-categories";

  _BusinessCategoryEmptyFields _emptyFields = _BusinessCategoryEmptyFields();

  bool get synced => _synced;
  BusinessCategory copyWIth(
          {String? name, List<Business>? businesses, StrapiFile? image}) =>
      BusinessCategory._unsynced(
          name ?? this.name,
          businesses ?? this.businesses,
          image ?? this.image,
          this.createdAt,
          this.updatedAt,
          this.id);
  BusinessCategory setNull(
      {bool name = false, bool businesses = false, bool image = false}) {
    return BusinessCategory._unsynced(
        name ? null : this.name,
        businesses ? null : this.businesses,
        image ? null : this.image,
        this.createdAt,
        this.updatedAt,
        this.id)
      .._emptyFields.name = name
      .._emptyFields.businesses = businesses
      .._emptyFields.image = image;
  }

  static BusinessCategory fromSyncedMap(Map<dynamic, dynamic> map) =>
      BusinessCategory._synced(
          map["name"],
          StrapiUtils.objFromListOfMap<Business>(
              map["businesses"], (e) => Businesses._fromIDorData(e)),
          StrapiUtils.objFromMap<StrapiFile>(
              map["image"], (e) => StrapiFiles._fromIDorData(e)),
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["id"]);
  static BusinessCategory? fromMap(Map<String, dynamic> map) =>
      BusinessCategory._unsynced(
          map["name"],
          StrapiUtils.objFromListOfMap<Business>(
              map["businesses"], (e) => Businesses._fromIDorData(e)),
          StrapiUtils.objFromMap<StrapiFile>(
              map["image"], (e) => StrapiFiles._fromIDorData(e)),
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["id"]);
  Map<String, dynamic> toMap() => _toMap(level: -1);
  Map<String, dynamic> _toMap({int level = 0}) {
    final toServer = level == 0;
    return {
      if (_emptyFields.name)
        "name": null
      else if (!_emptyFields.name && name != null)
        "name": name,
      if (_emptyFields.businesses)
        "businesses": []
      else if (!_emptyFields.businesses && businesses != null)
        "businesses": businesses
            ?.map((e) => toServer ? e.id : e._toMap(level: level + level))
            .toList(),
      if (_emptyFields.image)
        "image": null
      else if (!_emptyFields.image && image != null)
        "image": toServer ? image?.id : image?._toMap(level: level + level),
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "id": id
    };
  }

  Future<BusinessCategory> sync() async {
    if (!synced) {
      return this;
    }
    final _id = this.id;
    if (_id is! String) {
      return this;
    }
    final response = await BusinessCategories.findOne(_id);
    if (response is BusinessCategory) {
      return response;
    } else {
      return this;
    }
  }

  static _BusinessCategoryFields get fields => _BusinessCategoryFields.i;
  @override
  String toString() =>
      "[Strapi Collection Type BusinessCategory]\n" + _toMap().toString();
}

class BusinessCategories {
  static const collectionName = "business-categories";

  static List<BusinessCategory?> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => BusinessCategory.fromID(id)).toList();
  }

  static Future<BusinessCategory?> findOne(
    String id,
  ) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return BusinessCategory.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<BusinessCategory>> findMultiple({int limit = 16}) async {
    final list = await StrapiCollection.findMultiple(
      collection: collectionName,
      limit: limit,
    );
    if (list.isNotEmpty) {
      return list.map((map) => BusinessCategory.fromSyncedMap(map)).toList();
    }
    return [];
  }

  static Future<BusinessCategory?> create(
      BusinessCategory businessCategory) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: businessCategory._toMap(level: 0),
    );
    if (map.isNotEmpty) {
      return BusinessCategory.fromSyncedMap(map);
    }
  }

  static Future<BusinessCategory?> update(
      BusinessCategory businessCategory) async {
    final id = businessCategory.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: businessCategory._toMap(level: 0),
      );
      if (map.isNotEmpty) {
        return BusinessCategory.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<BusinessCategory?> delete(
      BusinessCategory businessCategory) async {
    final id = businessCategory.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return BusinessCategory.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }

  static BusinessCategory? _fromIDorData(idOrData) {
    if (idOrData is String) {
      return BusinessCategory.fromID(idOrData);
    }
    if (idOrData is Map) {
      if ((idOrData.containsKey("createdAt") ||
              idOrData.containsKey("updatedAt")) &&
          (idOrData["createdAt"] == null || idOrData["updatedAt"] == null)) {
        final id = idOrData["id"];
        return BusinessCategory.fromID(id);
      }
      return BusinessCategory.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<BusinessCategory>> executeQuery(
      StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    final response = await Strapi.i
        .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
    if (response.body.isNotEmpty) {
      final object = response.body.first;
      if (object is Map && object.containsKey("data")) {
        final data = object["data"];
        if (data is Map && data.containsKey(query.collectionName)) {
          final myList = data[query.collectionName];
          if (myList is List) {
            final list = <BusinessCategory>[];
            myList.forEach((e) {
              final o = _fromIDorData(e);
              if (o is BusinessCategory) {
                list.add(o);
              }
            });
            return list;
          } else if (myList is Map && myList.containsKey("id")) {
            final o = _fromIDorData(myList);
            if (o is BusinessCategory) {
              return [o];
            }
          }
        }
      }
    }
    return [];
  }

  static Widget listenerWidget({
    Key? key,
    required BusinessCategory strapiObject,
    bool sync = false,
    required Widget Function(
      BuildContext,
      BusinessCategory,
      bool,
    )
        builder,
  }) {
    return _StrapiListenerWidget<BusinessCategory>(
      key: key,
      strapiObject: strapiObject,
      generator: BusinessCategory.fromMap,
      builder: builder,
      sync: sync,
    );
  }
}

class _BusinessCategoryFields {
  _BusinessCategoryFields._i();

  static final _BusinessCategoryFields i = _BusinessCategoryFields._i();

  final name = StrapiLeafField("name");

  final businesses = StrapiCollectionField("businesses");

  final image = StrapiModelField("image");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [name, businesses, image, createdAt, updatedAt, id];
  }
}

class _BusinessCategoryEmptyFields {
  bool name = false;

  bool businesses = false;

  bool image = false;
}

class Partner {
  Partner.fromID(this.id)
      : _synced = false,
        name = null,
        enabled = null,
        logo = null,
        businesses = null,
        owner = null,
        about = null,
        createdAt = null,
        updatedAt = null;

  Partner.fresh(
      {this.name,
      this.enabled,
      this.logo,
      this.businesses,
      this.owner,
      this.about})
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  Partner._synced(this.name, this.enabled, this.logo, this.businesses,
      this.owner, this.about, this.createdAt, this.updatedAt, this.id)
      : _synced = true;

  Partner._unsynced(this.name, this.enabled, this.logo, this.businesses,
      this.owner, this.about, this.createdAt, this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final String? name;

  final bool? enabled;

  final List<StrapiFile>? logo;

  final List<Business>? businesses;

  final User? owner;

  final String? about;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  static final collectionName = "partners";

  _PartnerEmptyFields _emptyFields = _PartnerEmptyFields();

  bool get synced => _synced;
  Partner copyWIth(
          {String? name,
          bool? enabled,
          List<StrapiFile>? logo,
          List<Business>? businesses,
          User? owner,
          String? about}) =>
      Partner._unsynced(
          name ?? this.name,
          enabled ?? this.enabled,
          logo ?? this.logo,
          businesses ?? this.businesses,
          owner ?? this.owner,
          about ?? this.about,
          this.createdAt,
          this.updatedAt,
          this.id);
  Partner setNull(
      {bool name = false,
      bool enabled = false,
      bool logo = false,
      bool businesses = false,
      bool owner = false,
      bool about = false}) {
    return Partner._unsynced(
        name ? null : this.name,
        enabled ? null : this.enabled,
        logo ? null : this.logo,
        businesses ? null : this.businesses,
        owner ? null : this.owner,
        about ? null : this.about,
        this.createdAt,
        this.updatedAt,
        this.id)
      .._emptyFields.name = name
      .._emptyFields.enabled = enabled
      .._emptyFields.logo = logo
      .._emptyFields.businesses = businesses
      .._emptyFields.owner = owner
      .._emptyFields.about = about;
  }

  static Partner fromSyncedMap(Map<dynamic, dynamic> map) => Partner._synced(
      map["name"],
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.objFromListOfMap<StrapiFile>(
          map["logo"], (e) => StrapiFiles._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Business>(
          map["businesses"], (e) => Businesses._fromIDorData(e)),
      StrapiUtils.objFromMap<User>(map["owner"], (e) => Users._fromIDorData(e)),
      map["about"],
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  static Partner? fromMap(Map<String, dynamic> map) => Partner._unsynced(
      map["name"],
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.objFromListOfMap<StrapiFile>(
          map["logo"], (e) => StrapiFiles._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Business>(
          map["businesses"], (e) => Businesses._fromIDorData(e)),
      StrapiUtils.objFromMap<User>(map["owner"], (e) => Users._fromIDorData(e)),
      map["about"],
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  Map<String, dynamic> toMap() => _toMap(level: -1);
  Map<String, dynamic> _toMap({int level = 0}) {
    final toServer = level == 0;
    return {
      if (_emptyFields.name)
        "name": null
      else if (!_emptyFields.name && name != null)
        "name": name,
      if (_emptyFields.enabled)
        "enabled": null
      else if (!_emptyFields.enabled && enabled != null)
        "enabled": enabled,
      if (_emptyFields.logo)
        "logo": []
      else if (!_emptyFields.logo && logo != null)
        "logo": logo
            ?.map((e) => toServer ? e.id : e._toMap(level: level + level))
            .toList(),
      if (_emptyFields.businesses)
        "businesses": []
      else if (!_emptyFields.businesses && businesses != null)
        "businesses": businesses
            ?.map((e) => toServer ? e.id : e._toMap(level: level + level))
            .toList(),
      if (_emptyFields.owner)
        "owner": null
      else if (!_emptyFields.owner && owner != null)
        "owner": toServer ? owner?.id : owner?._toMap(level: level + level),
      if (_emptyFields.about)
        "about": null
      else if (!_emptyFields.about && about != null)
        "about": about,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "id": id
    };
  }

  Future<Partner> sync() async {
    if (!synced) {
      return this;
    }
    final _id = this.id;
    if (_id is! String) {
      return this;
    }
    final response = await Partners.findOne(_id);
    if (response is Partner) {
      return response;
    } else {
      return this;
    }
  }

  static _PartnerFields get fields => _PartnerFields.i;
  @override
  String toString() =>
      "[Strapi Collection Type Partner]\n" + _toMap().toString();
}

class Partners {
  static const collectionName = "partners";

  static List<Partner?> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => Partner.fromID(id)).toList();
  }

  static Future<Partner?> findOne(
    String id,
  ) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return Partner.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<Partner>> findMultiple({int limit = 16}) async {
    final list = await StrapiCollection.findMultiple(
      collection: collectionName,
      limit: limit,
    );
    if (list.isNotEmpty) {
      return list.map((map) => Partner.fromSyncedMap(map)).toList();
    }
    return [];
  }

  static Future<Partner?> create(Partner partner) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: partner._toMap(level: 0),
    );
    if (map.isNotEmpty) {
      return Partner.fromSyncedMap(map);
    }
  }

  static Future<Partner?> update(Partner partner) async {
    final id = partner.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: partner._toMap(level: 0),
      );
      if (map.isNotEmpty) {
        return Partner.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<Partner?> delete(Partner partner) async {
    final id = partner.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return Partner.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }

  static Partner? _fromIDorData(idOrData) {
    if (idOrData is String) {
      return Partner.fromID(idOrData);
    }
    if (idOrData is Map) {
      if ((idOrData.containsKey("createdAt") ||
              idOrData.containsKey("updatedAt")) &&
          (idOrData["createdAt"] == null || idOrData["updatedAt"] == null)) {
        final id = idOrData["id"];
        return Partner.fromID(id);
      }
      return Partner.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<Partner>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    final response = await Strapi.i
        .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
    if (response.body.isNotEmpty) {
      final object = response.body.first;
      if (object is Map && object.containsKey("data")) {
        final data = object["data"];
        if (data is Map && data.containsKey(query.collectionName)) {
          final myList = data[query.collectionName];
          if (myList is List) {
            final list = <Partner>[];
            myList.forEach((e) {
              final o = _fromIDorData(e);
              if (o is Partner) {
                list.add(o);
              }
            });
            return list;
          } else if (myList is Map && myList.containsKey("id")) {
            final o = _fromIDorData(myList);
            if (o is Partner) {
              return [o];
            }
          }
        }
      }
    }
    return [];
  }

  static Widget listenerWidget({
    Key? key,
    required Partner strapiObject,
    bool sync = false,
    required Widget Function(
      BuildContext,
      Partner,
      bool,
    )
        builder,
  }) {
    return _StrapiListenerWidget<Partner>(
      key: key,
      strapiObject: strapiObject,
      generator: Partner.fromMap,
      builder: builder,
      sync: sync,
    );
  }
}

class _PartnerFields {
  _PartnerFields._i();

  static final _PartnerFields i = _PartnerFields._i();

  final name = StrapiLeafField("name");

  final enabled = StrapiLeafField("enabled");

  final logo = StrapiCollectionField("logo");

  final businesses = StrapiCollectionField("businesses");

  final owner = StrapiModelField("owner");

  final about = StrapiLeafField("about");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [
      name,
      enabled,
      logo,
      businesses,
      owner,
      about,
      createdAt,
      updatedAt,
      id
    ];
  }
}

class _PartnerEmptyFields {
  bool name = false;

  bool enabled = false;

  bool logo = false;

  bool businesses = false;

  bool owner = false;

  bool about = false;
}

class DefaultData {
  DefaultData.fromID(this.id)
      : _synced = false,
        locality = null,
        city = null,
        customId = null,
        createdAt = null,
        updatedAt = null;

  DefaultData.fresh({this.locality, this.city, this.customId})
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  DefaultData._synced(this.locality, this.city, this.customId, this.createdAt,
      this.updatedAt, this.id)
      : _synced = true;

  DefaultData._unsynced(this.locality, this.city, this.customId, this.createdAt,
      this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final Locality? locality;

  final City? city;

  final String? customId;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  static final collectionName = "default-data";

  _DefaultDataEmptyFields _emptyFields = _DefaultDataEmptyFields();

  bool get synced => _synced;
  DefaultData copyWIth({Locality? locality, City? city, String? customId}) =>
      DefaultData._unsynced(locality ?? this.locality, city ?? this.city,
          customId ?? this.customId, this.createdAt, this.updatedAt, this.id);
  DefaultData setNull(
      {bool locality = false, bool city = false, bool customId = false}) {
    return DefaultData._unsynced(
        locality ? null : this.locality,
        city ? null : this.city,
        customId ? null : this.customId,
        this.createdAt,
        this.updatedAt,
        this.id)
      .._emptyFields.locality = locality
      .._emptyFields.city = city
      .._emptyFields.customId = customId;
  }

  static DefaultData fromSyncedMap(Map<dynamic, dynamic> map) =>
      DefaultData._synced(
          StrapiUtils.objFromMap<Locality>(
              map["locality"], (e) => Localities._fromIDorData(e)),
          StrapiUtils.objFromMap<City>(
              map["city"], (e) => Cities._fromIDorData(e)),
          map["customId"],
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["id"]);
  static DefaultData? fromMap(Map<String, dynamic> map) =>
      DefaultData._unsynced(
          StrapiUtils.objFromMap<Locality>(
              map["locality"], (e) => Localities._fromIDorData(e)),
          StrapiUtils.objFromMap<City>(
              map["city"], (e) => Cities._fromIDorData(e)),
          map["customId"],
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["id"]);
  Map<String, dynamic> toMap() => _toMap(level: -1);
  Map<String, dynamic> _toMap({int level = 0}) {
    final toServer = level == 0;
    return {
      if (_emptyFields.locality)
        "locality": null
      else if (!_emptyFields.locality && locality != null)
        "locality":
            toServer ? locality?.id : locality?._toMap(level: level + level),
      if (_emptyFields.city)
        "city": null
      else if (!_emptyFields.city && city != null)
        "city": toServer ? city?.id : city?._toMap(level: level + level),
      if (_emptyFields.customId)
        "customId": null
      else if (!_emptyFields.customId && customId != null)
        "customId": customId,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "id": id
    };
  }

  Future<DefaultData> sync() async {
    if (!synced) {
      return this;
    }
    final _id = this.id;
    if (_id is! String) {
      return this;
    }
    final response = await DefaultDatas.findOne(_id);
    if (response is DefaultData) {
      return response;
    } else {
      return this;
    }
  }

  static _DefaultDataFields get fields => _DefaultDataFields.i;
  @override
  String toString() =>
      "[Strapi Collection Type DefaultData]\n" + _toMap().toString();
}

class DefaultDatas {
  static const collectionName = "default-data";

  static List<DefaultData?> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => DefaultData.fromID(id)).toList();
  }

  static Future<DefaultData?> findOne(
    String id,
  ) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return DefaultData.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<DefaultData>> findMultiple({int limit = 16}) async {
    final list = await StrapiCollection.findMultiple(
      collection: collectionName,
      limit: limit,
    );
    if (list.isNotEmpty) {
      return list.map((map) => DefaultData.fromSyncedMap(map)).toList();
    }
    return [];
  }

  static Future<DefaultData?> create(DefaultData defaultData) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: defaultData._toMap(level: 0),
    );
    if (map.isNotEmpty) {
      return DefaultData.fromSyncedMap(map);
    }
  }

  static Future<DefaultData?> update(DefaultData defaultData) async {
    final id = defaultData.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: defaultData._toMap(level: 0),
      );
      if (map.isNotEmpty) {
        return DefaultData.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<DefaultData?> delete(DefaultData defaultData) async {
    final id = defaultData.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return DefaultData.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }

  static DefaultData? _fromIDorData(idOrData) {
    if (idOrData is String) {
      return DefaultData.fromID(idOrData);
    }
    if (idOrData is Map) {
      if ((idOrData.containsKey("createdAt") ||
              idOrData.containsKey("updatedAt")) &&
          (idOrData["createdAt"] == null || idOrData["updatedAt"] == null)) {
        final id = idOrData["id"];
        return DefaultData.fromID(id);
      }
      return DefaultData.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<DefaultData>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    final response = await Strapi.i
        .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
    if (response.body.isNotEmpty) {
      final object = response.body.first;
      if (object is Map && object.containsKey("data")) {
        final data = object["data"];
        if (data is Map && data.containsKey(query.collectionName)) {
          final myList = data[query.collectionName];
          if (myList is List) {
            final list = <DefaultData>[];
            myList.forEach((e) {
              final o = _fromIDorData(e);
              if (o is DefaultData) {
                list.add(o);
              }
            });
            return list;
          } else if (myList is Map && myList.containsKey("id")) {
            final o = _fromIDorData(myList);
            if (o is DefaultData) {
              return [o];
            }
          }
        }
      }
    }
    return [];
  }

  static Widget listenerWidget({
    Key? key,
    required DefaultData strapiObject,
    bool sync = false,
    required Widget Function(
      BuildContext,
      DefaultData,
      bool,
    )
        builder,
  }) {
    return _StrapiListenerWidget<DefaultData>(
      key: key,
      strapiObject: strapiObject,
      generator: DefaultData.fromMap,
      builder: builder,
      sync: sync,
    );
  }
}

class _DefaultDataFields {
  _DefaultDataFields._i();

  static final _DefaultDataFields i = _DefaultDataFields._i();

  final locality = StrapiModelField("locality");

  final city = StrapiModelField("city");

  final customId = StrapiLeafField("customId");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [locality, city, customId, createdAt, updatedAt, id];
  }
}

class _DefaultDataEmptyFields {
  bool locality = false;

  bool city = false;

  bool customId = false;
}

class MasterProduct {
  MasterProduct.fromID(this.id)
      : _synced = false,
        name = null,
        description = null,
        image = null,
        createdAt = null,
        updatedAt = null;

  MasterProduct.fresh({this.name, this.description, this.image})
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  MasterProduct._synced(this.name, this.description, this.image, this.createdAt,
      this.updatedAt, this.id)
      : _synced = true;

  MasterProduct._unsynced(this.name, this.description, this.image,
      this.createdAt, this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final String? name;

  final String? description;

  final StrapiFile? image;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  static final collectionName = "master-products";

  _MasterProductEmptyFields _emptyFields = _MasterProductEmptyFields();

  bool get synced => _synced;
  MasterProduct copyWIth(
          {String? name, String? description, StrapiFile? image}) =>
      MasterProduct._unsynced(
          name ?? this.name,
          description ?? this.description,
          image ?? this.image,
          this.createdAt,
          this.updatedAt,
          this.id);
  MasterProduct setNull(
      {bool name = false, bool description = false, bool image = false}) {
    return MasterProduct._unsynced(
        name ? null : this.name,
        description ? null : this.description,
        image ? null : this.image,
        this.createdAt,
        this.updatedAt,
        this.id)
      .._emptyFields.name = name
      .._emptyFields.description = description
      .._emptyFields.image = image;
  }

  static MasterProduct fromSyncedMap(Map<dynamic, dynamic> map) =>
      MasterProduct._synced(
          map["name"],
          map["description"],
          StrapiUtils.objFromMap<StrapiFile>(
              map["image"], (e) => StrapiFiles._fromIDorData(e)),
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["id"]);
  static MasterProduct? fromMap(Map<String, dynamic> map) =>
      MasterProduct._unsynced(
          map["name"],
          map["description"],
          StrapiUtils.objFromMap<StrapiFile>(
              map["image"], (e) => StrapiFiles._fromIDorData(e)),
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["id"]);
  Map<String, dynamic> toMap() => _toMap(level: -1);
  Map<String, dynamic> _toMap({int level = 0}) {
    final toServer = level == 0;
    return {
      if (_emptyFields.name)
        "name": null
      else if (!_emptyFields.name && name != null)
        "name": name,
      if (_emptyFields.description)
        "description": null
      else if (!_emptyFields.description && description != null)
        "description": description,
      if (_emptyFields.image)
        "image": null
      else if (!_emptyFields.image && image != null)
        "image": toServer ? image?.id : image?._toMap(level: level + level),
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "id": id
    };
  }

  Future<MasterProduct> sync() async {
    if (!synced) {
      return this;
    }
    final _id = this.id;
    if (_id is! String) {
      return this;
    }
    final response = await MasterProducts.findOne(_id);
    if (response is MasterProduct) {
      return response;
    } else {
      return this;
    }
  }

  static _MasterProductFields get fields => _MasterProductFields.i;
  @override
  String toString() =>
      "[Strapi Collection Type MasterProduct]\n" + _toMap().toString();
}

class MasterProducts {
  static const collectionName = "master-products";

  static List<MasterProduct?> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => MasterProduct.fromID(id)).toList();
  }

  static Future<MasterProduct?> findOne(
    String id,
  ) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return MasterProduct.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<MasterProduct>> findMultiple({int limit = 16}) async {
    final list = await StrapiCollection.findMultiple(
      collection: collectionName,
      limit: limit,
    );
    if (list.isNotEmpty) {
      return list.map((map) => MasterProduct.fromSyncedMap(map)).toList();
    }
    return [];
  }

  static Future<MasterProduct?> create(MasterProduct masterProduct) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: masterProduct._toMap(level: 0),
    );
    if (map.isNotEmpty) {
      return MasterProduct.fromSyncedMap(map);
    }
  }

  static Future<MasterProduct?> update(MasterProduct masterProduct) async {
    final id = masterProduct.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: masterProduct._toMap(level: 0),
      );
      if (map.isNotEmpty) {
        return MasterProduct.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<MasterProduct?> delete(MasterProduct masterProduct) async {
    final id = masterProduct.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return MasterProduct.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }

  static MasterProduct? _fromIDorData(idOrData) {
    if (idOrData is String) {
      return MasterProduct.fromID(idOrData);
    }
    if (idOrData is Map) {
      if ((idOrData.containsKey("createdAt") ||
              idOrData.containsKey("updatedAt")) &&
          (idOrData["createdAt"] == null || idOrData["updatedAt"] == null)) {
        final id = idOrData["id"];
        return MasterProduct.fromID(id);
      }
      return MasterProduct.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<MasterProduct>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    final response = await Strapi.i
        .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
    if (response.body.isNotEmpty) {
      final object = response.body.first;
      if (object is Map && object.containsKey("data")) {
        final data = object["data"];
        if (data is Map && data.containsKey(query.collectionName)) {
          final myList = data[query.collectionName];
          if (myList is List) {
            final list = <MasterProduct>[];
            myList.forEach((e) {
              final o = _fromIDorData(e);
              if (o is MasterProduct) {
                list.add(o);
              }
            });
            return list;
          } else if (myList is Map && myList.containsKey("id")) {
            final o = _fromIDorData(myList);
            if (o is MasterProduct) {
              return [o];
            }
          }
        }
      }
    }
    return [];
  }

  static Widget listenerWidget({
    Key? key,
    required MasterProduct strapiObject,
    bool sync = false,
    required Widget Function(
      BuildContext,
      MasterProduct,
      bool,
    )
        builder,
  }) {
    return _StrapiListenerWidget<MasterProduct>(
      key: key,
      strapiObject: strapiObject,
      generator: MasterProduct.fromMap,
      builder: builder,
      sync: sync,
    );
  }
}

class _MasterProductFields {
  _MasterProductFields._i();

  static final _MasterProductFields i = _MasterProductFields._i();

  final name = StrapiLeafField("name");

  final description = StrapiLeafField("description");

  final image = StrapiModelField("image");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [name, description, image, createdAt, updatedAt, id];
  }
}

class _MasterProductEmptyFields {
  bool name = false;

  bool description = false;

  bool image = false;
}

enum Feature { webWidget, facebookMessnger, listing }

class BusinessFeature {
  BusinessFeature.fromID(this.id)
      : _synced = false,
        feature = null,
        startDate = null,
        endDate = null,
        business = null,
        createdAt = null,
        updatedAt = null;

  BusinessFeature.fresh(
      {this.feature, this.startDate, this.endDate, this.business})
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  BusinessFeature._synced(this.feature, this.startDate, this.endDate,
      this.business, this.createdAt, this.updatedAt, this.id)
      : _synced = true;

  BusinessFeature._unsynced(this.feature, this.startDate, this.endDate,
      this.business, this.createdAt, this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final Feature? feature;

  final DateTime? startDate;

  final DateTime? endDate;

  final Business? business;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  static final collectionName = "business-features";

  _BusinessFeatureEmptyFields _emptyFields = _BusinessFeatureEmptyFields();

  bool get synced => _synced;
  BusinessFeature copyWIth(
          {Feature? feature,
          DateTime? startDate,
          DateTime? endDate,
          Business? business}) =>
      BusinessFeature._unsynced(
          feature ?? this.feature,
          startDate ?? this.startDate,
          endDate ?? this.endDate,
          business ?? this.business,
          this.createdAt,
          this.updatedAt,
          this.id);
  BusinessFeature setNull(
      {bool feature = false,
      bool startDate = false,
      bool endDate = false,
      bool business = false}) {
    return BusinessFeature._unsynced(
        feature ? null : this.feature,
        startDate ? null : this.startDate,
        endDate ? null : this.endDate,
        business ? null : this.business,
        this.createdAt,
        this.updatedAt,
        this.id)
      .._emptyFields.feature = feature
      .._emptyFields.startDate = startDate
      .._emptyFields.endDate = endDate
      .._emptyFields.business = business;
  }

  static BusinessFeature fromSyncedMap(Map<dynamic, dynamic> map) =>
      BusinessFeature._synced(
          StrapiUtils.toEnum<Feature>(Feature.values, map["feature"]),
          StrapiUtils.parseDateTime(map["startDate"]),
          StrapiUtils.parseDateTime(map["endDate"]),
          StrapiUtils.objFromMap<Business>(
              map["business"], (e) => Businesses._fromIDorData(e)),
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["id"]);
  static BusinessFeature? fromMap(Map<String, dynamic> map) =>
      BusinessFeature._unsynced(
          StrapiUtils.toEnum<Feature>(Feature.values, map["feature"]),
          StrapiUtils.parseDateTime(map["startDate"]),
          StrapiUtils.parseDateTime(map["endDate"]),
          StrapiUtils.objFromMap<Business>(
              map["business"], (e) => Businesses._fromIDorData(e)),
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["id"]);
  Map<String, dynamic> toMap() => _toMap(level: -1);
  Map<String, dynamic> _toMap({int level = 0}) {
    final toServer = level == 0;
    return {
      if (_emptyFields.feature)
        "feature": null
      else if (!_emptyFields.feature && feature != null)
        "feature": StrapiUtils.enumToString(feature),
      if (_emptyFields.startDate)
        "startDate": null
      else if (!_emptyFields.startDate && startDate != null)
        "startDate": startDate?.toIso8601String(),
      if (_emptyFields.endDate)
        "endDate": null
      else if (!_emptyFields.endDate && endDate != null)
        "endDate": endDate?.toIso8601String(),
      if (_emptyFields.business)
        "business": null
      else if (!_emptyFields.business && business != null)
        "business":
            toServer ? business?.id : business?._toMap(level: level + level),
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "id": id
    };
  }

  Future<BusinessFeature> sync() async {
    if (!synced) {
      return this;
    }
    final _id = this.id;
    if (_id is! String) {
      return this;
    }
    final response = await BusinessFeatures.findOne(_id);
    if (response is BusinessFeature) {
      return response;
    } else {
      return this;
    }
  }

  static _BusinessFeatureFields get fields => _BusinessFeatureFields.i;
  @override
  String toString() =>
      "[Strapi Collection Type BusinessFeature]\n" + _toMap().toString();
}

class BusinessFeatures {
  static const collectionName = "business-features";

  static List<BusinessFeature?> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => BusinessFeature.fromID(id)).toList();
  }

  static Future<BusinessFeature?> findOne(
    String id,
  ) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return BusinessFeature.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<BusinessFeature>> findMultiple({int limit = 16}) async {
    final list = await StrapiCollection.findMultiple(
      collection: collectionName,
      limit: limit,
    );
    if (list.isNotEmpty) {
      return list.map((map) => BusinessFeature.fromSyncedMap(map)).toList();
    }
    return [];
  }

  static Future<BusinessFeature?> create(
      BusinessFeature businessFeature) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: businessFeature._toMap(level: 0),
    );
    if (map.isNotEmpty) {
      return BusinessFeature.fromSyncedMap(map);
    }
  }

  static Future<BusinessFeature?> update(
      BusinessFeature businessFeature) async {
    final id = businessFeature.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: businessFeature._toMap(level: 0),
      );
      if (map.isNotEmpty) {
        return BusinessFeature.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<BusinessFeature?> delete(
      BusinessFeature businessFeature) async {
    final id = businessFeature.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return BusinessFeature.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }

  static BusinessFeature? _fromIDorData(idOrData) {
    if (idOrData is String) {
      return BusinessFeature.fromID(idOrData);
    }
    if (idOrData is Map) {
      if ((idOrData.containsKey("createdAt") ||
              idOrData.containsKey("updatedAt")) &&
          (idOrData["createdAt"] == null || idOrData["updatedAt"] == null)) {
        final id = idOrData["id"];
        return BusinessFeature.fromID(id);
      }
      return BusinessFeature.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<BusinessFeature>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    final response = await Strapi.i
        .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
    if (response.body.isNotEmpty) {
      final object = response.body.first;
      if (object is Map && object.containsKey("data")) {
        final data = object["data"];
        if (data is Map && data.containsKey(query.collectionName)) {
          final myList = data[query.collectionName];
          if (myList is List) {
            final list = <BusinessFeature>[];
            myList.forEach((e) {
              final o = _fromIDorData(e);
              if (o is BusinessFeature) {
                list.add(o);
              }
            });
            return list;
          } else if (myList is Map && myList.containsKey("id")) {
            final o = _fromIDorData(myList);
            if (o is BusinessFeature) {
              return [o];
            }
          }
        }
      }
    }
    return [];
  }

  static Widget listenerWidget({
    Key? key,
    required BusinessFeature strapiObject,
    bool sync = false,
    required Widget Function(
      BuildContext,
      BusinessFeature,
      bool,
    )
        builder,
  }) {
    return _StrapiListenerWidget<BusinessFeature>(
      key: key,
      strapiObject: strapiObject,
      generator: BusinessFeature.fromMap,
      builder: builder,
      sync: sync,
    );
  }
}

class _BusinessFeatureFields {
  _BusinessFeatureFields._i();

  static final _BusinessFeatureFields i = _BusinessFeatureFields._i();

  final feature = StrapiLeafField("feature");

  final startDate = StrapiLeafField("startDate");

  final endDate = StrapiLeafField("endDate");

  final business = StrapiModelField("business");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [feature, startDate, endDate, business, createdAt, updatedAt, id];
  }
}

class _BusinessFeatureEmptyFields {
  bool feature = false;

  bool startDate = false;

  bool endDate = false;

  bool business = false;
}

class Review {
  Review.fromID(this.id)
      : _synced = false,
        reviewedOn = null,
        rating = null,
        review = null,
        emplyeeRating = null,
        employeeReview = null,
        facilityRating = null,
        facilityReview = null,
        booking = null,
        createdAt = null,
        updatedAt = null;

  Review.fresh(
      {this.reviewedOn,
      this.rating,
      this.review,
      this.emplyeeRating,
      this.employeeReview,
      this.facilityRating,
      this.facilityReview,
      this.booking})
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  Review._synced(
      this.reviewedOn,
      this.rating,
      this.review,
      this.emplyeeRating,
      this.employeeReview,
      this.facilityRating,
      this.facilityReview,
      this.booking,
      this.createdAt,
      this.updatedAt,
      this.id)
      : _synced = true;

  Review._unsynced(
      this.reviewedOn,
      this.rating,
      this.review,
      this.emplyeeRating,
      this.employeeReview,
      this.facilityRating,
      this.facilityReview,
      this.booking,
      this.createdAt,
      this.updatedAt,
      this.id)
      : _synced = false;

  final bool _synced;

  final DateTime? reviewedOn;

  final double? rating;

  final String? review;

  final double? emplyeeRating;

  final String? employeeReview;

  final double? facilityRating;

  final String? facilityReview;

  final Booking? booking;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  static final collectionName = "reviews";

  _ReviewEmptyFields _emptyFields = _ReviewEmptyFields();

  bool get synced => _synced;
  Review copyWIth(
          {DateTime? reviewedOn,
          double? rating,
          String? review,
          double? emplyeeRating,
          String? employeeReview,
          double? facilityRating,
          String? facilityReview,
          Booking? booking}) =>
      Review._unsynced(
          reviewedOn ?? this.reviewedOn,
          rating ?? this.rating,
          review ?? this.review,
          emplyeeRating ?? this.emplyeeRating,
          employeeReview ?? this.employeeReview,
          facilityRating ?? this.facilityRating,
          facilityReview ?? this.facilityReview,
          booking ?? this.booking,
          this.createdAt,
          this.updatedAt,
          this.id);
  Review setNull(
      {bool reviewedOn = false,
      bool rating = false,
      bool review = false,
      bool emplyeeRating = false,
      bool employeeReview = false,
      bool facilityRating = false,
      bool facilityReview = false,
      bool booking = false}) {
    return Review._unsynced(
        reviewedOn ? null : this.reviewedOn,
        rating ? null : this.rating,
        review ? null : this.review,
        emplyeeRating ? null : this.emplyeeRating,
        employeeReview ? null : this.employeeReview,
        facilityRating ? null : this.facilityRating,
        facilityReview ? null : this.facilityReview,
        booking ? null : this.booking,
        this.createdAt,
        this.updatedAt,
        this.id)
      .._emptyFields.reviewedOn = reviewedOn
      .._emptyFields.rating = rating
      .._emptyFields.review = review
      .._emptyFields.emplyeeRating = emplyeeRating
      .._emptyFields.employeeReview = employeeReview
      .._emptyFields.facilityRating = facilityRating
      .._emptyFields.facilityReview = facilityReview
      .._emptyFields.booking = booking;
  }

  static Review fromSyncedMap(Map<dynamic, dynamic> map) => Review._synced(
      StrapiUtils.parseDateTime(map["reviewedOn"]),
      StrapiUtils.parseDouble(map["rating"]),
      map["review"],
      StrapiUtils.parseDouble(map["emplyeeRating"]),
      map["employeeReview"],
      StrapiUtils.parseDouble(map["facilityRating"]),
      map["facilityReview"],
      StrapiUtils.objFromMap<Booking>(
          map["booking"], (e) => Bookings._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  static Review? fromMap(Map<String, dynamic> map) => Review._unsynced(
      StrapiUtils.parseDateTime(map["reviewedOn"]),
      StrapiUtils.parseDouble(map["rating"]),
      map["review"],
      StrapiUtils.parseDouble(map["emplyeeRating"]),
      map["employeeReview"],
      StrapiUtils.parseDouble(map["facilityRating"]),
      map["facilityReview"],
      StrapiUtils.objFromMap<Booking>(
          map["booking"], (e) => Bookings._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  Map<String, dynamic> toMap() => _toMap(level: -1);
  Map<String, dynamic> _toMap({int level = 0}) {
    final toServer = level == 0;
    return {
      if (_emptyFields.reviewedOn)
        "reviewedOn": null
      else if (!_emptyFields.reviewedOn && reviewedOn != null)
        "reviewedOn": reviewedOn?.toIso8601String(),
      if (_emptyFields.rating)
        "rating": null
      else if (!_emptyFields.rating && rating != null)
        "rating": rating,
      if (_emptyFields.review)
        "review": null
      else if (!_emptyFields.review && review != null)
        "review": review,
      if (_emptyFields.emplyeeRating)
        "emplyeeRating": null
      else if (!_emptyFields.emplyeeRating && emplyeeRating != null)
        "emplyeeRating": emplyeeRating,
      if (_emptyFields.employeeReview)
        "employeeReview": null
      else if (!_emptyFields.employeeReview && employeeReview != null)
        "employeeReview": employeeReview,
      if (_emptyFields.facilityRating)
        "facilityRating": null
      else if (!_emptyFields.facilityRating && facilityRating != null)
        "facilityRating": facilityRating,
      if (_emptyFields.facilityReview)
        "facilityReview": null
      else if (!_emptyFields.facilityReview && facilityReview != null)
        "facilityReview": facilityReview,
      if (_emptyFields.booking)
        "booking": null
      else if (!_emptyFields.booking && booking != null)
        "booking":
            toServer ? booking?.id : booking?._toMap(level: level + level),
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "id": id
    };
  }

  Future<Review> sync() async {
    if (!synced) {
      return this;
    }
    final _id = this.id;
    if (_id is! String) {
      return this;
    }
    final response = await Reviews.findOne(_id);
    if (response is Review) {
      return response;
    } else {
      return this;
    }
  }

  static _ReviewFields get fields => _ReviewFields.i;
  @override
  String toString() =>
      "[Strapi Collection Type Review]\n" + _toMap().toString();
}

class Reviews {
  static const collectionName = "reviews";

  static List<Review?> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => Review.fromID(id)).toList();
  }

  static Future<Review?> findOne(
    String id,
  ) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return Review.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<Review>> findMultiple({int limit = 16}) async {
    final list = await StrapiCollection.findMultiple(
      collection: collectionName,
      limit: limit,
    );
    if (list.isNotEmpty) {
      return list.map((map) => Review.fromSyncedMap(map)).toList();
    }
    return [];
  }

  static Future<Review?> create(Review review) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: review._toMap(level: 0),
    );
    if (map.isNotEmpty) {
      return Review.fromSyncedMap(map);
    }
  }

  static Future<Review?> update(Review review) async {
    final id = review.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: review._toMap(level: 0),
      );
      if (map.isNotEmpty) {
        return Review.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<Review?> delete(Review review) async {
    final id = review.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return Review.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }

  static Review? _fromIDorData(idOrData) {
    if (idOrData is String) {
      return Review.fromID(idOrData);
    }
    if (idOrData is Map) {
      if ((idOrData.containsKey("createdAt") ||
              idOrData.containsKey("updatedAt")) &&
          (idOrData["createdAt"] == null || idOrData["updatedAt"] == null)) {
        final id = idOrData["id"];
        return Review.fromID(id);
      }
      return Review.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<Review>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    final response = await Strapi.i
        .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
    if (response.body.isNotEmpty) {
      final object = response.body.first;
      if (object is Map && object.containsKey("data")) {
        final data = object["data"];
        if (data is Map && data.containsKey(query.collectionName)) {
          final myList = data[query.collectionName];
          if (myList is List) {
            final list = <Review>[];
            myList.forEach((e) {
              final o = _fromIDorData(e);
              if (o is Review) {
                list.add(o);
              }
            });
            return list;
          } else if (myList is Map && myList.containsKey("id")) {
            final o = _fromIDorData(myList);
            if (o is Review) {
              return [o];
            }
          }
        }
      }
    }
    return [];
  }

  static Widget listenerWidget({
    Key? key,
    required Review strapiObject,
    bool sync = false,
    required Widget Function(
      BuildContext,
      Review,
      bool,
    )
        builder,
  }) {
    return _StrapiListenerWidget<Review>(
      key: key,
      strapiObject: strapiObject,
      generator: Review.fromMap,
      builder: builder,
      sync: sync,
    );
  }
}

class _ReviewFields {
  _ReviewFields._i();

  static final _ReviewFields i = _ReviewFields._i();

  final reviewedOn = StrapiLeafField("reviewedOn");

  final rating = StrapiLeafField("rating");

  final review = StrapiLeafField("review");

  final emplyeeRating = StrapiLeafField("emplyeeRating");

  final employeeReview = StrapiLeafField("employeeReview");

  final facilityRating = StrapiLeafField("facilityRating");

  final facilityReview = StrapiLeafField("facilityReview");

  final booking = StrapiModelField("booking");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [
      reviewedOn,
      rating,
      review,
      emplyeeRating,
      employeeReview,
      facilityRating,
      facilityReview,
      booking,
      createdAt,
      updatedAt,
      id
    ];
  }
}

class _ReviewEmptyFields {
  bool reviewedOn = false;

  bool rating = false;

  bool review = false;

  bool emplyeeRating = false;

  bool employeeReview = false;

  bool facilityRating = false;

  bool facilityReview = false;

  bool booking = false;
}

class Role {
  Role.fromID(this.id)
      : _synced = false,
        name = null,
        description = null,
        type = null,
        permissions = null,
        users = null,
        createdAt = null,
        updatedAt = null;

  Role.fresh(
      {this.name, this.description, this.type, this.permissions, this.users})
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  Role._synced(this.name, this.description, this.type, this.permissions,
      this.users, this.createdAt, this.updatedAt, this.id)
      : _synced = true;

  Role._unsynced(this.name, this.description, this.type, this.permissions,
      this.users, this.createdAt, this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final String? name;

  final String? description;

  final String? type;

  final List<Permission>? permissions;

  final List<User>? users;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  static final collectionName = "Roles";

  _RoleEmptyFields _emptyFields = _RoleEmptyFields();

  bool get synced => _synced;
  Role copyWIth(
          {String? name,
          String? description,
          String? type,
          List<Permission>? permissions,
          List<User>? users}) =>
      Role._unsynced(
          name ?? this.name,
          description ?? this.description,
          type ?? this.type,
          permissions ?? this.permissions,
          users ?? this.users,
          this.createdAt,
          this.updatedAt,
          this.id);
  Role setNull(
      {bool name = false,
      bool description = false,
      bool type = false,
      bool permissions = false,
      bool users = false}) {
    return Role._unsynced(
        name ? null : this.name,
        description ? null : this.description,
        type ? null : this.type,
        permissions ? null : this.permissions,
        users ? null : this.users,
        this.createdAt,
        this.updatedAt,
        this.id)
      .._emptyFields.name = name
      .._emptyFields.description = description
      .._emptyFields.type = type
      .._emptyFields.permissions = permissions
      .._emptyFields.users = users;
  }

  static Role fromSyncedMap(Map<dynamic, dynamic> map) => Role._synced(
      map["name"],
      map["description"],
      map["type"],
      StrapiUtils.objFromListOfMap<Permission>(
          map["permissions"], (e) => Permissions._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<User>(
          map["users"], (e) => Users._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  static Role? fromMap(Map<String, dynamic> map) => Role._unsynced(
      map["name"],
      map["description"],
      map["type"],
      StrapiUtils.objFromListOfMap<Permission>(
          map["permissions"], (e) => Permissions._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<User>(
          map["users"], (e) => Users._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  Map<String, dynamic> toMap() => _toMap(level: -1);
  Map<String, dynamic> _toMap({int level = 0}) {
    final toServer = level == 0;
    return {
      if (_emptyFields.name)
        "name": null
      else if (!_emptyFields.name && name != null)
        "name": name,
      if (_emptyFields.description)
        "description": null
      else if (!_emptyFields.description && description != null)
        "description": description,
      if (_emptyFields.type)
        "type": null
      else if (!_emptyFields.type && type != null)
        "type": type,
      if (_emptyFields.permissions)
        "permissions": []
      else if (!_emptyFields.permissions && permissions != null)
        "permissions": permissions
            ?.map((e) => toServer ? e.id : e._toMap(level: level + level))
            .toList(),
      if (_emptyFields.users)
        "users": []
      else if (!_emptyFields.users && users != null)
        "users": users
            ?.map((e) => toServer ? e.id : e._toMap(level: level + level))
            .toList(),
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "id": id
    };
  }

  Future<Role> sync() async {
    if (!synced) {
      return this;
    }
    final _id = this.id;
    if (_id is! String) {
      return this;
    }
    final response = await Roles.findOne(_id);
    if (response is Role) {
      return response;
    } else {
      return this;
    }
  }

  static _RoleFields get fields => _RoleFields.i;
  @override
  String toString() => "[Strapi Collection Type Role]\n" + _toMap().toString();
}

class Roles {
  static const collectionName = "Roles";

  static List<Role?> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => Role.fromID(id)).toList();
  }

  static Future<Role?> findOne(
    String id,
  ) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return Role.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<Role>> findMultiple({int limit = 16}) async {
    final list = await StrapiCollection.findMultiple(
      collection: collectionName,
      limit: limit,
    );
    if (list.isNotEmpty) {
      return list.map((map) => Role.fromSyncedMap(map)).toList();
    }
    return [];
  }

  static Future<Role?> create(Role role) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: role._toMap(level: 0),
    );
    if (map.isNotEmpty) {
      return Role.fromSyncedMap(map);
    }
  }

  static Future<Role?> update(Role role) async {
    final id = role.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: role._toMap(level: 0),
      );
      if (map.isNotEmpty) {
        return Role.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<Role?> delete(Role role) async {
    final id = role.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return Role.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }

  static Role? _fromIDorData(idOrData) {
    if (idOrData is String) {
      return Role.fromID(idOrData);
    }
    if (idOrData is Map) {
      if ((idOrData.containsKey("createdAt") ||
              idOrData.containsKey("updatedAt")) &&
          (idOrData["createdAt"] == null || idOrData["updatedAt"] == null)) {
        final id = idOrData["id"];
        return Role.fromID(id);
      }
      return Role.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<Role>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    final response = await Strapi.i
        .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
    if (response.body.isNotEmpty) {
      final object = response.body.first;
      if (object is Map && object.containsKey("data")) {
        final data = object["data"];
        if (data is Map && data.containsKey(query.collectionName)) {
          final myList = data[query.collectionName];
          if (myList is List) {
            final list = <Role>[];
            myList.forEach((e) {
              final o = _fromIDorData(e);
              if (o is Role) {
                list.add(o);
              }
            });
            return list;
          } else if (myList is Map && myList.containsKey("id")) {
            final o = _fromIDorData(myList);
            if (o is Role) {
              return [o];
            }
          }
        }
      }
    }
    return [];
  }

  static Widget listenerWidget({
    Key? key,
    required Role strapiObject,
    bool sync = false,
    required Widget Function(
      BuildContext,
      Role,
      bool,
    )
        builder,
  }) {
    return _StrapiListenerWidget<Role>(
      key: key,
      strapiObject: strapiObject,
      generator: Role.fromMap,
      builder: builder,
      sync: sync,
    );
  }
}

class _RoleFields {
  _RoleFields._i();

  static final _RoleFields i = _RoleFields._i();

  final name = StrapiLeafField("name");

  final description = StrapiLeafField("description");

  final type = StrapiLeafField("type");

  final permissions = StrapiCollectionField("permissions");

  final users = StrapiCollectionField("users");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [
      name,
      description,
      type,
      permissions,
      users,
      createdAt,
      updatedAt,
      id
    ];
  }
}

class _RoleEmptyFields {
  bool name = false;

  bool description = false;

  bool type = false;

  bool permissions = false;

  bool users = false;
}

class User {
  User.fromID(this.id)
      : _synced = false,
        username = null,
        email = null,
        provider = null,
        resetPasswordToken = null,
        confirmationToken = null,
        confirmed = null,
        blocked = null,
        role = null,
        favourites = null,
        name = null,
        pushNotifications = null,
        employee = null,
        partner = null,
        locality = null,
        city = null,
        bookings = null,
        cart = null,
        createdAt = null,
        updatedAt = null;

  User.fresh(
      {this.username,
      this.email,
      this.provider,
      this.resetPasswordToken,
      this.confirmationToken,
      this.confirmed,
      this.blocked,
      this.role,
      this.favourites,
      this.name,
      this.pushNotifications,
      this.employee,
      this.partner,
      this.locality,
      this.city,
      this.bookings,
      this.cart})
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  User._synced(
      this.username,
      this.email,
      this.provider,
      this.resetPasswordToken,
      this.confirmationToken,
      this.confirmed,
      this.blocked,
      this.role,
      this.favourites,
      this.name,
      this.pushNotifications,
      this.employee,
      this.partner,
      this.locality,
      this.city,
      this.bookings,
      this.cart,
      this.createdAt,
      this.updatedAt,
      this.id)
      : _synced = true;

  User._unsynced(
      this.username,
      this.email,
      this.provider,
      this.resetPasswordToken,
      this.confirmationToken,
      this.confirmed,
      this.blocked,
      this.role,
      this.favourites,
      this.name,
      this.pushNotifications,
      this.employee,
      this.partner,
      this.locality,
      this.city,
      this.bookings,
      this.cart,
      this.createdAt,
      this.updatedAt,
      this.id)
      : _synced = false;

  final bool _synced;

  final String? username;

  final String? email;

  final String? provider;

  final String? resetPasswordToken;

  final String? confirmationToken;

  final bool? confirmed;

  final bool? blocked;

  final Role? role;

  final List<Favourites>? favourites;

  final String? name;

  final List<PushNotification>? pushNotifications;

  final Employee? employee;

  final Partner? partner;

  final Locality? locality;

  final City? city;

  final List<Booking>? bookings;

  final Booking? cart;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  static final collectionName = "Users";

  _UserEmptyFields _emptyFields = _UserEmptyFields();

  bool get synced => _synced;
  User copyWIth(
          {String? username,
          String? email,
          String? provider,
          String? resetPasswordToken,
          String? confirmationToken,
          bool? confirmed,
          bool? blocked,
          Role? role,
          List<Favourites>? favourites,
          String? name,
          List<PushNotification>? pushNotifications,
          Employee? employee,
          Partner? partner,
          Locality? locality,
          City? city,
          List<Booking>? bookings,
          Booking? cart}) =>
      User._unsynced(
          username ?? this.username,
          email ?? this.email,
          provider ?? this.provider,
          resetPasswordToken ?? this.resetPasswordToken,
          confirmationToken ?? this.confirmationToken,
          confirmed ?? this.confirmed,
          blocked ?? this.blocked,
          role ?? this.role,
          favourites ?? this.favourites,
          name ?? this.name,
          pushNotifications ?? this.pushNotifications,
          employee ?? this.employee,
          partner ?? this.partner,
          locality ?? this.locality,
          city ?? this.city,
          bookings ?? this.bookings,
          cart ?? this.cart,
          this.createdAt,
          this.updatedAt,
          this.id);
  User setNull(
      {bool username = false,
      bool email = false,
      bool provider = false,
      bool resetPasswordToken = false,
      bool confirmationToken = false,
      bool confirmed = false,
      bool blocked = false,
      bool role = false,
      bool favourites = false,
      bool name = false,
      bool pushNotifications = false,
      bool employee = false,
      bool partner = false,
      bool locality = false,
      bool city = false,
      bool bookings = false,
      bool cart = false}) {
    return User._unsynced(
        username ? null : this.username,
        email ? null : this.email,
        provider ? null : this.provider,
        resetPasswordToken ? null : this.resetPasswordToken,
        confirmationToken ? null : this.confirmationToken,
        confirmed ? null : this.confirmed,
        blocked ? null : this.blocked,
        role ? null : this.role,
        favourites ? null : this.favourites,
        name ? null : this.name,
        pushNotifications ? null : this.pushNotifications,
        employee ? null : this.employee,
        partner ? null : this.partner,
        locality ? null : this.locality,
        city ? null : this.city,
        bookings ? null : this.bookings,
        cart ? null : this.cart,
        this.createdAt,
        this.updatedAt,
        this.id)
      .._emptyFields.username = username
      .._emptyFields.email = email
      .._emptyFields.provider = provider
      .._emptyFields.resetPasswordToken = resetPasswordToken
      .._emptyFields.confirmationToken = confirmationToken
      .._emptyFields.confirmed = confirmed
      .._emptyFields.blocked = blocked
      .._emptyFields.role = role
      .._emptyFields.favourites = favourites
      .._emptyFields.name = name
      .._emptyFields.pushNotifications = pushNotifications
      .._emptyFields.employee = employee
      .._emptyFields.partner = partner
      .._emptyFields.locality = locality
      .._emptyFields.city = city
      .._emptyFields.bookings = bookings
      .._emptyFields.cart = cart;
  }

  static User fromSyncedMap(Map<dynamic, dynamic> map) => User._synced(
      map["username"],
      map["email"],
      map["provider"],
      map["resetPasswordToken"],
      map["confirmationToken"],
      StrapiUtils.parseBool(map["confirmed"]),
      StrapiUtils.parseBool(map["blocked"]),
      StrapiUtils.objFromMap<Role>(map["role"], (e) => Roles._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Favourites>(
          map["favourites"], (e) => Favourites.fromMap(e)),
      map["name"],
      StrapiUtils.objFromListOfMap<PushNotification>(
          map["pushNotifications"], (e) => PushNotifications._fromIDorData(e)),
      StrapiUtils.objFromMap<Employee>(
          map["employee"], (e) => Employees._fromIDorData(e)),
      StrapiUtils.objFromMap<Partner>(
          map["partner"], (e) => Partners._fromIDorData(e)),
      StrapiUtils.objFromMap<Locality>(
          map["locality"], (e) => Localities._fromIDorData(e)),
      StrapiUtils.objFromMap<City>(map["city"], (e) => Cities._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Booking>(
          map["bookings"], (e) => Bookings._fromIDorData(e)),
      StrapiUtils.objFromMap<Booking>(
          map["cart"], (e) => Bookings._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  static User? fromMap(Map<String, dynamic> map) => User._unsynced(
      map["username"],
      map["email"],
      map["provider"],
      map["resetPasswordToken"],
      map["confirmationToken"],
      StrapiUtils.parseBool(map["confirmed"]),
      StrapiUtils.parseBool(map["blocked"]),
      StrapiUtils.objFromMap<Role>(map["role"], (e) => Roles._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Favourites>(
          map["favourites"], (e) => Favourites.fromMap(e)),
      map["name"],
      StrapiUtils.objFromListOfMap<PushNotification>(
          map["pushNotifications"], (e) => PushNotifications._fromIDorData(e)),
      StrapiUtils.objFromMap<Employee>(
          map["employee"], (e) => Employees._fromIDorData(e)),
      StrapiUtils.objFromMap<Partner>(
          map["partner"], (e) => Partners._fromIDorData(e)),
      StrapiUtils.objFromMap<Locality>(
          map["locality"], (e) => Localities._fromIDorData(e)),
      StrapiUtils.objFromMap<City>(map["city"], (e) => Cities._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Booking>(
          map["bookings"], (e) => Bookings._fromIDorData(e)),
      StrapiUtils.objFromMap<Booking>(
          map["cart"], (e) => Bookings._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  Map<String, dynamic> toMap() => _toMap(level: -1);
  Map<String, dynamic> _toMap({int level = 0}) {
    final toServer = level == 0;
    return {
      if (_emptyFields.username)
        "username": null
      else if (!_emptyFields.username && username != null)
        "username": username,
      if (_emptyFields.email)
        "email": null
      else if (!_emptyFields.email && email != null)
        "email": email,
      if (_emptyFields.provider)
        "provider": null
      else if (!_emptyFields.provider && provider != null)
        "provider": provider,
      if (_emptyFields.resetPasswordToken)
        "resetPasswordToken": null
      else if (!_emptyFields.resetPasswordToken && resetPasswordToken != null)
        "resetPasswordToken": resetPasswordToken,
      if (_emptyFields.confirmationToken)
        "confirmationToken": null
      else if (!_emptyFields.confirmationToken && confirmationToken != null)
        "confirmationToken": confirmationToken,
      if (_emptyFields.confirmed)
        "confirmed": null
      else if (!_emptyFields.confirmed && confirmed != null)
        "confirmed": confirmed,
      if (_emptyFields.blocked)
        "blocked": null
      else if (!_emptyFields.blocked && blocked != null)
        "blocked": blocked,
      if (_emptyFields.role)
        "role": null
      else if (!_emptyFields.role && role != null)
        "role": toServer ? role?.id : role?._toMap(level: level + level),
      if (_emptyFields.favourites)
        "favourites": []
      else if (!_emptyFields.favourites && favourites != null)
        "favourites":
            favourites?.map((e) => e._toMap(level: level + level)).toList(),
      if (_emptyFields.name)
        "name": null
      else if (!_emptyFields.name && name != null)
        "name": name,
      if (_emptyFields.pushNotifications)
        "pushNotifications": []
      else if (!_emptyFields.pushNotifications && pushNotifications != null)
        "pushNotifications": pushNotifications
            ?.map((e) => toServer ? e.id : e._toMap(level: level + level))
            .toList(),
      if (_emptyFields.employee)
        "employee": null
      else if (!_emptyFields.employee && employee != null)
        "employee":
            toServer ? employee?.id : employee?._toMap(level: level + level),
      if (_emptyFields.partner)
        "partner": null
      else if (!_emptyFields.partner && partner != null)
        "partner":
            toServer ? partner?.id : partner?._toMap(level: level + level),
      if (_emptyFields.locality)
        "locality": null
      else if (!_emptyFields.locality && locality != null)
        "locality":
            toServer ? locality?.id : locality?._toMap(level: level + level),
      if (_emptyFields.city)
        "city": null
      else if (!_emptyFields.city && city != null)
        "city": toServer ? city?.id : city?._toMap(level: level + level),
      if (_emptyFields.bookings)
        "bookings": []
      else if (!_emptyFields.bookings && bookings != null)
        "bookings": bookings
            ?.map((e) => toServer ? e.id : e._toMap(level: level + level))
            .toList(),
      if (_emptyFields.cart)
        "cart": null
      else if (!_emptyFields.cart && cart != null)
        "cart": toServer ? cart?.id : cart?._toMap(level: level + level),
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "id": id
    };
  }

  Future<User> sync() async {
    if (!synced) {
      return this;
    }
    final _id = this.id;
    if (_id is! String) {
      return this;
    }
    final response = await Users.findOne(_id);
    if (response is User) {
      return response;
    } else {
      return this;
    }
  }

  static _UserFields get fields => _UserFields.i;
  @override
  String toString() => "[Strapi Collection Type User]\n" + _toMap().toString();
}

class Users {
  static const collectionName = "Users";

  static List<User?> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => User.fromID(id)).toList();
  }

  static Future<User?> findOne(
    String id,
  ) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return User.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<User>> findMultiple({int limit = 16}) async {
    final list = await StrapiCollection.findMultiple(
      collection: collectionName,
      limit: limit,
    );
    if (list.isNotEmpty) {
      return list.map((map) => User.fromSyncedMap(map)).toList();
    }
    return [];
  }

  static Future<User?> create(User user) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: user._toMap(level: 0),
    );
    if (map.isNotEmpty) {
      return User.fromSyncedMap(map);
    }
  }

  static Future<User?> update(User user) async {
    final id = user.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: user._toMap(level: 0),
      );
      if (map.isNotEmpty) {
        return User.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<User?> delete(User user) async {
    final id = user.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return User.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }

  static User? _fromIDorData(idOrData) {
    if (idOrData is String) {
      return User.fromID(idOrData);
    }
    if (idOrData is Map) {
      if ((idOrData.containsKey("createdAt") ||
              idOrData.containsKey("updatedAt")) &&
          (idOrData["createdAt"] == null || idOrData["updatedAt"] == null)) {
        final id = idOrData["id"];
        return User.fromID(id);
      }
      return User.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<User>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    final response = await Strapi.i
        .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
    if (response.body.isNotEmpty) {
      final object = response.body.first;
      if (object is Map && object.containsKey("data")) {
        final data = object["data"];
        if (data is Map && data.containsKey(query.collectionName)) {
          final myList = data[query.collectionName];
          if (myList is List) {
            final list = <User>[];
            myList.forEach((e) {
              final o = _fromIDorData(e);
              if (o is User) {
                list.add(o);
              }
            });
            return list;
          } else if (myList is Map && myList.containsKey("id")) {
            final o = _fromIDorData(myList);
            if (o is User) {
              return [o];
            }
          }
        }
      }
    }
    return [];
  }

  static User? _me;
  static Future<User?> me({asFindOne: false}) async {
    final _id = _me?.id;
    if (asFindOne && (_me is User && _id is String)) {
      return findOne(_id);
    }

    if (Strapi.i.strapiToken.isEmpty) {
      throw StrapiException(
          msg:
              "cannot get users/me endpoint without token, please authenticate first");
    }
    final response = await StrapiCollection.customEndpoint(
        collection: "users", endPoint: "me");
    if (response is List && response.isNotEmpty) {
      _me = User.fromSyncedMap(response.first);
    }
    if (_me is User && asFindOne) {
      return me(asFindOne: asFindOne);
    }
    return _me;
  }

  static Widget listenerWidget({
    Key? key,
    required User strapiObject,
    bool sync = false,
    required Widget Function(
      BuildContext,
      User,
      bool,
    )
        builder,
  }) {
    return _StrapiListenerWidget<User>(
      key: key,
      strapiObject: strapiObject,
      generator: User.fromMap,
      builder: builder,
      sync: sync,
    );
  }
}

class _UserFields {
  _UserFields._i();

  static final _UserFields i = _UserFields._i();

  final username = StrapiLeafField("username");

  final email = StrapiLeafField("email");

  final provider = StrapiLeafField("provider");

  final resetPasswordToken = StrapiLeafField("resetPasswordToken");

  final confirmationToken = StrapiLeafField("confirmationToken");

  final confirmed = StrapiLeafField("confirmed");

  final blocked = StrapiLeafField("blocked");

  final role = StrapiModelField("role");

  final favourites = StrapiComponentField("favourites");

  final name = StrapiLeafField("name");

  final pushNotifications = StrapiCollectionField("pushNotifications");

  final employee = StrapiModelField("employee");

  final partner = StrapiModelField("partner");

  final locality = StrapiModelField("locality");

  final city = StrapiModelField("city");

  final bookings = StrapiCollectionField("bookings");

  final cart = StrapiModelField("cart");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [
      username,
      email,
      provider,
      resetPasswordToken,
      confirmationToken,
      confirmed,
      blocked,
      role,
      favourites,
      name,
      pushNotifications,
      employee,
      partner,
      locality,
      city,
      bookings,
      cart,
      createdAt,
      updatedAt,
      id
    ];
  }
}

class _UserEmptyFields {
  bool username = false;

  bool email = false;

  bool provider = false;

  bool resetPasswordToken = false;

  bool confirmationToken = false;

  bool confirmed = false;

  bool blocked = false;

  bool role = false;

  bool favourites = false;

  bool name = false;

  bool pushNotifications = false;

  bool employee = false;

  bool partner = false;

  bool locality = false;

  bool city = false;

  bool bookings = false;

  bool cart = false;
}

class Permission {
  Permission.fromID(this.id)
      : _synced = false,
        type = null,
        controller = null,
        action = null,
        enabled = null,
        policy = null,
        role = null,
        createdAt = null,
        updatedAt = null;

  Permission.fresh(
      {this.type,
      this.controller,
      this.action,
      this.enabled,
      this.policy,
      this.role})
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  Permission._synced(this.type, this.controller, this.action, this.enabled,
      this.policy, this.role, this.createdAt, this.updatedAt, this.id)
      : _synced = true;

  Permission._unsynced(this.type, this.controller, this.action, this.enabled,
      this.policy, this.role, this.createdAt, this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final String? type;

  final String? controller;

  final String? action;

  final bool? enabled;

  final String? policy;

  final Role? role;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  static final collectionName = "Permissions";

  _PermissionEmptyFields _emptyFields = _PermissionEmptyFields();

  bool get synced => _synced;
  Permission copyWIth(
          {String? type,
          String? controller,
          String? action,
          bool? enabled,
          String? policy,
          Role? role}) =>
      Permission._unsynced(
          type ?? this.type,
          controller ?? this.controller,
          action ?? this.action,
          enabled ?? this.enabled,
          policy ?? this.policy,
          role ?? this.role,
          this.createdAt,
          this.updatedAt,
          this.id);
  Permission setNull(
      {bool type = false,
      bool controller = false,
      bool action = false,
      bool enabled = false,
      bool policy = false,
      bool role = false}) {
    return Permission._unsynced(
        type ? null : this.type,
        controller ? null : this.controller,
        action ? null : this.action,
        enabled ? null : this.enabled,
        policy ? null : this.policy,
        role ? null : this.role,
        this.createdAt,
        this.updatedAt,
        this.id)
      .._emptyFields.type = type
      .._emptyFields.controller = controller
      .._emptyFields.action = action
      .._emptyFields.enabled = enabled
      .._emptyFields.policy = policy
      .._emptyFields.role = role;
  }

  static Permission fromSyncedMap(
          Map<dynamic, dynamic> map) =>
      Permission._synced(
          map["type"],
          map["controller"],
          map["action"],
          StrapiUtils.parseBool(map["enabled"]),
          map["policy"],
          StrapiUtils.objFromMap<Role>(
              map["role"], (e) => Roles._fromIDorData(e)),
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["id"]);
  static Permission? fromMap(Map<String, dynamic> map) => Permission._unsynced(
      map["type"],
      map["controller"],
      map["action"],
      StrapiUtils.parseBool(map["enabled"]),
      map["policy"],
      StrapiUtils.objFromMap<Role>(map["role"], (e) => Roles._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  Map<String, dynamic> toMap() => _toMap(level: -1);
  Map<String, dynamic> _toMap({int level = 0}) {
    final toServer = level == 0;
    return {
      if (_emptyFields.type)
        "type": null
      else if (!_emptyFields.type && type != null)
        "type": type,
      if (_emptyFields.controller)
        "controller": null
      else if (!_emptyFields.controller && controller != null)
        "controller": controller,
      if (_emptyFields.action)
        "action": null
      else if (!_emptyFields.action && action != null)
        "action": action,
      if (_emptyFields.enabled)
        "enabled": null
      else if (!_emptyFields.enabled && enabled != null)
        "enabled": enabled,
      if (_emptyFields.policy)
        "policy": null
      else if (!_emptyFields.policy && policy != null)
        "policy": policy,
      if (_emptyFields.role)
        "role": null
      else if (!_emptyFields.role && role != null)
        "role": toServer ? role?.id : role?._toMap(level: level + level),
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "id": id
    };
  }

  Future<Permission> sync() async {
    if (!synced) {
      return this;
    }
    final _id = this.id;
    if (_id is! String) {
      return this;
    }
    final response = await Permissions.findOne(_id);
    if (response is Permission) {
      return response;
    } else {
      return this;
    }
  }

  static _PermissionFields get fields => _PermissionFields.i;
  @override
  String toString() =>
      "[Strapi Collection Type Permission]\n" + _toMap().toString();
}

class Permissions {
  static const collectionName = "Permissions";

  static List<Permission?> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => Permission.fromID(id)).toList();
  }

  static Future<Permission?> findOne(
    String id,
  ) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return Permission.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<Permission>> findMultiple({int limit = 16}) async {
    final list = await StrapiCollection.findMultiple(
      collection: collectionName,
      limit: limit,
    );
    if (list.isNotEmpty) {
      return list.map((map) => Permission.fromSyncedMap(map)).toList();
    }
    return [];
  }

  static Future<Permission?> create(Permission permission) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: permission._toMap(level: 0),
    );
    if (map.isNotEmpty) {
      return Permission.fromSyncedMap(map);
    }
  }

  static Future<Permission?> update(Permission permission) async {
    final id = permission.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: permission._toMap(level: 0),
      );
      if (map.isNotEmpty) {
        return Permission.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<Permission?> delete(Permission permission) async {
    final id = permission.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return Permission.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }

  static Permission? _fromIDorData(idOrData) {
    if (idOrData is String) {
      return Permission.fromID(idOrData);
    }
    if (idOrData is Map) {
      if ((idOrData.containsKey("createdAt") ||
              idOrData.containsKey("updatedAt")) &&
          (idOrData["createdAt"] == null || idOrData["updatedAt"] == null)) {
        final id = idOrData["id"];
        return Permission.fromID(id);
      }
      return Permission.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<Permission>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    final response = await Strapi.i
        .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
    if (response.body.isNotEmpty) {
      final object = response.body.first;
      if (object is Map && object.containsKey("data")) {
        final data = object["data"];
        if (data is Map && data.containsKey(query.collectionName)) {
          final myList = data[query.collectionName];
          if (myList is List) {
            final list = <Permission>[];
            myList.forEach((e) {
              final o = _fromIDorData(e);
              if (o is Permission) {
                list.add(o);
              }
            });
            return list;
          } else if (myList is Map && myList.containsKey("id")) {
            final o = _fromIDorData(myList);
            if (o is Permission) {
              return [o];
            }
          }
        }
      }
    }
    return [];
  }

  static Widget listenerWidget({
    Key? key,
    required Permission strapiObject,
    bool sync = false,
    required Widget Function(
      BuildContext,
      Permission,
      bool,
    )
        builder,
  }) {
    return _StrapiListenerWidget<Permission>(
      key: key,
      strapiObject: strapiObject,
      generator: Permission.fromMap,
      builder: builder,
      sync: sync,
    );
  }
}

class _PermissionFields {
  _PermissionFields._i();

  static final _PermissionFields i = _PermissionFields._i();

  final type = StrapiLeafField("type");

  final controller = StrapiLeafField("controller");

  final action = StrapiLeafField("action");

  final enabled = StrapiLeafField("enabled");

  final policy = StrapiLeafField("policy");

  final role = StrapiModelField("role");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [
      type,
      controller,
      action,
      enabled,
      policy,
      role,
      createdAt,
      updatedAt,
      id
    ];
  }
}

class _PermissionEmptyFields {
  bool type = false;

  bool controller = false;

  bool action = false;

  bool enabled = false;

  bool policy = false;

  bool role = false;
}

class StrapiFile {
  StrapiFile.fromID(this.id)
      : _synced = false,
        name = null,
        alternativeText = null,
        caption = null,
        width = null,
        height = null,
        formats = null,
        hash = null,
        ext = null,
        mime = null,
        size = null,
        url = null,
        previewUrl = null,
        provider = null,
        provider_metadata = null,
        related = null,
        createdAt = null,
        updatedAt = null;

  StrapiFile.fresh(
      {this.name,
      this.alternativeText,
      this.caption,
      this.width,
      this.height,
      this.formats,
      this.hash,
      this.ext,
      this.mime,
      this.size,
      this.url,
      this.previewUrl,
      this.provider,
      this.provider_metadata,
      this.related})
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  StrapiFile._synced(
      this.name,
      this.alternativeText,
      this.caption,
      this.width,
      this.height,
      this.formats,
      this.hash,
      this.ext,
      this.mime,
      this.size,
      this.url,
      this.previewUrl,
      this.provider,
      this.provider_metadata,
      this.related,
      this.createdAt,
      this.updatedAt,
      this.id)
      : _synced = true;

  StrapiFile._unsynced(
      this.name,
      this.alternativeText,
      this.caption,
      this.width,
      this.height,
      this.formats,
      this.hash,
      this.ext,
      this.mime,
      this.size,
      this.url,
      this.previewUrl,
      this.provider,
      this.provider_metadata,
      this.related,
      this.createdAt,
      this.updatedAt,
      this.id)
      : _synced = false;

  final bool _synced;

  final String? name;

  final String? alternativeText;

  final String? caption;

  final int? width;

  final int? height;

  final Map<String, dynamic>? formats;

  final String? hash;

  final String? ext;

  final String? mime;

  final double? size;

  final String? url;

  final String? previewUrl;

  final String? provider;

  final Map<String, dynamic>? provider_metadata;

  final List<dynamic>? related;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  static final collectionName = "Files";

  _StrapiFileEmptyFields _emptyFields = _StrapiFileEmptyFields();

  bool get synced => _synced;
  StrapiFile copyWIth(
          {String? name,
          String? alternativeText,
          String? caption,
          int? width,
          int? height,
          Map<String, dynamic>? formats,
          String? hash,
          String? ext,
          String? mime,
          double? size,
          String? url,
          String? previewUrl,
          String? provider,
          Map<String, dynamic>? provider_metadata,
          List<dynamic>? related}) =>
      StrapiFile._unsynced(
          name ?? this.name,
          alternativeText ?? this.alternativeText,
          caption ?? this.caption,
          width ?? this.width,
          height ?? this.height,
          formats ?? this.formats,
          hash ?? this.hash,
          ext ?? this.ext,
          mime ?? this.mime,
          size ?? this.size,
          url ?? this.url,
          previewUrl ?? this.previewUrl,
          provider ?? this.provider,
          provider_metadata ?? this.provider_metadata,
          related ?? this.related,
          this.createdAt,
          this.updatedAt,
          this.id);
  StrapiFile setNull(
      {bool name = false,
      bool alternativeText = false,
      bool caption = false,
      bool width = false,
      bool height = false,
      bool formats = false,
      bool hash = false,
      bool ext = false,
      bool mime = false,
      bool size = false,
      bool url = false,
      bool previewUrl = false,
      bool provider = false,
      bool provider_metadata = false,
      bool related = false}) {
    return StrapiFile._unsynced(
        name ? null : this.name,
        alternativeText ? null : this.alternativeText,
        caption ? null : this.caption,
        width ? null : this.width,
        height ? null : this.height,
        formats ? null : this.formats,
        hash ? null : this.hash,
        ext ? null : this.ext,
        mime ? null : this.mime,
        size ? null : this.size,
        url ? null : this.url,
        previewUrl ? null : this.previewUrl,
        provider ? null : this.provider,
        provider_metadata ? null : this.provider_metadata,
        related ? null : this.related,
        this.createdAt,
        this.updatedAt,
        this.id)
      .._emptyFields.name = name
      .._emptyFields.alternativeText = alternativeText
      .._emptyFields.caption = caption
      .._emptyFields.width = width
      .._emptyFields.height = height
      .._emptyFields.formats = formats
      .._emptyFields.hash = hash
      .._emptyFields.ext = ext
      .._emptyFields.mime = mime
      .._emptyFields.size = size
      .._emptyFields.url = url
      .._emptyFields.previewUrl = previewUrl
      .._emptyFields.provider = provider
      .._emptyFields.provider_metadata = provider_metadata
      .._emptyFields.related = related;
  }

  static StrapiFile fromSyncedMap(Map<dynamic, dynamic> map) =>
      StrapiFile._synced(
          map["name"],
          map["alternativeText"],
          map["caption"],
          StrapiUtils.parseInt(map["width"]),
          StrapiUtils.parseInt(map["height"]),
          map["formats"],
          map["hash"],
          map["ext"],
          map["mime"],
          StrapiUtils.parseDouble(map["size"]),
          map["url"],
          map["previewUrl"],
          map["provider"],
          map["provider_metadata"],
          map["related"],
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["id"]);
  static StrapiFile? fromMap(Map<String, dynamic> map) => StrapiFile._unsynced(
      map["name"],
      map["alternativeText"],
      map["caption"],
      StrapiUtils.parseInt(map["width"]),
      StrapiUtils.parseInt(map["height"]),
      map["formats"],
      map["hash"],
      map["ext"],
      map["mime"],
      StrapiUtils.parseDouble(map["size"]),
      map["url"],
      map["previewUrl"],
      map["provider"],
      map["provider_metadata"],
      map["related"],
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  Map<String, dynamic> toMap() => _toMap(level: -1);
  Map<String, dynamic> _toMap({int level = 0}) {
    final toServer = level == 0;
    return {
      if (_emptyFields.name)
        "name": null
      else if (!_emptyFields.name && name != null)
        "name": name,
      if (_emptyFields.alternativeText)
        "alternativeText": null
      else if (!_emptyFields.alternativeText && alternativeText != null)
        "alternativeText": alternativeText,
      if (_emptyFields.caption)
        "caption": null
      else if (!_emptyFields.caption && caption != null)
        "caption": caption,
      if (_emptyFields.width)
        "width": null
      else if (!_emptyFields.width && width != null)
        "width": width,
      if (_emptyFields.height)
        "height": null
      else if (!_emptyFields.height && height != null)
        "height": height,
      if (_emptyFields.formats)
        "formats": null
      else if (!_emptyFields.formats && formats != null)
        "formats": formats,
      if (_emptyFields.hash)
        "hash": null
      else if (!_emptyFields.hash && hash != null)
        "hash": hash,
      if (_emptyFields.ext)
        "ext": null
      else if (!_emptyFields.ext && ext != null)
        "ext": ext,
      if (_emptyFields.mime)
        "mime": null
      else if (!_emptyFields.mime && mime != null)
        "mime": mime,
      if (_emptyFields.size)
        "size": null
      else if (!_emptyFields.size && size != null)
        "size": size,
      if (_emptyFields.url)
        "url": null
      else if (!_emptyFields.url && url != null)
        "url": url,
      if (_emptyFields.previewUrl)
        "previewUrl": null
      else if (!_emptyFields.previewUrl && previewUrl != null)
        "previewUrl": previewUrl,
      if (_emptyFields.provider)
        "provider": null
      else if (!_emptyFields.provider && provider != null)
        "provider": provider,
      if (_emptyFields.provider_metadata)
        "provider_metadata": null
      else if (!_emptyFields.provider_metadata && provider_metadata != null)
        "provider_metadata": provider_metadata,
      if (_emptyFields.related)
        "related": []
      else if (!_emptyFields.related && related != null)
        "related": related,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "id": id
    };
  }

  Future<StrapiFile> sync() async {
    if (!synced) {
      return this;
    }
    final _id = this.id;
    if (_id is! String) {
      return this;
    }
    final response = await StrapiFiles.findOne(_id);
    if (response is StrapiFile) {
      return response;
    } else {
      return this;
    }
  }

  static _StrapiFileFields get fields => _StrapiFileFields.i;
  @override
  String toString() =>
      "[Strapi Collection Type StrapiFile]\n" + _toMap().toString();
}

class StrapiFiles {
  static const collectionName = "Files";

  static List<StrapiFile?> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => StrapiFile.fromID(id)).toList();
  }

  static Future<StrapiFile?> findOne(
    String id,
  ) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return StrapiFile.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<StrapiFile>> findMultiple({int limit = 16}) async {
    final list = await StrapiCollection.findMultiple(
      collection: collectionName,
      limit: limit,
    );
    if (list.isNotEmpty) {
      return list.map((map) => StrapiFile.fromSyncedMap(map)).toList();
    }
    return [];
  }

  static Future<StrapiFile?> create(StrapiFile strapiFile) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: strapiFile._toMap(level: 0),
    );
    if (map.isNotEmpty) {
      return StrapiFile.fromSyncedMap(map);
    }
  }

  static Future<StrapiFile?> update(StrapiFile strapiFile) async {
    final id = strapiFile.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: strapiFile._toMap(level: 0),
      );
      if (map.isNotEmpty) {
        return StrapiFile.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<StrapiFile?> delete(StrapiFile strapiFile) async {
    final id = strapiFile.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return StrapiFile.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }

  static StrapiFile? _fromIDorData(idOrData) {
    if (idOrData is String) {
      return StrapiFile.fromID(idOrData);
    }
    if (idOrData is Map) {
      if ((idOrData.containsKey("createdAt") ||
              idOrData.containsKey("updatedAt")) &&
          (idOrData["createdAt"] == null || idOrData["updatedAt"] == null)) {
        final id = idOrData["id"];
        return StrapiFile.fromID(id);
      }
      return StrapiFile.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<StrapiFile>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    final response = await Strapi.i
        .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
    if (response.body.isNotEmpty) {
      final object = response.body.first;
      if (object is Map && object.containsKey("data")) {
        final data = object["data"];
        if (data is Map && data.containsKey(query.collectionName)) {
          final myList = data[query.collectionName];
          if (myList is List) {
            final list = <StrapiFile>[];
            myList.forEach((e) {
              final o = _fromIDorData(e);
              if (o is StrapiFile) {
                list.add(o);
              }
            });
            return list;
          } else if (myList is Map && myList.containsKey("id")) {
            final o = _fromIDorData(myList);
            if (o is StrapiFile) {
              return [o];
            }
          }
        }
      }
    }
    return [];
  }

  static Widget listenerWidget({
    Key? key,
    required StrapiFile strapiObject,
    bool sync = false,
    required Widget Function(
      BuildContext,
      StrapiFile,
      bool,
    )
        builder,
  }) {
    return _StrapiListenerWidget<StrapiFile>(
      key: key,
      strapiObject: strapiObject,
      generator: StrapiFile.fromMap,
      builder: builder,
      sync: sync,
    );
  }
}

class _StrapiFileFields {
  _StrapiFileFields._i();

  static final _StrapiFileFields i = _StrapiFileFields._i();

  final name = StrapiLeafField("name");

  final alternativeText = StrapiLeafField("alternativeText");

  final caption = StrapiLeafField("caption");

  final width = StrapiLeafField("width");

  final height = StrapiLeafField("height");

  final formats = StrapiLeafField("formats");

  final hash = StrapiLeafField("hash");

  final ext = StrapiLeafField("ext");

  final mime = StrapiLeafField("mime");

  final size = StrapiLeafField("size");

  final url = StrapiLeafField("url");

  final previewUrl = StrapiLeafField("previewUrl");

  final provider = StrapiLeafField("provider");

  final provider_metadata = StrapiLeafField("provider_metadata");

  final related = StrapiCollectionField("related");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [
      name,
      alternativeText,
      caption,
      width,
      height,
      formats,
      hash,
      ext,
      mime,
      size,
      url,
      previewUrl,
      provider,
      provider_metadata,
      related,
      createdAt,
      updatedAt,
      id
    ];
  }
}

class _StrapiFileEmptyFields {
  bool name = false;

  bool alternativeText = false;

  bool caption = false;

  bool width = false;

  bool height = false;

  bool formats = false;

  bool hash = false;

  bool ext = false;

  bool mime = false;

  bool size = false;

  bool url = false;

  bool previewUrl = false;

  bool provider = false;

  bool provider_metadata = false;

  bool related = false;
}

class ProductCategory {
  ProductCategory._unsynced(this.mine, this.name, this.enabled, this.image,
      this.description, this.catalogueItems);

  ProductCategory(
      {this.mine,
      this.name,
      this.enabled,
      this.image,
      this.description,
      this.catalogueItems});

  final double? mine;

  final String? name;

  final bool? enabled;

  final List<StrapiFile>? image;

  final String? description;

  final List<Product>? catalogueItems;

  static ProductCategory? fromMap(Map<String, dynamic> map) =>
      ProductCategory._unsynced(
          StrapiUtils.parseDouble(map["mine"]),
          map["name"],
          StrapiUtils.parseBool(map["enabled"]),
          StrapiUtils.objFromListOfMap<StrapiFile>(
              map["image"], (e) => StrapiFiles._fromIDorData(e)),
          map["description"],
          StrapiUtils.objFromListOfMap<Product>(
              map["catalogueItems"], (e) => Product.fromMap(e)));
  Map<String, dynamic> toMap() => _toMap(level: -1);
  Map<String, dynamic> _toMap({int level = 0}) {
    final toServer = level == 0;
    return {
      "mine": mine,
      "name": name,
      "enabled": enabled,
      "image": image
          ?.map((e) => toServer ? e.id : e._toMap(level: level + level))
          .toList(),
      "description": description,
      "catalogueItems":
          catalogueItems?.map((e) => e._toMap(level: level + level)).toList()
    };
  }

  static _ProductCategoryFields get fields => _ProductCategoryFields.i;
  @override
  String toString() =>
      "[Strapi Component Type ProductCategory]: \n" + _toMap().toString();
}

class _ProductCategoryFields {
  _ProductCategoryFields._i();

  static final _ProductCategoryFields i = _ProductCategoryFields._i();

  final mine = StrapiLeafField("mine");

  final name = StrapiLeafField("name");

  final enabled = StrapiLeafField("enabled");

  final image = StrapiCollectionField("image");

  final description = StrapiLeafField("description");

  final catalogueItems = StrapiComponentField("catalogueItems");

  String call() {
    return "{mine,name,enabled,image{id},description,catalogueItems${_ProductFields.i()}}";
  }
}

class _ProductCategoryEmptyFields {
  bool mine = false;

  bool name = false;

  bool enabled = false;

  bool image = false;

  bool description = false;

  bool catalogueItems = false;
}

class Product {
  Product._unsynced(this.price, this.duration, this.enabled, this.nameOverride,
      this.descriptionOverride, this.imageOverride, this.productReference);

  Product(
      {this.price,
      this.duration,
      this.enabled,
      this.nameOverride,
      this.descriptionOverride,
      this.imageOverride,
      this.productReference});

  final double? price;

  final int? duration;

  final bool? enabled;

  final String? nameOverride;

  final String? descriptionOverride;

  final List<StrapiFile>? imageOverride;

  final MasterProduct? productReference;

  static Product? fromMap(Map<String, dynamic> map) => Product._unsynced(
      StrapiUtils.parseDouble(map["price"]),
      StrapiUtils.parseInt(map["duration"]),
      StrapiUtils.parseBool(map["enabled"]),
      map["nameOverride"],
      map["descriptionOverride"],
      StrapiUtils.objFromListOfMap<StrapiFile>(
          map["imageOverride"], (e) => StrapiFiles._fromIDorData(e)),
      StrapiUtils.objFromMap<MasterProduct>(
          map["productReference"], (e) => MasterProducts._fromIDorData(e)));
  Map<String, dynamic> toMap() => _toMap(level: -1);
  Map<String, dynamic> _toMap({int level = 0}) {
    final toServer = level == 0;
    return {
      "price": price,
      "duration": duration,
      "enabled": enabled,
      "nameOverride": nameOverride,
      "descriptionOverride": descriptionOverride,
      "imageOverride": imageOverride
          ?.map((e) => toServer ? e.id : e._toMap(level: level + level))
          .toList(),
      "productReference": toServer
          ? productReference?.id
          : productReference?._toMap(level: level + level)
    };
  }

  static _ProductFields get fields => _ProductFields.i;
  @override
  String toString() =>
      "[Strapi Component Type Product]: \n" + _toMap().toString();
}

class _ProductFields {
  _ProductFields._i();

  static final _ProductFields i = _ProductFields._i();

  final price = StrapiLeafField("price");

  final duration = StrapiLeafField("duration");

  final enabled = StrapiLeafField("enabled");

  final nameOverride = StrapiLeafField("nameOverride");

  final descriptionOverride = StrapiLeafField("descriptionOverride");

  final imageOverride = StrapiCollectionField("imageOverride");

  final productReference = StrapiModelField("productReference");

  String call() {
    return "{price,duration,enabled,nameOverride,descriptionOverride,imageOverride{id},productReference{id}}";
  }
}

class _ProductEmptyFields {
  bool price = false;

  bool duration = false;

  bool enabled = false;

  bool nameOverride = false;

  bool descriptionOverride = false;

  bool imageOverride = false;

  bool productReference = false;
}

class Address {
  Address._unsynced(this.address, this.coordinates, this.locality);

  Address({this.address, this.coordinates, this.locality});

  final String? address;

  final Coordinates? coordinates;

  final Locality? locality;

  static Address? fromMap(Map<String, dynamic> map) => Address._unsynced(
      map["address"],
      StrapiUtils.objFromMap<Coordinates>(
          map["coordinates"], (e) => Coordinates.fromMap(e)),
      StrapiUtils.objFromMap<Locality>(
          map["locality"], (e) => Localities._fromIDorData(e)));
  Map<String, dynamic> toMap() => _toMap(level: -1);
  Map<String, dynamic> _toMap({int level = 0}) {
    final toServer = level == 0;
    return {
      "address": address,
      "coordinates": coordinates?._toMap(level: level + level),
      "locality":
          toServer ? locality?.id : locality?._toMap(level: level + level)
    };
  }

  static _AddressFields get fields => _AddressFields.i;
  @override
  String toString() =>
      "[Strapi Component Type Address]: \n" + _toMap().toString();
}

class _AddressFields {
  _AddressFields._i();

  static final _AddressFields i = _AddressFields._i();

  final address = StrapiLeafField("address");

  final coordinates = StrapiComponentField("coordinates");

  final locality = StrapiModelField("locality");

  String call() {
    return "{address,coordinates${_CoordinatesFields.i()},locality{id}}";
  }
}

class _AddressEmptyFields {
  bool address = false;

  bool coordinates = false;

  bool locality = false;
}

class Package {
  Package._unsynced(this.name, this.startDate, this.endDate, this.enabled,
      this.priceBefore, this.priceAfter);

  Package(
      {this.name,
      this.startDate,
      this.endDate,
      this.enabled,
      this.priceBefore,
      this.priceAfter});

  final String? name;

  final DateTime? startDate;

  final DateTime? endDate;

  final bool? enabled;

  final double? priceBefore;

  final double? priceAfter;

  static Package? fromMap(Map<String, dynamic> map) => Package._unsynced(
      map["name"],
      StrapiUtils.parseDateTime(map["startDate"]),
      StrapiUtils.parseDateTime(map["endDate"]),
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.parseDouble(map["priceBefore"]),
      StrapiUtils.parseDouble(map["priceAfter"]));
  Map<String, dynamic> toMap() => _toMap(level: -1);
  Map<String, dynamic> _toMap({int level = 0}) {
    final toServer = level == 0;
    return {
      "name": name,
      "startDate": startDate?.toIso8601String(),
      "endDate": endDate?.toIso8601String(),
      "enabled": enabled,
      "priceBefore": priceBefore,
      "priceAfter": priceAfter
    };
  }

  static _PackageFields get fields => _PackageFields.i;
  @override
  String toString() =>
      "[Strapi Component Type Package]: \n" + _toMap().toString();
}

class _PackageFields {
  _PackageFields._i();

  static final _PackageFields i = _PackageFields._i();

  final name = StrapiLeafField("name");

  final startDate = StrapiLeafField("startDate");

  final endDate = StrapiLeafField("endDate");

  final enabled = StrapiLeafField("enabled");

  final priceBefore = StrapiLeafField("priceBefore");

  final priceAfter = StrapiLeafField("priceAfter");

  String call() {
    return "{name,startDate,endDate,enabled,priceBefore,priceAfter}";
  }
}

class _PackageEmptyFields {
  bool name = false;

  bool startDate = false;

  bool endDate = false;

  bool enabled = false;

  bool priceBefore = false;

  bool priceAfter = false;
}

class Timing {
  Timing._unsynced(this.from, this.to, this.enabled);

  Timing({this.from, this.to, this.enabled});

  final DateTime? from;

  final DateTime? to;

  final bool? enabled;

  static Timing? fromMap(Map<String, dynamic> map) => Timing._unsynced(
      StrapiUtils.parseDateTime(map["from"]),
      StrapiUtils.parseDateTime(map["to"]),
      StrapiUtils.parseBool(map["enabled"]));
  Map<String, dynamic> toMap() => _toMap(level: -1);
  Map<String, dynamic> _toMap({int level = 0}) {
    final toServer = level == 0;
    return {
      "from": from?.toIso8601String(),
      "to": to?.toIso8601String(),
      "enabled": enabled
    };
  }

  static _TimingFields get fields => _TimingFields.i;
  @override
  String toString() =>
      "[Strapi Component Type Timing]: \n" + _toMap().toString();
}

class _TimingFields {
  _TimingFields._i();

  static final _TimingFields i = _TimingFields._i();

  final from = StrapiLeafField("from");

  final to = StrapiLeafField("to");

  final enabled = StrapiLeafField("enabled");

  String call() {
    return "{from,to,enabled}";
  }
}

class _TimingEmptyFields {
  bool from = false;

  bool to = false;

  bool enabled = false;
}

enum DayName { sunday, monday, tuesday, wednesday, thursday, friday, saturday }

class DayTiming {
  DayTiming._unsynced(this.timings, this.dayName);

  DayTiming({this.timings, this.dayName});

  final List<Timing>? timings;

  final DayName? dayName;

  static DayTiming? fromMap(Map<String, dynamic> map) => DayTiming._unsynced(
      StrapiUtils.objFromListOfMap<Timing>(
          map["timings"], (e) => Timing.fromMap(e)),
      StrapiUtils.toEnum<DayName>(DayName.values, map["dayName"]));
  Map<String, dynamic> toMap() => _toMap(level: -1);
  Map<String, dynamic> _toMap({int level = 0}) {
    final toServer = level == 0;
    return {
      "timings": timings?.map((e) => e._toMap(level: level + level)).toList(),
      "dayName": StrapiUtils.enumToString(dayName)
    };
  }

  static _DayTimingFields get fields => _DayTimingFields.i;
  @override
  String toString() =>
      "[Strapi Component Type DayTiming]: \n" + _toMap().toString();
}

class _DayTimingFields {
  _DayTimingFields._i();

  static final _DayTimingFields i = _DayTimingFields._i();

  final timings = StrapiComponentField("timings");

  final dayName = StrapiLeafField("dayName");

  String call() {
    return "{timings${_TimingFields.i()},dayName}";
  }
}

class _DayTimingEmptyFields {
  bool timings = false;

  bool dayName = false;
}

class Favourites {
  Favourites._unsynced(this.business, this.addedOn);

  Favourites({this.business, this.addedOn});

  final Business? business;

  final DateTime? addedOn;

  static Favourites? fromMap(Map<String, dynamic> map) => Favourites._unsynced(
      StrapiUtils.objFromMap<Business>(
          map["business"], (e) => Businesses._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["addedOn"]));
  Map<String, dynamic> toMap() => _toMap(level: -1);
  Map<String, dynamic> _toMap({int level = 0}) {
    final toServer = level == 0;
    return {
      "business":
          toServer ? business?.id : business?._toMap(level: level + level),
      "addedOn": addedOn?.toIso8601String()
    };
  }

  static _FavouritesFields get fields => _FavouritesFields.i;
  @override
  String toString() =>
      "[Strapi Component Type Favourites]: \n" + _toMap().toString();
}

class _FavouritesFields {
  _FavouritesFields._i();

  static final _FavouritesFields i = _FavouritesFields._i();

  final business = StrapiModelField("business");

  final addedOn = StrapiLeafField("addedOn");

  String call() {
    return "{business{id},addedOn}";
  }
}

class _FavouritesEmptyFields {
  bool business = false;

  bool addedOn = false;
}

class Holiday {
  Holiday._unsynced(this.date, this.nameOfTheHoliday);

  Holiday({this.date, this.nameOfTheHoliday});

  final DateTime? date;

  final String? nameOfTheHoliday;

  static Holiday? fromMap(Map<String, dynamic> map) => Holiday._unsynced(
      StrapiUtils.parseDateTime(map["date"]), map["nameOfTheHoliday"]);
  Map<String, dynamic> toMap() => _toMap(level: -1);
  Map<String, dynamic> _toMap({int level = 0}) {
    final toServer = level == 0;
    return {
      "date": date?.toIso8601String(),
      "nameOfTheHoliday": nameOfTheHoliday
    };
  }

  static _HolidayFields get fields => _HolidayFields.i;
  @override
  String toString() =>
      "[Strapi Component Type Holiday]: \n" + _toMap().toString();
}

class _HolidayFields {
  _HolidayFields._i();

  static final _HolidayFields i = _HolidayFields._i();

  final date = StrapiLeafField("date");

  final nameOfTheHoliday = StrapiLeafField("nameOfTheHoliday");

  String call() {
    return "{date,nameOfTheHoliday}";
  }
}

class _HolidayEmptyFields {
  bool date = false;

  bool nameOfTheHoliday = false;
}

class Coordinates {
  Coordinates._unsynced(this.latitude, this.longitude);

  Coordinates({this.latitude, this.longitude});

  final double? latitude;

  final double? longitude;

  static Coordinates? fromMap(Map<String, dynamic> map) =>
      Coordinates._unsynced(StrapiUtils.parseDouble(map["latitude"]),
          StrapiUtils.parseDouble(map["longitude"]));
  Map<String, dynamic> toMap() => _toMap(level: -1);
  Map<String, dynamic> _toMap({int level = 0}) {
    final toServer = level == 0;
    return {"latitude": latitude, "longitude": longitude};
  }

  static _CoordinatesFields get fields => _CoordinatesFields.i;
  @override
  String toString() =>
      "[Strapi Component Type Coordinates]: \n" + _toMap().toString();
}

class _CoordinatesFields {
  _CoordinatesFields._i();

  static final _CoordinatesFields i = _CoordinatesFields._i();

  final latitude = StrapiLeafField("latitude");

  final longitude = StrapiLeafField("longitude");

  String call() {
    return "{latitude,longitude}";
  }
}

class _CoordinatesEmptyFields {
  bool latitude = false;

  bool longitude = false;
}
