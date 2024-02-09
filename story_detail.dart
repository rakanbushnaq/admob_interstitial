import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:kids_stories/helper/db_helper.dart';
import 'package:kids_stories/models/comment.dart';
import 'package:kids_stories/models/favorite.dart';
import 'package:kids_stories/models/story.dart';
import 'package:kids_stories/services/comment_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Auth/login.dart';
import 'post_comment.dart';

class StoryDetail extends StatefulWidget {
  final Story? story;
  StoryDetail({
    this.story,
  });
  @override
  _StoryDetailState createState() => _StoryDetailState();
}

class _StoryDetailState extends State<StoryDetail> {
  var _isFavorite = false;
  List<Comment> _commentsListByArticle = [];
  CommentService _commentService = CommentService();
  bool isLoading = true;

  _getCommentsByStory() async {
    var commentsByStory =
        await _commentService.commentsByArticle(this.widget.story!.id);
    var _list = json.decode(commentsByStory.body);
    List<Comment> results = [];
    _list['data'].forEach((data) {
      var model = Comment();
      model.id = data["id"];
      model.uName = data["Name"];
      model.comment = data["comment"];
      model.user_id = data['user_id'];
      model.userPic = data['profilePic'];
      model.date = data['created'];
      results.add(model);
    });
    if (mounted) {
      setState(() {
        _commentsListByArticle = results;
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    DBHelper.getSingle(widget.story!.id!).then((value) {
      if (value != null) {
        setState(() {
          _isFavorite = true;
        });
      }
    });
    _getCommentsByStory();
    super.initState();
  }

  void _postComment() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    int? _userId = _prefs.getInt('userId');
    if (_userId != null && _userId > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostComment(id: this.widget.story!.id),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    }
  }

  Widget commentList() {
    if (_commentsListByArticle.length > 0) {
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _commentsListByArticle.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: _commentsListByArticle.length == 0
                ? Container(
                    child: Text(
                      "No Data",
                      style: TextStyle(fontFamily: 'Dalbys Stamp Stamp'),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(_commentsListByArticle[
                                        index]
                                    .userPic ==
                                null
                            ? 'https://www.pngkey.com/png/detail/114-1149878_setting-user-avatar-in-specific-size-without-breaking.png'
                            : _commentsListByArticle[index].userPic!),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _commentsListByArticle[index].uName!,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Icon(
                                    Icons.watch_later,
                                    size: 12,
                                  ),
                                ),
                                Text(
                                  DateFormat('dd-MMM-yyyy').format(
                                    DateTime.parse(
                                        _commentsListByArticle[index].date!),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Container(
                                  width: 282,
                                  child: Text(
                                    _commentsListByArticle[index].comment!,
                                    maxLines: 5,
                                    style: TextStyle(fontSize: 16),
                                  )),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
          );
        },
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(18.0),
        child: Stack(
          children: [
            Container(
              height: 80,
              child: Center(
                child: IconButton(
                    icon: Icon(
                      Icons.comment,
                      size: 40,
                      color: Colors.indigoAccent,
                    ),
                    onPressed: null),
              ),
            ),
            Container(
              child: Center(
                child: Text(
                  "No Comment",
                  style: TextStyle(fontFamily: 'Dalbys Stamp Stamp'),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  SharedPreferences? prefs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          this.widget.story!.name!,
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(40),
          bottomLeft: Radius.circular(40),
        )),
        actions: [
          IconButton(
              icon: _isFavorite
                  ? Icon(
                      Icons.favorite,
                      size: 34,
                      color: Colors.red,
                    )
                  : Icon(
                      Icons.favorite_border,
                      size: 34,
                      color: Colors.red,
                    ),
              onPressed: () {
                setState(() {
                  //print( this.widget.recipe.title);
                  Favorite favorite = Favorite();
                  favorite.storyId = widget.story!.id;
                  favorite.isFavorite = 1;
                  favorite.title = widget.story!.name;
                  favorite.details = widget.story!.details;
                  favorite.author = widget.story!.author;
                  favorite.date = widget.story!.date;
                  favorite.image = widget.story!.image;

                  // print(favorite.title +
                  //     ', ' + favorite.ingredients +
                  //     ', ' +favorite.directions+
                  //     ', '+favorite.cookTime+
                  //     ', '+favorite.image);

                  DBHelper.insert(favorite).then((value) {
                    _isFavorite = !_isFavorite;
                  });
                });
              }),
        ],
      ),
      body: ListView(
        children: [
          Stack(
            children: [
              Container(
                height: 360,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(45.0),
                    bottomRight: Radius.circular(45.0),
                  ),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            child: Row(
                              children: [
                                Icon(Icons.remove_red_eye),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  this.widget.story!.views!,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Text(
                                this.widget.story!.categoryName!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ))
                      ],
                    ),
                  ),
                  FadeInImage.assetNetwork(
                    placeholder: 'assets/kids.png',
                    image: this.widget.story!.image!,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fill,
                    height: MediaQuery.of(context).size.height * 0.30,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    this.widget.story!.authorPic != null
                                        ? this.widget.story!.authorPic!
                                        : ''),
                                radius: 30,
                              ),
                              radius: 32,
                              backgroundColor: Colors.redAccent,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Column(
                                children: [
                                  Text(
                                    this.widget.story!.author!,
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('dd-MMM-yyyy').format(
                                      DateTime.parse(this.widget.story!.date!),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                                icon: Icon(
                                  Icons.comment,
                                ),
                                onPressed: () {
                                  _postComment();
                                }),
                            IconButton(
                                icon: Icon(Icons.share), onPressed: () {}),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Center(
                child: Text(
              this.widget.story!.name!,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Html(
                data: this.widget.story!.details!,
                style: {
                  "html": Style(
                    fontSize: FontSize.xLarge,
                  ),
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 5),
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    color: Colors.green),
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Comments',
                    style: TextStyle(
                      fontSize: 21,
                    ),
                  ),
                ))),
          ),
          Container(
              child: Column(
            children: [
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : commentList(),
              // AdmobBanner(
              //   adUnitId: getBannerAdUnitId(),
              //   adSize: AdmobBannerSize.MEDIUM_RECTANGLE,
              // ),
            ],
          )),
          Padding(
            padding: const EdgeInsets.all(48.0),
            child: ElevatedButton(
              child: Text(
                "Go Back ",
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          )
        ],
      ),
    );
  }

  // void _share() {
  //   try {
  //     Share.text(
  //         this.widget.story.name,
  //         this
  //                 .widget
  //                 .story
  //                 .details
  //                 .replaceAll('<li>', '->  ')
  //                 .replaceAll('</li>', '.')
  //                 .replaceAll('<ul>', '')
  //                 .replaceAll('</ul>', '')
  //                 .replaceAll('&nbsp;', '')
  //                 .replaceAll('<p>', '')
  //                 .replaceAll('<h1>', '')
  //                 .replaceAll('<h2>', '')
  //                 .replaceAll('<h3>', '')
  //                 .replaceAll('<em>', '')
  //                 .replaceAll('<b>', '')
  //                 .replaceAll('<img>', '')
  //                 .replaceAll('<a>', '')
  //                 .replaceAll('</h1>', '')
  //                 .replaceAll('</h2>', '')
  //                 .replaceAll('</h3>', '')
  //                 .replaceAll('</em>', '')
  //                 .replaceAll('</b>', '')
  //                 .replaceAll('</img>', '')
  //                 .replaceAll('</a>', '')
  //                 .replaceAll('</p>', '')
  //                 .replaceAll('<strong>', '')
  //                 .replaceAll('</strong>', '') +
  //             'For more Recipes visit \n https://pkbhai.com',
  //         'text/plain');
  //   } catch (e) {
  //     print('error: $e');
  //   }
  // }
}
