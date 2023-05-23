import 'package:attendance_marker_frontend/screens/single_company_screen.dart';
import 'package:attendance_marker_frontend/utils/constants/size_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/company_model.dart';
import '../utils/constants/backend_api_constants.dart';
import '../utils/constants/color_constants.dart';
import '../utils/constants/model_constants.dart';
import '../utils/constants/text_constants.dart';
import '../utils/widgets/toast_widget.dart';

class AllCompaniesScreen extends StatefulWidget {
  const AllCompaniesScreen({super.key});

  @override
  State<AllCompaniesScreen> createState() => _AllCompaniesScreenState();
}

class _AllCompaniesScreenState extends State<AllCompaniesScreen> {
  bool isLoading = true;
  List companies = [];
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getAllCompanies();
  }

  // ---------------------------------------------- Get All Companies Function Start ----------------------------------------------

  CompanyModel? companyDataFromAPI;
  getAllCompanies() async {
    Dio dio = Dio();
    Response response;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString(ModelConstants.token);

    try {
      response = await dio.get(
        BackendAPIConstants.rootAPI + BackendAPIConstants.getAllCompaniesAPI,
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {ModelConstants.auth: "Bearer $accessToken"},
        ),
      );

      if (response.statusCode == 200) {
        var items = response.data;
        ToastWidget.functionToastWidget(TextConstants.allCompanySuccessToast,
            ColorConstants.toastSuccessColor);
        setState(() {
          companies = items;
        });
        isLoading = false;
      } else {
        ToastWidget.functionToastWidget(
            TextConstants.allCompanyErrorToast, ColorConstants.toastErrorColor);
        setState(() {
          companies = [];
        });
      }
      // return json.decode(response.data);
      return response.data;
    } on DioError catch (e) {
      ToastWidget.functionToastWidget(
          e.toString(), ColorConstants.toastWarningColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: UserAppBarWidget.functionAppBarInside(
      //     TextConstants.allCompaniesAppBarTitleText, context),
      // drawer: NavigationalDrawerWidget.functionUserNavigationalDrawer(context),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: companies.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    var companyId =
                        companies[index][ModelConstants.companyId];
                    var companyName =
                        companies[index][ModelConstants.companyName];
                    var companyLocation =
                        companies[index][ModelConstants.companyLocation];

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SingleCompanyScreen(
                                comId: companyId,
                                comName: companyName,
                                comLocation: companyLocation)));
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        SizeConstants.cardPaddingHorizontal,
                        SizeConstants.cardWithAppBarPaddingTop,
                        SizeConstants.cardPaddingHorizontal,
                        SizeConstants.cardPaddingBottom),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(SizeConstants.cardBorderRadius),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(
                                SizeConstants.cardPaddingAll),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Image.asset(
                                  TextConstants.companiesImageLink,
                                  height: SizeConstants.cardImageHeight,
                                  width: SizeConstants.cardImageWidth,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                    width: SizeConstants.cardContainerWidth),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                          height: SizeConstants
                                              .cardContainerMinHeight),
                                      Text(
                                        TextConstants.cardCompanyName,
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
                                        (companies[index]
                                                [ModelConstants.companyName]
                                            .toString()),
                                        maxLines: 3,
                                        style: TextStyle(
                                          color:
                                              ColorConstants.cardValueTextColor,
                                          fontWeight: FontWeight.normal,
                                          fontSize:
                                              SizeConstants.cardValueTextFontSize,
                                        ),
                                      ),
                                      Container(
                                          height: SizeConstants
                                              .cardContainerMaxHeight),
                                      Text(
                                        TextConstants.cardCompanyLocation,
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
                                              .cardContainerMaxHeight),
                                      Text(
                                        (companies[index]
                                                [ModelConstants.companyLocation]
                                            .toString()),
                                        maxLines: 1,
                                        style: TextStyle(
                                          color:
                                              ColorConstants.cardValueTextColor,
                                          fontWeight: FontWeight.normal,
                                          fontSize:
                                              SizeConstants.cardValueTextFontSize,
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