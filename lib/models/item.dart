class Item {
  int? id;
  String? nom;

  Item(Map<String, dynamic> map) {
    nom = map['nom'] ?? "";
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
    };
  }
}
