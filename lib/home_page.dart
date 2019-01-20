import "package:flutter/material.dart";

import "following_list_view.dart" show FollowingListView;

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _SearchUsersDelegate _searchDelegate;

  _HomePageState() {
    _searchDelegate = _SearchUsersDelegate();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Insta Cleaner",
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            IconButton(
              tooltip: "Pesquisar",
              icon: Icon(
                Icons.search,
                color: Colors.black87,
              ),
              onPressed: () => _spawnSearch(context),
            ),
          ],
        ),
        body: FollowingListView(),
      );

  Future<void> _spawnSearch(BuildContext context) async => await showSearch<String>(
        context: context,
        delegate: _searchDelegate,
      );
}

class _SearchUsersDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    if (query.isEmpty) {
      return [];
    }

    return [
      IconButton(
        tooltip: "Limpar",
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: "Voltar",
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => FollowingListView();

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(child: Text("Sem histórico de pesquisa"));
    // final history = _searchHistoryService.getHistory();

    // return history.isEmpty
    //     ? Center(
    //         child: Text("Sem histórico de pesquisa"),
    //       )
    //     : ListView(
    //         children: history.map((text) => _buildShowTile(context, text)).toList(),
    //       );
  }

  @override
  void showResults(BuildContext context) {
    // _searchHistoryService.putAndReorder(query);

    super.showResults(context);
  }

  // Widget _buildShowTile(BuildContext context, String name) {
  //   return ListTile(
  //     leading: Icon(Icons.history),
  //     trailing: IconButton(
  //       icon: Icon(
  //         Icons.call_made,
  //         textDirection: TextDirection.rtl,
  //       ),
  //       onPressed: () => query = name,
  //     ),
  //     title: Text(name),
  //     onTap: () {
  //       query = name;
  //       showResults(context);
  //     },
  //   );
  // }
}
