import 'package:get/get.dart';

import '../controllers/raffle_controller.dart';

class RaffleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RaffleController>(
      () => RaffleController(),
    );
  }
} 