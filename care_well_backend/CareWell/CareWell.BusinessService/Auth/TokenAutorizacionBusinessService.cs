using CareWell.BusinessService.Abstractions.Auth;
using CareWell.Queries.Auth;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace CareWell.BusinessService.Auth
{
    public class TokenAutorizacionBusinessService : ITokenAutorizacionBusinessService
    {
        private readonly string _key;
        private readonly string _issuer;
        private readonly string _audience;

        public TokenAutorizacionBusinessService(IConfiguration configuration)
        {
            _key = configuration["Jwt:Key"]!;
            _issuer = configuration["Jwt:Issuer"]!;
            _audience = configuration["Jwt:Audience"]!;
        }

        public string GenerarTokenAcceso(GenerarTokenAccesoQuery query)
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

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
