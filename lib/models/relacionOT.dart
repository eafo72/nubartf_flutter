class FullOT {
  List<Item2> itemsOT = [];

  //constructor vacio
  FullOT();

  FullOT.fromJsonList(List<dynamic> jsonList) {
    for (var item in jsonList) {
      final singleItem = Item2.fromJsonMap(item);
        itemsOT.add(singleItem);
    }
  }
}

class Item2 {
  int? relacion_ot_id;
  int? relacion_ot_tienda_id;
  int? relacion_ot_objetivo_id;
  
  Item2({
    this.relacion_ot_id,
    this.relacion_ot_tienda_id,
    this.relacion_ot_objetivo_id
  });

  Item2.fromJsonMap(Map<String, dynamic> json) {
    relacion_ot_id = int.parse(json['relacion_ot_id']);
    relacion_ot_tienda_id = int.parse(json['relacion_ot_tienda_id']);
    relacion_ot_objetivo_id = int.parse(json['relacion_ot_objetivo_id']);
  }
}