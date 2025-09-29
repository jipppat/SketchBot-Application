import 'dart:io';
import 'dart:convert'; // ✅ base64Decode
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:roslibdart/roslibdart.dart';
import 'dart:typed_data'; // ✅ Uint8List
import 'save.dart';

class RobotPage extends StatefulWidget {
  const RobotPage({super.key});

  @override
  State<RobotPage> createState() => _RobotPageState();
}

class _RobotPageState extends State<RobotPage> {
  late Ros ros;
  Topic? poseTopic;
  Topic? cameraTopic; // ✅ กล้อง
  bool rosConnected = false;
  bool rosConnecting = false;
  Uint8List? cameraImage; // ✅ เก็บภาพจาก ROS

  @override
  void initState() {
    super.initState();
    _connectRos();
  }

  Future<void> _connectRos() async {
    setState(() => rosConnecting = true);

    ros = Ros(url: 'ws://172.27.209.93:9090');

    try {
      ros.connect();
      debugPrint("✅ Connected to ROS!");
      setState(() {
        rosConnected = true;
        rosConnecting = false;
      });

      poseTopic = Topic(
        ros: ros,
        name: '/arm_target_pose',
        type: 'geometry_msgs/PoseStamped',
      );

      cameraTopic = Topic(
        ros: ros,
        name: '/camera/image_raw/compressed',
        type: 'sensor_msgs/CompressedImage',
      );

      _subscribeCamera(); // ✅ ตรงนี้ไม่แดงแล้ว
    } catch (e) {
      debugPrint("⚠️ Error while connecting: $e");
      setState(() {
        rosConnected = false;
        rosConnecting = false;
      });
    }

    return; // ✅ กัน warning async
  }

  void _subscribeCamera() {
    cameraTopic!.subscribe((msg) {
      try {
        final map = msg as Map; // 👈 cast dynamic → Map
        final data = map["data"];

        if (data is String) {
          final decoded = base64Decode(data);
          setState(() {
            cameraImage = decoded;
          });
        } else {
          debugPrint("⚠️ Camera data is not a string: $data");
        }
      } catch (e) {
        debugPrint("⚠️ Camera decode error: $e");
      }
    });
  }

  void _disconnectRos() {
    try {
      ros.close();
      debugPrint("❌ Disconnected from ROS!");
    } catch (e) {
      debugPrint("⚠️ Error while closing: $e");
    }
    setState(() => rosConnected = false);
  }

  void _sendPose() {
    if (!rosConnected || poseTopic == null) {
      debugPrint("⚠️ Not connected or topic not ready!");
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
    debugPrint("📤 Pose published: $msg");
  }

  Future<void> _savePoseAndGoToSavePage() async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/sketches');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    final file =
        File('${folder.path}/pose_${DateTime.now().millisecondsSinceEpoch}.json');
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Robot Control"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.green),
            tooltip: "Save & Go to Saved Page",
            onPressed: rosConnected ? _savePoseAndGoToSavePage : null,
          ),
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: Colors.red),
            tooltip: "Disconnect",
            onPressed: rosConnected ? _disconnectRos : null,
          ),
        ],
      ),
      body: Column(
        children: [
          // 🖥️ พื้นที่กลางจอ แสดงกล้อง ROS
          Expanded(
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400, width: 2),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black,
                ),
                child: Center(
                  child: cameraImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            cameraImage!,
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ),
                        )
                      : rosConnecting
                          ? const Text(
                              "🔄 Connecting to ROS...",
                              style: TextStyle(color: Colors.orange, fontSize: 18),
                            )
                          : rosConnected
                              ? const Text(
                                  "✅ Waiting for camera stream...",
                                  style: TextStyle(color: Colors.green, fontSize: 18),
                                )
                              : const Text(
                                  "❌ Not connected",
                                  style: TextStyle(color: Colors.red, fontSize: 18),
                                ),
                ),
              ),
            ),
          ),

          // 🔘 ปุ่ม Start / Stop / Resume แถวล่าง
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.black,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  icon: const Icon(Icons.play_arrow, color: Colors.black),
                  label: const Text("Start"),
                  onPressed: rosConnected ? _sendPose : null,
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.black,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  icon: const Icon(Icons.stop, color: Colors.black),
                  label: const Text("Stop"),
                  onPressed: rosConnected
                      ? () {
                          debugPrint("🛑 Stop signal sent!");
                        }
                      : null,
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.black,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  icon: const Icon(Icons.refresh, color: Colors.black),
                  label: const Text("Resume"),
                  onPressed: rosConnected
                      ? () {
                          debugPrint("🔄 Resume signal sent!");
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
