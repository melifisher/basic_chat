import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:text_search/text_search.dart';

class SearchLocalScreen extends StatefulWidget {
  @override
  _SearchLocalScreenState createState() => _SearchLocalScreenState();
}

class _SearchLocalScreenState extends State<SearchLocalScreen> {
  List<TextSearchItem<String>> index = [];
  List<String> resultados = [];

  @override
  void initState() {
    super.initState();
    cargarYIndexarArchivo();
  }

  Future<void> cargarYIndexarArchivo() async {
    final contenido = await rootBundle.loadString('assets/datoscompletos.txt');
    final lineas = contenido.split('\n'); // Dividir el contenido en líneas

    final fragmentosDeLineas = <String>[];
    final maxLineas = 10; // Número de líneas por fragmento

    // Agrupar las líneas en fragmentos de 20 líneas
    for (int i = 0; i < lineas.length; i += maxLineas) {
      final fragmento = lineas
          .sublist(
            i,
            i + maxLineas > lineas.length ? lineas.length : i + maxLineas,
          )
          .join('\n');
      fragmentosDeLineas.add(fragmento);
    }

    index = [];
    for (var fragmento in fragmentosDeLineas) {
      // Eliminar acentos de cada fragmento usando la librería diacritic.
      final fragmentoSinAcentos = removeDiacritics(fragmento);

      index.add(
        TextSearchItem.fromTerms(fragmentoSinAcentos, [fragmentoSinAcentos]),
      );
    }

    setState(() {});
  }

  void buscar(String consulta) {
    final buscador = TextSearch(index);
    consulta = removeDiacritics(consulta.trim().toLowerCase());

    final palabras = consulta.split(RegExp(r'\s+')); // Separa por espacios
    final Map<String, int> contadorFragmentos = {};

    // Buscar cada palabra por separado
    for (var palabra in palabras) {
      final resultadosParciales = buscador.search(palabra, matchThreshold: 1.5);

      for (var resultado in resultadosParciales) {
        final fragmento = resultado.object;

        // Contar cuántas palabras coinciden en cada fragmento
        contadorFragmentos[fragmento] =
            (contadorFragmentos[fragmento] ?? 0) + 1;
      }
    }

    // Filtrar fragmentos que contengan TODAS las palabras
    final resultadosFiltrados =
        contadorFragmentos.entries
            .where((entry) => entry.value == palabras.length)
            .map((entry) => entry.key)
            .toList();

    setState(() {
      resultados = resultadosFiltrados;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Buscador')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Buscar...',
                border: OutlineInputBorder(),
              ),
              onChanged: buscar,
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: resultados.length,
                itemBuilder: (context, index) {
                  return ListTile(title: Text(resultados[index]));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
