import 'package:flix_mobile/models/cast_member.dart';
import 'package:flix_mobile/screens/cast_member_profile.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flix_mobile/widgets/person_row.dart';
import 'package:flutter/material.dart';

class CrewTab extends StatelessWidget {
  const CrewTab({super.key, required this.directors});

  final List<CastMember> directors;

  @override
  Widget build(BuildContext context) {
    if (directors.isEmpty) {
      return buildEmpty(context, "No director credited for this movie.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < directors.length; i++) ...[
          if (i > 0) const Divider(),
          PersonRow(
            castMember: directors[i],
            subtitle: "Director",
            onTap: () => _openProfile(context, directors[i]),
          ),
        ],
      ],
    );
  }

  void _openProfile(BuildContext context, CastMember director) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CastMemberProfile(castMember: director),
      ),
    );
  }
}
