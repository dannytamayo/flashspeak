import 'package:flutter/material.dart';
import 'ViewCategory.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final List<String> categorias = [
    "Frutas",
    "Animales",
    "Colores",
    "Vegetales",
    "Números",
    "Profesiones",
    "Verbos",
  ];

  final List<IconData> icons = [
    Icons.local_florist, 
    Icons.pets, 
    Icons.palette, 
    Icons.eco, 
    Icons.format_list_numbered, 
    Icons.work, 
    Icons.directions_walk, 
  ];

  final List<Color> cardColors = [
    Colors.red,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.tealAccent,
    Colors.lightBlueAccent,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flycards Vocabulario"),
      ),
      body: Column(
        children: <Widget>[
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(0.0, 14.0, 0.0, 0.0),
                child: Text("CATEGORIAS",
                    style:
                        TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold)),
              ),
            ],
          ),

          // const SizedBox(height: 10.0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (var i = 0; i < categorias.length; i++)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  VistaCategoria(categoria: categorias[i]),
                            ),
                          );
                        },
                        child: Container(
                          height: 150.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: cardColors[i].withOpacity(0.8),
                          ),
                          margin: const EdgeInsets.only(bottom: 10.0),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Text(
                                      categorias[i],
                                      style: const TextStyle(
                                          fontSize: 28.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Icon(
                                      icons[i],
                                      size: 130.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
