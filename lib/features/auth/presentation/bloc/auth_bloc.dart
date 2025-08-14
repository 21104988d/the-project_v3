import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:the_project_v3/core/usecases/usecase.dart';
import 'package:the_project_v3/features/auth/domain/entities/user.dart';
import 'package:the_project_v3/features/auth/domain/usecases/sign_in.dart';
import 'package:the_project_v3/features/auth/domain/usecases/sign_up.dart';
import 'package:the_project_v3/features/auth/domain/usecases/sign_out.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignIn signIn;
  final SignUp signUp;
  final SignOut signOut;

  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.signOut,
  }) : super(AuthInitial()) {
    on<SignInEvent>((event, emit) async {
      emit(AuthLoading());
      final failureOrUser = await signIn(SignInParams(email: event.email, password: event.password));
      failureOrUser.fold(
        (failure) => emit(AuthError('Failed to sign in')),
        (user) => emit(Authenticated(user)),
      );
    });
    on<SignUpEvent>((event, emit) async {
      emit(AuthLoading());
      final failureOrUser = await signUp(SignUpParams(email: event.email, password: event.password));
      failureOrUser.fold(
        (failure) => emit(AuthError('Failed to sign up')),
        (user) => emit(Authenticated(user)),
      );
    });
    on<SignOutEvent>((event, emit) async {
      emit(AuthLoading());
      final failureOrVoid = await signOut(NoParams());
      failureOrVoid.fold(
        (failure) => emit(AuthError('Failed to sign out')),
        (_) => emit(Unauthenticated()),
      );
    });
  }
}
