import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Home_Page());
  }
}

class Todo {
  String Title;
  bool isCompleted;

  Todo({required this.Title, this.isCompleted = false});

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      Title: map['Title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Title': Title,
      'isCompleted': isCompleted,
    };
  }
}

class Home_Page extends StatefulWidget {
  const Home_Page({super.key});

  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  var NameController = TextEditingController().obs;
  RxList<Todo> AddList = <Todo>[].obs;

  @override
  void initState() {
    super.initState();
    GetData();
  }

  void GetData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? todoListString = prefs.getString('todoList');

    if (todoListString != null) {
      List<dynamic> decodedList = jsonDecode(todoListString);
      List<Todo> todoList =
          decodedList.map((item) => Todo.fromMap(item)).toList();
      AddList.assignAll(todoList);
    }
  }

  SetData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String todoListString =
        jsonEncode(AddList.map((todo) => todo.toMap()).toList());
    await prefs.setString('todoList', todoListString);
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double screenWidth = mediaQueryData.size.width;
    double screenHeight = mediaQueryData.size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Resume App'),
      ),
      body: Obx(
        () => Stack(
          children: [
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: AddList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Obx(
                          () => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: screenHeight / 10,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.black12),
                              child: Center(
                                  child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    width: screenWidth / 4,
                                    child: Text(
                                      overflow: TextOverflow.ellipsis,
                                      '${AddList[index].Title}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          NameController.value.text =
                                              AddList[index].Title;
                                          return AlertDialog(
                                            content: Container(
                                              height: screenHeight / 4,
                                              child: SingleChildScrollView(
                                                physics:
                                                    BouncingScrollPhysics(),
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20),
                                                      child: TextField(
                                                        controller:
                                                            NameController
                                                                .value,
                                                        decoration: InputDecoration(
                                                            border: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10))),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (NameController.value
                                                            .text.isNotEmpty) {
                                                          setState(() {});
                                                          AddList.value[index]
                                                                  .Title =
                                                              NameController
                                                                  .value.text;
                                                          SetData();
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                        NameController.value
                                                            .clear();
                                                      },
                                                      child: Container(
                                                        width: screenWidth / 8,
                                                        height:
                                                            screenHeight / 18,
                                                        decoration: BoxDecoration(
                                                            color:
                                                                Colors.black12,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        child: Center(
                                                            child: Text(
                                                          'Save',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      width: screenWidth / 8,
                                      height: screenHeight / 20,
                                      decoration: BoxDecoration(
                                          color: Colors.black12,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Center(
                                          child: Icon(
                                        Icons.edit,
                                        size: screenHeight / 25,
                                      )),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      AddList.removeAt(index);
                                      SetData();
                                    },
                                    child: Container(
                                      width: screenWidth / 8,
                                      height: screenHeight / 20,
                                      decoration: BoxDecoration(
                                          color: Colors.black12,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Center(
                                          child: Icon(
                                        Icons.delete,
                                        size: screenHeight / 25,
                                      )),
                                    ),
                                  ),
                                ],
                              )),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Obx(
                    () => Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: TextField(
                              controller: NameController.value,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10))),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (NameController.value.text.isNotEmpty) {
                              AddList.add(
                                  Todo(Title: NameController.value.text));
                              SetData();
                              NameController.value.clear();
                            }
                          },
                          child: Container(
                            width: screenWidth / 7,
                            height: screenHeight / 18,
                            decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                                child: Text(
                              'Add',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                          ),
                        ),
                        SizedBox(
                          width: screenWidth / 15,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: screenHeight / 2.5,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
