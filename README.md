![header](https://raw.githubusercontent.com/ondbyte/super_strapi/master/image.png)

A Strapi library for Dart developers. with which you can generate dart classes from strapi models and make basic find, findOne, count.. etc queries, as well as complex graph queries.

# Usage

## Add as a dev dependency
in your pubspec.yaml
```yaml
dev_dependencies:
  super_strapi: <latest_version>
```

## generating dart classes from strapi models
If you have a strapi project at `/some/strapi/project/path`, run the super_strapi like this
```console
flutter pub run super_strapi -i /some/strapi/project/path/ -o /output/folder/path
```
> 📝 NOTE: if you need to use the output with plain dart project use `dart pub`
```console
dart pub run super_strapi -i /some/strapi/project/path/ -o /output/folder/path
```
> 📝 NOTE: as not all packages from pub support nullsafety this command should be accompanied with `--no-sound-null-safety` flag
```console
dart pub run --no-sound-null-safety super_strapi -i /some/strapi/project/path/ -o /output/folder/path
```
Above command will generate dart/flutter project which will contain all the data models and helper classes.

If you have a collection type called `Restaurant` in your strapi project the generated dart project will have a `Restaurant` class, a `Restaurants` class with all helper methods so you could do find multiple with
```dart
final restaurants = await Restaurants.findMultiple();
```
or find one restaraunt with
```dart
final restaurant = await Restaurants.findOne("<id of the object>");
```

### creating new restaurant
```dart
final newRestaurant = Restaurant.fresh(/* set all the resturant properties*/);
final createdRestaurant = await Restaurants.create(newRestaurant);
```
### updating a existing restaurant
```dart
///use copyWith methods to change/update values
final newRestaurant = oldResturant.copyWith(/* set all the resturant properties*/);
///or to remove a value i.e set it null use setNull method, use this method to remove a value setting null with copyWith method doesn't update it to null on the server
final newRestaurant = oldResturant.setNull(/* set properties null*/);
final updatedRestaurant = await Restaurants.update(newRestaurant);
```

# Graph queries
Complex graph queries is supported in the package [simple_strapi](https://github.com/ondbyte/simple_strapi#complex-graph-queries), but they're still complex, super strapi comes handy in doing complex graph queries, graph queries are always about stating required fields in the response.

if you a collection named `Restaurant` with references to some other collections named `Country`, and you need to query the restaurants which belongs to country named `india`, what you can do is
```dart
final query = StrapiCollectionQuery(
    cllectionName: Restaurant.collectionName,
    requiredFields: Restaurant.fields(),
);
//now filter the country
//use whereModelField if the reference is a single reference
query.whereModelField(
    field: Restaurant.fields.country,
    query: StrapiModelQuery(
        requiredFields:Country.fields(),
    )..whereField(
        field: Country.fields.name,
        query: StrapiFieldQuery.equalTo,
        value:"india"
    )
);
// execute the query
final restaurants = await Restaurants.executeQuery(query);
```
PS: more details will be added to this documentation in coming days