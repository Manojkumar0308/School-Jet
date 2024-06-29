import 'package:flutter/material.dart';

class NotificationRefreshProvider extends ChangeNotifier {
  bool _shouldRefresh = false;

  bool get shouldRefresh => _shouldRefresh;
/*  
when a widget wants to trigger a notification refresh, 
it can call the refresh() method provided by this class.
Widgets that need to know whether notifications 
should be refreshed can listen to changes in the 
shouldRefresh getter and act accordingly.
*/
  void refresh() {
    _shouldRefresh = true;
    notifyListeners();
  }

/*
The consumed() method sets _shouldRefresh to false, 
indicating that the refresh has been consumed or used.
*/
  void consumed() {
    _shouldRefresh = false;
  }
}
