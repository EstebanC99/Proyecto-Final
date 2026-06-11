using CareWell.BusinessService.Abstractions.Auth;
using CareWell.DataViews.Auth;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.Factories;
using CareWell.Queries.Auth;
using CareWell.Repository;
using CareWell.Repository.Auth;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace CareWell.BusinessService.Auth
{
    public class TokenAutorizacionBusinessService : BusinessService, ITokenAutorizacionBusinessService
    {
        private readonly string _key;
        private readonly string _issuer;
        private readonly string _audience;

        private IBaseFactory Factory { get; set; }
        private IRefreshTokenRepository RefreshTokenRepository { get; set; }
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }

        public TokenAutorizacionBusinessService(IUnitOfWork unitOfWork,   
                                                IConfiguration configuration,
                                                IBaseFactory baseFactory,
                                                IRefreshTokenRepository refreshTokenRepository,
                                                IEntityLoaderDomainService entityLoaderDomainService)
            : base(unitOfWork)
        {
            _key = configuration["Jwt:Key"]!;
            _issuer = configuration["Jwt:Issuer"]!;
            _audience = configuration["Jwt:Audience"]!;

            this.Factory = baseFactory;
            this.RefreshTokenRepository = refreshTokenRepository;
            this.EntityLoaderDomainService = entityLoaderDomainService;
        }

        public AccessTokenDataView GenerarTokenAcceso(GenerarTokenAccesoQuery query)
        {
            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, query.UsuarioID.ToString()),
                new Claim(JwtRegisteredClaimNames.Email, query.Email),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_key));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: _issuer,
                audience: _audience,
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(30),
                signingCredentials: creds);

            var accessToken =  new JwtSecurityTokenHandler().WriteToken(token);

            var refreshToken = this.Factory.Crear<RefreshToken>();
            
            refreshToken.Crear(Guid.NewGuid().ToString("N"),
                               this.EntityLoaderDomainService.GetByID<Usuario>(query.UsuarioID),
                               DateTime.UtcNow.AddDays(30));

            this.RefreshTokenRepository.Add(refreshToken);

            this.UnitOfWork.SaveChanges();

            return new AccessTokenDataView
            {
                AccessToken = accessToken,
                RefreshToken = refreshToken.Token
            };
        }
    }
}
