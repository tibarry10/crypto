import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Importation pour formater les nombres

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CryptoApp(),
  ));
}

class CryptoApp extends StatefulWidget {
  @override
  _CryptoAppState createState() => _CryptoAppState();
}

class _CryptoAppState extends State<CryptoApp> {
  final NumberFormat formatter = NumberFormat("#,##0.00", "en_US"); // Format des nombres

  // Stocke les prix des cryptos
  Map<String, dynamic> prices = {
    'BTC': 'Loading...',
    'AXL': 'Loading...',
    'OSMO': 'Loading...',
    'TAO': 'Loading...'
  };

  // Stocke les quantités possédées
  Map<String, double> ownedCrypto = {
    'BTC': 2.0,
    'AXL': 0.0,
    'OSMO': 0.0,
    'TAO': 0.0
  };

  // Fonction pour récupérer les prix depuis l'API Binance
  Future<void> fetchPrices() async {
    final url = Uri.parse('https://api.binance.com/api/v3/ticker/price?symbols=%5B%22BTCUSDT%22,%22AXLUSDT%22,%22OSMOUSDT%22,%22TAOUSDT%22%5D');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          for (var item in data) {
            String symbol = item['symbol'].replaceAll('USDT', '');
            prices[symbol] = item['price']; // Met à jour les prix des cryptos
          }
        });
      }
    } catch (e) {
      setState(() {
        prices = {
          'BTC': 'Error',
          'AXL': 'Error',
          'OSMO': 'Error',
          'TAO': 'Error'
        }; // Affiche une erreur si la récupération échoue
      });
    }
  }

  // Fonction pour afficher le menu et modifier les valeurs possédées en bas de l'écran
  void _showCryptoDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext dialogContext) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Modifier la quantité possédée", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: 'BTC',
                onChanged: (String? newValue) {},
                items: ['BTC', 'AXL', 'OSMO', 'TAO'].map<DropdownMenuItem<String>>((String key) {
                  return DropdownMenuItem<String>(
                    value: key,
                    child: Text(key),
                  );
                }).toList(),
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Quantité possédée"),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: Text("Annuler"),
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                  ElevatedButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Fonction pour calculer la valeur totale
  double getTotalValue() {
    double total = 0.0;
    prices.forEach((key, value) {
      if (value != 'Loading...' && value != 'Error') {
        total += (ownedCrypto[key] ?? 0) * double.parse(value);
      }
    });
    return total;
  }

  // Fonction pour générer une Card pour une crypto
  Widget buildCryptoCard(String key) {
    return Card(
      color: Colors.blueGrey[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Text('$key', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('${formatter.format(double.tryParse(prices[key].toString()) ?? 0)} USD', style: TextStyle(fontSize: 20, color: Colors.green)),
            Text('Possédé: ${formatter.format(ownedCrypto[key] ?? 0)}', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchPrices(); // Récupère les prix au lancement de l'application
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Colors.grey, fontSize: 18),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('${formatter.format(getTotalValue())} USD', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.blueGrey[900],
          centerTitle: true,
          actions: [
            PopupMenuButton<String>( // Remplacement de l'icône de stylo par les trois petits points
              onSelected: (value) {
                if (value == 'edit') {
                  _showCryptoDialog();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Modifier les quantités'),
                ),
              ],
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var key in prices.keys) buildCryptoCard(key),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: fetchPrices,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[700],
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text('Actualiser'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
