import 'package:flix_mobile/models/cast_member.dart';
import 'package:flix_mobile/models/movie_credit.dart';
import 'package:flix_mobile/screens/cast_member_profile.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flix_mobile/widgets/person_row.dart';
import 'package:flutter/material.dart';

class CastTab extends StatelessWidget {
  const CastTab({super.key, required this.cast});

  final List<MovieCredit> cast;

  @override
  Widget build(BuildContext context) {
    if (cast.isEmpty) {
      return buildEmpty(context, "No cast listed for this movie.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < cast.length; i++) ...[
          if (i > 0) const Divider(),
          PersonRow(
            castMember: cast[i].castMember,
            subtitle: cast[i].characterName,
            onTap: () => _openProfile(context, cast[i].castMember),
          ),
        ],
      ],
    );
  }

  void _openProfile(BuildContext context, CastMember? castMember) {
    if (castMember == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CastMemberProfile(castMember: castMember),
      ),
    );
  }
}
