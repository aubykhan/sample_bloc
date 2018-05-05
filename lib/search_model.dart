import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:rxdart/rxdart.dart';

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