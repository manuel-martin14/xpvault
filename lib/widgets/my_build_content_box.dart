import 'package:flutter/material.dart';
import 'package:xpvault/screens/game_detail.dart';
import 'package:xpvault/screens/movie_detail.dart';
import 'package:xpvault/screens/movies_series.dart';
import 'package:xpvault/screens/serie_detail.dart';
import 'package:xpvault/screens/series.dart';
import 'package:xpvault/screens/steam.dart';
import 'package:xpvault/themes/app_color.dart';

import 'my_netimagecontainer.dart';

class MyBuildContentBox extends StatelessWidget {
  final List<dynamic> items;
  final bool showBodyLabel;
  final Widget? returnPage;
  final String? title;
  final String? username;

  const MyBuildContentBox({
    super.key,
    required this.items,
    this.showBodyLabel = true,
    this.returnPage,
    this.title,
    this.username,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = items.isEmpty;
    final ScrollController scrollController = ScrollController();

    void Function()? onShowAllTap;

    if (!isEmpty) {
      final firstTypeStr = items[0].runtimeType.toString();

      if (firstTypeStr == 'Game') {
        onShowAllTap = () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SteamPage(returnPage: SteamPage(),),
            ),
          );
        };
      } else if (firstTypeStr == 'Movie') {
        onShowAllTap = () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MoviesSeriesPage(profileUsername: username,returnPage: MoviesSeriesPage(profileUsername: username,),),
            ),
          );
        };
      } else if (firstTypeStr == 'Serie') {
        onShowAllTap = () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SeriesPage(username: username, returnPage: SeriesPage(username: username,),),
            ),
          );
        };
      } else {
        onShowAllTap = null;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              if (!isEmpty && onShowAllTap != null)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: onShowAllTap,
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        bool isHovered = false;
                        return MouseRegion(
                          onEnter: (_) => setState(() => isHovered = true),
                          onExit: (_) => setState(() => isHovered = false),
                          cursor: SystemMouseCursors.click,
                          child: Text(
                            "Show All",
                            style: TextStyle(
                              color: isHovered ? AppColors.accentLight : Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),

        if (isEmpty)
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                "Content soon...",
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 200,
            child: Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 8,
              radius: const Radius.circular(8),
              child: ListView.separated(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final String title;
                  String? imageUrl;
                  String bodyText;

                  final typeStr = item.runtimeType.toString();

                  if (typeStr == 'Game') {
                    title = item.title;
                    imageUrl = item.screenshotUrl;
                    bodyText = "Game";
                  } else if (typeStr == 'Movie') {
                    title = item.title;
                    imageUrl = item.posterUrl;
                    bodyText = "Movie";
                  } else if (typeStr == 'Serie') {
                    title = item.title;
                    imageUrl = item.posterUrl;
                    bodyText = "Serie";
                  } else if (typeStr == 'Achievement') {
                    title = item.name ?? 'Unknown';
                    imageUrl = item.url;
                    bodyText = "Achievement";
                  } else if (typeStr == 'Casting') {
                    title = item.name;
                    imageUrl = item.photoUrl;
                    bodyText = showBodyLabel ? item.character : '';
                  } else if (typeStr == 'CastMember') {
                    title = item.name;
                    imageUrl = item.photoUrl;
                    bodyText = showBodyLabel ? item.character : '';
                  } else if (typeStr == 'Person') {
                    title = item.name;
                    imageUrl = item.photoUrl;
                    bodyText = showBodyLabel ? 'Director' : '';
                  } else {
                    title = 'Unknown';
                    imageUrl = null;
                    bodyText = '';
                  }

                  void Function()? onTapHandler;
                  if (typeStr == 'Game') {
                    onTapHandler = () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              GameDetailPage(steamId: item.steamId, returnPage: returnPage),
                        ),
                      );
                    };
                  } else if (typeStr == 'Movie') {
                    onTapHandler = () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MovieDetailPage(movieId: item.tmbdId, returnPage: returnPage),
                        ),
                      );
                    };
                  } else if (typeStr == 'Serie') {
                    onTapHandler = () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SerieDetailPage(serieId: item.tmbdId, returnPage: returnPage),
                        ),
                      );
                    };
                  } else {
                    onTapHandler = null;
                  }

                  return SizedBox(
                    width: 120,
                    child: MyNetImageContainer(
                      title: title,
                      body: showBodyLabel ? bodyText : '',
                      image: imageUrl ?? '',
                      onTap: onTapHandler,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
