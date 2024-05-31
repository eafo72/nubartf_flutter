class FullEO {
  List<Item4> itemsEO = [];

  //constructor vacio
  FullEO();

  FullEO.fromJsonList(List<dynamic> jsonList) {
    for (var item in jsonList) {
      final singleItem = Item4.fromJsonMap(item);
        itemsEO.add(singleItem);
    }
  }
}

class Item4 {
  int? relacioneoid;
  int? relacioneoobjetivoid;
  int? relacioneoelementosid;
  int? ordenaparicion;
  
  Item4({
    this.relacioneoid,
    this.relacioneoobjetivoid,
    this.relacioneoelementosid,
    this.ordenaparicion
  });

  Item4.fromJsonMap(Map<String, dynamic> json) {
    relacioneoid = int.parse(json['relacion_eo_id']);
    relacioneoobjetivoid = int.parse(json['relacion_eo_objetivo_id']);
    relacioneoelementosid = int.parse(json['relacion_eo_elementos_id']);
    ordenaparicion = int.parse(json['orden_aparicion']);
  }
}