import 'package:flutter/material.dart';

class UserProfileBottomSheet extends StatelessWidget {
  final Map<String, dynamic> profile;

  const UserProfileBottomSheet({Key? key, required this.profile})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 72,
                height: 72,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(Icons.person, size: 40),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name : ${profile['name']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Age : ${profile['age']}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite_border),
              color: const Color.fromARGB(255, 209, 25, 12),
              onPressed: () {},
              tooltip: 'Add Interest',
            ),
            IconButton(
              icon: const Icon(Icons.person_add),
              color: const Color.fromARGB(255, 8, 158, 158),
              onPressed: () {},
              tooltip: 'Add Friend',
            ),
          ],
        ),
      ),
    );
  }
}
