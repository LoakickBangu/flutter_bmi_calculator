import 'package:flutter/material.dart';
import 'package:bmi_calculator/input_page/gender/gender_card.dart';
import 'package:bmi_calculator/input_page/weight/weight_card.dart';
import 'package:bmi_calculator/widget_utils.dart' show screenAwareSize;
import 'package:bmi_calculator/input_page/height/height_card.dart';
import 'package:bmi_calculator/input_page/input_page_styles.dart';
import 'package:bmi_calculator/app_bar.dart';
import 'package:bmi_calculator/models/gender.dart';
import 'package:bmi_calculator/input_page/input_summary_card.dart';

class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  Gender gender = Gender.other;
  int height = 170;
  int weight = 70;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: BmiAppBar(),
        preferredSize: Size.fromHeight(appBarHeight(context)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InputSummaryCard(gender: gender, height: height, weight: weight),
          Expanded(child: _buildCards(context)),
          _buildBottom(context)
        ],
      ),
    );
  }

  Widget _buildBottom(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: screenAwareSize(108.0, context),
      width: double.infinity,
      child: Switch(
        value: true,
        onChanged: (val) {},
      ),
    );
  }

  Widget _buildCards(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              Expanded(
                child: GenderCard(
                  gender: gender,
                  onChanged: (val) => setState(() => gender = val),
                ),
              ),
              Expanded(
                  child: WeightCard(
                weight: weight,
                onChanged: (val) => setState(() => weight = val),
              )),
            ],
          ),
        ),
        Expanded(
          child: HeightCard(
            height: height,
            onChanged: (val) => setState(() => height = val),
          ),
        ),
      ],
    );
  }
}
