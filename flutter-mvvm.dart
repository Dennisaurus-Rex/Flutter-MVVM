import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NetworkRepository {
  Future<List<String>> fetchData() async {
    final List<String> data = [];
    // Do network stuff
    return data;
  }
}

class Viewmodel extends ChangeNotifier {
  final NetworkRepository _repository = NetworkRepository();

  ViewState _state = ViewState.initial;
  List<String> _content = [];
  
  void _setState(ViewState state) {
    _state = state;
    notifyListeners();
  }

  ViewState get state => _state;
  List<String> get content => _content;

  Future<void> attach() async {
    _setState(ViewState.loading);
    try {
      final data = await _repository.fetchData();
      // Modify the data
      _content = data;
      _setState(ViewState.content);
    } catch (e) {
      _setState(ViewState.error);
    }
  }
}

enum ViewState {
  initial, loading, content, error
}

class UIWidget extends StatelessWidget {
  final Viewmodel viewmodel;

  const UIWidget({Key? key, required this.viewmodel}) : super(key: key);

  void _attachViewmodel() {
    viewmodel.attach();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // NotifiedWidget implementation below
      body: NotifiedWidget<Viewmodel>(
        viewmodel: viewmodel,
        builder: (context, viewmodel) {
          switch (viewmodel.state) {
            case ViewState.initial:
              _attachViewmodel();
              return Text('');
            case ViewState.loading:
              return Center(child: CircularProgressIndicator());
            case ViewState.content:
              return ListView.builder(
                itemBuilder: (context, index) => Text(viewmodel.content[index])
              );
            case ViewState.error:
              return Text('Oh no!'); 
          }
        }
      ),
    );
  }
}

class NotifiedWidget<T extends ChangeNotifier> extends StatelessWidget {
  final T viewmodel;
  final Widget Function(BuildContext context, T viewmodel) builder;

  const NotifiedWidget({Key? key, required this.viewmodel, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<T>(
      create: (context) => viewmodel,
      dispose: (context, viewmodel) => viewmodel.dispose(),
      builder: (context, _) => Consumer<T>(
        builder: (context, viewmodel, _) => builder(context, viewmodel)
      ),
    );
  }
}
