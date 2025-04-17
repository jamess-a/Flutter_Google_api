import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Person> fetchPerson() async {
  final response = await http.get(Uri.parse('https://randomuser.me/api/'));

  if (response.statusCode == 200) {
    return Person.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load person');
  }
}

class Person {
  final String gender;
  final String firstName;
  final String lastName;
  final String city;
  final String email;

  Person({
    required this.gender,
    required this.firstName,
    required this.lastName,
    required this.city,
    required this.email,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    final name = json['results'][0]['name'];
    final location = json['results'][0]['location'];

    return Person(
      gender: json['results'][0]['gender'],
      firstName: name['first'],
      lastName: name['last'],
      city: location['city'],
      email: json['results'][0]['email'],
    );
  }
}

class PersonView extends StatefulWidget {
  const PersonView({super.key});

  @override
  State<PersonView> createState() => _PersonViewState();
}

class _PersonViewState extends State<PersonView> {
  late Future<Person> futurePerson;

  @override
  void initState() {
    super.initState();
    futurePerson = fetchPerson();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Random Person')),
      body: Center(
        child: FutureBuilder<Person>(
          future: futurePerson,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Gender: ${snapshot.data!.gender}'),
                  Text(
                      'Name: ${snapshot.data!.firstName} ${snapshot.data!.lastName}'),
                  Text('City: ${snapshot.data!.city}'),
                  Text('Email: ${snapshot.data!.email}'),
                ],
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
