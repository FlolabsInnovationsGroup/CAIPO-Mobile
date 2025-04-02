import 'package:flutter/material.dart';
import '../../core/wearable/wearable_service.dart';
import 'package:fl_chart/fl_chart.dart';

class WearableStatusChart extends StatelessWidget {
  const WearableStatusChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wearableService = WearableService();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Wearable Device Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                StreamBuilder<WearableStatus>(
                  stream: wearableService.statusStream,
                  builder: (context, snapshot) {
                    final status = snapshot.data ?? WearableStatus.disconnected;
                    return Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getStatusColor(status),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          status.toString().split('.').last,
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<Map<String, dynamic>>(
              stream: wearableService.dataStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text('Waiting for device data...'),
                  );
                }

                return SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(show: true),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _generateDataPoints(snapshot.data!),
                          isCurved: true,
                          color: Theme.of(context).primaryColor,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(WearableStatus status) {
    switch (status) {
      case WearableStatus.connected:
        return Colors.green;
      case WearableStatus.recording:
        return Colors.blue;
      case WearableStatus.error:
        return Colors.red;
      case WearableStatus.disconnected:
        return Colors.grey;
    }
  }

  List<FlSpot> _generateDataPoints(Map<String, dynamic> data) {
    // Convert your data into chart points
    // This is a placeholder implementation
    final List<FlSpot> spots = [];
    // TODO: Implement actual data conversion based on your data structure
    return spots;
  }
} 