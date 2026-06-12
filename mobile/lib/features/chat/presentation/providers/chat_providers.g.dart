// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(chatRepository)
final chatRepositoryProvider = ChatRepositoryProvider._();

final class ChatRepositoryProvider
    extends $FunctionalProvider<ChatRepository, ChatRepository, ChatRepository>
    with $Provider<ChatRepository> {
  ChatRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'chatRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$chatRepositoryHash();

  @$internal
  @override
  $ProviderElement<ChatRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChatRepository create(Ref ref) {
    return chatRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatRepository>(value),
    );
  }
}

String _$chatRepositoryHash() => r'15214aae0b27e9fed4f29814e4236653b942416b';

@ProviderFor(ConversationListNotifier)
final conversationListProvider = ConversationListNotifierProvider._();

final class ConversationListNotifierProvider extends $AsyncNotifierProvider<
    ConversationListNotifier, List<Conversation>> {
  ConversationListNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'conversationListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$conversationListNotifierHash();

  @$internal
  @override
  ConversationListNotifier create() => ConversationListNotifier();
}

String _$conversationListNotifierHash() =>
    r'964943ff4c44b73be82fd04608399458289655a4';

abstract class _$ConversationListNotifier
    extends $AsyncNotifier<List<Conversation>> {
  FutureOr<List<Conversation>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<Conversation>>, List<Conversation>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Conversation>>, List<Conversation>>,
        AsyncValue<List<Conversation>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(MessageNotifier)
final messageProvider = MessageNotifierFamily._();

final class MessageNotifierProvider
    extends $AsyncNotifierProvider<MessageNotifier, List<ChatMessage>> {
  MessageNotifierProvider._(
      {required MessageNotifierFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'messageProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$messageNotifierHash();

  @override
  String toString() {
    return r'messageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MessageNotifier create() => MessageNotifier();

  @override
  bool operator ==(Object other) {
    return other is MessageNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messageNotifierHash() => r'8e8ae9bf092732cc8d360c6ad59e084fdc4d2fb3';

final class MessageNotifierFamily extends $Family
    with
        $ClassFamilyOverride<MessageNotifier, AsyncValue<List<ChatMessage>>,
            List<ChatMessage>, FutureOr<List<ChatMessage>>, String> {
  MessageNotifierFamily._()
      : super(
          retry: null,
          name: r'messageProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  MessageNotifierProvider call(
    String conversationId,
  ) =>
      MessageNotifierProvider._(argument: conversationId, from: this);

  @override
  String toString() => r'messageProvider';
}

abstract class _$MessageNotifier extends $AsyncNotifier<List<ChatMessage>> {
  late final _$args = ref.$arg as String;
  String get conversationId => _$args;

  FutureOr<List<ChatMessage>> build(
    String conversationId,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<ChatMessage>>, List<ChatMessage>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<ChatMessage>>, List<ChatMessage>>,
        AsyncValue<List<ChatMessage>>,
        Object?,
        Object?>;
    return element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}

@ProviderFor(TypingIndicator)
final typingIndicatorProvider = TypingIndicatorFamily._();

final class TypingIndicatorProvider
    extends $NotifierProvider<TypingIndicator, Map<int, bool>> {
  TypingIndicatorProvider._(
      {required TypingIndicatorFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'typingIndicatorProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$typingIndicatorHash();

  @override
  String toString() {
    return r'typingIndicatorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TypingIndicator create() => TypingIndicator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<int, bool> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<int, bool>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TypingIndicatorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$typingIndicatorHash() => r'6d5e8c18f13c47e6a746d584d7a0b43b6178aef1';

final class TypingIndicatorFamily extends $Family
    with
        $ClassFamilyOverride<TypingIndicator, Map<int, bool>, Map<int, bool>,
            Map<int, bool>, String> {
  TypingIndicatorFamily._()
      : super(
          retry: null,
          name: r'typingIndicatorProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  TypingIndicatorProvider call(
    String conversationId,
  ) =>
      TypingIndicatorProvider._(argument: conversationId, from: this);

  @override
  String toString() => r'typingIndicatorProvider';
}

abstract class _$TypingIndicator extends $Notifier<Map<int, bool>> {
  late final _$args = ref.$arg as String;
  String get conversationId => _$args;

  Map<int, bool> build(
    String conversationId,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Map<int, bool>, Map<int, bool>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Map<int, bool>, Map<int, bool>>,
        Map<int, bool>,
        Object?,
        Object?>;
    return element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}

@ProviderFor(UserSearch)
final userSearchProvider = UserSearchProvider._();

final class UserSearchProvider
    extends $AsyncNotifierProvider<UserSearch, List<ChatUser>> {
  UserSearchProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userSearchProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userSearchHash();

  @$internal
  @override
  UserSearch create() => UserSearch();
}

String _$userSearchHash() => r'7f26d83e0549687b36a4291e0e9b81428708df0f';

abstract class _$UserSearch extends $AsyncNotifier<List<ChatUser>> {
  FutureOr<List<ChatUser>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<ChatUser>>, List<ChatUser>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<ChatUser>>, List<ChatUser>>,
        AsyncValue<List<ChatUser>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
