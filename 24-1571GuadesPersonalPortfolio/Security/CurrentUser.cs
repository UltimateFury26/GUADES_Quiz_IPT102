using System.Web;
using System.Web.Security;
using _24_1571GuadesPersonalPortfolio.Helpers;

namespace _24_1571GuadesPersonalPortfolio.Security
{
    /// <summary>
    /// Read-only view of the logged-in account, taken from the Forms Authentication ticket.
    /// The ticket's UserData holds "UserId|Role", and this is the only class that reads or builds it.
    /// </summary>
    public static class CurrentUser
    {
        private const char Separator = '|';

        /// <summary>True when someone is logged in.</summary>
        public static bool IsAuthenticated
        {
            get
            {
                HttpContext ctx = HttpContext.Current;
                return ctx != null && ctx.User != null && ctx.User.Identity.IsAuthenticated;
            }
        }

        /// <summary>The logged-in user's UserId, or 0 when nobody is logged in.</summary>
        public static int Id
        {
            get
            {
                int id;
                string role;
                return TryReadTicket(out id, out role) ? id : 0;
            }
        }

        /// <summary>The logged-in username, or an empty string when nobody is logged in.</summary>
        public static string Username
        {
            get { return IsAuthenticated ? HttpContext.Current.User.Identity.Name : string.Empty; }
        }

        /// <summary>The logged-in role ("Admin" or "User"), or an empty string.</summary>
        public static string Role
        {
            get
            {
                int id;
                string role;
                return TryReadTicket(out id, out role) ? role : string.Empty;
            }
        }

        /// <summary>True when the logged-in account is an Admin.</summary>
        public static bool IsAdmin
        {
            get { return Role == Constants.Roles.Admin; }
        }

        /// <summary>Packs the values stored in the ticket's UserData.</summary>
        public static string BuildUserData(int userId, string role)
        {
            return userId + Separator.ToString() + role;
        }

        /// <summary>Unpacks a ticket's UserData. Returns false if it is missing or malformed.</summary>
        public static bool TryParseUserData(string userData, out int userId, out string role)
        {
            userId = 0;
            role = string.Empty;

            if (string.IsNullOrEmpty(userData))
            {
                return false;
            }

            string[] parts = userData.Split(Separator);
            if (parts.Length != 2 || !int.TryParse(parts[0], out userId))
            {
                userId = 0;
                return false;
            }

            role = parts[1];
            return true;
        }

        private static bool TryReadTicket(out int userId, out string role)
        {
            userId = 0;
            role = string.Empty;

            if (!IsAuthenticated)
            {
                return false;
            }

            FormsIdentity identity = HttpContext.Current.User.Identity as FormsIdentity;
            if (identity == null)
            {
                return false;
            }

            return TryParseUserData(identity.Ticket.UserData, out userId, out role);
        }
    }
}