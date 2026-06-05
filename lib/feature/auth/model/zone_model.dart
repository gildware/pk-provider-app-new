class ZoneData {
  String? id;
  String? name;
  String? description;
  int depth = 0;
  bool isParent = false;

  ZoneData({
    this.id,
    this.name,
    this.description,
    this.depth = 0,
    this.isParent = false,
  });

  bool get hasDescription => description != null && description!.trim().isNotEmpty;

  ZoneData.fromJson(Map<String, dynamic> json)
      : depth = json['depth'] is int ? json['depth'] as int : 0,
        isParent = json['is_parent'] == true {
    id = json['id']?.toString();
    name = json['name']?.toString();
    description = json['description']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['depth'] = depth;
    data['is_parent'] = isParent;
    return data;
  }
}
