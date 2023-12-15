import 'package:flutter/material.dart';
import 'Profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'ManageRequests.dart';

class DriverRidesPage extends StatefulWidget {
  final DatabaseReference database;

  DriverRidesPage({required this.database});

  @override
  _DriverRidesPageState createState() => _DriverRidesPageState();
}

class _DriverRidesPageState extends State<DriverRidesPage> {
  List<RideData>? driverRides;
  late String currentDriverId;

  @override
  void initState() {
    super.initState();
    fetchDriverId(); // Initialize currentDriverId in initState
    fetchDriverRides();
  }

  void fetchDriverId() async {
    // Get the current user's ID using FirebaseAuth
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentDriverId = user.uid;
      });
    }
  }

  void fetchDriverRides() async {
    List<RideData> fetchedRides = await fetchRidesForDriver(currentDriverId, widget.database);

    setState(() {
      driverRides = fetchedRides;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF495159),
      appBar: AppBar(
        title: Text(
          'Order Tracking',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF73C2BE),
          ),
        ),
        backgroundColor: Color(0xFF495159),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            color: Color(0xFF73C2BE),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: driverRides == null
                ? Center(
              child: CircularProgressIndicator(),
            )
                : driverRides!.isEmpty
                ? Center(
              child: Text(
                'No rides assigned yet!',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            )
                : ListView.builder(
              itemCount: driverRides!.length,
              itemBuilder: (context, index) {
                RideData ride = driverRides![index];


                return RideCard(
                  period: ride.period,
                  from: ride.source,
                  to: ride.destination,
                  car: ride.car,
                  price: ride.price,
                  ride: ride,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RideCard extends StatelessWidget {
  final String period;
  final String from;
  final String to;
  final String car;
  final String price;
  final RideData ride;

  RideCard({
    required this.period,
    required this.from,
    required this.to,
    required this.car,
    required this.price,
    required this.ride
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to RideInfoPage and pass the ride ID
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManageRequests(ride: ride),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Card(
          elevation: 0,
          color: Color(0xC0FDFB),
          child: ListTile(
            title: Text(
              '$period',
              style: TextStyle(color: Color(0xFF73C2BE)),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'From: $from',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'To: $to',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'Car: $car',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'Price: $price',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RideData {
  final String rideID;
  final String car;
  final String destination;
  final String driverID;
  final String driverName;
  final String period;
  final String price;
  final String source;
  final String driverGrade;
  final String driverPhoneNumber;
  final Map<String, String> riderStates;


  RideData({
    required this.rideID,
    required this.car,
    required this.destination,
    required this.driverID,
    required this.driverName,
    required this.period,
    required this.price,
    required this.source,
    required this.driverGrade,
    required this.driverPhoneNumber,
    required this.riderStates,
  });

  // Factory method to create RideData from a Map
  factory RideData.fromMap(Map<dynamic, dynamic> map, String driverName, String driverGrade, String driverPhoneNumber, String rideID, String driverID) {
    return RideData(
      rideID: rideID,
      car: map['car'] ?? '',
      destination: map['destination'] ?? '',
      driverID: driverID,
      driverName: driverName,
      period: map['period'] ?? '',
      price: map['price'] ?? '',
      source: map['source'] ?? '',
      driverGrade: driverGrade,
      driverPhoneNumber: driverPhoneNumber,
      riderStates: {
        'rider1Id': map['rider1Id'] ?? '',
        'rider1State': map['rider1State'] ?? '',
        'rider2Id': map['rider2Id'] ?? '',
        'rider2State': map['rider2State'] ?? '',
        'rider3Id': map['rider3Id'] ?? '',
        'rider3State': map['rider3State'] ?? '',
        'rider4Id': map['rider4Id'] ?? '',
        'rider4State': map['rider4State'] ?? '',
      },
    );
  }
}

Future<List<RideData>> fetchRidesForDriver(String driverId, DatabaseReference database) async {
  List<RideData> driverRides = [];

  // Fetch rides where the current user ID is the driver ID
  final ridesSnapshot = await database.child('Rides').once();

  if (ridesSnapshot.snapshot.value != null) {
    final ridesMap = ridesSnapshot.snapshot.value as Map<dynamic, dynamic>;

    for (var entry in ridesMap.entries) {
      String rideDriverId = entry.value['driverId'];

      if (rideDriverId == driverId) {
        String rider1Id = entry.value['rider1Id'];
        String rider2Id = entry.value['rider2Id'];
        String rider3Id = entry.value['rider3Id'];
        String rider4Id = entry.value['rider4Id'];
        String rider1State = entry.value['rider1State'];
        String rider2State = entry.value['rider2State'];
        String rider3State = entry.value['rider3State'];
        String rider4State = entry.value['rider4State'];

        // Assuming riderState can't be 'none' for more than one rider
        String riderState = rider1State != 'none' ? rider1State : rider2State != 'none' ? rider2State : rider3State != 'none' ? rider3State : rider4State;

        String riderId;
        if (riderState == rider1State) {
          riderId = rider1Id;
        } else if (riderState == rider2State) {
          riderId = rider2Id;
        } else if (riderState == rider3State) {
          riderId = rider3Id;
        } else {
          riderId = rider4Id;
        }

        String driverName = await fetchDriverName(driverId, database);
        String driverGrade = await fetchDriverGrade(driverId, database);
        String driverPhoneNumber = await fetchDriverPhoneNumber(driverId, database);

        RideData ride = RideData.fromMap(
          entry.value,
          driverName,
          driverGrade,
          driverPhoneNumber,
          entry.key,
          driverId,
        );

        driverRides.add(ride);
      }
    }
  }

  return driverRides;
}

Future<String> fetchDriverName(String driverId, DatabaseReference database) async {
  DatabaseEvent dataSnapshot = await database.child('Users').child(driverId).child('name').once();
  return dataSnapshot.snapshot.value.toString();
}

Future<String> fetchDriverGrade(String driverId, DatabaseReference database) async {
  DatabaseEvent dataSnapshot = await database.child('Users').child(driverId).child('grade').once();
  return dataSnapshot.snapshot.value.toString();
}

Future<String> fetchDriverPhoneNumber(String driverId, DatabaseReference database) async {
  DatabaseEvent dataSnapshot = await database.child('Users').child(driverId).child('phoneNumber').once();
  return dataSnapshot.snapshot.value.toString();
}
