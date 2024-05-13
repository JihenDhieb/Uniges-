import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String artCode;
  final String artDes;
  final double artPV;
  final String artFamille2;
  final num artStock;

  ProductCard({
    required this.artCode,
    required this.artDes,
    required this.artPV,
    required this.artFamille2,
    required this.artStock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: Colors.grey.shade300,
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$artCode",
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              artDes,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),

            /*   Text(
              "Category: $artFamille2",
              style: const TextStyle(
                color: Colors.blue,
              ),
            ),*/

            Expanded(child: Text("")),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${artPV.toStringAsFixed(3)} DT",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  artStock > 0 ? "En stock" : "en rupture",
                  style: TextStyle(
                    color: artStock > 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
