import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_api/wio_api.dart';

import '../l10n/app_localizations.dart';
import '../shell/back_button.dart';
import '../shell/layout.dart';
import '../shell/providers.dart';
import '../update/app_too_old.dart';
import '../update/update_required_screen.dart';
import 'session_provider.dart';
import 'sign_in_controller.dart';

/// "Anmelden": the owner signs in with e-mail and password (D-126).
///
/// UX rule 4 exception: the e-mail and password fields are the only required
/// text fields in the app. Signing in cannot work without them. This screen
/// is not a precedent for any other required field (D-126).
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _showPassword = false;
  Timer? _countdown;

  @override
  void dispose() {
    _countdown?.cancel();
    _email.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    // Too old: signing in would fail too, so Anmelden shows why (D-155).
    if (ref.read(appTooOldProvider) != null) {
      context.go(updateLocation);
      return;
    }
    unawaited(
      ref
          .read(signInControllerProvider.notifier)
          .submit(_email.text, _password.text),
    );
  }

  /// Redraws once a second while a 429 wait runs, so the minutes count down.
  void _syncCountdown(SignInState state) {
    final waiting = state.retryAt != null;
    if (waiting && _countdown == null) {
      _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else if (!waiting) {
      _countdown?.cancel();
      _countdown = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(signInControllerProvider);
    ref.listen(signInControllerProvider, (previous, next) {
      _syncCountdown(next);
      if (next.done) {
        _password.clear();
        context.go('/');
      }
      // The password is not kept beyond the workspace step (D-127).
      if (previous?.choosingWorkspace == true && !next.choosingWorkspace) {
        _password.clear();
      }
    });
    final controller = ref.read(signInControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: WioBackButton(
          onPressed: state.choosingWorkspace ? controller.backToFields : null,
        ),
        leadingWidth: wioBackButtonWidth(context),
        title: Text(l10n.signInTitle),
      ),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: <Widget>[
            if (state.choosingWorkspace)
              ..._workspaceChoice(context, state)
            else
              ..._fields(context),
            _Message(state: state),
          ],
        ),
      ),
      // One main button at the bottom, within thumb reach (UX rule 3). It is
      // never disabled (D-75, D-126); while a request runs a tap does nothing.
      bottomNavigationBar: state.choosingWorkspace
          ? null
          : SafeArea(
              child: Align(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: wioMaxContentWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(64),
                      ),
                      onPressed: _submit,
                      child: Text(
                        state.sending ? l10n.signInSending : l10n.signInButton,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  List<Widget> _fields(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return <Widget>[
      const SizedBox(height: 16),
      AutofillGroup(
        child: Column(
          children: <Widget>[
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const <String>[AutofillHints.email],
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.next,
              style: textTheme.titleMedium,
              decoration: InputDecoration(
                labelText: l10n.signInEmail,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _password,
              focusNode: _passwordFocus,
              obscureText: !_showPassword,
              autofillHints: const <String>[AutofillHints.password],
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.done,
              style: textTheme.titleMedium,
              decoration: InputDecoration(
                labelText: l10n.signInPassword,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: () => setState(() => _showPassword = !_showPassword),
          child: Text(
            _showPassword ? l10n.signInHidePassword : l10n.signInShowPassword,
          ),
        ),
      ),
      _DeviceName(),
    ];
  }

  List<Widget> _workspaceChoice(BuildContext context, SignInState state) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(signInControllerProvider.notifier);
    return <Widget>[
      SectionHeading(l10n.signInChooseWorkspace),
      for (final WorkspaceRef workspace in state.workspaces)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(72),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () =>
                unawaited(controller.chooseWorkspace(workspace.id)),
            child: Text(
              workspace.name ?? l10n.unnamedWorkspace,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
    ];
  }
}

/// "Dieses Gerät: …", the name sent with sign-in (D-125).
class _DeviceName extends ConsumerStatefulWidget {
  @override
  ConsumerState<_DeviceName> createState() => _DeviceNameState();
}

class _DeviceNameState extends ConsumerState<_DeviceName> {
  late final Future<String> _name = ref.read(deviceNameProvider)();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _name,
      builder: (context, snapshot) => snapshot.hasData
          ? HintText(AppLocalizations.of(context).signInDevice(snapshot.data!))
          : const SizedBox.shrink(),
    );
  }
}

/// The German message for the last answer (D-128), read out by screen
/// readers when it changes.
class _Message extends ConsumerWidget {
  const _Message({required this.state});

  final SignInState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = state.message;
    if (message == null) return const SizedBox.shrink();
    final now = ref.read(clockProvider)();
    final retryAt = state.retryAt;
    // The wait is over: the next tap on Anmelden sends again.
    if (message == SignInMessage.tooManyAttempts &&
        retryAt != null &&
        !now.isBefore(retryAt)) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    final text = switch (message) {
      SignInMessage.emptyFields => l10n.signInEmptyFields,
      SignInMessage.invalidCredentials => l10n.signInInvalidCredentials,
      SignInMessage.tooManyAttempts => l10n.signInTooManyAttempts(
        _minutesLeft(retryAt, now),
      ),
      SignInMessage.maintenance => l10n.signInMaintenance,
      SignInMessage.noConnection => l10n.signInNoConnection,
      SignInMessage.invalidRequest => l10n.signInInvalidRequest,
      SignInMessage.serverError => l10n.signInServerError,
      SignInMessage.noServer => l10n.signInNoServer,
      SignInMessage.otherWorkspace => l10n.signInOtherWorkspace,
      SignInMessage.upgradeRequired => l10n.signInUpgradeRequired,
    };
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Semantics(
        liveRegion: true,
        child: Text(
          text,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      ),
    );
  }
}

/// Whole minutes left of a 429 wait, at least 1 (D-128).
int _minutesLeft(DateTime? retryAt, DateTime now) {
  if (retryAt == null) return 1;
  final seconds = retryAt.difference(now).inSeconds;
  return seconds <= 60 ? 1 : (seconds / 60).ceil();
}
