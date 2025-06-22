import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mes_mobile_app/common_widgets/dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mes_mobile_app/screens/login/login_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:mes_mobile_app/styles/text_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;

  final List<String> _adImages = [
    'assets/assetslogo.png',
    'assets/ro.png',
    'assets/플루터 네비게이터 함수.png',
    'assets/반환 정석.png',
  ];

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_currentPage < _adImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildAdBanner(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(imagePath, fit: BoxFit.cover, width: double.infinity),
    );
  }

  // 기존 build()는 그대로 유지되며, 위에 PageView만 바꿈
  @override
  Widget build(BuildContext context) {
    //region - 삭제예정 -
    final List<String> dates = [
      '5/19',
      '5/20',
      '5/21',
      '5/22',
      '5/23',
      '5/24',
      '5/26',
      '5/27',
      '5/28',
      '5/30',
      '5/31',
      '6/1',
      '6/2',
      '6/3',
      '6/4',
      '6/5',
      '6/6',
      '6/7',
      '6/8',
      '6/9',
      '6/10',
      '6/11',
    ];

    final List<FlSpot> spots = [
      FlSpot(0, 4),
      FlSpot(1, 4),
      FlSpot(2, 6),
      FlSpot(3, 5),
      FlSpot(4, 7),
      FlSpot(5, 11),
      FlSpot(6, 7),
      FlSpot(7, 7),
      FlSpot(8, 7),
      FlSpot(9, 9),
      FlSpot(10, 11),
      FlSpot(11, 4),
      FlSpot(12, 6),
      FlSpot(13, 2),
      FlSpot(14, 5),
      FlSpot(15, 5),
      FlSpot(16, 10),
      FlSpot(17, 10),
      FlSpot(18, 4),
      FlSpot(19, 9),
      FlSpot(20, 6),
      FlSpot(21, 5),
    ];

    //endregion

    return Scaffold(
      appBar: AppBar(
        title: const Text("", style: AppTextStyles.subtitle),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 94, 176, 255),
      ),

      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Center(
                child: Text(
                  'MES 메뉴',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.notifications,
              title: '알람 내역 확인',
              routeName: '/alarms',
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.inventory,
              title: '적치/피킹',
              routeName: '/putawayAndPicking',
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.qr_code_scanner,
              title: '재고 조회',
              routeName: '/locationInventory',
            ),
            const Spacer(),
            Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                '로그아웃',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('jwt');
                await prefs.remove('fcm');
                await prefs.remove('user_id');

                const storage = FlutterSecureStorage();
                await storage.delete(key: 'jwt');
                await storage.delete(key: 'fcm');
                await storage.delete(key: 'user_id');


                if (context.mounted) {
                  DialogHelper.showErrorDialog(context, "로그아웃 완료");
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔁 자동 슬라이드 배너
            const Text(
              "Screen",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color.fromARGB(255, 139, 157, 186)),
              ),
              child: SizedBox(
                height: 180,
                child: PageView(
                  controller: _pageController,
                  children: _adImages
                      .map((path) => _buildAdBanner(path))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "공수 Chart",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              //region - 삭제예정 -
              child: SizedBox(
                height: 350,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: 21,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        barWidth: 3,
                        color: Colors.blue,
                        dotData: FlDotData(show: false),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 2,
                          getTitlesWidget: (value, meta) {
                            return Text(value.toInt().toString());
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1, // 더 촘촘하게 찍기
                          reservedSize: 32, // 아래 padding 확보 (이게 중요)
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index >= 0 && index < dates.length) {
                              return Transform.rotate(
                                angle: -0.5, // 회전
                                child: Text(
                                  dates[index],
                                  style: TextStyle(fontSize: 9),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: true),
                  ),
                ),
              ),
            ),
            //endregion
            const SizedBox(height: 32),
            const Text(
              "소요 분야",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 450,
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 20,
                      title: '개발 환경 세팅',
                      titleStyle: AppTextStyles.subtitle,
                      radius: 50,
                      color: Color.fromARGB(255, 255, 17, 43),
                    ),
                    PieChartSectionData(
                      value: 10,
                      title: '서버 및 외부 IP 세팅',
                      titleStyle: AppTextStyles.subtitle,
                      radius: 50,
                      color: Color.fromARGB(255, 39, 239, 9),
                    ),
                    PieChartSectionData(
                      value: 25,
                      title: 'REST API개발',
                      titleStyle: AppTextStyles.subtitle,
                      radius: 50,
                      color: Color.fromARGB(255, 243, 255, 0),
                    ),
                    PieChartSectionData(
                      value: 45,
                      title: 'FLUTTER 개발',
                      titleStyle: AppTextStyles.subtitle,
                      radius: 50,
                      color: Color.fromARGB(255, 123, 255, 0),
                    ),
                  ],
                  sectionsSpace: 4,
                  centerSpaceRadius: 50,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String routeName,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, routeName);
      },
    );
  }
}
