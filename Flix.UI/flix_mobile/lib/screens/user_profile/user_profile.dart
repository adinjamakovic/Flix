import 'package:flix_mobile/models/review_count.dart';
import 'package:flix_mobile/models/user.dart';
import 'package:flix_mobile/providers/review_provider.dart';
import 'package:flix_mobile/screens/activity.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flix_mobile/widgets/rating_count.dart';
import 'package:flix_mobile/widgets/review_side_scroll.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({ super.key, required this.currentUser });

  final User currentUser;


  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late ReviewProvider _reviewProvider;
  ReviewCount? _reviewCount;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _reviewProvider = context.read<ReviewProvider>();

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ReviewCount reviewCount = await _reviewProvider.getUserReviewCount();

      if(!mounted) return;

      setState(() {
        _isLoading = false;
        _reviewCount = reviewCount;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = errorText(e);
      });
    }
  }

  void _redirectToActivity() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ActivityScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
   return Column(
       children: [
        SizedBox(height: 16,),
        buildAvatar( context, 
          widget.currentUser.profileImage, 
          widget.currentUser.username,
          radius: 48),
        SizedBox(height: 16,),
        Divider(),
        SizedBox(height: 8,),
        ReviewSideScroll(title: "RECENT ACTIVITY", reviews: widget.currentUser.reviews ?? const [], isUserProfile: true,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(onPressed: _redirectToActivity, child: const Text("More activity", style: TextStyle(color: Colors.white)),),
            IconButton(onPressed: _redirectToActivity, icon: Icon(Icons.arrow_forward))
          ],
        ),
        Divider(),
        _buildRatings(context)
       ],
     );
  }

  Widget _buildRatings(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return buildMessage(
        context,
        _error!,
        action: TextButton(
          onPressed: _load,
          child: const Text("Try again"),
        ),
      );
    }

    final ReviewCount? counts = _reviewCount;
    if (counts == null) {
      return buildEmpty(context, "No ratings yet");
    }

    return RatingCountChart(counts: counts);
  }
}