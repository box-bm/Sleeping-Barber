import 'package:flutter/material.dart';
import 'package:mobile_barbero_dormilon/models/state.dart';
import 'package:uuid/uuid.dart';

class Customer {
  String id = const Uuid().v1();

  int number = 0;
  CustomerState state = CustomerState.waiting;

  Customer.create(this.number);

  copyWith({
    String? id,
    int? number,
    CustomerState? state,
  }) {
    this.id = id ?? this.id;
    this.number = number ?? this.number;
    this.state = state ?? this.state;
  }

  String get stateToString {
    switch (state) {
      case CustomerState.done:
        return "✔️";
      case CustomerState.waiting:
        return "⌛️";
      case CustomerState.working:
        return "💇🏻‍♂️";
      default:
        return "-";
    }
  }

  String get name => "Cliente #$number";

  Color get color {
    switch (state) {
      case CustomerState.done:
        return Colors.green;
      case CustomerState.waiting:
        return Colors.orange;
      case CustomerState.working:
        return Colors.blue;
      case CustomerState.exited:
        return Colors.red;
    }
  }
}
