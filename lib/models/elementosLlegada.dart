class FullElementos {
  List<Item5> itemsElementos = [];

  //constructor vacio
  FullElementos();

  FullElementos.fromJsonList(List<dynamic> jsonList) {
    for (var item in jsonList) {
      final singleItem = Item5.fromJsonMap(item);
        itemsElementos.add(singleItem);
    }
  }
}

class Item5 {
  int?    id;
  int?    elemento_id;
  String? nombre_elemento;
  String? script_elemento;
  String? name;
  String? tipo_entrega;
    
  Item5({
    this.id,
    this.elemento_id,
    this.nombre_elemento,
    this.script_elemento,
    this.name,
    this.tipo_entrega
  });

  Item5.fromJsonMap(Map<String, dynamic> json) {
    id = int.parse(json['elemento_id']);
    elemento_id = int.parse(json['elemento_id']);
    nombre_elemento = json['nombre_elemento'];
    script_elemento = json['script_elemento'];
    name = json['name'];
    tipo_entrega = json['tipo_entrega'];
  }
}