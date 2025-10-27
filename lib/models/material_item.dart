class MaterialItem {
  String id;
  String name;
  double cost; // per unit
  double quantity;
  String? unit; // e.g., ft, pcs

  MaterialItem({
    required this.id,
    required this.name,
    required this.cost,
    this.quantity = 1,
    this.unit,
  });
}
