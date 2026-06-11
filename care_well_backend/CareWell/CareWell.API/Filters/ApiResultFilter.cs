using CareWell.Global.Exceptions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace CareWell.API.Filters
{
    public class ApiResultFilter : IActionFilter, IExceptionFilter
    {
        private readonly ILogger<ApiResultFilter> _logger;

        public ApiResultFilter(ILogger<ApiResultFilter> logger)
        {
            _logger = logger;
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
                RecursoNoEncontradoException ex => (StatusCodes.Status404NotFound, ex.Message),
                UnauthorizedAccessException ex => (StatusCodes.Status401Unauthorized, ex.Message),
                _ => (StatusCodes.Status500InternalServerError, "Ocurrió un error inesperado.")
            };

            if (statusCode == StatusCodes.Status500InternalServerError)
                _logger.LogError(context.Exception, "Error inesperado: {Mensaje}", context.Exception.Message);

            context.Result = new ObjectResult(new { mensaje }) { StatusCode = statusCode };
            context.ExceptionHandled = true;
        }
    }
}
