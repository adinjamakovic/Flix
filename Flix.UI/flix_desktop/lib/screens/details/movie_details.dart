import 'package:flix_desktop/layouts/master_screen.dart';
import 'package:flix_desktop/models/movie.dart';
import 'package:flix_desktop/providers/movie_provider.dart';
import 'package:flix_desktop/screens/lists/movie_list.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class MovieDetails extends StatefulWidget {
  const MovieDetails({ Key? key, this.movie }) : super(key: key);
  
  final Movie? movie;
  
  @override
  _MovieDetailsState createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};

  late MovieProvider _movieProvider;

  @override 
  void initState() {
    super.initState();

    _initialValue = {
      'title': widget.movie?.title,
      'releaseDate': widget.movie?.releaseDate.toString()
    };

    _movieProvider = context.read<MovieProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(
        widget.movie == null ? "New Movie" : "Update movie: ${widget.movie!.title}"
      ),),
      body: _buildForm(),
    );
  }

  Center _buildForm() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FormBuilder(
              key: _formKey,
              initialValue: _initialValue,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FormBuilderTextField(
                            name: "title",
                            validator: (value) {
                              if(value == null || value.isEmpty){
                                return mField;
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(label: Text("Title")),
                          )
                        ),
                        Expanded(
                        child: FormBuilderTextField(
                            name: "releaseDate",
                            validator: (value) {
                              if(value == null || value.isEmpty){
                                return mField;
                              } else if (DateTime.tryParse(value) == null) {
                                return dateField;
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(label: Text("Release Date")),
                          )
                        )
                    ],
                  )
                ],
              )
              ),
              ElevatedButton(
                onPressed: () async {
                  _formKey.currentState?.save();

                  try {
                    if(_formKey.currentState!.validate()){
                      
                    }
                  } catch (e) {
                  }
                }, 
                child: Text("Save"))
          ],
        ),
      ),
    );
  }
}