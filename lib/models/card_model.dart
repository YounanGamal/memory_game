import 'package:get/get.dart';

class CardModel {
  final int id;
  final String value;
  final RxBool isFlipped = false.obs;
  final RxBool isMatched = false.obs;
  final RxBool isWrong = false.obs;
  final RxBool isHighlighted = false.obs;

  CardModel({required this.id, required this.value});

  void reset() {
    isFlipped.value = false;
    isMatched.value = false;
    isWrong.value = false;
    isHighlighted.value = false;
  }
}
