import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:bmi_calculator/widget_utils.dart';
import 'package:bmi_calculator/models/gender.dart';

double circleSize(BuildContext context) => screenAwareSize(80.0, context);
const double defaultGenderAngle = math.pi / 4;

const Map<Gender, double> genderAngles = {
  Gender.female: -defaultGenderAngle,
  Gender.other: 0,
  Gender.male: defaultGenderAngle,
};
