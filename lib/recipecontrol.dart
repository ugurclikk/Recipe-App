import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'controller/storage_controller.dart';
import 'firebase_notification.dart';
 FirebaseStorage storage = FirebaseStorage.instance;
class RecipeApp extends StatefulWidget {
  @override
  _RecipeAppState createState() => _RecipeAppState();
}

class _RecipeAppState extends State<RecipeApp> {
  Future<List<Map<String, dynamic>>> _loadImages() async {
    List<Map<String, dynamic>> files = [];
    FirebaseStorage storage = FirebaseStorage.instance;
    final ListResult result = await storage.ref().list();
    final List<Reference> allFiles = result.items;

    await Future.forEach<Reference>(allFiles, (file) async {
      final String fileUrl = await file.getDownloadURL();
      final FullMetadata fileMeta = await file.getMetadata();
      files.add({
        "url": fileUrl,
        "path": file.fullPath,
        "uploaded_by": fileMeta.customMetadata?['uploaded_by'] ?? 'Nobody',
        "description":
            fileMeta.customMetadata?['description'] ?? 'No description'
      });
    });

    return files;
  }

  //Controllers for inputs
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ingredientsController = TextEditingController();
  final TextEditingController summaryController = TextEditingController();
  final TextEditingController stepsController = TextEditingController();
  //connection to the firebase
  final CollectionReference recipeCollection =
      FirebaseFirestore.instance.collection('recipes');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.menu,
                color: Colors.black,
              ),
            )
          ],
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          )),
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: recipeCollection.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Bir şeyler ters gitti!');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Yükleniyor...');
            }

            List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
//List of exist recipe ui
            return FutureBuilder(
                future: _loadImages(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    var lst = snapshot.data as List;
                    return ListView.builder(
                      itemCount: lst.length>=documents.length?documents.length:documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          final Map<String, dynamic> image =
                              snapshot.data![index];
                          DocumentSnapshot document = documents[index];
                          String ingredients = document['ingredients'];
                          String steps = document['steps'];
                          return ListTile(
                            leading: Image.network(image["url"]),
                            title: Text(document['name']),
                            subtitle: Text(ingredients),
                            onTap: () => _showRecipeDetails(context, document),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _updateRecipe(document, context),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Tarifi Sil'),
                                        content: const Text(
                                            'Bu tarifi silmek istediğinize emin misiniz?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('İptal'),
                                          ),
                                          TextButton(
                                            onPressed: () async{
                                              document.reference.delete();
                                              await storage.ref(image["uploaded_by"]).delete();
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Sil'),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Text("");
                        }
                      },
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.cyanAccent,
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    );
                  }
                  ;
                });
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff129575),
        child: const Icon(Icons.add),
        onPressed: () async {
          await initMessaging();
          _addRecipe(context);
        },
      ),
    );
  }

//read
  void _showRecipeDetails(BuildContext context, DocumentSnapshot document) {
    String ingredients = document['ingredients'];
    String steps = document['steps'];
//separete operations
    List<String> stepsdetailed =
        steps.split('\n').map((e) => e.trim()).toList();
    List<String> ingredientsdetailed =
        ingredients.split(',').map((e) => e.trim()).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(document['name']),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                const Text('Malzemeler: \n'),
                Container(
                  width: 70,
                  height: 70,
                  child: ListView.builder(
                    itemCount: ingredientsdetailed.length,
                    itemBuilder: (context, index) {
                      return Text(ingredientsdetailed[index]);
                    },
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text("Tarif Özeti:\n"),
                Text(document['summary']),
                const SizedBox(height: 16.0),
                const Text('Tarif Aşamaları:'),
                Column(
                  children: List.generate(
                    stepsdetailed.length,
                    (index) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Text((index + 1).toString()),
                      ),
                      title: Text(stepsdetailed[index]),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

//create
  void _addRecipe(BuildContext context) {
    nameController.clear();
    ingredientsController.clear();
    summaryController.clear();
    stepsController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tarif Ekle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tarif Adı',
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: ingredientsController,
                  decoration: const InputDecoration(
                    labelText: 'Malzemeler (virgülle ayrılmış)',
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: summaryController,
                  decoration: const InputDecoration(
                    labelText: 'Tarif Özeti',
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: stepsController,
                  decoration: const InputDecoration(
                    labelText: 'Tarif Aşamaları (her satıra bir adım)',
                  ),
                  minLines: 3,
                  maxLines: null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () async {
                String name = nameController.text.trim();
                String ingredientsText = ingredientsController.text.trim();
                String summary = summaryController.text.trim();
                String stepsText = stepsController.text.trim();

                if (name.isEmpty ||
                    ingredientsText.isEmpty ||
                    summary.isEmpty ||
                    stepsText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Lütfen tüm alanları doldurun')),
                  );
                  return;
                }

                List<String> ingredients =
                    ingredientsText.split(',').map((e) => e.trim()).toList();
                List<String> stepsdetailed =
                    stepsText.split('\n').map((e) => e.trim()).toList();

                await recipeCollection.add({
                  'name': name,
                  'ingredients': ingredientsText,
                  'summary': summary,
                  'steps': stepsText,
                });

                Navigator.pop(context);
              },
              child: const Text('Ekle'),
            ),
            TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePagea(),
                      ));
                },
                child: const Text("Resim ekle")),
          ],
        );
      },
    );
  }

//delete
  void _deleteRecipe(DocumentSnapshot document,String ref) {
      FirebaseStorage storage = FirebaseStorage.instance;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tarifi Sil'),
          content: const Text('Bu tarifi silmek istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hayır'),
            ),
            TextButton(
              onPressed: () async {
                await document.reference.delete();
                await storage.ref(ref).delete();
                Navigator.pop(context);
              },
              child: const Text('Evet'),
            ),
          ],
        );
      },
    );
  }
}

//update
Future<void> _updateRecipe(
    DocumentSnapshot<Object?> document, BuildContext context) async {
  final TextEditingController nameController =
      TextEditingController(text: document['name']);
  final TextEditingController ingredientsController =
      TextEditingController(text: document['ingredients']);
  final TextEditingController summaryController =
      TextEditingController(text: document['summary']);
  final TextEditingController stepsController =
      TextEditingController(text: document['steps']);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Tarifi Güncelle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Tarif Adı',
                ),
              ),
              TextField(
                controller: ingredientsController,
                decoration: const InputDecoration(
                  hintText: 'Malzemeler (virgülle ayırın)',
                ),
                minLines: 3,
                maxLines: null,
              ),
              TextField(
                controller: summaryController,
                decoration: const InputDecoration(
                  hintText: 'Tarif Özeti',
                ),
                minLines: 3,
                maxLines: null,
              ),
              TextField(
                controller: stepsController,
                decoration: const InputDecoration(
                  hintText:
                      'Tarif Aşamaları (her adımı yeni bir satırda yazın)',
                ),
                minLines: 5,
                maxLines: null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('recipes')
                  .doc(document.id)
                  .update({
                'name': nameController.text,
                'ingredients': ingredientsController.text,
                'summary': summaryController.text,
                'steps': stepsController.text,
              });
              Navigator.pop(context);
            },
            child: const Text('Güncelle'),
          ),
        ],
      );
    },
  );
}
