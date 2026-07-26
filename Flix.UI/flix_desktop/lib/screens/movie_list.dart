import 'package:flix_desktop/layouts/master_screen.dart';
import 'package:flix_desktop/models/movie.dart';
import 'package:flix_desktop/models/search_result.dart';
import 'package:flix_desktop/providers/movie_provider.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MovieList extends StatefulWidget {
  const MovieList({ Key? key, }) : super(key: key);

  @override
  _MovieListState createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  late MovieProvider _movieProvider;
  SearchResult<Movie>? result;
  bool isLoading = true;  

  TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _movieProvider = context.read<MovieProvider>();

    initTable();
  }

  Future<void> initTable() async {
    try {
      var data = await _movieProvider.get();

      setState(() {
        result = data;
        isLoading = false;
      });

    } on Exception catch (e) {
      alertBox(context, "Error", e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Movie list",
      destination: DrawerDestination.movies,
      child: Column(
        children: [
          _buildSearch(),
          isLoading ? CircularProgressIndicator() : _buildTable()
        ],
      )
    );
  }

  Expanded _buildTable() {
    return Expanded(
          child: SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              child: DataTable(
                columns: [
                  DataColumn(label: Text("Title")),
                  DataColumn(label: Text("Description")),
                  DataColumn(label: Text("Trailer")),
                  DataColumn(label: Text("Release Date")),
                  DataColumn(label: Text("Duration (min)")),
                  DataColumn(label: Text("Views")),
                  DataColumn(label: Text("Enabled")),
                  DataColumn(label: Text("Country")),
                  DataColumn(label: Text("Language")),
                ], 
                rows: result?.items
                ?.map(
                  (e) => DataRow(
                  cells: [
                    DataCell(Text(e.title ?? '')),
                    DataCell(Text(e.description ?? '')),
                    DataCell(Text(e.trailerUrl ?? '')),
                    DataCell(Text(e.releaseDate.toString())),
                    DataCell(Text(e.durationMinutes.toString())),
                    DataCell(Text(e.views.toString())),
                    DataCell(Text(e.isEnabled.toString() == "True" ? "ACTIVE" : "DISABLED")),
                    DataCell(Text(e.countryId.toString())),
                    DataCell(Text(e.languageId.toString())),
                  ]
                  )).toList() ?? List.empty()),
            ),
          )
          );
  }

  Padding _buildSearch() {
    return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      label: Text("Title")
                    ),
                    controller: _titleController,
                  ),
                ),
              ),
              ElevatedButton(onPressed: () async {
                 try {
                    var data = await _movieProvider.get(filter: {"title": _titleController.text});

                    setState(() {
                      result = data;
                      isLoading = false;
                    });

                  } on Exception catch (e) {
                      alertBox(context, "Error", e.toString());
                  }
              }, 
              child: Text("Search")),
              SizedBox(width: 10,),
              ElevatedButton(onPressed: () {}, child: Text("New")),
            ],
          ),
        );
  }
}