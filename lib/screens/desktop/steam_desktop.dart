import 'package:flutter/material.dart';
import 'package:xpvault/controllers/game_controller.dart';
import 'package:xpvault/layouts/desktop_layout.dart';
import 'package:xpvault/models/game.dart';
import 'package:xpvault/screens/game_detail.dart';
import 'package:xpvault/services/user_manager.dart';
import 'package:xpvault/themes/app_color.dart';
import 'package:xpvault/widgets/my_dropdownbutton.dart';
import 'package:xpvault/widgets/my_netimagecontainer.dart';
import 'package:xpvault/widgets/my_textformfield.dart';

class SteamDesktopPage extends StatefulWidget {
  final Widget? returnPage;
  final String? profileSteamId;

  const SteamDesktopPage({super.key, this.returnPage, this.profileSteamId});

  @override
  State<SteamDesktopPage> createState() => _SteamDesktopPageState();
}

class _SteamDesktopPageState extends State<SteamDesktopPage> {
  static const String defaultImage =
      "https://upload.wikimedia.org/wikipedia/commons/a/a3/Image-not-found.png";

  final GameController _gameController = GameController();
  final TextEditingController searchController = TextEditingController();

  static const int _pageSize = 12;

  String? _steamUsername;
  String? _profileSteamId;
  String? _loggedInSteamId;
  String dropdownvalue = "";
  String lastSearchValue = "";
  List<Game> games = [];
  List<Game> myGames = [];
  bool _isLoading = true;
  bool _isLoadingMyGames = true;
  bool _isSteamUser = false;
  bool _isFirstTimeSearching = true;
  bool _isFirstTimeAll = true;
  bool _isFirstTimeGenre = true;

  int _currentPage = 0;

  final List<String> steamGenres = [
    "All",
    'Action',
    'Adventure',
    'RPG',
    'Simulation',
    'Strategy',
    'Sports',
    'Racing',
    'Indie',
    'Casual'
  ];

  @override
  void initState() {
    super.initState();
    _loadGames();
    _initUserContext();
  }

  Future<void> _initUserContext() async {
    final currentUser = await UserManager.getUser();
    setState(() {
      _loggedInSteamId = currentUser?.steamUser?.steamId;
      _steamUsername = currentUser?.steamUser?.nickname;
      _profileSteamId = widget.profileSteamId ?? _loggedInSteamId;
    });
    if (_profileSteamId != null) {
      await _loadMyGames(_profileSteamId!);
    }
  }

  Future<void> _loadGames() async {
    List<Game> loadedGames = [];
    final isSearching = searchController.text.trim().isNotEmpty;

    setState(() {
      _isLoading = true;
    });

    if (isSearching) {
      if (_isFirstTimeSearching || lastSearchValue != searchController.text) {
        _currentPage = 0;
        _isFirstTimeSearching = false;
        _isFirstTimeAll = true;
        _isFirstTimeGenre = true;
      }
      loadedGames = await _gameController.searchGameByTitle(
        page: _currentPage,
        size: _pageSize,
        gameTitle: searchController.text,
      );
      lastSearchValue = searchController.text;
      dropdownvalue = "All";
    } else if (dropdownvalue.isNotEmpty) {
      if (_isFirstTimeGenre) {
        _currentPage = 0;
        _isFirstTimeGenre = false;
        _isFirstTimeAll = true;
        _isFirstTimeSearching = true;
      }
      loadedGames = await _gameController.getGamesByGenre(
        genre: dropdownvalue,
        page: _currentPage,
        size: _pageSize,
      );
    } else {
      if (_isFirstTimeAll) {
        _currentPage = 0;
        _isFirstTimeAll = false;
        _isFirstTimeSearching = true;
        _isFirstTimeGenre = true;
      }
      loadedGames = await _gameController.fetchGames(
        page: _currentPage,
        size: _pageSize,
      );
    }

    setState(() {
      games = loadedGames;
      _isLoading = false;
    });
  }

  Future<void> _loadMyGames(String steamId) async {
    setState(() {
      _isLoadingMyGames = true;
      _isSteamUser = true;
    });

    List<Game> loadedGames = await _gameController.getUserGames(steamId);

    setState(() {
      myGames = loadedGames;
      _isLoadingMyGames = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DesktopLayout(
      title: "XPVAULT",
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: MyTextformfield(
                    hintText: "Search",
                    obscureText: false,
                    textEditingController: searchController,
                    suffixIcon: IconButton(
                      onPressed: () {
                        _currentPage = 0;
                        _loadGames();
                      },
                      icon: Icon(Icons.search, color: AppColors.textMuted),
                    ),
                    onFieldSubmitted: (_) {
                      setState(() {
                        dropdownvalue = "";
                        _currentPage = 0;
                      });
                      _loadGames();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: MyDropdownbutton(
                    hint: dropdownvalue.isEmpty ? "Select genre" : dropdownvalue,
                    items: steamGenres
                        .map<DropdownMenuItem<String>>(
                          (String genre) => DropdownMenuItem<String>(
                            value: genre,
                            child: Text(genre),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value is String) {
                        setState(() {
                          searchController.clear();
                          _currentPage = 0;
                          dropdownvalue = value == "All" ? "" : value;
                        });
                        _loadGames();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.tertiary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Games",
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: _isLoading
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.accent,
                                      ),
                                    )
                                  : games.isEmpty
                                      ? Center(
                                          child: Text(
                                            "No games found.",
                                            style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : GridView.builder(
                                          itemCount: games.length,
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 10,
                                            mainAxisSpacing: 10,
                                            childAspectRatio: 2,
                                          ),
                                          itemBuilder: (context, index) {
                                            final game = games[index];
                                            final imageUrl = (game.screenshotUrl
                                                        ?.trim()
                                                        .isNotEmpty ??
                                                    false)
                                                ? game.screenshotUrl!
                                                : defaultImage;

                                            return MyNetImageContainer(
                                              title: game.title,
                                              body: '',
                                              image: imageUrl,
                                              onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => GameDetailPage(
                                                    steamId: game.steamId,
                                                    returnPage: widget.returnPage,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.tertiary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              myGames.isEmpty
                                  ? "My games"
                                  : "${_steamUsername ?? 'My'} games",
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: !_isSteamUser
                                  ? Center(
                                      child: Text(
                                        "Please log in with your Steam account to view your games.",
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : _isLoadingMyGames
                                      ? Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.accent,
                                          ),
                                        )
                                      : myGames.isEmpty
                                          ? Center(
                                              child: Text(
                                                "You have no games.",
                                                style: TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 16,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            )
                                          : GridView.builder(
                                              itemCount: myGames.length,
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 1,
                                                crossAxisSpacing: 5,
                                                mainAxisSpacing: 10,
                                                childAspectRatio: 5,
                                              ),
                                              itemBuilder: (context, index) {
                                                final game = myGames[index];
                                                final imageUrl = (game.screenshotUrl
                                                            ?.trim()
                                                            .isNotEmpty ??
                                                        false)
                                                    ? game.screenshotUrl!
                                                    : defaultImage;

                                                return MyNetImageContainer(
                                                  title: game.title,
                                                  body: '',
                                                  image: imageUrl,
                                                  onTap: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          GameDetailPage(
                                                        steamId: game.steamId,
                                                        returnPage: widget.returnPage,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _currentPage > 0 && !_isLoading
                      ? () {
                          setState(() {
                            _currentPage--;
                          });
                          _loadGames();
                        }
                      : null,
                  child: const Text("Previous"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: !_isLoading && games.length == _pageSize
                      ? () {
                          setState(() {
                            _currentPage++;
                          });
                          _loadGames();
                        }
                      : null,
                  child: const Text("Next"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
