import 'package:flutter/material.dart';
import 'package:dating_app/services/user_service.dart';
import 'package:dating_app/services/backend_service.dart';

class FriendRequestsDialog extends StatefulWidget {
  const FriendRequestsDialog({super.key});

  @override
  State<FriendRequestsDialog> createState() => _FriendRequestsDialogState();
}

class _FriendRequestsDialogState extends State<FriendRequestsDialog> {
  List<Map<String, dynamic>> requests = [];

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    final data = await UserService().getIncomingFriendRequests();
    setState(() => requests = List<Map<String, dynamic>>.from(data));
  }

  Future<void> requestResponse(String senderUid, int decision) async {
    final String message = await friendRequestResponse(senderUid, decision);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));

    fetchRequests();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Friend Requests'),
      content: SizedBox(
        width: double.maxFinite,
        child:
            requests.isEmpty
                ? const Text("No incoming requests")
                : ListView.builder(
                  shrinkWrap: true,
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    return ListTile(
                      title: Text("Username: ${request['username']}"),
                      subtitle: Text("Short Name: ${request['shortName']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => requestResponse(request['uid'], 1),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => requestResponse(request['uid'], 0),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
