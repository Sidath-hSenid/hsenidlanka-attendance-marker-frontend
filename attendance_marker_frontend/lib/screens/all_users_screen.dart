import 'package:attendance_marker_frontend/screens/single_user_screen.dart';
import 'package:attendance_marker_frontend/services/user_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants/backend_api_constants.dart';
import '../utils/constants/color_constants.dart';
import '../utils/constants/model_constants.dart';
import '../utils/constants/size_constants.dart';
import '../utils/constants/text_constants.dart';
import '../utils/widgets/navigational_drawer_widget.dart';
import '../utils/widgets/toast_widget.dart';

class AllUsersScreen extends StatefulWidget {
  const AllUsersScreen({super.key});

  @override
  State<AllUsersScreen> createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends State<AllUsersScreen> {
  bool isLoading = true;
  List users = [];
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getAllUsers();
  }

  // ---------------------------------------------- Get All Users Function Start ----------------------------------------------

  getAllUsers() async {
    Dio dio = Dio();
    Response response;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString(ModelConstants.token);

    try {
      response = await dio.get(
        BackendAPIConstants.rootAPI + BackendAPIConstants.getAllUsersAPI,
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {ModelConstants.auth: "Bearer $accessToken"},
        ),
      );

      if (response.data[ModelConstants.apiStatusCode] == 200) {
        var items = response.data[ModelConstants.apiUserResponseList];
        setState(() {
          users = items;
        });
        isLoading = false;
      } else if (response.data[ModelConstants.apiStatusCode] == 404) {
        ToastWidget.functionToastWidget(
            TextConstants.noDataFound, ColorConstants.toastErrorColor);
        setState(() {
          users = [];
        });
      } else if (response.data[ModelConstants.apiStatusCode] == 400) {
        ToastWidget.functionToastWidget(
            TextConstants.badRequest, ColorConstants.toastErrorColor);
      } else {
        ToastWidget.functionToastWidget(
            TextConstants.allUserErrorToast, ColorConstants.toastErrorColor);
      }
      return response.data;
    } on DioError catch (e) {
      ToastWidget.functionToastWidget(
          e.toString(), ColorConstants.toastWarningColor);
    }
  }

  // ---------------------------------------------- Get All Users Function End ----------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationalDrawerWidget.functionAdminNavigationalDrawer(context),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: users.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    var userId = users[index][ModelConstants.userId];
                    var username = users[index][ModelConstants.username];
                    var email = users[index][ModelConstants.email];
                    var company = users[index][ModelConstants.company];

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SingleUserScreen(
                                useId: userId,
                                usename: username,
                                useEmail: email,
                                useCompany: company)));
                  },
                  onLongPress: () {
                    var userId = users[index][ModelConstants.userId];
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text(
                              TextConstants.alertTitle,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: SizeConstants.alertTitleFontSize,
                                  color: ColorConstants.primaryColor),
                            ),
                            content: const Text(
                              TextConstants.alertDeleteContent,
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: SizeConstants.alertContentFontSize,
                                  color: ColorConstants.primaryColor),
                            ),
                            actions: [
                              TextButton(
                                child: const Text(
                                  TextConstants.alertButtonCancel,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          SizeConstants.alertButtonFontSize,
                                      color: ColorConstants.primaryColor),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text(
                                  TextConstants.alertButtonConfirm,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          SizeConstants.alertButtonFontSize,
                                      color: ColorConstants.primaryColor),
                                ),
                                onPressed: () {
                                  UserService().deleteUserById(userId, context);
                                },
                              ),
                            ],
                          );
                        });
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        SizeConstants.cardPaddingHorizontal,
                        SizeConstants.cardWithAppBarPaddingTop,
                        SizeConstants.cardPaddingHorizontal,
                        SizeConstants.cardPaddingBottom),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            SizeConstants.cardBorderRadius),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(
                                SizeConstants.cardPaddingAll),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  TextConstants.usersImageLink,
                                  height: SizeConstants.cardImageHeight,
                                  width: SizeConstants.cardImageWidth,
                                  fit: BoxFit.contain,
                                ),
                                Container(
                                    width: SizeConstants.cardContainerWidth),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                          height: SizeConstants
                                              .cardContainerMinHeight),
                                      Text(
                                        TextConstants.cardUsername,
                                        style: TextStyle(
                                          color: ColorConstants
                                              .cardAttributeTextColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: SizeConstants
                                              .cardAttributeTextFontSize,
                                        ),
                                      ),
                                      Container(
                                          height: SizeConstants
                                              .cardContainerMinHeight),
                                      Text(
                                        (users[index][ModelConstants.username]
                                            .toString()),
                                        maxLines: 2,
                                        style: TextStyle(
                                          color:
                                              ColorConstants.cardValueTextColor,
                                          fontWeight: FontWeight.normal,
                                          fontSize: SizeConstants
                                              .cardValueTextFontSize,
                                        ),
                                      ),
                                      Container(
                                          height: SizeConstants
                                              .cardContainerMaxHeight),
                                      Text(
                                        TextConstants.cardUserCompany,
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: ColorConstants
                                              .cardAttributeTextColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: SizeConstants
                                              .cardAttributeTextFontSize,
                                        ),
                                      ),
                                      Container(
                                          height: SizeConstants
                                              .cardContainerMinHeight),
                                      Text(
                                        (users[index][ModelConstants.company]
                                                [ModelConstants.companyName]
                                            .toString()),
                                        maxLines: 2,
                                        style: TextStyle(
                                          color:
                                              ColorConstants.cardValueTextColor,
                                          fontWeight: FontWeight.normal,
                                          fontSize: SizeConstants
                                              .cardValueTextFontSize,
                                        ),
                                      ),
                                    ],
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
              },
            ),
    );
  }
}
