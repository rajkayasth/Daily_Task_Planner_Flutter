import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/task.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _taskController;
  late List<Task> _tasks;
  late List<bool> _taskDone;

  void saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Task t = Task.fromString(_taskController.text);
    /*prefs.setString('task', json.encode(t.getMap()));
    _taskController.text = '';*/
    //prefs.remove('task');

    String? tasks = prefs.getString('task');
    List list = (tasks == null) ? [] : json.decode(tasks);

    list.add(json.encode(t.getMap()));
    prefs.setString('task', json.encode(list));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(list.toString()),
    ));
    _taskController.text = '';
    Navigator.of(context).pop();
    _getTasks();
  }

  Future<void> _getTasks() async {
    _tasks = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasks = prefs.getString('task');
    List list = (tasks == null) ? [] : json.decode(tasks);
    for (dynamic d in list) {
      _tasks.add(Task.fromMap(json.decode(d)));
    }
    /*ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_tasks.toString()),
    ));*/
    _taskDone = List.generate(_tasks.length, (index) => false);
    setState(() {});
  }

  Future<void> updatePandingTaskList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<Task> pandingList = [];

    for(var i = 0; i < _tasks.length; i ++)
      if(!_taskDone[i]) pandingList.add(_tasks[i]);

      var pandingListEncoded = List.generate(pandingList.length, (i) => json.encode(pandingList[i].getMap()));
      prefs.setString('task', json.encode(pandingListEncoded));

      _getTasks();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _taskController = TextEditingController();

    _getTasks();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Task Manager',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          IconButton(icon:  Icon(CupertinoIcons.square_favorites_alt_fill),onPressed: updatePandingTaskList),
          IconButton(icon:  Icon(CupertinoIcons.delete_solid),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('task', json.encode([]));

                _getTasks();
          }

              )
        ],
      ),
      body: (_tasks == null)
          ? Center(
              child: Text('NO task Added Yet'),
            )
          : Column(
              children: _tasks
                  .map((e) => Flexible(
                        child: Container(
                          height: 200.0,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          padding: const EdgeInsets.only(left: 10.0),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(
                                color: Colors.black,
                                width: 0.5,
                              )),
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                e.task,
                                style: GoogleFonts.montserrat(),
                              ),
                              Checkbox(
                                value: _taskDone[_tasks.indexOf(e)],
                                onChanged: (val) {
                                  setState(() {
                                    _taskDone[_tasks.indexOf(e)] = val!;
                                  });
                                },
                                key: GlobalKey(),
                              )
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue,
        onPressed: () => showModalBottomSheet(
            context: context,
            builder: (BuildContext context) => Container(
                  padding: const EdgeInsets.all(10.0),
                  height: 250.0,
                  // height: 500,
                  color: Colors.blue[200],
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add Task',
                            style: GoogleFonts.montserrat(
                                fontSize: 20, color: Colors.white),
                          ),
                          GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                              )),
                        ],
                      ),
                      Divider(
                        thickness: 2,
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      TextField(
                        controller: _taskController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'Enter Task',
                          hintStyle: GoogleFonts.montserrat(),
                        ),
                      ),
                      // SizedBox(height: 20.0,),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        // height: 200.0,
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.0),
                              width:
                                  (MediaQuery.of(context).size.width / 2) - 10,
                              child: RaisedButton(
                                color: Colors.white54,
                                onPressed: () => _taskController.text = '',
                                child: Text(
                                  'RESET',
                                  style: GoogleFonts.montserrat(),
                                ),
                              ),
                            ),
                            //Divider(thickness: 2,),
                            Container(
                              padding: EdgeInsets.all(10.0),
                              width:
                                  (MediaQuery.of(context).size.width / 2) - 10,
                              child: RaisedButton(
                                color: Colors.blue[500],
                                onPressed: () => saveData(),
                                child: Text(
                                  'Add',
                                  style: GoogleFonts.montserrat(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
      ),
    );
  }


}
