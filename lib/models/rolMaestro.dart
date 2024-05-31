class FullRols {
  List<Item1> itemsRols = [];

  //constructor vacio
  FullRols();

  FullRols.fromJsonList(List<dynamic> jsonList) {
    for (var item in jsonList) {
      final singleItem = Item1.fromJsonMap(item);
        itemsRols.add(singleItem);
    }
  }
}

class Item1 {
  int? rol_maestro_id;
  int? rol_marca_id;
  int? rol_id_tienda;
  int? rol_id_orden_trabajo;
  String? fecha_hora_creacion_visita_rol;
  String? fecha_programada_visita_rol;
  String? hora_programada_visita_rol;
  String? usuario_id_creador_rol;
  int? colaborador_id_asignado_rol;
  String? fechayhorasubida;
  String? geosubida;
  
  Item1({
    this.rol_maestro_id,
    this.rol_marca_id,
    this.rol_id_tienda,
    this.rol_id_orden_trabajo,
    this.fecha_hora_creacion_visita_rol,
    this.fecha_programada_visita_rol,
    this.hora_programada_visita_rol,
    this.usuario_id_creador_rol,
    this.colaborador_id_asignado_rol,
    this.fechayhorasubida,
    this.geosubida
  });

  Item1.fromJsonMap(Map<String, dynamic> json) {
    rol_maestro_id = int.parse(json['rol_maestro_id']);
    rol_marca_id = int.parse(json['rol_marca_id']);
    rol_id_tienda =  int.parse(json['rol_id_tienda']);
    rol_id_orden_trabajo = int.parse(json['rol_id_orden_trabajo']);
    fecha_hora_creacion_visita_rol = json['fecha_hora_creacion_visita_rol'];
    fecha_programada_visita_rol = json['fecha_programada_visita_rol'];
    hora_programada_visita_rol = json['hora_programada_visita_rol'];
    usuario_id_creador_rol = json['usuario_id_creador_rol'];
    colaborador_id_asignado_rol = int.parse(json['colaborador_id_asignado_rol']);
    fechayhorasubida = json['fechayhorasubida'];
    geosubida = json['geosubida'];
  }
}