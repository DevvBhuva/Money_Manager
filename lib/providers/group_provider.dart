import 'package:flutter/foundation.dart';
import '../models/group.dart';

class GroupProvider extends ChangeNotifier {
  final List<Group> _groups = [];

  List<Group> get groups => List.unmodifiable(_groups);

  void addGroup(Group group) {
    _groups.insert(0, group);
    notifyListeners();
  }

  void updateGroup(Group group) {
    final index = _groups.indexWhere((g) => g.id == group.id);
    if (index != -1) {
      _groups[index] = group;
      notifyListeners();
    }
  }

  void deleteGroup(String groupId) {
    _groups.removeWhere((g) => g.id == groupId);
    notifyListeners();
  }

  void clearGroups() {
    _groups.clear();
    notifyListeners();
  }
} 