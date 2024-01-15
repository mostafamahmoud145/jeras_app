import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/widget/component/IconButton.dart';
import 'package:jeras/widget/custom_back_button.dart';
import 'package:jeras/widget/responsive.dart';

import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../FireStorePagnation/bloc/pagination_listeners.dart';
import '../FireStorePagnation/paginate_firestore.dart';
import '../config/app_constat.dart';
import '../config/app_values.dart';
import '../config/colors_file.dart';
import '../models/chat.dart';
import '../widget/chatListItem.dart';

class ChatScreen extends StatefulWidget {
  final GroceryUser user;

  const ChatScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  PaginateRefreshedChangeListener refreshChangeListener =
      PaginateRefreshedChangeListener();
  late Query filterQuery;
  String lang ='';
  @override
  void initState() {
    super.initState();
    if (widget.user.userType == "USER")
      filterQuery = FirebaseFirestore.instance
          .collection('Chat')
          .where('user.uid', isEqualTo: widget.user.uid)
          .orderBy('messageTime', descending: true);
    else
      filterQuery = FirebaseFirestore.instance
          .collection('Chat')
          .where('consult.uid', isEqualTo: widget.user.uid)
          .orderBy('messageTime', descending: true);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");

    return Scaffold(
      body: Stack(children: <Widget>[
        Column(
          children: <Widget>[
            Container(
                width: size.width,
                child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.width * AppPadding.p0_06 : AppPadding.p20,
                          right:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.width * AppPadding.p0_06 : AppPadding.p20,
                          top: AppPadding.p10,
                          bottom: AppPadding.p10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                    CustomBackButton(),
                                             SizedBox(width: AppSize.w10.w),
                          Text(
                            getTranslated(context, "chat"),
                            style: TextStyle(
                              fontFamily: getTranslated(context, "Ithra"),
                              fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s34.sp : AppFontsSizeManager.s21_3.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black1,
                            ),
                          ),
                        ],
                      ),
                    ))),
            Center(
                child: Container(
                    color: AppColors.lightGrey,
                    height: AppSize.h1.h,
                    width: size.width)),
            Expanded(
              child: RefreshIndicator(
                child: PaginateFirestore(
                  key: ValueKey(filterQuery),
                  itemBuilderType: PaginateBuilderType.listView,
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.width * AppPadding.p0_06 : AppPadding.p20,
                    vertical: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? size.height * AppPadding.p0_06
                        : AppPadding.p20.h,
                  ),
                  //Change types accordingly
                  itemBuilder: (context, documentSnapshot, index) {
                    return ChatListItem(
                      size: size,
                      item: Chat.fromMap(documentSnapshot[index].data() as Map),
                      user: widget.user,
                    );
                  },
                  query: filterQuery,
                  separator: Container(
                    //widthchat
                    width: size.width,
                    height: AppSize.h1.h,
                    color:AppColors.borderLightGrey,
                  ),
                  listeners: [
                    refreshChangeListener,
                  ],
                  isLive: true,
                ),
                onRefresh: () async {
                  refreshChangeListener.refreshed = true;
                },
              ),
            )
          ],
        ),
      ]),
    );
  }
}
