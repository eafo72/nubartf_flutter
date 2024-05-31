class FullOM {
  List<Item2> itemsOM = [];

  //constructor vacio
  FullOM();

  FullOM.fromJsonList(List<dynamic> jsonList) {
    for (var item in jsonList) {
      final singleItem = Item2.fromJsonMap(item);
        itemsOM.add(singleItem);
    }
  }
}

class Item2 {
  int? relacion_om_id;
  int? relacion_om_mtc_id;
  int? relacion_om_objetivo_id;
  
  Item2({
    this.relacion_om_id,
    this.relacion_om_mtc_id,
    this.relacion_om_objetivo_id
  });

  Item2.fromJsonMap(Map<String, dynamic> json) {
    relacion_om_id = int.parse(json['relacion_om_id']);
    relacion_om_mtc_id = int.parse(json['relacion_om_mtc_id']);
    relacion_om_objetivo_id = int.parse(json['relacion_om_objetivo_id']);
  }
}