import 'package:flutter/material.dart';

class AvatarElements {
  final String initials;
  final String name;
  final String label;
  final Color color;

  AvatarElements(
      {required this.initials,
      required this.name,
      required this.color,
      this.label = ""});
}

class Description extends StatelessWidget {
  final String title;
  final String description;
  final bool hideDescription;
  final Function()? onAdd;
  final List<AvatarElements> listChild;

  const Description(
      {required this.title,
      required this.description,
      this.onAdd,
      this.hideDescription = false,
      this.listChild = const [],
      super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ListTile(
        title: Row(children: [
          Text(title),
          if (onAdd != null)
            IconButton(onPressed: onAdd, icon: const Icon(Icons.add))
        ]),
        subtitle: !hideDescription ? Text(description) : null,
      ),
      if (listChild.isNotEmpty)
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Wrap(
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                runSpacing: 5,
                spacing: 5,
                children: [
                  ...listChild.map(
                    (e) => Chip(
                      backgroundColor: e.color,
                      label: Text(
                        e.label,
                        style: const TextStyle(fontSize: 16),
                      ),
                      avatar: CircleAvatar(
                        backgroundColor: const Color.fromARGB(61, 0, 0, 0),
                        child: Text(e.initials,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.white)),
                      ),
                    ),
                  )
                ])),
    ]);
  }
}
