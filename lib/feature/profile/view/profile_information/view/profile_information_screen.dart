import 'package:demandium_provider/feature/profile/view/profile_information/widgets/address_info_tab.dart';
import 'package:demandium_provider/feature/profile/view/profile_information/widgets/company_identification_tab.dart';
import 'package:demandium_provider/feature/profile/view/profile_information/widgets/company_info_tab.dart';
import 'package:demandium_provider/feature/profile/view/profile_information/widgets/contact_identification_tab.dart';
import 'package:demandium_provider/feature/profile/view/profile_information/widgets/contact_person_info_tab.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class ProfileInformationScreen extends StatefulWidget {
  const ProfileInformationScreen({super.key});

  @override
  State<ProfileInformationScreen> createState() => _ProfileInformationScreenState();
}

class _ProfileInformationScreenState extends State<ProfileInformationScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    UserProfileController.scheduleProfileDataLoad(reloadProvider: true);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  int _tabCount(bool isCompany) => isCompany ? 5 : 3;

  void _ensureTabController(bool isCompany) {
    final length = _tabCount(isCompany);
    if (_tabController == null || _tabController!.length != length) {
      _tabController?.dispose();
      _tabController = TabController(length: length, vsync: this);
    }
  }

  List<String> _tabLabels(bool isCompany) {
    if (isCompany) {
      return [
        'contact_person_info_title',
        'contact_person_identity',
        'company_information',
        'address_information',
        'company_documents',
      ];
    }
    return [
      'contact_person_info_title',
      'contact_person_identity',
      'address_information',
    ];
  }

  List<Widget> _tabViews(bool isCompany) {
    if (isCompany) {
      return const [
        ContactPersonInfoTab(),
        ContactIdentificationTab(),
        CompanyInfoTab(),
        AddressInfoTab(),
        CompanyIdentificationTab(),
      ];
    }
    return const [
      ContactPersonInfoTab(),
      ContactIdentificationTab(),
      AddressInfoTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(builder: (c) {
      final isCompany = c.isCompanyProvider;
      _ensureTabController(isCompany);
      final labels = _tabLabels(isCompany);

      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: CustomAppBar(title: trLabel('edit_profile')),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SizedBox(height: Dimensions.paddingSizeSmall),
              Container(
                height: 45,
                margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                    color: context.adaptivePrimaryColor,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  labelStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                  unselectedLabelStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                  tabAlignment: TabAlignment.start,
                  dividerHeight: 0,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  splashBorderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                  tabs: labels
                      .map((key) => Tab(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                                color: context.adaptivePrimaryColor.withValues(alpha: 0.1),
                              ),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(trLabel(key)),
                            ),
                          ))
                      .toList(),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _tabViews(isCompany),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
