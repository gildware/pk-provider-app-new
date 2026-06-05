
import 'dart:convert';

EarningDataModel earningDataModelFromJson(String str) => EarningDataModel.fromJson(json.decode(str));

String earningDataModelToJson(EarningDataModel data) => json.encode(data.toJson());

class EarningDataModel {
  EarningData? thisWeek;
  EarningData? thisMonth;
  EarningData? thisYear;

  EarningDataModel({
    this.thisWeek,
    this.thisMonth,
    this.thisYear,
  });

  factory EarningDataModel.fromJson(Map<String, dynamic> json) => EarningDataModel(
    thisWeek: json["this_week"] == null ? null : EarningData.fromJson(json["this_week"]),
    thisMonth: json["this_month"] == null ? null : EarningData.fromJson(json["this_month"]),
    thisYear: json["this_year"] == null ? null : EarningData.fromJson(json["this_year"]),
  );

  Map<String, dynamic> toJson() => {
    "this_week": thisWeek?.toJson(),
    "this_month": thisMonth?.toJson(),
    "this_year": thisYear?.toJson(),
  };
}

class EarningData {
  double total;
  double change;

  EarningData({
    required this.total,
    required this.change,
  });

  factory EarningData.fromJson(Map<String, dynamic> json) => EarningData(
    total: double.tryParse('${json["total"]}') ?? 0,
    change: double.tryParse('${json["change"]}') ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "change": change,
  };
}
