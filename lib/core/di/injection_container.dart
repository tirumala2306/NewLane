import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/firebase/firebase_bootstrap.dart';
import 'package:newlane/core/network/api_client.dart';
import 'package:newlane/core/storage/app_storage.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/auth/bloc/activate_account/activate_account_bloc.dart';
import 'package:newlane/features/auth/bloc/complete_profile/complete_profile_bloc.dart';
import 'package:newlane/features/auth/bloc/complete_profile/complete_profile_event.dart';
import 'package:newlane/features/auth/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:newlane/features/auth/bloc/request_access/request_access_bloc.dart';
import 'package:newlane/features/auth/bloc/request_status/request_status_bloc.dart';
import 'package:newlane/features/auth/bloc/reset_password/reset_password_bloc.dart';
import 'package:newlane/features/auth/bloc/sign_in/sign_in_bloc.dart';
import 'package:newlane/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:newlane/features/auth/domain/entities/agent_profile.dart';
import 'package:newlane/features/auth/domain/usecases/activate_account.dart';
import 'package:newlane/features/auth/domain/usecases/complete_profile.dart';
import 'package:newlane/features/auth/domain/usecases/forgot_password.dart';
import 'package:newlane/features/auth/domain/usecases/get_access_request_status.dart';
import 'package:newlane/features/auth/domain/usecases/get_agent_me.dart';
import 'package:newlane/features/auth/domain/usecases/login.dart';
import 'package:newlane/features/auth/domain/usecases/reset_password.dart';
import 'package:newlane/features/auth/domain/usecases/submit_access_request.dart';
import 'package:newlane/features/auth/repositories/auth_repository.dart';
import 'package:newlane/features/auth/repositories/auth_repository_impl.dart';
import 'package:newlane/features/chats/bloc/chat_list/chat_list_bloc.dart';
import 'package:newlane/features/chats/bloc/conversation/conversation_bloc.dart';
import 'package:newlane/features/chats/data/datasources/chat_api_remote_data_source.dart';
import 'package:newlane/features/chats/data/datasources/chat_remote_data_source.dart';
import 'package:newlane/features/chats/data/datasources/firestore_chat_remote_data_source.dart';
import 'package:newlane/features/chats/data/datasources/mock_chat_remote_data_source.dart';
import 'package:newlane/features/chats/repositories/chat_repository.dart';
import 'package:newlane/features/chats/repositories/chat_repository_impl.dart';
import 'package:newlane/features/create_post/bloc/tag_office/tag_office_bloc.dart';
import 'package:newlane/features/create_post/bloc/tag_office/tag_office_event.dart';
import 'package:newlane/features/create_post/data/datasources/offices_remote_data_source.dart';
import 'package:newlane/features/create_post/domain/usecases/get_office_by_id.dart';
import 'package:newlane/features/create_post/domain/usecases/get_offices.dart';
import 'package:newlane/features/create_post/repositories/offices_repository.dart';
import 'package:newlane/features/create_post/repositories/offices_repository_impl.dart';
import 'package:newlane/features/create_post/domain/entities/office.dart';
import 'package:newlane/features/directory/bloc/agent_detail/agent_detail_bloc.dart';
import 'package:newlane/features/directory/bloc/directory_bloc.dart';
import 'package:newlane/features/directory/bloc/directory_event.dart';
import 'package:newlane/features/directory/bloc/office_directory_bloc.dart';
import 'package:newlane/features/directory/bloc/office_directory_event.dart';
import 'package:newlane/features/directory/data/datasources/directory_remote_data_source.dart';
import 'package:newlane/features/directory/domain/entities/directory_agent.dart';
import 'package:newlane/features/directory/domain/usecases/get_directory_agent_by_id.dart';
import 'package:newlane/features/directory/domain/usecases/get_directory_agents.dart';
import 'package:newlane/features/directory/domain/usecases/get_directory_team.dart';
import 'package:newlane/features/directory/repositories/directory_repository.dart';
import 'package:newlane/features/directory/repositories/directory_repository_impl.dart';
import 'package:newlane/features/directory/bloc/agent_detail/agent_detail_event.dart';
import 'package:newlane/features/marketing_request/bloc/create/marketing_request_bloc.dart';
import 'package:newlane/features/marketing_request/bloc/list/my_requests_bloc.dart';
import 'package:newlane/features/marketing_request/bloc/list/my_requests_event.dart';
import 'package:newlane/features/marketing_request/data/datasources/marketing_request_remote_data_source.dart';
import 'package:newlane/features/marketing_request/domain/entities/marketing_request.dart';
import 'package:newlane/features/marketing_request/domain/usecases/create_marketing_request.dart';
import 'package:newlane/features/marketing_request/domain/usecases/get_marketing_request_by_id.dart';
import 'package:newlane/features/marketing_request/domain/usecases/get_marketing_request_counts.dart';
import 'package:newlane/features/marketing_request/domain/usecases/get_marketing_requests.dart';
import 'package:newlane/features/marketing_request/repositories/marketing_request_repository.dart';
import 'package:newlane/features/marketing_request/repositories/marketing_request_repository_impl.dart';
import 'package:newlane/features/content_generator/data/datasources/content_generator_remote_data_source.dart';
import 'package:newlane/features/content_generator/domain/content_generator_draft.dart';
import 'package:newlane/features/content_generator/domain/usecases/generate_content.dart';
import 'package:newlane/features/content_generator/repositories/content_generator_repository.dart';
import 'package:newlane/features/content_generator/repositories/content_generator_repository_impl.dart';
import 'package:newlane/features/feed/bloc/feed_bloc.dart';
import 'package:newlane/features/feed/bloc/feed_event.dart';
import 'package:newlane/features/feed/data/datasources/feed_remote_data_source.dart';
import 'package:newlane/features/feed/domain/entities/feed_post.dart';
import 'package:newlane/features/feed/domain/usecases/feed_usecases.dart';
import 'package:newlane/features/feed/repositories/feed_repository.dart';
import 'package:newlane/features/feed/repositories/feed_repository_impl.dart';
import 'package:newlane/features/support/data/datasources/support_remote_data_source.dart';
import 'package:newlane/features/support/data/mock/support_mock_data.dart';
import 'package:newlane/features/support/domain/usecases/support_usecases.dart';
import 'package:newlane/features/support/repositories/support_repository.dart';
import 'package:newlane/features/support/repositories/support_repository_impl.dart';
import 'package:newlane/features/profile/bloc/profile_bloc.dart';
import 'package:newlane/features/profile/bloc/profile_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manual DI — one place to build data / domain / presentation.
class InjectionContainer {
  InjectionContainer._();

  static final InjectionContainer instance = InjectionContainer._();

  late final SharedPreferences _sharedPreferences;
  late final AppStorage appStorage;
  late final ApiClient apiClient;
  late final AuthRemoteDataSource _authRemoteDataSource;
  late final AuthRepository _authRepository;
  late final SubmitAccessRequest _submitAccessRequest;
  late final GetAccessRequestStatus _getAccessRequestStatus;
  late final ActivateAccount _activateAccount;
  late final CompleteProfile _completeProfile;
  late final GetAgentMe _getAgentMe;
  late final Login _login;
  late final ForgotPassword _forgotPassword;
  late final ResetPassword _resetPassword;
  late final DirectoryRemoteDataSource _directoryRemoteDataSource;
  late final DirectoryRepository _directoryRepository;
  late final GetDirectoryAgents _getDirectoryAgents;
  late final GetDirectoryTeam _getDirectoryTeam;
  late final GetDirectoryAgentById _getDirectoryAgentById;
  late final MarketingRequestRemoteDataSource _marketingRequestRemoteDataSource;
  late final MarketingRequestRepository _marketingRequestRepository;
  late final CreateMarketingRequest _createMarketingRequest;
  late final GetMarketingRequests _getMarketingRequests;
  late final GetMarketingRequestById _getMarketingRequestById;
  late final GetMarketingRequestCounts _getMarketingRequestCounts;
  late final ContentGeneratorRemoteDataSource _contentGeneratorRemoteDataSource;
  late final ContentGeneratorRepository _contentGeneratorRepository;
  late final GenerateContent _generateContent;
  late final GetContentTemplates _getContentTemplates;
  late final FeedRemoteDataSource _feedRemoteDataSource;
  late final FeedRepository _feedRepository;
  late final GetFeed _getFeed;
  late final ToggleFeedLike _toggleFeedLike;
  late final GetFeedComments _getFeedComments;
  late final AddFeedComment _addFeedComment;
  late final CreateFeedPost _createFeedPost;
  late final SupportRemoteDataSource _supportRemoteDataSource;
  late final SupportRepository _supportRepository;
  late final GetMySupportTickets _getMySupportTickets;
  late final GetSupportTicketById _getSupportTicketById;
  late final CreateSupportTicket _createSupportTicket;
  late final ReplySupportTicket _replySupportTicket;
  late final OfficesRemoteDataSource _officesRemoteDataSource;
  late final OfficesRepository _officesRepository;
  late final GetOffices _getOffices;
  late final GetOfficeById _getOfficeById;
  late final ChatRemoteDataSource _chatRemoteDataSource;
  late final ChatRepository _chatRepository;
  late final ChatApiRemoteDataSource chatApiRemoteDataSource;

  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    appStorage = AppStorage(_sharedPreferences);
    apiClient = ApiClient(storage: appStorage);
    _authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient);
    _authRepository = AuthRepositoryImpl(
      remoteDataSource: _authRemoteDataSource,
      storage: appStorage,
    );
    _submitAccessRequest = SubmitAccessRequest(_authRepository);
    _getAccessRequestStatus = GetAccessRequestStatus(_authRepository);
    _activateAccount = ActivateAccount(_authRepository);
    _completeProfile = CompleteProfile(_authRepository);
    _getAgentMe = GetAgentMe(_authRepository);
    _login = Login(_authRepository);
    _forgotPassword = ForgotPassword(_authRepository);
    _resetPassword = ResetPassword(_authRepository);

    _directoryRemoteDataSource = DirectoryRemoteDataSourceImpl(apiClient);
    _directoryRepository = DirectoryRepositoryImpl(
      remote: _directoryRemoteDataSource,
    );
    _getDirectoryAgents = GetDirectoryAgents(_directoryRepository);
    _getDirectoryTeam = GetDirectoryTeam(_directoryRepository);
    _getDirectoryAgentById = GetDirectoryAgentById(_directoryRepository);

    _marketingRequestRemoteDataSource = MarketingRequestRemoteDataSourceImpl(
      apiClient,
    );
    _marketingRequestRepository = MarketingRequestRepositoryImpl(
      remote: _marketingRequestRemoteDataSource,
    );
    _createMarketingRequest = CreateMarketingRequest(
      _marketingRequestRepository,
    );
    _getMarketingRequests = GetMarketingRequests(_marketingRequestRepository);
    _getMarketingRequestById = GetMarketingRequestById(
      _marketingRequestRepository,
    );
    _getMarketingRequestCounts = GetMarketingRequestCounts(
      _getMarketingRequests,
    );

    _contentGeneratorRemoteDataSource = ContentGeneratorRemoteDataSourceImpl(
      apiClient,
    );
    _contentGeneratorRepository = ContentGeneratorRepositoryImpl(
      remote: _contentGeneratorRemoteDataSource,
    );
    _generateContent = GenerateContent(_contentGeneratorRepository);
    _getContentTemplates = GetContentTemplates(_contentGeneratorRepository);

    _feedRemoteDataSource = FeedRemoteDataSourceImpl(apiClient);
    _feedRepository = FeedRepositoryImpl(remote: _feedRemoteDataSource);
    _getFeed = GetFeed(_feedRepository);
    _toggleFeedLike = ToggleFeedLike(_feedRepository);
    _getFeedComments = GetFeedComments(_feedRepository);
    _addFeedComment = AddFeedComment(_feedRepository);
    _createFeedPost = CreateFeedPost(_feedRepository);

    _supportRemoteDataSource = SupportRemoteDataSourceImpl(apiClient);
    _supportRepository = SupportRepositoryImpl(remote: _supportRemoteDataSource);
    _getMySupportTickets = GetMySupportTickets(_supportRepository);
    _getSupportTicketById = GetSupportTicketById(_supportRepository);
    _createSupportTicket = CreateSupportTicket(_supportRepository);
    _replySupportTicket = ReplySupportTicket(_supportRepository);

    _officesRemoteDataSource = OfficesRemoteDataSourceImpl(apiClient);
    _officesRepository = OfficesRepositoryImpl(
      remote: _officesRemoteDataSource,
    );
    _getOffices = GetOffices(_officesRepository);
    _getOfficeById = GetOfficeById(_officesRepository);

    // Chat: Firestore when Firebase is ready, otherwise local mock streams.
    _chatRemoteDataSource = FirebaseBootstrap.isReady
        ? FirestoreChatRemoteDataSource()
        : MockChatRemoteDataSource();
    _chatRepository = ChatRepositoryImpl(remote: _chatRemoteDataSource);
    chatApiRemoteDataSource = ChatApiRemoteDataSource(apiClient);

    AppLog.line(
      '[DI] ready | chat=${FirebaseBootstrap.isReady ? "firestore" : "mock"}',
    );
  }

  RequestAccessBloc createRequestAccessBloc() {
    return RequestAccessBloc(submitAccessRequest: _submitAccessRequest);
  }

  RequestStatusBloc createRequestStatusBloc() {
    return RequestStatusBloc(getAccessRequestStatus: _getAccessRequestStatus);
  }

  ActivateAccountBloc createActivateAccountBloc() {
    return ActivateAccountBloc(activateAccount: _activateAccount);
  }

  CompleteProfileBloc createCompleteProfileBloc() {
    return CompleteProfileBloc(
      completeProfile: _completeProfile,
      getAgentMe: _getAgentMe,
    )..add(const CompleteProfileStarted());
  }

  SignInBloc createSignInBloc() {
    return SignInBloc(login: _login);
  }

  ForgotPasswordBloc createForgotPasswordBloc() {
    return ForgotPasswordBloc(forgotPassword: _forgotPassword);
  }

  ResetPasswordBloc createResetPasswordBloc() {
    return ResetPasswordBloc(resetPassword: _resetPassword);
  }

  ProfileBloc? _sharedProfileBloc;

  ProfileBloc createProfileBloc() {
    _sharedProfileBloc ??= ProfileBloc(getAgentMe: _getAgentMe)
      // First open only — later taps use cache until refreshProfile().
      ..add(const ProfileLoadRequested());
    return _sharedProfileBloc!;
  }

  /// Call after profile edit / approval so Profile + More show fresh data.
  void refreshProfile() {
    createProfileBloc().add(const ProfileLoadRequested(force: true));
  }

  DirectoryBloc createDirectoryBloc() {
    return DirectoryBloc(
      getDirectoryAgents: _getDirectoryAgents,
      getAgentMe: _getAgentMe,
    )..add(const DirectoryStarted());
  }

  OfficeDirectoryBloc createOfficeDirectoryBloc() {
    return OfficeDirectoryBloc(
      getDirectoryTeam: _getDirectoryTeam,
      getAgentMe: _getAgentMe,
    )..add(const OfficeDirectoryStarted());
  }

  AgentDetailBloc createAgentDetailBloc({
    required int agentId,
    DirectoryAgent? initial,
  }) {
    return AgentDetailBloc(
      getDirectoryAgentById: _getDirectoryAgentById,
      getAgentMe: _getAgentMe,
      chatRepository: _chatRepository,
    )..add(AgentDetailStarted(agentId: agentId, initial: initial));
  }

  MarketingRequestBloc createMarketingRequestBloc() {
    return MarketingRequestBloc(
      createMarketingRequest: _createMarketingRequest,
    );
  }

  MyRequestsBloc createMyRequestsBloc() {
    return MyRequestsBloc(getMarketingRequests: _getMarketingRequests)
      ..add(const MyRequestsStarted());
  }

  Future<Result<MarketingRequest>> fetchMarketingRequestById(int id) {
    return _getMarketingRequestById(GetMarketingRequestByIdParams(id));
  }

  Future<Result<MarketingRequestCounts>> fetchMarketingRequestCounts() {
    return _getMarketingRequestCounts(const NoParams());
  }

  Future<Result<ContentGenerateResult>> generateContent(
    ContentGeneratorDraft draft,
  ) {
    return _generateContent(draft);
  }

  Future<Result<List<ContentTemplate>>> fetchContentTemplates() {
    return _getContentTemplates(const NoParams());
  }

  FeedBloc createFeedBloc() {
    return FeedBloc(
      getFeed: _getFeed,
      toggleFeedLike: _toggleFeedLike,
    )..add(const FeedStarted());
  }

  Future<Result<List<FeedPost>>> fetchFeed({String filter = 'all'}) {
    return _getFeed(GetFeedParams(filter: filter));
  }

  Future<Result<List<FeedComment>>> fetchFeedComments(int postId) {
    return _getFeedComments(GetFeedCommentsParams(postId));
  }

  Future<Result<FeedComment>> addFeedComment(AddFeedCommentParams params) {
    return _addFeedComment(params);
  }

  Future<Result<FeedPost>> createFeedPost(CreateFeedPostParams params) {
    return _createFeedPost(params);
  }

  Future<Result<List<SupportTicket>>> fetchMySupportTickets() {
    return _getMySupportTickets(const GetMySupportTicketsParams());
  }

  Future<Result<SupportTicket>> fetchSupportTicketById(int ticketId) {
    return _getSupportTicketById(GetSupportTicketByIdParams(ticketId: ticketId));
  }

  Future<Result<SupportTicket>> createSupportTicket(
    CreateSupportTicketParams params,
  ) {
    return _createSupportTicket(params);
  }

  Future<Result<SupportTicket>> replySupportTicket(
    ReplySupportTicketParams params,
  ) {
    return _replySupportTicket(params);
  }

  Future<Result<Office>> fetchOfficeById(int officeId) {
    return _getOfficeById(GetOfficeByIdParams(officeId));
  }

  Future<Result<List<Office>>> fetchOffices({String search = ''}) {
    return _getOffices(GetOfficesParams(search: search));
  }

  TagOfficeBloc createTagOfficeBloc({int? selectedOfficeId}) {
    return TagOfficeBloc(getOffices: _getOffices)
      ..add(TagOfficeStarted(selectedOfficeId: selectedOfficeId));
  }

  ChatListBloc createChatListBloc() {
    return ChatListBloc(chatRepository: _chatRepository);
  }

  ConversationBloc createConversationBloc() {
    return ConversationBloc(chatRepository: _chatRepository);
  }

  Future<void> logout() async {
    await _authRepository.logout();
    // Shell BlocProvider owns dispose; just drop the shared reference.
    _sharedProfileBloc = null;
  }

  bool get isLoggedIn => appStorage.hasAuthToken;

  Future<Result<AgentProfile>> fetchAgentMe() {
    return _getAgentMe(const NoParams());
  }
}
