import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'GitHub Job Search'),
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
          new Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              onChanged: bloc.query.add,
              decoration: InputDecoration(
                icon: Icon(Icons.search),
                hintText: 'Search job',
              ),
            ),
          ),
          _buildPreamble(),
          new Flexible(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildPreamble() => StreamBuilder(
        stream: bloc.preamble,
        builder: (_, snapshot) => Text(snapshot?.data ?? ''),
      );

  Widget _buildResults() {
    return StreamBuilder(
      stream: bloc.results,
      initialData: [],
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          var list = snapshot?.data as List;
          return list.length > 0
              ? ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, index) => ListTile(
                        title: Text(snapshot?.data[index]),
                      ),
                )
              : Center(child: Text('No data found'));
        } else {
          return Text('Not found');
        }
      },
    );
  }
}

class SearchBloc {
  final Api api;

  Stream<String> _preamble = new Stream.empty();
  Stream<String> get preamble => _preamble;

  Stream<List<String>> _results = new Stream.empty();
  Stream<List<String>> get results => _results;

  //With RxDart
  ReplaySubject<String> _query = new ReplaySubject<String>();

  //With built-in streams
  //StreamController<String> _query = new StreamController<String>();
  Sink<String> get query => _query;

  SearchBloc(this.api) {
    //With RxDart
    _results = _query
        .distinct()
        .asyncMap(api.search)
        .asBroadcastStream();

    _preamble = new Observable(results)
        .withLatestFrom(_query.stream, (_, query) => 'Results for $query')
        .asBroadcastStream();

    //With built-in stream
    //_results = _query.stream.asyncMap(api.search).asBroadcastStream();
  }

  void dispose() {
    _query.close();
  }
}

class Api {
  final HttpClient _client = new HttpClient();
  static const String _url =
      'https://jobs.github.com/positions.json?description={0}';

  Future<List<String>> search(String query) async {
    var request =
        await _client.getUrl(Uri.parse(_url.replaceFirst('{0}', query)));
    var response = await request.close();

    List<String> list = await response
        .transform(utf8.decoder)
        .transform(json.decoder)
        .expand((json) => json as List)
        .map((json) => (json as Map)['title'] as String)
        .toList();

    return list;
  }
}
