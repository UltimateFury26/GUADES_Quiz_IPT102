<%@ Page Title="Sign up" Language="C#" MasterPageFile="~/Auth.Master" AutoEventWireup="true" CodeBehind="Signup.aspx.cs" Inherits="_24_1571GuadesPersonalPortfolio.SignupPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="auth-title">Create your account</h1>
    <p class="auth-sub">Sign up to view the portfolio.</p>

    <asp:Panel ID="pnlMessage" runat="server" Visible="false" role="alert">
        <asp:Literal ID="litMessage" runat="server" Mode="Encode" />
    </asp:Panel>

    <asp:Panel ID="pnlForm" runat="server" CssClass="auth-form" DefaultButton="btnSignup">
        <div class="form-field">
            <asp:Label ID="lblUsername" runat="server" AssociatedControlID="txtUsername"
                CssClass="form-label" Text="Username" />
            <asp:TextBox ID="txtUsername" runat="server" CssClass="form-input" MaxLength="50"
                autocomplete="username" autocapitalize="none" spellcheck="false" />
            <asp:RequiredFieldValidator ID="rfvUsername" runat="server" ControlToValidate="txtUsername"
                Display="Dynamic" CssClass="form-error" ErrorMessage="Choose a username." />
            <asp:RegularExpressionValidator ID="revUsername" runat="server" ControlToValidate="txtUsername"
                Display="Dynamic" CssClass="form-error" ValidationExpression="^[A-Za-z0-9_]{4,50}$"
                ErrorMessage="Use 4 to 50 characters: letters, numbers or underscores only." />
            <asp:CustomValidator ID="cvUsernameTaken" runat="server"
                Display="Dynamic" CssClass="form-error" ErrorMessage="That username is already taken. Try another." />
        </div>

        <div class="form-field">
            <asp:Label ID="lblEmail" runat="server" AssociatedControlID="txtEmail"
                CssClass="form-label" Text="Email" />
            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-input" MaxLength="100"
                TextMode="Email" autocomplete="email" autocapitalize="none" spellcheck="false" />
            <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail"
                Display="Dynamic" CssClass="form-error" ErrorMessage="Enter your email." />
            <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail"
                Display="Dynamic" CssClass="form-error" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                ErrorMessage="Enter a valid email, like name@example.com." />
            <asp:CustomValidator ID="cvEmailTaken" runat="server"
                Display="Dynamic" CssClass="form-error" ErrorMessage="An account with that email already exists. Log in instead." />
        </div>

        <div class="form-field">
            <asp:Label ID="lblPhone" runat="server" AssociatedControlID="txtPhone"
                CssClass="form-label" Text="Phone number" />
            <asp:TextBox ID="txtPhone" runat="server" CssClass="form-input" MaxLength="11"
                TextMode="Phone" autocomplete="tel" inputmode="numeric" placeholder="09123456789" />
            <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone"
                Display="Dynamic" CssClass="form-error" ErrorMessage="Enter your phone number." />
            <asp:RegularExpressionValidator ID="revPhone" runat="server" ControlToValidate="txtPhone"
                Display="Dynamic" CssClass="form-error" ValidationExpression="^09[0-9]{9}$"
                ErrorMessage="Use 11 digits starting with 09." />
        </div>

        <div class="form-field">
            <asp:Label ID="lblPassword" runat="server" AssociatedControlID="txtPassword"
                CssClass="form-label" Text="Password" />
            <div class="password-field">
                <asp:TextBox ID="txtPassword" runat="server" ClientIDMode="Static" CssClass="form-input" TextMode="Password"
                    MaxLength="100" autocomplete="new-password" />
                <button type="button" class="password-toggle" aria-label="Show password">
                    <svg class="icon icon-eye" viewBox="0 0 24 24"><path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7-10-7-10-7z" /><circle cx="12" cy="12" r="3" /></svg>
                    <svg class="icon icon-eye-off" viewBox="0 0 24 24"><path d="M3 3l18 18" /><path d="M10.6 5.2A10.6 10.6 0 0 1 12 5c6.4 0 10 7 10 7a17.7 17.7 0 0 1-3.2 4.1M6.6 6.6C4 8.3 2 12 2 12s3.6 7 10 7c1.4 0 2.7-.3 3.9-.8" /><path d="M9.9 9.9a3 3 0 0 0 4.2 4.2" /></svg>
                </button>
            </div>
            <div class="pwd-strength" data-strength-for="txtPassword">
                <div class="pwd-strength-track"><div class="pwd-strength-fill" data-strength-fill></div></div>
                <span class="pwd-strength-label" data-strength-label></span>
            </div>
            <p class="form-hint">At least 8 characters, with a letter and a number.</p>
            <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword"
                Display="Dynamic" CssClass="form-error" ErrorMessage="Choose a password." />
            <asp:RegularExpressionValidator ID="revPassword" runat="server" ControlToValidate="txtPassword"
                Display="Dynamic" CssClass="form-error" ValidationExpression="^(?=.*[A-Za-z])(?=.*[0-9]).{8,100}$"
                ErrorMessage="That password doesn't meet the requirements." />
        </div>

        <div class="form-field">
            <asp:Label ID="lblConfirm" runat="server" AssociatedControlID="txtConfirm"
                CssClass="form-label" Text="Confirm password" />
            <div class="password-field">
                <asp:TextBox ID="txtConfirm" runat="server" CssClass="form-input" TextMode="Password"
                    MaxLength="100" autocomplete="new-password" />
                <button type="button" class="password-toggle" aria-label="Show password">
                    <svg class="icon icon-eye" viewBox="0 0 24 24"><path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7-10-7-10-7z" /><circle cx="12" cy="12" r="3" /></svg>
                    <svg class="icon icon-eye-off" viewBox="0 0 24 24"><path d="M3 3l18 18" /><path d="M10.6 5.2A10.6 10.6 0 0 1 12 5c6.4 0 10 7 10 7a17.7 17.7 0 0 1-3.2 4.1M6.6 6.6C4 8.3 2 12 2 12s3.6 7 10 7c1.4 0 2.7-.3 3.9-.8" /><path d="M9.9 9.9a3 3 0 0 0 4.2 4.2" /></svg>
                </button>
            </div>
            <asp:RequiredFieldValidator ID="rfvConfirm" runat="server" ControlToValidate="txtConfirm"
                Display="Dynamic" CssClass="form-error" ErrorMessage="Type your password again." />
            <asp:CompareValidator ID="cmpConfirm" runat="server" ControlToValidate="txtConfirm"
                ControlToCompare="txtPassword" Operator="Equal" Type="String"
                Display="Dynamic" CssClass="form-error" ErrorMessage="The passwords don't match." />
        </div>

        <asp:Button ID="btnSignup" runat="server" Text="Create account"
            CssClass="pill-btn pill-btn-primary auth-submit" OnClick="btnSignup_Click" />
    </asp:Panel>

    <p class="auth-foot">
        Already have an account? <a href="~/Login.aspx" runat="server">Log in</a>
    </p>
</asp:Content>
