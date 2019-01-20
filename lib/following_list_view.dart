import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart" show canLaunch, launch;

class FollowingListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FollowingListViewState();
}

class _FollowingListViewState extends State<FollowingListView> {
  @override
  Widget build(BuildContext context) => ListView(
        children: _following.map((User u) => _buildListViewTile(context, u)).toList(),
      );

  Widget _buildListViewTile(BuildContext context, User user) => _UserCard(
        user: user,
        onUserPressed: _navigateToUser,
        onFollow: _followUser,
        onFollowing: (u) => _unfollowUser(context, u),
      );

  void _followUser(User user) => setState(() => user.follow());

  Future<void> _navigateToUser(User user) async {
    if (await canLaunch(user.profileUrl)) {
      await launch(user.profileUrl);
    }
  }

  Future<void> _unfollowUser(BuildContext context, User user) async {
    if (!await _confirmUnfollow(context, user)) {
      print("Não deixou de seguir");
      return;
    }

    print("Deixou de seguir");
  }

  Future<bool> _confirmUnfollow(BuildContext context, User user) async => await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(user.profilePic),
                      radius: 40,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Se mudar de ideia, você precisará solicitar para seguir",
                          ),
                          TextSpan(
                            text: " @${user.username} ",
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          TextSpan(
                            text: "novamente.",
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              actions: [
                FlatButton(
                  child: Text("CANCELAR"),
                  textColor: Colors.black87,
                  onPressed: () => Navigator.pop(context, false),
                ),
                FlatButton(
                  child: Text("DEIXAR DE SEGUIR"),
                  textColor: Colors.red,
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ),
      );
}

typedef UserFunc(User user);

class _UserCard extends StatelessWidget {
  final User _user;
  final Function _onUserPressed;
  final Function _onFollow;
  final Function _onFollowing;

  _UserCard({@required User user, UserFunc onUserPressed, UserFunc onFollow, UserFunc onFollowing})
      : this._user = user,
        this._onUserPressed = onUserPressed,
        this._onFollow = onFollow,
        this._onFollowing = onFollowing;

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(_user.username),
        subtitle: Text(_user.name),
        onTap: () => _onUserPressed(_user),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(_user.profilePic),
        ),
        trailing: _user.isFollowing
            ? OutlineButton(
                child: Text("Seguindo"),
                onPressed: () => _onFollowing(_user),
              )
            : FlatButton(
                child: Text("Seguir"),
                color: Colors.blue,
                textColor: Colors.white,
                onPressed: () => _onFollow(_user),
              ),
      );
}

class User {
  User({this.id, this.name, this.username, this.profileUrl, this.profilePic, isFollowing = false})
      : this._isFollowing = isFollowing;

  final int id;
  final String name;
  final String username;
  final String profileUrl;
  final String profilePic;

  bool _isFollowing;
  bool get isFollowing => _isFollowing;

  void follow() {
    _isFollowing = true;
  }

  void unfollow() {
    _isFollowing = false;
  }
}

final _following = [
  User(
    id: 1,
    name: "Leandro Neko",
    username: "leandroneko",
    profileUrl: "https://www.instagram.com/leandroneko/",
    profilePic:
        "https://instagram.fjoi2-1.fna.fbcdn.net/vp/1227b756b3511c008b4653d41c8273bd/5CC03042/t51.2885-19/s150x150/47690721_762539200793315_2621319472480256000_n.jpg?_nc_ht=instagram.fjoi2-1.fna.fbcdn.net",
    isFollowing: true,
  ),
  User(
    id: 2,
    name: "⚡️PITTY⚡️",
    username: "pitty",
    profileUrl: "https://www.instagram.com/pitty/",
    profilePic:
        "https://instagram.fjoi2-1.fna.fbcdn.net/vp/b35b26b4dc3c5dcd68d674a8a0f699d2/5CCFBF39/t51.2885-19/s150x150/36149132_190177528500343_3582746510120452096_n.jpg?_nc_ht=instagram.fjoi2-1.fna.fbcdn.net",
  ),
  User(
    id: 3,
    name: "Ana Abelha",
    username: "euanaabelha",
    profileUrl: "https://www.instagram.com/euanaabelha/",
    profilePic:
        "https://instagram.fjoi2-1.fna.fbcdn.net/vp/470ef8ec63ad46d5dbe12f9c5adbdb19/5CBFEEF7/t51.2885-19/s150x150/42890822_188202832072110_1885326991805120512_n.jpg?_nc_ht=instagram.fjoi2-1.fna.fbcdn.net",
    isFollowing: true,
  ),
];
