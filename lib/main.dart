import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart'; // Import pour SystemNavigator
import 'package:clipboard/clipboard.dart';
import 'dart:io'; // Pour gérer les exceptions de socket
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TranslateScreen(),
    );
  }
}

class TranslateScreen extends StatefulWidget {
  @override
  _TranslateScreenState createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  TextEditingController _controller = TextEditingController();
  String _translatedText = '';
  String _selectedSourceLang = 'fr'; // Langue source par défaut
  String _selectedTargetLang = 'dyu'; // Langue cible par défaut
  FlutterTts flutterTts = FlutterTts();
  double _speechRate = 0.5; // Vitesse de lecture initiale
  final FocusNode _focusNode = FocusNode();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  TextEditingController _searchController = TextEditingController();
  // String _currentImage = 'assets/images/suggestion.png'; // Image par défaut
  String _currentImage = 'assets/images/menu.png'; // Image par défaut

  int _wordCount = 0;

  bool _isLoading = false; // Indicateur de chargement
  bool _isPlaying = false; // Indicateur de lecture
  bool _isSpeaking = false;
  bool _isSpeaking_userText = false;
  bool _isclick = false;

  // List<String> suggestions = [
  //   'Bonjour',
  //   'Bien',
  //   'Rire',
  //   'Okay',
  //   'Not',
  //   'Kouame',
  //   'Bosson',
  //   'Badou',
  //   'Thibaut',
  //   'Maintenant'
  // ];
  final List<String> suggestions = [
    'Bonjour',
    'Bonsoir',
    'Comment vas-tu ?',
    'Merci',
  ];
  List<String> filteredSuggestions = [];

  // @override
  // void initState() {
  //   super.initState();
  //   filteredSuggestions = suggestions;
  //   _searchController.addListener(_filterSuggestions);
  // }

  void _updateWordCount() {
    setState(() {
      _wordCount = _controller.text.trim().isEmpty
          ? 0
          : _controller.text.trim().split(RegExp(r'\s+')).length;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateWordCount);
    // super.initState();
    // filteredSuggestions = suggestions;
    filteredSuggestions = List.from(suggestions);
    _searchController.addListener(() {
      _filterSuggestions(_searchController.text);
    });
    // _searchController.addListener(_filterSuggestions);
  }

  void _filterSuggestions(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredSuggestions = List.from(suggestions);
      } else {
        filteredSuggestions = suggestions.where((suggestion) {
          return suggestion.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_updateWordCount);
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> translateText(String text) async {
    text = text.trim();

    if (text.isEmpty) {
      setState(() {
        _translatedText = 'Entrez un texte à traduire';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http
          .post(
            //lien vers API
            Uri.parse(''),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'text': text,
              'source': _selectedSourceLang,
              'target': _selectedTargetLang,
            }),
          )
          .timeout(Duration(seconds: 10)); // Délai d'attente de 10 secondes

      await Future.delayed(Duration(
          seconds: 3)); // Délai de 3 secondes avant d'afficher la traduction

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        setState(() {
          _translatedText = jsonDecode(response.body)['translatedText'];
        });
      } else {
        setState(() {
          _translatedText = 'Erreur de traduction';
        });
      }
    } on SocketException catch (_) {
      setState(() {
        _isLoading = false;
        _translatedText = 'Connexion à l\'API temporairement interrompue';
      });
    } on http.ClientException catch (_) {
      setState(() {
        _isLoading = false;
        _translatedText = 'Connexion à l\'API temporairement interrompue';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _translatedText = 'Connexion temporairement interrompue';
      });
    }
  }

  Future<void> speak(String text) async {
    String languageCode;
    if (_selectedTargetLang == 'fr') {
      languageCode = 'fr-FR';
    } else if (_selectedTargetLang == 'dyu') {
      languageCode = 'dyu-DYU';
    } else if (_selectedTargetLang == 'agni') {
      languageCode = 'agni';
    } else {
      languageCode = 'en-US';
    }

    if (_isPlaying) {
      await flutterTts.stop();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await flutterTts.setLanguage(languageCode);
      await flutterTts.setPitch(1.0);
      await flutterTts.setSpeechRate(_speechRate);
      await flutterTts.speak(text);
      setState(() {
        _isPlaying = true;
      });

      flutterTts.setCompletionHandler(() {
        setState(() {
          _isPlaying = false;
        });
      });
    }

    // if (_isSpeaking) {
    //   await flutterTts.stop();
    //   setState(() {
    //     _isSpeaking = false;
    //   });
    // } else {
    //   await flutterTts.setLanguage(languageCode);
    //   await flutterTts.setPitch(1.0);
    //   await flutterTts.setSpeechRate(_speechRate);
    //   await flutterTts.speak(text);
    //   setState(() {
    //     _isSpeaking = true;
    //   });

    //   flutterTts.setCompletionHandler(() {
    //     setState(() {
    //       _isSpeaking = false;
    //     });
    //   });
    // }

    // if (_isSpeaking_userText) {
    //   await flutterTts.stop();
    //   setState(() {
    //     _isSpeaking_userText = false;
    //   });
    // } else {
    //   await flutterTts.setLanguage(languageCode);
    //   await flutterTts.setPitch(1.0);
    //   await flutterTts.setSpeechRate(_speechRate);
    //   await flutterTts.speak(text);
    //   setState(() {
    //     _isSpeaking_userText = true;
    //   });

    //   flutterTts.setCompletionHandler(() {
    //     setState(() {
    //       _isSpeaking_userText = false;
    //     });
    //   });
    // }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _selectedSourceLang;
      _selectedSourceLang = _selectedTargetLang;
      _selectedTargetLang = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        // systemOverlayStyle: SystemUiOverlayStyle(
        //   statusBarColor:
        //       Color.fromARGB(255, 255, 255, 255), // Couleur de la Status Bar
        //   statusBarIconBrightness:
        //       Brightness.light, // Icônes de la Status Bar (Blanc ou Noir)
        // ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                    color: Color.fromARGB(255, 232, 232, 232), width: 1),
              ),
              child: IconButton(
                icon: Icon(
                  CupertinoIcons.back,
                  color: Color.fromARGB(255, 41, 40, 40),
                  size: 22, // Taille souhaitée de l'icône
                ),
                onPressed: () {
                  // Action pour le bouton retour
                },
              ),
            ),
            Text(
              'FR-a-ECI',
              style: TextStyle(
                fontFamily: 'Quicksand', // Utiliser la police Quicksand
                fontWeight: FontWeight.w600,
              ),
            ),
            /*style: TextStyle(fontSize: 20)*/
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                    color: Color.fromARGB(255, 232, 232, 232), width: 1),
              ),
              child: IconButton(
                icon: Image.asset(
                  'assets/images/menu.png',
                  width: 17, // Largeur souhaitée
                  height: 17, // Hauteur souhaitée
                ),
                onPressed: () {
                  final RenderBox button =
                      context.findRenderObject() as RenderBox;
                  final RenderBox overlay = Overlay.of(context)
                      .context
                      .findRenderObject() as RenderBox;
                  final Offset position =
                      button.localToGlobal(Offset.zero, ancestor: overlay);

                  setState(() {
                    _currentImage =
                        'assets/images/ci.png'; // Nouvelle image lorsque le menu s'affiche
                  });

                  showMenu(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    context: context,
                    shadowColor: Color.fromARGB(255, 0, 0, 0),
                    position: RelativeRect.fromLTRB(
                      position.dx +
                          button.size.width -
                          10, // Décalage léger vers la gauche
                      position.dy -
                          button.size.height, // Juste au-dessus du bouton
                      overlay.size.width -
                          position.dx -
                          button.size.width +
                          10, // Espace à droite
                      position.dy +
                          button.size.height *
                              2, // Distance pour éviter le chevauchement
                    ),
                    items: [
                      PopupMenuItem(
                        child: Container(
                          width: 200, // Largeur augmentée
                          height:
                              250, // Hauteur fixe pour afficher la barre de recherche + éléments
                          child: StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return Column(
                                children: [
                                  TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Rechercher...',
                                      hintStyle: TextStyle(
                                        fontFamily:
                                            'Quicksand', // Utiliser la police Quicksand
                                        fontWeight: FontWeight.w600,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                        borderSide: BorderSide(
                                          color: const Color.fromARGB(255, 0, 0,
                                              0), // Couleur de la bordure
                                          width: 2.0, // Largeur de la bordure
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                        borderSide: BorderSide(
                                          color: Colors
                                              .grey, // Couleur de la bordure lorsque le champ n'est pas focus
                                          width: 1.0, // Largeur de la bordure
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                        borderSide: BorderSide(
                                          color: const Color.fromARGB(255, 0, 0,
                                              0), // Couleur de la bordure lorsque le champ est focus
                                          width: 2.0, // Largeur de la bordure
                                        ),
                                      ),
                                      suffixIcon:
                                          _searchController.text.isNotEmpty
                                              ? IconButton(
                                                  icon: Image.asset(
                                                    "assets/images/trash-can.png",
                                                    width: 18,
                                                    height: 18,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _searchController.clear();
                                                      filteredSuggestions =
                                                          suggestions; // Réinitialiser les suggestions
                                                    });
                                                  },
                                                )
                                              : null,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        // Supprime les espaces en trop avant de comparer
                                        String sanitizedValue = value
                                            .trim()
                                            .replaceAll(RegExp(r'\s+'), ' ');
                                        filteredSuggestions = suggestions
                                            .where((suggestion) => suggestion
                                                .toLowerCase()
                                                .contains(sanitizedValue
                                                    .toLowerCase()))
                                            .toList();
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: filteredSuggestions
                                            .map((suggestion) {
                                          return ListTile(
                                            title: Text(
                                              suggestion,
                                              style: TextStyle(
                                                fontFamily:
                                                    'Quicksand', // Utiliser la police Quicksand
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            onTap: () {
                                              print('Selected: $suggestion');
                                              Navigator.of(context).pop();
                                              _searchController.text =
                                                  suggestion;
                                              setState(() {
                                                _controller.text =
                                                    _searchController.text;
                                                _currentImage =
                                                    'assets/images/suggestion.png'; // Revenir à l'image initiale
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        value: null, // No value needed for scrolling container
                      ),
                    ],
                  ).then((_) {
                    // Remettre l'image initiale lorsque le menu contextuel disparaît
                    setState(() {
                      _currentImage = 'assets/images/suggestion.png';
                    });
                  });
                },
              ),
            ),
          ],
        ),
        // backgroundColor: Colors.,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 130.0,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Color.fromARGB(255, 232, 232, 232), width: 1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: DropdownButton<String>(
                      iconSize: 0,
                      value: _selectedSourceLang,
                      items: [
                        DropdownMenuItem(
                          value: 'fr',
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Image.asset('assets/images/france.png',
                                  width: 24,
                                  height:
                                      24), // Chemin vers l'image de la France
                              SizedBox(width: 8),
                              Text(
                                'Français',
                                style: TextStyle(
                                  color: const Color.fromARGB(
                                      255, 0, 0, 0), // Couleur rouge
                                  fontWeight: FontWeight.bold, // Texte en gras
                                ),
                              ),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'dyu',
                          child: Row(
                            children: [
                              Image.asset('assets/images/ci.png',
                                  width: 24,
                                  height: 24), // Chemin vers l'image de Dioula
                              SizedBox(width: 8),
                              Text(
                                'Dioula',
                                style: TextStyle(
                                  color: const Color.fromARGB(
                                      255, 0, 0, 0), // Couleur rouge
                                  fontWeight: FontWeight.bold, // Texte en gras
                                ),
                              ),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'agni',
                          child: Row(
                            children: [
                              Image.asset('assets/images/ci.png',
                                  width: 24,
                                  height: 24), // Chemin vers l'image de Agni
                              SizedBox(width: 8),
                              Text(
                                'Agni',
                                style: TextStyle(
                                  color: const Color.fromARGB(
                                      255, 0, 0, 0), // Couleur rouge
                                  fontWeight: FontWeight.bold, // Texte en gras
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedSourceLang = value!;
                        });
                      },
                      borderRadius: BorderRadius.circular(5),
                      dropdownColor: Colors.white,
                      underline: SizedBox(), // Retirer la ligne soulignée
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _swapLanguages,
                    child: Image.asset(
                      'assets/images/changer.png', // Remplacez par le chemin de votre image
                      width: 17, // Ajustez la taille de l'image si nécessaire
                      height: 17,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(16),
                    ),
                  ),
                  Container(
                    width: 130.0,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Color.fromARGB(255, 232, 232, 232), width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: DropdownButton<String>(
                      value: _selectedTargetLang,
                      iconSize: 0,
                      items: [
                        DropdownMenuItem(
                          value: 'fr',
                          child: Row(
                            children: [
                              Image.asset('assets/images/france.png',
                                  width: 24,
                                  height:
                                      24), // Chemin vers l'image de la France
                              SizedBox(width: 8),
                              Text(
                                'Français',
                                style: TextStyle(
                                  color: const Color.fromARGB(
                                      255, 0, 0, 0), // Couleur rouge
                                  fontWeight: FontWeight.bold, // Texte en gras
                                ),
                              ),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'dyu',
                          child: Row(
                            children: [
                              Image.asset('assets/images/ci.png',
                                  width: 24,
                                  height: 24), // Chemin vers l'image de Dioula
                              SizedBox(width: 8),
                              Text(
                                'Dioula',
                                style: TextStyle(
                                  color: const Color.fromARGB(
                                      255, 0, 0, 0), // Couleur rouge
                                  fontWeight: FontWeight.bold, // Texte en gras
                                ),
                              ),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'agni',
                          child: Row(
                            children: [
                              Image.asset('assets/images/ci.png',
                                  width: 24,
                                  height: 24), // Chemin vers l'image de Agni
                              SizedBox(width: 8),
                              Text(
                                'Agni',
                                style: TextStyle(
                                  color: const Color.fromARGB(
                                      255, 0, 0, 0), // Couleur rouge
                                  fontWeight: FontWeight.bold, // Texte en gras
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedTargetLang = value!;
                        });
                      },

                      borderRadius: BorderRadius.circular(10),
                      dropdownColor: Colors.white,
                      underline: SizedBox(), // Retirer la ligne soulignée
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Stack(
                children: [
                  TextField(
                    controller: _controller,
                    style: TextStyle(
                      fontFamily: 'Quicksand', // Utiliser la police Quicksand
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    onChanged: (text) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Entrez le texte',
                      hintFadeDuration: Durations.medium4,
                      hintStyle: TextStyle(
                          // color: const Color.fromARGB(
                          //     255, 0, 0, 0), // Couleur du hintText
                          fontSize: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 232, 232, 232),
                          width: 1.2, // Augmentez l'épaisseur de la bordure ici
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 232, 232, 232),
                          width: 1.2, // Augmentez l'épaisseur de la bordure ici
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 232, 232, 232),
                          width: 1.2, // Augmentez l'épaisseur de la bordure ici
                        ),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 23, vertical: 19),
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    minLines: 10, // Augmente la hauteur de l'input
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(
                            height: 25,
                            color: Color.fromARGB(255, 232, 232, 232),
                            thickness: 1.6,
                            indent:
                                8, // Ajoute une marge de 20 pixels sur le côté gauche
                            endIndent:
                                17, // Ajoute une marge de 20 pixels sur le côté droit
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        8.0), // Ajoute de l'espace à gauche du texte
                                child: Text(
                                  '${_controller.text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF000000),
                                    fontFamily:
                                        'NotoSans', // Utiliser la police Quicksand
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                ' / 50',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF989898),
                                  fontFamily:
                                      'NotoSans', // Utiliser la police Quicksand
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Spacer(), // Espace entre le texte et les icônes pour les pousser vers la droite
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        10.0), // Ajoute un peu d'espace à droite du Spacer
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Afficher le bouton uniquement si le contrôleur n'est pas vide
                                    if (_controller.text.isNotEmpty)
                                      IconButton(
                                        icon: Image.asset(
                                          'assets/images/star.png', // Icône pour commencer la lecture
                                          width: 17.0,
                                          height: 17.0,
                                        ),
                                        onPressed: () {
                                          // speak(_controller.text);
                                          _controller.clear();
                                          _updateWordCount();
                                          // Vide le contenu du contrôleur
                                        },
                                      ),
                                    IconButton(
                                      icon: Image.asset(
                                        'assets/images/record.png',
                                        width:
                                            19.0, // Ajuste la largeur selon tes besoins
                                        height:
                                            19.0, // Ajuste la hauteur selon tes besoins
                                      ),
                                      onPressed: () {
                                        _isPlaying = false;
                                        print("is : $_isPlaying");
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              backgroundColor: Colors.white,
                                              title: Row(
                                                children: [
                                                  Image.asset(
                                                    "assets/images/warning.png",
                                                    width:
                                                        24, // Ajuste la largeur selon tes besoins
                                                    height:
                                                        24, // Ajuste la hauteur selon tes besoins
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 7)),
                                                  Text(
                                                    "Information",
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  // Image.asset(
                                                  //   "assets/images/plane.webp",
                                                  //   width:
                                                  //       50, // Ajuste la largeur selon tes besoins
                                                  //   height:
                                                  //       50, // Ajuste la hauteur selon tes besoins
                                                  // ),
                                                  SizedBox(
                                                      width:
                                                          8), // Espace entre l'icône et le titre
                                                ],
                                              ),
                                              content: Text(
                                                "Cette fonctionnalité sera bientôt disponible...😊",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text(
                                                    "OK",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Ferme la boîte de dialogue
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        speak(
                                            "Cette fonctionnalité sera bientôt disponible...");
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                      color: Color.fromARGB(255, 232, 232, 232),
                      width: 1.2), // Bordure grise
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _isLoading
                          ? SpinKitWanderingCubes(
                              color: Colors.black,
                              size: 20.0,
                            )
                          : Padding(
                              padding: EdgeInsets.only(
                                top: 20,
                                left: 20.0,
                                right: 20.0,
                              ),
                              child: Align(
                                alignment: Alignment
                                    .topLeft, // Aligne le texte en haut à gauche
                                child: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 300),
                                  child: _translatedText.isEmpty
                                      ? SizedBox
                                          .shrink() // Affiche rien quand le texte est vide
                                      : AnimatedTextKit(
                                          key:
                                              ValueKey<String>(_translatedText),
                                          animatedTexts: [
                                            TypewriterAnimatedText(
                                              _translatedText,
                                              textStyle: TextStyle(
                                                  fontSize: 16.0,
                                                  fontFamily:
                                                      'Quicksand', // Utiliser la police Quicksand
                                                  fontWeight: FontWeight.w600),
                                              speed:
                                                  Duration(milliseconds: 100),
                                            ),
                                          ],
                                          totalRepeatCount: 1,
                                        ),
                                ),
                              ),
                            ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(
                            height: 0,
                            color: Color.fromARGB(255, 232, 232, 232),
                            thickness: 1.6,
                            indent: 4,
                            endIndent: 15,
                          ),
                          SizedBox(height: 12.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(width: 4),
                                  Text(
                                    '${_translatedText.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF000000),
                                      fontFamily:
                                          'NotoSans', // Utiliser la police Quicksand
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    ' / 50',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF989898),
                                      fontFamily:
                                          'NotoSans', // Utiliser la police Quicksand
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Image.asset(
                                      _isPlaying
                                          ? 'assets/images/arretez.png'
                                          : 'assets/images/haut-parleur-audio.png',
                                      width: 19.0,
                                      height: 19.0,
                                    ),
                                    onPressed: () {
                                      if (_translatedText.isEmpty) {
                                        speak(
                                            "Aucun texte à traduire, entrez d'abord un texte");
                                      } else {
                                        speak(_translatedText);
                                      }
                                    },
                                  ),
                                  SizedBox(width: 8),
                                  IconButton(
                                    icon: Image.asset(
                                      'assets/images/copie.png',
                                      width: 17.0,
                                      height: 17.0,
                                    ),
                                    onPressed: () {
                                      if (_translatedText.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Aucune traduction à copier')),
                                        );
                                      } else {
                                        FlutterClipboard.copy(_translatedText)
                                            .then((value) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text('Texte copié!')),
                                          );
                                        });
                                      }
                                    },
                                  ),
                                  SizedBox(width: 8),
                                  _translatedText.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(
                                            Icons
                                                .clear, // Icône pour vider le texte
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _translatedText =
                                                  ''; // Vide le texte traduit
                                              print('Texte vidé'); // Debug
                                            });
                                          },
                                        )
                                      : SizedBox
                                          .shrink(), // Affiche rien si le texte est vide
                                  // Affiche rien si le texte est vide
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Vérifie si le texte est vide
                        if (_controller.text.isEmpty) {
                          // Affiche un message d'erreur
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Entrez d\'abord un texte'),
                            ),
                          );
                          // Focus sur le champ de saisie pour réactiver l'input
                          FocusScope.of(context).requestFocus(_focusNode);
                        } else {
                          // Appelle la fonction de traduction si le texte n'est pas vide
                          translateText(_controller.text);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(
                            255, 0, 0, 0), // Couleur de fond du bouton Traduire
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 20.0), // Hauteur du bouton Traduire
                      ),
                      child: Text(
                        'Traduire',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily:
                              'Quicksand', // Utiliser la police Quicksand
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     speak(_translatedText);
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor:
                  //         Color(0xFFA020F0), // Couleur de fond du bouton Lire
                  //     shape: CircleBorder(),
                  //     padding: EdgeInsets.all(16),
                  //   ),
                  //   child: Icon(
                  //     _isPlaying ? Icons.stop : Icons.volume_up,
                  //     color: Colors.white,
                  //   ),
                  // ),

                  // IconButton(
                  //   icon: Image.asset(
                  //     _currentImage, // Chemin vers l'image actuelle
                  //     width: 20.0,
                  //     height: 20.0,
                  //   ),
                  //   onPressed: () {
                  //     final RenderBox button =
                  //         context.findRenderObject() as RenderBox;
                  //     final RenderBox overlay = Overlay.of(context)
                  //         .context
                  //         .findRenderObject() as RenderBox;
                  //     final Offset position =
                  //         button.localToGlobal(Offset.zero, ancestor: overlay);

                  //     setState(() {
                  //       _currentImage =
                  //           'assets/images/cross.png'; // Nouvelle image lorsque le menu s'affiche
                  //     });

                  //     showMenu(
                  //       color: const Color.fromARGB(255, 255, 255, 255),
                  //       context: context,
                  //       shadowColor: Color.fromARGB(255, 0, 0, 0),
                  //       position: RelativeRect.fromLTRB(
                  //         position.dx +
                  //             button.size.width -
                  //             10, // Décalage léger vers la gauche
                  //         position.dy -
                  //             button.size.height, // Juste au-dessus du bouton
                  //         overlay.size.width -
                  //             position.dx -
                  //             button.size.width +
                  //             10, // Espace à droite
                  //         position.dy +
                  //             button.size.height *
                  //                 2, // Distance pour éviter le chevauchement
                  //       ),
                  //       items: [
                  //         PopupMenuItem(
                  //           child: Container(
                  //             width: 200, // Largeur augmentée
                  //             height:
                  //                 190, // Hauteur fixe pour afficher la barre de recherche + éléments
                  //             child: StatefulBuilder(
                  //               builder: (BuildContext context,
                  //                   StateSetter setState) {
                  //                 return Column(
                  //                   children: [
                  //                     TextField(
                  //                       controller: _searchController,
                  //                       decoration: InputDecoration(
                  //                         hintText: 'Rechercher...',
                  //                         border: OutlineInputBorder(
                  //                           borderRadius:
                  //                               BorderRadius.circular(4.0),
                  //                           borderSide: BorderSide(
                  //                               color: Colors.black,
                  //                               width: 2.0), // Bordure noire
                  //                         ),
                  //                         enabledBorder: OutlineInputBorder(
                  //                           borderSide: BorderSide(
                  //                               width: 1.0,
                  //                               color: Color.fromARGB(255, 0, 0,
                  //                                   0)), // Bordure noire
                  //                         ),
                  //                         focusedBorder: OutlineInputBorder(
                  //                           borderSide: BorderSide(
                  //                               width: 1.4,
                  //                               color: Color.fromARGB(255, 0, 0,
                  //                                   0)), // Bordure noire
                  //                         ),
                  //                       ),
                  //                       onChanged: (value) {
                  //                         setState(() {
                  //                           // Supprime les espaces en trop avant de comparer
                  //                           String sanitizedValue = value
                  //                               .trim()
                  //                               .replaceAll(
                  //                                   RegExp(r'\s+'), ' ');
                  //                           filteredSuggestions = suggestions
                  //                               .where((suggestion) =>
                  //                                   suggestion
                  //                                       .toLowerCase()
                  //                                       .contains(sanitizedValue
                  //                                           .toLowerCase()))
                  //                               .toList();
                  //                         });
                  //                       },
                  //                     ),
                  //                     Expanded(
                  //                       child: SingleChildScrollView(
                  //                         child: Column(
                  //                           children: filteredSuggestions
                  //                               .map((suggestion) {
                  //                             return ListTile(
                  //                               title: Text(suggestion),
                  //                               onTap: () {
                  //                                 print(
                  //                                     'Selected: $suggestion');
                  //                                 Navigator.of(context).pop();
                  //                                 _searchController.text =
                  //                                     suggestion;
                  //                                 setState(() {
                  //                                   _controller.text =
                  //                                       _searchController.text;
                  //                                   _currentImage =
                  //                                       'assets/images/menu.png'; // Revenir à l'image initiale
                  //                                 });
                  //                               },
                  //                             );
                  //                           }).toList(),
                  //                         ),
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 );
                  //               },
                  //             ),
                  //           ),
                  //           value:
                  //               null, // No value needed for scrolling container
                  //         ),
                  //       ],
                  //     ).then((_) {
                  //       // Remettre l'image initiale lorsque le menu contextuel disparaît
                  //       setState(() {
                  //         _currentImage = 'assets/images/menu.png';
                  //       });
                  //     });
                  //   },
                  // ),
                  IconButton(
                    icon: Image.asset(
                      'assets/images/partir.png', // Chemin vers l'image
                      width: 18.0,
                      height: 18.0,
                    ),
                    onPressed: () {
                      // Affiche une boîte de dialogue de confirmation
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor:
                                Colors.white, // Fond blanc pour le dialog
                            title: Row(
                              children: [
                                Icon(
                                  Icons.clear,
                                  color: Colors.red,
                                ),
                                SizedBox(
                                    width:
                                        8), // Espacement entre l'icône et le texte
                                Text(
                                  'Confirmation',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            content: Text('Voulez-vous vraiment quitter?'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Non'),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Ferme le dialog
                                },
                              ),
                              TextButton(
                                child: Text('Oui'),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Ferme le dialog
                                  SystemNavigator.pop(); // Quitte l'application
                                },
                              ),
                            ],
                          );
                          ;
                        },
                      );
                    },
                  )
                ],
              ),
              SizedBox(height: 20),
              // Text(
              //   'Vitesse de lecture:',
              //   style: TextStyle(fontSize: 16),
              // ),
              // Slider(
              //   value: _speechRate,
              //   onChanged: (newRate) {
              //     setState(() {
              //       _speechRate = newRate;
              //     });
              //   },
              //   min: 0.1,
              //   max: 1.0,
              //   divisions: 10,
              //   label: 'Vitesse de lecture: ${_speechRate.toStringAsFixed(1)}',
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
