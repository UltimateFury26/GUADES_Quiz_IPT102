using System;
using System.Collections.Generic;
using System.Data;

namespace _24_1571GuadesPersonalPortfolio.Data
{
    public class Post
    {
        public int PostId { get; set; }
        public string Title { get; set; }
        public string Body { get; set; }
        public bool IsPublished { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public string AuthorName { get; set; }
    }

    public static class PostRepository
    {

        public static List<Post> GetPublished()
        {
            return ToPosts(Db.ExecuteTable("usp_Post_GetPublished"));
        }

       
        public static List<Post> GetAll()
        {
            return ToPosts(Db.ExecuteTable("usp_Post_GetAll"));
        }

        public static Post GetById(int postId)
        {
            DataTable table = Db.ExecuteTable("usp_Post_GetById", Db.Param("@PostId", postId));
            return table.Rows.Count == 0 ? null : ToPost(table.Rows[0]);
        }

        public static int Insert(string title, string body, bool isPublished, int authorId)
        {
            object newId = Db.ExecuteScalar(
                "usp_Post_Insert",
                Db.Param("@Title", title),
                Db.Param("@Body", body),
                Db.Param("@IsPublished", isPublished),
                Db.Param("@AuthorId", authorId));

            return Convert.ToInt32(newId);
        }

       
        public static int Update(int postId, string title, string body, bool isPublished)
        {
            object affected = Db.ExecuteScalar(
                "usp_Post_Update",
                Db.Param("@PostId", postId),
                Db.Param("@Title", title),
                Db.Param("@Body", body),
                Db.Param("@IsPublished", isPublished));

            return Convert.ToInt32(affected);
        }

       
        public static int SetPublished(int postId, bool isPublished)
        {
            object affected = Db.ExecuteScalar(
                "usp_Post_SetPublished",
                Db.Param("@PostId", postId),
                Db.Param("@IsPublished", isPublished));

            return Convert.ToInt32(affected);
        }

        public static int Delete(int postId)
        {
            object affected = Db.ExecuteScalar("usp_Post_Delete", Db.Param("@PostId", postId));
            return Convert.ToInt32(affected);
        }

        private static List<Post> ToPosts(DataTable table)
        {
            List<Post> posts = new List<Post>();

            foreach (DataRow row in table.Rows)
            {
                posts.Add(ToPost(row));
            }

            return posts;
        }

        private static Post ToPost(DataRow row)
        {
            return new Post
            {
                PostId = (int)row["PostId"],
                Title = (string)row["Title"],
                Body = (string)row["Body"],
                IsPublished = (bool)row["IsPublished"],
                CreatedAt = Convert.ToDateTime(row["CreatedAt"]),
                UpdatedAt = row["UpdatedAt"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(row["UpdatedAt"]),
                AuthorName = (string)row["AuthorName"]
            };
        }
    }
}
