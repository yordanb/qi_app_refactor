import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../providers/kpi_provider.dart';
import '../auth/login_page.dart';
import 'page_menu_adm_config.dart';
import 'page_menu_adm_news.dart';
import 'page_menu_adm_tool.dart';
import 'page_menu_ipeak.dart';
import 'page_menu_jarvis.dart';
import 'page_menu_myacvh.dart';
import 'page_menu_sap.dart';
import 'page_menu_ss.dart';
import 'page_menu_ssab.dart';

class CardExample extends ConsumerStatefulWidget {
  const CardExample({super.key});

  @override
  ConsumerState<CardExample> createState() => _CardExampleState();
}

class _CardExampleState extends ConsumerState<CardExample> {
  String role = '';
  String update = '';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    setState(() {
      role = 'Admin'; // Dummy role, replace with actual logic
    });
  }

  @override
  Widget build(BuildContext context) {
    final kpiAsync = ref.watch(kpiProvider);
    final barAsync = ref.watch(barChartProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Plant 2 QI Board Acvh',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: kpiAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (kpi) {
                    update = kpi.update;
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth / 2;
                        final h = constraints.maxHeight / 2;
                        return Wrap(
                          children: List.generate(kpi.items.length, (index) {
                            final kpiItem = kpi.items[index];
                            final rawValue = kpiItem.value;
                            final value = rawValue is String
                                ? double.tryParse(rawValue as String) ?? 0.0
                                : rawValue as double? ?? 0.0;
                            final label = kpiItem.label;
                            List<Color> colors = [
                              Colors.red,
                              Colors.orange,
                              Colors.green,
                            ];

                            return SizedBox(
                              width: w,
                              height: h,
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: Text(
                                      label,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 20.0),
                                    child: SfRadialGauge(
                                      axes: <RadialAxis>[
                                        RadialAxis(
                                          minimum: 0,
                                          maximum: 150,
                                          showLabels: false,
                                          showTicks: false,
                                          ranges: <GaugeRange>[
                                            GaugeRange(
                                              startValue: 0,
                                              endValue: 25,
                                              color: colors[0],
                                            ),
                                            GaugeRange(
                                              startValue: 25,
                                              endValue: 100,
                                              color: colors[1],
                                            ),
                                            GaugeRange(
                                              startValue: 100,
                                              endValue: 150,
                                              color: colors[2],
                                            ),
                                          ],
                                          pointers: <GaugePointer>[
                                            NeedlePointer(value: value),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10.0,
                                      ),
                                      child: Text(
                                        "$value %",
                                        style: TextStyle(
                                          fontSize:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.034,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: barAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (barData) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: barData.length,
                    itemBuilder: (context, index) {
                      final item = barData[index];
                      final title = item['kpi'];
                      final response = List<Map<String, dynamic>>.from(
                        item['response'],
                      );

                      return Card(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: SfCartesianChart(
                            isTransposed: true,
                            title: ChartTitle(text: title),
                            primaryXAxis: const CategoryAxis(
                              labelIntersectAction:
                                  AxisLabelIntersectAction.rotate45,
                            ),
                            primaryYAxis: NumericAxis(
                              title: AxisTitle(
                                text:
                                    title.contains("Zero") ||
                                        title.contains("5")
                                    ? 'Jumlah MP'
                                    : title.contains("Acvh")
                                    ? 'Acvh (%)'
                                    : title == "Pending Approval"
                                    ? 'Jumlah SS'
                                    : 'Acvh (%)',
                              ),
                            ),
                            series: <CartesianSeries>[
                              BarSeries<Map<String, dynamic>, String>(
                                dataSource: response,
                                xValueMapper: (Map data, _) => data['label'],
                                yValueMapper: (Map data, _) =>
                                    double.tryParse(data['value']) ?? 0.0,
                                pointColorMapper: (Map data, _) {
                                  final value =
                                      double.tryParse(data['value']) ?? 0.0;
                                  if (title.contains("Acvh")) {
                                    if (value < 25) return Colors.red;
                                    if (value < 100) return Colors.yellow;
                                    return Colors.green;
                                  } else if (title.contains("Zero")) {
                                    return Colors.red;
                                  } else if (title == "Pending Approval") {
                                    if (value < 25) return Colors.green;
                                    if (value < 100) return Colors.yellow;
                                    return Colors.red;
                                  }
                                  return Colors.red;
                                },
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 5),
            Text('Update: $update'),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180,
                  childAspectRatio: 3.2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                children: [
                  _buildCard(context, 'SS', const PageMenuSS()),
                  _buildCard(context, 'Jarvis', const PageMenuJarvis()),
                  _buildCard(context, 'Ipeak', const PageMenuIpeak()),
                  _buildCard(context, 'SS AB', const PageMenuSsab()),
                  _buildCard(context, 'SAP', const PageMenuSap()),
                  _buildCard(context, 'My Acvh', const PageMenuMyacvh()),
                  if (role == 'Admin') ...[
                    _buildCard(context, 'Config', const PageMenuAdmConfig()),
                    _buildCard(context, 'Tool', const PageMenuAdmTool()),
                    _buildCard(context, 'News', const PageMenuAdmNews()),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, Widget page) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
          if (result == true) {
            setState(() {});
          }
        },
        child: Center(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
