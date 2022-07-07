using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using DevExpress.ExpressApp;
using DevExpress.ExpressApp.Blazor.Utils;
using DevExpress.ExpressApp.Security;
using DevExpress.ExpressApp.WebApi.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using Swashbuckle.AspNetCore.Annotations;
using Template.Module.BusinessObjects;

namespace Template.WebApi.JWT {
    [ApiController]
    [Route("api/[controller]")]
    // This is a JWT authentication service sample.
    public class AuthenticationController : ControllerBase {
        private readonly ISecurityAuthenticationService securityAuthenticationService;
        private readonly IObjectConverter objectConverter;
        private readonly IConfiguration configuration;
        public AuthenticationController(ISecurityAuthenticationService securityAuthenticationService, IObjectConverter objectConverter, IConfiguration configuration) {
            this.securityAuthenticationService = securityAuthenticationService;
            this.objectConverter = objectConverter;
            this.configuration = configuration;
        }
        [HttpPost("Authenticate")]
        public IActionResult Authenticate(
            [FromBody]
            [SwaggerRequestBody(@"For example: <br /> { ""userName"": ""Admin"", ""password"": """" }")]
            AuthenticationStandardLogonParameters logonParameters
        ) {
            ApplicationUser user;
            try {
                user = (ApplicationUser)securityAuthenticationService.Authenticate(logonParameters);
            }
            catch(Exception ex) {
                if(ex is IUserFriendlyException) {
                    return Unauthorized(ex.Message);
                }
                else {
                    return Unauthorized();
                }
            }
            IList<Claim> claims = new List<Claim>();
            claims.Add(new Claim(ClaimTypes.NameIdentifier, user.Oid.ToString()));
            // You can save logonParameters for further use.
            claims.Add(new Claim("LogonParams", objectConverter.Pack(logonParameters)));
            var issuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(configuration["Authentication:Jwt:IssuerSigningKey"]));
            var token = new JwtSecurityToken(
                issuer: configuration["Authentication:Jwt:Issuer"],
                audience: configuration["Authentication:Jwt:Audience"],
                claims: claims,
                expires: DateTime.Now.AddHours(2),
                signingCredentials: new SigningCredentials(issuerSigningKey, SecurityAlgorithms.HmacSha256)
            );
            return Ok(new JwtSecurityTokenHandler().WriteToken(token));
        }
    }
}
