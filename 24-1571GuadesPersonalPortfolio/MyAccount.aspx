<%@ Page Title="My Account" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MyAccount.aspx.cs" Inherits="_24_1571GuadesPersonalPortfolio.MyAccountPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="settings-title">My Account</h1>

    <div class="settings-grid">

        <!-- ACCOUNT INFORMATION -->
        <div class="settings-card">
            <h2>Account Information</h2>

            <asp:Panel ID="pnlAccountMessage" runat="server" Visible="false" role="alert">
                <asp:Literal ID="litAccountMessage" runat="server" Mode="Encode" />
            </asp:Panel>

            <div class="form-field">
                <span class="form-label">Username</span>
                <span class="readonly-field"><asp:Literal ID="litUsername" runat="server" Mode="Encode" /></span>
            </div>

            <div class="form-field">
                <asp:Label ID="lblEmail" runat="server" AssociatedControlID="txtEmail"
                    CssClass="form-label" Text="Email" />
                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-input" MaxLength="100"
                    TextMode="Email" autocomplete="email" autocapitalize="none" spellcheck="false" />
                <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail"
                    Display="Dynamic" CssClass="form-error" ErrorMessage="Enter your email." ValidationGroup="AccountInfo" />
                <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail"
                    Display="Dynamic" CssClass="form-error" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                    ErrorMessage="Enter a valid email, like name@example.com." ValidationGroup="AccountInfo" />
                <asp:CustomValidator ID="cvEmailTaken" runat="server"
                    Display="Dynamic" CssClass="form-error" ErrorMessage="Another account already uses that email."
                    ValidationGroup="AccountInfo" />
            </div>

            <div class="form-field">
                <asp:Label ID="lblPhone" runat="server" AssociatedControlID="txtPhone"
                    CssClass="form-label" Text="Phone number" />
                <asp:TextBox ID="txtPhone" runat="server" CssClass="form-input" MaxLength="11"
                    TextMode="Phone" autocomplete="tel" inputmode="numeric" placeholder="09123456789" />
                <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone"
                    Display="Dynamic" CssClass="form-error" ErrorMessage="Enter your phone number." ValidationGroup="AccountInfo" />
                <asp:RegularExpressionValidator ID="revPhone" runat="server" ControlToValidate="txtPhone"
                    Display="Dynamic" CssClass="form-error" ValidationExpression="^09[0-9]{9}$"
                    ErrorMessage="Use 11 digits starting with 09." ValidationGroup="AccountInfo" />
            </div>

            <asp:Button ID="btnSaveAccount" runat="server" Text="Save changes"
                CssClass="pill-btn pill-btn-primary settings-submit" ValidationGroup="AccountInfo"
                OnClick="btnSaveAccount_Click" />
        </div>

        <!-- CHANGE PASSWORD -->
        <div class="settings-card">
            <h2>Change Password</h2>

            <asp:Panel ID="pnlPasswordMessage" runat="server" Visible="false" role="alert">
                <asp:Literal ID="litPasswordMessage" runat="server" Mode="Encode" />
            </asp:Panel>

            <div class="form-field">
                <asp:Label ID="lblCurrentPassword" runat="server" AssociatedControlID="txtCurrentPassword"
                    CssClass="form-label" Text="Current password" />
                <div class="password-field">
                    <asp:TextBox ID="txtCurrentPassword" runat="server" CssClass="form-input" TextMode="Password"
                        MaxLength="100" autocomplete="current-password" />
                    <button type="button" class="password-toggle" aria-label="Show password">
                        <svg class="icon icon-eye" viewBox="0 0 24 24"><path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7-10-7-10-7z" /><circle cx="12" cy="12" r="3" /></svg>
                        <svg class="icon icon-eye-off" viewBox="0 0 24 24"><path d="M3 3l18 18" /><path d="M10.6 5.2A10.6 10.6 0 0 1 12 5c6.4 0 10 7 10 7a17.7 17.7 0 0 1-3.2 4.1M6.6 6.6C4 8.3 2 12 2 12s3.6 7 10 7c1.4 0 2.7-.3 3.9-.8" /><path d="M9.9 9.9a3 3 0 0 0 4.2 4.2" /></svg>
                    </button>
                </div>
                <asp:RequiredFieldValidator ID="rfvCurrentPassword" runat="server" ControlToValidate="txtCurrentPassword"
                    Display="Dynamic" CssClass="form-error" ErrorMessage="Enter your current password." ValidationGroup="ChangePassword" />
                <asp:CustomValidator ID="cvWrongCurrentPassword" runat="server"
                    Display="Dynamic" CssClass="form-error" ErrorMessage="That current password is incorrect."
                    ValidationGroup="ChangePassword" />
            </div>

            <div class="form-field">
                <asp:Label ID="lblNewPassword" runat="server" AssociatedControlID="txtNewPassword"
                    CssClass="form-label" Text="New password" />
                <div class="password-field">
                    <asp:TextBox ID="txtNewPassword" runat="server" ClientIDMode="Static" CssClass="form-input" TextMode="Password"
                        MaxLength="100" autocomplete="new-password" />
                    <button type="button" class="password-toggle" aria-label="Show password">
                        <svg class="icon icon-eye" viewBox="0 0 24 24"><path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7-10-7-10-7z" /><circle cx="12" cy="12" r="3" /></svg>
                        <svg class="icon icon-eye-off" viewBox="0 0 24 24"><path d="M3 3l18 18" /><path d="M10.6 5.2A10.6 10.6 0 0 1 12 5c6.4 0 10 7 10 7a17.7 17.7 0 0 1-3.2 4.1M6.6 6.6C4 8.3 2 12 2 12s3.6 7 10 7c1.4 0 2.7-.3 3.9-.8" /><path d="M9.9 9.9a3 3 0 0 0 4.2 4.2" /></svg>
                    </button>
                </div>
                <div class="pwd-strength" data-strength-for="txtNewPassword">
                    <div class="pwd-strength-track"><div class="pwd-strength-fill" data-strength-fill></div></div>
                    <span class="pwd-strength-label" data-strength-label></span>
                </div>
                <p class="form-hint">At least 8 characters, with a letter and a number.</p>
                <asp:RequiredFieldValidator ID="rfvNewPassword" runat="server" ControlToValidate="txtNewPassword"
                    Display="Dynamic" CssClass="form-error" ErrorMessage="Choose a new password." ValidationGroup="ChangePassword" />
                <asp:RegularExpressionValidator ID="revNewPassword" runat="server" ControlToValidate="txtNewPassword"
                    Display="Dynamic" CssClass="form-error" ValidationExpression="^(?=.*[A-Za-z])(?=.*[0-9]).{8,100}$"
                    ErrorMessage="That password doesn't meet the requirements." ValidationGroup="ChangePassword" />
            </div>

            <div class="form-field">
                <asp:Label ID="lblConfirmNewPassword" runat="server" AssociatedControlID="txtConfirmNewPassword"
                    CssClass="form-label" Text="Confirm new password" />
                <div class="password-field">
                    <asp:TextBox ID="txtConfirmNewPassword" runat="server" CssClass="form-input" TextMode="Password"
                        MaxLength="100" autocomplete="new-password" />
                    <button type="button" class="password-toggle" aria-label="Show password">
                        <svg class="icon icon-eye" viewBox="0 0 24 24"><path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7-10-7-10-7z" /><circle cx="12" cy="12" r="3" /></svg>
                        <svg class="icon icon-eye-off" viewBox="0 0 24 24"><path d="M3 3l18 18" /><path d="M10.6 5.2A10.6 10.6 0 0 1 12 5c6.4 0 10 7 10 7a17.7 17.7 0 0 1-3.2 4.1M6.6 6.6C4 8.3 2 12 2 12s3.6 7 10 7c1.4 0 2.7-.3 3.9-.8" /><path d="M9.9 9.9a3 3 0 0 0 4.2 4.2" /></svg>
                    </button>
                </div>
                <asp:RequiredFieldValidator ID="rfvConfirmNewPassword" runat="server" ControlToValidate="txtConfirmNewPassword"
                    Display="Dynamic" CssClass="form-error" ErrorMessage="Type the new password again." ValidationGroup="ChangePassword" />
                <asp:CompareValidator ID="cmpConfirmNewPassword" runat="server" ControlToValidate="txtConfirmNewPassword"
                    ControlToCompare="txtNewPassword" Operator="Equal" Type="String"
                    Display="Dynamic" CssClass="form-error" ErrorMessage="The passwords don't match." ValidationGroup="ChangePassword" />
            </div>

            <asp:Button ID="btnChangePassword" runat="server" Text="Change password"
                CssClass="pill-btn pill-btn-primary settings-submit" ValidationGroup="ChangePassword"
                OnClick="btnChangePassword_Click" />
        </div>

    </div>
</asp:Content>
