import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/constants/asset_constants.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/create_post/domain/entities/office.dart';
import 'package:newlane/features/directory/domain/entities/directory_agent.dart';
import 'package:newlane/features/directory/widgets/office_team_member_card.dart';
import 'package:newlane/features/more/widgets/more_card.dart';
import 'package:newlane/features/profile/bloc/profile_bloc.dart';
import 'package:newlane/features/profile/bloc/profile_event.dart';
import 'package:newlane/features/profile/bloc/profile_state.dart';
import 'package:newlane/shared/widgets/app_svg.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';

class OfficeScreen extends StatefulWidget {
  const OfficeScreen({super.key});

  @override
  State<OfficeScreen> createState() => _OfficeScreenState();
}

class _OfficeScreenState extends State<OfficeScreen> {
  Office? _office;
  bool _loadingOffice = false;
  bool _loadingMembers = false;
  String? _error;
  String? _membersError;
  int? _loadedForOfficeId;
  List<DirectoryAgent> _members = <DirectoryAgent>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ProfileState state = context.read<ProfileBloc>().state;
      if (state is! ProfileLoaded) {
        context.read<ProfileBloc>().add(const ProfileLoadRequested());
      } else {
        _loadAssignedOffice(state);
      }
    });
  }

  Future<void> _loadAssignedOffice(ProfileLoaded state) async {
    final int officeId = state.profile.officeId;
    final String officeName = state.profile.officeName.trim();
    final String officeQuery = state.profile.directoryOfficeQuery;

    if (officeId <= 0 && officeName.isEmpty) {
      setState(() {
        _office = null;
        _members = <DirectoryAgent>[];
        _error = 'No office is assigned to your account yet.';
        _loadingOffice = false;
        _loadingMembers = false;
      });
      return;
    }

    if (_loadedForOfficeId == officeId && _office != null) {
      if (_members.isEmpty && !_loadingMembers) {
        await _loadMembers(officeQuery);
      }
      return;
    }

    setState(() {
      _loadingOffice = true;
      _error = null;
    });

    if (officeId > 0) {
      final Result<Office> byId =
          await InjectionContainer.instance.fetchOfficeById(officeId);
      if (!mounted) return;
      final Office? office = byId.when(
        ok: (Office value) => value,
        err: (_) => null,
      );
      if (office != null) {
        setState(() {
          _office = office;
          _loadedForOfficeId = officeId;
          _loadingOffice = false;
        });
        await _loadMembers(officeQuery);
        return;
      }
      final String? apiError = byId.when(
        ok: (_) => null,
        err: (failure) => failure.message,
      );
      await _loadByName(
        officeName,
        officeId: officeId,
        error: apiError,
        officeQuery: officeQuery,
      );
      return;
    }

    await _loadByName(officeName, officeQuery: officeQuery);
  }

  Future<void> _loadByName(
    String officeName, {
    int officeId = 0,
    String? error,
    String officeQuery = '',
  }) async {
    final Result<List<Office>> listResult =
        await InjectionContainer.instance.fetchOffices(search: officeName);
    if (!mounted) return;

    listResult.when(
      ok: (List<Office> offices) {
        Office? match;
        final String needle = officeName.toLowerCase();
        for (final Office office in offices) {
          if (officeId > 0 && office.id == officeId) {
            match = office;
            break;
          }
          if (needle.isNotEmpty && office.name.toLowerCase() == needle) {
            match = office;
            break;
          }
        }
        match ??= offices.isEmpty ? null : offices.first;

        setState(() {
          _office = match ??
              Office(
                id: officeId,
                name: officeName.isEmpty ? 'Your Office' : officeName,
              );
          _loadedForOfficeId = officeId > 0 ? officeId : match?.id;
          _loadingOffice = false;
          _error = match == null ? error : null;
        });
      },
      err: (failure) {
        setState(() {
          _office = Office(
            id: officeId,
            name: officeName.isEmpty ? 'Your Office' : officeName,
          );
          _loadingOffice = false;
          _error = error ?? failure.message;
        });
      },
    );

    final String query = officeQuery.trim().isNotEmpty
        ? officeQuery.trim()
        : (officeId > 0 ? '$officeId' : officeName);
    await _loadMembers(query);
  }

  Future<void> _loadMembers(String officeQuery) async {
    final String query = officeQuery.trim();
    if (query.isEmpty) {
      setState(() {
        _members = <DirectoryAgent>[];
        _loadingMembers = false;
        _membersError = null;
      });
      return;
    }

    setState(() {
      _loadingMembers = true;
      _membersError = null;
    });

    final Result<DirectoryAgentsPage> result =
        await InjectionContainer.instance.fetchDirectoryAgents(
      office: query,
      sort: 'name_asc',
    );
    if (!mounted) return;

    result.when(
      ok: (DirectoryAgentsPage page) {
        final List<DirectoryAgent> agents = List<DirectoryAgent>.from(
          page.agents,
        )..sort(
            (DirectoryAgent a, DirectoryAgent b) =>
                a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
          );
        setState(() {
          _members = agents;
          _loadingMembers = false;
          _membersError = null;
        });
      },
      err: (failure) {
        setState(() {
          _members = <DirectoryAgent>[];
          _loadingMembers = false;
          _membersError = failure.message;
        });
      },
    );
  }

  void _openMember(DirectoryAgent member) {
    context.push(
      '${AppRoutes.directoryAgent}/${member.id}',
      extra: member,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (BuildContext context, ProfileState state) {
        if (state is ProfileLoaded) {
          _loadAssignedOffice(state);
        }
      },
      builder: (BuildContext context, ProfileState state) {
        final String fallbackName = switch (state) {
          ProfileLoaded(:final profile)
              when profile.officeName.trim().isNotEmpty =>
            profile.officeName.trim(),
          _ => 'Your Office',
        };
        final String name = _office?.name.trim().isNotEmpty == true
            ? _office!.name.trim()
            : fallbackName;
        final String address = _office?.displayAddress ?? '';
        final String phone = _office?.phone.trim() ?? '';
        final String email = _office?.email.trim() ?? '';
        final bool profileLoading = state is ProfileLoading ||
            state is ProfileInitial ||
            _loadingOffice;

        return Scaffold(
          backgroundColor: AppColors.black,
          appBar: NewLaneAppBar(
            prefixIcon: Icons.arrow_back_ios_new,
            onPrefixPressed: () => context.pop(),
            title: 'OFFICE',
            titleFontSize: 16,
            height: ScreenUtils.h(56),
          ),
          body: ListView(
            padding: EdgeInsets.fromLTRB(
              ScreenUtils.w(16),
              ScreenUtils.h(12),
              ScreenUtils.w(16),
              ScreenUtils.h(32),
            ),
            children: <Widget>[
              MoreCard(
                child: SizedBox(
                  height: ScreenUtils.h(88),
                  child: Center(
                    child: AppSvg(
                      AssetConstants.newLaneAppLogo,
                      height: ScreenUtils.h(36),
                    ),
                  ),
                ),
              ),
              SizedBox(height: ScreenUtils.h(12)),
              MoreCard(
                child: profileLoading
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: ScreenUtils.h(28),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryButtonBg,
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            name,
                            style: AppTypography.semiBold(fontSize: 16),
                          ),
                          SizedBox(height: ScreenUtils.h(14)),
                          if (address.isNotEmpty) ...<Widget>[
                            _info(Icons.place_outlined, address),
                            SizedBox(height: ScreenUtils.h(12)),
                          ],
                          if (phone.isNotEmpty) ...<Widget>[
                            _info(Icons.phone_outlined, phone),
                            SizedBox(height: ScreenUtils.h(12)),
                          ],
                          if (email.isNotEmpty) ...<Widget>[
                            _info(Icons.email_outlined, email),
                            SizedBox(height: ScreenUtils.h(16)),
                          ],
                          if (address.isEmpty &&
                              phone.isEmpty &&
                              email.isEmpty) ...<Widget>[
                            Text(
                              _error ??
                                  'Office contact details will appear here once available.',
                              style: AppTypography.regular(
                                fontSize: 12,
                                color: AppColors.mutedGrey,
                              ),
                            ),
                            SizedBox(height: ScreenUtils.h(16)),
                          ],
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(ScreenUtils.w(12)),
                            decoration: BoxDecoration(
                              color: const Color(0xFF101010),
                              borderRadius: BorderRadius.circular(
                                ScreenUtils.r(8),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Icon(
                                  Icons.info_outline,
                                  size: ScreenUtils.sp(16),
                                  color: AppColors.primaryButtonBg,
                                ),
                                SizedBox(width: ScreenUtils.w(8)),
                                Expanded(
                                  child: Text(
                                    'This is your assigned office. If you believe this is incorrect, please contact your administrator.',
                                    style: AppTypography.regular(
                                      fontSize: 11,
                                      height: 1.4,
                                      color: AppColors.white.withValues(
                                        alpha: 0.65,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
              SizedBox(height: ScreenUtils.h(16)),
              Text(
                'People in this office',
                style: AppTypography.semiBold(fontSize: 14),
              ),
              SizedBox(height: ScreenUtils.h(10)),
              if (_loadingMembers)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: ScreenUtils.h(24)),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryButtonBg,
                    ),
                  ),
                )
              else if (_membersError != null && _members.isEmpty)
                MoreCard(
                  child: Text(
                    _membersError!,
                    style: AppTypography.regular(
                      fontSize: 12,
                      color: AppColors.mutedGrey,
                    ),
                  ),
                )
              else if (_members.isEmpty)
                MoreCard(
                  child: Text(
                    'No teammates found for this office yet.',
                    style: AppTypography.regular(
                      fontSize: 12,
                      color: AppColors.mutedGrey,
                    ),
                  ),
                )
              else
                ..._members.map((DirectoryAgent member) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: ScreenUtils.h(10)),
                    child: OfficeTeamMemberCard(
                      member: member,
                      onTap: () => _openMember(member),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _info(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: ScreenUtils.sp(16), color: AppColors.primaryButtonBg),
        SizedBox(width: ScreenUtils.w(8)),
        Expanded(
          child: Text(
            text,
            style: AppTypography.regular(fontSize: 13, height: 1.35),
          ),
        ),
      ],
    );
  }
}
