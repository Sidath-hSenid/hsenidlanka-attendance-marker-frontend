import 'package:attendance_marker_frontend/screens/add_end_time_screen.dart';
import 'package:attendance_marker_frontend/screens/add_start_time_screen.dart';
import 'package:attendance_marker_frontend/screens/user_view_attendances_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/user_service.dart';
import '../utils/constants/color_constants.dart';
import '../utils/constants/icon_constants.dart';
import '../utils/constants/model_constants.dart';
import '../utils/constants/size_constants.dart';
import '../utils/constants/text_constants.dart';
import '../utils/widgets/navigational_drawer_widget.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  // ---------------------------------------------- Get All Companies Function Start ----------------------------------------------

  var username = "";
  var email = "";
  var companyName = "";
  var companyLocation = "";

  @override
  void initState() {
    super.initState();
    getUserById();
  }

  getUserById() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString(ModelConstants.username).toString();
      email = prefs.getString(ModelConstants.email).toString();
      companyName = prefs.getString(ModelConstants.companyName).toString();
      companyLocation =
          prefs.getString(ModelConstants.companyLocation).toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: NavigationalDrawerWidget.functionUserNavigationalDrawer(
            username, email, companyName, companyLocation, context),
        appBar: AppBar(
          title: const Text(TextConstants.appTitle),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(
                  icon: Icon(IconConstants.viewAttendances),
                  text: TextConstants.viewUserAttendancesTitleText),
              Tab(
                  icon: Icon(IconConstants.attendanceStartTime),
                  text: TextConstants.addStartTimeTitleText),
              Tab(
                  icon: Icon(IconConstants.attendanceEndTime),
                  text: TextConstants.addEndTimeTitleText)
            ],
          ),
          actions: <Widget>[
            IconButton(
              alignment: Alignment.centerRight,
              icon: const Icon(
                IconConstants.appLogOut,
                color: ColorConstants.appBarIconColor,
                size: SizeConstants.appBarIconSize,
              ),
              onPressed: () {
                UserService().logOut(context);
              },
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            UserViewAttendancesScreen(),
            AddStartTimeScreen(),
            AddEndTimeScreen(),
          ],
        ),
      ),
    );
  }
}
