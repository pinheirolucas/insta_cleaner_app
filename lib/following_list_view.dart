import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart" show canLaunch, launch;
import "package:insta_cleaner/di.dart" as di;

import "auth_handler.dart" show AuthHandler;
import "users_service.dart" show User, UsersService;

class FollowingListView extends StatefulWidget {
  factory FollowingListView({String search = ""}) =>
      FollowingListView.inject(di.Container.retrieve<UsersService>(), search);
  FollowingListView.inject(this.usersService, this.search);

  final String search;
  final UsersService usersService;

  bool get hasSearch => search?.isNotEmpty ?? false;

  @override
  State<StatefulWidget> createState() => _FollowingListViewState();
}

class _FollowingListViewState extends State<FollowingListView> with AuthHandler {
  @override
  Widget build(BuildContext context) => FutureBuilder<List<User>>(
        future: widget.hasSearch ? widget.usersService.search(widget.search) : widget.usersService.getFollowing(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return handleBadResponse(snapshot, (context) => setState(() {}));
          }

          return snapshot.connectionState == ConnectionState.done
              ? ListView(
                  children: snapshot.data.map((User u) => _buildListViewTile(context, u)).toList(),
                )
              : LinearProgressIndicator();
        },
      );

  Widget _buildListViewTile(BuildContext context, User user) => _UserCard(
        user: user,
        onUserPressed: _navigateToUser,
        onFollow: _followUser,
        onFollowing: (u) => _unfollowUser(context, u),
      );

  Future<void> _followUser(User user) async {
    // TODO: handle error and loading
    await widget.usersService.follow(user.username);

    setState(() => user.follow());
  }

  Future<void> _navigateToUser(User user) async {
    if (await canLaunch(user.profileUrl)) {
      await launch(user.profileUrl);
    }
  }

  Future<void> _unfollowUser(BuildContext context, User user) async {
    if (!await _confirmUnfollow(context, user)) {
      return;
    }

    // TODO: handle error and loading
    await widget.usersService.unfollow(user.username);
    setState(() => user.unfollow());
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
  Widget build(BuildContext context) {
    final title = <Widget>[
      Text(_user.username),
    ];

    if (_user.isVerified) {
      title.add(
        Padding(
          padding: EdgeInsets.only(left: 5),
          child: Icon(
            Icons.check_circle,
            color: Colors.blue,
            size: 15,
          ),
        ),
      );
    }

    return ListTile(
      title: Container(
        child: Row(
          children: title,
        ),
      ),
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
}
