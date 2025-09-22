import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:roslibdart/roslibdart.dart';
import 'save.dart'; // ✅ import SavePage

class RobotPage extends StatefulWidget {
  const RobotPage({super.key});

  @override
  State<RobotPage> createState() => _RobotPageState();
}

class _RobotPageState extends State<RobotPage> {
  late Ros ros;
  Topic? poseTopic;
  bool rosConnected = false;
  bool rosConnecting = false;

  @override
  void initState() {
    super.initState();
    _connectRos();
  }

  Future<void> _connectRos() async {
    setState(() => rosConnecting = true);

    ros = Ros(url: 'ws://172.27.209.93:9090');

    try {
       ros.connect(); // ✅ connect แบบ async
      print("✅ Connected to ROS!");
      setState(() {
        rosConnected = true;
        rosConnecting = false;
      });

      poseTopic = Topic(
        ros: ros,
        name: '/arm_target_pose',
        type: 'geometry_msgs/PoseStamped',
      );
    } catch (e) {
      print("⚠️ Error while connecting: $e");
      setState(() {
        rosConnected = false;
        rosConnecting = false;
      });
    }
  }

  void _disconnectRos() {
    try {
      ros.close();
      print("❌ Disconnected from ROS!");
    } catch (e) {
      print("⚠️ Error while closing: $e");
    }
    setState(() => rosConnected = false);
  }

  void _sendPose() {
    if (!rosConnected || poseTopic == null) {
      print("⚠️ Not connected or topic not ready!");
      return;
    }

    final msg = {
      "header": {"frame_id": "world"},
      "pose": {
        "position": {"x": 0.5, "y": 0.0, "z": 0.3},
        "orientation": {"x": 0, "y": 0, "z": 0, "w": 1},
      }
    };

    poseTopic!.publish(msg);
    print("📤 Pose published: $msg");
  }

  Future<void> _savePoseAndGoToSavePage() async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/sketches');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    // เก็บไฟล์ JSON (pose data)
    final file = File('${folder.path}/pose_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString('{"x":0.5,"y":0.0,"z":0.3}');

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SavePage()),
      );
    }
  }

  @override
  void dispose() {
    _disconnectRos();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Robot Control")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (rosConnecting)
              const Text(
                "🔄 Connecting to ROS...",
                style: TextStyle(fontSize: 18, color: Colors.orange),
              )
            else
              Text(
                rosConnected ? "✅ Connected to ROS" : "❌ Not connected",
                style: TextStyle(
                  fontSize: 18,
                  color: rosConnected ? Colors.green : Colors.red,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: rosConnected ? _sendPose : null,
              child: const Text("Send Target Pose"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: rosConnected ? _disconnectRos : _connectRos,
              child: Text(rosConnected ? "Disconnect" : "Reconnect"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: rosConnected ? _savePoseAndGoToSavePage : null,
              child: const Text("Save & Go to Saved Page"),
            ),
          ],
        ),
      ),
    );
  }
}
