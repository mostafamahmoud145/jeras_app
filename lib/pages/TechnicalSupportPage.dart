import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:uuid/uuid.dart';

import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/SupportList.dart';
import '../../models/user.dart';
import '../../widget/supportListItem.dart';
import '../FireStorePagnation/bloc/pagination_listeners.dart';
import '../FireStorePagnation/paginate_firestore.dart';
import '../config/app_constat.dart';
import '../controller/blocs/account_bloc/account_bloc.dart';
import '../screens/supportMessagesScreen.dart';

class TechnicalSupportPage extends StatefulWidget {
  @override
  _TechnicalSupportPageState createState() => _TechnicalSupportPageState();
}

class _TechnicalSupportPageState extends State<TechnicalSupportPage>
    with AutomaticKeepAliveClientMixin<TechnicalSupportPage> {
  final TextEditingController searchController = new TextEditingController();
  PaginateRefreshedChangeListener refreshChangeListener =
      PaginateRefreshedChangeListener();
  late AccountBloc accountBloc;
  GroceryUser? user;
  bool _new = true, _pending = false, _all = false;
  bool load = false, open = true, closed = false, summary = false;
  late String lang, userImage, theme = "light";
  SupportList? supportList;
  bool loadingSupportList = true;

  @override
  void initState() {
    super.initState();
    getUser().then((value) {
      getSupportList();
    });
  }

  Future<void> getUser() async {
    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(GetLoggedUserEvent());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.white,
      body: BlocBuilder(
        bloc: accountBloc,
        builder: (context, state) {
          if (state is GetLoggedUserInProgressState) {
            return Center(child: CircularProgressIndicator());
          } else if (state is GetLoggedUserCompletedState) {
            user = state.user;
            return Container(
              height: 888,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: AppSize.h5.h,
                  ),
                  Visibility(
                      visible: user!.userType == "SUPPORT",
                      child: supportWidget(size)),
                  SizedBox(
                    height: AppSize.h5.h,
                  ),
                  Visibility(
                      visible: _new && user!.userType == "SUPPORT",
                      child: list(size, initiateSearch("_new"))),
                  Visibility(
                      visible: _pending && user!.userType == "SUPPORT",
                      child: list(size, initiateSearch("_pending"))),
                  Visibility(
                      visible: _all && user!.userType == "SUPPORT",
                      child: list(size, initiateSearch("_all"))),
                  loadingSupportList == false
                      ? Visibility(
                          visible: user!.userType != "SUPPORT",
                          child: Expanded(
                              child: //userAndConsultChat(context),
                                  SupportMessageScreen(
                            item: supportList!,
                            user: user!,
                            theme: theme,
                          ))
                          //list(size, initiateSearch("")),
                          )
                      : Center(
                          child:
                              CircularProgressIndicator(color: AppColors.pink)),
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<void> getSupportList() async {
    final QuerySnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance
            .collection('SupportList')
            .where('userUid', isEqualTo: user!.uid)
            .limit(1)
            .orderBy('messageTime', descending: true)
            .get();

    if (documentSnapshot.docs.isNotEmpty) {
      print("documentSnapshot isNotEmpty ^^^ ");
      supportList = SupportList.fromMap(documentSnapshot.docs[0].data());
      setState(() {
        loadingSupportList = false;
      });
    } else if (documentSnapshot.docs.isEmpty) {
      print("documentSnapshot isEmpty 333 ");
      String supportListId = Uuid().v4();
      await FirebaseFirestore.instance
          .collection("SupportList")
          .doc(supportListId)
          .set({
        'supportListId': supportListId,
        'chatStatus': false,
        'messageTime': FieldValue.serverTimestamp(),
        'owner': user!.userType,
        'supportListStatus': false,
        'userName': user!.name,
        'userUid': user!.uid,
        'lastMessage': "",
        'userMessageNum': 0,
        'consultMessageNum': 0,
        //'lastMessage': " ",
      });

      var documentSnapshot = await FirebaseFirestore.instance
          .collection("SupportList")
          .doc(supportListId)
          .get();
      supportList = SupportList.fromMap(documentSnapshot.data() as Map);
      setState(() {
        loadingSupportList = false;
      });
    } else {
      throw Exception('No documents found');
    }
  }

  /* Future<SupportList> getSupportList() async {
    final QuerySnapshot<Map<String, dynamic>> documentSnapshot =
    await FirebaseFirestore.instance
        .collection('SupportList')
        .where('userUid', isEqualTo: user!.uid)
        .orderBy('messageTime', descending: true)
        .get();
    if (documentSnapshot.docs.isNotEmpty) {
      return SupportList.fromMap(documentSnapshot.docs[0].data());
    } else {
      throw Exception('No documents found');
    }
  }*/

/*
  Widget userAndConsultChat(BuildContext context) {
    return FutureBuilder<SupportList>(
      future: getSupportList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(); // or some other loading widget
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          return SupportMessageScreen(
            item: snapshot.data!,
            user: user!,
            theme: theme,
          );
        } else {
          return Text('No data available');
        }
      },
    );
  }
*/

  Widget list(Size size, Query _query) {
    return Expanded(
      child: PaginateFirestore(
        itemBuilderType: PaginateBuilderType.listView,
        separator: SizedBox(
          height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? AppSize.h40.h
              : AppSize.h20.h,
        ),
        padding: EdgeInsets.only(
          left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? size.width * AppPadding.p0_06
              : AppPadding.p32.w,
          right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? size.width * AppPadding.p0_06
              : AppPadding.p32.w,
          bottom: AppPadding.p16,
          top: AppPadding.p16,
        ),
        //Change types accordingly
        itemBuilder: (context, documentSnapshot, index) {
          return SupportListItem(
            size: size,
            item: SupportList.fromMap(documentSnapshot[index].data() as Map),
            user: user!,
            theme: 'light',
          );
        },
        query: _query,
        isLive: true,
      ),
    );
  }

  supportWidget(Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: AppSize.h10.h,
          horizontal: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? size.width * AppSize.w0_2.w
              : AppSize.w20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /* Row(mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Container(height: 40,width: (kIsWeb||size.width >= AppConstants.kIsWebValue)
?size.width*.2:size.width*.7,
            padding: const EdgeInsets.symmetric( horizontal: 1.0, vertical: 0.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.r10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey,
                  blurRadius: 2.0,
                  spreadRadius: 0.0,
                  offset: Offset(0.0, 1.0), // shadow direction: bottom right
                )
              ],
            ),
            child: Center(
              child: TextField(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NameSearchScreen(loggedUser: user!,),
                    ),
                  );
                },
                keyboardType: TextInputType.text,
                controller: searchController,
                textInputAction: TextInputAction.search,
                enableInteractiveSelection: true,
                readOnly:false,
                style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                  fontSize: AppFontsSizeManager.s14_5,
                   color: AppColors.black87,
                  letterSpacing: AppConstants.letterSpacing0_5,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                  prefixIcon:Icon(Icons.search, size: 14,color:AppColors.pink),
                  suffixIcon: InkWell(
                      child: Icon(Icons.send_rounded, size: 14), onTap: () {
                  }),
                  border: InputBorder.none,
                  hintText: getTranslated(context, "name"),
                  hintStyle: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                    fontSize: AppFontsSizeManager.s14_5,
                    color: Theme.of(context).primaryColor,
                    letterSpacing: AppConstants.letterSpacing0_5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: (kIsWeb||size.width >= AppConstants.kIsWebValue)
?20:10,),
          Container(height: 40,width: size.width*.15,
            decoration: new BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,),
            child: InkWell(
                child: Icon(Icons.wifi_protected_setup, size: 18,color: AppColors.pink,), onTap: () {
              closeAll();
            }),
          ),
        ],
      ),
      SizedBox(height: 10,),*/
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _new = true;
                      _pending = false;
                      _all = false;
                      initiateSearch("_new");
                    });
                  },
                  child: Container(
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.h66.h
                        : AppSize.h30.h,
                    width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.w194.w
                        : size.width * AppSize.w0_25,
                    padding: const EdgeInsets.all(AppPadding.p2),
                    decoration: BoxDecoration(
                      color: _new
                          ? Theme.of(context).primaryColor
                          : AppColors.lightPink,
                      borderRadius: BorderRadius.circular(
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppRadius.r33.r
                              : AppRadius.r18.r),
                    ),
                    child: Center(
                      child: Text(
                        getTranslated(context, "_new"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          color: _new
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s26_6.sp
                                  : AppFontsSizeManager.s14.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: AppSize.w5.w,
                ),
                InkWell(
                  splashColor: Colors.green.withOpacity(0.6),
                  onTap: () {
                    setState(() {
                      _new = false;
                      _pending = true;
                      _all = false;
                      initiateSearch("_pending");
                    });
                  },
                  child: Container(
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.h66.h
                        : AppSize.h30.h,
                    width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.w194.w
                        : size.width * AppSize.w0_25,
                    padding: const EdgeInsets.all(AppPadding.p2),
                    decoration: BoxDecoration(
                      color: _pending
                          ? Theme.of(context).primaryColor
                          : AppColors.lightPink,
                      borderRadius: BorderRadius.circular(
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppRadius.r33.r
                              : AppRadius.r18.r),
                    ),
                    child: Center(
                      child: Text(
                        getTranslated(context, "_pending"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          color: _pending
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s26_6.sp
                                  : AppFontsSizeManager.s14.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: AppSize.w5.w,
                ),
                InkWell(
                  splashColor: Colors.green.withOpacity(0.6),
                  onTap: () {
                    setState(() {
                      _new = false;
                      _pending = false;
                      _all = true;
                      initiateSearch("_all");
                    });
                  },
                  child: Container(
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.h66.h
                        : AppSize.h30.h,
                    width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.w194.w
                        : size.width * AppSize.w0_25,
                    padding: const EdgeInsets.all(AppPadding.p2),
                    decoration: BoxDecoration(
                      color: _all
                          ? Theme.of(context).primaryColor
                          : AppColors.lightPink,
                      borderRadius: BorderRadius.circular(
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppRadius.r33.r
                              : AppRadius.r18.r),
                    ),
                    child: Center(
                      child: Text(
                        getTranslated(context, "_all"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          color: _all
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s26_6.sp
                                  : AppFontsSizeManager.s14.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ])
        ],
      ),
    );
  }

  closeAll() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.supportListPath)
          .where('openingStatus', isEqualTo: true)
          .get();
      for (var doc in querySnapshot.docs) {
        await FirebaseFirestore.instance
            .collection(Paths.supportListPath)
            .doc(doc.id)
            .update({
          'openingStatus': false,
        });
      }
    } catch (e) {}
  }

  Query initiateSearch(String val) {
    if (user!.userType == "SUPPORT" && val == "_new")
      return FirebaseFirestore.instance
          .collection('SupportList')
          .where('supportMessageNum', isGreaterThan: 0)
          .orderBy('supportMessageNum', descending: true);
    else if (user!.userType == "SUPPORT" && val == "_pending")
      return FirebaseFirestore.instance
          .collection('SupportList')
          .where('pending', isEqualTo: true)
          .orderBy('messageTime', descending: true);
    else if (user!.userType == "SUPPORT" && val == "_all")
      return FirebaseFirestore.instance
          .collection('SupportList')
          .orderBy('messageTime', descending: true);
    else
      return FirebaseFirestore.instance
          .collection('SupportList')
          .where('userUid', isEqualTo: user!.uid)
          .orderBy('messageTime', descending: true);
  }

  @override
  bool get wantKeepAlive => true;
}
