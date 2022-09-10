import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:mobile_barbero_dormilon/description.dart';
import 'package:mobile_barbero_dormilon/models/barber.dart';
import 'package:mobile_barbero_dormilon/models/customer.dart';
import 'package:mobile_barbero_dormilon/models/state.dart';

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
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Barbero Dormilon'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int taskLimit = 5;
  int taskTime = 5;
  List<Customer> customers = [];
  List<Barber> barbers = [Barber.create(1)];
  Queue<Duration> timerQueue = Queue<Duration>();

  void _resetSettings() {
    setState(() {
      taskLimit = 5;
      customers = [];
      barbers = [Barber.create(1)];
    });
  }

  void _increaseTaskLimit() {
    setState(() {
      taskLimit++;
    });
  }

  void _decreaseTaskLimit() {
    if (getWaitingCustomers().length > taskLimit - 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            "No se puede reducir la cantidad de procesos a un numero menor de clientes"),
      ));
    } else if (taskLimit > 1) {
      setState(() {
        taskLimit--;
      });
    } else {}
  }

  void _increaseTaskTime() {
    setState(() {
      taskTime++;
    });
  }

  void _decreaseTaskTime() {
    if (taskTime == 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("No se puede reducir el tiempo a menos de 1 segundo"),
      ));
      return;
    }
    setState(() {
      taskTime--;
    });
  }

  List<Customer> getWaitingCustomers() => customers
      .where((customer) => customer.state == CustomerState.waiting)
      .toList();

  List<Barber> getSleepingBarbers() =>
      barbers.where((barber) => barber.state == BarberState.sleeping).toList();

  void _addCustomer() {
    List<Barber> sleepingBarbers = getSleepingBarbers();
    if (taskLimit + sleepingBarbers.length > getWaitingCustomers().length) {
      Customer newCustomer = Customer.create(customers.length + 1);
      setState(() {
        customers = [
          ...customers,
          newCustomer,
        ];
      });
      validateDisponibility();
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Se ha llenado el maximo de clientes en la barberia"),
      ));
    }
  }

  void _addBarber() {
    setState(() {
      barbers = [...barbers, Barber.create(barbers.length + 1)];
    });
    validateDisponibility();
  }

  void validateDisponibility() {
    List<Barber> sleepingBarbers = getSleepingBarbers();
    List<Customer> waitingCustomer = getWaitingCustomers();
    if (sleepingBarbers.isNotEmpty && waitingCustomer.isNotEmpty) {
      assingTask(sleepingBarbers.first, waitingCustomer.first);
    }
  }

  void assingTask(Barber barber, Customer customer) {
    setState(() {
      barbers
          .firstWhere((element) => element.id == barber.id)
          .copyWith(state: BarberState.working, customer: customer);
      customers
          .firstWhere((element) => element.id == customer.id)
          .copyWith(state: CustomerState.working);
    });
    prepareDoneTask(barber);
  }

  void prepareDoneTask(Barber barber) {
    Timer(Duration(seconds: taskTime), (() {
      setState(() {
        customers
            .firstWhere((element) => element.id == barber.customer!.id)
            .copyWith(state: CustomerState.done);
      });
      Timer(const Duration(seconds: 2), (() {
        setState(() {
          customers
              .firstWhere((element) => element.id == barber.customer!.id)
              .copyWith(state: CustomerState.exited);
          barbers
              .firstWhere((element) => element.id == barber.id)
              .copyWith(state: BarberState.sleeping, customer: null);
        });
        validateDisponibility();
      }));
    }));
  }

  void _seeDetails() {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return ListView(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(left: 14, top: 20, bottom: 20),
                child: const Text(
                  'Información',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const Description(
                title: "Asientos",
                description:
                    "Listado de la cantidad maxima de procesos que se pueden tener almacenados",
              ),
              const Description(
                title: "Barbero",
                description:
                    "El barbero representa los procesos que se pueden ejecutar durante el proceso de administracion de tareas, mientras mas barberos mas tareas en simultaneo se estaran ejecutando",
              ),
              const Description(
                title: "Clientes",
                description:
                    "Los clientes son cada una de las tareas que estan ya sea en la cola o siendo ejecutados. Idependientemente su estado estos deben ser atendidos por el procesador (Barbero).",
              ),
              const Divider(),
              Container(
                padding: const EdgeInsets.only(left: 14, top: 20),
                child: const Text(
                  'Grupo #5',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const Description(
                title: "Eduardo Humberto Aroche Noriega",
                description: "9490-10-6270, earochen@miumg.edu.gt",
              ),
              const Description(
                title: "Yelsyn Adrid Hernandez Cruz",
                description: "9490-17-969, yhernandezc10@miumg.edu.gt",
              ),
              const Description(
                title: "Brandon Gerardo Manzo Godoy",
                description: "9490-18-502, bmanzog@miumg.edu.gt",
              ),
              ElevatedButton(
                child: const Text('Cerrar'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: _seeDetails, icon: const Icon(Icons.info_outline)),
          IconButton(
              onPressed: _resetSettings, icon: const Icon(Icons.restart_alt))
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 10,
          ),
          ListTile(
            title: Text("Sillas: $taskLimit"),
            subtitle: Row(
              children: [
                ElevatedButton.icon(
                    label: const Text("Agregar"),
                    onPressed: _increaseTaskLimit,
                    icon: const Icon(Icons.add)),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton.icon(
                  label: const Text("Quitar"),
                  onPressed: _decreaseTaskLimit,
                  icon: const Icon(Icons.remove),
                )
              ],
            ),
          ),
          ListTile(
            title: Text("Tiempo estimado: $taskTime segundos"),
            subtitle: Row(
              children: [
                ElevatedButton.icon(
                    label: const Text("Agregar"),
                    onPressed: _increaseTaskTime,
                    icon: const Icon(Icons.add)),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton.icon(
                  label: const Text("Quitar"),
                  onPressed: _decreaseTaskTime,
                  icon: const Icon(Icons.remove),
                )
              ],
            ),
          ),
          const Divider(),
          Description(
            title: "Barberos",
            description:
                "El barbero representa los procesos que se pueden ejecutar simultaneos.",
            onAdd: _addBarber,
            listChild: barbers
                .map((e) => AvatarElements(
                    initials: "B${e.number}",
                    name: e.name,
                    color: e.color,
                    label: e.stateToString))
                .toList(),
          ),
          Description(
            title: "Clientes",
            description:
                "Los clientes son cada una de las tareas ingresadas al sistema.",
            onAdd: _addCustomer,
            listChild: customers
                .where((element) => element.state != CustomerState.exited)
                .map((e) => AvatarElements(
                    initials: "C${e.number}",
                    name: e.name,
                    color: e.color,
                    label: e.stateToString))
                .toList(),
          ),
          const Spacer()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCustomer,
        tooltip: 'Increment',
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
