abstract final class AppRoutes {
  // Auth
  static const root = '/';
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const recoverPassword = '/auth/recover-password';
  static const createCredentials = '/auth/create-credentials';

  // Shell
  static const home = '/home';

  static const profile = '/profile';
  static const profileEdit = '/profile/edit';

  static const settings = '/settings';
  static const settingsTerms = '/settings/terms';
  static const settingsChangePassword = '/settings/change-password';

  static const dependents = '/dependents';
  static const dependentsNew = '/dependents/new';
  static const dependentDetail = '/dependents/:id';
  static const dependentEdit = '/dependents/:id/edit';

  static const careTeam = '/care-team';
  static const careTeamAddResponsible = '/care-team/add-responsible';
  static const careTeamAddCaregiver = '/care-team/add-caregiver';
  static const careTeamMember = '/care-team/member/:memberId';

  static const agenda = '/agenda';
  static const agendaNew = '/agenda/new';
  static const agendaEvent = '/agenda/:id';

  static const health = '/health';
  static const healthHabits = '/health/habits';
  static const healthHabitsNew = '/health/habits/new';
  static const healthRecommendations = '/health/recommendations';
  static const healthEvents = '/health/events';
  static const healthEventsNew = '/health/events/new';
  static const healthEventDetail = '/health/events/:id';
  static const healthEventNoteNew = '/health/events/:id/note';
  static const healthTimeline = '/health/timeline';
  static const healthMoodNew = '/health/mood/new';
  static const healthMoodHistory = '/health/mood/history';

  static const emergency = '/emergency';
  static const emergencySent = '/emergency/sent';

  // Nombres de ruta para navegación con go_router
  static const loginName = 'login';
  static const registerName = 'register';
  static const recoverPasswordName = 'recover-password';
  static const createCredentialsName = 'create-credentials';
  static const homeName = 'home';
  static const profileName = 'profile';
  static const profileEditName = 'profile-edit';
  static const settingsName = 'settings';
  static const settingsTermsName = 'settings-terms';
  static const settingsChangePasswordName = 'settings-change-password';
  static const dependentsName = 'dependents';
  static const dependentsNewName = 'dependents-new';
  static const dependentDetailName = 'dependent-detail';
  static const dependentEditName = 'dependent-edit';
  static const careTeamName = 'care-team';
  static const careTeamAddResponsibleName = 'care-team-add-responsible';
  static const careTeamAddCaregiverName = 'care-team-add-caregiver';
  static const careTeamMemberName = 'care-team-member';
  static const agendaName = 'agenda';
  static const agendaNewName = 'agenda-new';
  static const agendaEventName = 'agenda-event';
  static const healthName = 'health';
  static const healthHabitsName = 'health-habits';
  static const healthHabitsNewName = 'health-habits-new';
  static const healthRecommendationsName = 'health-recommendations';
  static const healthEventsName = 'health-events';
  static const healthEventsNewName = 'health-events-new';
  static const healthEventDetailName = 'health-event-detail';
  static const healthEventNoteNewName = 'health-event-note-new';
  static const healthTimelineName = 'health-timeline';
  static const healthHabitDetailName = 'health-habit-detail';
  static const healthHabitEditName = 'health-habit-edit';
  static const healthMoodNewName = 'health-mood-new';
  static const healthMoodHistoryName = 'health-mood-history';
  static const emergencyName = 'emergency';
  static const emergencySentName = 'emergency-sent';
}
