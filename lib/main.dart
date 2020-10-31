import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'location_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserLocation>(
      create: (context) => LocationService().locationStream,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _latitudeController,
                  decoration: InputDecoration(
                      hintText: "Latitude", labelText: "Latitude"),
                ),
                TextFormField(
                  controller: _longitudeController,
                  decoration: InputDecoration(
                      hintText: "Longitude", labelText: "Longitude"),
                ),
                RaisedButton(
                  onPressed: () async {
                    debugPrint("====" + _latitudeController.text.toString());
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setDouble("lat",
                        double.parse(_latitudeController.text.toString()));
                    prefs.setDouble("long",
                        double.parse(_longitudeController.text.toString()));
                  },
                  child: Text("Set LatLong"),
                ),
                LocationView()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Null> _initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _latitudeController.text = prefs.getDouble("lat").toString() == "null"
          ? "-6.1476692"
          : prefs.getDouble("lat").toString();
      _longitudeController.text = prefs.getDouble("long").toString() == "null"
          ? "106.7746505"
          : prefs.getDouble("long").toString();
    });
  }
}

class LocationView extends StatelessWidget {
  const LocationView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var userLocation = Provider.of<UserLocation>(context);
    return Row(
      children: [
        Container(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
            )),
        Expanded(
                  child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SelectableText(
                    'Location Now= ${userLocation?.latitude}, ${userLocation?.longitude}'),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                    "Location Office = ${userLocation.latitudeOffice}, ${userLocation.longitudeOffice}"),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text("Distance = ${userLocation.distance}"),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text("Address Now = ${userLocation.address}"),
              ),
            ],
          ),
        )
      ],
    );
  }
}
