import 'package:hive/hive.dart';

class BaseDeDatos{

  List datosCuenta = [];

  final Box _boxDeLaHive = Hive.box("box_datos_cuenta");


  void carregarDades(){
    datosCuenta = _boxDeLaHive.get("box_datos_cuenta");

  }

  void actualizarDades(){
    _boxDeLaHive.put("box_datos_cuenta", datosCuenta);
  }


  void crearDadesExemple(){
    datosCuenta = [
      {"name": "Arnau", "email": "a.rodriguez@ceroca.cat", "passwd": "123456"},
      {"name": "Jheremy", "email": "j.valda@ceroca.cat", "passwd": "123456"},
      {"name": "Lucas", "email": "l.quintana@ceroca.cat", "passwd": "123456"},
    ];
  }
}