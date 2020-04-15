import 'package:meta/meta.dart';
import 'package:flutter/material.dart';

enum Flavor { FREE, PAID }

class FlavorValues {
  FlavorValues({@required this.hasAds});

  final bool hasAds;
}

class FlavorConfig {
  final Flavor flavor;
  final FlavorValues values;
  static FlavorConfig _instance;

  factory FlavorConfig(
      {@required Flavor flavor, @required FlavorValues values}) {
    _instance ??= FlavorConfig._internal(flavor, values);
    return _instance;
  }

  FlavorConfig._internal(this.flavor, this.values);
  static FlavorConfig get instance {return _instance;}
  static bool isFree() => _instance.flavor == Flavor.FREE;
  static bool isPaid() => _instance.flavor == Flavor.PAID;
}
