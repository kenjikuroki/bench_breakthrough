// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$workoutHistoryHash() => r'86b30473027e55415da514adca09ea60b5f08c9f';

/// See also [workoutHistory].
@ProviderFor(workoutHistory)
final workoutHistoryProvider =
    AutoDisposeStreamProvider<List<WorkoutHistoryItem>>.internal(
  workoutHistory,
  name: r'workoutHistoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$workoutHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef WorkoutHistoryRef
    = AutoDisposeStreamProviderRef<List<WorkoutHistoryItem>>;
String _$currentMaxHash() => r'8d9854a99ca1ed77d5fd0a2601075188255afb26';

/// See also [CurrentMax].
@ProviderFor(CurrentMax)
final currentMaxProvider =
    AutoDisposeAsyncNotifierProvider<CurrentMax, double>.internal(
  CurrentMax.new,
  name: r'currentMaxProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentMaxHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentMax = AutoDisposeAsyncNotifier<double>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
