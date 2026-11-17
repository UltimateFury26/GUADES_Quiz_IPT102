using System;

namespace _24_1571GuadesPersonalPortfolio.Helpers
{
    /// <summary>
    /// Small helpers for addresses that an Admin types in, so they can be shown as links safely.
    /// </summary>
    public static class UrlHelper
    {
        /// <summary>
        /// Returns the address (trimmed) only when it is an absolute http or https link, otherwise
        /// an empty string. A value like "javascript:..." can therefore never become a clickable link.
        /// </summary>
        public static string SafeHttpUrl(string url)
        {
            Uri uri;
            if (!string.IsNullOrWhiteSpace(url)
                && Uri.TryCreate(url.Trim(), UriKind.Absolute, out uri)
                && (uri.Scheme == Uri.UriSchemeHttp || uri.Scheme == Uri.UriSchemeHttps))
            {
                return url.Trim();
            }

            return string.Empty;
        }
    }
}
