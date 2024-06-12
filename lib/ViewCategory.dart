// ignore_for_file: file_names

import 'dart:async';
import 'dart:math';

import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:html/dom.dart' as dom;
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:flip_card/flip_card.dart';
import 'package:practice/models/FlashCard.dart';
import 'package:translator/translator.dart';
import 'package:animate_do/animate_do.dart';

class VistaCategoria extends StatefulWidget {
  const VistaCategoria({super.key, required this.categoria});

  final String categoria;

  @override
  // ignore: no_logic_in_create_state
  State<VistaCategoria> createState() => _VistaCategoriaState(categoria);
}

class _VistaCategoriaState extends State<VistaCategoria> {
  String categoria;
  String errorMessage = "Vale";
  final translator = GoogleTranslator();
  bool isLoading = true;
  List<FlipCardController> controllers = [];

  List<List<int>> randomIndexesPerCard = [];

  // String translatedText = "";

  String responseMessage = "GUESS";

  List<FlashCard> cards = [];

  bool isValid = false;
  bool isAnswered = false;

  _VistaCategoriaState(this.categoria);

  Map<String, String> categoriasInfo = {
    "Animales":
        "https://kids-flashcards.com/es/free-printable/animales-domesticos-tarjetas-didacticas-en-ingles",
    "Frutas":
        "https://kids-flashcards.com/es/free-printable/frutas-tarjetas-didacticas-en-ingles",
    "Colores":
        "https://kids-flashcards.com/es/free-printable/colores-tarjetas-didacticas-en-ingles",
    "Vegetales":
        "https://kids-flashcards.com/es/free-printable/verduras-tarjetas-didacticas-en-ingles",
    "Números":
        "https://kids-flashcards.com/es/free-printable/numeros-(1-20)-tarjetas-didacticas-en-ingles",
    "Profesiones":
        "https://kids-flashcards.com/es/free-printable/profesiones-tarjetas-didacticas-en-ingles",
    "Verbos":
        "https://kids-flashcards.com/es/free-printable/verbos-de-rutina-tarjetas-didacticas-en-ingles"
  };

  @override
  void initState() {
    super.initState();
    getWebsiteData();
  }

  Future getWebsiteData() async {
    if (categoriasInfo.containsKey(categoria)) {
      String? link = categoriasInfo[categoria];

      final url = Uri.parse(link!);
      final response = await http.get(url);

      final soup = BeautifulSoup(response.body);
      final items = soup.findAll('div', class_: 'card-hover');


      String textToTranslate = items.map((e) => e.find('h3')?.text).join('\n');

      String translation =
          (await translator.translate(textToTranslate, to: 'es')).text;

      List<String> translations = translation.split('\n');

      for (int i = 0; i < items.length; i++) {
        var item = items[i];
        String? imgSource =
            item.find('img', class_: 'gallery-thumb')?.attributes['src'];

        var h3Element = item.find('h3');

        String? h3Text = h3Element?.text;

        String processedTranslation =
            translations[i][0].toUpperCase() + translations[i].substring(1);

        cards.add(FlashCard(
            src: imgSource!, name: h3Text ?? '', textEs: processedTranslation));

        controllers.add(FlipCardController());
      }

      for (int i = 0; i < cards.length; i++) {
        List<int> randomIndexes = [];
        while (randomIndexes.length < 3) {
          int randomIndex = Random().nextInt(cards.length);
          if (!randomIndexes.contains(randomIndex) && randomIndex != i) {
            randomIndexes.add(randomIndex);
          }
        }
        randomIndexes.add(i);
        randomIndexes.shuffle();
        randomIndexesPerCard.add(randomIndexes);
      }
      setState(() {
        isLoading = false;
      });
    } else {
      errorMessage = "No existe esa Categoria";
    }
  }

  void checkAnswer(int index, int selectedButtonIndex) {
    String correctAnswer = cards[index].name;
    String selectedAnswer = cards[selectedButtonIndex].name;
    if (correctAnswer == selectedAnswer) {
      // Respuesta Correcta
      // print('Respuesta Correcta');

      controllers[index].toggleCard();

      setState(() {
        isValid = true;
        isAnswered = true;
        responseMessage = "GOOD";
      });

      Future.delayed(const Duration(milliseconds: 3000), () {
        setState(() {
          isValid = false;
          controllers[index].toggleCard();
          isAnswered = false;
        });
      });

      // _controller.toggleCard();
    } else {
      // Respuesta Incorrecta
      // print('Respuesta Incorrecta');

      setState(() {
        isValid = false;
        isAnswered = true;
        responseMessage = "BAD";
      });

        Future.delayed(const Duration(milliseconds: 3000), () {
        setState(() {
          isValid = false;
          isAnswered = false;
        });
      });


    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vocabulario - ${widget.categoria}"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: isAnswered ? ZoomIn(
                    child: Container(
                        decoration: BoxDecoration(
                          color: isValid ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        height: 100,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Row(children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: isValid
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.green,
                                          size: 40,
                                        )
                                      : const Icon(
                                          Icons.error,
                                          color: Colors.red,
                                          size: 40,
                                        ),
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: Center(
                                  child: Text(
                                responseMessage,
                                style: const TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              )))
                        ])),
                  ) : const SizedBox(),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: cards.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.05),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.6,
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: FlipCard(
                                controller: controllers[index],
                                flipOnTouch: false,
                                fill: Fill
                                    .fillBack, // Fill the back side of the card to make in the same size as the front.
                                direction: FlipDirection.HORIZONTAL, // default
                                side: CardSide.FRONT,
                                front: Container(
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(20.0),
                                      color: Colors.blue.withOpacity(0.2)),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            child: Center(
                                              child: Text(
                                                cards[index].textEs,
                                                style: const TextStyle(
                                                    fontSize: 30.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: GridView.builder(
                                            itemCount: 4,
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              childAspectRatio: 2,
                                              mainAxisSpacing: 10.0,
                                              crossAxisSpacing: 10.0,
                                            ),
                                            itemBuilder:
                                                (BuildContext context, int i) {
                                              return ElevatedButton(
                                                onPressed: () {
                                                  checkAnswer(
                                                      index,
                                                      randomIndexesPerCard[
                                                          index][i]);
                                                },
                                                child: Text(cards[
                                                        randomIndexesPerCard[
                                                            index][i]]
                                                    .name),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                back: Container(
                                  width:
                                      MediaQuery.of(context).size.width - 25.0,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(
                                              0.5), // Color de la sombra
                                          spreadRadius:
                                              5, // Distancia de la sombra
                                          blurRadius:
                                              7, // Desenfoque de la sombra
                                          offset: const Offset(0,
                                              3), // Desplazamiento de la sombra
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(20.0),
                                      color: Colors.white),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        20.0), // Bordes redondeados para la imagen
                                    child: Image.network(
                                      cards[index].src,

                                      // fit: BoxFit
                                      //     .fill, // La imagen ocupará todo el espacio disponible sin distorsionarse
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
