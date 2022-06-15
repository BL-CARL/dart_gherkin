import 'dart:async';

import 'package:collection/collection.dart';

import 'message_level.dart';
import 'messages/messages.dart';

typedef VoidCallback = void Function();

typedef ReportInvoke<T extends Reporter> = Future<void>? Function(T report);

typedef FutureAction = Future<void> Function();

typedef ActionReport<T> = Future<void> Function([T? message]);

typedef FutureValueAction<T> = Future<void> Function(T message);

/// {@template reporter.reporteractionhandler}
/// Auxiliary class for customizing the actions of features
/// {@endtemplate}
class ReportActionHandler<S extends ActionMessage> {
  /// Provides interaction with the function after the start of a certain action
  final StateAction<S> onStarted;

  /// Provides interaction with the function after the finish of a certain action
  final StateAction<S> onFinished;

  /// {@macro reporter.reporteractionhandler}
  ReportActionHandler({
    ActionReport<S>? onStarted,
    ActionReport<S>? onFinished,
  })  : onStarted = StateAction<S>(action: onStarted),
        onFinished = StateAction<S>(action: onFinished);

  List<StateAction> get stateActions => [onStarted, onFinished];

  factory ReportActionHandler.empty() => ReportActionHandler<S>();
}

/// {@template reporter.stateaction}
/// Auxiliary class for performing various actions
/// {@endtemplate}
class StateAction<T extends ActionMessage> {
  final ActionReport<T>? _action;

  /// {@macro reporter.stateaction}
  ///
  /// [action] - an action is a callback function
  StateAction({
    ActionReport<T>? action,
  }) : _action = action;

  /// The function of safely calling an action.
  /// Inside notifies listeners (calls [notifyListeners]).
  Future<void> maybeCall([T? value]) async {
    if (_action != null) {
      await _action!.call(value);
    }
  }
}

/// {@template reporter.reporter}
/// An abstract class both for all reporters
/// {@endtemplate}
abstract class Reporter {}

/// {@template reporter.testreporter}
/// An abstract class that allows you to track the status of the start of tests.
/// {@endtemplate}
abstract class TestReporter implements Reporter {
  ReportActionHandler<TestMessage> get test;
}

/// {@template reporter.featurereporter}
/// An abstract class that allows you to track the status of features.
/// {@endtemplate}
abstract class FeatureReporter implements Reporter {
  ReportActionHandler<FeatureMessage> get feature;
}

/// {@template reporter.scenarioreporter}
/// An abstract class that allows you to track the status of scenarios.
/// {@endtemplate}
abstract class ScenarioReporter implements Reporter {
  ReportActionHandler<ScenarioMessage> get scenario;
}

/// {@template reporter.stepreporter}
/// An abstract class that allows you to track the status of steps.
/// {@endtemplate}
abstract class StepReporter implements Reporter {
  ReportActionHandler<StepMessage> get step;
}

/// {@template reporter.exceptionreporter}
/// An abstract class that allows you to track the status of exceptions.
/// {@endtemplate}
abstract class ExceptionReporter implements Reporter {
  Future<void> onException(Object exception, StackTrace stackTrace);
}

/// {@template reporter.messagereporter}
/// An abstract class that allows you to send messages and intercept them.
/// {@endtemplate}
abstract class MessageReporter implements Reporter {
  Future<void> message(String message, MessageLevel level);
}

/// {@template reporter.messagereporter}
/// An abstract class that allows you to send messages and intercept them.
/// {@endtemplate}
abstract class DisposableReporter implements Reporter {
  Future<void> dispose();
}

/// {@template reporter.fullreporter}
/// This is an abstraction for the implementation
/// of all methods for generating reports
/// {@endtemplate}
abstract class FullReporter
    implements
        TestReporter,
        FeatureReporter,
        StepReporter,
        InfoReporter,
        ScenarioReporter,
        DisposableReporter {}

/// {@template reporter.fullfeature}
/// This is an abstraction for the implementation
/// of all methods for generating reports without [TestReporter]
/// {@endtemplate}
abstract class FullFeatureReporter
    implements
        FeatureReporter,
        StepReporter,
        InfoReporter,
        ScenarioReporter,
        DisposableReporter {}

/// {@template reporter.fullreporter}
/// This interface is necessary for tracking errors and displaying
/// various messages in the reporter
/// {@endtemplate}
abstract class InfoReporter implements MessageReporter, ExceptionReporter {}

/// {@template reporter.allreporters}
/// This mixin allows you to create aggregating reporters.
/// {@endtemplate}
mixin AllReporters implements Reporter {
  /// Get reporters
  UnmodifiableListView<Reporter> get reporters;

  /// A function that allows you to combine a certain function
  /// for all [reporters] and call it as one
  Future<void> invokeReporters<T extends Reporter>(ReportInvoke<T> invoke) {
    final validReportCallbacks =
        reporters.whereType<T>().map(invoke).whereNotNull();

    return Future.wait(validReportCallbacks);
  }
}
