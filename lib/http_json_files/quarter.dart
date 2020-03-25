import 'package:json_annotation/json_annotation.dart';

part 'quarter.g.dart';

/* To delete errors about quarter.g.dart you need to create this file by using
 - one time code generation => "flutter pub run build_runner build" in project root
 - generating code continuously => "flutter pub run build_runner watch" in project root,
    it will automatically build necessary files when needed depending on file changes.
 */

@JsonSerializable()
class Quarter{

  String startTime;
  String endTime;
  double temp;

  /// Constructor
  Quarter(this.startTime, this.endTime, this.temp);

  /// A necessary factory constructor for creating a new Quarter instance
  /// from a map. Pass the map to the generated `_$QuarterFromJson()` constructor.
  /// The constructor is named after the source class, in this case, Quarter.
  factory Quarter.fromJson(Map<String, dynamic> json) => _$QuarterFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$QuarterToJson`.
  Map<String, dynamic> toJson() => _$QuarterToJson(this);
}