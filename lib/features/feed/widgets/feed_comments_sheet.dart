import 'package:flutter/material.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/feed/domain/entities/feed_post.dart';
import 'package:newlane/features/feed/domain/usecases/feed_usecases.dart';
import 'package:newlane/features/profile/widgets/profile_avatar.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';

Future<bool?> showFeedCommentsSheet({
  required BuildContext context,
  required FeedPost post,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF121212),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(ScreenUtils.r(16)),
      ),
    ),
    builder: (BuildContext context) {
      return _FeedCommentsSheet(post: post);
    },
  );
}

class _FeedCommentsSheet extends StatefulWidget {
  const _FeedCommentsSheet({required this.post});

  final FeedPost post;

  @override
  State<_FeedCommentsSheet> createState() => _FeedCommentsSheetState();
}

class _FeedCommentsSheetState extends State<_FeedCommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  List<FeedComment> _comments = const <FeedComment>[];
  bool _loading = true;
  bool _sending = false;
  bool _added = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final Result<List<FeedComment>> result =
        await InjectionContainer.instance.fetchFeedComments(widget.post.id);
    if (!mounted) return;
    result.when(
      ok: (List<FeedComment> comments) {
        setState(() {
          _comments = comments;
          _loading = false;
        });
      },
      err: (failure) {
        setState(() => _loading = false);
        AppSnackBar.showError(
          context,
          title: 'Comments',
          message: failure.message,
        );
      },
    );
  }

  Future<void> _send() async {
    final String text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    final Result<FeedComment> result =
        await InjectionContainer.instance.addFeedComment(
      AddFeedCommentParams(postId: widget.post.id, text: text),
    );
    if (!mounted) return;
    result.when(
      ok: (FeedComment comment) {
        _controller.clear();
        setState(() {
          _sending = false;
          _added = true;
          _comments = <FeedComment>[comment, ..._comments];
        });
      },
      err: (failure) {
        setState(() => _sending = false);
        AppSnackBar.showError(
          context,
          title: 'Comment',
          message: failure.message,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.72,
        child: Column(
          children: <Widget>[
            SizedBox(height: ScreenUtils.h(10)),
            Container(
              width: ScreenUtils.w(40),
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(ScreenUtils.w(16)),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Comments',
                      style: AppTypography.semiBold(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context, _added),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryButtonBg,
                      ),
                    )
                  : _comments.isEmpty
                      ? Center(
                          child: Text(
                            'No comments yet',
                            style: AppTypography.regular(
                              color: AppColors.mutedGrey,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtils.w(16),
                          ),
                          itemCount: _comments.length,
                          separatorBuilder: (_, _) =>
                              SizedBox(height: ScreenUtils.h(12)),
                          itemBuilder: (BuildContext context, int index) {
                            final FeedComment comment = _comments[index];
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                ProfileAvatar(
                                  url: comment.authorAvatar.isEmpty
                                      ? null
                                      : comment.authorAvatar,
                                  size: ScreenUtils.w(32),
                                ),
                                SizedBox(width: ScreenUtils.w(10)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        comment.authorName,
                                        style: AppTypography.semiBold(
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(height: ScreenUtils.h(4)),
                                      Text(
                                        comment.text,
                                        style: AppTypography.regular(
                                          fontSize: 13,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  ScreenUtils.w(12),
                  ScreenUtils.h(8),
                  ScreenUtils.w(12),
                  ScreenUtils.h(10),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: AppTypography.regular(fontSize: 14),
                        cursorColor: AppColors.primaryButtonBg,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: AppTypography.regular(
                            fontSize: 14,
                            color: AppColors.mutedGrey,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF1C1C1C),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              ScreenUtils.r(22),
                            ),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: ScreenUtils.w(14),
                            vertical: ScreenUtils.h(10),
                          ),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    SizedBox(width: ScreenUtils.w(8)),
                    IconButton(
                      onPressed: _sending ? null : _send,
                      icon: _sending
                          ? SizedBox(
                              width: ScreenUtils.w(18),
                              height: ScreenUtils.w(18),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryButtonBg,
                              ),
                            )
                          : Icon(
                              Icons.send_rounded,
                              color: AppColors.primaryButtonBg,
                              size: ScreenUtils.sp(22),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
