using System;
using System.IO;
using System.Web;

namespace _24_1571GuadesPersonalPortfolio.Helpers
{
    /// <summary>
    /// Turns a stored image path (relative to the site root, e.g. "..._Media/headshot.jpg") into a
    /// URL the browser can load, but only when the file really exists. A missing or empty image
    /// gives an empty string, so the page can show its icon cover instead of a broken picture.
    /// </summary>
    public static class ImageHelper
    {
        /// <summary>
        /// Returns the image's URL, or an empty string when the path is empty, tries to leave the
        /// site folder, or points to a file that is not on disk.
        /// </summary>
        public static string ResolveExisting(string relativePath)
        {
            HttpContext context = HttpContext.Current;

            if (context == null || string.IsNullOrWhiteSpace(relativePath))
            {
                return string.Empty;
            }

            string clean = relativePath.Trim().Replace('\\', '/').TrimStart('/');

            if (clean.Contains(".."))
            {
                return string.Empty;
            }

            try
            {
                string physicalPath = context.Server.MapPath("~/" + clean);
                return File.Exists(physicalPath)
                    ? VirtualPathUtility.ToAbsolute("~/" + clean)
                    : string.Empty;
            }
            catch (HttpException)
            {
                return string.Empty;
            }
            catch (ArgumentException)
            {
                return string.Empty;
            }
        }
    }
}
