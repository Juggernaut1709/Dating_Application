import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dating_app/services/user_service.dart';
import 'package:dating_app/services/backend_service.dart';

class RequestsDialog extends StatefulWidget {
  const RequestsDialog({super.key});

  @override
  State<RequestsDialog> createState() => _RequestsDialogState();
}

class _RequestsDialogState extends State<RequestsDialog> {
  List<Map<String, dynamic>> requests = [];

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    final data = await UserService().getIncomingRequests();
    setState(() => requests = List<Map<String, dynamic>>.from(data));
  }

  Future<void> _requestResponse(
    String senderUid,
    String role,
    int decision,
  ) async {
    final String message = await requestResponse(senderUid, role, decision);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    fetchRequests();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.zero,
      content: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF6A5AE0),
              Color(0xFF74C0FC),
            ], // purple → light blue
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  const Text(
                    'Requests',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Content
                  requests.isEmpty
                      ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          "No incoming requests",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      )
                      : Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final request = requests[index];
                            final isLover = request['role'] == 'L';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 4,
                                    sigmaY: 4,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors:
                                            isLover
                                                ? [
                                                  Colors.pinkAccent.withOpacity(
                                                    0.25,
                                                  ),
                                                  Colors.redAccent.withOpacity(
                                                    0.2,
                                                  ),
                                                ]
                                                : [
                                                  Colors.white.withOpacity(
                                                    0.08,
                                                  ),
                                                  Colors.blueAccent.withOpacity(
                                                    0.1,
                                                  ),
                                                ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.person,
                                          color: Colors.white70,
                                          size: 28,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Username: ${request['username']}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Short Name: ${request['shortName']}",
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        _buildGradientAction(
                                          icon: Icons.check,
                                          gradient: [
                                            Colors.green,
                                            Colors.lightGreenAccent,
                                          ],
                                          onTap:
                                              () => _requestResponse(
                                                request['uid'],
                                                request['role'],
                                                1,
                                              ),
                                        ),
                                        const SizedBox(width: 8),
                                        _buildGradientAction(
                                          icon: Icons.close,
                                          gradient: [
                                            Colors.redAccent,
                                            Colors.deepOrange,
                                          ],
                                          onTap:
                                              () => _requestResponse(
                                                request['uid'],
                                                request['role'],
                                                0,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                  const SizedBox(height: 16),

                  // Close Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                      ),
                      child: const Text("Close"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientAction({
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: gradient.last.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
