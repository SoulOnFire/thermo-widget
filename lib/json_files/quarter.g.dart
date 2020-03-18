// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quarter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Quarter _$QuarterFromJson(Map<String, dynamic> json) {
  return Quarter(
    json['startTime'] as String,
    json['endTime'] as String,
    (json['temp'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$QuarterToJson(Quarter instance) => <String, dynamic>{
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'temp': instance.temp,
    };
