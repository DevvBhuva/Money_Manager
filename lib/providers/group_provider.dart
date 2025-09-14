import 'package:flutter/foundation.dart';
import '../models/group.dart';
import '../services/storage_service.dart';

class GroupProvider extends ChangeNotifier {
  final List<Group> _groups = [];
  String? _currentUserId;
  bool _isInitialized = false;

  List<Group> get groups => List.unmodifiable(_groups);
  bool get isInitialized => _isInitialized;

  // ========== INITIALIZATION ==========
  
  /// Initialize the provider with user data
  Future<void> initialize(String userId) async {
    if (_currentUserId == userId && _isInitialized) return;
    
    _currentUserId = userId;
    
    try {
      // Load groups from storage
      final loadedGroups = await StorageService.loadGroups(userId);
      
      _groups.clear();
      _groups.addAll(loadedGroups);
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing GroupProvider: $e');
      _isInitialized = true; // Mark as initialized even if loading failed
    }
  }
  
  /// Clear all data (useful for logout)
  Future<void> clearData() async {
    _groups.clear();
    _currentUserId = null;
    _isInitialized = false;
    notifyListeners();
  }

  // ========== GROUP MANAGEMENT ==========

  void addGroup(Group group) {
    _groups.insert(0, group);
    _saveGroups();
    notifyListeners();
  }

  void updateGroup(Group group) {
    final index = _groups.indexWhere((g) => g.id == group.id);
    if (index != -1) {
      _groups[index] = group;
      _saveGroups();
      notifyListeners();
    }
  }

  void deleteGroup(String groupId) {
    _groups.removeWhere((g) => g.id == groupId);
    _saveGroups();
    notifyListeners();
  }

  void clearGroups() {
    _groups.clear();
    _saveGroups();
    notifyListeners();
  }
  
  Future<void> _saveGroups() async {
    if (_currentUserId != null) {
      await StorageService.saveGroups(_currentUserId!, _groups);
    }
  }
} 