import 'package:flutter/material.dart';
import 'package:roslibdart/roslibdart.dart';

class RobotPage extends StatefulWidget {
  const RobotPage({super.key});

  @override
  State<RobotPage> createState() => _RobotPageState();
}

class _RobotPageState extends State<RobotPage> {
  late Ros ros;
  Topic? poseTopic;
  bool rosConnected = false;

  @override
  void initState() {
    super.initState();
    _connectRos();
  }

  Future<void> _connectRos() async {
    ros = Ros(url: 'ws://172.27.209.93:9090'); // 👉 เปลี่ยนเป็น IP VM ของ ROSBridge

    try {
      ros.connect();
      print("✅ Connected to ROS!");
      setState(() => rosConnected = true);

      // กำหนด Topic สำหรับ publish
      poseTopic = Topic(
        ros: ros,
        name: '/arm_target_pose',
        type: 'geometry_msgs/PoseStamped',
      );
    } catch (e) {
      print("⚠️ Failed to connect to ROS: $e");
      setState(() => rosConnected = false);
    }
  }

  Future<void> _disconnectRos() async {
    try {
      await ros.close();
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

    poseTopic!.publish(msg); // ✅ ไม่ต้อง advertise()
    print("📤 Pose published: $msg");
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
          ],
        ),
      ),
    );
  }
}
