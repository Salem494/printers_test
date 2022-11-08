import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:another_brother/custom_paper.dart';
import 'package:another_brother/label_info.dart';
import 'package:another_brother/printer_info.dart';
import 'package:another_brother/type_b_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final controller = PageController (
      initialPage: 1
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PageView(
          children: [
        WifiPrintPage(title: 'WiFi Sample'),
        WifiPrinterListPage(title: "Sample WiFi List")
      ]
      ),

    );
  }
}

class WifiPrintPage extends StatefulWidget {
  WifiPrintPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _WifiPrintPageState createState() => _WifiPrintPageState();
}

class _WifiPrintPageState extends State<WifiPrintPage> {

  bool _error = false;

  void getPrint(BuildContext context) async {
   print("******");
    Printer printer =  Printer();
    var printInfo = PrinterInfo();
    printInfo.printerModel = Model.PJ_773;
    printInfo.printMode = PrintMode.FIT_TO_PAGE;
    printInfo.isAutoCut = true;
    printInfo.port = Port.NET;
    // Set the label type.
    printInfo.paperSize = PaperSize.A4;
    await printer.setPrinterInfo(printInfo);
    List<NetPrinter> printers = await printer.getNetPrinters([Model.PJ_773.getName()]);

    if (printers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("No printers found on your network."),
        ),
      ));

      return;
    }
    printInfo.ipAddress = printers.single.ipAddress;
    print("********* :${printers.single.ipAddress}");
    printer.setPrinterInfo(printInfo);
    printer.printImage(await loadImage('assets/brother_hack.png'));

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Padding(
              padding:  EdgeInsets.all(8.0),
              child: Text("Don't forget to grant permissions to your app in Settings.",
                textAlign: TextAlign.center,),
            ),
            Image(image: AssetImage('assets/brother_hack.png'))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => getPrint(context),
        tooltip: 'Print',
        child: const Icon(Icons.print),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<ui.Image> loadImage(String assetPath) async {
    final ByteData img = await rootBundle.load(assetPath);
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(new Uint8List.view(img.buffer), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }
}

class WifiPrinterListPage extends StatefulWidget {
  WifiPrinterListPage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _WifiPrinterListPageState createState() => _WifiPrinterListPageState();
}

class _WifiPrinterListPageState extends State<WifiPrinterListPage> {

  Future<List<NetPrinter>>getMyNetworkPrinters() async {
    Printer printer = new Printer();
    PrinterInfo printInfo = new PrinterInfo();

    await printer.setPrinterInfo(printInfo);
    return printer.getNetPrinters([Model.QL_1110NWB.getName(), Model.PJ_773.getName()]);
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: getMyNetworkPrinters(),
        builder: (buildContext, AsyncSnapshot<List<NetPrinter>>snapShot) {

          if(snapShot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Looking for printers."),
            );
          }

          if (snapShot.hasData) {
            // TODO Return a list
            List<NetPrinter> foundPrinters = snapShot.data!;

            if (foundPrinters.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("No printers found."),
              );
            }

            return ListView.builder(
                itemCount: foundPrinters.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(title:Text("Printer: ${foundPrinters[index].modelName}"),
                      subtitle: Text("IP: ${foundPrinters[index].ipAddress}"),
                      onTap: () {
                        // TODO Do anything you want! Maybe print?
                      },
                    ),
                  );
                });
          }
          else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Looking for printers."),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {

          });
        },
        tooltip: 'Retry',
        child: Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<ui.Image> loadImage(String assetPath) async {
    final ByteData img = await rootBundle.load(assetPath);
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(new Uint8List.view(img.buffer), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }
}