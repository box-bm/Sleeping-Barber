import 'package:flutter/material.dart';
import 'package:mobile_barbero_dormilon/models/customer.dart';
import 'package:mobile_barbero_dormilon/models/state.dart';
import 'package:uuid/uuid.dart';

class Barber {
  String id = const Uuid().v1();
  int number = 0;
  BarberState state = BarberState.sleeping;
  Customer? customer;

  Barber.create(this.number);

  copyWith({
    String? id,
    int? number,
    BarberState? state,
    Customer? customer,
  }) {
    this.id = id ?? this.id;
    this.number = number ?? this.number;
    this.state = state ?? this.state;
    this.customer = customer ?? this.customer;
  }

  String get stateToString {
    switch (state) {
      case BarberState.sleeping:
        return "💤";
      case BarberState.working:
        return "✂️ C${customer?.number}";
    }
  }

  String get name => "Barbero $number";

  Color get color {
    switch (state) {
      case BarberState.sleeping:
        return Colors.grey;
      case BarberState.working:
        return Colors.blue;
    }
  }
}
