import 'package:get/get.dart';
import 'package:tracking_app/enum/view_state.dart';

class BaseController extends GetxController implements GetxService {
  final _selectedIndex = 0.obs;
  final _state = ViewState.idle.obs;

  get selectedIndex => _selectedIndex.value;

  set selectedIndex(index) => _selectedIndex.value = index;

  ViewState get state => _state.value;

  setState(ViewState state) {
    _state.value = state;
  }
}
