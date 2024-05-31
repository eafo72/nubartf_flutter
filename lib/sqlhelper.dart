import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE relacioneo(
        relacioneoid INT,
        relacioneoobjetivoid INT,
        relacioneoelementosid INT,
        ordenaparicion INT
      )
      """);
    await database.execute("""CREATE TABLE elementosllegada(
        id INT,
        elementoid INT, 
        nombreelemento TEXT, 
        scriptelemento TEXT, 
        name TEXT, 
        tipoentrega TEXT
      )
      """);
    await database.execute("""CREATE TABLE relacionot(
        id INT,
        relacionotid INT,
        relacionottiendaid INT,
        relacionotobjetivoid INT
      )
      """);  
     await database.execute("""CREATE TABLE objetivos(
        id INT,
        objetivoid INT,
        nombreobjetivo TEXT,
        imagenobjetivo TEXT,
        tipoobjetivo TEXT,
        limiterepeticion TEXT,
        meta INT, 
        entregados INT, 
        firma TEXT
      )
      """);  
      await database.execute("""CREATE TABLE entregable(
       entrega_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
       entregarolid INT, 
       entrega_nombre_elemento TEXT, 
       entrega_tipo_texto TEXT, 
       entrega_tipo_numero TEXT, 
       entrega_tipo_fecha TEXT, 
       entrega_tipo_hora TEXT, 
       entrega_tipo_imagen TEXT, 
       entrega_tipo_audio TEXT, 
       entrega_fecha_llegada TEXT, 
       entrega_hora_llegada TEXT, 
       entregaobjetivoid INT, 
       entregahoracierre TEXT, 
       entregafechacierre TEXT, 
       meta_venta TEXT
      )
      """);  
      await database.execute("""CREATE TABLE misiones(
        mision_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        misionrol_maestroid INT,
        misionidordentrabajo INT, 
        misionidmarca INT, 
        fechainiciomision TEXT, 
        horainiciomision TEXT, 
        geoiniciomision TEXT, 
        pausasmision TEXT, 
        reiniciosmision TEXT, 
        prcomentarios TEXT, 
        fechaentregamision TEXT, 
        horaentregamision TEXT,  
        geoentregamision TEXT, 
        soscausa TEXT, 
        soscomentario TEXT, 
        status TEXT
      )
      """);  
      await database.execute("""CREATE TABLE leerelementos(
        id_elemento INT,
        nombre_elemento TEXT, 
        name TEXT, 
        tipo_entrega TEXT
      )
      """);  
      await database.execute("""CREATE TABLE rolmaestromisiones(
        rolmaestroid INT NOT NULL PRIMARY KEY,
        rolmarcaid INT,
        rolidtienda INT,
        rolidordentrabajo INT,
        fechahoracreacionvisitarol TEXT,
        fechaprogramadavisitarol TEXT,
        horaprogramadavisitarol TEXT, 
        usuarioidcreadorrol TEXT, 
        colaboradoridasignadorol INT, 
        fechayhorasubida TEXT, 
        geosubida TEXT
      )
      """);  
      await database.execute("""CREATE TABLE rolmaestromisionesUNIQUE(
        rolmaestroid INT,
        rolmarcaid INT,
        rolidtienda INT,
        rolidordentrabajo INT,
        fechahoracreacionvisitarol TEXT,
        fechaprogramadavisitarol TEXT,
        horaprogramadavisitarol TEXT, 
        usuarioidcreadorrol TEXT, 
        colaboradoridasignadorol INT, 
        fechayhorasubida TEXT, 
        geosubida TEXT
      )
      """);  
      await database.execute("""CREATE TABLE tienda(
        tiendaid INT,
        nombretienda TEXT, 
        ubicaciontienda TEXT,  
        geotienda TEXT, 
        encargadotienda TEXT, 
        documentoslista TEXT, 
        codigoqr TEXT,
        cadenaidtienda TEXT
      )
      """);
      await database.execute("""CREATE TABLE marcas(
        marcaid INT, 
        marclienteid TEXT, 
        nombremarca TEXT, 
        descripcionmarca TEXT, 
        tipomarca TEXT, 
        nomarca TEXT, 
        documentos TEXT,
        incluyeinventario TEXT
      )
      """);
      await database.execute("""CREATE TABLE verificacionmarcas(
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        idrol INT,
        idmarca INT,
        status TEXT
      )
      """);
      await database.execute("""CREATE TABLE geouser(
        id INT, 
        lat DOUBLE, 
        long DOUBLE
      )
      """);
      await database.execute("""CREATE TABLE objetivosmarca(
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        idrol INT,
        idmarca INT,
        idtienda INT,
        idobjetivo INT,
        nombreobjetivo STRING,
        imagenobjetivo STRING,
        firmaobjetivo STRING,
        realizado INT
      )
      """); 
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'nubartf.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  //relacionOT
  // INSERT
  static Future<int> createRelacionOT(
     int relacion_ot_id,
     int relacion_ot_tienda_id,
     int relacion_ot_objetivo_id,
    ) async {
    final db = await SQLHelper.db();
    final data = {
      'relacionotid' : relacion_ot_id,
      'relacionottiendaid' : relacion_ot_tienda_id,
      'relacionotobjetivoid' : relacion_ot_objetivo_id
    };
    final finalid = await db.insert('relacionot', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return finalid;
  }

  //objetivos
  // INSERT
  static Future<int> createObjetivo(
    int    id,
    int    objetivo_id,
    String    nombre_objetivo,
    String imagen_objetivo,
    String tipo_objetivo,
    int    meta,
    int    entregados,
    String firma
    ) async {
    final db = await SQLHelper.db();
    final data = {
      'id': id,
      'objetivoid' : objetivo_id,
      'nombreobjetivo' : nombre_objetivo,
      'imagenobjetivo' : imagen_objetivo,
      'tipoobjetivo' : tipo_objetivo,
      'meta' : meta,
      'entregados' : entregados,
      'firma' : firma
    };
    final finalid = await db.insert('objetivos', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return finalid;
  }

  //relacionEO
  // INSERT
  static Future<int> createRelacionEO(
    int relacioneoid,
    int relacioneoobjetivoid,
    int relacioneoelementosid,
    int ordenaparicion,
    ) async {
    final db = await SQLHelper.db();
    final data = {
      'relacioneoid': relacioneoid,
      'relacioneoobjetivoid': relacioneoobjetivoid,
      'relacioneoelementosid': relacioneoelementosid,
      'ordenaparicion': ordenaparicion
    };
    final finalid = await db.insert('relacioneo', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return finalid;
  }


  //elementosLlegada
  // INSERT
  static Future<int> createElementoLlegada(
    int    id,
    int    elemento_id,
    String nombre_elemento,
    String script_elemento,
    String name,
    String tipo_entrega
    ) async {
    final db = await SQLHelper.db();
    final data = {
      'id' : id,
      'elementoid' : elemento_id,
      'nombreelemento' : nombre_elemento,
      'scriptelemento' : script_elemento,
      'name' : name,
      'tipoentrega' : tipo_entrega
    };
    final finalid = await db.insert('elementosllegada', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return finalid;
  }

  //RolMaestro
  // INSERT
  static Future<int> createRol(
    int rolmaestroid,
    int rolmarcaid,
    int rolidtienda,
    int rolidordentrabajo,
    String fechahoracreacionvisitarol,
    String fechaprogramadavisitarol,
    String horaprogramadavisitarol, 
    String usuarioidcreadorrol, 
    int colaboradoridasignadorol, 
    String fechayhorasubida, 
    String geosubida
    ) async {
    final db = await SQLHelper.db();

    final data = {
      'rolmaestroid': rolmaestroid,
      'rolmarcaid': rolmarcaid,
      'rolidtienda': rolidtienda,
      'rolidordentrabajo': rolidordentrabajo,
      'fechahoracreacionvisitarol': fechahoracreacionvisitarol,
      'fechaprogramadavisitarol': fechaprogramadavisitarol,
      'horaprogramadavisitarol': horaprogramadavisitarol,
      'usuarioidcreadorrol': usuarioidcreadorrol,
      'colaboradoridasignadorol': colaboradoridasignadorol,
      'fechayhorasubida': fechayhorasubida,
      'geosubida': geosubida
    };

    final finalid = await db.insert('rolmaestromisiones', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return finalid;
    
  }

  //tienda
  // INSERT
  static Future<int> createTienda(
    int    tienda_id,
    String nombre_tienda,
    String ubicacion_tienda,
    String geo_tienda,
    String encargado_tienda,
    String documento,
    String codigoqr,
    String cadena_id_tienda,
    ) async {
    final db = await SQLHelper.db();
    final data = {
      'tiendaid' : tienda_id,
      'nombretienda' : nombre_tienda,
      'ubicaciontienda' : ubicacion_tienda,
      'geotienda' : geo_tienda,
      'encargadotienda' : encargado_tienda,
      'documentoslista' : documento,
      'codigoqr' : codigoqr,
      'cadenaidtienda' : cadena_id_tienda
    };
    final finalid = await db.insert('tienda', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return finalid;
  }

  //marcas
  // INSERT
  static Future<int> createMarca(
    int    marca_id,
    String mar_cliente_id,
    String nombre_marca,
    String descripcion_marca,
    String tipo_marca,
    String no_marca,
    String documentos,
    String incluye_inventario,
    ) async {
    final db = await SQLHelper.db();
    final data = {
      'marcaid' : marca_id,
      'marclienteid' : mar_cliente_id,
      'nombremarca' : nombre_marca,
      'descripcionmarca' : descripcion_marca,
      'tipomarca' : tipo_marca,
      'nomarca' : no_marca,
      'documentos' : documentos,
      'incluyeinventario' : incluye_inventario
    };
    final finalid = await db.insert('marcas', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return finalid;
  }

/*
  //RolMaestroUnique
  // INSERT
  static Future<int> createRolUnique(
    int rolmaestroid,
    int rolmarcaid,
    int rolidtienda,
    int rolidordentrabajo,
    String fechahoracreacionvisitarol,
    String fechaprogramadavisitarol,
    String horaprogramadavisitarol, 
    String usuarioidcreadorrol, 
    int colaboradoridasignadorol, 
    String fechayhorasubida, 
    String geosubida
    ) async {
    final db = await SQLHelper.db();
    final data = {
      'rolmaestroid': rolmaestroid,
      'rolmarcaid': rolmarcaid,
      'rolidtienda': rolidtienda,
      'rolidordentrabajo': rolidordentrabajo,
      'fechahoracreacionvisitarol': fechahoracreacionvisitarol,
      'fechaprogramadavisitarol': fechaprogramadavisitarol,
      'horaprogramadavisitarol': horaprogramadavisitarol,
      'usuarioidcreadorrol': usuarioidcreadorrol,
      'colaboradoridasignadorol': colaboradoridasignadorol,
      'fechayhorasubida': fechayhorasubida,
      'geosubida': geosubida
    };
    final finalid = await db.insert('rolmaestromisionesUNIQUE', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return finalid;
  }*/


////////////////////////////////////// ROL MAESTRO ///////////////////////////////////

  //GET roles de hoy
  static Future<List<Map<String, dynamic>>> getTodayRoles(id_usuario,fecha) async {
    final db = await SQLHelper.db();
    String query = 'SELECT DISTINCT * FROM rolmaestromisiones';
    query += ' INNER JOIN tienda';
    query += ' ON rolmaestromisiones.rolidtienda = tienda.tiendaid'; 
    query += ' LEFT JOIN misiones';
    query += ' ON rolmaestromisiones.rolmaestroid = misiones.misionrol_maestroid AND rolmaestromisiones.rolmarcaid = misiones.misionidmarca'; 
    query += ' WHERE colaboradoridasignadorol = ${id_usuario}';
    query += ' AND fechayhorasubida = "0000-00-00 00:00:00"';
    query += ' AND fechaprogramadavisitarol = "${fecha}"';
    //print(query);
    return db.rawQuery(query);
  }

  //GET ALL user roles
  static Future<List<Map<String, dynamic>>> getRoles() async {
    final db = await SQLHelper.db();
     String query = 'SELECT DISTINCT * FROM rolmaestromisiones';
    query += ' INNER JOIN tienda';
    query += ' ON rolmaestromisiones.rolidtienda = tienda.tiendaid'; 
    //print(query);
    return db.rawQuery(query);
  }

  //GET ALL user roles siguientes apartir de hoy incluyendo hoy
  static Future<List<Map<String, dynamic>>> getNextRoles() async {
    DateTime dateToday = DateTime.now(); 
    final _hoy = dateToday.toString().substring(0,10);
    final db = await SQLHelper.db();
    String query = 'SELECT DISTINCT * FROM rolmaestromisiones';
    query += ' INNER JOIN tienda';
    query += ' ON rolmaestromisiones.rolidtienda = tienda.tiendaid'; 
    query += ' WHERE fechaprogramadavisitarol >= "${_hoy}" ORDER BY fechaprogramadavisitarol ASC';
    //print(query);
    return db.rawQuery(query);
  }

  //GET ALL user roles anteriores apartir de hoy sin incluir hoy
  static Future<List<Map<String, dynamic>>> getPastRoles() async {
    DateTime dateToday = DateTime.now(); 
    final _hoy = dateToday.toString().substring(0,10);
    final db = await SQLHelper.db();
    String query = 'SELECT DISTINCT * FROM rolmaestromisiones';
    query += ' INNER JOIN tienda';
    query += ' ON rolmaestromisiones.rolidtienda = tienda.tiendaid'; 
    query += ' WHERE fechaprogramadavisitarol < "${_hoy}" ORDER BY fechaprogramadavisitarol ASC';
    //print(query);
    return db.rawQuery(query);
  }

  //GET ALL user roles by date
  static Future<List<Map<String, dynamic>>> getRolesByDate(fecha) async {
    final db = await SQLHelper.db();
     String query = 'SELECT DISTINCT * FROM rolmaestromisiones';
    query += ' INNER JOIN tienda';
    query += ' ON rolmaestromisiones.rolidtienda = tienda.tiendaid'; 
    query += ' WHERE fechaprogramadavisitarol = "${fecha}"';
    //print(query);
    return db.rawQuery(query);
  }

  //GET roles by ot
  static Future<List<Map<String, dynamic>>> getTodayRolesByOT(idot) async {
    final db = await SQLHelper.db();
    String query = 'SELECT DISTINCT * FROM rolmaestromisiones';
    query += ' INNER JOIN tienda';
    query += ' ON rolmaestromisiones.rolidtienda = tienda.tiendaid'; 
    query += ' INNER JOIN marcas';
    query += ' ON rolmaestromisiones.rolmarcaid = marcas.marcaid'; 
    query += ' LEFT JOIN verificacionmarcas';
    query += ' ON verificacionmarcas.idmarca = marcas.marcaid AND verificacionmarcas.idrol = rolmaestromisiones.rolmaestroid' ; 
     query += ' WHERE rolidordentrabajo = ${idot}';
    //print(query);
    return db.rawQuery(query);
  }

  //GET roles by ot
  static Future<List<Map<String, dynamic>>> getTodayRolesByROL(idrol) async {
    final db = await SQLHelper.db();
    String query = 'SELECT DISTINCT * FROM rolmaestromisiones';
    query += ' INNER JOIN tienda';
    query += ' ON rolmaestromisiones.rolidtienda = tienda.tiendaid'; 
    query += ' INNER JOIN marcas';
    query += ' ON rolmaestromisiones.rolmarcaid = marcas.marcaid'; 
    query += ' LEFT JOIN verificacionmarcas';
    query += ' ON verificacionmarcas.idmarca = marcas.marcaid AND verificacionmarcas.idrol = rolmaestromisiones.rolmaestroid' ; 
     query += ' WHERE rolmaestroid = ${idrol}';
    //print(query);
    return db.rawQuery(query);
  }



  //update rol fechahorasubida
  static Future<int> updateRolWithFechaSubida(
    int idrol,
    int idmarca,
    int idot,
    String fecha
    ) async {
    final db = await SQLHelper.db();

    final data = {
      'fechayhorasubida' : fecha
    };
    final finalid = await db.update('rolmaestromisiones', data, where: "rolmaestroid = ? and rolmarcaid = ? and rolidordentrabajo = ?", whereArgs: [idrol, idmarca, idot]);
    return finalid;
 
  }

////////////////////////////////////// OBJETIVOS ///////////////////////////////////

  //GET ALL objetivos
  static Future<List<Map<String, dynamic>>> getObjetivos() async {
    final db = await SQLHelper.db();
    return db.query('objetivos');
  }

////////////////////////////////////// MARCAS ///////////////////////////////////

  //GET ALL MARCAS
  static Future<List<Map<String, dynamic>>> getAllMarcas() async {
    final db = await SQLHelper.db();
    return db.rawQuery('SELECT DISTINCT * FROM marcas ORDER BY nombremarca');
  }

////////////////////////////////////// TIENDAS ///////////////////////////////////

  //GET ALL TIENDAS
  static Future<List<Map<String, dynamic>>> getAllTiendas() async {
    final db = await SQLHelper.db();
    return db.rawQuery('SELECT DISTINCT * FROM tienda ORDER BY nombretienda');
  }

 //GET tienda by id
  static Future<List<Map<String, dynamic>>> getTiendaById(idtienda) async {
    final db = await SQLHelper.db();
    return db.rawQuery("SELECT * FROM tienda WHERE tiendaid = $idtienda LIMIT 1"); 
  }



////////////////////////////////////// MISIONES ///////////////////////////////////

  //GET if exist mision for role
  static Future<List<Map<String, dynamic>>> getMissionExist(idrol,idmarca,idot) async {
    final db = await SQLHelper.db();
    return db.rawQuery("SELECT COUNT(*) as items FROM misiones WHERE misionrol_maestroid = $idrol AND misionidmarca = $idmarca AND misionidordentrabajo = $idot"); 
  }

  //GET ALL misiones
  static Future<List<Map<String, dynamic>>> getMisiones() async {
    final db = await SQLHelper.db();
    return db.query('misiones');
  }

   //GET misionesby idrol idmarca idot
   static Future<List<Map<String, dynamic>>> getMision(int idrol, int idmarca, int idot) async {
    final db = await SQLHelper.db();
    return db.query('misiones', where: "misionrol_maestroid = ? and misionidmarca = ? and  misionidordentrabajo = ?", whereArgs: [idrol, idmarca, idot], limit: 1);
  }


 // INSERT verificacion marca por idmarca y idrol 
  static Future<int> insertMission(
    int idrol, 
    int idmarca, 
    int idot,
    String fechainiciomision,
    String horainiciomision,
    String geoiniciomision
    ) async {
    final db = await SQLHelper.db();

    final data = {
      'misionrol_maestroid' : idrol,
      'misionidmarca' : idmarca,
      'misionidordentrabajo' : idot,
      'fechainiciomision' : fechainiciomision,
      'horainiciomision' : horainiciomision,
      'geoiniciomision' : geoiniciomision,
      'pausasmision' : '',
      'reiniciosmision' : '',
      'prcomentarios' : '',
      'fechaentregamision' : '',
      'horaentregamision' : '',
      'geoentregamision' : '',
      'soscausa' : '',
      'soscomentario' : '',
      'status' : ''
    };

    final finalid = await db.insert('misiones', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return finalid;
  }

  // Update misiones
  static Future<int> updateMissionWhenFinish(
    int idrol, 
    int idmarca, 
    int idot,
    String fechaentregamision,
    String horaentregamision,
    String geoentregamision,
    String status
    ) async {
    final db = await SQLHelper.db();

    final data = {
      'fechaentregamision' : fechaentregamision,
      'horaentregamision' : horaentregamision,
      'geoentregamision' : geoentregamision,
      'status' : status
    };
    final finalid = await db.update('misiones', data, where: "misionrol_maestroid = ? and misionidmarca = ? and misionidordentrabajo = ?", whereArgs: [idrol, idmarca, idot]);
    return finalid;

  }

  //abort mission SOS
  static Future<int> abortMissionSOS(
    int idot,
    int idrol,
    String comentario,
    String causa,
    String fecha,
    String hora
  ) async {
    final db = await SQLHelper.db();


    final data = {
      'fechaentregamision' : fecha,
      'horaentregamision' : hora,
      'soscausa': causa,
      'soscomentario': comentario,
      'status' : 'SOS'
    };
    final finalid = await db.update('misiones', data, where: "misionrol_maestroid = ? and misionidordentrabajo = ?", whereArgs: [idrol, idot]);
    return finalid;
  }
 

 //pause mission
  static Future<List<Map<String, dynamic>>> pauseMission(
    int idot,
    int idrol,
    String comentario,
    String causa,
    String fecha,
    String hora
  ) async {
    final db = await SQLHelper.db();
    
    var finalid = await db.rawQuery('UPDATE misiones SET prcomentarios = prcomentarios || "/P:$comentario", pausasmision =  pausasmision || "/$fecha" || "-" || "$hora" || "-" || "$causa"  WHERE misionrol_maestroid = $idrol and misionidordentrabajo = $idot');
    return finalid;
  }

  //play mission after pause
  static Future<List<Map<String, dynamic>>> playMission(
    int idot,
    int idrol,
    String comentario,
    String fecha,
    String hora
  ) async {
    final db = await SQLHelper.db();
    
    var finalid = await db.rawQuery('UPDATE misiones SET prcomentarios = prcomentarios || "/R:$comentario", reiniciosmision =  reiniciosmision || "/$fecha" || "-" || "$hora"  WHERE misionrol_maestroid = $idrol and misionidordentrabajo = $idot');
    return finalid;
  }  
  
////////////////////////////////////// VERIFICACION MARCAS ///////////////////////////////////


 
  //GET if exist marca en verificacion marca
  static Future<List<Map<String, dynamic>>> checkMarcaExistOnVM(idmarca,idrol) async {
    final db = await SQLHelper.db();
    return db.rawQuery("SELECT COUNT(*) as items FROM verificacionmarcas WHERE idmarca = $idmarca AND idrol = $idrol"); 
  }



   //GET check marca terminada
  static Future<List<Map<String, dynamic>>> checkMarcaTerminada(idmarca,idrol) async {
    final db = await SQLHelper.db();
    return db.rawQuery("SELECT COUNT(*) as items FROM verificacionmarcas WHERE idmarca = $idmarca AND idrol = $idrol AND status = 'Si'"); 
  }





  //GET ALL verificacion marcas
  static Future<List<Map<String, dynamic>>> getVerificacionMarcas() async {
    final db = await SQLHelper.db();
    return db.rawQuery('SELECT DISTINCT * FROM verificacionmarcas INNER JOIN marcas ON verificacionmarcas.idmarca = marcas.marcaid');
  }

  // UPDATE verificacion marca por idmarca y idrol 
  static Future<List<Map<String, dynamic>>> updateStatusMarca(int idmarca, int idrol, String valor) async {
    final db = await SQLHelper.db();

    return db.rawQuery('UPDATE verificacionmarcas SET status = $valor WHERE idmarca = $idmarca AND idrol = $idrol');
    
  }

  // INSERT verificacion marca por idmarca y idrol 
  static Future<int> insertStatusMarca(int idmarca, int idrol, String valor) async {
    final db = await SQLHelper.db();

    final data = {
      'idmarca' : idmarca,
      'idrol' : idrol,
      'status' : valor
    };

    final finalid = await db.insert('verificacionmarcas', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return finalid;
    
  }




////////////////////////////////////// RELACIONEO ///////////////////////////////////

  //GET tareas por objetivo
  static Future<List<Map<String, dynamic>>> getTareasDelObjetivo(idobjetivo) async {
    final db = await SQLHelper.db();
    return db.rawQuery("SELECT DISTINCT * FROM relacioneo INNER JOIN elementosllegada ON relacioneo.relacioneoelementosid  = elementosllegada.elementoid WHERE relacioneoobjetivoid = $idobjetivo"); 
  }




////////////////////////////////////// RELACIONOT ///////////////////////////////////

  //GET objetivos por tienda
  static Future<List<Map<String, dynamic>>> getRelationObjetivosTienda(idtienda) async {
    final db = await SQLHelper.db();
    return db.rawQuery("SELECT DISTINCT * FROM relacionot INNER JOIN objetivos ON relacionot.relacionotobjetivoid  = objetivos.objetivoid WHERE relacionottiendaid = $idtienda"); 
  }



////////////////////////////////////// OBJETIVOS MARCA  //////////////////////////////////

//en realidad todo esto es objetivos tienda ya no es por marca

  //GET objetivosmarcaExist
  static Future<List<Map<String, dynamic>>> getObjetivoMarcaExist(idrol,idmarca,idobjetivo) async {
    final db = await SQLHelper.db();
    return db.rawQuery("SELECT COUNT(*) as items FROM objetivosmarca WHERE idrol = $idrol AND idmarca = $idmarca AND idobjetivo = $idobjetivo"); 
  }

  //GET objetivosmarca by rol
  static Future<List<Map<String, dynamic>>> getObjetivosMarcaByRol(idrol,idmarca) async {
    final db = await SQLHelper.db();
    return db.rawQuery("SELECT * FROM objetivosmarca WHERE idrol = $idrol AND idmarca = $idmarca"); 
  }

  //GET ALL objetivos marca
  static Future<List<Map<String, dynamic>>> getObjetivosMarca() async {
    final db = await SQLHelper.db();
    return db.query('objetivosmarca');
  }

  //GET checar si ya termino objetivos del rol
  static Future<List<Map<String, dynamic>>> checkObjetivosTerminados(idrol,idmarca) async {
    final db = await SQLHelper.db();
    return db.rawQuery("SELECT COUNT(*) as items FROM objetivosmarca WHERE idrol = $idrol AND idmarca = $idmarca AND realizado = 0"); 
  }

  //INSERT objetivomarca
  static Future<int> insertObjetivoMarca(
    int? __idrol,
    int? __idmarca,
    int? __idtienda,
    int? __idobjetivo,
    String? nombreobjetivo,
    String? imagenobjetivo,
    String? firmaobjetivo,
    ) async {
    final db = await SQLHelper.db();
     final data = {
      'idrol':__idrol,
      'idmarca':__idmarca,
      'idtienda':__idtienda,
      'idobjetivo':__idobjetivo,
      'nombreobjetivo':nombreobjetivo,
      'imagenobjetivo':imagenobjetivo,
      'firmaobjetivo' :firmaobjetivo, 
      'realizado':0
    };
    final result = await db.insert('objetivosmarca', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return result;
  }
  
  // UPDATE objetivomarca por id 
  static Future<int> updateWithRealizadoObjetivoMarca(int id) async {
    final db = await SQLHelper.db();

    final data = {
      'realizado': 1
    };

    final result =
        await db.update('objetivosmarca', data, where: "id = ?", whereArgs: [id]);
    return result;
  }



  ////////////////////////////////////// ENTREGABLE ///////////////////////////////////
  
  
  // INSERT entregable
  static Future<int> saveEntregable(
       int? entregarolid,
       String? entrega_nombre_elemento, 
       String? entrega_tipo_texto, 
       String? entrega_tipo_numero, 
       String? entrega_tipo_fecha, 
       String? entrega_tipo_hora, 
       String? entrega_tipo_imagen, 
       String? entrega_tipo_audio, 
       String? entrega_fecha_llegada, 
       String? entrega_hora_llegada, 
       String? entregafechacierre,
       String? entregahoracierre, 
       int? entregaobjetivoid  
      ) async {
    final db = await SQLHelper.db();
    final data = {
       'entregarolid': entregarolid,
       'entrega_nombre_elemento': entrega_nombre_elemento, 
       'entrega_tipo_texto': entrega_tipo_texto, 
       'entrega_tipo_numero': entrega_tipo_numero, 
       'entrega_tipo_fecha': entrega_tipo_fecha, 
       'entrega_tipo_hora': entrega_tipo_hora, 
       'entrega_tipo_imagen': entrega_tipo_imagen, 
       'entrega_tipo_audio': entrega_tipo_audio, 
       'entrega_fecha_llegada': entrega_fecha_llegada, 
       'entrega_hora_llegada': entrega_hora_llegada, 
       'entregafechacierre': entregafechacierre,
       'entregahoracierre': entregahoracierre, 
       'entregaobjetivoid': entregaobjetivoid
    };
    final id = await db.insert('entregable', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  //GET ALL entregables
  static Future<List<Map<String, dynamic>>> getEntregables() async {
    final db = await SQLHelper.db();
    return db.query('entregable');
  }

  //GET entregables by rol
  static Future<List<Map<String, dynamic>>> getEntregablesByRol(idrol) async {
    final db = await SQLHelper.db();
    return db.rawQuery("SELECT * FROM entregable WHERE entregarolid = $idrol"); 
  }
  
  
////////////////////////////////////// VARIOS ///////////////////////////////////
  
//DELETE TABLE
static Future<void> deleteTable(String tableName) async {
    final db = await SQLHelper.db();
    try {
      await db.rawQuery('DELETE FROM ${tableName}');
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

//DELETE TABLEs relacionOT,objetivos,relacionEO,rolmaestromisiones,elementosLlegada,tienda,marcas,rolmaestromisionesUNIQUE
static Future<void> deleteInitialTables() async {
    final db = await SQLHelper.db();

    try {
      await db.rawQuery('DELETE FROM relacionOT');
      await db.rawQuery('DELETE FROM objetivos');
      await db.rawQuery('DELETE FROM relacionEO');
      await db.rawQuery('DELETE FROM rolmaestromisiones');
      await db.rawQuery('DELETE FROM elementosLlegada');
      await db.rawQuery('DELETE FROM tienda');
      await db.rawQuery('DELETE FROM marcas');
      //await db.rawQuery('DELETE FROM rolmaestromisionesUNIQUE');
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }


 
}
