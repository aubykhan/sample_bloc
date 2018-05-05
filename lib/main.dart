import 'package:app_bloc/search_model.dart';
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
