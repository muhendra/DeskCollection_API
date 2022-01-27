using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Web;
using System.Web.Http.Controllers;
using System.Web.Http.Filters;

namespace DeskCollWebService.Filters
{
    public class BasicAuthenticationAttribute : AuthorizationFilterAttribute
    {
        public override void OnAuthorization(HttpActionContext actionContext)
        {
            string authUserID = ConfigurationManager.AppSettings["AuthUserID"];
            string authPass = ConfigurationManager.AppSettings["AuthPass"];

            var authHeader = actionContext.Request.Headers.Authorization;

            if (authHeader != null)
            {
                var authenticationToken = actionContext.Request.Headers.Authorization.Parameter;
                var decodedAuthenticationToken = Encoding.UTF8.GetString(Convert.FromBase64String(authenticationToken));
                var usernamePasswordArray = decodedAuthenticationToken.Split(':');
                var userName = usernamePasswordArray[0];
                var password = usernamePasswordArray[1];

                // Replace this with your own system of security / means of validating credentials
                var isValid = userName == authUserID && password == authPass;

                if (isValid)
                {
                    //var principal = new GenericPrincipal(new GenericIdentity(userName), null);
                    //Thread.CurrentPrincipal = principal;

                    //actionContext.Response =
                    //   actionContext.Request.CreateResponse(HttpStatusCode.OK,
                    //      "User " + userName + " successfully authenticated");

                    return;
                }
            }

            HandleUnathorized(actionContext);
        }

        private static void HandleUnathorized(HttpActionContext actionContext)
        {
            actionContext.Response = actionContext.Request.CreateResponse(HttpStatusCode.Unauthorized);
            actionContext.Response.Headers.Add("WWW-Authenticate", "Basic Scheme='Data' location = 'http://localhost:");
        }
    }
}