import 'dart:convert';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kids_stories/delegates/story_search.dart';
import 'package:kids_stories/models/category.dart';
import 'package:kids_stories/models/comment.dart';
import 'package:kids_stories/models/slider.dart';
import 'package:kids_stories/models/story.dart';
import 'package:kids_stories/screens/story_detail.dart';
import 'package:kids_stories/screens/story_list.dart';
import 'package:kids_stories/services/category_service.dart';
import 'package:kids_stories/services/comment_service.dart';
import 'package:kids_stories/services/story_service.dart';
import 'package:kids_stories/services/slider_service.dart';
import 'package:kids_stories/widgets/home_all_poems.dart';
import 'package:kids_stories/widgets/home_all_essays.dart';
import 'package:kids_stories/widgets/home_post_categories.dart';

import '../helper/navigation.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  Widget? result;
  SliderService _sliderService = SliderService();
  CategoryService _categoryService = CategoryService();
  StoryService _storyService = StoryService();
  CommentService _commentService = CommentService();
  List<Comment> _commentList = [];
  var items = [];
  List<Category> _categoryList = [];
  List<Story> _popularList = [];
  List<Story> _essayList = [];
  List<Story> _poemList = [];
  List<SliderModel> _sliderList = [];

  @override
  void initState() {
    super.initState();
    _getAllSliders();
    _getAllCategories();
    _getAllStories();
    _getAllEssays();
    _getAllPoems();
    _getAllComments();
  }

  _getAllSliders() async {
    var sliders = await _sliderService.getSliders();
    var result = json.decode(sliders.body);
    result['data'].forEach((data) {
      var model = SliderModel();
      model.id = data["id"];
      model.url = data["url"];
      model.image = data["image"];
      setState(() {
        _sliderList.add(model);
      });
    });
  }

  _getAllCategories() async {
    var categories = await _categoryService.getCategories();
    var result = json.decode(categories.body);
    print(result);
    result['data'].forEach((data) {
      var model = Category();
      model.id = data["id"];
      model.name = data["name"];
      model.icon = data["icon"];
      setState(() {
        _categoryList.add(model);
        isLoading = false;
      });
    });
    //print(result);
  }

  _getAllStories() async {
    var allRecipes = await _storyService.getAllStories();
    var result = json.decode(allRecipes.body);
    // print(allRecipes.body);
    result['data'].forEach((data) {
      var model = Story();
      model.id = data['id'];
      model.name = data['name'];
      model.details = data['details'];
      model.language = data['Language'];
      model.views = data['views'].toString();
      model.image = data['image'];
      model.date = data['created'].toString();
      model.categoryName = data['categoryName'];
      model.author = data['Author'];
      model.authorPic = data['authorPic'];
      setState(() {
        _popularList.add(model);
      });
    });
  }

  _getAllPoems() async {
    var allPoems = await _storyService.getPoems();
    var result = json.decode(allPoems.body);
    result['data'].forEach((data) {
      var model = Story();
      model.id = data['id'];
      model.name = data['name'];
      model.details = data['details'];
      model.views = data['views'].toString();
      model.image = data['image'];
      model.date = data['created'].toString();
      model.categoryName = data['categoryName'];
      model.author = data['Author'];
      model.authorPic = data['authorPic'];
      setState(() {
        _poemList.add(model);
      });
    });
  }

  _getAllComments() async {
    var allComments = await _commentService.allComments();
    var result = json.decode(allComments.body);
    result['data'].forEach((data) {
      var model = Comment();
      model.id = data['id'];
      model.uName = data['Name'];
      model.comment = data['comment'];
      model.date = data['created'].toString();
      model.userPic = data['profilePic'];
      setState(() {
        _commentList.add(model);
        isLoading = false;
      });
    });
  }

  _getAllEssays() async {
    var essay = await _storyService.getEssays();
    var result = json.decode(essay.body);
    result['data'].forEach((data) {
      var model = Story();
      model.id = data['id'];
      model.name = data['name'];
      model.details = data['details'];
      model.views = data['views'].toString();
      model.image = data['image'];
      model.date = data['created'].toString();
      model.categoryName = data['categoryName'];
      model.author = data['Author'];
      model.authorPic = data['authorPic'];
      setState(() {
        _essayList.add(model);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Kid's Stories",
        ),
        centerTitle: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(40),
          bottomLeft: Radius.circular(40),
        )),
      ),
      drawer: NavigationDrawer1(),
      body: Container(
        alignment: Alignment.center,
        child: Center(
          child: isLoading
              ? CircularProgressIndicator(
                  backgroundColor: Colors.deepPurple,
                  strokeWidth: 10,
                )
              : ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: InkWell(
                        onTap: () {
                          showSearch(
                              context: context,
                              delegate: StorySearch(stories: _popularList));
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 2)
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Search...',
                                    style: TextStyle(
                                        fontSize: 21, color: Colors.black),
                                  ),
                                  Icon(Icons.search, color: Colors.black)
                                ],
                              ),
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CarouselSlider.builder(
                          itemCount: _sliderList.length - 0,
                          itemBuilder: (BuildContext context, int index, _) =>
                              Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.pink,
                                  ),
                                  height: 150,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: FadeInImage(
                                        fit: BoxFit.fill,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        placeholder:
                                            AssetImage('assets/kids.png'),
                                        image: NetworkImage(
                                          _sliderList[index].image!.isNotEmpty
                                              ? _sliderList[index].image!
                                              : "",
                                        )),
                                  )),
                          options: CarouselOptions(
                            height: 150,
                            autoPlay: true,
                            enlargeCenterPage: true,
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                      child: Column(
                        children: [
                          HomePostCategories(
                            categoryList: _categoryList,
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      indent: 30,
                      endIndent: 30,
                      thickness: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Story of the day",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              )),
                          Divider(
                            endIndent: 300,
                            thickness: 5,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                    HomeAllEssays(
                      recipeList: _essayList,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16, top: 1, bottom: 5),
                      child: Divider(
                        thickness: 1,
                        color: Colors.black54,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Popular',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  StoryList()));
                                    },
                                    child: Text(
                                      'View All',
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                      ),
                                    ))
                              ],
                            ),
                          ),
                          Container(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              itemCount: _popularList.length > 10
                                  ? 10
                                  : _popularList.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Container(
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  print(_popularList[index]
                                                      .name);
                                                  // '$uRL${_popularList[index].id}
                                                  // Future<http.Response> createAlbum(String title) {
                                                  //   return http.post(
                                                  //     Uri.parse('https://jsonplaceholder.typicode.com/albums'),
                                                  //     headers: <String, String>{
                                                  //       'Content-Type': 'application/json; charset=UTF-8',
                                                  //     },
                                                  //     body: jsonEncode(<String, String>{
                                                  //       'title': title,
                                                  //     }),
                                                  //   );
                                                  // }
                                                  Navigator.push(context,
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                    return StoryDetail(
                                                      story:
                                                          _popularList[index],
                                                    );
                                                  }));
                                                },
                                                child: Stack(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets
                                                                  .only(
                                                              left: 25.0,
                                                              top: 8),
                                                      child: Card(
                                                        elevation: 5,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            15.0,
                                                          ),
                                                        ),
                                                        child: Container(
                                                          height: 90,
                                                          width: 320,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                        .only(
                                                                    bottom:
                                                                        10.0),
                                                                child:
                                                                    Container(
                                                                        width:
                                                                            185,
                                                                        child:
                                                                            Text(
                                                                          _popularList[index].name!,
                                                                          maxLines:
                                                                              2,
                                                                          style: TextStyle(
                                                                              fontSize: 18,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.red),
                                                                        )),
                                                              ),
                                                              Container(
                                                                width: 180,
                                                                child: Text(
                                                                    _popularList[
                                                                            index]
                                                                        .details!
                                                                        .replaceAll(
                                                                            '<p>',
                                                                            '')
                                                                        .replaceAll(
                                                                            '</p>',
                                                                            '')
                                                                        .replaceAll(
                                                                            '<h1>',
                                                                            '')
                                                                        .replaceAll(
                                                                            '</h1>',
                                                                            ''),
                                                                    maxLines:
                                                                        1,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 12,
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                            Colors.black54,
                                                        radius: 45,
                                                        child: CircleAvatar(
                                                          radius: 42,
                                                          //backgroundColor: Colors.green,
                                                          backgroundImage:
                                                              NetworkImage(
                                                                  _popularList[
                                                                          index]
                                                                      .image!),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                        top: 15,
                                                        right: 5,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,

                                                          children: [
                                                            IconButton(
                                                                icon: Icon(Icons
                                                                    .share),
                                                                onPressed:
                                                                    () {
                                                                  // _share(
                                                                  //     _popularList[index].id);
                                                                }),
                                                            Row(
                                                              children: [
                                                                Icon(Icons.remove_red_eye),
                                                                Text(_popularList[index].views!),
                                                              ],
                                                            )
                                                          ],
                                                        )),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16, top: 1, bottom: 1),
                      child: Divider(
                        thickness: 1,
                        color: Colors.black54,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Poems",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    HomeAllPoems(
                      drinkRecipeList: _poemList,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 10),
                            child: Row(
                              children: [
                                Text(
                                  "Latest comment",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 48.0),
                            child: Container(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                itemCount: _commentList.length > 5
                                    ? 5
                                    : _commentList.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    child: InkWell(
                                      onTap: () {
                                        showModalBottomSheet<void>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Container(
                                              height: 400,
                                              child: Padding(
                                                padding: const EdgeInsets
                                                        .symmetric(
                                                    horizontal: 15),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text(
                                                      _commentList[index]
                                                          .comment!,
                                                      style: TextStyle(
                                                          fontSize: 21),
                                                    ),
                                                    TextButton(
                                                      child:
                                                          const Text('Close'),
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Stack(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                        left: 25.0, top: 8),
                                                child: Card(
                                                  elevation: 5,
                                                  shape:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      15.0,
                                                    ),
                                                  ),
                                                  child: Container(
                                                    height: 90,
                                                    width: 320,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  bottom:
                                                                      10.0),
                                                          child: Text(
                                                            _commentList[
                                                                    index]
                                                                .uName!,
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .red),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 50),
                                                          child: Container(
                                                            width: 220,
                                                            child: Text(
                                                                _commentList[
                                                                        index]
                                                                    .comment!
                                                                    .replaceAll(
                                                                        '<p>',
                                                                        '')
                                                                    .replaceAll(
                                                                        '</p>',
                                                                        '')
                                                                    .replaceAll(
                                                                        '<h1>',
                                                                        '')
                                                                    .replaceAll(
                                                                        '</h1>',
                                                                        ''),
                                                                maxLines: 2,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 12,
                                                child: CircleAvatar(
                                                  radius: 45,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            41),
                                                    child: FadeInImage(
                                                        fit: BoxFit.cover,
                                                        width: 82,
                                                        height: 82,
                                                        placeholder: AssetImage(
                                                            'assets/place_user.png'),
                                                        image: NetworkImage(_commentList[
                                                                        index]
                                                                    .userPic ==
                                                                null
                                                            ? "https://www.pngkey.com/png/detail/114-1149878_setting-user-avatar-in-specific-size-without-breaking.png"
                                                            : _commentList[
                                                                    index]
                                                                .userPic!)),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 15,
                                                right: 15,
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets
                                                                  .only(
                                                              right: 8.0),
                                                      child: Icon(
                                                        Icons.watch_later,
                                                        size: 11,
                                                      ),
                                                    ),
                                                    Text(
                                                      DateFormat(
                                                              'dd-MMM-yyyy')
                                                          .format(
                                                        DateTime.parse(
                                                            _commentList[
                                                                    index]
                                                                .date!),
                                                      ),
                                                      style: TextStyle(
                                                          fontSize: 13),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
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
                  ],
                ),
        ),
      ),
    );
  }

  // _launchURL(String url) async {
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

  // void _share(int index) {
  //   try {
  //     Share.text(
  //         _popularList[index].name,
  //         _popularList[index]
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
  //             'For more stories visit \n com.dizitaltrends.kids_stories',
  //         'text/plain');
  //   } catch (e) {
  //     print('error: $e');
  //   }
  // }
}
