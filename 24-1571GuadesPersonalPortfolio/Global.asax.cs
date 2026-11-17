using System;
using System.IO;
using System.Security.Principal;
using System.Web;
using System.Web.Security;
using _24_1571GuadesPersonalPortfolio.Security;

namespace _24_1571GuadesPersonalPortfolio
{

    public class Global : HttpApplication
    {
        protected void Application_PostAuthenticateRequest(object sender, EventArgs e)
        {
            FormsIdentity identity = Context.User != null
                ? Context.User.Identity as FormsIdentity
                : null;

            if (identity == null)
            {
                return;
            }

            int userId;
            string role;
            if (CurrentUser.TryParseUserData(identity.Ticket.UserData, out userId, out role))
            {
                Context.User = new GenericPrincipal(identity, new[] { role });
            }
        }

     
        protected void Application_Error(object sender, EventArgs e)
        {
            Exception ex = Server.GetLastError();
            if (ex == null)
            {
                return;
            }

            try
            {
                string logPath = Server.MapPath("~/App_Data/error.log");
                string entry = string.Format(
                    "{0:u} | {1} | {2}{3}{4}{5}",
                    DateTime.UtcNow,
                    Request != null ? Request.RawUrl : "(no request)",
                    ex.GetType().Name,
                    Environment.NewLine,
                    ex.ToString(),
                    Environment.NewLine + "----" + Environment.NewLine);

                File.AppendAllText(logPath, entry);
            }
            catch
            {
            }
        }
    }
}