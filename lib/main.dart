import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(CryptoApp()); // Démarre l'application Flutter
}

class CryptoApp extends StatefulWidget {
  @override
  _CryptoAppState createState() => _CryptoAppState();
}

class _CryptoAppState extends State<CryptoApp> {
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
    final url = Uri.parse('https://api.binance.com/api/v3/ticker/price?symbols=["BTCUSDT","AXLUSDT","OSMOUSDT","TAOUSDT"]');
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

  // Fonction pour afficher le menu et modifier les valeurs possédées
  void _showCryptoDialog() {
    String selectedCrypto = 'BTC';
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choisissez votre crypto et quantité"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedCrypto,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCrypto = newValue!;
                  });
                },
                items: ownedCrypto.keys.map<DropdownMenuItem<String>>((String key) {
                  return DropdownMenuItem<String>(
                    value: key,
                    child: Text(key),
                  );
                }).toList(),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Quantité possédée"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Annuler"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("OK"),
              onPressed: () {
                setState(() {
                  ownedCrypto[selectedCrypto] = double.tryParse(amountController.text) ?? 0.0;
                });
                Navigator.pop(context);
              },
            ),
          ],
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
          title: Text('Crypto Tracker', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.blueGrey[900],
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: _showCryptoDialog,
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var key in prices.keys)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[800],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    child: Column(
                      children: [
                        Text('$key: ${prices[key]}', style: TextStyle(fontSize: 20, color: Colors.white)),
                        Text('Possédé: ${ownedCrypto[key]}', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 20),
              Text('Valeur totale: ${getTotalValue().toStringAsFixed(2)} USD', style: TextStyle(fontSize: 22, color: Colors.green)),
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
