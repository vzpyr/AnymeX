import 'package:anymex/widgets/anymex_widgets/anymex_text.dart';
import 'package:anymex/widgets/helper/tv_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AnymeXSheet extends StatelessWidget {
  final String? title;
  final String? message;
  final Widget? contentWidget;
  final Widget? customWidget;
  final bool showDragHandle;

  const AnymeXSheet({
    super.key,
    this.title,
    this.message,
    this.contentWidget,
    this.customWidget,
    this.showDragHandle = false,
  });

  static Future<T?> custom<T>(
    Widget widget,
    BuildContext context, {
    bool showDragHandle = false,
  }) =>
      AnymeXSheet(
        customWidget: widget,
        showDragHandle: showDragHandle,
      ).show<T>(context);

  Future<T?> show<T>(
    BuildContext context,
  ) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (context) => AnymeXSheet(
        title: title,
        message: message,
        contentWidget: contentWidget,
        customWidget: customWidget,
        showDragHandle: showDragHandle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          12,
          0,
          12,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
          ),
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showDragHandle)
                Container(
                  width: 36,
                  height: 3.5,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              if (customWidget != null)
                customWidget!
              else ...[
                if (title != null) ...[
                  AnymeXText(text: title!, size: 18, variant: TextVariant.bold),
                  const SizedBox(height: 10),
                ],
                contentWidget ??
                    (message != null
                        ? AnymeXText(
                            text: message!,
                            textAlign: TextAlign.center,
                            size: 14)
                        : const SizedBox.shrink()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Widget loginSheetHelper({
  required BuildContext context,
  required String title,
  required String serviceName,
  bool showTokenOption = false,
}) {
  return _LoginSheetWidget(
    title: title,
    serviceName: serviceName,
    showTokenOption: showTokenOption,
  );
}

class _LoginSheetWidget extends StatefulWidget {
  final String title;
  final String serviceName;
  final bool showTokenOption;

  const _LoginSheetWidget({
    required this.title,
    required this.serviceName,
    required this.showTokenOption,
  });

  @override
  State<_LoginSheetWidget> createState() => _LoginSheetWidgetState();
}

class _LoginSheetWidgetState extends State<_LoginSheetWidget> {
  bool _isTokenMode = false;
  final TextEditingController _tokenController = TextEditingController();

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (_isTokenMode) {
      const url =
          'https://anilist.co/api/v2/oauth/authorize?client_id=35224&response_type=token';
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _isTokenMode = false),
                  icon: const Icon(Icons.arrow_back_rounded),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Login with Token',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 20, thickness: 1),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '1. Tap below to generate your AniList token\n2. Copy the token and paste it here',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: colors.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () =>
                launchUrlString(url, mode: LaunchMode.externalApplication),
            icon: const Icon(Icons.open_in_browser_rounded, size: 18),
            label: const Text('Get AniList Token in Browser'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tokenController,
            decoration: InputDecoration(
              hintText: 'Paste token here',
              hintStyle: TextStyle(
                fontFamily: 'Poppins',
                color: colors.onSurface.withOpacity(0.5),
              ),
              filled: true,
              fillColor: colors.surfaceContainerHighest.withOpacity(0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.content_paste_rounded),
                onPressed: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  if (data?.text != null) {
                    setState(() {
                      _tokenController.text = data!.text!.trim();
                    });
                  }
                },
              ),
            ),
            style: TextStyle(
              fontFamily: 'Poppins',
              color: colors.onSurface,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final token = _tokenController.text.trim();
              if (token.isNotEmpty) {
                Navigator.pop(context, 'token:$token');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Connect',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            children: [
              Icon(
                Icons.login_rounded,
                color: colors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        const Divider(height: 20, thickness: 1),
        const SizedBox(height: 8),
        AnymexOnTap(
          onTap: () => Navigator.pop(context, 'browser_internal'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.outline.withOpacity(0.12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.open_in_new_rounded,
                  color: colors.primary,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Internal Browser',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Login inside the app (Recommended)',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurface.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.onSurface.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        AnymexOnTap(
          onTap: () => Navigator.pop(context, 'browser_external'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.outline.withOpacity(0.12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.explore_outlined,
                  color: colors.primary,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'External Browser',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Login using your default browser',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurface.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.onSurface.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
        if (widget.showTokenOption) ...[
          const SizedBox(height: 12),
          AnymexOnTap(
            onTap: () => setState(() => _isTokenMode = true),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.outline.withOpacity(0.12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.vpn_key_rounded,
                    color: colors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Login with Token',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Manually paste OAuth access token',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.onSurface.withOpacity(0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.onSurface.withOpacity(0.4),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}
