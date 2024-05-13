import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uniges/services/uniges_service.dart';
import 'package:uniges/modules/statistique/statistique_service.dart';

class BankCardWidget extends StatelessWidget {
  final String company;

  const BankCardWidget({
    super.key,
    required this.company,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatistiqueService>(
      builder: (controller) {
        final data = controller.calculateSumsForCompanyAndBanks(company);
        final balance = double.parse(data["balance"]);
        final totalIncome = double.parse(data["totalIncome"]);
        final totalOutgoing = double.parse(data["totalOutgoing"]);

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              width: 320,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 0, 128, 255),
                    Color.fromARGB(255, 0, 64, 128),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'SOLDE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      UnigesService.formatNumberWithSpaces(balance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoColumn(
                            totalIncome,
                            const Color.fromARGB(255, 40, 167, 69),
                            Icons.keyboard_double_arrow_down_rounded),
                        _buildInfoColumn(
                            totalOutgoing,
                            const Color.fromARGB(255, 220, 53, 69),
                            Icons.keyboard_double_arrow_up_rounded),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _abbreviateNumber(double value) {
    if (value.abs() >= 1.0e9) {
      return '${(value / 1.0e9).toStringAsFixed(3)}B';
    }
    if (value.abs() >= 1.0e6) {
      return '${(value / 1.0e6).toStringAsFixed(3)}M';
    }
    if (value.abs() >= 1.0e3) {
      return '${(value / 1.0e3).toStringAsFixed(2)}K';
    }
    return value.toStringAsFixed(2);
  }

  Widget _buildInfoColumn(double value, Color color, IconData icon) {
    String formattedValue = (value > 1000000 || value < -1000000)
        ? _abbreviateNumber(value)
        : UnigesService.formatNumberWithSpaces(value);

    return Row(
      children: [
        Icon(
          icon,
          color: color,
        ),
        Text(
          formattedValue,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
