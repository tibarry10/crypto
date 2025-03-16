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
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Affichage des prix des cryptos avec des cartes stylisées
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
                    child: Text('$key: ${prices[key]}', style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                ),
              SizedBox(height: 20),
              // Bouton pour actualiser les prix
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
