import 'dart:async';

import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SearchBloc bloc = new SearchBloc(new Api());

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          TextField(onChanged: bloc.query.add),
          _buildResults(),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return StreamBuilder(
      stream: bloc.results,
      builder: (_, snapshot) => ListView.builder(
            itemBuilder: (_, index) => ListTile(
                  title: Text(snapshot?.data[index]),
                ),
          ),
    );
  }
}

class Api {
  Future<List<String>> search(String query) async {
    return ['hey'];
  }
}

class SearchBloc {
  //final Sink<String> query = new StreamController();
  final Api api;

  Stream<List<String>> _results = new Stream.empty();
  Stream<List<String>> get results => _results;

  //With RxDart
  //ReplaySubject<String> _query = new ReplaySubject<String>();
  
  //With built-in streams
  StreamController<String> _query = new StreamController<String>();
  Sink<String> get query => _query;

  SearchBloc(this.api) {
    //With RxDart
    // _results = _query
    //   .observable
    //   .asyncMap(api.search)
    //   .asBroadcastStream();

    //With built-in stream
    _results = _query.stream.asyncMap(api.search).asBroadcastStream();
  }

  void dispose() {
    _query.close();
  }
}
