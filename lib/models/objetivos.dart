class FullObjetivos {
  List<Item3> itemsObjetivos = [];

  //constructor vacio
  FullObjetivos();

  FullObjetivos.fromJsonList(List<dynamic> jsonList) {
    for (var item in jsonList) {
      final singleItem = Item3.fromJsonMap(item);
        itemsObjetivos.add(singleItem);
    }
  }
}

class Item3 {
  int?    id;
  int?    objetivo_id;
  String? nombre_objetivo;
  String? imagen_objetivo;
  String? tipo_objetivo;
  int?    meta;
  int?    entregados;
  String? firma;
  
  Item3({
    this.id,
    this.objetivo_id,
    this.nombre_objetivo,
    this.imagen_objetivo,
    this.tipo_objetivo,
    this.meta,
    this.entregados,
    this.firma
  });

  Item3.fromJsonMap(Map<String, dynamic> json) {
    id = int.parse(json['objetivo_id']);
    objetivo_id = int.parse(json['objetivo_id']);
    nombre_objetivo = json['nombre_objetivo'];
    imagen_objetivo = json['imagen_objetivo'];
    tipo_objetivo = json['tipo_objetivo'];
    meta = int.parse(json['meta']);
    entregados = int.parse(json['entregados']);
    firma = json['firma'];
  }
}