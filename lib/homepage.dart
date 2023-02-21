import 'package:flutter/material.dart';
import 'sqlhelper.dart';

class home extends StatefulWidget {
  const home({Key? key}) : super(key: key);

  @override
  State<home> createState() => _homeState();
}
class _homeState extends State<home> {
  List<Map<String, dynamic>> _journals = []; //fetching all the data from database
  bool _isloading = true;

  void _refreshjournals() async {
    final data = await SQLhelper.getitems();
    setState(() {
      _journals = data;
      _isloading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshjournals(); //loading the dairy when the app start
  }

  final TextEditingController _titlecontroller = TextEditingController();
  final TextEditingController _desccontroller = TextEditingController();

  void showForm(int? id) async {
    if (id != null) {
      final _existingjournal =
          _journals.firstWhere((element) => element['id'] == id);
      _titlecontroller.text = _existingjournal['title'];
      _desccontroller.text = _existingjournal['description'];
    }
    showModalBottomSheet(
        context: context,
        elevation: 10,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                  top: 15,
                  right: 15,
                  left: 15,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 200),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _titlecontroller,
                    decoration: InputDecoration(hintText: 'title'),

                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _desccontroller,
                    decoration: InputDecoration(hintText: 'description'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (id == null) {
                          addItem();
                        }
                        if (id != null) {
                          updateItem(id);
                        }
                        _titlecontroller.text = '';
                        _desccontroller.text = '';
                        Navigator.of(context).pop();
                      },
                      child: Text(id == null ? 'create new' : 'update'))
                ],
              ),
            ));
  }

  Future<void> addItem() async {
    SQLhelper.createitems(_titlecontroller.text, _desccontroller.text);
    _refreshjournals();
  }

  Future<void> updateItem(id) async {
    SQLhelper.updateitem(id, _titlecontroller.text, _desccontroller.text);
    _refreshjournals();
  }

  Future<void> deleteItem(id) async {
    SQLhelper.deleteitem(id);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('succefully deleted')));
    _refreshjournals();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SQFlite'),
      ),
      body: _isloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _journals.length,
              itemBuilder: (context, index) => Card(
                   color: Colors.orange,
                    margin: EdgeInsets.all(20),
                    child: ListTile(
                      title: Text(_journals[index]['title']),
                      subtitle: Text(_journals[index]['description']),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(onPressed: ()=>showForm(_journals[index]['id']),
                                icon:Icon(Icons.edit)),
                            IconButton(onPressed: ()=>deleteItem(_journals[index]['id']),
                                icon:Icon(Icons.delete))
                          ],
                        ),
                      ),
                    ),
                  )),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () =>showForm(null),
      ),
    );
  }
}
