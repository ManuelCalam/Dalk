import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionProvider extends ChangeNotifier {
  final SupabaseClient _supabase;
  late final StreamSubscription<List<Map<String, dynamic>>> _subscription;

  bool _hasActiveAccess = false;
  bool get isPremium => _hasActiveAccess;

  bool _isCancellationScheduled = false;
  bool get isCancellationScheduled => _isCancellationScheduled;

  String? _currentPeriodEnd;
  String? get currentPeriodEnd => _currentPeriodEnd;

  SubscriptionProvider(this._supabase) {
    _initSubscriptionStatus();
  }

  void _updateStatus(String? status, {String? periodEnd}) {
    if (status == null) {
      _hasActiveAccess = false;
      _isCancellationScheduled = false;
      _currentPeriodEnd = null;
      return;
    }

    const activeAccessStates = {'active', 'trialing', 'canceled_at_period_end'};

    final newHasActiveAccess = activeAccessStates.contains(status);
    final newIsCancellationScheduled = status == 'canceled_at_period_end';

    if (periodEnd != null) {
      _currentPeriodEnd = periodEnd;
    } else if (!newHasActiveAccess) {
      _currentPeriodEnd = null;
    }

    if (_hasActiveAccess != newHasActiveAccess || 
        _isCancellationScheduled != newIsCancellationScheduled ||
        _currentPeriodEnd != periodEnd) 
    {
      _hasActiveAccess = newHasActiveAccess;
      _isCancellationScheduled = newIsCancellationScheduled;
      notifyListeners();
    }
  }

  void _initSubscriptionStatus() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return;
    }

    _supabase
        .from('users')
        .select('subscription_status, subscription_current_period_end')
        .eq('uuid', userId)
        .single()
        .then((data) {
          final status = data['subscription_status'] as String?;
          final periodEnd = data['subscription_current_period_end'] as String?;
          _updateStatus(status, periodEnd: periodEnd);
        });

    _subscription = _supabase
        .from('users')
        .stream(primaryKey: ['uuid'])
        .eq('uuid', userId)
        .listen((data) {
          if (data.isNotEmpty) {
            final status = data.first['subscription_status'] as String?;
            final periodEnd = data.first['subscription_current_period_end'] as String?;
            _updateStatus(status, periodEnd: periodEnd); 
          }
        });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}