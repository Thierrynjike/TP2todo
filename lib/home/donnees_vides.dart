import 'package:flutter/material.dart';

class DonneesVides extends StatelessWidget {
  const DonneesVides({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Aucune donnée n'est présente",
        textScaleFactor: 2.5,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
      ),
    );
  }
}
