using System;
using System.IO;
using System.Web;

namespace _24_1571GuadesPersonalPortfolio.Helpers
{
    /// <summary>Outcome of FileUploader.SaveImage: either the saved path or a message for the Admin.</summary>
    public sealed class UploadResult
    {
        public bool Success { get; private set; }

        /// <summary>Path relative to the site root, e.g. "..._Uploads/3f2a....jpg". Empty on failure.</summary>
        public string RelativePath { get; private set; }

        /// <summary>Friendly explanation when Success is false.</summary>
        public string Error { get; private set; }

        public static UploadResult Ok(string relativePath)
        {
            return new UploadResult { Success = true, RelativePath = relativePath, Error = string.Empty };
        }

        public static UploadResult Fail(string error)
        {
            return new UploadResult { Success = false, RelativePath = string.Empty, Error = error };
        }
    }

    /// <summary>
    /// Validates and saves images an Admin uploads, and removes uploaded files that are no longer used.
    /// A file is accepted only when its extension, its content type AND its first bytes all say it is a
    /// JPG, PNG or GIF, and it is at most 5 MB. It is saved under a generated name, never the original one.
    /// The seeded images in the Media folder are never deleted by this class.
    /// </summary>
    public static class FileUploader
    {
        /// <summary>Folder (under the site root) that holds every uploaded image.</summary>
        public const string UploadFolder = "24-1571GuadesPersonalPortfolio_Uploads";

        /// <summary>Largest accepted file, in bytes (5 MB).</summary>
        public const int MaxBytes = 5 * 1024 * 1024;

        private const string KindJpg = "jpg";
        private const string KindPng = "png";
        private const string KindGif = "gif";

        private const string NoFileMessage = "Choose an image to upload.";
        private const string TooLargeMessage = "That image is larger than 5 MB.";
        private const string WrongTypeMessage = "Use a JPG, PNG or GIF image.";
        private const string NotAnImageMessage = "That file doesn't look like a real JPG, PNG or GIF image.";
        private const string SaveFailedMessage = "The image couldn't be saved on the server. Try again.";

        /// <summary>Checks and saves one uploaded image. Never throws for a bad file; read Success and Error.</summary>
        public static UploadResult SaveImage(HttpPostedFile file)
        {
            if (file == null || file.ContentLength == 0)
            {
                return UploadResult.Fail(NoFileMessage);
            }

            if (file.ContentLength > MaxBytes)
            {
                return UploadResult.Fail(TooLargeMessage);
            }

            string kind = KindForExtension(Path.GetExtension(file.FileName ?? string.Empty));

            if (kind == null || !ContentTypeMatches(kind, file.ContentType))
            {
                return UploadResult.Fail(WrongTypeMessage);
            }

            if (!SignatureMatches(kind, file.InputStream))
            {
                return UploadResult.Fail(NotAnImageMessage);
            }

            try
            {
                string folder = HttpContext.Current.Server.MapPath("~/" + UploadFolder);
                Directory.CreateDirectory(folder);

                string fileName = Guid.NewGuid().ToString("N") + "." + kind;
                file.SaveAs(Path.Combine(folder, fileName));

                return UploadResult.Ok(UploadFolder + "/" + fileName);
            }
            catch (IOException)
            {
                return UploadResult.Fail(SaveFailedMessage);
            }
            catch (UnauthorizedAccessException)
            {
                return UploadResult.Fail(SaveFailedMessage);
            }
            catch (HttpException)
            {
                return UploadResult.Fail(SaveFailedMessage);
            }
        }

        /// <summary>
        /// Deletes a file previously saved by SaveImage. Does nothing for an empty path, for anything
        /// outside the uploads folder (so the seeded Media images are safe) or for a file that is gone.
        /// </summary>
        public static void DeleteIfUploaded(string relativePath)
        {
            if (string.IsNullOrWhiteSpace(relativePath))
            {
                return;
            }

            string clean = relativePath.Trim().Replace('\\', '/');
            string prefix = UploadFolder + "/";

            if (!clean.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
            {
                return;
            }

            string fileName = clean.Substring(prefix.Length);

            if (fileName.Length == 0 || fileName.Contains("..") || fileName != Path.GetFileName(fileName))
            {
                return;
            }

            try
            {
                string physicalPath = Path.Combine(
                    HttpContext.Current.Server.MapPath("~/" + UploadFolder), fileName);

                if (File.Exists(physicalPath))
                {
                    File.Delete(physicalPath);
                }
            }
            catch (IOException)
            {
                // A file that cannot be removed right now is left behind; it is never shown anywhere.
            }
            catch (UnauthorizedAccessException)
            {
            }
        }

        /// <summary>Maps an extension to "jpg", "png" or "gif", or null when it is not an allowed image type.</summary>
        private static string KindForExtension(string extension)
        {
            switch ((extension ?? string.Empty).ToLowerInvariant())
            {
                case ".jpg":
                case ".jpeg":
                    return KindJpg;

                case ".png":
                    return KindPng;

                case ".gif":
                    return KindGif;

                default:
                    return null;
            }
        }

        private static bool ContentTypeMatches(string kind, string contentType)
        {
            string type = (contentType ?? string.Empty).Trim().ToLowerInvariant();

            switch (kind)
            {
                case KindJpg:
                    return type == "image/jpeg" || type == "image/pjpeg";

                case KindPng:
                    return type == "image/png" || type == "image/x-png";

                default:
                    return type == "image/gif";
            }
        }

        /// <summary>Compares the first bytes of the file with the signature of the claimed image type.</summary>
        private static bool SignatureMatches(string kind, Stream stream)
        {
            byte[] header = new byte[8];

            stream.Position = 0;
            int read = stream.Read(header, 0, header.Length);
            stream.Position = 0;

            switch (kind)
            {
                case KindJpg:
                    return read >= 3 && header[0] == 0xFF && header[1] == 0xD8 && header[2] == 0xFF;

                case KindPng:
                    return read >= 8
                        && header[0] == 0x89 && header[1] == 0x50 && header[2] == 0x4E && header[3] == 0x47
                        && header[4] == 0x0D && header[5] == 0x0A && header[6] == 0x1A && header[7] == 0x0A;

                default:
                    return read >= 6
                        && header[0] == 'G' && header[1] == 'I' && header[2] == 'F' && header[3] == '8'
                        && (header[4] == '7' || header[4] == '9') && header[5] == 'a';
            }
        }
    }
}
