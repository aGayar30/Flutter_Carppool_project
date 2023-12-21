import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Profile.dart';
import 'package:firebase_database/firebase_database.dart';
import 'rideInfo.dart';

class OrderTrackingPage extends StatefulWidget {
  final String? currentUserId;
  final DatabaseReference database;

  OrderTrackingPage({required this.currentUserId, required this.database});

  @override
  _OrderTrackingPageState createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  List<RideData>? userRides; // Use nullable type to represent initial state

  @override
  void initState() {
    super.initState();
    fetchUserRides();
  }

  void fetchUserRides() async {
    List<RideData> fetchedRides = await fetchRidesForUser(widget.currentUserId , widget.database);

    setState(() {
      userRides = fetchedRides;
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
            child: userRides == null
                ? Center(
              child: CircularProgressIndicator(),
            )
                : userRides!.isEmpty
                ? Center(
                  child: Text(
                    'No rides yet, start requesting now!',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                )
                : ListView.builder(
              itemCount: userRides!.length,
              itemBuilder: (context, index) {
                RideData ride = userRides![index];

                return RideCard(
                  from: ride.source,
                  to: ride.destination,
                  driverName: ride.driverName,
                  car: ride.car,
                  price: ride.price,
                  status: ride.status,
                  ride: ride,
                  currentUserId: widget.currentUserId,
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
  final String from;
  final String to;
  final String driverName;
  final String car;
  final String price;
  final String status;
  final RideData ride;
  final String? currentUserId;
  final  DateFormat dateFormat = DateFormat('dd/MM/yyyy');


  RideCard({
    required this.from,
    required this.to,
    required this.driverName,
    required this.car,
    required this.price,
    required this.status,
    required this.ride,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to RideInfoPage and pass the ride data and current user ID
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RideInfo(ride: ride, currentUserId: currentUserId),
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
              '$from to $to',
              style: TextStyle(color: Color(0xFF73C2BE)),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Driver: $driverName',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'Car: $car',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'Date: ${ dateFormat.format(ride.date)}',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'Price: $price',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'Status: $status',
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
  final String status;
  final DateTime date;

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
    required this.status,
    required this.date
  });

  factory RideData.fromMapWithStatus(Map<dynamic, dynamic> map, String driverName, String driverGrade, String driverPhoneNumber, String rideID, String driverID, String status) {
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
      status: status,
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(), // Parse date from the map
    );
  }
}

Future<List<RideData>> fetchRidesForUser(String? userId, DatabaseReference database) async {
  List<RideData> userRides = [];

  // Fetch rides where the current user ID is present as one of the riders
  final ridesSnapshot = await database.child('Rides').once();

  if (ridesSnapshot.snapshot.value != null) {
    final ridesMap = ridesSnapshot.snapshot.value as Map<dynamic, dynamic>;

    for (var entry in ridesMap.entries) {
      // Check if the user is one of the riders
      for (int i = 1; i <= 4; i++) {
        String riderId = entry.value['rider${i}Id'];
        String riderState = entry.value['rider${i}State'];

        if (riderId == userId && riderState != 'none') {
          String driverId = entry.value['driverId'];
          String driverName = await fetchDriverName(driverId, database);
          String driverGrade = await fetchDriverGrade(driverId, database);
          String driverPhoneNumber = await fetchDriverPhoneNumber(driverId, database);

          RideData ride = RideData.fromMapWithStatus(
            entry.value,
            driverName,
            driverGrade,
            driverPhoneNumber,
            entry.key,
            driverId,
            riderState,
          );

          userRides.add(ride);
          break; // Move to the next ride
        }
      }
    }
  }

  return userRides;
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
