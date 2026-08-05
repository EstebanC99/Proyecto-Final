using CareWell.Notifications.Email;
using CareWell.Notifications.Push;
using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;

namespace CareWell.Notifications
{
    public static class NotificationsExtensions
    {
        public static IServiceCollection AddNotifications(this IServiceCollection services)
        {
            #region Emails

            services.AddScoped<IEmailSender, EmailSender>();

            #endregion

            #region Push

            services.AddSingleton(serviceProvider =>
            {
                var opciones = serviceProvider.GetRequiredService<IOptions<PushOptions>>().Value;

                var credencial = !string.IsNullOrWhiteSpace(opciones.CredencialesJson)
                    ? CredentialFactory.FromJson<ServiceAccountCredential>(opciones.CredencialesJson)
                    : CredentialFactory.FromFile<ServiceAccountCredential>(opciones.RutaCredenciales);

                var app = FirebaseApp.DefaultInstance ?? FirebaseApp.Create(new AppOptions
                {
                    Credential = GoogleCredential.FromServiceAccountCredential(credencial),
                });

                return FirebaseMessaging.GetMessaging(app);
            });

            services.AddScoped<IPushSender>(serviceProvider =>
            {
                var opciones = serviceProvider.GetRequiredService<IOptions<PushOptions>>().Value;

                if (!opciones.EstaConfigurado)
                    return ActivatorUtilities.CreateInstance<PushSenderNulo>(serviceProvider);

                return ActivatorUtilities.CreateInstance<FirebasePushSender>(serviceProvider);
            });

            #endregion

            return services;
        }
    }
}
