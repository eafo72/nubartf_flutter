class FullMarcas {
  List<Item7> itemsMarcas = [];

  //constructor vacio
  FullMarcas();

  FullMarcas.fromJsonList(List<dynamic> jsonList) {
    for (var item in jsonList) {
      final singleItem = Item7.fromJsonMap(item);
        itemsMarcas.add(singleItem);
    }
  }
}

class Item7 {
  int? marca_id;
  String? mar_cliente_id;
  String? nombre_marca;
  String? descripcion_marca;
  String? tipo_marca;
  String? no_marca;
  String? documentos;
  String? incluye_inventario;
   
  Item7({
    this.marca_id,
    this.mar_cliente_id,
    this.nombre_marca,
    this.descripcion_marca,
    this.tipo_marca,
    this.no_marca,
    this.documentos,
    this.incluye_inventario
  });

  Item7.fromJsonMap(Map<String, dynamic> json) {
    marca_id = int.parse(json['marca_id']);
    mar_cliente_id = json['mar_cliente_id'];
    nombre_marca = json['nombre_marca'];
    descripcion_marca = json['descripcion_marca'];
    tipo_marca = json['tipo_marca'];
    no_marca = json['no_marca'];
    documentos = json['documentos'];
    incluye_inventario = json['incluye_inventario'];
  }
}