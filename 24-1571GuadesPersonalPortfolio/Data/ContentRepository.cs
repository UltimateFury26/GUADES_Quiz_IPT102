using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace _24_1571GuadesPersonalPortfolio.Data
{
    public class PersonalInfo
    {
        public string FullName { get; set; }
        public string Tagline { get; set; }
        public string Bio { get; set; }
        public string Email { get; set; }
        public string Phone { get; set; }
        public string Address { get; set; }
        public string GitHubUrl { get; set; }
        public string LinkedInUrl { get; set; }
        public string AvatarPath { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    public class Project
    {
        public int ProjectId { get; set; }
        public string Title { get; set; }
        public string TechStack { get; set; }
        public string Role { get; set; }
        public string Details { get; set; }
        public string RepoUrl { get; set; }
        public int SortOrder { get; set; }
    }

    public class Skill
    {
        public int SkillId { get; set; }
        public string Name { get; set; }
        public string Category { get; set; }
        public string Description { get; set; }
        public int SortOrder { get; set; }
    }

    public class EducationEntry
    {
        public int EducationId { get; set; }
        public string SchoolName { get; set; }
        public string Level { get; set; }
        public string Program { get; set; }
        public int? StartYear { get; set; }
        public int? EndYear { get; set; }
        public string Description { get; set; }
        public string PhotoPath { get; set; }
        public int SortOrder { get; set; }
    }


    public class GalleryEntry
    {
        public int GalleryId { get; set; }
        public string ImagePath { get; set; }
        public string Caption { get; set; }
        public int SortOrder { get; set; }
    }

    public class HobbyEntry
    {
        public int HobbyId { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string ImagePath { get; set; }
        public int SortOrder { get; set; }
    }
    public static class ContentRepository
    {
        public static PersonalInfo GetPersonalInfo()
        {
            DataTable table = Db.ExecuteTable("usp_PersonalInfo_Get");

            if (table.Rows.Count == 0)
            {
                return null;
            }

            DataRow row = table.Rows[0];

            return new PersonalInfo
            {
                FullName = (string)row["FullName"],
                Tagline = Text(row, "Tagline"),
                Bio = Text(row, "Bio"),
                Email = Text(row, "Email"),
                Phone = Text(row, "Phone"),
                Address = Text(row, "Address"),
                GitHubUrl = Text(row, "GitHubUrl"),
                LinkedInUrl = Text(row, "LinkedInUrl"),
                AvatarPath = Text(row, "AvatarPath"),
                UpdatedAt = Convert.ToDateTime(row["UpdatedAt"])
            };
        }

 
        public static void UpdatePersonalInfo(PersonalInfo info)
        {
            Db.ExecuteScalar(
                "usp_PersonalInfo_Update",
                Db.Param("@FullName", info.FullName),
                Db.Param("@Tagline", info.Tagline),
                Db.Param("@Bio", info.Bio),
                Db.Param("@Email", info.Email),
                Db.Param("@Phone", info.Phone),
                Db.Param("@Address", info.Address),
                Db.Param("@GitHubUrl", info.GitHubUrl),
                Db.Param("@LinkedInUrl", info.LinkedInUrl),
                Db.Param("@AvatarPath", info.AvatarPath));
        }


        public static List<Project> GetProjects()
        {
            DataTable table = Db.ExecuteTable("usp_Project_GetAll");
            List<Project> projects = new List<Project>();

            foreach (DataRow row in table.Rows)
            {
                projects.Add(ToProject(row));
            }

            return projects;
        }

        public static Project GetProjectById(int projectId)
        {
            DataTable table = Db.ExecuteTable("usp_Project_GetById", Db.Param("@ProjectId", projectId));
            return table.Rows.Count == 0 ? null : ToProject(table.Rows[0]);
        }

    
        public static int InsertProject(Project project, int? sortOrder)
        {
            object newId = Db.ExecuteScalar("usp_Project_Insert", ProjectParameters(project, false, sortOrder));
            return Convert.ToInt32(newId);
        }

        public static int UpdateProject(Project project, int? sortOrder)
        {
            object affected = Db.ExecuteScalar("usp_Project_Update", ProjectParameters(project, true, sortOrder));
            return Convert.ToInt32(affected);
        }

        public static int DeleteProject(int projectId)
        {
            object affected = Db.ExecuteScalar("usp_Project_Delete", Db.Param("@ProjectId", projectId));
            return Convert.ToInt32(affected);
        }

       
        public static List<Skill> GetSkills()
        {
            DataTable table = Db.ExecuteTable("usp_Skill_GetAll", Db.Param("@Category", null));
            List<Skill> skills = new List<Skill>();

            foreach (DataRow row in table.Rows)
            {
                skills.Add(ToSkill(row));
            }

            return skills;
        }


        public static Skill GetSkillById(int skillId)
        {
            DataTable table = Db.ExecuteTable("usp_Skill_GetById", Db.Param("@SkillId", skillId));
            return table.Rows.Count == 0 ? null : ToSkill(table.Rows[0]);
        }

       
        public static int InsertSkill(Skill skill, int? sortOrder)
        {
            object newId = Db.ExecuteScalar("usp_Skill_Insert", SkillParameters(skill, false, sortOrder));
            return Convert.ToInt32(newId);
        }

        public static int UpdateSkill(Skill skill, int? sortOrder)
        {
            object affected = Db.ExecuteScalar("usp_Skill_Update", SkillParameters(skill, true, sortOrder));
            return Convert.ToInt32(affected);
        }

        public static int DeleteSkill(int skillId)
        {
            object affected = Db.ExecuteScalar("usp_Skill_Delete", Db.Param("@SkillId", skillId));
            return Convert.ToInt32(affected);
        }

        public static List<EducationEntry> GetEducation()
        {
            DataTable table = Db.ExecuteTable("usp_Education_GetAll");
            List<EducationEntry> schools = new List<EducationEntry>();

            foreach (DataRow row in table.Rows)
            {
                schools.Add(ToEducation(row));
            }

            return schools;
        }

        public static EducationEntry GetEducationById(int educationId)
        {
            DataTable table = Db.ExecuteTable("usp_Education_GetById", Db.Param("@EducationId", educationId));
            return table.Rows.Count == 0 ? null : ToEducation(table.Rows[0]);
        }

        public static int InsertEducation(EducationEntry entry, int? sortOrder)
        {
            object newId = Db.ExecuteScalar("usp_Education_Insert", EducationParameters(entry, false, sortOrder));
            return Convert.ToInt32(newId);
        }

        public static int UpdateEducation(EducationEntry entry, int? sortOrder)
        {
            object affected = Db.ExecuteScalar("usp_Education_Update", EducationParameters(entry, true, sortOrder));
            return Convert.ToInt32(affected);
        }

        public static int DeleteEducation(int educationId)
        {
            object affected = Db.ExecuteScalar("usp_Education_Delete", Db.Param("@EducationId", educationId));
            return Convert.ToInt32(affected);
        }

        public static List<GalleryEntry> GetGallery()
        {
            DataTable table = Db.ExecuteTable("usp_Gallery_GetAll");
            List<GalleryEntry> photos = new List<GalleryEntry>();

            foreach (DataRow row in table.Rows)
            {
                photos.Add(ToGalleryEntry(row));
            }

            return photos;
        }

    
        public static GalleryEntry GetGalleryById(int galleryId)
        {
            DataTable table = Db.ExecuteTable("usp_Gallery_GetById", Db.Param("@GalleryId", galleryId));
            return table.Rows.Count == 0 ? null : ToGalleryEntry(table.Rows[0]);
        }

        public static int InsertGalleryItem(GalleryEntry entry, int? sortOrder)
        {
            object newId = Db.ExecuteScalar("usp_Gallery_Insert", GalleryParameters(entry, false, sortOrder));
            return Convert.ToInt32(newId);
        }

        public static int UpdateGalleryItem(GalleryEntry entry, int? sortOrder)
        {
            object affected = Db.ExecuteScalar("usp_Gallery_Update", GalleryParameters(entry, true, sortOrder));
            return Convert.ToInt32(affected);
        }

       
        public static int DeleteGalleryItem(int galleryId)
        {
            object affected = Db.ExecuteScalar("usp_Gallery_Delete", Db.Param("@GalleryId", galleryId));
            return Convert.ToInt32(affected);
        }

        public static List<HobbyEntry> GetHobbies()
        {
            DataTable table = Db.ExecuteTable("usp_Hobby_GetAll");
            List<HobbyEntry> hobbies = new List<HobbyEntry>();

            foreach (DataRow row in table.Rows)
            {
                hobbies.Add(ToHobby(row));
            }

            return hobbies;
        }

        public static HobbyEntry GetHobbyById(int hobbyId)
        {
            DataTable table = Db.ExecuteTable("usp_Hobby_GetById", Db.Param("@HobbyId", hobbyId));
            return table.Rows.Count == 0 ? null : ToHobby(table.Rows[0]);
        }


        public static int InsertHobby(HobbyEntry entry, int? sortOrder)
        {
            object newId = Db.ExecuteScalar("usp_Hobby_Insert", HobbyParameters(entry, false, sortOrder));
            return Convert.ToInt32(newId);
        }

        public static int UpdateHobby(HobbyEntry entry, int? sortOrder)
        {
            object affected = Db.ExecuteScalar("usp_Hobby_Update", HobbyParameters(entry, true, sortOrder));
            return Convert.ToInt32(affected);
        }

        public static int DeleteHobby(int hobbyId)
        {
            object affected = Db.ExecuteScalar("usp_Hobby_Delete", Db.Param("@HobbyId", hobbyId));
            return Convert.ToInt32(affected);
        }

        private static HobbyEntry ToHobby(DataRow row)
        {
            return new HobbyEntry
            {
                HobbyId = (int)row["HobbyId"],
                Title = (string)row["Title"],
                Description = Text(row, "Description"),
                ImagePath = Text(row, "ImagePath"),
                SortOrder = (int)row["SortOrder"]
            };
        }

        private static SqlParameter[] HobbyParameters(HobbyEntry entry, bool includeId, int? sortOrder)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();

            if (includeId)
            {
                parameters.Add(Db.Param("@HobbyId", entry.HobbyId));
            }

            parameters.Add(Db.Param("@Title", entry.Title));
            parameters.Add(Db.Param("@Description", entry.Description));
            parameters.Add(Db.Param("@ImagePath", entry.ImagePath));
            parameters.Add(Db.Param("@SortOrder", sortOrder));

            return parameters.ToArray();
        }

        private static Project ToProject(DataRow row)
        {
            return new Project
            {
                ProjectId = (int)row["ProjectId"],
                Title = (string)row["Title"],
                TechStack = Text(row, "TechStack"),
                Role = Text(row, "Role"),
                Details = Text(row, "Details"),
                RepoUrl = Text(row, "RepoUrl"),
                SortOrder = (int)row["SortOrder"]
            };
        }

        private static SqlParameter[] ProjectParameters(Project project, bool includeId, int? sortOrder)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();

            if (includeId)
            {
                parameters.Add(Db.Param("@ProjectId", project.ProjectId));
            }

            parameters.Add(Db.Param("@Title", project.Title));
            parameters.Add(Db.Param("@TechStack", project.TechStack));
            parameters.Add(Db.Param("@Role", project.Role));
            parameters.Add(Db.Param("@Details", project.Details));
            parameters.Add(Db.Param("@RepoUrl", project.RepoUrl));
            parameters.Add(Db.Param("@SortOrder", sortOrder));

            return parameters.ToArray();
        }

        private static GalleryEntry ToGalleryEntry(DataRow row)
        {
            return new GalleryEntry
            {
                GalleryId = (int)row["GalleryId"],
                ImagePath = (string)row["ImagePath"],
                Caption = Text(row, "Caption"),
                SortOrder = (int)row["SortOrder"]
            };
        }

        private static SqlParameter[] GalleryParameters(GalleryEntry entry, bool includeId, int? sortOrder)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();

            if (includeId)
            {
                parameters.Add(Db.Param("@GalleryId", entry.GalleryId));
            }

            parameters.Add(Db.Param("@ImagePath", entry.ImagePath));
            parameters.Add(Db.Param("@Caption", entry.Caption));
            parameters.Add(Db.Param("@SortOrder", sortOrder));

            return parameters.ToArray();
        }

        private static Skill ToSkill(DataRow row)
        {
            return new Skill
            {
                SkillId = (int)row["SkillId"],
                Name = (string)row["Name"],
                Category = (string)row["Category"],
                Description = Text(row, "Description"),
                SortOrder = (int)row["SortOrder"]
            };
        }

        private static SqlParameter[] SkillParameters(Skill skill, bool includeId, int? sortOrder)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();

            if (includeId)
            {
                parameters.Add(Db.Param("@SkillId", skill.SkillId));
            }

            parameters.Add(Db.Param("@Name", skill.Name));
            parameters.Add(Db.Param("@Category", skill.Category));
            parameters.Add(Db.Param("@Description", skill.Description));
            parameters.Add(Db.Param("@SortOrder", sortOrder));

            return parameters.ToArray();
        }

        private static EducationEntry ToEducation(DataRow row)
        {
            return new EducationEntry
            {
                EducationId = (int)row["EducationId"],
                SchoolName = (string)row["SchoolName"],
                Level = (string)row["Level"],
                Program = Text(row, "Program"),
                StartYear = row["StartYear"] == DBNull.Value ? (int?)null : Convert.ToInt32(row["StartYear"]),
                EndYear = row["EndYear"] == DBNull.Value ? (int?)null : Convert.ToInt32(row["EndYear"]),
                Description = Text(row, "Description"),
                PhotoPath = Text(row, "PhotoPath"),
                SortOrder = (int)row["SortOrder"]
            };
        }

        private static SqlParameter[] EducationParameters(EducationEntry entry, bool includeId, int? sortOrder)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();

            if (includeId)
            {
                parameters.Add(Db.Param("@EducationId", entry.EducationId));
            }

            parameters.Add(Db.Param("@SchoolName", entry.SchoolName));
            parameters.Add(Db.Param("@Level", entry.Level));
            parameters.Add(Db.Param("@Program", entry.Program));
            parameters.Add(Db.Param("@StartYear", entry.StartYear));
            parameters.Add(Db.Param("@EndYear", entry.EndYear));
            parameters.Add(Db.Param("@Description", entry.Description));
            parameters.Add(Db.Param("@PhotoPath", entry.PhotoPath));
            parameters.Add(Db.Param("@SortOrder", sortOrder));

            return parameters.ToArray();
        }

        private static string Text(DataRow row, string column)
        {
            return row[column] == DBNull.Value ? null : (string)row[column];
        }
    }
}