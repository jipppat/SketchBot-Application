import 'package:flutter/material.dart';
import 'package:roslibdart/roslibdart.dart';

class RobotPage extends StatefulWidget {
  const RobotPage({super.key});
  @override
  State<RobotPage> createState() => _RobotPageState();
}

class _RobotPageState extends State<RobotPage> {
  late Ros ros;
  late Topic poseTopic;
  bool rosConnected = false;

  @override
  void initState() {
    super.initState();
    _connectRos();
  }

Future<void> _connectRos() async {
    ros = Ros(url: 'ws://172.27.209.93:9090'); // 👉 เปลี่ยนเป็น IP ของ ROSBridge ของคุณ

    try {
       ros.connect();
      print("✅ Connected to ROS!");
      setState(() => rosConnected = true);

      // สร้าง Topic ที่จะ publish
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

  void _sendPose(double x, double y, double z) {
    if (!rosConnected) return;

    final msg = {
      "header": {"frame_id": "world"},
      "pose": {
        "position": {"x": x, "y": y, "z": z},
        "orientation": {"x": 0.0, "y": 0.0, "z": 0.0, "w": 1.0},
      }
    };
    poseTopic.publish(msg);
    print("📤 Pose sent: x=$x y=$y z=$z");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Robot Control")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () => _sendPose(0.3, 0.0, 0.2),
                child: const Text("Move to Pose 1")),
            ElevatedButton(
                onPressed: () => _sendPose(0.0, 0.2, 0.3),
                child: const Text("Move to Pose 2")),
            const SizedBox(height: 20),
            Text(
              rosConnected ? "ROS Connected" : "ROS Disconnected",
              style: TextStyle(
                  fontSize: 16,
                  color: rosConnected ? Colors.green : Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
