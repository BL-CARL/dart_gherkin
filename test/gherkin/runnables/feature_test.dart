import 'package:gherkin/src/gherkin/runnables/background.dart';
import 'package:gherkin/src/gherkin/runnables/comment_line.dart';
import 'package:gherkin/src/gherkin/runnables/debug_information.dart';
import 'package:gherkin/src/gherkin/runnables/empty_line.dart';
import 'package:gherkin/src/gherkin/runnables/feature.dart';
import 'package:gherkin/src/gherkin/runnables/scenario.dart';
import 'package:gherkin/src/gherkin/runnables/tags.dart';
import 'package:gherkin/src/gherkin/runnables/text_line.dart';
import 'package:test/test.dart';

Iterable<String> tagsToList(Iterable<TagsRunnable> tags) sync* {
  for (final tag in tags.expand((element) => element.tags)) {
    yield tag;
  }
}

void main() {
  final debugInfo = RunnableDebugInformation.empty();
  group('addChild', () {
    test('can add TextLineRunnable', () {
      final runnable = FeatureRunnable('', debugInfo);
      runnable.addChild(TextLineRunnable(debugInfo)..text = 'text');
      runnable.addChild(TextLineRunnable(debugInfo)..text = 'text line two');
      expect(runnable.description, 'text\ntext line two');
    });
    test('can add TagsRunnable which are given to taggable the taggable child',
        () {
      final runnable = FeatureRunnable('', debugInfo);
      runnable.addChild(TagsRunnable(debugInfo)..tags = ['one', 'two']);
      runnable.addChild(TagsRunnable(debugInfo)..tags = ['three']);
      final scenario = ScenarioRunnable('', null, debugInfo);
      runnable.addChild(scenario);
      expect(tagsToList(scenario.tags), ['one', 'two', 'three']);
    });
    test('can add EmptyLineRunnable', () {
      final runnable = FeatureRunnable('', debugInfo);
      runnable.addChild(EmptyLineRunnable(debugInfo));
    });
    test('can add CommentLineRunnable', () {
      final runnable = FeatureRunnable('', debugInfo);
      runnable.addChild(CommentLineRunnable('', debugInfo));
    });
    test('can add ScenarioRunnable', () {
      final runnable = FeatureRunnable('', debugInfo);
      runnable.addChild(ScenarioRunnable('1', null, debugInfo));
      runnable.addChild(ScenarioRunnable('2', null, debugInfo));
      runnable.addChild(ScenarioRunnable('3', null, debugInfo));
      expect(runnable.scenarios.length, 3);
      expect(runnable.scenarios.elementAt(0).name, '1');
      expect(runnable.scenarios.elementAt(1).name, '2');
      expect(runnable.scenarios.elementAt(2).name, '3');
    });
    test('can add BackgroundRunnable', () {
      final runnable = FeatureRunnable('', debugInfo);
      runnable.addChild(BackgroundRunnable('1', debugInfo));
      expect(runnable.background, isNotNull);
      expect(runnable.background!.name, '1');
    });
  });
}
