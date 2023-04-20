import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeApp extends StatefulWidget {
  @override
  _RecipeAppState createState() => _RecipeAppState();
}

class _RecipeAppState extends State<RecipeApp> {
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.menu,
                color: Colors.black,
              ),
            )
          ],
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
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
              return Text('Bir şeyler ters gitti!');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Yükleniyor...');
            }

            List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
//List of exist recipe ui
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot document = documents[index];
                String ingredients = document['ingredients'];
                String steps = document['steps'];
                return ListTile(
                  title: Text(document['name']),
                  subtitle: Text(ingredients),
                  onTap: () => _showRecipeDetails(context, document),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _updateRecipe(document, context),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Tarifi Sil'),
                              content: Text(
                                  'Bu tarifi silmek istediğinize emin misiniz?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('İptal'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    document.reference.delete();
                                    Navigator.pop(context);
                                  },
                                  child: Text('Sil'),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff129575),
        child: Icon(Icons.add),
        onPressed: () => _addRecipe(context),
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
                Text('Malzemeler: \n'),
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
                SizedBox(height: 8.0),
                Text("Tarif Özeti:\n"),
                Text(document['summary']),
                SizedBox(height: 16.0),
                Text('Tarif Aşamaları:'),
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
              child: Text('Kapat'),
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
          title: Text('Tarif Ekle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Tarif Adı',
                  ),
                ),
                SizedBox(height: 8.0),
                TextField(
                  controller: ingredientsController,
                  decoration: InputDecoration(
                    labelText: 'Malzemeler (virgülle ayrılmış)',
                  ),
                ),
                SizedBox(height: 8.0),
                TextField(
                  controller: summaryController,
                  decoration: InputDecoration(
                    labelText: 'Tarif Özeti',
                  ),
                ),
                SizedBox(height: 8.0),
                TextField(
                  controller: stepsController,
                  decoration: InputDecoration(
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
              child: Text('İptal'),
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
                    SnackBar(content: Text('Lütfen tüm alanları doldurun')),
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
              child: Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

//delete
  void _deleteRecipe(DocumentSnapshot document) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tarifi Sil'),
          content: Text('Bu tarifi silmek istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hayır'),
            ),
            TextButton(
              onPressed: () async {
                await document.reference.delete();
                Navigator.pop(context);
              },
              child: Text('Evet'),
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
        title: Text('Tarifi Güncelle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Tarif Adı',
                ),
              ),
              TextField(
                controller: ingredientsController,
                decoration: InputDecoration(
                  hintText: 'Malzemeler (virgülle ayırın)',
                ),
                minLines: 3,
                maxLines: null,
              ),
              TextField(
                controller: summaryController,
                decoration: InputDecoration(
                  hintText: 'Tarif Özeti',
                ),
                minLines: 3,
                maxLines: null,
              ),
              TextField(
                controller: stepsController,
                decoration: InputDecoration(
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
            child: Text('İptal'),
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
            child: Text('Güncelle'),
          ),
        ],
      );
    },
  );
}
