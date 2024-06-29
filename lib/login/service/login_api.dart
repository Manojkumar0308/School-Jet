// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import '../../host_service/host_services.dart';

class LoginApi {
  final HostService hostService = HostService();

  // ignore: prefer_typing_uninitialized_variables
  var responseData;
  bool isLoading = false;
}
