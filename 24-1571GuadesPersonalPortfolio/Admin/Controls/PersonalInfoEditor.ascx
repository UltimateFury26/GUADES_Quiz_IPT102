<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="PersonalInfoEditor.ascx.cs" Inherits="_24_1571GuadesPersonalPortfolio.PersonalInfoEditor" %>

<div class="editor-card">
    <h2>Personal Information</h2>
    <p class="editor-intro">This is the website owner's profile. Every signed-in user sees it on Home. It is not the login account.</p>

    <asp:Panel ID="pnlMessage" runat="server" Visible="false" role="alert">
        <asp:Literal ID="litMessage" runat="server" Mode="Encode" />
    </asp:Panel>

    <div class="form-field">
        <asp:Label runat="server" AssociatedControlID="txtFullName" CssClass="form-label" Text="Full name" />
        <asp:TextBox ID="txtFullName" runat="server" CssClass="form-input" MaxLength="100" />
        <asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName"
            Display="Dynamic" CssClass="form-error" ErrorMessage="Enter the full name." ValidationGroup="PersonalInfo" />
    </div>

    <div class="form-field">
        <asp:Label runat="server" AssociatedControlID="txtTagline" CssClass="form-label" Text="Tagline" />
        <asp:TextBox ID="txtTagline" runat="server" CssClass="form-input" MaxLength="200" />
        <p class="form-hint">One short line under the name, such as your course.</p>
    </div>

    <div class="form-field">
        <asp:Label runat="server" AssociatedControlID="txtBio" CssClass="form-label" Text="Bio" />
        <asp:TextBox ID="txtBio" runat="server" CssClass="form-input form-textarea" TextMode="MultiLine" Rows="6" MaxLength="2000" />
        <p class="form-hint">Up to 2000 characters.</p>
    </div>

    <div class="form-row">
        <div class="form-field">
            <asp:Label runat="server" AssociatedControlID="txtEmail" CssClass="form-label" Text="Contact email" />
            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-input" MaxLength="100" TextMode="Email" autocapitalize="none" spellcheck="false" />
            <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail"
                Display="Dynamic" CssClass="form-error" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                ErrorMessage="Enter a valid email, like name@example.com." ValidationGroup="PersonalInfo" />
        </div>

        <div class="form-field">
            <asp:Label runat="server" AssociatedControlID="txtPhone" CssClass="form-label" Text="Contact phone" />
            <asp:TextBox ID="txtPhone" runat="server" CssClass="form-input" MaxLength="20" TextMode="Phone" />
            <asp:RegularExpressionValidator ID="revPhone" runat="server" ControlToValidate="txtPhone"
                Display="Dynamic" CssClass="form-error" ValidationExpression="^[0-9+()\- ]{7,20}$"
                ErrorMessage="Use 7 to 20 digits (spaces, +, - and brackets are fine)." ValidationGroup="PersonalInfo" />
        </div>
    </div>

    <div class="form-field">
        <asp:Label runat="server" AssociatedControlID="txtAddress" CssClass="form-label" Text="Address" />
        <asp:TextBox ID="txtAddress" runat="server" CssClass="form-input" MaxLength="250" />
    </div>

    <div class="form-row">
        <div class="form-field">
            <asp:Label runat="server" AssociatedControlID="txtGitHub" CssClass="form-label" Text="GitHub link" />
            <asp:TextBox ID="txtGitHub" runat="server" CssClass="form-input" MaxLength="250" TextMode="Url" placeholder="https://github.com/username" />
            <asp:RegularExpressionValidator ID="revGitHub" runat="server" ControlToValidate="txtGitHub"
                Display="Dynamic" CssClass="form-error" ValidationExpression="^https?://\S+$"
                ErrorMessage="Start the link with http:// or https://" ValidationGroup="PersonalInfo" />
        </div>

        <div class="form-field">
            <asp:Label runat="server" AssociatedControlID="txtLinkedIn" CssClass="form-label" Text="LinkedIn link" />
            <asp:TextBox ID="txtLinkedIn" runat="server" CssClass="form-input" MaxLength="250" TextMode="Url" placeholder="https://www.linkedin.com/in/username" />
            <asp:RegularExpressionValidator ID="revLinkedIn" runat="server" ControlToValidate="txtLinkedIn"
                Display="Dynamic" CssClass="form-error" ValidationExpression="^https?://\S+$"
                ErrorMessage="Start the link with http:// or https://" ValidationGroup="PersonalInfo" />
        </div>
    </div>

    <div class="form-field">
        <span class="form-label">Profile photo</span>
        <div class="avatar-edit">
            <asp:Image ID="imgAvatar" runat="server" CssClass="avatar-preview" AlternateText="Current profile photo" Visible="false" />
            <asp:Panel ID="pnlNoAvatar" runat="server" CssClass="avatar-preview avatar-placeholder">No photo</asp:Panel>
            <div class="avatar-controls">
                <asp:FileUpload ID="fuAvatar" runat="server" CssClass="form-file" accept=".jpg,.jpeg,.png,.gif" />
                <p class="form-hint">JPG, PNG or GIF, up to 5 MB. Leave empty to keep the current photo.</p>
            </div>
        </div>
    </div>

    <asp:Button ID="btnSave" runat="server" Text="Save changes" CssClass="pill-btn pill-btn-primary settings-submit"
        ValidationGroup="PersonalInfo" OnClick="btnSave_Click" />
</div>
