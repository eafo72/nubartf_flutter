class FullTienda {
  List<Item6> itemsTienda = [];

  //constructor vacio
  FullTienda();

  FullTienda.fromJsonList(List<dynamic> jsonList) {
    for (var item in jsonList) {
      final singleItem = Item6.fromJsonMap(item);
        itemsTienda.add(singleItem);
    }
  }
}

class Item6 {
  int? tienda_id;
  String? nombre_tienda;
  String? ubicacion_tienda;
  String? geo_tienda;
  String? encargado_tienda;
  String? documento;
  String? codigoqr;
  String? cadena_id_tienda;
  
  Item6({
    this.tienda_id,
    this.nombre_tienda,
    this.ubicacion_tienda,
    this.geo_tienda,
    this.encargado_tienda,
    this.documento,
    this.codigoqr,
    this.cadena_id_tienda
  });

  Item6.fromJsonMap(Map<String, dynamic> json) {
    tienda_id  = int.parse(json['tienda_id']);
    nombre_tienda = json['nombre_tienda'];
    ubicacion_tienda = json['ubicacion_tienda'];
    geo_tienda = json['geo_tienda'];
    encargado_tienda = json['encargado_tienda'];
    documento = json['documento'];
    codigoqr = json['codigoqr'];
    cadena_id_tienda = json['cadena_id_tienda'];
  }
}