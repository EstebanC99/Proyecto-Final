import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/providers/providers.dart';
import '../../presentation/screens/screens.dart';
import 'app_routes.dart';

/// Notifier que convierte los cambios de [authStateProvider] en notificaciones
/// para el [refreshListenable] de GoRouter, evitando recrear el router.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen(authStateProvider, (previous, next) => notifyListeners());
  }
}

final _routerNotifierProvider = Provider<_RouterNotifier>(
  (ref) => _RouterNotifier(ref),
);

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.root,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      if (isLoggedIn && isAuthRoute) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.root, redirect: (_, _) => AppRoutes.login),

      // ── Auth (fuera del shell) ──────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: AppRoutes.registerName,
        builder: (_, _) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.recoverPassword,
        name: AppRoutes.recoverPasswordName,
        builder: (_, _) => const RecoverPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.createCredentials,
        name: AppRoutes.createCredentialsName,
        builder: (_, _) => const CreateCredentialsScreen(),
      ),
      GoRoute(
        path: AppRoutes.accountCreated,
        name: AppRoutes.accountCreatedName,
        builder: (_, _) => const AccountCreatedScreen(),
      ),

      // ── Shell (sesión autenticada) ─────────────────────────────────────────
      ShellRoute(
        builder: (_, _, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: AppRoutes.homeName,
            builder: (_, _) => const HomeScreen(),
          ),

          // Profile
          GoRoute(
            path: AppRoutes.profile,
            name: AppRoutes.profileName,
            builder: (_, _) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                name: AppRoutes.profileEditName,
                builder: (_, _) => const ProfileEditScreen(),
              ),
            ],
          ),

          // Settings
          GoRoute(
            path: AppRoutes.settings,
            name: AppRoutes.settingsName,
            builder: (_, _) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'terms',
                name: AppRoutes.settingsTermsName,
                builder: (_, _) => const TermsScreen(),
              ),
              GoRoute(
                path: 'change-password',
                name: AppRoutes.settingsChangePasswordName,
                builder: (_, _) => const ChangePasswordScreen(),
              ),
            ],
          ),

          // Dependents
          GoRoute(
            path: AppRoutes.dependents,
            name: AppRoutes.dependentsName,
            builder: (_, _) => const DependentsScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: AppRoutes.dependentsNewName,
                builder: (_, _) => const DependentFormScreen(),
              ),
              GoRoute(
                path: ':id',
                name: AppRoutes.dependentDetailName,
                builder: (_, state) => DependentDetailScreen(
                  dependentId: int.parse(state.pathParameters['id']!),
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: AppRoutes.dependentEditName,
                    builder: (_, state) => DependentFormScreen(
                      dependentId: int.tryParse(
                        state.pathParameters['id'] ?? '',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Care team
          GoRoute(
            path: AppRoutes.careTeam,
            name: AppRoutes.careTeamName,
            builder: (_, _) => const CareTeamScreen(),
            routes: [
              GoRoute(
                path: 'add-responsible',
                name: AppRoutes.careTeamAddResponsibleName,
                builder: (_, _) => const CareTeamFormScreen(
                  formType: CareTeamFormType.responsible,
                ),
              ),
              GoRoute(
                path: 'add-caregiver',
                name: AppRoutes.careTeamAddCaregiverName,
                builder: (_, _) => const CareTeamFormScreen(
                  formType: CareTeamFormType.caregiver,
                ),
              ),
              GoRoute(
                path: 'member/:memberId',
                name: AppRoutes.careTeamMemberName,
                builder: (_, state) => CareTeamMemberScreen(
                  memberId: int.parse(state.pathParameters['memberId']!),
                ),
              ),
            ],
          ),

          // Agenda
          GoRoute(
            path: AppRoutes.agenda,
            name: AppRoutes.agendaName,
            builder: (_, _) => const AgendaScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: AppRoutes.agendaNewName,
                builder: (_, _) => const AgendaEventScreen(),
              ),
              GoRoute(
                path: ':id',
                name: AppRoutes.agendaEventName,
                builder: (_, state) => AgendaEventScreen(
                  eventId: int.tryParse(state.pathParameters['id'] ?? ''),
                ),
              ),
            ],
          ),

          // Health
          GoRoute(
            path: AppRoutes.health,
            name: AppRoutes.healthName,
            builder: (_, _) => const HealthScreen(),
            routes: [
              GoRoute(
                path: 'habits',
                name: AppRoutes.healthHabitsName,
                builder: (_, _) => const HabitsScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    name: AppRoutes.healthHabitsNewName,
                    builder: (_, _) => const HabitFormScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    name: AppRoutes.healthHabitDetailName,
                    builder: (_, s) => HabitDetailScreen(
                      habitId: int.parse(s.pathParameters['id']!),
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        name: AppRoutes.healthHabitEditName,
                        builder: (_, s) => HabitFormScreen(
                          habitId: int.tryParse(s.pathParameters['id'] ?? ''),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                path: 'recommendations',
                name: AppRoutes.healthRecommendationsName,
                builder: (_, _) => const RecommendationsScreen(),
              ),
              GoRoute(
                path: 'events',
                name: AppRoutes.healthEventsName,
                builder: (_, _) => const HealthEventsScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    name: AppRoutes.healthEventsNewName,
                    builder: (_, _) => const HealthEventFormScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    name: AppRoutes.healthEventDetailName,
                    builder: (_, state) => HealthEventDetailScreen(
                      eventId: int.parse(state.pathParameters['id']!),
                    ),
                    routes: [
                      GoRoute(
                        path: 'note',
                        name: AppRoutes.healthEventNoteNewName,
                        builder: (_, state) => HealthEventNoteFormScreen(
                          eventoId: int.parse(state.pathParameters['id']!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                path: 'timeline',
                name: AppRoutes.healthTimelineName,
                builder: (_, _) => const TimelineScreen(),
              ),
              GoRoute(
                path: 'mood/new',
                name: AppRoutes.healthMoodNewName,
                builder: (_, _) => const MoodFormScreen(),
              ),
              GoRoute(
                path: 'mood/history',
                name: AppRoutes.healthMoodHistoryName,
                builder: (_, _) => const MoodHistoryScreen(),
              ),
            ],
          ),

          // Emergency
          GoRoute(
            path: AppRoutes.emergency,
            name: AppRoutes.emergencyName,
            builder: (_, _) => const EmergencyScreen(),
          ),
          GoRoute(
            path: AppRoutes.emergencySent,
            name: AppRoutes.emergencySentName,
            builder: (_, _) => const EmergencySentScreen(),
          ),
        ],
      ),
    ],
  );
});
