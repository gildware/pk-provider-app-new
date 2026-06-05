class ZoneTreeNode {
  final String id;
  final String name;
  final String description;
  final List<ZoneTreeNode> children;

  const ZoneTreeNode({
    required this.id,
    required this.name,
    this.description = '',
    this.children = const [],
  });

  bool get isParent => children.isNotEmpty;

  factory ZoneTreeNode.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'];
    final childList = rawChildren is List
        ? rawChildren
            .map((e) => ZoneTreeNode.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
        : <ZoneTreeNode>[];

    return ZoneTreeNode(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString().trim() ?? '',
      children: childList,
    );
  }

  /// This zone and every descendant id (parent + all children).
  List<String> collectSubtreeZoneIds() {
    if (id.isEmpty) return [];
    if (!isParent) return [id];
    return [
      id,
      ...children.expand((c) => c.collectSubtreeZoneIds()),
    ];
  }

  List<String> collectLeafIds() {
    if (!isParent) {
      return id.isEmpty ? [] : [id];
    }
    return children.expand((c) => c.collectLeafIds()).toList();
  }

  List<ZoneTreeNode> collectLeafNodes() {
    if (!isParent) {
      return id.isEmpty ? [] : [this];
    }
    return children.expand((c) => c.collectLeafNodes()).toList();
  }
}
