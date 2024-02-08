import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var subscription = FlutterBluePlus.onScanResults.listen(
    (results) async {
      if (results.isNotEmpty) {
        ScanResult r = results.last; // the most recently found device
        print('${r.device.remoteId}: "${r.advertisementData.advName}" found!');

        if (r.advertisementData.advName == "Hue") {
          print('Hue found!');
          BluetoothDevice device = r.device;

          await device.connect();
          print('Hue connected!');

          var services = await device.discoverServices();
          services.forEach((service) async {
            //参考 https://future-architect.github.io/articles/20220404b/
            var targetServiceUuid =
                Guid("932c32bd-0000-47a2-835a-a8d455b859dd");

            var brightnessCharacteristicUuid =
                Guid("932c32bd-0003-47a2-835a-a8d455b859dd");

            var temperatureCharacteristicUuid =
                Guid("932c32bd-0004-47a2-835a-a8d455b859dd");

            if (service.serviceUuid == targetServiceUuid) {
              print('Service found!');
              var characteristics = service.characteristics;
              var brightnessCharacteristic = characteristics.firstWhere(
                  (c) => c.characteristicUuid == brightnessCharacteristicUuid);

              var temperatureCharacteristic = characteristics.firstWhere(
                  (c) => c.characteristicUuid == temperatureCharacteristicUuid);

              print(
                  'brightness characteristic found! $brightnessCharacteristic');
              print(
                  'temperature characteristic found! $temperatureCharacteristic');

              for (int i = 1; i < 254; i += 3) {
                await brightnessCharacteristic.write([i]);
                await temperatureCharacteristic.write([i, i]);
              }

              for (int i = 254; i > 2; i -= 3) {
                await brightnessCharacteristic.write([i]);
                await temperatureCharacteristic.write([i, i]);
              }
            }
          });

          // await device.disconnect();
        }
      }
    },
    onError: (e) => print(e),
  );

  void _scanHue() async {
    await FlutterBluePlus.startScan(
        withNames: ["Hue"], timeout: Duration(seconds: 10));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
          child: ElevatedButton(
        onPressed: _scanHue,
        child: Text('Light up!'),
      )
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          ),
    );
  }
}
