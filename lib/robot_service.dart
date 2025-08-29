import 'package:roslibdart/roslibdart.dart';

class RosService {
  late Ros ros;
  late Topic pub;

  void connect() {
    ros = Ros(url: 'ws://172.27.209.93:9090');
    ros.connect(); // เรียกง่าย ๆ ไม่มี await หรือ callback

    pub = Topic(
      ros: ros,
      name: '/arm_target_pose',
      type: 'geometry_msgs/PoseStamped',
      // queue_size: 10,  <-- เอาออก
    );
  }

  void sendPose() {
    final msg = {
      "header": {"frame_id": "base_link"},
      "pose": {
        "position": {"x": 0.3, "y": 0.0, "z": 0.2},
        "orientation": {"x": 0.0, "y": 0.0, "z": 0.0, "w": 1.0},
      }
    };
    pub.publish(msg);
    print("📤 Pose sent!");
  }
}
