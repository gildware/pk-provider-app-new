import 'dart:convert';

class WithdrawModel {
  WithdrawModel({
    this.message, required this.withdrawalMethods,
  });

  String? message;
  List<WithdrawalMethod>? withdrawalMethods;

  factory WithdrawModel.fromRawJson(String str) => WithdrawModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory WithdrawModel.fromJson(Map<String, dynamic> json) => WithdrawModel(
    withdrawalMethods: List<WithdrawalMethod>.from(json["content"]['data'].map((x) => WithdrawalMethod.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "withdrawal_methods": List<dynamic>.from(withdrawalMethods!.map((x) => x.toJson())),
  };
}

class WithdrawalMethod {
  WithdrawalMethod({
    this.id,
    this.methodName,
    this.methodFields,
    this.isDefault,
    this.isActive
  });

  String? id;
  String? methodName;
  List<MethodField>? methodFields;
  int? isDefault;
  int? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory WithdrawalMethod.fromRawJson(String str) => WithdrawalMethod.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory WithdrawalMethod.fromJson(Map<String, dynamic> json) => WithdrawalMethod(
    id: json["id"]?.toString(),
    methodName: json["method_name"]?.toString(),
    methodFields: json["method_fields"] is List
        ? List<MethodField>.from(
            (json["method_fields"] as List).map((x) => MethodField.fromJson(Map<String, dynamic>.from(x))),
          )
        : [],
    isDefault: _parseFlagInt(json["is_default"]),
    isActive: _parseFlagInt(json["is_active"]),
  );

  bool get isActiveForSelection => isActive == 1 || isActive == null;

  Map<String, dynamic> toJson() => {
    "id": id,
    "method_name": methodName,
    "method_fields": List<dynamic>.from(methodFields!.map((x) => x.toJson())),
    "is_default": isDefault,
    "is_active": isActive,
  };
}

int? _parseFlagInt(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value ? 1 : 0;
  if (value is num) return value.toInt();
  final normalized = value.toString().trim().toLowerCase();
  if (normalized == 'true' || normalized == '1') return 1;
  if (normalized == 'false' || normalized == '0') return 0;
  return int.tryParse(normalized);
}

class MethodField {
  String? inputType;
  String? inputName;
  String? placeholder;
  int? isRequired;

  MethodField(
      {this.inputType, this.inputName, this.placeholder, this.isRequired});

  MethodField.fromJson(Map<String, dynamic> json) {
    inputType = json['input_type'];
    inputName = json['input_name'];
    placeholder = json['placeholder'];
    isRequired = int.tryParse(json['is_required'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['input_type'] = inputType;
    data['input_name'] = inputName;
    data['placeholder'] = placeholder;
    data['is_required'] = isRequired;
    return data;
  }
}
