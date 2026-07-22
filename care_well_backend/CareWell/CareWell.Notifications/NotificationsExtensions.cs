using CareWell.Notifications.Email;
using Microsoft.Extensions.DependencyInjection;

namespace CareWell.Notifications
{
    public static class NotificationsExtensions
    {
        public static IServiceCollection AddNotifications(this IServiceCollection services)
        {
            #region Emails

            services.AddScoped<IEmailSender, EmailSender>();

            #endregion

            return services;
        }
    }
}
