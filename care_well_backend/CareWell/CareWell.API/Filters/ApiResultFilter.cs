using CareWell.BusinessService.Abstractions.Auditoria;
using CareWell.Commands.Auditoria;
using CareWell.Global.Exceptions;
using CareWell.Security;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace CareWell.API.Filters
{
    public class ApiResultFilter : IActionFilter, IExceptionFilter
    {
        private readonly IRegistrarLogExcepcionBusinessService _registrarLogExcepcionBusinessService;
        private readonly IUserContext _userContext;

        public ApiResultFilter(IRegistrarLogExcepcionBusinessService registrarLogExcepcionBusinessService,
                               IUserContext userContext)
        {
            _registrarLogExcepcionBusinessService = registrarLogExcepcionBusinessService;
            _userContext = userContext;
        }

        public void OnActionExecuting(ActionExecutingContext context) { }

        public void OnActionExecuted(ActionExecutedContext context)
        {
            if (context.Exception is not null)
                return;

            context.Result = context.Result switch
            {
                EmptyResult => new OkResult(),
                ObjectResult { StatusCode: null } obj => new OkObjectResult(obj.Value),
                _ => context.Result
            };
        }

        public void OnException(ExceptionContext context)
        {
            var (statusCode, mensaje) = context.Exception switch
            {
                ValidacionDominioException ex => (StatusCodes.Status400BadRequest, ex.Message),
                UnauthorizedAccessException ex => (StatusCodes.Status401Unauthorized, ex.Message),
                EmailNoVerificadoException ex => (StatusCodes.Status403Forbidden, ex.Message),
                RecursoNoEncontradoException ex => (StatusCodes.Status404NotFound, ex.Message),
                CuentaExistenteException ex => (StatusCodes.Status409Conflict, ex.Message),
                ServicioNoDisponibleException ex => (StatusCodes.Status503ServiceUnavailable, ex.Message),

                OperationCanceledException => (499, "La solicitud fue cancelada."),
                _ => (StatusCodes.Status500InternalServerError, "Ocurrió un error inesperado.")
            };

            _registrarLogExcepcionBusinessService.Registrar(new RegistrarLogExcepcionCommand
            {
                Tipo = context.Exception.GetType().FullName ?? context.Exception.GetType().Name,
                Controlada = statusCode != StatusCodes.Status500InternalServerError,
                Mensaje = context.Exception.Message,
                StackTrace = context.Exception.ToString(),
                Ruta = context.HttpContext.Request.Path,
                Verbo = context.HttpContext.Request.Method,
                TraceIdentifier = context.HttpContext.TraceIdentifier,
                UsuarioID = _userContext.HayUsuario ? _userContext.UsuarioID : (int?)null
            });

            context.Result = new ObjectResult(new { mensaje }) { StatusCode = statusCode };
            context.ExceptionHandled = true;
        }
    }
}
