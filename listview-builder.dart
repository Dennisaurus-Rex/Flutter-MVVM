import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NetworkRepository {
  Future<List<dynamic>> fetchData() async {
    final List<dynamic> data = [];
    // Do network stuff
    return data;
  }
}

class Viewmodel extends ChangeNotifier {
  final NetworkRepository _repository = NetworkRepository();

  ViewState _state = ViewState.initial;
  List<WidgetModel> _content = [];
  
  void _setState(ViewState state) {
    _state = state;
    notifyListeners();
  }

  ViewState get state => _state;
  List<WidgetModel> get content => _content;

  Future<void> attach() async {
    _setState(ViewState.loading);
    try {
      final data = await _repository.fetchData();
      // Modify the data
      final modifiedData = data.modifications();
      _content = modifiedData;
      _setState(ViewState.content);
    } catch (e) {
      _setState(ViewState.error);
    }
  }
}

enum ViewState {
  initial, loading, content, error
}

class WidgetModel {
  final WidgetType type;
  // Any content needed by child widgets
  final String title;
  final List<OtherStuff> stuff;
}

enum WidgetType {
  feed, following, recent
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
                itemBuilder: (context, index) {
                  final model = viewmodel.content[index];
                  
                  switch (model.type) {
                    case WidgetType.feed:
                      return FeedWidget(model.title, model.stuff...);
                    case WidgetType.following:
                      return FollowingWidget(model.title, model.stuff...);
                    case WidgetType.recent:
                      return RecentWidget(model.title, model.stuff...);
                  }
                }
              );
            case ViewState.error:
              return Text('Oh no!'); 
          }
        }
      ),
    );
  }
}
