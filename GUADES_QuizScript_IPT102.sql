/* =====================================================================
   PersonalPortfolioDB - COMPLETE DATABASE SCRIPT
   IPT102 Online Quiz 1 - Personal Website (ASP.NET Web Forms + MS SQL)

   This file concatenates, in the order they were written and run:
     1. Phase 1  - Tables
     2. Phase 2  - Stored procedures and seed data
     3. Add-on   - User visit tracking (PageVisits)

   It is safe to run top to bottom against a fresh database, and safe to
   re-run against an existing one: tables use IF NOT EXISTS, procedures use
   CREATE OR ALTER, and every seed insert is guarded.
   ===================================================================== */



/* #####################################################################
   PART 1 OF 3 — PHASE 1: TABLES
   ##################################################################### */

/* =====================================================================
   PersonalPortfolioDB - PHASE 1: TABLES
   IPT102 Online Quiz 1 - Personal Website (ASP.NET Web Forms + MS SQL)

   What this script does
     - Creates the database if it does not exist yet
     - Creates the 8 tables, their keys, defaults, checks and indexes
     - Is safe to re-run: existing tables are left untouched

   Two kinds of data are kept apart on purpose
     USER INFORMATION  : dbo.Users
     WEBSITE CONTENT   : dbo.PersonalInfo, dbo.Education, dbo.Skills,
                         dbo.Hobbies, dbo.Projects, dbo.GalleryItems,
                         dbo.Posts (announcements)
     Content tables have no UserId. They belong to the site owner and
     only the Admin edits them.
   ===================================================================== */

IF DB_ID(N'PersonalPortfolioDB') IS NULL
    CREATE DATABASE PersonalPortfolioDB;
GO

USE PersonalPortfolioDB;
GO

/* ---------------------------------------------------------------------
   1. USERS  (user information: one row per registered account)
   --------------------------------------------------------------------- */
IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Users
    (
        UserId        INT IDENTITY(1,1)  NOT NULL,
        Username      NVARCHAR(50)       NOT NULL,
        Email         NVARCHAR(100)      NOT NULL,
        Phone         VARCHAR(11)        NOT NULL,
        PasswordHash  VARBINARY(32)      NOT NULL,   -- SHA2_256 hash, made inside SQL
        PasswordSalt  UNIQUEIDENTIFIER   NOT NULL,   -- random salt per user
        [Role]        VARCHAR(10)        NOT NULL CONSTRAINT DF_Users_Role      DEFAULT ('User'),
        [Status]      VARCHAR(10)        NOT NULL CONSTRAINT DF_Users_Status    DEFAULT ('Active'),
        CreatedAt     DATETIME2(0)       NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT (SYSDATETIME()),
        LastLoginAt   DATETIME2(0)       NULL,

        CONSTRAINT PK_Users          PRIMARY KEY (UserId),
        CONSTRAINT UQ_Users_Username UNIQUE (Username),
        CONSTRAINT UQ_Users_Email    UNIQUE (Email),
        CONSTRAINT CK_Users_Role     CHECK ([Role]   IN ('Admin', 'User')),
        CONSTRAINT CK_Users_Status   CHECK ([Status] IN ('Active', 'Inactive')),
        CONSTRAINT CK_Users_Phone    CHECK (Phone NOT LIKE '%[^0-9]%' AND LEN(Phone) = 11)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = N'IX_Users_Status' AND object_id = OBJECT_ID(N'dbo.Users'))
    CREATE INDEX IX_Users_Status ON dbo.Users ([Status]);

IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = N'IX_Users_CreatedAt' AND object_id = OBJECT_ID(N'dbo.Users'))
    CREATE INDEX IX_Users_CreatedAt ON dbo.Users (CreatedAt);
GO

/* ---------------------------------------------------------------------
   2. PERSONALINFO  (website content: exactly one row, the owner's profile)
   --------------------------------------------------------------------- */
IF OBJECT_ID(N'dbo.PersonalInfo', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PersonalInfo
    (
        PersonalInfoId INT            NOT NULL CONSTRAINT DF_PersonalInfo_Id DEFAULT (1),
        FullName       NVARCHAR(100)  NOT NULL,
        Tagline        NVARCHAR(200)  NULL,
        Bio            NVARCHAR(MAX)  NULL,
        Email          NVARCHAR(100)  NULL,
        Phone          VARCHAR(20)    NULL,
        [Address]      NVARCHAR(250)  NULL,
        GitHubUrl      NVARCHAR(250)  NULL,
        LinkedInUrl    NVARCHAR(250)  NULL,
        AvatarPath     NVARCHAR(260)  NULL,
        UpdatedAt      DATETIME2(0)   NOT NULL CONSTRAINT DF_PersonalInfo_UpdatedAt DEFAULT (SYSDATETIME()),

        CONSTRAINT PK_PersonalInfo           PRIMARY KEY (PersonalInfoId),
        CONSTRAINT CK_PersonalInfo_SingleRow CHECK (PersonalInfoId = 1)
    );
END
GO

/* ---------------------------------------------------------------------
   3. EDUCATION  (website content: Educational Attainment)
   --------------------------------------------------------------------- */
IF OBJECT_ID(N'dbo.Education', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Education
    (
        EducationId  INT IDENTITY(1,1) NOT NULL,
        SchoolName   NVARCHAR(150)     NOT NULL,
        [Level]      NVARCHAR(50)      NOT NULL,   -- e.g. Senior High School, College
        Program      NVARCHAR(150)     NULL,       -- e.g. BS Information Technology
        StartYear    SMALLINT          NOT NULL,
        EndYear      SMALLINT          NULL,       -- NULL = still studying
        [Description] NVARCHAR(MAX)    NULL,
        PhotoPath    NVARCHAR(260)     NULL,
        SortOrder    INT               NOT NULL CONSTRAINT DF_Education_SortOrder DEFAULT (0),

        CONSTRAINT PK_Education       PRIMARY KEY (EducationId),
        CONSTRAINT CK_Education_Years CHECK (EndYear IS NULL OR EndYear >= StartYear)
    );
END
GO

/* ---------------------------------------------------------------------
   4. SKILLS  (website content: Skills; Category decides the board)
   --------------------------------------------------------------------- */
IF OBJECT_ID(N'dbo.Skills', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Skills
    (
        SkillId       INT IDENTITY(1,1) NOT NULL,
        [Name]        NVARCHAR(100)     NOT NULL,
        Category      VARCHAR(20)       NOT NULL,
        [Description] NVARCHAR(MAX)     NULL,
        SortOrder     INT               NOT NULL CONSTRAINT DF_Skills_SortOrder DEFAULT (0),

        CONSTRAINT PK_Skills          PRIMARY KEY (SkillId),
        CONSTRAINT CK_Skills_Category CHECK (Category IN ('Frontend', 'Backend', 'Tools'))
    );
END
GO

/* ---------------------------------------------------------------------
   5. HOBBIES  (website content: Hobbies & Interest)
   --------------------------------------------------------------------- */
IF OBJECT_ID(N'dbo.Hobbies', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Hobbies
    (
        HobbyId       INT IDENTITY(1,1) NOT NULL,
        Title         NVARCHAR(100)     NOT NULL,
        [Description] NVARCHAR(500)     NULL,
        ImagePath     NVARCHAR(260)     NULL,
        SortOrder     INT               NOT NULL CONSTRAINT DF_Hobbies_SortOrder DEFAULT (0),

        CONSTRAINT PK_Hobbies PRIMARY KEY (HobbyId)
    );
END
GO

/* ---------------------------------------------------------------------
   6. PROJECTS  (website content: Recent Projects)
   --------------------------------------------------------------------- */
IF OBJECT_ID(N'dbo.Projects', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Projects
    (
        ProjectId  INT IDENTITY(1,1) NOT NULL,
        Title      NVARCHAR(150)     NOT NULL,
        TechStack  NVARCHAR(250)     NULL,
        [Role]     NVARCHAR(100)     NULL,
        Details    NVARCHAR(MAX)     NULL,
        RepoUrl    NVARCHAR(250)     NULL,
        SortOrder  INT               NOT NULL CONSTRAINT DF_Projects_SortOrder DEFAULT (0),

        CONSTRAINT PK_Projects PRIMARY KEY (ProjectId)
    );
END
GO

/* ---------------------------------------------------------------------
   7. GALLERYITEMS  (website content: Gallery)
   --------------------------------------------------------------------- */
IF OBJECT_ID(N'dbo.GalleryItems', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.GalleryItems
    (
        GalleryId  INT IDENTITY(1,1) NOT NULL,
        ImagePath  NVARCHAR(260)     NOT NULL,
        Caption    NVARCHAR(200)     NULL,
        SortOrder  INT               NOT NULL CONSTRAINT DF_GalleryItems_SortOrder DEFAULT (0),

        CONSTRAINT PK_GalleryItems PRIMARY KEY (GalleryId)
    );
END
GO

/* ---------------------------------------------------------------------
   8. POSTS  (website content: Announcements written by the Admin)
   Only Admins author posts and Admin accounts cannot be deleted, so
   this foreign key never blocks a user deletion.
   --------------------------------------------------------------------- */
IF OBJECT_ID(N'dbo.Posts', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Posts
    (
        PostId       INT IDENTITY(1,1) NOT NULL,
        Title        NVARCHAR(150)     NOT NULL,
        Body         NVARCHAR(MAX)     NOT NULL,
        IsPublished  BIT               NOT NULL CONSTRAINT DF_Posts_IsPublished DEFAULT (0),
        CreatedAt    DATETIME2(0)      NOT NULL CONSTRAINT DF_Posts_CreatedAt   DEFAULT (SYSDATETIME()),
        UpdatedAt    DATETIME2(0)      NULL,
        AuthorId     INT               NOT NULL,

        CONSTRAINT PK_Posts        PRIMARY KEY (PostId),
        CONSTRAINT FK_Posts_Author FOREIGN KEY (AuthorId) REFERENCES dbo.Users (UserId)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = N'IX_Posts_IsPublished_CreatedAt' AND object_id = OBJECT_ID(N'dbo.Posts'))
    CREATE INDEX IX_Posts_IsPublished_CreatedAt ON dbo.Posts (IsPublished, CreatedAt DESC);
GO

/* ---------------------------------------------------------------------
   CHECK: this should list 8 tables
   Education, GalleryItems, Hobbies, PersonalInfo, Posts, Projects,
   Skills, Users
   --------------------------------------------------------------------- */
SELECT TABLE_NAME
FROM   INFORMATION_SCHEMA.TABLES
WHERE  TABLE_SCHEMA = 'dbo' AND TABLE_TYPE = 'BASE TABLE'
ORDER  BY TABLE_NAME;
GO

/* #####################################################################
   PART 2 OF 3 — PHASE 2: STORED PROCEDURES AND SEED DATA
   ##################################################################### */

/* =====================================================================
   PersonalPortfolioDB - PHASE 2: STORED PROCEDURES + SEED DATA
   IPT102 Online Quiz 1 - Personal Website (ASP.NET Web Forms + MS SQL)

   Run AFTER Phase1_Tables.sql. Safe to re-run:
     - functions and procedures use CREATE OR ALTER
     - every seed insert is guarded, so nothing is duplicated

   Sections
     A. Small schema adjustment (Education.StartYear may be NULL)
     B. Helper functions (validation + password hashing)
     C. Account procedures        (usp_User_*)
     D. Admin user management     (usp_Admin_*)
     E. Website content           (usp_PersonalInfo_*, usp_Education_*, usp_Skill_*,
                                   usp_Hobby_*, usp_Project_*, usp_Gallery_*)
     F. Announcements             (usp_Post_*)
     G. Reports                   (usp_Report_*)
     H. Seed data                 (admin, content, welcome post, demo users)

   Conventions
     - Procedures that can fail for an EXPECTED reason return a one-row
       result set whose first column is ResultCode (0 = OK). The code
       meanings are written above each procedure.
     - Content INSERT procedures return the new id (column NewId).
       Content UPDATE / DELETE procedures return rows affected (column Affected).
     - Image path parameters on UPDATE procedures: NULL = keep current path.
     - Passwords are hashed here: SHA2_256(password + salt), salt = NEWID().
   ===================================================================== */

USE PersonalPortfolioDB;
GO

/* =====================================================================
   A. SCHEMA ADJUSTMENT
   Elementary / junior high years are not known yet, so StartYear must
   be allowed to be NULL. CK_Education_Years still works with NULL.
   ===================================================================== */
IF EXISTS (SELECT 1 FROM sys.columns
           WHERE object_id = OBJECT_ID(N'dbo.Education')
             AND name = N'StartYear' AND is_nullable = 0)
    ALTER TABLE dbo.Education ALTER COLUMN StartYear SMALLINT NULL;
GO

/* =====================================================================
   B. HELPER FUNCTIONS
   ===================================================================== */
CREATE OR ALTER FUNCTION dbo.fn_HashPassword (@Password NVARCHAR(100), @Salt UNIQUEIDENTIFIER)
RETURNS VARBINARY(32)
AS
BEGIN
    RETURN HASHBYTES('SHA2_256', @Password + CONVERT(NVARCHAR(36), @Salt));
END
GO

CREATE OR ALTER FUNCTION dbo.fn_IsValidUsername (@Username NVARCHAR(50))
RETURNS BIT
AS
BEGIN
    RETURN CASE WHEN @Username IS NOT NULL
                 AND LEN(@Username) BETWEEN 4 AND 50
                 AND @Username NOT LIKE N'%[^A-Za-z0-9_]%'
                THEN 1 ELSE 0 END;
END
GO

CREATE OR ALTER FUNCTION dbo.fn_IsValidEmail (@Email NVARCHAR(100))
RETURNS BIT
AS
BEGIN
    RETURN CASE WHEN @Email IS NOT NULL
                 AND LEN(@Email) BETWEEN 5 AND 100
                 AND @Email NOT LIKE N'%[ ]%'
                 AND @Email LIKE N'_%@_%._%'
                 AND CHARINDEX(N'@', @Email, CHARINDEX(N'@', @Email) + 1) = 0
                THEN 1 ELSE 0 END;
END
GO

CREATE OR ALTER FUNCTION dbo.fn_IsValidPhone (@Phone VARCHAR(11))
RETURNS BIT
AS
BEGIN
    RETURN CASE WHEN @Phone IS NOT NULL
                 AND LEN(@Phone) = 11
                 AND @Phone NOT LIKE '%[^0-9]%'
                 AND @Phone LIKE '09%'
                THEN 1 ELSE 0 END;
END
GO

CREATE OR ALTER FUNCTION dbo.fn_IsStrongPassword (@Password NVARCHAR(100))
RETURNS BIT
AS
BEGIN
    RETURN CASE WHEN @Password IS NOT NULL
                 AND LEN(@Password) >= 8
                 AND PATINDEX(N'%[A-Za-z]%', @Password) > 0
                 AND PATINDEX(N'%[0-9]%', @Password) > 0
                THEN 1 ELSE 0 END;
END
GO

/* =====================================================================
   C. ACCOUNT PROCEDURES
   ===================================================================== */

/* ResultCode: 0 OK | 1 username taken | 2 email taken | 3 invalid input */
CREATE OR ALTER PROCEDURE dbo.usp_User_Register
    @Username NVARCHAR(50),
    @Email    NVARCHAR(100),
    @Phone    VARCHAR(11),
    @Password NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SET @Username = LTRIM(RTRIM(@Username));
    SET @Email    = LTRIM(RTRIM(@Email));
    SET @Phone    = LTRIM(RTRIM(@Phone));

    IF dbo.fn_IsValidUsername(@Username) = 0 OR dbo.fn_IsValidEmail(@Email) = 0
       OR dbo.fn_IsValidPhone(@Phone) = 0   OR dbo.fn_IsStrongPassword(@Password) = 0
    BEGIN
        SELECT 3 AS ResultCode, CAST(NULL AS INT) AS UserId;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM dbo.Users WHERE Username = @Username)
    BEGIN
        SELECT 1 AS ResultCode, CAST(NULL AS INT) AS UserId;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM dbo.Users WHERE Email = @Email)
    BEGIN
        SELECT 2 AS ResultCode, CAST(NULL AS INT) AS UserId;
        RETURN;
    END

    DECLARE @Salt UNIQUEIDENTIFIER = NEWID();

    BEGIN TRY
        INSERT INTO dbo.Users (Username, Email, Phone, PasswordHash, PasswordSalt)
        VALUES (@Username, @Email, @Phone, dbo.fn_HashPassword(@Password, @Salt), @Salt);

        SELECT 0 AS ResultCode, CAST(SCOPE_IDENTITY() AS INT) AS UserId;
    END TRY
    BEGIN CATCH
        -- Two people registering the same name at the same moment: the unique index wins.
        IF ERROR_NUMBER() IN (2601, 2627)
        BEGIN
            SELECT CASE WHEN EXISTS (SELECT 1 FROM dbo.Users WHERE Username = @Username)
                        THEN 1 ELSE 2 END AS ResultCode,
                   CAST(NULL AS INT) AS UserId;
            RETURN;
        END
        ;THROW;
    END CATCH
END
GO

/* ResultCode: 0 OK | 1 invalid credentials | 2 account inactive */
CREATE OR ALTER PROCEDURE dbo.usp_User_Login
    @Identifier NVARCHAR(100),   -- username or email
    @Password   NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UserId INT, @Username NVARCHAR(50), @Role VARCHAR(10), @Status VARCHAR(10),
            @Hash VARBINARY(32), @Salt UNIQUEIDENTIFIER;

    IF @Identifier IS NULL OR @Password IS NULL
    BEGIN
        SELECT 1 AS ResultCode, CAST(NULL AS INT) AS UserId,
               CAST(NULL AS NVARCHAR(50)) AS Username, CAST(NULL AS VARCHAR(10)) AS [Role];
        RETURN;
    END

    SET @Identifier = LTRIM(RTRIM(@Identifier));

    SELECT TOP (1) @UserId = UserId, @Username = Username, @Role = [Role], @Status = [Status],
                   @Hash = PasswordHash, @Salt = PasswordSalt
    FROM   dbo.Users
    WHERE  Username = @Identifier OR Email = @Identifier;

    IF @UserId IS NULL OR @Hash <> dbo.fn_HashPassword(@Password, @Salt)
    BEGIN
        SELECT 1 AS ResultCode, CAST(NULL AS INT) AS UserId,
               CAST(NULL AS NVARCHAR(50)) AS Username, CAST(NULL AS VARCHAR(10)) AS [Role];
        RETURN;
    END

    IF @Status <> 'Active'
    BEGIN
        SELECT 2 AS ResultCode, CAST(NULL AS INT) AS UserId,
               CAST(NULL AS NVARCHAR(50)) AS Username, CAST(NULL AS VARCHAR(10)) AS [Role];
        RETURN;
    END

    UPDATE dbo.Users SET LastLoginAt = SYSDATETIME() WHERE UserId = @UserId;

    SELECT 0 AS ResultCode, @UserId AS UserId, @Username AS Username, @Role AS [Role];
END
GO

/* Account details. Never returns the hash or salt. Also used to confirm Status on each request. */
CREATE OR ALTER PROCEDURE dbo.usp_User_GetById
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT UserId, Username, Email, Phone, [Role], [Status], CreatedAt, LastLoginAt
    FROM   dbo.Users
    WHERE  UserId = @UserId;
END
GO

/* ResultCode: 0 OK | 1 email taken | 2 user not found | 3 invalid input */
CREATE OR ALTER PROCEDURE dbo.usp_User_UpdateAccount
    @UserId INT,
    @Email  NVARCHAR(100),
    @Phone  VARCHAR(11)
AS
BEGIN
    SET NOCOUNT ON;

    SET @Email = LTRIM(RTRIM(@Email));
    SET @Phone = LTRIM(RTRIM(@Phone));

    IF dbo.fn_IsValidEmail(@Email) = 0 OR dbo.fn_IsValidPhone(@Phone) = 0
    BEGIN
        SELECT 3 AS ResultCode;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE UserId = @UserId)
    BEGIN
        SELECT 2 AS ResultCode;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM dbo.Users WHERE Email = @Email AND UserId <> @UserId)
    BEGIN
        SELECT 1 AS ResultCode;
        RETURN;
    END

    BEGIN TRY
        UPDATE dbo.Users SET Email = @Email, Phone = @Phone WHERE UserId = @UserId;
        SELECT 0 AS ResultCode;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
        BEGIN
            SELECT 1 AS ResultCode;
            RETURN;
        END
        ;THROW;
    END CATCH
END
GO

/* ResultCode: 0 OK | 1 current password wrong | 2 user not found | 3 new password too weak */
CREATE OR ALTER PROCEDURE dbo.usp_User_ChangePassword
    @UserId          INT,
    @CurrentPassword NVARCHAR(100),
    @NewPassword     NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Hash VARBINARY(32), @Salt UNIQUEIDENTIFIER;

    SELECT @Hash = PasswordHash, @Salt = PasswordSalt
    FROM   dbo.Users
    WHERE  UserId = @UserId;

    IF @Hash IS NULL
    BEGIN
        SELECT 2 AS ResultCode;
        RETURN;
    END

    IF @CurrentPassword IS NULL OR @Hash <> dbo.fn_HashPassword(@CurrentPassword, @Salt)
    BEGIN
        SELECT 1 AS ResultCode;
        RETURN;
    END

    IF dbo.fn_IsStrongPassword(@NewPassword) = 0
    BEGIN
        SELECT 3 AS ResultCode;
        RETURN;
    END

    DECLARE @NewSalt UNIQUEIDENTIFIER = NEWID();

    UPDATE dbo.Users
    SET    PasswordSalt = @NewSalt,
           PasswordHash = dbo.fn_HashPassword(@NewPassword, @NewSalt)
    WHERE  UserId = @UserId;

    SELECT 0 AS ResultCode;
END
GO

/* =====================================================================
   D. ADMIN USER MANAGEMENT
   ===================================================================== */

/* Account information only. No password data is ever returned. */
CREATE OR ALTER PROCEDURE dbo.usp_Admin_GetUsers
    @Search NVARCHAR(100) = NULL,
    @Status VARCHAR(10)   = NULL     -- 'Active', 'Inactive' or NULL for all
AS
BEGIN
    SET NOCOUNT ON;

    SET @Search = NULLIF(LTRIM(RTRIM(@Search)), N'');
    SET @Status = NULLIF(LTRIM(RTRIM(@Status)), '');

    SELECT UserId, Username, Email, Phone, [Role], [Status], CreatedAt, LastLoginAt
    FROM   dbo.Users
    WHERE  (@Status IS NULL OR [Status] = @Status)
      AND  (@Search IS NULL
            OR CHARINDEX(@Search, Username) > 0
            OR CHARINDEX(@Search, Email)    > 0
            OR CHARINDEX(@Search, Phone)    > 0)
    ORDER BY CreatedAt DESC, UserId DESC;
END
GO

/* ResultCode: 0 OK | 1 user not found | 2 cannot act on yourself
               3 cannot act on an Admin | 4 invalid status | 5 caller is not an active Admin */
CREATE OR ALTER PROCEDURE dbo.usp_Admin_SetUserStatus
    @ActingAdminId INT,
    @UserId        INT,
    @Status        VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    IF @Status NOT IN ('Active', 'Inactive')
    BEGIN
        SELECT 4 AS ResultCode;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.Users
                   WHERE UserId = @ActingAdminId AND [Role] = 'Admin' AND [Status] = 'Active')
    BEGIN
        SELECT 5 AS ResultCode;
        RETURN;
    END

    IF @UserId = @ActingAdminId
    BEGIN
        SELECT 2 AS ResultCode;
        RETURN;
    END

    DECLARE @TargetRole VARCHAR(10);
    SELECT @TargetRole = [Role] FROM dbo.Users WHERE UserId = @UserId;

    IF @TargetRole IS NULL
    BEGIN
        SELECT 1 AS ResultCode;
        RETURN;
    END

    IF @TargetRole = 'Admin'
    BEGIN
        SELECT 3 AS ResultCode;
        RETURN;
    END

    UPDATE dbo.Users SET [Status] = @Status WHERE UserId = @UserId;
    SELECT 0 AS ResultCode;
END
GO

/* ResultCode: 0 OK | 1 user not found | 2 cannot act on yourself
               3 cannot act on an Admin | 5 caller is not an active Admin */
CREATE OR ALTER PROCEDURE dbo.usp_Admin_DeleteUser
    @ActingAdminId INT,
    @UserId        INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Users
                   WHERE UserId = @ActingAdminId AND [Role] = 'Admin' AND [Status] = 'Active')
    BEGIN
        SELECT 5 AS ResultCode;
        RETURN;
    END

    IF @UserId = @ActingAdminId
    BEGIN
        SELECT 2 AS ResultCode;
        RETURN;
    END

    DECLARE @TargetRole VARCHAR(10);
    SELECT @TargetRole = [Role] FROM dbo.Users WHERE UserId = @UserId;

    IF @TargetRole IS NULL
    BEGIN
        SELECT 1 AS ResultCode;
        RETURN;
    END

    IF @TargetRole = 'Admin'
    BEGIN
        SELECT 3 AS ResultCode;
        RETURN;
    END

    BEGIN TRANSACTION;
        -- Only Admins author posts, so a normal user never owns rows elsewhere.
        DELETE FROM dbo.Users WHERE UserId = @UserId AND [Role] = 'User';
    COMMIT TRANSACTION;

    SELECT 0 AS ResultCode;
END
GO

/* =====================================================================
   E. WEBSITE CONTENT (owner's content, edited only by the Admin)
   Required-text problems raise error 50001 (a programming/validation
   error the C# layer catches and shows as a friendly message).
   ===================================================================== */

/* ---------- PersonalInfo (single row) ---------- */
CREATE OR ALTER PROCEDURE dbo.usp_PersonalInfo_Get
AS
BEGIN
    SET NOCOUNT ON;

    SELECT PersonalInfoId, FullName, Tagline, Bio, Email, Phone, [Address],
           GitHubUrl, LinkedInUrl, AvatarPath, UpdatedAt
    FROM   dbo.PersonalInfo
    WHERE  PersonalInfoId = 1;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_PersonalInfo_Update
    @FullName    NVARCHAR(100),
    @Tagline     NVARCHAR(200) = NULL,
    @Bio         NVARCHAR(MAX) = NULL,
    @Email       NVARCHAR(100) = NULL,
    @Phone       VARCHAR(20)   = NULL,
    @Address     NVARCHAR(250) = NULL,
    @GitHubUrl   NVARCHAR(250) = NULL,
    @LinkedInUrl NVARCHAR(250) = NULL,
    @AvatarPath  NVARCHAR(260) = NULL      -- NULL = keep current avatar
AS
BEGIN
    SET NOCOUNT ON;

    IF LEN(LTRIM(RTRIM(ISNULL(@FullName, N'')))) = 0
        THROW 50001, 'Full name is required.', 1;

    IF EXISTS (SELECT 1 FROM dbo.PersonalInfo WHERE PersonalInfoId = 1)
        UPDATE dbo.PersonalInfo
        SET    FullName    = LTRIM(RTRIM(@FullName)),
               Tagline     = @Tagline,
               Bio         = @Bio,
               Email       = @Email,
               Phone       = @Phone,
               [Address]   = @Address,
               GitHubUrl   = @GitHubUrl,
               LinkedInUrl = @LinkedInUrl,
               AvatarPath  = ISNULL(@AvatarPath, AvatarPath),
               UpdatedAt   = SYSDATETIME()
        WHERE  PersonalInfoId = 1;
    ELSE
        INSERT INTO dbo.PersonalInfo (FullName, Tagline, Bio, Email, Phone, [Address], GitHubUrl, LinkedInUrl, AvatarPath)
        VALUES (LTRIM(RTRIM(@FullName)), @Tagline, @Bio, @Email, @Phone, @Address, @GitHubUrl, @LinkedInUrl, @AvatarPath);

    SELECT 1 AS Affected;
END
GO

/* ---------- Education ---------- */
CREATE OR ALTER PROCEDURE dbo.usp_Education_GetAll
AS
BEGIN
    SET NOCOUNT ON;

    SELECT EducationId, SchoolName, [Level], Program, StartYear, EndYear,
           [Description], PhotoPath, SortOrder
    FROM   dbo.Education
    ORDER BY SortOrder, EducationId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Education_GetById
    @EducationId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT EducationId, SchoolName, [Level], Program, StartYear, EndYear,
           [Description], PhotoPath, SortOrder
    FROM   dbo.Education
    WHERE  EducationId = @EducationId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Education_Insert
    @SchoolName  NVARCHAR(150),
    @Level       NVARCHAR(50),
    @Program     NVARCHAR(150) = NULL,
    @StartYear   SMALLINT      = NULL,
    @EndYear     SMALLINT      = NULL,
    @Description NVARCHAR(MAX) = NULL,
    @PhotoPath   NVARCHAR(260) = NULL,
    @SortOrder   INT           = NULL      -- NULL = place last
AS
BEGIN
    SET NOCOUNT ON;

    IF LEN(LTRIM(RTRIM(ISNULL(@SchoolName, N'')))) = 0 OR LEN(LTRIM(RTRIM(ISNULL(@Level, N'')))) = 0
        THROW 50001, 'School name and level are required.', 1;

    INSERT INTO dbo.Education (SchoolName, [Level], Program, StartYear, EndYear, [Description], PhotoPath, SortOrder)
    VALUES (LTRIM(RTRIM(@SchoolName)), LTRIM(RTRIM(@Level)), @Program, @StartYear, @EndYear, @Description, @PhotoPath,
            ISNULL(@SortOrder, (SELECT ISNULL(MAX(SortOrder), 0) + 10 FROM dbo.Education)));

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS NewId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Education_Update
    @EducationId INT,
    @SchoolName  NVARCHAR(150),
    @Level       NVARCHAR(50),
    @Program     NVARCHAR(150) = NULL,
    @StartYear   SMALLINT      = NULL,
    @EndYear     SMALLINT      = NULL,
    @Description NVARCHAR(MAX) = NULL,
    @PhotoPath   NVARCHAR(260) = NULL,     -- NULL = keep current photo
    @SortOrder   INT           = NULL      -- NULL = keep current order
AS
BEGIN
    SET NOCOUNT ON;

    IF LEN(LTRIM(RTRIM(ISNULL(@SchoolName, N'')))) = 0 OR LEN(LTRIM(RTRIM(ISNULL(@Level, N'')))) = 0
        THROW 50001, 'School name and level are required.', 1;

    UPDATE dbo.Education
    SET    SchoolName    = LTRIM(RTRIM(@SchoolName)),
           [Level]       = LTRIM(RTRIM(@Level)),
           Program       = @Program,
           StartYear     = @StartYear,
           EndYear       = @EndYear,
           [Description] = @Description,
           PhotoPath     = ISNULL(@PhotoPath, PhotoPath),
           SortOrder     = ISNULL(@SortOrder, SortOrder)
    WHERE  EducationId = @EducationId;

    SELECT @@ROWCOUNT AS Affected;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Education_Delete
    @EducationId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.Education WHERE EducationId = @EducationId;
    SELECT @@ROWCOUNT AS Affected;
END
GO

/* ---------- Skills (Category: Frontend / Backend / Tools) ---------- */
CREATE OR ALTER PROCEDURE dbo.usp_Skill_GetAll
    @Category VARCHAR(20) = NULL           -- NULL = every category
AS
BEGIN
    SET NOCOUNT ON;

    SELECT SkillId, [Name], Category, [Description], SortOrder
    FROM   dbo.Skills
    WHERE  @Category IS NULL OR Category = @Category
    ORDER BY SortOrder, SkillId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Skill_GetById
    @SkillId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT SkillId, [Name], Category, [Description], SortOrder
    FROM   dbo.Skills
    WHERE  SkillId = @SkillId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Skill_Insert
    @Name        NVARCHAR(100),
    @Category    VARCHAR(20),
    @Description NVARCHAR(MAX) = NULL,
    @SortOrder   INT           = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF LEN(LTRIM(RTRIM(ISNULL(@Name, N'')))) = 0
        THROW 50001, 'Skill name is required.', 1;
    IF @Category NOT IN ('Frontend', 'Backend', 'Tools')
        THROW 50001, 'Category must be Frontend, Backend or Tools.', 1;

    INSERT INTO dbo.Skills ([Name], Category, [Description], SortOrder)
    VALUES (LTRIM(RTRIM(@Name)), @Category, @Description,
            ISNULL(@SortOrder, (SELECT ISNULL(MAX(SortOrder), 0) + 10 FROM dbo.Skills)));

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS NewId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Skill_Update
    @SkillId     INT,
    @Name        NVARCHAR(100),
    @Category    VARCHAR(20),
    @Description NVARCHAR(MAX) = NULL,
    @SortOrder   INT           = NULL      -- NULL = keep current order
AS
BEGIN
    SET NOCOUNT ON;

    IF LEN(LTRIM(RTRIM(ISNULL(@Name, N'')))) = 0
        THROW 50001, 'Skill name is required.', 1;
    IF @Category NOT IN ('Frontend', 'Backend', 'Tools')
        THROW 50001, 'Category must be Frontend, Backend or Tools.', 1;

    UPDATE dbo.Skills
    SET    [Name]        = LTRIM(RTRIM(@Name)),
           Category      = @Category,
           [Description] = @Description,
           SortOrder     = ISNULL(@SortOrder, SortOrder)
    WHERE  SkillId = @SkillId;

    SELECT @@ROWCOUNT AS Affected;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Skill_Delete
    @SkillId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.Skills WHERE SkillId = @SkillId;
    SELECT @@ROWCOUNT AS Affected;
END
GO

/* ---------- Hobbies & Interest ---------- */
CREATE OR ALTER PROCEDURE dbo.usp_Hobby_GetAll
AS
BEGIN
    SET NOCOUNT ON;

    SELECT HobbyId, Title, [Description], ImagePath, SortOrder
    FROM   dbo.Hobbies
    ORDER BY SortOrder, HobbyId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Hobby_GetById
    @HobbyId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT HobbyId, Title, [Description], ImagePath, SortOrder
    FROM   dbo.Hobbies
    WHERE  HobbyId = @HobbyId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Hobby_Insert
    @Title       NVARCHAR(100),
    @Description NVARCHAR(500) = NULL,
    @ImagePath   NVARCHAR(260) = NULL,
    @SortOrder   INT           = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF LEN(LTRIM(RTRIM(ISNULL(@Title, N'')))) = 0
        THROW 50001, 'Title is required.', 1;

    INSERT INTO dbo.Hobbies (Title, [Description], ImagePath, SortOrder)
    VALUES (LTRIM(RTRIM(@Title)), @Description, @ImagePath,
            ISNULL(@SortOrder, (SELECT ISNULL(MAX(SortOrder), 0) + 10 FROM dbo.Hobbies)));

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS NewId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Hobby_Update
    @HobbyId     INT,
    @Title       NVARCHAR(100),
    @Description NVARCHAR(500) = NULL,
    @ImagePath   NVARCHAR(260) = NULL,     -- NULL = keep current image
    @SortOrder   INT           = NULL      -- NULL = keep current order
AS
BEGIN
    SET NOCOUNT ON;

    IF LEN(LTRIM(RTRIM(ISNULL(@Title, N'')))) = 0
        THROW 50001, 'Title is required.', 1;

    UPDATE dbo.Hobbies
    SET    Title         = LTRIM(RTRIM(@Title)),
           [Description] = @Description,
           ImagePath     = ISNULL(@ImagePath, ImagePath),
           SortOrder     = ISNULL(@SortOrder, SortOrder)
    WHERE  HobbyId = @HobbyId;

    SELECT @@ROWCOUNT AS Affected;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Hobby_Delete
    @HobbyId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.Hobbies WHERE HobbyId = @HobbyId;
    SELECT @@ROWCOUNT AS Affected;
END
GO

/* ---------- Recent Projects ---------- */
CREATE OR ALTER PROCEDURE dbo.usp_Project_GetAll
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ProjectId, Title, TechStack, [Role], Details, RepoUrl, SortOrder
    FROM   dbo.Projects
    ORDER BY SortOrder, ProjectId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Project_GetById
    @ProjectId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ProjectId, Title, TechStack, [Role], Details, RepoUrl, SortOrder
    FROM   dbo.Projects
    WHERE  ProjectId = @ProjectId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Project_Insert
    @Title     NVARCHAR(150),
    @TechStack NVARCHAR(250) = NULL,
    @Role      NVARCHAR(100) = NULL,
    @Details   NVARCHAR(MAX) = NULL,
    @RepoUrl   NVARCHAR(250) = NULL,
    @SortOrder INT           = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF LEN(LTRIM(RTRIM(ISNULL(@Title, N'')))) = 0
        THROW 50001, 'Project title is required.', 1;

    INSERT INTO dbo.Projects (Title, TechStack, [Role], Details, RepoUrl, SortOrder)
    VALUES (LTRIM(RTRIM(@Title)), @TechStack, @Role, @Details, @RepoUrl,
            ISNULL(@SortOrder, (SELECT ISNULL(MAX(SortOrder), 0) + 10 FROM dbo.Projects)));

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS NewId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Project_Update
    @ProjectId INT,
    @Title     NVARCHAR(150),
    @TechStack NVARCHAR(250) = NULL,
    @Role      NVARCHAR(100) = NULL,
    @Details   NVARCHAR(MAX) = NULL,
    @RepoUrl   NVARCHAR(250) = NULL,
    @SortOrder INT           = NULL        -- NULL = keep current order
AS
BEGIN
    SET NOCOUNT ON;

    IF LEN(LTRIM(RTRIM(ISNULL(@Title, N'')))) = 0
        THROW 50001, 'Project title is required.', 1;

    UPDATE dbo.Projects
    SET    Title     = LTRIM(RTRIM(@Title)),
           TechStack = @TechStack,
           [Role]    = @Role,
           Details   = @Details,
           RepoUrl   = @RepoUrl,
           SortOrder = ISNULL(@SortOrder, SortOrder)
    WHERE  ProjectId = @ProjectId;

    SELECT @@ROWCOUNT AS Affected;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Project_Delete
    @ProjectId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.Projects WHERE ProjectId = @ProjectId;
    SELECT @@ROWCOUNT AS Affected;
END
GO

/* ---------- Gallery ---------- */
CREATE OR ALTER PROCEDURE dbo.usp_Gallery_GetAll
AS
BEGIN
    SET NOCOUNT ON;

    SELECT GalleryId, ImagePath, Caption, SortOrder
    FROM   dbo.GalleryItems
    ORDER BY SortOrder, GalleryId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Gallery_GetById
    @GalleryId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT GalleryId, ImagePath, Caption, SortOrder
    FROM   dbo.GalleryItems
    WHERE  GalleryId = @GalleryId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Gallery_Insert
    @ImagePath NVARCHAR(260),
    @Caption   NVARCHAR(200) = NULL,
    @SortOrder INT           = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF LEN(LTRIM(RTRIM(ISNULL(@ImagePath, N'')))) = 0
        THROW 50001, 'An image is required.', 1;

    INSERT INTO dbo.GalleryItems (ImagePath, Caption, SortOrder)
    VALUES (@ImagePath, @Caption,
            ISNULL(@SortOrder, (SELECT ISNULL(MAX(SortOrder), 0) + 10 FROM dbo.GalleryItems)));

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS NewId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Gallery_Update
    @GalleryId INT,
    @Caption   NVARCHAR(200) = NULL,
    @ImagePath NVARCHAR(260) = NULL,       -- NULL = keep current image
    @SortOrder INT           = NULL        -- NULL = keep current order
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.GalleryItems
    SET    Caption   = @Caption,
           ImagePath = ISNULL(@ImagePath, ImagePath),
           SortOrder = ISNULL(@SortOrder, SortOrder)
    WHERE  GalleryId = @GalleryId;

    SELECT @@ROWCOUNT AS Affected;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Gallery_Delete
    @GalleryId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.GalleryItems WHERE GalleryId = @GalleryId;
    SELECT @@ROWCOUNT AS Affected;
END
GO

/* =====================================================================
   F. ANNOUNCEMENTS (written by the Admin, read by every logged-in user)
   ===================================================================== */
CREATE OR ALTER PROCEDURE dbo.usp_Post_GetPublished
AS
BEGIN
    SET NOCOUNT ON;

    SELECT p.PostId, p.Title, p.Body, p.IsPublished, p.CreatedAt, p.UpdatedAt,
           u.Username AS AuthorName
    FROM   dbo.Posts p
    JOIN   dbo.Users u ON u.UserId = p.AuthorId
    WHERE  p.IsPublished = 1
    ORDER BY p.CreatedAt DESC, p.PostId DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Post_GetAll
AS
BEGIN
    SET NOCOUNT ON;

    SELECT p.PostId, p.Title, p.Body, p.IsPublished, p.CreatedAt, p.UpdatedAt,
           u.Username AS AuthorName
    FROM   dbo.Posts p
    JOIN   dbo.Users u ON u.UserId = p.AuthorId
    ORDER BY p.CreatedAt DESC, p.PostId DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Post_GetById
    @PostId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT p.PostId, p.Title, p.Body, p.IsPublished, p.CreatedAt, p.UpdatedAt,
           u.Username AS AuthorName
    FROM   dbo.Posts p
    JOIN   dbo.Users u ON u.UserId = p.AuthorId
    WHERE  p.PostId = @PostId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Post_Insert
    @Title       NVARCHAR(150),
    @Body        NVARCHAR(MAX),
    @IsPublished BIT = 0,
    @AuthorId    INT
AS
BEGIN
    SET NOCOUNT ON;

    IF LEN(LTRIM(RTRIM(ISNULL(@Title, N'')))) = 0 OR LEN(LTRIM(RTRIM(ISNULL(@Body, N'')))) = 0
        THROW 50001, 'Title and message are required.', 1;

    INSERT INTO dbo.Posts (Title, Body, IsPublished, AuthorId)
    VALUES (LTRIM(RTRIM(@Title)), @Body, @IsPublished, @AuthorId);

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS NewId;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Post_Update
    @PostId      INT,
    @Title       NVARCHAR(150),
    @Body        NVARCHAR(MAX),
    @IsPublished BIT
AS
BEGIN
    SET NOCOUNT ON;

    IF LEN(LTRIM(RTRIM(ISNULL(@Title, N'')))) = 0 OR LEN(LTRIM(RTRIM(ISNULL(@Body, N'')))) = 0
        THROW 50001, 'Title and message are required.', 1;

    UPDATE dbo.Posts
    SET    Title       = LTRIM(RTRIM(@Title)),
           Body        = @Body,
           IsPublished = @IsPublished,
           UpdatedAt   = SYSDATETIME()
    WHERE  PostId = @PostId;

    SELECT @@ROWCOUNT AS Affected;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Post_SetPublished
    @PostId      INT,
    @IsPublished BIT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Posts
    SET    IsPublished = @IsPublished,
           UpdatedAt   = SYSDATETIME()
    WHERE  PostId = @PostId;

    SELECT @@ROWCOUNT AS Affected;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Post_Delete
    @PostId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.Posts WHERE PostId = @PostId;
    SELECT @@ROWCOUNT AS Affected;
END
GO

/* =====================================================================
   G. REPORTS
   ===================================================================== */
CREATE OR ALTER PROCEDURE dbo.usp_Report_UserSummary
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MonthStart DATE = DATEFROMPARTS(YEAR(SYSDATETIME()), MONTH(SYSDATETIME()), 1);

    SELECT COUNT(*)                                                    AS TotalUsers,
           ISNULL(SUM(CASE WHEN [Status] = 'Active'   THEN 1 ELSE 0 END), 0) AS ActiveUsers,
           ISNULL(SUM(CASE WHEN [Status] = 'Inactive' THEN 1 ELSE 0 END), 0) AS InactiveUsers,
           ISNULL(SUM(CASE WHEN [Role]   = 'Admin'    THEN 1 ELSE 0 END), 0) AS AdminUsers,
           ISNULL(SUM(CASE WHEN CreatedAt >= @MonthStart THEN 1 ELSE 0 END), 0) AS NewThisMonth
    FROM   dbo.Users;
END
GO

/* Last 12 months (oldest first), including months with zero signups. */
CREATE OR ALTER PROCEDURE dbo.usp_Report_SignupsByMonth
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ThisMonth DATE = DATEFROMPARTS(YEAR(SYSDATETIME()), MONTH(SYSDATETIME()), 1);

    ;WITH Months AS
    (
        SELECT DATEADD(MONTH, -11, @ThisMonth) AS MonthStart
        UNION ALL
        SELECT DATEADD(MONTH, 1, MonthStart) FROM Months WHERE MonthStart < @ThisMonth
    )
    SELECT m.MonthStart,
           LEFT(DATENAME(MONTH, m.MonthStart), 3) + N' ' + CAST(YEAR(m.MonthStart) AS NVARCHAR(4)) AS Label,
           COUNT(u.UserId) AS Signups
    FROM   Months m
    LEFT JOIN dbo.Users u
           ON u.CreatedAt >= m.MonthStart
          AND u.CreatedAt <  DATEADD(MONTH, 1, m.MonthStart)
    GROUP BY m.MonthStart
    ORDER BY m.MonthStart;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Report_RecentUsers
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (5) UserId, Username, Email, [Role], [Status], CreatedAt
    FROM   dbo.Users
    ORDER BY CreatedAt DESC, UserId DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Report_ContentSummary
AS
BEGIN
    SET NOCOUNT ON;

    SELECT N'Education'              AS Section, COUNT(*) AS Items FROM dbo.Education
    UNION ALL SELECT N'Skills',                  COUNT(*) FROM dbo.Skills
    UNION ALL SELECT N'Hobbies & Interest',      COUNT(*) FROM dbo.Hobbies
    UNION ALL SELECT N'Recent Projects',         COUNT(*) FROM dbo.Projects
    UNION ALL SELECT N'Gallery',                 COUNT(*) FROM dbo.GalleryItems
    UNION ALL SELECT N'Announcements (published)', COUNT(*) FROM dbo.Posts WHERE IsPublished = 1
    UNION ALL SELECT N'Announcements (draft)',     COUNT(*) FROM dbo.Posts WHERE IsPublished = 0;
END
GO

/* =====================================================================
   H. SEED DATA
   Text placeholders used below and replaced while inserting:
     {m} = em dash    {d} = middle dot
   Image paths point to the existing Media folder. Uploads made later
   from the Admin page are saved under 24-1571GuadesPersonalPortfolio_Uploads/.
   ===================================================================== */

/* ---- H1. Admin account: admin / Admin_123 (change it in My Account) ---- */
DECLARE @AdminSalt UNIQUEIDENTIFIER = NEWID();

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Username = N'admin')
    INSERT INTO dbo.Users (Username, Email, Phone, PasswordHash, PasswordSalt, [Role], [Status])
    VALUES (N'admin', N'admin@gmail.com', '09123456789',
            dbo.fn_HashPassword(N'Admin_123', @AdminSalt), @AdminSalt, 'Admin', 'Active');
GO

/* ---- H2. Personal information (single row) ---- */
IF NOT EXISTS (SELECT 1 FROM dbo.PersonalInfo)
    INSERT INTO dbo.PersonalInfo (FullName, Tagline, Bio, Email, Phone, [Address], GitHubUrl, LinkedInUrl, AvatarPath)
    VALUES (
        N'Mark Rafael L. Guades',
        REPLACE(N'Bachelor of Science in Information Technology {d} Building since 2024', N'{d}', NCHAR(183)),
        REPLACE(N'I''m an Information Technology student who enjoys turning rough ideas into working software, from small ASP.NET Web Forms tools to full MVC apps with a database behind them. I like problems that mix logic and interface design {m} getting the back-end data right and making it easy for someone else to actually use.', N'{m}', NCHAR(8212)),
        N'guadesmarkrafaellim@gmail.com',
        '09240169431',
        N'#37 Tandang Sora Avenue, Talipapa, Quezon City',
        N'https://github.com/UltimateFury26',
        N'https://www.linkedin.com/in/mark-rafael-guades-924099436/',
        N'24-1571GuadesPersonalPortfolio_Media/headshot.jpg');
GO

/* ---- H3. Education (Lanting from elementary to senior high, then QCU) ----
   Years for Elementary and Junior High are left empty until the owner
   supplies them (the Admin can fill them in). Empty years are hidden.   */
INSERT INTO dbo.Education (SchoolName, [Level], Program, StartYear, EndYear, PhotoPath, SortOrder)
SELECT v.SchoolName, v.[Level], v.Program, v.StartYear, v.EndYear, v.PhotoPath, v.SortOrder
FROM (VALUES
    (N'Dr. Carlos S. Lanting College', N'Elementary',          CAST(NULL AS NVARCHAR(150)),                       CAST(NULL AS SMALLINT), CAST(NULL AS SMALLINT), CAST(NULL AS NVARCHAR(260)), 10),
    (N'Dr. Carlos S. Lanting College', N'Junior High School',  CAST(NULL AS NVARCHAR(150)),                       CAST(NULL AS SMALLINT), CAST(NULL AS SMALLINT), CAST(NULL AS NVARCHAR(260)), 20),
    (N'Dr. Carlos S. Lanting College', N'Senior High School',  CAST(NULL AS NVARCHAR(150)),                       CAST(2022 AS SMALLINT), CAST(2024 AS SMALLINT), N'24-1571GuadesPersonalPortfolio_Media/senior-high.jpg', 30),
    (N'Quezon City University',        N'College',             N'Bachelor of Science in Information Technology', CAST(2024 AS SMALLINT), CAST(2028 AS SMALLINT), N'24-1571GuadesPersonalPortfolio_Media/college.jpg',     40)
) AS v (SchoolName, [Level], Program, StartYear, EndYear, PhotoPath, SortOrder)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Education e
                  WHERE e.SchoolName = v.SchoolName AND e.[Level] = v.[Level]);
GO

/* ---- H4. Skills (descriptions carried over from the static page) ---- */
INSERT INTO dbo.Skills ([Name], Category, [Description], SortOrder)
SELECT v.[Name], v.Category, REPLACE(v.[Description], N'{m}', NCHAR(8212)), v.SortOrder
FROM (VALUES
    (N'HTML / CSS',      'Frontend', N'Comfortable building layouts from scratch {m} grids, flexbox, responsive breakpoints, and custom components without relying on a framework. This portfolio itself is the clearest example: the board grid, masonry section, and modal system are all hand-written CSS.', 10),
    (N'JavaScript',      'Frontend', N'Solid with vanilla DOM scripting for interactive UI {m} event handling, state toggling, and keeping interactions consistent across a page. Used it to build every modal, the lightbox, and the scrollspy nav on this portfolio, all without any external library.', 20),
    (N'C# / ASP.NET',    'Backend',  N'Experienced with both Web Forms and MVC. Built a fully working calculator in Web Forms with all logic in code-behind and state persisted through ViewState, and separately built Pawchase, a multi-page MVC e-commerce app with product listings, reviews, and an admin dashboard.', 30),
    (N'SQL',             'Backend',  N'Able to write the queries an app actually needs {m} selects with joins, inserts, and updates against a live database rather than just theory. In Pawchase, I wrote raw MySQL queries through MySqlCommand to load products, variants, orders, and reviews for the storefront and admin pages.', 40),
    (N'Git / GitHub',    'Tools',    N'Comfortable with the everyday workflow {m} commits, branches, and pushing to a remote {m} and have worked through real merge conflicts, not just clean pushes. Pawchase was version-controlled on GitHub and involved resolving conflicting changes across the same files while collaborating.', 50),
    (N'Visual Studio',   'Tools',    N'My main IDE for coursework {m} used it across Web Forms, MVC, and Windows Forms (VB.NET) projects, including debugging, the designer tools, and managing solution/project structure. Every project in my portfolio, including this site, was built and run in Visual Studio 2026.', 60)
) AS v ([Name], Category, [Description], SortOrder)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Skills s WHERE s.[Name] = v.[Name]);
GO

/* ---- H5. Hobbies & Interest ----
   Titles are temporary ("Interest 1" ...). Rename them, add descriptions,
   or replace the photos from Admin > Manage Content > Hobbies.            */
INSERT INTO dbo.Hobbies (Title, ImagePath, SortOrder)
SELECT v.Title, v.ImagePath, v.SortOrder
FROM (VALUES
    (N'Interest 1', N'24-1571GuadesPersonalPortfolio_Media/interest-1.jpg', 10),
    (N'Interest 2', N'24-1571GuadesPersonalPortfolio_Media/interest-2.jpg', 20),
    (N'Interest 3', N'24-1571GuadesPersonalPortfolio_Media/interest-3.jpg', 30),
    (N'Interest 4', N'24-1571GuadesPersonalPortfolio_Media/interest-4.jpg', 40),
    (N'Interest 5', N'24-1571GuadesPersonalPortfolio_Media/interest-5.jpg', 50),
    (N'Interest 6', N'24-1571GuadesPersonalPortfolio_Media/interest-6.jpg', 60)
) AS v (Title, ImagePath, SortOrder)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Hobbies h WHERE h.ImagePath = v.ImagePath);
GO

/* ---- H6. Recent Projects (only facts already stated on the static page) ---- */
INSERT INTO dbo.Projects (Title, TechStack, [Role], Details, RepoUrl, SortOrder)
SELECT v.Title, v.TechStack, v.[Role], v.Details, v.RepoUrl, v.SortOrder
FROM (VALUES
    (N'Pawchase',
     N'ASP.NET MVC, C#, MySQL, GitHub',
     CAST(NULL AS NVARCHAR(100)),
     N'A multi-page e-commerce app with product listings, reviews, and an admin dashboard, backed by a MySQL database. It was version-controlled on GitHub and built collaboratively, which meant resolving merge conflicts across shared files.',
     N'https://github.com/DaVincii636/Pawchase_',
     10),
    (N'Basic Calculator',
     N'ASP.NET Web Forms, C#',
     CAST(NULL AS NVARCHAR(100)),
     N'A fully working calculator built in ASP.NET Web Forms, with all of its logic in the code-behind and its state persisted through ViewState.',
     CAST(NULL AS NVARCHAR(250)),
     20),
    (N'Personal Portfolio Website',
     N'ASP.NET Web Forms, C#, SQL Server, HTML/CSS, JavaScript',
     CAST(NULL AS NVARCHAR(100)),
     N'This website. Built with ASP.NET Web Forms and a SQL Server database using stored procedures, with hand-written HTML and CSS and vanilla JavaScript and no external libraries. Its content is managed by the Admin, and signed-in users view it.',
     CAST(NULL AS NVARCHAR(250)),
     30)
) AS v (Title, TechStack, [Role], Details, RepoUrl, SortOrder)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Projects p WHERE p.Title = v.Title);
GO

/* ---- H7. Gallery ---- */
INSERT INTO dbo.GalleryItems (ImagePath, SortOrder)
SELECT v.ImagePath, v.SortOrder
FROM (VALUES
    (N'24-1571GuadesPersonalPortfolio_Media/gallery-1.jpg', 10),
    (N'24-1571GuadesPersonalPortfolio_Media/gallery-2.jpg', 20),
    (N'24-1571GuadesPersonalPortfolio_Media/gallery-3.jpg', 30),
    (N'24-1571GuadesPersonalPortfolio_Media/gallery-4.jpg', 40),
    (N'24-1571GuadesPersonalPortfolio_Media/gallery-5.jpg', 50),
    (N'24-1571GuadesPersonalPortfolio_Media/gallery-6.jpg', 60)
) AS v (ImagePath, SortOrder)
WHERE NOT EXISTS (SELECT 1 FROM dbo.GalleryItems g WHERE g.ImagePath = v.ImagePath);
GO

/* ---- H8. Welcome announcement (authored by admin, published) ---- */
INSERT INTO dbo.Posts (Title, Body, IsPublished, AuthorId)
SELECT N'Welcome to my portfolio',
       N'Thanks for stopping by! This site brings together my background, skills, projects and interests in one place. Take a look around the boards, and check back here for updates whenever I post something new.',
       1,
       (SELECT UserId FROM dbo.Users WHERE Username = N'admin')
WHERE EXISTS (SELECT 1 FROM dbo.Users WHERE Username = N'admin')
  AND NOT EXISTS (SELECT 1 FROM dbo.Posts WHERE Title = N'Welcome to my portfolio');
GO

/* ---- H9. DEMO USERS (sample data so Reports has numbers) --------------
   All demo accounts use the password  Demo_1234
   Signup dates are spread over the past months; two accounts are Inactive.
   To remove them at any time, run:
       DELETE FROM dbo.Users WHERE Username LIKE 'demo[_]%';
   ----------------------------------------------------------------------- */
INSERT INTO dbo.Users (Username, Email, Phone, PasswordHash, PasswordSalt, [Status], CreatedAt, LastLoginAt)
SELECT v.Username, v.Email, v.Phone, 0x, NEWID(), v.[Status],
       DATEADD(DAY, -v.DaysAgo, SYSDATETIME()),
       CASE WHEN v.[Status] = 'Active' THEN DATEADD(DAY, -v.LastSeenDaysAgo, SYSDATETIME()) END
FROM (VALUES
    (N'demo_ana',   N'demo.ana@example.com',   '09171230001', 'Active',   200, 3),
    (N'demo_ben',   N'demo.ben@example.com',   '09171230002', 'Active',   150, 12),
    (N'demo_carla', N'demo.carla@example.com', '09171230003', 'Active',    95, 1),
    (N'demo_dave',  N'demo.dave@example.com',  '09171230004', 'Inactive',  60, 0),
    (N'demo_ella',  N'demo.ella@example.com',  '09171230005', 'Active',    20, 2),
    (N'demo_felix', N'demo.felix@example.com', '09171230006', 'Inactive',   5, 0)
) AS v (Username, Email, Phone, [Status], DaysAgo, LastSeenDaysAgo)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Users u WHERE u.Username = v.Username);

-- The placeholder hash (0x) is replaced with the real salted hash of Demo_1234.
UPDATE dbo.Users
SET    PasswordHash = dbo.fn_HashPassword(N'Demo_1234', PasswordSalt)
WHERE  Username LIKE N'demo[_]%' AND PasswordHash = 0x;
GO

/* =====================================================================
   CHECKS (run after the script)
   ===================================================================== */
-- 1) Stored procedures created (expect 46)
SELECT COUNT(*) AS StoredProcedures FROM sys.procedures WHERE name LIKE N'usp[_]%';

-- 2) Rows seeded (expect: Users 7, PersonalInfo 1, Education 4, Skills 6,
--    Hobbies 6, Projects 3, Gallery 6, Posts 1)
SELECT (SELECT COUNT(*) FROM dbo.Users)        AS Users,
       (SELECT COUNT(*) FROM dbo.PersonalInfo) AS PersonalInfo,
       (SELECT COUNT(*) FROM dbo.Education)    AS Education,
       (SELECT COUNT(*) FROM dbo.Skills)       AS Skills,
       (SELECT COUNT(*) FROM dbo.Hobbies)      AS Hobbies,
       (SELECT COUNT(*) FROM dbo.Projects)     AS Projects,
       (SELECT COUNT(*) FROM dbo.GalleryItems) AS Gallery,
       (SELECT COUNT(*) FROM dbo.Posts)        AS Posts;

-- 3) Login test (expect ResultCode 0 for the admin, 1 for a wrong password)
EXEC dbo.usp_User_Login N'admin', N'Admin_123';
EXEC dbo.usp_User_Login N'admin', N'wrong-password';
GO

/* #####################################################################
   PART 3 OF 3 — ADD-ON: USER VISIT TRACKING
   ##################################################################### */

/* =====================================================================
   PersonalPortfolioDB - ADD-ON: USER VISIT TRACKING
   IPT102 Online Quiz 1 - Personal Website (ASP.NET Web Forms + MS SQL)

   What this script does
     - Creates dbo.PageVisits if it does not exist yet: one row per time a
       regular User views the portfolio (Home.aspx). Admin visits are never
       recorded, so the Admin looking at their own site never counts.
     - Creates or updates three stored procedures:
         usp_Visit_Record          inserts one visit row (called from Home.aspx)
         usp_Report_VisitSummary   total visits, unique visitors, today, this month
         usp_Report_VisitsByMonth  the last 12 months, including months with zero
     - Is safe to re-run: the table is created only if missing, and the
       procedures use CREATE OR ALTER.

   Run this in SSMS (or Visual Studio's SQL Server Object Explorer) against
   PersonalPortfolioDB, the same way the earlier phase scripts were run.
   ===================================================================== */

USE PersonalPortfolioDB;
GO

/* ---------------------------------------------------------------------
   TABLE: PageVisits
   If a User account is later deleted by the Admin, that user's own visit
   history is deleted with it (ON DELETE CASCADE) rather than blocking the
   deletion. Admin accounts are never deleted, so this never touches them.
   --------------------------------------------------------------------- */
IF OBJECT_ID(N'dbo.PageVisits', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PageVisits
    (
        VisitId    INT IDENTITY(1,1) NOT NULL,
        UserId     INT               NOT NULL,
        VisitedAt  DATETIME2(0)      NOT NULL CONSTRAINT DF_PageVisits_VisitedAt DEFAULT (SYSDATETIME()),

        CONSTRAINT PK_PageVisits      PRIMARY KEY (VisitId),
        CONSTRAINT FK_PageVisits_User FOREIGN KEY (UserId)
            REFERENCES dbo.Users (UserId) ON DELETE CASCADE
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = N'IX_PageVisits_VisitedAt' AND object_id = OBJECT_ID(N'dbo.PageVisits'))
    CREATE INDEX IX_PageVisits_VisitedAt ON dbo.PageVisits (VisitedAt);
GO

/* ---------------------------------------------------------------------
   usp_Visit_Record
   Records one visit for @UserId. The WHERE EXISTS re-checks the account is
   a User (not an Admin) inside SQL itself, the same defence-in-depth used
   elsewhere in this project (e.g. usp_Admin_SetUserStatus): even if this is
   ever called for an Admin by mistake, no row is written.
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE dbo.usp_Visit_Record
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.PageVisits (UserId)
    SELECT @UserId
    WHERE EXISTS (SELECT 1 FROM dbo.Users WHERE UserId = @UserId AND [Role] = 'User');
END
GO

/* ---------------------------------------------------------------------
   usp_Report_VisitSummary
   Total visits, unique visitors, and how many happened today and this month.
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE dbo.usp_Report_VisitSummary
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Today      DATE = CAST(SYSDATETIME() AS DATE);
    DECLARE @MonthStart DATE = DATEFROMPARTS(YEAR(SYSDATETIME()), MONTH(SYSDATETIME()), 1);

    SELECT COUNT(*)                                                                      AS TotalVisits,
           COUNT(DISTINCT UserId)                                                        AS UniqueVisitors,
           ISNULL(SUM(CASE WHEN CAST(VisitedAt AS DATE) = @Today   THEN 1 ELSE 0 END), 0) AS VisitsToday,
           ISNULL(SUM(CASE WHEN VisitedAt >= @MonthStart           THEN 1 ELSE 0 END), 0) AS VisitsThisMonth
    FROM   dbo.PageVisits;
END
GO

/* ---------------------------------------------------------------------
   usp_Report_VisitsByMonth
   Last 12 months (oldest first), including months with zero visits.
   Mirrors usp_Report_SignupsByMonth exactly, against PageVisits instead of Users.
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE dbo.usp_Report_VisitsByMonth
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ThisMonth DATE = DATEFROMPARTS(YEAR(SYSDATETIME()), MONTH(SYSDATETIME()), 1);

    ;WITH Months AS
    (
        SELECT DATEADD(MONTH, -11, @ThisMonth) AS MonthStart
        UNION ALL
        SELECT DATEADD(MONTH, 1, MonthStart) FROM Months WHERE MonthStart < @ThisMonth
    )
    SELECT m.MonthStart,
           LEFT(DATENAME(MONTH, m.MonthStart), 3) + N' ' + CAST(YEAR(m.MonthStart) AS NVARCHAR(4)) AS Label,
           COUNT(v.VisitId) AS Visits
    FROM   Months m
    LEFT JOIN dbo.PageVisits v
           ON v.VisitedAt >= m.MonthStart
          AND v.VisitedAt <  DATEADD(MONTH, 1, m.MonthStart)
    GROUP BY m.MonthStart
    ORDER BY m.MonthStart;
END
GO

/* ---------------------------------------------------------------------
   CHECK: confirms the table and all three procedures exist
   --------------------------------------------------------------------- */
SELECT 'Table'     AS Kind, name AS ObjectName FROM sys.tables     WHERE name = 'PageVisits'
UNION ALL
SELECT 'Procedure' AS Kind, name AS ObjectName FROM sys.procedures WHERE name IN
    ('usp_Visit_Record', 'usp_Report_VisitSummary', 'usp_Report_VisitsByMonth')
ORDER BY Kind, ObjectName;
GO
