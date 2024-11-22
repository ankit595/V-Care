import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatisticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Sample data for demonstration
    final List<ChartData> chartData = [
      ChartData('Jan', 30, 25), // Total patients: 30, Treated patients: 20
      ChartData('Feb', 40, 38), // Total patients: 40, Treated patients: 25
      ChartData('Mar', 35, 34), // Total patients: 35, Treated patients: 30
      // Add more data as needed
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics',
          style: TextStyle(
              color: Colors.black,
              fontFamily: "Itim",
              fontSize: 25),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text("Total",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Itim",
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text("105",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Itim",
                          fontSize: 15),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text("Recovered",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Itim",
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text("97",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Itim",
                          fontSize: 15),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text("On Medication",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Itim",
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text("8",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Itim",
                          fontSize: 15),
                    ),
                  ],
                )
              ],
            ),
          ),
          Center(
            child: Container(
              height: 400,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  title: AxisTitle(text: 'Months'), // X-axis label
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Number of Patients %'), // Y-axis label
                ),
                series: <ChartSeries>[
                  // Render column chart
                  ColumnSeries<ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (ChartData data, _) => data.month,
                    yValueMapper: (ChartData data, _) => data.totalPatients,
                    // Color each column based on the series index
                    color: Color(0xFF9F01C9),
                    name: 'Total Patients',
                  ),
                  ColumnSeries<ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (ChartData data, _) => data.month,
                    yValueMapper: (ChartData data, _) => data.treatedPatients,
                    // Color each column based on the series index
                    color: Color(0x9F9E5EFF),
                    name: 'Treated Patients',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final String month;
  final int totalPatients;
  final int treatedPatients;

  ChartData(this.month, this.totalPatients, this.treatedPatients);
}