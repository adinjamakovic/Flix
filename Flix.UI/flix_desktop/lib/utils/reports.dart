import 'dart:typed_data';

import 'package:flix_desktop/models/admin_statistics.dart';
import 'package:flix_desktop/models/movie.dart';
import 'package:flix_desktop/models/user.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const PdfColor _brand = PdfColor.fromInt(0xFFD9151C);
const PdfColor _muted = PdfColor.fromInt(0xFF5A5A63);
const PdfColor _headerFill = PdfColor.fromInt(0xFFF2F0F5);

/// The most active members of the platform, ordered the way the dashboard
/// shows them.
Future<Uint8List> buildUsersReport(AdminStatistics statistics) {
  final List<User> users = statistics.mostActiveUsers ?? List.empty();

  final pw.Document document = pw.Document();

  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => [
        _buildHeader(
          "Most Active Users",
          "The members writing and watching the most on FLIX",
        ),
        pw.SizedBox(height: 20),
        _buildSummary([
          ("Active users", formatCount(statistics.activeUsers)),
          ("Total reviews", formatCount(statistics.totalReviews)),
          ("Members listed", users.length.toString()),
        ]),
        pw.SizedBox(height: 24),
        _buildTable(
          headers: [
            "#",
            "Username",
            "Name",
            "Country",
            "Watched",
            "Reviews",
            "Member since",
          ],
          alignments: {
            0: pw.Alignment.center,
            4: pw.Alignment.center,
            5: pw.Alignment.center,
            6: pw.Alignment.center,
          },
          widths: {
            0: const pw.FixedColumnWidth(26),
            1: const pw.FlexColumnWidth(3),
            2: const pw.FlexColumnWidth(3),
            3: const pw.FlexColumnWidth(2),
            4: const pw.FlexColumnWidth(1.4),
            5: const pw.FlexColumnWidth(1.4),
            6: const pw.FlexColumnWidth(2),
          },
          rows: [
            for (int i = 0; i < users.length; i++)
              [
                (i + 1).toString(),
                users[i].username ?? "-",
                users[i].fullName ?? "-",
                users[i].country?.name ?? "-",
                (users[i].moviesWatched ?? 0).toString(),
                (users[i].reviewsWritten ?? 0).toString(),
                formatDate(users[i].createdAt),
              ],
          ],
        ),
      ],
      footer: _buildFooter,
    ),
  );

  return document.save();
}

/// The catalog seen twice over - by how much it is watched, and by how well it
/// is rated.
Future<Uint8List> buildMoviesReport(AdminStatistics statistics) {
  final List<Movie> movies = statistics.mostPopularMovies ?? List.empty();

  final List<Movie> mostWatched = List<Movie>.from(movies)
    ..sort((a, b) => (b.views ?? 0).compareTo(a.views ?? 0));

  // A movie nobody has rated has no rating to be ranked by.
  final List<Movie> bestRated = movies
      .where((movie) => (movie.reviewCount ?? 0) > 0 && movie.rating != null)
      .toList()
    ..sort((a, b) => b.rating!.compareTo(a.rating!));

  final pw.Document document = pw.Document();

  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => [
        _buildHeader(
          "Most Popular Movies",
          "The most watched and the best rated titles in the catalog",
        ),
        pw.SizedBox(height: 20),
        _buildSummary([
          ("Movies in catalog", formatCount(statistics.totalMovies)),
          ("Total reviews", formatCount(statistics.totalReviews)),
          ("Titles listed", movies.length.toString()),
        ]),
        pw.SizedBox(height: 24),
        _buildSectionTitle("Most watched"),
        pw.SizedBox(height: 8),
        _buildMovieTable(mostWatched),
        pw.SizedBox(height: 24),
        _buildSectionTitle("Best rated"),
        pw.SizedBox(height: 8),
        _buildMovieTable(bestRated),
      ],
      footer: _buildFooter,
    ),
  );

  return document.save();
}

pw.Widget _buildMovieTable(List<Movie> movies) {
  if (movies.isEmpty) {
    return pw.Text(
      "Nothing to report yet",
      style: const pw.TextStyle(color: _muted, fontSize: 11),
    );
  }

  return _buildTable(
    headers: ["#", "Title", "Released", "Genres", "Views", "Rating", "Reviews"],
    alignments: {
      0: pw.Alignment.center,
      2: pw.Alignment.center,
      4: pw.Alignment.center,
      5: pw.Alignment.center,
      6: pw.Alignment.center,
    },
    widths: {
      0: const pw.FixedColumnWidth(26),
      1: const pw.FlexColumnWidth(3.4),
      2: const pw.FlexColumnWidth(1.4),
      3: const pw.FlexColumnWidth(3),
      4: const pw.FlexColumnWidth(1.4),
      5: const pw.FlexColumnWidth(1.4),
      6: const pw.FlexColumnWidth(1.4),
    },
    rows: [
      for (int i = 0; i < movies.length; i++)
        [
          (i + 1).toString(),
          movies[i].title ?? "-",
          movies[i].releaseDate?.year.toString() ?? "-",
          movies[i].genreNames ?? "-",
          (movies[i].views ?? 0).toString(),
          movies[i].rating == null ? "-" : formatRating(movies[i].rating!),
          (movies[i].reviewCount ?? 0).toString(),
        ],
    ],
  );
}

pw.Widget _buildHeader(String title, String subtitle) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            "FLIX",
            style: pw.TextStyle(
              color: _brand,
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            "Generated ${formatDate(DateTime.now())}",
            style: const pw.TextStyle(color: _muted, fontSize: 10),
          ),
        ],
      ),
      pw.SizedBox(height: 12),
      pw.Text(
        title,
        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        subtitle,
        style: const pw.TextStyle(color: _muted, fontSize: 11),
      ),
      pw.SizedBox(height: 12),
      pw.Divider(color: _brand, thickness: 1.5),
    ],
  );
}

pw.Widget _buildSectionTitle(String title) {
  return pw.Text(
    title,
    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
  );
}

pw.Widget _buildSummary(List<(String, String)> entries) {
  return pw.Row(
    children: [
      for (final (String label, String value) in entries)
        pw.Expanded(
          child: pw.Container(
            margin: const pw.EdgeInsets.only(right: 12),
            padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const pw.BoxDecoration(color: _headerFill),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  label,
                  style: const pw.TextStyle(color: _muted, fontSize: 9),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  value,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

pw.Widget _buildTable({
  required List<String> headers,
  required List<List<String>> rows,
  required Map<int, pw.Alignment> alignments,
  required Map<int, pw.TableColumnWidth> widths,
}) {
  return pw.TableHelper.fromTextArray(
    headers: headers,
    data: rows,
    border: null,
    columnWidths: widths,
    cellAlignment: pw.Alignment.centerLeft,
    cellAlignments: alignments,
    headerAlignment: pw.Alignment.centerLeft,
    headerAlignments: alignments,
    headerDecoration: const pw.BoxDecoration(color: _headerFill),
    headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
    cellStyle: const pw.TextStyle(fontSize: 10),
    cellHeight: 22,
    oddRowDecoration: const pw.BoxDecoration(
      color: PdfColor.fromInt(0xFFFAFAFA),
    ),
  );
}

pw.Widget _buildFooter(pw.Context context) {
  return pw.Container(
    alignment: pw.Alignment.centerRight,
    margin: const pw.EdgeInsets.only(top: 12),
    child: pw.Text(
      "Page ${context.pageNumber} of ${context.pagesCount}",
      style: const pw.TextStyle(color: _muted, fontSize: 9),
    ),
  );
}

