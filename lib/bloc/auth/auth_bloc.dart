import 'package:bloc/bloc.dart';
import '../../data/services/auth_service.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  AuthBloc({required this.authService}) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final resp = await authService.login(event.email, event.password);
      emit(AuthAuthenticated(resp['data']));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
