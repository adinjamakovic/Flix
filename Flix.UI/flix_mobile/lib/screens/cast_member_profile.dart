import 'package:flix_mobile/enums/cast_role.dart';
import 'package:flix_mobile/models/cast_member.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flutter/material.dart';

// Fed the cast member carried by the movie response rather than re-fetching it:
// `CastMemberService` does not override `GetByIdAsync`, so `GET /CastMember/{id}`
// goes through `FindAsync` and comes back with no country and no roles at all.
class CastMemberProfile extends StatelessWidget {
  const CastMemberProfile({super.key, required this.castMember});

  static const double _avatarRadius = 56;
  static const double _flagWidth = 24;
  static const double _flagHeight = 16;
  static const double _labelWidth = 100;

  final CastMember castMember;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          children: [
            Center(
              child: buildAvatar(
                context,
                castMember.photo,
                castMember.fullName,
                radius: _avatarRadius,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              castMember.fullName ?? "Unknown",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            _buildRoles(context),
            const SizedBox(height: 20),
            const Divider(),
            _buildDetail(context, "Born", Text(formatDate(castMember.birthDate))),
            if (castMember.country != null)
              _buildDetail(context, "Country", _buildCountry(context)),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              castMember.biography?.trim().isNotEmpty == true
                  ? castMember.biography!.trim()
                  : "No biography available.",
              style: TextStyle(color: colors.onSurfaceVariant, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoles(BuildContext context) {
    final List<CastRole> roles = (castMember.roles ?? const [])
        .whereType<CastRole>()
        .toList();

    if (roles.isEmpty) return const SizedBox.shrink();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: [
        for (final CastRole role in roles) Chip(label: Text(getRoleName(role))),
      ],
    );
  }

  Widget _buildCountry(BuildContext context) {
    final Uri? flag = httpUri(castMember.country?.flagImage);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (flag != null) ...[
          Image.network(
            flag.toString(),
            width: _flagWidth,
            height: _flagHeight,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
        ],
        Text(castMember.country?.name ?? "-"),
      ],
    );
  }

  Widget _buildDetail(BuildContext context, String label, Widget value) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _labelWidth,
            child: Text(
              label,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
            ),
          ),
          Expanded(
            child: DefaultTextStyle.merge(
              style: TextStyle(color: colors.onSurface, fontSize: 14),
              child: value,
            ),
          ),
        ],
      ),
    );
  }
}
